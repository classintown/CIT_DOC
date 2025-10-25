# ===========================================================================
# FLEXIBLE TEST DATA CREATION - CONFIGURABLE ENROLLMENT FLOW
# ===========================================================================
# This script allows you to specify HOW MANY of each entity to create:
# 
# USAGE EXAMPLES:
#   # Create 5 activities, 5 locations, 5 classes, 3 students, 2 enrollments each
#   .\create-test-data-flexible.ps1 -AuthToken "TOKEN" -Activities 5 -Locations 5 -Classes 5 -Students 3 -EnrollmentsPerStudent 2
#
#   # Quick single test (1 of everything)
#   .\create-test-data-flexible.ps1 -AuthToken "TOKEN" -Activities 1 -Locations 1 -Classes 1 -Students 1
#
#   # Create 10 activities and locations only (no students/enrollments)
#   .\create-test-data-flexible.ps1 -AuthToken "TOKEN" -Activities 10 -Locations 10 -Classes 0 -Students 0
#
#   # Large test dataset
#   .\create-test-data-flexible.ps1 -AuthToken "TOKEN" -Activities 30 -Locations 30 -Classes 20 -Students 50 -EnrollmentsPerStudent 3
# ===========================================================================

param(
    [string]$BaseUrl = "http://localhost:2000",
    [string]$AuthToken = "",
    
    # Entity counts - customize as needed
    [int]$Activities = 5,
    [int]$Locations = 5,
    [int]$Classes = 5,
    [int]$Students = 3,
    [int]$EnrollmentsPerStudent = 2,
    
    # Class distribution settings
    [int]$OnlineClassesPercent = 50,  # 50% online, 50% in-person
    [int]$CountBasedPercent = 50,     # 50% count-based, 50% duration-based
    
    # Other options
    [switch]$SkipPayments,
    [switch]$Verbose
)

# ===========================================================================
# VALIDATION
# ===========================================================================

if (-not $AuthToken) {
    Write-Host "Error: Auth token required!" -ForegroundColor Red
    Write-Host "Usage: .\create-test-data-flexible.ps1 -AuthToken 'YOUR_TOKEN' [options]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Parameters:" -ForegroundColor Cyan
    Write-Host "  -Activities <int>              Number of activities to create (default: 5)" -ForegroundColor White
    Write-Host "  -Locations <int>               Number of locations to create (default: 5)" -ForegroundColor White
    Write-Host "  -Classes <int>                 Number of classes to create (default: 5)" -ForegroundColor White
    Write-Host "  -Students <int>                Number of students to create (default: 3)" -ForegroundColor White
    Write-Host "  -EnrollmentsPerStudent <int>   Enrollments per student (default: 2)" -ForegroundColor White
    Write-Host "  -OnlineClassesPercent <int>    % of online classes (default: 50)" -ForegroundColor White
    Write-Host "  -CountBasedPercent <int>       % of count-based classes (default: 50)" -ForegroundColor White
    Write-Host "  -SkipPayments                  Skip payment plan creation" -ForegroundColor White
    Write-Host "  -Verbose                       Show detailed progress" -ForegroundColor White
    exit 1
}

# Validate dependencies
if ($Classes -gt 0 -and ($Activities -eq 0 -or $Locations -eq 0)) {
    Write-Host "ERROR: Cannot create classes without activities and locations!" -ForegroundColor Red
    Write-Host "Please specify at least -Activities 1 -Locations 1" -ForegroundColor Yellow
    exit 1
}

if ($Students -gt 0 -and $Classes -eq 0) {
    Write-Host "WARNING: Creating students but no classes. Enrollments will not be possible." -ForegroundColor Yellow
    Start-Sleep -Seconds 2
}

if ($EnrollmentsPerStudent -gt $Classes) {
    Write-Host "WARNING: EnrollmentsPerStudent ($EnrollmentsPerStudent) exceeds Classes ($Classes)" -ForegroundColor Yellow
    Write-Host "Adjusting to $Classes enrollments per student" -ForegroundColor Yellow
    $EnrollmentsPerStudent = $Classes
}

$headers = @{
    "Authorization" = "Bearer $AuthToken"
    "Content-Type" = "application/json"
    "Accept" = "application/json"
}

$script:CreatedActivities = @()
$script:CreatedLocations = @()
$script:CreatedClasses = @()
$script:CreatedStudents = @()
$script:StudentTokens = @{}
$script:Enrollments = @()
$script:PaymentPlans = @()
$script:StartTime = Get-Date
$script:InstructorId = ""

# ===========================================================================
# LOGGING FUNCTIONS
# ===========================================================================

function Write-Progress-Log {
    param(
        [string]$Message,
        [string]$Color = "Cyan"
    )
    $elapsed = (Get-Date) - $script:StartTime
    $timestamp = Get-Date -Format "HH:mm:ss"
    $elapsedStr = "{0:mm}:{0:ss}" -f $elapsed
    Write-Host "[$timestamp | Elapsed: $elapsedStr] $Message" -ForegroundColor $Color
}

function Write-Step-Header {
    param([string]$Step, [string]$Description)
    Write-Host ""
    Write-Host "===================================================================" -ForegroundColor Cyan
    Write-Host "  $Step - $Description" -ForegroundColor Cyan
    Write-Host "===================================================================" -ForegroundColor Cyan
    Write-Progress-Log "Starting: $Description" "Yellow"
}

function Write-Verbose-Log {
    param([string]$Message, [string]$Color = "Gray")
    if ($Verbose) {
        Write-Host "  $Message" -ForegroundColor $Color
    }
}

# ===========================================================================
# JWT TOKEN PARSER
# ===========================================================================

