# ClassInTown Load Testing & Analytics Guide

## Overview
This comprehensive load testing script helps you:
- **Stress test** your backend to find breaking points
- **Track capacity** - how many requests per second your system can handle
- **Monitor downtime** - when endpoints go down and when they recover
- **Analyze performance** - detailed metrics for every request
- **Simulate worldwide traffic** - test from different geographic locations
- **Database monitoring** - track DB-specific endpoints

## Quick Start

### Basic Load Test (10 minutes, 50 concurrent requests)
```powershell
cd C:\CIT-ping
powershell -ExecutionPolicy Bypass -File .\cit_load_test.ps1
```

### Custom Parameters
```powershell
# Test with 200 concurrent requests for 30 minutes
powershell -ExecutionPolicy Bypass -File .\cit_load_test.ps1 -MaxConcurrentRequests 200 -TestDurationMinutes 30

# Stress test mode (pushes system to failure)
powershell -ExecutionPolicy Bypass -File .\cit_load_test.ps1 -StressTest -MaxConcurrentRequests 500

# Quick capacity test (5 minutes, 100 requests/sec target)
powershell -ExecutionPolicy Bypass -File .\cit_load_test.ps1 -RequestsPerSecondTarget 100 -TestDurationMinutes 5
```

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `MaxConcurrentRequests` | 100 | Maximum number of simultaneous requests |
| `RampUpSeconds` | 30 | Time to gradually increase load (prevents instant spike) |
| `TestDurationMinutes` | 10 | How long to run the test |
| `RequestsPerSecondTarget` | 50 | Target requests per second |
| `StressTest` | false | Enable stress test mode (pushes beyond limits) |

## What Gets Tested

The script automatically tests these endpoints:
1. **Admin Users** - `https://dev.classintown.com/admin/users` (UI, Critical)
2. **User API** - `https://dev.classintown.com/api/v1/user` (API, Critical)
3. **Health Check** - `https://dev.classintown.com/api/health` (Health)
4. **DB Status** - `https://dev.classintown.com/api/status` (DB, Critical)
5. **Login** - `https://dev.classintown.com/login` (UI, Critical)

### Adding More Endpoints
Edit the script and add to the `$Endpoints` array:
```powershell
@{Name="My Endpoint"; Url="https://dev.classintown.com/my/api"; Type="API"; Critical=$true}
```

## Output Files

### 1. `load_test.log`
Real-time log with every event:
```
2025-10-06 20:45:32.123 [INFO] ClassInTown Load Test Started
2025-10-06 20:45:32.456 [INFO] Testing Admin Users with 10 concurrent requests
2025-10-06 20:45:35.789 [ERROR] ENDPOINT DOWN: DB Status - Server error 503
2025-10-06 20:46:12.345 [WARN] ENDPOINT RECOVERED: DB Status after 0 min 36.556 sec
```

### 2. `load_test.csv`
Every single request with full details:
- Timestamp (millisecond precision)
- Endpoint name, URL, type
- Geographic location simulation
- HTTP status code
- Success/failure status
- DNS, TCP, TLS, TTFB timings (3 decimal places)
- Total user wait time
- Bytes transferred, speed
- Number of redirects
- Error messages

### 3. `load_test_analytics.csv`
Statistical analysis per endpoint:
- **Total requests**
- **Min/Max/Average response times**
- **Median response time**
- **P95** (95th percentile - 95% of requests faster than this)
- **P99** (99th percentile - 99% of requests faster than this)
- All times in both seconds (3 decimals) and "X min Y.Z sec" format

### 4. `capacity_report.csv`
Requests per second analysis:
- Every second of the test
- How many requests were sent
- How many succeeded/failed
- Success rate percentage
- Average response time for that second

### 5. `downtime_report.csv`
Downtime incidents (only created if downtime occurs):
- Which endpoint went down
- Exact time it went down (millisecond precision)
- Exact time it came back up
- Total downtime duration
- Formatted downtime duration

## Understanding the Results

### Finding Your System's Capacity
1. Look at `capacity_report.csv`
2. Find where success rate starts dropping below 95%
3. That's your maximum sustainable requests per second

Example:
```csv
Second,TotalRequests,Successful,Failed,SuccessRate,AvgResponseTime
2025-10-06 20:45:30,50,50,0,100.00,0.234
2025-10-06 20:45:31,75,75,0,100.00,0.289
2025-10-06 20:45:32,100,98,2,98.00,0.456
2025-10-06 20:45:33,125,110,15,88.00,1.234  ← System struggling here
```
**Conclusion**: System can handle ~100 requests/second reliably.

