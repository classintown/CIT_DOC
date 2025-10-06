# ===== ClassInTown Monitor – PS5.1 compatible & hardened =====
$Urls = @(
  "https://dev.classintown.com/admin/users"

  # add more URLs here
)

$Root       = "C:\CIT-ping"
$TxtPath    = Join-Path $Root "cit_ping.log"
$CsvPath    = Join-Path $Root "cit_ping.csv"
$TimeoutSec = 15
$Retries    = 2
$BackoffSec = 3
$UA         = "CIT-Monitor/1.5 (+windows)"

New-Item -ItemType Directory -Force -Path $Root | Out-Null

function Rotate([string]$p,[int]$limitMB=5,[int]$copies=3){
  if(!(Test-Path $p)){return}
  if(((Get-Item $p).Length/1MB) -lt $limitMB){return}
  for($i=$copies;$i-ge 1;$i--){
    $src = if($i -eq 1){$p}else{"$p." + ($i-1)}
    $dst = "$p.$i"
    if(Test-Path $src){Move-Item -Force $src $dst}
  }
}

function ParseDouble([string]$s){
  $d = 0.0
  if ([string]::IsNullOrWhiteSpace($s)) { return 0.0 }
  if ([double]::TryParse($s, [ref]$d)) { return $d } else { return 0.0 }
}

function FormatTime([double]$seconds){
  if ($seconds -lt 60) {
    return "0 min {0:N3} sec" -f $seconds
  } else {
    $minutes = [math]::Floor($seconds / 60)
    $remainingSeconds = $seconds % 60
    return "{0} min {1:N3} sec" -f $minutes, $remainingSeconds
  }
}

function CurlCheck([string]$u){
  # Add cache-busting parameter to ensure fresh requests
  $cacheBuster = "t=$(Get-Date -Format 'yyyyMMddHHmmss')"
  $separator = if ($u -match '\?') { '&' } else { '?' }
  $urlWithCacheBuster = "$u$separator$cacheBuster"
  
  # Follow redirects (-L), show errors (-sS), set timeouts, disable cache
  $fmt = "dns=%{time_namelookup} tcp=%{time_connect} tls=%{time_appconnect} ttfb=%{time_starttransfer} total=%{time_total} code=%{http_code} bytes=%{size_download} speed=%{speed_download} redirect=%{num_redirects} ssl_verify=%{ssl_verify_result} content_type=%{content_type}"
  $args = @(
    '-sS','-L',
    '--connect-timeout','6',
    '--max-time', $TimeoutSec,
    '-A', $UA,
    '-o','NUL',
    '-w', $fmt,
    '--header', 'Cache-Control: no-cache, no-store, must-revalidate',
    '--header', 'Pragma: no-cache',
    '--header', 'Expires: 0',
    '--url', $urlWithCacheBuster
  )

  # Capture both stdout and stderr, then make a single string (PS5.1-safe)
  $lines = & curl.exe @args 2>&1
  $all   = [string]::Join("`n", @($lines))

  # Build key=value dictionary from the metrics tokens we printed
  $kv = @{}
  if (-not [string]::IsNullOrWhiteSpace($all)) {
    $tokens = $all -split '\s+'
    foreach ($t in $tokens) {
      if ($t -match '=') {
        $parts = $t -split '=', 2
        if ($parts.Count -eq 2) { $kv[$parts[0]] = $parts[1] }
      }
    }
  }

  # Extract values safely
  $code  = 0;   if ($kv.ContainsKey('code'))  { [int]$code  = $kv['code'] }
  $dns   = ParseDouble($kv['dns'])
  $tcp   = ParseDouble($kv['tcp'])
  $tls   = ParseDouble($kv['tls'])
  $ttfb  = ParseDouble($kv['ttfb'])
  $total = ParseDouble($kv['total'])
  $bytes = ParseDouble($kv['bytes'])
  $speed = ParseDouble($kv['speed'])
  $redirects = 0; if ($kv.ContainsKey('redirect')) { [int]$redirects = $kv['redirect'] }
  $sslVerify = 0; if ($kv.ContainsKey('ssl_verify')) { [int]$sslVerify = $kv['ssl_verify'] }
  $contentType = ""; if ($kv.ContainsKey('content_type')) { $contentType = $kv['content_type'] }

  # Any non-metric text becomes the error message
  $errtxt = ''
  if ($all) {
    # keep only lines that do NOT contain a "code=###" token
    $errLines = @()
    foreach ($ln in ($all -split "`r?`n")) {
      if ($ln -notmatch '(^|\s)code=\d{3}(\s|$)') { $errLines += $ln }
    }
    if ($errLines.Count -gt 0) { $errtxt = [string]::Join(' | ', $errLines) }
  }

  [pscustomobject]@{
    code=$code; dns=$dns; tcp=$tcp; tls=$tls; ttfb=$ttfb; total=$total; bytes=$bytes; speed=$speed; 
    redirects=$redirects; sslVerify=$sslVerify; contentType=$contentType; err=$errtxt
  }
}

$ts = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
$overallOK = $true

foreach($url in $Urls){
  $tries=0; $r=$null
  do{
    $tries++
    $r = CurlCheck $url
    if ($r.code -ne 200) { Start-Sleep -Seconds ($BackoffSec * $tries) }
  } while ($r.code -ne 200 -and $tries -le (1 + $Retries))

  $line = ("{0}  URL={1}  code={2}  USER_WAIT={3}  ttfb={4}  dns={5}  tcp={6}  tls={7}  bytes={8}  speed={9}  redirects={10}  ssl_ok={11}  type={12}" -f `
           $ts,$url,$r.code,(FormatTime $r.total),(FormatTime $r.ttfb),(FormatTime $r.dns),(FormatTime $r.tcp),(FormatTime $r.tls),$r.bytes,$r.speed,$r.redirects,$r.sslVerify,$r.contentType)
  if (($r.code -eq 0 -or $r.code -ne 200) -and $r.err) { $line += "  ERROR: $($r.err)" }

  Rotate $TxtPath
  $line | Out-File -FilePath $TxtPath -Append -Encoding utf8

  $row = [pscustomobject]@{
    timestamp=$ts; url=$url; attempt=$tries; http_code=$r.code
    dns_s=("{0:N3}" -f $r.dns); tcp_s=("{0:N3}" -f $r.tcp); tls_s=("{0:N3}" -f $r.tls)
    ttfb_s=("{0:N3}" -f $r.ttfb); total_s=("{0:N3}" -f $r.total)
    bytes=$r.bytes; speedBps=$r.speed; redirects=$r.redirects; ssl_verify=$r.sslVerify; content_type=$r.contentType
    dns_formatted=(FormatTime $r.dns); tcp_formatted=(FormatTime $r.tcp); tls_formatted=(FormatTime $r.tls)
    ttfb_formatted=(FormatTime $r.ttfb); total_formatted=(FormatTime $r.total)
    user_wait_time=(FormatTime $r.total); user_wait_seconds=("{0:N3}" -f $r.total)
  }

  Rotate $CsvPath
  $ok=$false; $w=0
  while(-not $ok -and $w -lt 3){
    try { $row | Export-Csv -Path $CsvPath -Append -NoTypeInformation -Encoding utf8; $ok=$true }
    catch { Start-Sleep -Milliseconds 300; $w++ }
  }

  if ($r.code -ne 200) { $overallOK = $false }
}

exit ($(if ($overallOK) { 0 } else { 2 }))
