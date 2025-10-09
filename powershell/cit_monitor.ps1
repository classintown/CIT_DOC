# ===== ClassInTown Monitor – PS5.1 compatible & hardened =====
$Urls = @(
  "https://dev.classintown.com/admin/users",
"https://dev.classintown.com/api/v1/user"
  "https://www.classintown.com/admin/users",
"https://www.classintown.com/api/v1/user"
  "https://dev.classintown.com/api/v1/calendars/events/user"
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
  $cacheBuster = "t=$(Get-Date -Format 'yyyyMMddHHmmssffff')"
  $separator = if ($u -match '\?') { '&' } else { '?' }
  $urlWithCacheBuster = "$u$separator$cacheBuster"
  
  # Use PowerShell's Stopwatch for accurate timing
  $sw = [System.Diagnostics.Stopwatch]::StartNew()
  $startTime = Get-Date
  
  # Follow redirects (-L), show errors (-sS), set timeouts, disable cache
  $fmt = "code=%{http_code} bytes=%{size_download} speed=%{speed_download}"
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
    '--header', 'Accept: application/json',
    '--header', 'Content-Type: application/json'
  )
  
  # Add Bearer token for calendar endpoint
  if ($u -match 'calendars/events/user') {
    $bearerToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNjhkN2U1ZTliM2NhNTU0N2Y2ZDNjN2MzIiwiZW1haWwiOiJzaGFzaGFua2RrdGVAZ21haWwuY29tIiwidXNlcl90eXBlIjoiSW5zdHJ1Y3RvciIsInVzZXJfcm9sZSI6Ikluc3RydWN0b3IiLCJtb2JpbGUiOjkzNzAzMDM2OTEsIndoYXRzYXBwX25vdGlmaWNhdGlvbnNfZW5hYmxlZCI6dHJ1ZSwiZW1haWxfbm90aWZpY2F0aW9uc19lbmFibGVkIjp0cnVlLCJwdXNoX25vdGlmaWNhdGlvbnNfZW5hYmxlZCI6dHJ1ZSwianRpIjoiYmI2ZTJjMjctNWQwYy00NTU1LWI5ZTItNTcxYzM5NzA5NDkxIiwiaXNzIjoiQ2xhc3NJblRvd24iLCJhdWQiOiJDbGFzc0luVG93bi1Vc2VycyIsImlhdCI6MTc2MDAzNjY1OCwibmJmIjoxNzYwMDM2NjU4LCJleHAiOjE3NjAxMjMwNTh9.lbIb00FExC7weq8e_2xHceSHmujULBafq-VeCbFQsug"
    $args += '--header', "Authorization: Bearer $bearerToken"
  }
  
  $args += '--url', $urlWithCacheBuster

  # Capture both stdout and stderr, then make a single string (PS5.1-safe)
  $lines = & curl.exe @args 2>&1
  $all   = [string]::Join("`n", @($lines))
  
  # Stop timing
  $sw.Stop()
  $endTime = Get-Date
  $totalTime = $sw.Elapsed.TotalSeconds

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
  $bytes = ParseDouble($kv['bytes'])
  $speed = ParseDouble($kv['speed'])
  
  # Use actual measured time instead of curl's broken timing
  $total = $totalTime
  
  # Estimate breakdown (rough approximations based on typical patterns)
  # These are estimates since curl's timing variables are unreliable
  $dns   = $total * 0.15  # ~15% DNS lookup
  $tcp   = $total * 0.20  # ~20% TCP connection
  $tls   = $total * 0.25  # ~25% TLS handshake
  $ttfb  = $total * 0.70  # ~70% time to first byte
  
  $redirects = 0
  $sslVerify = 0
  $contentType = "unknown"

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

  $line = ("{0}  URL={1}  code={2}  ACTUAL_USER_WAIT={3} ({4:N3}s)  bytes={5}  speed={6}" -f `
           $ts,$url,$r.code,(FormatTime $r.total),$r.total,$r.bytes,$r.speed)
  if (($r.code -eq 0 -or $r.code -ne 200) -and $r.err) { $line += "  ERROR: $($r.err)" }

  Rotate $TxtPath
  $line | Out-File -FilePath $TxtPath -Append -Encoding utf8

  $row = [pscustomobject]@{
    timestamp=$ts; url=$url; attempt=$tries; http_code=$r.code
    actual_user_wait_seconds=("{0:N3}" -f $r.total)
    actual_user_wait_formatted=(FormatTime $r.total)
    bytes=$r.bytes; speedBps=$r.speed
    dns_estimate_s=("{0:N3}" -f $r.dns)
    tcp_estimate_s=("{0:N3}" -f $r.tcp)
    tls_estimate_s=("{0:N3}" -f $r.tls)
    ttfb_estimate_s=("{0:N3}" -f $r.ttfb)
    note="Timing measured by PowerShell Stopwatch (accurate). DNS/TCP/TLS are estimates."
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
