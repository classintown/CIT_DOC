# ============================================================================
# QUICK DELETE - One Command Solution
# ============================================================================
# Usage: .\quick-delete-future-events.ps1 "YOUR_TOKEN" "YOUR_EMAIL"
# ============================================================================

param(
    [Parameter(Mandatory=$true)]
    [string]$Token,
    
    [Parameter(Mandatory=$true)]
    [string]$Email,
    
    [string]$BaseUrl = "http://localhost:2000"
)

$headers = @{ "Authorization" = "Bearer $Token"; "Content-Type" = "application/json" }
$now = Get-Date

Write-Host "`n[DELETE] Deleting future calendar events for: $Email`n" -ForegroundColor Cyan

# Fetch events
try {
    Write-Host "Fetching events..." -ForegroundColor Yellow
    $resp = Invoke-RestMethod -Uri "$BaseUrl/calendars/events/user" -Headers $headers -Method Get
    Write-Host "Total events returned: $($resp.data.Count)" -ForegroundColor Yellow
    
    $future = @()
    $skipped = 0
    $resp.data | ForEach-Object {
        try {
            $dateStr = if ($_.start.dateTime) { $_.start.dateTime } else { $_.start.date }
            # Convert "M/d/yyyy HH:mm:ss" format to DateTime
            $st = [DateTime]::ParseExact($dateStr, "M/d/yyyy HH:mm:ss", $null)
            if ($st -gt $now) {
                $future += $_
            }
        } catch {
            $skipped++
            Write-Host "  [SKIP] Unable to parse: $($_.summary) (date: $dateStr)" -ForegroundColor DarkGray
        }
    }
    
    Write-Host "Found $($future.Count) future events (skipped $skipped unparseable)`n" -ForegroundColor Green
    
    if ($future.Count -eq 0) { 
        Write-Host "Nothing to delete!`n" -ForegroundColor Green
        exit 0 
    }
    
    # Show list
    $future | ForEach-Object { 
        try {
            $dateStr = if ($_.start.dateTime) { $_.start.dateTime } else { $_.start.date }
            $st = [DateTime]::ParseExact($dateStr, "M/d/yyyy HH:mm:ss", $null)
            $formatted = $st.ToString('MM/dd HH:mm')
            Write-Host "  - [$formatted] $($_.summary)" -ForegroundColor Gray
        } catch {
            Write-Host "  - [unknown] $($_.summary)" -ForegroundColor Gray
        }
    }
    
    Write-Host "`nType YES to delete all: " -NoNewline -ForegroundColor Yellow
    if ((Read-Host) -ne "YES") { Write-Host "Cancelled`n" -ForegroundColor Red; exit 0 }
    
    # Delete
    Write-Host "`nDeleting..." -ForegroundColor Yellow
    $ok = 0; $fail = 0
    $future | ForEach-Object {
        try {
            Invoke-RestMethod -Uri "$BaseUrl/calendars/$($_.id)" -Headers $headers -Method Delete | Out-Null
            Write-Host "[OK] $($_.summary)" -ForegroundColor Green
            $ok++
        } catch {
            if ($_.Exception.Response.StatusCode.value__ -in @(404,410)) { $ok++ } else { $fail++; Write-Host "[FAIL] $($_.summary)" -ForegroundColor Red }
        }
        Start-Sleep -Milliseconds 50
    }
    
    Write-Host "`n[DONE] Deleted: $ok, Failed: $fail`n" -ForegroundColor Green
    
} catch {
    Write-Host "`n[ERROR] $_`n" -ForegroundColor Red
    exit 1
}