### Analyzing Downtime
Check `downtime_report.csv`:
```csv
Endpoint,DownAt,UpAt,DowntimeSeconds,DowntimeFormatted
DB Status,2025-10-06 20:45:35.789,2025-10-06 20:46:12.345,36.556,0 min 36.556 sec
```
**Conclusion**: DB endpoint was down for 36.556 seconds under load.

### Performance Metrics
Check `load_test_analytics.csv`:
```csv
Endpoint,TotalRequests,MinResponseTime,MaxResponseTime,AvgResponseTime,P95ResponseTime,P99ResponseTime
Admin Users,5000,0.123,5.678,0.456,1.234,2.345
```

**What this means:**
- **Min (0.123s)**: Fastest response
- **Avg (0.456s)**: Typical response time
- **P95 (1.234s)**: 95% of users wait less than this
- **P99 (2.345s)**: 99% of users wait less than this
- **Max (5.678s)**: Slowest response (possibly during peak load)

### Geographic Simulation
The script simulates requests from 6 locations:
- **US-East** (20ms latency)
- **US-West** (50ms latency)
- **Europe** (100ms latency)
- **Asia** (150ms latency)
- **Australia** (200ms latency)
- **South America** (180ms latency)

This helps you understand how users worldwide experience your site.

## Stress Testing Mode

### What It Does
```powershell
powershell -ExecutionPolicy Bypass -File .\cit_load_test.ps1 -StressTest -MaxConcurrentRequests 500
```

1. Starts with low load
2. Gradually increases (ramp-up period)
3. After ramp-up, keeps increasing beyond max
4. Continues until system breaks or test ends
5. Records exactly when and how system failed

### Use Cases
- Find breaking point of your infrastructure
- Test auto-scaling behavior
- Verify error handling under extreme load
- Capacity planning for future growth

### What to Watch For
- At what point does success rate drop?
- Do endpoints go down? Which ones first?
- How long does recovery take?
- Are errors graceful or catastrophic?

## Real-World Scenarios

### Scenario 1: Pre-Launch Capacity Test
```powershell
# Test for 1 hour with expected peak traffic
powershell -ExecutionPolicy Bypass -File .\cit_load_test.ps1 -MaxConcurrentRequests 200 -TestDurationMinutes 60 -RequestsPerSecondTarget 150
```
**Goal**: Verify system can handle launch day traffic.

### Scenario 2: Find Breaking Point
```powershell
# Stress test until failure
powershell -ExecutionPolicy Bypass -File .\cit_load_test.ps1 -StressTest -MaxConcurrentRequests 1000 -TestDurationMinutes 30
```
**Goal**: Know your limits before users find them.

### Scenario 3: Database Performance
```powershell
# Focus on DB endpoints with sustained load
powershell -ExecutionPolicy Bypass -File .\cit_load_test.ps1 -MaxConcurrentRequests 300 -TestDurationMinutes 20
```
**Goal**: Test database connection pooling and query performance.

### Scenario 4: Quick Health Check
```powershell
# 2-minute quick test
powershell -ExecutionPolicy Bypass -File .\cit_load_test.ps1 -MaxConcurrentRequests 50 -TestDurationMinutes 2
```
**Goal**: Verify system is healthy after deployment.

## Metrics Explained

### DNS Time
Time to resolve domain name to IP address.
- **Good**: < 0.050s (50ms)
- **Acceptable**: 0.050-0.200s
- **Poor**: > 0.200s

### TCP Time
Time to establish TCP connection.
- **Good**: < 0.100s (100ms)
- **Acceptable**: 0.100-0.300s
- **Poor**: > 0.300s

### TLS Time
Time for SSL/TLS handshake.
- **Good**: < 0.150s (150ms)
- **Acceptable**: 0.150-0.500s
- **Poor**: > 0.500s

### TTFB (Time To First Byte)
Time until server starts sending response.
- **Good**: < 0.200s (200ms)
- **Acceptable**: 0.200-1.000s
- **Poor**: > 1.000s

### Total Time (USER_WAIT)
Complete time user waits for full response.
- **Good**: < 0.500s (500ms)
- **Acceptable**: 0.500-2.000s
- **Poor**: > 2.000s

## Troubleshooting

### Script Won't Start
```powershell
# Check execution policy
Get-ExecutionPolicy

# If restricted, run as:
powershell -ExecutionPolicy Bypass -File .\cit_load_test.ps1
```

