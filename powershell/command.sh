powershell -NoProfile -ExecutionPolicy Bypass -File C:\CIT-ping\cit_monitor.ps1
Get-Content C:\CIT-ping\cit_ping.log -Tail 3
if (Test-Path C:\CIT-ping\cit_ping.csv) { Import-Csv C:\CIT-ping\cit_ping.csv | Select-Object -Last 3 }