function Get-InstructorIdFromToken {
    param([string]$Token)
    
    try {
        $parts = $Token.Split('.')
        if ($parts.Length -ne 3) {
            Write-Host "ERROR: Invalid JWT token format" -ForegroundColor Red
            return $null
        }
        
        $payload = $parts[1]
        $padding = 4 - ($payload.Length % 4)
        if ($padding -ne 4) {
            $payload += "=" * $padding
        }
        
        $payloadBytes = [System.Convert]::FromBase64String($payload)
        $payloadJson = [System.Text.Encoding]::UTF8.GetString($payloadBytes)
        $payloadData = $payloadJson | ConvertFrom-Json
        
        return $payloadData.user_id
    }
    catch {
        Write-Host "ERROR: Failed to parse JWT token - $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# ===========================================================================
# MULTIPART UPLOAD HELPER
# ===========================================================================

function Invoke-MultipartUpload {
    param(
        [string]$Uri,
        [hashtable]$Headers,
        [hashtable]$Fields,
        [string]$FilePath,
        [string]$FileFieldName = "media"
    )
    
    Add-Type -AssemblyName System.Net.Http
    
    $httpClient = New-Object System.Net.Http.HttpClient
    $httpClient.Timeout = New-TimeSpan -Seconds 60
    
    if ($Headers["Authorization"]) {
        $httpClient.DefaultRequestHeaders.Add("Authorization", $Headers["Authorization"])
    }
    
    try {
        $form = New-Object System.Net.Http.MultipartFormDataContent
        
        foreach ($key in $Fields.Keys) {
            $value = $Fields[$key]
            $stringValue = ""
            
            if ($value -is [array]) {
                if ($value.Count -eq 1) {
                    $stringValue = "[$($value[0] | ConvertTo-Json -Compress)]"
                } else {
                    $stringValue = $value | ConvertTo-Json -Compress -Depth 5
                }
            }
            elseif ($value -is [hashtable]) {
                $stringValue = $value | ConvertTo-Json -Compress -Depth 5
            }
            elseif ($value -is [bool]) {
                $stringValue = $value.ToString().ToLower()
            }
            else {
                $stringValue = $value.ToString()
            }
            
            $stringContent = New-Object System.Net.Http.StringContent($stringValue)
            $form.Add($stringContent, $key)
        }
        
        if ($FilePath -and (Test-Path $FilePath)) {
            $fileStream = [System.IO.File]::OpenRead($FilePath)
            $fileContent = New-Object System.Net.Http.StreamContent($fileStream)
            $fileContent.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::Parse("image/svg+xml")
            $fileName = [System.IO.Path]::GetFileName($FilePath)
            $form.Add($fileContent, $FileFieldName, $fileName)
        }
        
        $response = $httpClient.PostAsync($Uri, $form).Result
        $responseContent = $response.Content.ReadAsStringAsync().Result
        
        if ($fileStream) {
            $fileStream.Close()
            $fileStream.Dispose()
        }
        
        if ($response.IsSuccessStatusCode) {
            return $responseContent | ConvertFrom-Json
        } else {
            throw "HTTP $($response.StatusCode): $responseContent"
        }
    }
    finally {
        if ($httpClient) {
            $httpClient.Dispose()
        }
        if ($form) {
            $form.Dispose()
        }
    }
}

# ===========================================================================
# INITIALIZATION
# ===========================================================================

Write-Host ""
Write-Host "===================================================================" -ForegroundColor Magenta
Write-Host "  FLEXIBLE TEST DATA CREATION" -ForegroundColor Magenta
Write-Host "===================================================================" -ForegroundColor Magenta

Write-Progress-Log "Extracting Instructor ID from JWT token..." "Yellow"
$script:InstructorId = Get-InstructorIdFromToken -Token $AuthToken
if (-not $script:InstructorId) {
    Write-Host "FATAL ERROR: Could not extract Instructor ID from token!" -ForegroundColor Red
    exit 1
}
Write-Progress-Log "Instructor ID: $($script:InstructorId)" "Green"

Write-Host ""
Write-Host "CONFIGURATION:" -ForegroundColor Cyan
Write-Host "   Activities: $Activities" -ForegroundColor White
Write-Host "   Locations: $Locations" -ForegroundColor White
Write-Host "   Classes: $Classes (${OnlineClassesPercent}% online, ${CountBasedPercent}% count-based)" -ForegroundColor White
Write-Host "   Students: $Students" -ForegroundColor White
Write-Host "   Enrollments per Student: $EnrollmentsPerStudent" -ForegroundColor White
Write-Host "   Skip Payments: $($SkipPayments.IsPresent)" -ForegroundColor White

# ===========================================================================
# STEP 1: CREATE ACTIVITIES
# ===========================================================================

if ($Activities -gt 0) {
    Write-Step-Header "STEP 1" "Creating $Activities Activities"
    
    $imagesPath = Join-Path $PSScriptRoot "images"
    $allImages = @()
    
    if (Test-Path $imagesPath) {
        $allImages = Get-ChildItem -Path $imagesPath -Filter "*.svg" | Select-Object -ExpandProperty FullName
        Write-Progress-Log "Found $($allImages.Count) SVG images" "Gray"
    }
    
    $activityTemplates = @(
        @{ Base = "Yoga"; Category = "Hatha"; Level = "Beginner"; Format = "Group"; Proficiency = "beginner" },
        @{ Base = "Yoga"; Category = "Vinyasa"; Level = "Intermediate"; Format = "Group"; Proficiency = "intermediate" },
        @{ Base = "Dance"; Category = "Ballet"; Level = "Kids"; Format = "Group"; Proficiency = "beginner" },
        @{ Base = "Dance"; Category = "Hip Hop"; Level = "Teen"; Format = "Group"; Proficiency = "intermediate" },
        @{ Base = "Martial Arts"; Category = "Karate"; Level = "White Belt"; Format = "Group"; Proficiency = "beginner" },
        @{ Base = "Music"; Category = "Piano"; Level = "Beginner"; Format = "One-on-one"; Proficiency = "beginner" },
        @{ Base = "Music"; Category = "Guitar"; Level = "Intermediate"; Format = "One-on-one"; Proficiency = "intermediate" },
        @{ Base = "Art"; Category = "Painting"; Level = "Hobby"; Format = "Group"; Proficiency = "beginner" },
        @{ Base = "Fitness"; Category = "Zumba"; Level = "Cardio"; Format = "Group"; Proficiency = "intermediate" },
        @{ Base = "Swimming"; Category = "Freestyle"; Level = "Beginner"; Format = "Group"; Proficiency = "beginner" }
    )
    
    for ($i = 0; $i -lt $Activities; $i++) {
        $template = $activityTemplates[$i % $activityTemplates.Count]
        $activityName = "$($template.Level) $($template.Category) $($template.Base) $(if ($i -ge $activityTemplates.Count) { "- Session $($i + 1)" })"
        
        Write-Progress-Log "[$(($i+1))/$Activities] Creating: $activityName..." "Gray"
        
        $mediaPath = ""
        if ($allImages.Count -gt 0) {
            $mediaPath = $allImages[$i % $allImages.Count]
        }
        
        $activityFields = @{
            activity_name = $activityName
            description = "Professional $($template.Level.ToLower()) level $($template.Category.ToLower()) training"
            category = @($template.Base)
            activity_type = "In Person"
            format = $template.Format
            skills = @(@{
                skill_name = $template.Category
                proficiency = $template.Proficiency
            })
            audience = @("All Ages")
            age_range = @{
                min = 5
                max = 65
            }
            adult_participation = "None"
            grades_assessment = "None"
            homework = $false
            pod_learning = $false
            requirements = "Basic fitness level"
            materials = @(@{
                material_name = "Mat"
                quantity = "1"
            })
            is_active = $true
            is_test_data = $true  # ⭐ FLAG AS TEST DATA
        }
        
        try {
            if ($mediaPath -and (Test-Path $mediaPath)) {
                $response = Invoke-MultipartUpload -Uri "$BaseUrl/activities/" -Headers $headers -Fields $activityFields -FilePath $mediaPath
            } else {
                $activityBody = $activityFields | ConvertTo-Json -Depth 5
                $response = Invoke-RestMethod -Uri "$BaseUrl/activities/" -Method POST -Headers $headers -Body $activityBody
            }
            
            $activityId = if ($response.data) { $response.data._id } else { $response._id }
            
            $script:CreatedActivities += @{
                Name = $activityName
                Id = $activityId
                Category = $template.Base
            }
            
            Write-Host "  [OK] Created: $activityId" -ForegroundColor Green
        }
        catch {
            Write-Host "  [FAIL] Failed: $($_.Exception.Message)" -ForegroundColor Yellow
        }
        
        Start-Sleep -Milliseconds 100
    }
    
    Write-Progress-Log "Created $($script:CreatedActivities.Count)/$Activities activities" "Green"
}

# ===========================================================================
# STEP 2: CREATE LOCATIONS
# ===========================================================================

if ($Locations -gt 0) {
    Write-Step-Header "STEP 2" "Creating $Locations Locations"
    
    $locationTemplates = @(
        @{ Type = "Center"; Area = "Andheri"; City = "Mumbai"; Region = "Western Suburbs" },
        @{ Type = "Studio"; Area = "Bandra"; City = "Mumbai"; Region = "Western Suburbs" },
        @{ Type = "Academy"; Area = "Borivali"; City = "Mumbai"; Region = "Western Suburbs" },
        @{ Type = "Institute"; Area = "Thane"; City = "Thane"; Region = "Thane" },
        @{ Type = "Club"; Area = "Vashi"; City = "Navi Mumbai"; Region = "Navi Mumbai" },
        @{ Type = "Hall"; Area = "Powai"; City = "Mumbai"; Region = "Eastern Suburbs" },
        @{ Type = "Gym"; Area = "Malad"; City = "Mumbai"; Region = "Western Suburbs" },
        @{ Type = "Arena"; Area = "Goregaon"; City = "Mumbai"; Region = "Western Suburbs" }
    )
    
    for ($i = 0; $i -lt $Locations; $i++) {
        $template = $locationTemplates[$i % $locationTemplates.Count]
        $locationName = "$($template.Area) $($template.Type)$(if ($i -ge $locationTemplates.Count) { " - Branch $($i + 1)" })"
        
        Write-Progress-Log "[$(($i+1))/$Locations] Creating: $locationName..." "Gray"
        
        $locationBody = @{
            title = $locationName
            address = "$(Get-Random -Minimum 1 -Maximum 999), $($template.Area) West"
            city = $template.City
            state = "Maharashtra"
            country = "India"
            pincode = "$(Get-Random -Minimum 400001 -Maximum 400999)"
            latitude = [decimal](19.0 + (Get-Random -Minimum 0 -Maximum 300) / 1000.0)
            longitude = [decimal](72.8 + (Get-Random -Minimum 0 -Maximum 300) / 1000.0)
            region = $template.Region
            place_type = $template.Type
            is_active = $true
            is_test_data = $true  # ⭐ FLAG AS TEST DATA
        } | ConvertTo-Json -Depth 5
        
        try {
            $response = Invoke-RestMethod -Uri "$BaseUrl/maps/enhanced" -Method POST -Headers $headers -Body $locationBody
            
            # Extract location ID from response (enhanced location returns { location: { _id: ... } })
            $locationId = $null
            if ($response.data -and $response.data.location -and $response.data.location._id) {
                $locationId = $response.data.location._id
            }
            elseif ($response.location -and $response.location._id) {
                $locationId = $response.location._id
            }
            elseif ($response.data -and $response.data._id) {
                $locationId = $response.data._id
            }
            elseif ($response._id) {
                $locationId = $response._id
            }
            elseif ($response.id) {
                $locationId = $response.id
            }
            elseif ($response.data -and $response.data.id) {
                $locationId = $response.data.id
            }
            
            $script:CreatedLocations += @{
                Name = $locationName
                Id = $locationId
                City = $template.City
            }
            
            if ($locationId) {
                Write-Host "  [OK] Created: $locationId" -ForegroundColor Green
            } else {
                Write-Host "  [WARNING] Created but no ID returned" -ForegroundColor Yellow
            }
        }
        catch {
            Write-Host "  [FAIL] Failed: $($_.Exception.Message)" -ForegroundColor Yellow
        }
        
        Start-Sleep -Milliseconds 100
    }
    
    Write-Progress-Log "Created $($script:CreatedLocations.Count)/$Locations locations" "Green"
}

# ===========================================================================
# STEP 3: FETCH COMPLETE DATA
# ===========================================================================

if ($Classes -gt 0) {
    Write-Step-Header "STEP 3" "Fetching Activity and Location Data"
    
    try {
        $response = Invoke-RestMethod -Uri "$BaseUrl/activities/active" -Method GET -Headers $headers
        $allActivities = if ($response.data) { $response.data } else { $response }
        if ($allActivities -isnot [array]) { $allActivities = @($allActivities) }
        Write-Progress-Log "Fetched $($allActivities.Count) activities" "Green"
    }
    catch {
        Write-Host "CRITICAL ERROR: Failed to fetch activities" -ForegroundColor Red
        exit 1
    }
    
    try {
        $response = Invoke-RestMethod -Uri "$BaseUrl/maps" -Method GET -Headers $headers
        $allLocations = if ($response.data) { $response.data } else { $response }
        if ($allLocations -isnot [array]) { $allLocations = @($allLocations) }
        Write-Progress-Log "Fetched $($allLocations.Count) locations" "Green"
    }
    catch {
        Write-Host "CRITICAL ERROR: Failed to fetch locations" -ForegroundColor Red
        exit 1
    }
}

# ===========================================================================
# STEP 4: CREATE CLASSES
# ===========================================================================

if ($Classes -gt 0) {
    Write-Step-Header "STEP 4" "Creating $Classes Class Schedules"
    
    function Get-FutureDateTime {
        param([int]$DaysFromNow = 7, [int]$Hour = 9, [int]$Minute = 0)
        $date = (Get-Date).AddDays($DaysFromNow).Date.AddHours($Hour).AddMinutes($Minute)
        return $date.ToUniversalTime().ToString("yyyy-MM-dd'T'HH:mm:ss.fff'Z'")
    }
    
    $timeSlots = @(
        @{ Hour = 6; Duration = 1 },
        @{ Hour = 9; Duration = 1 },
        @{ Hour = 14; Duration = 1.5 },
        @{ Hour = 17; Duration = 1 },
        @{ Hour = 19; Duration = 1 }
    )
    
    $weekDays = @("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")
    
    for ($i = 0; $i -lt $Classes; $i++) {
        $activity = $allActivities[(Get-Random -Minimum 0 -Maximum $allActivities.Count)]
        $location = $allLocations[(Get-Random -Minimum 0 -Maximum $allLocations.Count)]
        $timeSlot = $timeSlots[(Get-Random -Maximum $timeSlots.Count)]
        $day = $weekDays[(Get-Random -Maximum $weekDays.Count)]
        
        # Determine if online based on percentage
        $isOnline = ((Get-Random -Minimum 0 -Maximum 100) -lt $OnlineClassesPercent)
        
        # Determine if count-based based on percentage
        $isCountBased = ((Get-Random -Minimum 0 -Maximum 100) -lt $CountBasedPercent)
        $classType = if ($isCountBased) { "count" } else { "duration" }
        $sessionCount = if ($isCountBased) { Get-Random -Minimum 4 -Maximum 12 } else { 0 }
        
        $mode = if ($isOnline) { "ONLINE" } else { "IN-PERSON" }
        $typeLabel = if ($isCountBased) { "COUNT" } else { "DURATION" }
        
        Write-Progress-Log "[$(($i+1))/$Classes] Creating: $mode/$typeLabel - $($activity.activity_name)..." "Gray"
        
        # Calculate days to target day
        $baseDays = ($weekDays.IndexOf($day) - (Get-Date).DayOfWeek.value__)
        if ($baseDays -lt 0) { $baseDays += 7 }
        
        # Generate slots
        $slots = @()
        $slotCount = if ($isCountBased) { $sessionCount } else { 4 }
        
        for ($week = 0; $week -lt $slotCount; $week++) {
            $daysToAdd = $baseDays + ($week * 7)
            $startDateTime = Get-FutureDateTime -DaysFromNow $daysToAdd -Hour $timeSlot.Hour -Minute 0
            $endHour = $timeSlot.Hour + [Math]::Floor($timeSlot.Duration)
            $endMinute = ($timeSlot.Duration - [Math]::Floor($timeSlot.Duration)) * 60
            $endDateTime = Get-FutureDateTime -DaysFromNow $daysToAdd -Hour $endHour -Minute $endMinute
            
            $slots += @{
                start = @{
                    dateTime = $startDateTime
                    timeZone = "Asia/Calcutta"
                }
                end = @{
                    dateTime = $endDateTime
                    timeZone = "Asia/Calcutta"
                }
            }
        }
        
        $classBody = @{
            activity = @{
                _id = $activity._id.ToString()
                activity_name = $activity.activity_name.ToString()
                description = $activity.description.ToString()
            }
            is_online = $isOnline
            duration = 1
            classType = $classType
            schedules = @(
                @{
                    day = $day
                    slots = $slots
                }
            )
            is_full_price = $true
            full_price = (Get-Random -Minimum 5000 -Maximum 20000)
            capacity = (Get-Random -Minimum 10 -Maximum 50)
            is_drop_in_price = $false
            drop_in_price = 0
            is_free_activity = $false
            is_monthly_pricing = $false
            monthly_pricing = 0
            is_test_data = $true  # ⭐ FLAG AS TEST DATA
        }
        
        if ($isCountBased) {
            $classBody.classCount = $sessionCount
        }
        
        if (-not $isOnline) {
            $classBody.location = @{
                _id = $location._id.ToString()
                title = $location.title.ToString()
            }
            $classBody.class_link = ""
        } else {
            $classBody.class_link = "https://meet.google.com/$(Get-Random -Minimum 100000 -Maximum 999999)"
        }
        
        try {
            $response = Invoke-RestMethod -Uri "$BaseUrl/instructClass/" -Method POST -Headers $headers -Body ($classBody | ConvertTo-Json -Depth 10)
            $classId = if ($response.data) { $response.data._id } else { $response._id }
            
            $script:CreatedClasses += @{
                ClassId = $classId
                Activity = $activity.activity_name
                IsOnline = $isOnline
                ClassType = $classType
                Success = $true
            }
            
            Write-Host "  [OK] Created: $classId" -ForegroundColor Green
        }
        catch {
            Write-Host "  [FAIL] Failed: $($_.Exception.Message)" -ForegroundColor Yellow
            $script:CreatedClasses += @{
                ClassId = $null
                Activity = $activity.activity_name
                IsOnline = $isOnline
                ClassType = $classType
                Success = $false
            }
        }
        
        Start-Sleep -Milliseconds 2000
    }
    
    $successCount = ($script:CreatedClasses | Where-Object {$_.Success}).Count
    Write-Progress-Log "Created $successCount/$Classes classes" "Green"
}

# ===========================================================================
# STEP 5: CREATE STUDENTS
# ===========================================================================

if ($Students -gt 0) {
    Write-Step-Header "STEP 5" "Creating $Students Students"
    
    for ($i = 1; $i -le $Students; $i++) {
        $email = "student$i@test.com"
        Write-Progress-Log "[$i/$Students] Creating: $email..." "Gray"
        
        $studentBody = @{
            first_name = "Student$i"
            last_name = "Test"
            email = $email
            password = "Test@123"
            dob = "2005-01-01"
            address = ""
            pincode = ""
            profile_photo = ""
            mobile = "90000000$($i.ToString().PadLeft(2,'0'))"
            countryCode = "+91"
            instructorId = $script:InstructorId
            is_test_data = $true  # ⭐ FLAG AS TEST DATA
        } | ConvertTo-Json -Depth 5
        
        try {
            $response = Invoke-RestMethod -Uri "$BaseUrl/student" -Method POST -Headers $headers -Body $studentBody
            $studentData = if ($response.data) { $response.data } else { $response }
            
            $script:CreatedStudents += @{
                StudentUserId = $studentData.studentUser._id
                StudentDetailId = $studentData.studentDetail._id
                Email = $email
                Password = "Test@123"
            }
            
            Write-Host "  [OK] Created: $($studentData.studentUser._id)" -ForegroundColor Green
        }
        catch {
            Write-Host "  [FAIL] Failed: $($_.Exception.Message)" -ForegroundColor Yellow
        }
        
        Start-Sleep -Milliseconds 300
    }
    
    Write-Progress-Log "Created $($script:CreatedStudents.Count)/$Students students" "Green"
}

# ===========================================================================
# STEP 6: AUTHENTICATE STUDENTS
# ===========================================================================

if ($Students -gt 0 -and $script:CreatedStudents.Count -gt 0) {
    Write-Step-Header "STEP 6" "Authenticating Students"
    
    foreach ($student in $script:CreatedStudents) {
        Write-Verbose-Log "Logging in: $($student.Email)..."
        
        $loginBody = @{
            identifierType = "email"
            email = $student.Email
            password = $student.Password
        } | ConvertTo-Json
        
        try {
            $response = Invoke-RestMethod -Uri "$BaseUrl/auths/signIn" -Method POST -Headers @{"Content-Type"="application/json"} -Body $loginBody
            
            $tokenValue = if ($response.data -and $response.data.accessToken) { 
                $response.data.accessToken 
            } elseif ($response.accessToken) { 
                $response.accessToken 
            } else {
                $null
            }
            
            if ($tokenValue) {
                $script:StudentTokens[$student.StudentUserId.ToString()] = $tokenValue
            }
        }
        catch {
            Write-Verbose-Log "Auth failed: $($_.Exception.Message)" "Yellow"
        }
        
        Start-Sleep -Milliseconds 200
    }
    
    Write-Progress-Log "Authenticated $($script:StudentTokens.Count)/$($script:CreatedStudents.Count) students" "Green"
}

# ===========================================================================
# STEP 7: CREATE ENROLLMENT PROGRESS (Instructor-Side)
# ===========================================================================

$successfulClasses = $script:CreatedClasses | Where-Object {$_.Success}

if ($Students -gt 0 -and $successfulClasses.Count -gt 0 -and $EnrollmentsPerStudent -gt 0) {
    Write-Step-Header "STEP 7" "Initiating Enrollment Progress"
    
    $enrollmentInitCount = 0
    $enrollmentInitSuccess = 0
    
    foreach ($student in $script:CreatedStudents) {
        $numEnrollments = [Math]::Min($EnrollmentsPerStudent, $successfulClasses.Count)
        $selectedClasses = Get-Random -InputObject $successfulClasses -Count $numEnrollments
        
        foreach ($class in $selectedClasses) {
            $enrollmentInitCount++
            Write-Progress-Log "[$enrollmentInitCount] Notifying $($student.Email) about course $($class.Activity)..." "Gray"
            
            # Send notification (use StudentDetailId)
            try {
                $notifyUri = "$BaseUrl/student/$($student.StudentDetailId)/notify/$($class.ClassId)"
                Invoke-RestMethod -Uri $notifyUri -Method POST -Headers $headers -Body "{}" | Out-Null
                Write-Verbose-Log "Notification sent" "Cyan"
            }
            catch {
                Write-Verbose-Log "Warning: Notification failed - $($_.Exception.Message)" "Yellow"
            }
            
            Start-Sleep -Milliseconds 200
            
            # Complete initial enrollment steps
            $stepsBody = @{
                steps = @("student_create", "student_notify_course")
                completed_by = "instructor"
                metadata = @{
                    student_id = $student.StudentUserId
                    instructor_class_id = $class.ClassId
                }
            } | ConvertTo-Json -Depth 10
            
            try {
                $stepStart = Get-Date
                $progressResponse = Invoke-RestMethod -Uri "$BaseUrl/student-enrollment/steps/complete" -Method POST -Headers $headers -Body $stepsBody
                $stepDuration = ((Get-Date) - $stepStart).TotalSeconds
                
                $progressId = if ($progressResponse.data -and $progressResponse.data.enrollment_status -and $progressResponse.data.enrollment_status._id) {
                    $progressResponse.data.enrollment_status._id
                } elseif ($progressResponse.data -and $progressResponse.data._id) {
                    $progressResponse.data._id
                } elseif ($progressResponse.enrollment_status -and $progressResponse.enrollment_status._id) {
                    $progressResponse.enrollment_status._id
                } elseif ($progressResponse._id) {
                    $progressResponse._id
                } else {
                    $null
                }
                
                if (-not $progressId) {
                    Write-Host "  ERROR: Failed to extract enrollment progress ID!" -ForegroundColor Red
                    continue
                }
                
                $script:Enrollments += @{
                    StudentUserId = $student.StudentUserId
                    StudentDetailId = $student.StudentDetailId
                    StudentEmail = $student.Email
                    ClassId = $class.ClassId
                    ClassName = $class.Activity
                    EnrollmentProgressId = $progressId
                    EnrollmentScheduleId = $null
                    PaymentPlanId = $null
                    Status = "progress_created"
                }
                
                $enrollmentInitSuccess++
                Write-Host "  SUCCESS (${stepDuration}s) - Progress ID: $progressId" -ForegroundColor Green
            }
            catch {
                $errorMsg = $_.Exception.Message
                Write-Host "  FAILED: $errorMsg" -ForegroundColor Red
            }
            
            Start-Sleep -Milliseconds 300
        }
    }
    
    Write-Progress-Log "STEP 7 COMPLETE: Initiated $enrollmentInitSuccess/$enrollmentInitCount enrollments" "Green"
}

# ===========================================================================
# STEP 8: STUDENT ACCESS & CREATE ENROLLMENT SCHEDULES
# ===========================================================================

if ($Students -gt 0 -and $script:Enrollments.Count -gt 0) {
    Write-Step-Header "STEP 8" "Creating Enrollment Schedules (Student-Side)"
    
    $scheduleCreateCount = 0
    $scheduleCreateSuccess = 0
    
    foreach ($enrollment in $script:Enrollments) {
        $scheduleCreateCount++
        
        $studentUserId = $enrollment.StudentUserId.ToString()
        $studentToken = $script:StudentTokens[$studentUserId]
        
        if (-not $studentToken) {
            Write-Verbose-Log "SKIP: No token for student $($enrollment.StudentEmail)" "Yellow"
            continue
        }
        
        Write-Progress-Log "[$scheduleCreateCount/$($script:Enrollments.Count)] Schedule accessed by $($enrollment.StudentEmail)..." "Gray"
        
        $studentHeaders = @{
            "Authorization" = "Bearer $studentToken"
            "Content-Type" = "application/json"
        }
        
        # Student accesses class first
        try {
            Invoke-RestMethod -Uri "$BaseUrl/instructClass/single/$($enrollment.ClassId)" -Method GET -Headers $studentHeaders | Out-Null
            Write-Verbose-Log "Student accessed class" "Cyan"
        }
        catch {
            Write-Verbose-Log "Warning: Class access failed - $($_.Exception.Message)" "Yellow"
        }
        
        Start-Sleep -Milliseconds 200
        
        # Create enrollment schedule
        $scheduleBody = @{
            studentId = $studentUserId
            instructorClassId = $enrollment.ClassId
        } | ConvertTo-Json
        
        try {
            $stepStart = Get-Date
            $scheduleResponse = Invoke-RestMethod -Uri "$BaseUrl/enrollment/schedule" -Method POST -Headers $studentHeaders -Body $scheduleBody
            $stepDuration = ((Get-Date) - $stepStart).TotalSeconds
            
            $scheduleId = if ($scheduleResponse.data -and $scheduleResponse.data._id) {
                $scheduleResponse.data._id
            } elseif ($scheduleResponse._id) {
                $scheduleResponse._id
            } else {
                $null
            }
            
            if (-not $scheduleId) {
                Write-Verbose-Log "WARNING: No schedule ID in response" "Yellow"
            }
            
            # Update enrollment record
            $enrollmentIndex = $script:Enrollments.IndexOf($enrollment)
            $script:Enrollments[$enrollmentIndex].EnrollmentScheduleId = $scheduleId
            $script:Enrollments[$enrollmentIndex].Status = "schedule_created"
            
            $scheduleCreateSuccess++
            Write-Host "  SUCCESS (${stepDuration}s) - Schedule ID: $scheduleId" -ForegroundColor Green
        }
        catch {
            $errorMsg = $_.Exception.Message
            Write-Host "  FAILED: $errorMsg" -ForegroundColor Red
        }
        
        Start-Sleep -Milliseconds 300
    }
    
    Write-Progress-Log "STEP 8 COMPLETE: Created $scheduleCreateSuccess/$scheduleCreateCount enrollment schedules" "Green"
}

# ===========================================================================
# STEP 9: CREATE PAYMENT PLANS (Instructor-Side)
# ===========================================================================

if (-not $SkipPayments -and ($script:Enrollments | Where-Object {$_.EnrollmentScheduleId}).Count -gt 0) {
    Write-Step-Header "STEP 9" "Creating Payment Plans"
    
    $paymentPlanCount = 0
    $paymentPlanSuccess = 0
    $enrollmentsWithSchedules = $script:Enrollments | Where-Object {$_.EnrollmentScheduleId}
    
    foreach ($enrollment in $enrollmentsWithSchedules) {
        $paymentPlanCount++
        Write-Progress-Log "[$paymentPlanCount/$($enrollmentsWithSchedules.Count)] Creating payment plan for $($enrollment.StudentEmail)..." "Gray"
        
        $today = Get-Date
        $paymentPlanBody = @{
            enrollmentId = $enrollment.EnrollmentScheduleId
            instructorClassId = $enrollment.ClassId
            totalAmount = 12000
            planItems = @(
                @{
                    label = "Initial Payment"
                    amountDue = 4800
                    amount = 4800
                    dueDate = $today.ToString("yyyy-MM-dd")
                    status = "pending"
                },
                @{
                    label = "Second Payment"
                    amountDue = 3600
                    amount = 3600
                    dueDate = $today.AddDays(30).ToString("yyyy-MM-dd")
                    status = "pending"
                },
                @{
                    label = "Final Payment"
                    amountDue = 3600
                    amount = 3600
                    dueDate = $today.AddDays(60).ToString("yyyy-MM-dd")
                    status = "pending"
                }
            )
            expiresAt = $today.AddMonths(3).ToString("yyyy-MM-dd")
            notes = "Payment plan created using 3 Installments template"
        } | ConvertTo-Json -Depth 10
        
        try {
            $stepStart = Get-Date
            $planResponse = Invoke-RestMethod -Uri "$BaseUrl/enrollment/payment-plans" -Method POST -Headers $headers -Body $paymentPlanBody
            $stepDuration = ((Get-Date) - $stepStart).TotalSeconds
            
            $planId = if ($planResponse.data -and $planResponse.data._id) {
                $planResponse.data._id
            } elseif ($planResponse._id) {
                $planResponse._id
            } else {
                $null
            }
            
            # Update enrollment record
            $enrollmentIndex = $script:Enrollments.IndexOf($enrollment)
            $script:Enrollments[$enrollmentIndex].PaymentPlanId = $planId
            $script:Enrollments[$enrollmentIndex].Status = "payment_plan_created"
            
            $script:PaymentPlans += @{
                PaymentPlanId = $planId
                EnrollmentId = $enrollment.EnrollmentScheduleId
                StudentEmail = $enrollment.StudentEmail
                TotalAmount = 12000
            }
            
            $paymentPlanSuccess++
            Write-Host "  SUCCESS (${stepDuration}s) - Plan ID: $planId" -ForegroundColor Green
            
            # Mark step complete in progress
            $progressBody = @{
                step = "payment_plan_created"
                completed_by = "instructor"
                metadata = @{
                    payment_plan_id = $planId
                    template_used = "3 Installments"
                }
            } | ConvertTo-Json -Depth 5
            
            try {
                Invoke-RestMethod -Uri "$BaseUrl/student-enrollment/step/complete/$($enrollment.EnrollmentProgressId)" -Method POST -Headers $headers -Body $progressBody | Out-Null
                Write-Verbose-Log "Progress step marked complete" "Cyan"
            }
            catch {
                Write-Verbose-Log "Warning: Progress update failed" "Yellow"
            }
            
            # Send notification
            Start-Sleep -Milliseconds 200
            $notifyBody = @{
                paymentPlanId = $planId
                channels = @("mobile", "email")
            } | ConvertTo-Json
            
            try {
                Invoke-RestMethod -Uri "$BaseUrl/enrollment/payment-plans/notify" -Method POST -Headers $headers -Body $notifyBody | Out-Null
                Write-Verbose-Log "Payment plan notification sent" "Cyan"
            }
            catch {
                Write-Verbose-Log "Warning: Notification failed" "Yellow"
            }
        }
        catch {
            $errorMsg = $_.Exception.Message
            Write-Host "  FAILED: $errorMsg" -ForegroundColor Red
        }
        
        Start-Sleep -Milliseconds 500
    }
    
    Write-Progress-Log "STEP 9 COMPLETE: Created $paymentPlanSuccess/$paymentPlanCount payment plans" "Green"
}

# ===========================================================================
# STEP 10: STUDENT PAYMENT CONFIRMATION (Student-Side)
# ===========================================================================

if (-not $SkipPayments -and ($script:Enrollments | Where-Object {$_.PaymentPlanId}).Count -gt 0) {
    Write-Step-Header "STEP 10" "Student Payment Completion & Confirmation"
    
    $studentPaymentCount = 0
    $studentPaymentSuccess = 0
    $enrollmentsWithPlans = $script:Enrollments | Where-Object {$_.PaymentPlanId}
    
    foreach ($enrollment in $enrollmentsWithPlans) {
        $studentPaymentCount++
        Write-Progress-Log "[$studentPaymentCount/$($enrollmentsWithPlans.Count)] Student $($enrollment.StudentEmail) completing payment..." "Gray"
        
        $studentUserId = $enrollment.StudentUserId.ToString()
        $studentToken = $script:StudentTokens[$studentUserId]
        
        if (-not $studentToken) {
            Write-Verbose-Log "SKIP: No token for student" "Yellow"
            continue
        }
        
        $studentHeaders = @{
            "Authorization" = "Bearer $studentToken"
            "Content-Type" = "application/json"
        }
        
        # Student accesses payment plan
        try {
            Invoke-RestMethod -Uri "$BaseUrl/enrollment/payment-plan/$($enrollment.PaymentPlanId)" -Method GET -Headers $studentHeaders | Out-Null
            Write-Verbose-Log "Student accessed payment plan" "Cyan"
        }
        catch {
            Write-Verbose-Log "Warning: Payment plan access failed - $($_.Exception.Message)" "Yellow"
        }
        
        Start-Sleep -Milliseconds 200
        
        # Student completes payment (simulated - mark first installment as paid)
        try {
            $paymentFields = @{
                planId = $enrollment.PaymentPlanId
                planItemLabel = "Initial Payment"
                paidBy = $studentUserId
                amount = "4800"
                method = "cash"
            }
            
            Invoke-MultipartUpload -Uri "$BaseUrl/enrollment/payments" -Headers $studentHeaders -Fields $paymentFields | Out-Null
            Write-Verbose-Log "Payment completed (simulated)" "Cyan"
        }
        catch {
            Write-Verbose-Log "Warning: Payment completion failed - $($_.Exception.Message)" "Yellow"
        }
        
        Start-Sleep -Milliseconds 200
        
        # Student confirms payment
        try {
            $confirmBody = @{
                steps = @("payment_done", "payment_confirmation_by_student")
                completed_by = "student"
                metadata = @{
                    payment_plan_id = $enrollment.PaymentPlanId
                    confirmed_at = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd'T'HH:mm:ss.fff'Z'")
                    confirmed_via = "automation_script"
                }
            } | ConvertTo-Json -Depth 5
            
            $stepStart = Get-Date
            Invoke-RestMethod -Uri "$BaseUrl/student-enrollment/steps/complete/$($enrollment.EnrollmentProgressId)" -Method POST -Headers $studentHeaders -Body $confirmBody | Out-Null
            $stepDuration = ((Get-Date) - $stepStart).TotalSeconds
            
            # Update enrollment status
            $enrollmentIndex = $script:Enrollments.IndexOf($enrollment)
            $script:Enrollments[$enrollmentIndex].Status = "student_confirmed"
            
            $studentPaymentSuccess++
            Write-Host "  SUCCESS (${stepDuration}s) - Student payment confirmed" -ForegroundColor Green
        }
        catch {
            $errorMsg = $_.Exception.Message
            Write-Host "  FAILED: Student confirmation failed - $errorMsg" -ForegroundColor Red
        }
        
        Start-Sleep -Milliseconds 300
    }
    
    Write-Progress-Log "STEP 10 COMPLETE: $studentPaymentSuccess/$studentPaymentCount students confirmed payment" "Green"
}

# ===========================================================================
# STEP 11: INSTRUCTOR PAYMENT CONFIRMATION & FINALIZE ENROLLMENT
# ===========================================================================

if (-not $SkipPayments -and ($script:Enrollments | Where-Object {$_.Status -eq "student_confirmed"}).Count -gt 0) {
    Write-Step-Header "STEP 11" "Instructor Payment Confirmation & Finalize Enrollment"
    
    $instructorConfirmCount = 0
    $instructorConfirmSuccess = 0
    $enrollmentsWithStudentConfirm = $script:Enrollments | Where-Object {$_.Status -eq "student_confirmed"}
    
    foreach ($enrollment in $enrollmentsWithStudentConfirm) {
        $instructorConfirmCount++
        Write-Progress-Log "[$instructorConfirmCount/$($enrollmentsWithStudentConfirm.Count)] Instructor confirming payment for $($enrollment.StudentEmail)..." "Gray"
        
        # Update enrollment schedule status
        try {
            $statusBody = @{
                status = "payment_confirmation_instructor"
            } | ConvertTo-Json
            
            Invoke-RestMethod -Uri "$BaseUrl/enrollment/schedule/$($enrollment.EnrollmentScheduleId)" -Method PATCH -Headers $headers -Body $statusBody | Out-Null
            Write-Verbose-Log "Enrollment status updated" "Cyan"
        }
        catch {
            Write-Verbose-Log "Warning: Status update failed" "Yellow"
        }
        
        Start-Sleep -Milliseconds 200
        
        # Instructor confirms payment and completes enrollment
        $finalStepsBody = @{
            steps = @(
                "payment_confirmation_by_instructor",
                "student_enrollment_done_completed"
            )
            completed_by = "instructor"
            metadata = @{
                ui_step = "payment-confirmation"
                instructor_confirmation = $true
                enrollment_id = $enrollment.EnrollmentScheduleId
                instructor_id = $script:InstructorId
                confirmed_via = "automation_script"
                timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd'T'HH:mm:ss.fff'Z'")
                final_step = $true
            }
        } | ConvertTo-Json -Depth 10
        
        try {
            $stepStart = Get-Date
            Invoke-RestMethod -Uri "$BaseUrl/student-enrollment/steps/complete/$($enrollment.EnrollmentProgressId)" -Method POST -Headers $headers -Body $finalStepsBody | Out-Null
            $stepDuration = ((Get-Date) - $stepStart).TotalSeconds
            
            # Update enrollment record
            $enrollmentIndex = $script:Enrollments.IndexOf($enrollment)
            $script:Enrollments[$enrollmentIndex].Status = "completed"
            
            $instructorConfirmSuccess++
            Write-Host "  SUCCESS (${stepDuration}s) - Enrollment 100% complete!" -ForegroundColor Green
        }
        catch {
            $errorMsg = $_.Exception.Message
            Write-Host "  FAILED: $errorMsg" -ForegroundColor Red
        }
        
        Start-Sleep -Milliseconds 300
    }
    
    Write-Progress-Log "STEP 11 COMPLETE: Completed $instructorConfirmSuccess/$instructorConfirmCount enrollments" "Green"
}

# ===========================================================================
# FINAL REPORT
# ===========================================================================

$totalElapsed = (Get-Date) - $script:StartTime
$totalStr = "{0:mm}:{0:ss}" -f $totalElapsed

Write-Host ""
Write-Host "===================================================================" -ForegroundColor Green
Write-Host "              EXECUTION COMPLETE!                              " -ForegroundColor Green
Write-Host "===================================================================" -ForegroundColor Green

Write-Host ""
Write-Host "SUMMARY:" -ForegroundColor Cyan
Write-Host "   Execution Time: $totalStr" -ForegroundColor White
Write-Host "   Activities Created: $($script:CreatedActivities.Count)/$Activities" -ForegroundColor White
Write-Host "   Locations Created: $($script:CreatedLocations.Count)/$Locations" -ForegroundColor White
Write-Host "   Classes Created: $(($script:CreatedClasses | Where-Object {$_.Success}).Count)/$Classes" -ForegroundColor White
Write-Host "   Students Created: $($script:CreatedStudents.Count)/$Students" -ForegroundColor White
Write-Host "   Students Authenticated: $($script:StudentTokens.Count)" -ForegroundColor White
Write-Host "   Total Enrollments: $($script:Enrollments.Count)" -ForegroundColor White

if (-not $SkipPayments) {
    Write-Host "   Payment Plans Created: $($script:PaymentPlans.Count)" -ForegroundColor White
    $completedEnrollments = ($script:Enrollments | Where-Object {$_.Status -eq "completed"}).Count
    Write-Host "   Fully Completed Enrollments: $completedEnrollments" -ForegroundColor Green
}

$reportFile = "flexible-test-report_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
$reportData = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    ExecutionTime = $totalElapsed.ToString()
    Configuration = @{
        Activities = $Activities
        Locations = $Locations
        Classes = $Classes
        Students = $Students
        EnrollmentsPerStudent = $EnrollmentsPerStudent
        SkipPayments = $SkipPayments.IsPresent
    }
    Results = @{
        ActivitiesCreated = $script:CreatedActivities.Count
        LocationsCreated = $script:CreatedLocations.Count
        ClassesCreated = ($script:CreatedClasses | Where-Object {$_.Success}).Count
        StudentsCreated = $script:CreatedStudents.Count
        StudentsAuthenticated = $script:StudentTokens.Count
        TotalEnrollments = $script:Enrollments.Count
        PaymentPlansCreated = $script:PaymentPlans.Count
        FullyCompletedEnrollments = ($script:Enrollments | Where-Object {$_.Status -eq "completed"}).Count
    }
    CreatedActivities = $script:CreatedActivities
    CreatedLocations = $script:CreatedLocations
    CreatedClasses = $script:CreatedClasses
    CreatedStudents = $script:CreatedStudents
    Enrollments = $script:Enrollments
    PaymentPlans = $script:PaymentPlans
}

$reportData | ConvertTo-Json -Depth 10 | Out-File -FilePath $reportFile -Encoding UTF8
Write-Host ""
Write-Host "Report saved to: $reportFile" -ForegroundColor Cyan

# Save student credentials if any were created
if ($script:CreatedStudents.Count -gt 0) {
    $studentsFile = "test-students_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
    $script:CreatedStudents | ConvertTo-Json -Depth 5 | Out-File -FilePath $studentsFile -Encoding UTF8
    Write-Host "Student credentials saved to: $studentsFile" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "All done!" -ForegroundColor Green

exit 0