### Too Many Timeouts
- Reduce `MaxConcurrentRequests`
- Increase `TimeoutSec` in script (line 30)
- Check network connectivity

### System Crashes During Test
- Start with lower `MaxConcurrentRequests`
- Use longer `RampUpSeconds` (e.g., 60)
- Don't use `-StressTest` initially

### Want More/Less Detail
Edit the script:
- More endpoints: Add to `$Endpoints` array (line 15)
- Different timeout: Change `$TimeoutSec` (line 30)
- Longer/shorter tests: Use `-TestDurationMinutes` parameter

## Best Practices

1. **Start Small**: Begin with low concurrent requests, increase gradually
2. **Baseline First**: Run normal monitoring script first to establish baseline
3. **Off-Peak Testing**: Run load tests during low-traffic periods
4. **Monitor Server**: Watch server CPU, memory, disk during tests
5. **Incremental Stress**: Don't jump straight to stress test mode
6. **Document Results**: Keep analytics CSVs for comparison over time
7. **Test After Changes**: Run tests after infrastructure or code changes

## Interpreting Results for Decisions

### "Should I upgrade my server?"
- If P95 response time > 1 second at expected load → Yes
- If success rate < 99% at expected load → Yes
- If frequent downtime events → Yes

### "How many users can I support?"
- Find max RPS with 99%+ success rate
- Assume 1 user = 2-5 requests per minute
- Max users ≈ (Max RPS × 60) / 3

Example: 100 RPS sustained = ~2,000 concurrent users

### "Is my database the bottleneck?"
- Compare response times: DB endpoints vs UI endpoints
- If DB endpoints 2x+ slower → Database is bottleneck
- Check `load_test_analytics.csv` for DB Status endpoint

### "Do I need a CDN?"
- If geographic simulation shows high latency → Yes
- If bytes transferred is high + slow speed → Yes
- If static content endpoints are slow → Yes

## Advanced Usage

### Schedule Regular Tests
Create a Windows Task Scheduler job:
```powershell
# Run every night at 2 AM
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-ExecutionPolicy Bypass -File C:\CIT-ping\cit_load_test.ps1 -TestDurationMinutes 15'
$trigger = New-ScheduledTaskTrigger -Daily -At 2am
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "CIT-LoadTest" -Description "Nightly load test"
```

### Compare Before/After
```powershell
# Before optimization
powershell -ExecutionPolicy Bypass -File .\cit_load_test.ps1 -TestDurationMinutes 10
Rename-Item load_test_analytics.csv load_test_analytics_BEFORE.csv

# After optimization
powershell -ExecutionPolicy Bypass -File .\cit_load_test.ps1 -TestDurationMinutes 10
Rename-Item load_test_analytics.csv load_test_analytics_AFTER.csv

# Compare the two files
```

### Integration with Monitoring
Run both scripts:
```powershell
# Terminal 1: Regular monitoring (every 5 minutes)
while($true) { 
  .\cit_monitor.ps1
  Start-Sleep -Seconds 300
}

# Terminal 2: Load test
.\cit_load_test.ps1 -TestDurationMinutes 30
```

## Support & Customization

### Need Different Endpoints?
Edit line 15-21 in `cit_load_test.ps1`:
```powershell
$Endpoints = @(
  @{Name="Your Endpoint"; Url="https://your-url.com/api"; Type="API"; Critical=$true}
)
```

### Need Different Metrics?
The curl format string (line 73) can be extended with:
- `%{size_header}` - Header size
- `%{size_request}` - Request size
- `%{remote_ip}` - Server IP
- `%{local_ip}` - Your IP

### Want Alerts?
Add to the script after line 200:
```powershell
if ($successRate -lt 95) {
  # Send email alert
  Send-MailMessage -To "admin@classintown.com" -Subject "Load Test Alert" -Body "Success rate: $successRate%"
}
```

## Summary

This load testing script gives you:
- ✅ **Precise capacity measurements** (requests per second)
- ✅ **Downtime tracking** (when, how long, which endpoints)
- ✅ **Performance analytics** (min, max, avg, P95, P99)
- ✅ **Geographic simulation** (worldwide user experience)
- ✅ **Stress testing** (find breaking points)
- ✅ **Detailed logs** (every request tracked)
- ✅ **Multiple reports** (CSV files for analysis)

Use it to make informed decisions about infrastructure, optimization, and capacity planning.
