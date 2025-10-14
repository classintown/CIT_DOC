# ===========================================================================
# COMPREHENSIVE CLASS CREATION TEST - CREATE EVERYTHING (FIXED VERSION)
# ===========================================================================
# This version includes ALL required fields for activities and locations
# 
# FEATURES:
# - ✅ SVG image upload support enabled (backend updated)
# - ✅ Proper multipart form construction using .NET HttpClient
# - ✅ Automatic fallback to JSON if no images available
# - ✅ Creates 30+ activities with random SVG images
# - ✅ Creates 30+ locations with all required fields
# - ✅ Creates 30+ class schedules (online + in-person)
# ===========================================================================

param(
    [string]$BaseUrl = "https://dev.classintown.com/api/v1",
    [string]$AuthToken = ""
)

if (-not $AuthToken) {
    Write-Host "Error: Auth token required!" -ForegroundColor Red
    Write-Host "Usage: .\create-test-data-FIXED.ps1 -AuthToken 'YOUR_TOKEN'" -ForegroundColor Yellow
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $AuthToken"
    "Content-Type" = "application/json"
    "Accept" = "application/json"
}

$script:CreatedActivities = @()
$script:CreatedLocations = @()
$script:CreatedClasses = @()
$script:StartTime = Get-Date

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
    Write-Host ""  -ForegroundColor Cyan
    Write-Host "===================================================================" -ForegroundColor Cyan
    Write-Host "  $Step - $Description" -ForegroundColor Cyan
    Write-Host "===================================================================" -ForegroundColor Cyan
    Write-Progress-Log "Starting: $Description" "Yellow"
}

# ===========================================================================
# MULTIPART UPLOAD HELPER FUNCTION (PowerShell 5.1 Compatible)
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
    
    # Add authorization header
    if ($Headers["Authorization"]) {
        $httpClient.DefaultRequestHeaders.Add("Authorization", $Headers["Authorization"])
    }
    
    try {
        $form = New-Object System.Net.Http.MultipartFormDataContent
        
        # Add all text fields
        foreach ($key in $Fields.Keys) {
            $value = $Fields[$key]
            $stringValue = ""
            
            # Convert arrays/objects to JSON strings
            if ($value -is [array]) {
                # Force array format even for single elements by wrapping in @()
                # This prevents PowerShell's ConvertTo-Json from unwrapping single-element arrays
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
        
        # Add file if provided
        if ($FilePath -and (Test-Path $FilePath)) {
            $fileStream = [System.IO.File]::OpenRead($FilePath)
            $fileContent = New-Object System.Net.Http.StreamContent($fileStream)
            $fileContent.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::Parse("image/svg+xml")
            $fileName = [System.IO.Path]::GetFileName($FilePath)
            $form.Add($fileContent, $FileFieldName, $fileName)
        }
        
        # Send request
        $response = $httpClient.PostAsync($Uri, $form).Result
        
        # Read response
        $responseContent = $response.Content.ReadAsStringAsync().Result
        
        # Close file stream if opened
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
# STEP 0: LOAD IMAGES FOR ACTIVITIES
# ===========================================================================

Write-Step-Header "STEP 0" "Loading Images for Activities"

$imagesPath = Join-Path $PSScriptRoot "images_png"
Write-Progress-Log "Loading SVG images from: $imagesPath" "Yellow"

try {
    if (Test-Path $imagesPath) {
        $allImages = Get-ChildItem -Path $imagesPath -Filter "*.png" | Select-Object -ExpandProperty FullName
        Write-Progress-Log "Found $($allImages.Count) SVG images" "Green"
        
        if ($allImages.Count -eq 0) {
            Write-Host "WARNING: No SVG images found in $imagesPath" -ForegroundColor Yellow
            Write-Host "Activities will be created without media" -ForegroundColor Yellow
        }
    } else {
        Write-Host "WARNING: Images directory not found: $imagesPath" -ForegroundColor Yellow
        Write-Host "Activities will be created without media" -ForegroundColor Yellow
        $allImages = @()
    }
}
catch {
    Write-Host "ERROR: Failed to load images - $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Activities will be created without media" -ForegroundColor Yellow
    $allImages = @()
}

# ===========================================================================
# STEP 1: CREATE 30+ ACTIVITIES (WITH ALL REQUIRED FIELDS + SVG IMAGES)
# ===========================================================================

Write-Step-Header "STEP 1" "Creating 30+ Activities (with SVG Images)"

$activityTemplates = @(
    @{ Base = "Yoga"; Categories = @("Hatha", "Vinyasa", "Ashtanga", "Yin", "Power", "Hot"); Levels = @("Beginner", "Intermediate", "Advanced"); Format = "Group" },
    @{ Base = "Dance"; Categories = @("Ballet", "Hip Hop", "Contemporary", "Salsa", "Ballroom", "Jazz"); Levels = @("Kids", "Teen", "Adult"); Format = "Group" },
    @{ Base = "Martial Arts"; Categories = @("Karate", "Taekwondo", "Judo", "Kickboxing", "MMA", "Tai Chi"); Levels = @("White Belt", "Yellow Belt", "Black Belt"); Format = "Group" },
    @{ Base = "Music"; Categories = @("Piano", "Guitar", "Violin", "Drums", "Vocal", "Flute"); Levels = @("Beginner", "Grade 3", "Grade 5"); Format = "One-on-one" },
    @{ Base = "Art"; Categories = @("Painting", "Sketching", "Watercolor", "Acrylic", "Oil Painting", "Digital Art"); Levels = @("Hobby", "Professional", "Kids"); Format = "Group" },
    @{ Base = "Fitness"; Categories = @("Zumba", "Aerobics", "Pilates", "CrossFit", "Boxing", "Spinning"); Levels = @("Low Impact", "High Intensity", "Cardio"); Format = "Group" },
    @{ Base = "Swimming"; Categories = @("Freestyle", "Breaststroke", "Butterfly", "Backstroke", "Water Polo", "Synchronized"); Levels = @("Beginner", "Intermediate", "Competitive"); Format = "Group" },
    @{ Base = "Cooking"; Categories = @("Italian", "Chinese", "Indian", "French", "Baking", "Pastry"); Levels = @("Basic", "Advanced", "Master Chef"); Format = "Hands-on" }
)

$activityCount = 0
$activityTarget = 35

Write-Progress-Log "Target: $activityTarget activities" "White"

foreach ($template in $activityTemplates) {
    foreach ($category in $template.Categories) {
        foreach ($level in $template.Levels) {
            $activityCount++
            $activityName = "$($level) $($category) $($template.Base)"
            $description = "Professional $($level.ToLower()) level $($category.ToLower()) $($template.Base.ToLower()) training for all ages"
            
            Write-Progress-Log "[$activityCount/$activityTarget] Creating: $activityName..." "Gray"
            
            # Create activity with ALL REQUIRED FIELDS - EXACT ENUM VALUES
            # Map level to correct proficiency enum
            $proficiencyMap = @{
                "Beginner" = "beginner"
                "Intermediate" = "intermediate"
                "Advanced" = "advanced"
                "Kids" = "beginner"
                "Teen" = "intermediate"
                "Adult" = "advanced"
                "White Belt" = "beginner"
                "Yellow Belt" = "intermediate"
                "Black Belt" = "expert"
                "Grade 3" = "intermediate"
                "Grade 5" = "advanced"
                "Hobby" = "beginner"
                "Professional" = "expert"
                "Low Impact" = "beginner"
                "High Intensity" = "advanced"
                "Cardio" = "intermediate"
                "Competitive" = "expert"
                "Basic" = "beginner"
                "Master Chef" = "expert"
            }
            
            $proficiency = if ($proficiencyMap.ContainsKey($level)) { $proficiencyMap[$level] } else { "intermediate" }
            
            # Select random image if available
            $mediaPath = ""
            if ($allImages.Count -gt 0) {
                $randomImageIndex = Get-Random -Minimum 0 -Maximum $allImages.Count
                $mediaPath = $allImages[$randomImageIndex]
            }
            
            # Prepare activity data fields
            $activityFields = @{
                activity_name = $activityName
                description = $description
                category = @($template.Base)
                activity_type = "In Person"
                format = $template.Format
                skills = @(@{
                    skill_name = $category
                    proficiency = $proficiency
                })
                audience = @("All Ages")
                age_range = @{
                    min = 5
                    max = 65
                }
                adult_participation = "None"
                grades_assessment = "None"
                homework = $false  # Send as boolean
                pod_learning = $false  # Send as boolean
                requirements = "Basic fitness level"
                materials = @(@{
                    material_name = "Mat"
                    quantity = "1"
                })
                is_active = $true
            }
            
            try {
                $stepStart = Get-Date
                
                if ($mediaPath -and (Test-Path $mediaPath)) {
                    # Use multipart upload with image
                    $response = Invoke-MultipartUpload -Uri "$BaseUrl/activities/" -Headers $headers -Fields $activityFields -FilePath $mediaPath
                    $imageName = Split-Path $mediaPath -Leaf
                } else {
                    # Use JSON without image
                    $activityBody = $activityFields | ConvertTo-Json -Depth 5
                    $response = Invoke-RestMethod -Uri "$BaseUrl/activities/" -Method POST -Headers $headers -Body $activityBody
                    $imageName = "None"
                }
                
                $stepDuration = ((Get-Date) - $stepStart).TotalSeconds
                
                $script:CreatedActivities += @{
                    Name = $activityName
                    Id = $response._id
                    Category = $template.Base
                    Media = $imageName
                }
                
                if ($imageName -ne "None") {
                    Write-Host "  SUCCESS (${stepDuration}s) - ID: $($response._id)" -ForegroundColor Green
                    Write-Host "     >> Image uploaded: $imageName" -ForegroundColor Cyan
                } else {
                    Write-Host "  SUCCESS (${stepDuration}s) - ID: $($response._id)" -ForegroundColor Green
                }
            }
            catch {
                $errorMsg = $_.Exception.Message
                Write-Host "  FAILED: $errorMsg" -ForegroundColor Yellow
                
                # Try to get detailed error
                try {
                    $errorDetails = $_ | ConvertFrom-Json
                    Write-Host "    Details: $($errorDetails.message)" -ForegroundColor Red
                } catch {}
                
                if ($errorMsg -match "duplicate|already exists") {
                    Write-Progress-Log "  Note: Activity may already exist, continuing..." "Gray"
                }
            }
            
            if ($activityCount -ge $activityTarget) { 
                Write-Progress-Log "Reached target of $activityTarget activities" "Green"
                break 
            }
        }
        if ($activityCount -ge $activityTarget) { 
            break 
        }
    }
    if ($activityCount -ge $activityTarget) { 
        break 
    }
}

$step1Elapsed = (Get-Date) - $script:StartTime
$step1Str = "{0:mm}:{0:ss}" -f $step1Elapsed
Write-Progress-Log "STEP 1 COMPLETE: Created $($script:CreatedActivities.Count)/$activityCount activities (Duration: $step1Str)" "Green"

# ===========================================================================
# STEP 2: CREATE 30+ LOCATIONS (WITH REGION FIELD)
# ===========================================================================

Write-Step-Header "STEP 2" "Creating 30+ Locations"

$locationTypes = @("Center", "Studio", "Academy", "Institute", "Club", "Hall", "Gym", "Arena")
$areas = @(
    "Andheri", "Bandra", "Borivali", "Churchgate", "Colaba", "Dadar", "Goregaon", 
    "Juhu", "Kandivali", "Kurla", "Malad", "Powai", "Santacruz", "Thane", "Vashi",
    "Chembur", "Ghatkopar", "Mulund", "Vikhroli", "Wadala", "Worli", "Lower Parel"
)
$cities = @("Mumbai", "Navi Mumbai", "Thane")
$regions = @("Western Suburbs", "Central Mumbai", "Eastern Suburbs", "Navi Mumbai", "Thane")

$locationCount = 0
$locationTarget = 35

Write-Progress-Log "Target: $locationTarget locations" "White"

foreach ($area in $areas) {
    foreach ($locType in $locationTypes) {
        $locationCount++
        $city = $cities[(Get-Random -Maximum $cities.Count)]
        $region = $regions[(Get-Random -Maximum $regions.Count)]
        $locationName = "$area $locType"
        $direction = if ((Get-Random -Minimum 0 -Maximum 2) -eq 1) { "East" } else { "West" }
        $address = "$(Get-Random -Minimum 1 -Maximum 999), $area $direction"
        
        Write-Progress-Log "[$locationCount/$locationTarget] Creating: $locationName..." "Gray"
        
        $locationBody = @{
            title = $locationName
            address = $address
            city = $city
            state = "Maharashtra"
            country = "India"
            pincode = "$(Get-Random -Minimum 400001 -Maximum 400999)"
            latitude = [decimal](19.0 + (Get-Random -Minimum 0 -Maximum 300) / 1000.0)
            longitude = [decimal](72.8 + (Get-Random -Minimum 0 -Maximum 300) / 1000.0)
            region = $region  # REQUIRED FIELD - WAS MISSING!
            place_type = $locType
            is_active = $true
        } | ConvertTo-Json -Depth 5
        
        try {
            $stepStart = Get-Date
            $response = Invoke-RestMethod -Uri "$BaseUrl/maps/enhanced" -Method POST -Headers $headers -Body $locationBody
            $stepDuration = ((Get-Date) - $stepStart).TotalSeconds
            
            $script:CreatedLocations += @{
                Name = $locationName
                Id = $response._id
                City = $city
                Area = $area
                Region = $region
            }
            Write-Host "  SUCCESS (${stepDuration}s) - ID: $($response._id)" -ForegroundColor Green
        }
        catch {
            $errorMsg = $_.Exception.Message
            Write-Host "  FAILED: $errorMsg" -ForegroundColor Yellow
            
            # Try to get detailed error
            try {
                $errorDetails = $_.ErrorDetails.Message | ConvertFrom-Json
                if ($errorDetails.message) {
                    Write-Host "    Details: $($errorDetails.message)" -ForegroundColor Red
                }
            } catch {}
        }
        
        Start-Sleep -Milliseconds 100
        
        if ($locationCount -ge $locationTarget) { 
            Write-Progress-Log "Reached target of $locationTarget locations" "Green"
            break 
        }
    }
    if ($locationCount -ge $locationTarget) { 
        break 
    }
}

$step2Elapsed = (Get-Date) - $script:StartTime
$step2Str = "{0:mm}:{0:ss}" -f $step2Elapsed
Write-Progress-Log "STEP 2 COMPLETE: Created $($script:CreatedLocations.Count)/$locationCount locations (Total Elapsed: $step2Str)" "Green"

# ===========================================================================
# STEP 3: FETCH ACTUAL IDs FROM BACKEND
# ===========================================================================

Write-Step-Header "STEP 3" "Fetching All Activities and Locations"

Write-Progress-Log "Fetching active activities from backend..." "Yellow"
try {
    $fetchStart = Get-Date
    $response = Invoke-RestMethod -Uri "$BaseUrl/activities/active" -Method GET -Headers $headers
    $fetchDuration = ((Get-Date) - $fetchStart).TotalSeconds
    
    # Check if response is wrapped in a data object
    if ($response.data) {
        Write-Progress-Log "Extracting activities from response.data..." "Yellow"
        $allActivities = $response.data
    }
    else {
        $allActivities = $response
    }
    
    Write-Progress-Log "Fetched $($allActivities.Count) activities (${fetchDuration}s)" "Green"
    
    # Convert to array if needed and validate
    if ($allActivities -isnot [array]) {
        Write-Progress-Log "Converting activities to array..." "Yellow"
        $allActivities = @($allActivities)
    }
    
    # Debug: Check first activity structure
    if ($allActivities.Count -gt 0) {
        $firstActivity = $allActivities[0]
        Write-Progress-Log "DEBUG: Activities is array: $($allActivities -is [array])" "Gray"
        Write-Progress-Log "DEBUG: Activities count: $($allActivities.Count)" "Gray"
        Write-Progress-Log "DEBUG: First activity type: $($firstActivity.GetType().Name)" "Gray"
        Write-Progress-Log "DEBUG: First activity _id: '$($firstActivity._id)'" "Gray"
        Write-Progress-Log "DEBUG: First activity name: '$($firstActivity.activity_name)'" "Gray"
    }
    else {
        Write-Host "ERROR: No activities returned from API!" -ForegroundColor Red
        exit 1
    }
    
    $allActivities | ConvertTo-Json -Depth 5 | Out-File "all-activities.json" -Encoding UTF8
    Write-Progress-Log "Saved to: all-activities.json" "Cyan"
}
catch {
    Write-Host "CRITICAL ERROR: Failed to fetch activities - $($_.Exception.Message)" -ForegroundColor Red
    Write-Progress-Log "Cannot continue without activities. Exiting." "Red"
    exit 1
}

Write-Progress-Log "Fetching all locations from backend..." "Yellow"
try {
    $fetchStart = Get-Date
    $response = Invoke-RestMethod -Uri "$BaseUrl/maps" -Method GET -Headers $headers
    $fetchDuration = ((Get-Date) - $fetchStart).TotalSeconds
    
    # Check if response is wrapped in a data object
    if ($response.data) {
        Write-Progress-Log "Extracting locations from response.data..." "Yellow"
        $allLocations = $response.data
    }
    else {
        $allLocations = $response
    }
    
    Write-Progress-Log "Fetched $($allLocations.Count) locations (${fetchDuration}s)" "Green"
    
    # Convert to array if needed and validate
    if ($allLocations -isnot [array]) {
        Write-Progress-Log "Converting locations to array..." "Yellow"
        $allLocations = @($allLocations)
    }
    
    # Debug: Check first location structure
    if ($allLocations.Count -gt 0) {
        $firstLocation = $allLocations[0]
        Write-Progress-Log "DEBUG: Locations is array: $($allLocations -is [array])" "Gray"
        Write-Progress-Log "DEBUG: Locations count: $($allLocations.Count)" "Gray"
        Write-Progress-Log "DEBUG: First location type: $($firstLocation.GetType().Name)" "Gray"
        Write-Progress-Log "DEBUG: First location _id: '$($firstLocation._id)'" "Gray"
        Write-Progress-Log "DEBUG: First location title: '$($firstLocation.title)'" "Gray"
    }
    else {
        Write-Host "ERROR: No locations returned from API!" -ForegroundColor Red
        exit 1
    }
    
    $allLocations | ConvertTo-Json -Depth 5 | Out-File "all-locations.json" -Encoding UTF8
    Write-Progress-Log "Saved to: all-locations.json" "Cyan"
}
catch {
    Write-Host "CRITICAL ERROR: Failed to fetch locations - $($_.Exception.Message)" -ForegroundColor Red
    Write-Progress-Log "Cannot continue without locations. Exiting." "Red"
    exit 1
}

$step3Elapsed = (Get-Date) - $script:StartTime
$step3Str = "{0:mm}:{0:ss}" -f $step3Elapsed
Write-Progress-Log "STEP 3 COMPLETE (Total Elapsed: $step3Str)" "Green"

# ===========================================================================
# STEP 4: CREATE 30+ CLASS SCHEDULES (ONLINE + IN-PERSON, DURATION + COUNT)
# ===========================================================================

Write-Step-Header "STEP 4" "Creating 30+ Class Schedules (Online + In-Person, Duration + Count)"

function Get-FutureDateTime {
    param(
        [int]$DaysFromNow = 7,
        [int]$Hour = 9,
        [int]$Minute = 0
    )
    $date = (Get-Date).AddDays($DaysFromNow).Date.AddHours($Hour).AddMinutes($Minute)
    return $date.ToUniversalTime().ToString("yyyy-MM-dd'T'HH:mm:ss.fff'Z'")
}

$timeSlots = @(
    @{ Hour = 6; Duration = 1; Label = "Early Morning (6-7 AM)" },
    @{ Hour = 7; Duration = 1.5; Label = "Morning (7-8:30 AM)" },
    @{ Hour = 9; Duration = 1; Label = "Mid Morning (9-10 AM)" },
    @{ Hour = 10; Duration = 2; Label = "Late Morning (10-12 PM)" },
    @{ Hour = 14; Duration = 1.5; Label = "Afternoon (2-3:30 PM)" },
    @{ Hour = 16; Duration = 1; Label = "Evening (4-5 PM)" },
    @{ Hour = 17; Duration = 1.5; Label = "Late Evening (5-6:30 PM)" },
    @{ Hour = 18; Duration = 2; Label = "Night (6-8 PM)" },
    @{ Hour = 19; Duration = 1; Label = "Late Night (7-8 PM)" },
    @{ Hour = 20; Duration = 1.5; Label = "Dinner Time (8-9:30 PM)" }
)

$weekDays = @("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")

function Create-ClassSchedule {
    param(
        [object]$Activity,
        [object]$Location,
        [bool]$IsOnline,
        [object]$TimeSlot,
        [string]$Day,
        [int]$ClassNumber,
        [int]$TotalClasses,
        [string]$ClassType = "duration",  # "duration" or "count"
        [int]$SessionCount = 0
    )
    
    $mode = if ($IsOnline) { "ONLINE" } else { "IN-PERSON" }
    $typeLabel = if ($ClassType -eq "count") { "COUNT-BASED" } else { "DURATION-BASED" }
    $className = "[$mode/$typeLabel] $($Activity.activity_name) - $($TimeSlot.Label)"
    
    Write-Progress-Log "[$ClassNumber/$TotalClasses] Creating class: $mode - $($Activity.activity_name)..." "Yellow"
    Write-Host "   Time: $($TimeSlot.Label) on $Day" -ForegroundColor Gray
    
    # Validate activity has required fields
    if (-not $Activity._id -or -not $Activity.activity_name -or -not $Activity.description) {
        Write-Host "   ERROR: Activity missing required fields!" -ForegroundColor Red
        Write-Host "   Activity ID: '$($Activity._id)'" -ForegroundColor Gray
        Write-Host "   Activity Name: '$($Activity.activity_name)'" -ForegroundColor Gray
        Write-Host "   Description: '$($Activity.description)'" -ForegroundColor Gray
        Write-Host "   Available fields: $($Activity | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name)" -ForegroundColor Yellow
        return $false
    }
    
    if (-not $IsOnline) {
        Write-Host "   Location: $($Location.title)" -ForegroundColor Gray
        # Validate location has required fields
        if (-not $Location._id -or -not $Location.title) {
            Write-Host "   ERROR: Location missing required fields!" -ForegroundColor Red
            return $false
        }
    }
    
    # Calculate schedule dates based on class type
    if ($ClassType -eq "count") {
        Write-Progress-Log "   Generating $SessionCount session slots for count-based class..." "Gray"
        $slots = @()
        for ($session = 0; $session -lt $SessionCount; $session++) {
            $daysToAdd = ($weekDays.IndexOf($Day) - (Get-Date).DayOfWeek.value__) + ($session * 7)
            if ($daysToAdd -lt 0) { $daysToAdd += 7 }
            
            $startDateTime = Get-FutureDateTime -DaysFromNow $daysToAdd -Hour $TimeSlot.Hour -Minute 0
            $endHour = $TimeSlot.Hour + [Math]::Floor($TimeSlot.Duration)
            $endMinute = ($TimeSlot.Duration - [Math]::Floor($TimeSlot.Duration)) * 60
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
        Write-Progress-Log "   Generated $($slots.Count) session slots" "Gray"
    }
    else {
        # Duration-based: 4 weeks of recurring classes
        Write-Progress-Log "   Generating 4 weeks of schedule slots..." "Gray"
        $slots = @()
        for ($week = 0; $week -lt 4; $week++) {
            $daysToAdd = ($weekDays.IndexOf($Day) - (Get-Date).DayOfWeek.value__) + ($week * 7)
            if ($daysToAdd -lt 0) { $daysToAdd += 7 }
            
            $startDateTime = Get-FutureDateTime -DaysFromNow $daysToAdd -Hour $TimeSlot.Hour -Minute 0
            $endHour = $TimeSlot.Hour + [Math]::Floor($TimeSlot.Duration)
            $endMinute = ($TimeSlot.Duration - [Math]::Floor($TimeSlot.Duration)) * 60
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
        Write-Progress-Log "   Generated $($slots.Count) time slots" "Gray"
    }
    
    $classBody = @{
        activity = @{
            _id = $Activity._id.ToString()
            activity_name = $Activity.activity_name.ToString()
            description = $Activity.description.ToString()
        }
        is_online = $IsOnline
        duration = 1
        classType = $ClassType
        schedules = @(
            @{
                day = $Day
                slots = $slots
            }
        )
        is_full_price = $true
        full_price = (Get-Random -Minimum 3000 -Maximum 20000)
        capacity = (Get-Random -Minimum 10 -Maximum 50)
        is_drop_in_price = ((Get-Random -Minimum 0 -Maximum 2) -eq 1)
        drop_in_price = if ((Get-Random -Minimum 0 -Maximum 2) -eq 1) { (Get-Random -Minimum 500 -Maximum 2000) } else { 0 }
        is_free_activity = $false
        is_monthly_pricing = ((Get-Random -Minimum 0 -Maximum 2) -eq 1)
        monthly_pricing = if ((Get-Random -Minimum 0 -Maximum 2) -eq 1) { (Get-Random -Minimum 2000 -Maximum 10000) } else { 0 }
        classCount = if ($ClassType -eq "count") { $SessionCount } else { $null }
    }
    
    if (-not $IsOnline) {
        $classBody.location = @{
            _id = $Location._id.ToString()
            title = $Location.title.ToString()
        }
        $classBody.class_link = ""
    }
    else {
        $classBody.class_link = "https://meet.google.com/$(Get-Random -Minimum 100000 -Maximum 999999)"
    }
    
    Write-Progress-Log "   Sending POST request to /instructClass/..." "Gray"
    Write-Progress-Log "   Activity ID: $($classBody.activity._id)" "Gray"
    Write-Progress-Log "   Activity Name: $($classBody.activity.activity_name)" "Gray"
    
    $bodyJson = $classBody | ConvertTo-Json -Depth 10
    
    try {
        $classStart = Get-Date
        $response = Invoke-RestMethod -Uri "$BaseUrl/instructClass/" -Method POST -Headers $headers -Body $bodyJson
        $classDuration = ((Get-Date) - $classStart).TotalSeconds
        
        Write-Host "  SUCCESS (${classDuration}s) - Class ID: $($response._id)" -ForegroundColor Green
        Write-Host "     Capacity: $($classBody.capacity) | Price: Rs.$($classBody.full_price)" -ForegroundColor Green
        
        $script:CreatedClasses += @{
            ClassId = $response._id
            ClassName = $className
            Activity = $Activity.activity_name
            Location = if ($Location) { $Location.title } else { "Online" }
            IsOnline = $IsOnline
            Day = $Day
            TimeSlot = $TimeSlot.Label
            Success = $true
        }
        
        return $true
    }
    catch {
        $errorMsg = $_.Exception.Message
        $classDuration = ((Get-Date) - $classStart).TotalSeconds
        
        Write-Host "  FAILED (${classDuration}s): $errorMsg" -ForegroundColor Red
        
        try {
            $errorDetails = $_.ErrorDetails.Message | ConvertFrom-Json
            if ($errorDetails.message) {
                Write-Host "     Backend Error: $($errorDetails.message)" -ForegroundColor Red
            }
        }
        catch { }
        
        $script:CreatedClasses += @{
            ClassId = $null
            ClassName = $className
            Activity = $Activity.activity_name
            Location = if ($Location) { $Location.title } else { "Online" }
            IsOnline = $IsOnline
            Day = $Day
            TimeSlot = $TimeSlot.Label
            Success = $false
            Error = $errorMsg
        }
        
        return $false
    }
}

$classCount = 0
$totalClassTarget = 32

# Create 16 IN-PERSON classes (8 duration + 8 count)
Write-Progress-Log "Creating 8 IN-PERSON DURATION-BASED classes..." "Cyan"
for ($i = 0; $i -lt 8; $i++) {
    $randomActivityIndex = Get-Random -Minimum 0 -Maximum $allActivities.Count
    $randomLocationIndex = Get-Random -Minimum 0 -Maximum $allLocations.Count
    
    $activity = $allActivities[$randomActivityIndex]
    $location = $allLocations[$randomLocationIndex]
    $timeSlot = $timeSlots[(Get-Random -Maximum $timeSlots.Count)]
    $day = $weekDays[(Get-Random -Maximum $weekDays.Count)]
    
    # Validate we got valid objects
    if (-not $activity) {
        Write-Host "ERROR: Failed to get activity at index $randomActivityIndex" -ForegroundColor Red
        Write-Host "Total activities: $($allActivities.Count)" -ForegroundColor Gray
        continue
    }
    if (-not $location) {
        Write-Host "ERROR: Failed to get location at index $randomLocationIndex" -ForegroundColor Red
        Write-Host "Total locations: $($allLocations.Count)" -ForegroundColor Gray
        continue
    }
    
    $classCount++
    Create-ClassSchedule -Activity $activity -Location $location -IsOnline $false -TimeSlot $timeSlot -Day $day -ClassNumber $classCount -TotalClasses $totalClassTarget -ClassType "duration"
    
    Write-Progress-Log "Waiting 500ms before next request..." "Gray"
    Start-Sleep -Milliseconds 500
}

Write-Progress-Log "Creating 8 IN-PERSON COUNT-BASED classes..." "Cyan"
for ($i = 0; $i -lt 8; $i++) {
    $randomActivityIndex = Get-Random -Minimum 0 -Maximum $allActivities.Count
    $randomLocationIndex = Get-Random -Minimum 0 -Maximum $allLocations.Count
    
    $activity = $allActivities[$randomActivityIndex]
    $location = $allLocations[$randomLocationIndex]
    $timeSlot = $timeSlots[(Get-Random -Maximum $timeSlots.Count)]
    $day = $weekDays[(Get-Random -Maximum $weekDays.Count)]
    $sessionCount = Get-Random -Minimum 4 -Maximum 12  # 4-12 sessions
    
    # Validate we got valid objects
    if (-not $activity) {
        Write-Host "ERROR: Failed to get activity at index $randomActivityIndex" -ForegroundColor Red
        Write-Host "Total activities: $($allActivities.Count)" -ForegroundColor Gray
        continue
    }
    if (-not $location) {
        Write-Host "ERROR: Failed to get location at index $randomLocationIndex" -ForegroundColor Red
        Write-Host "Total locations: $($allLocations.Count)" -ForegroundColor Gray
        continue
    }
    
    $classCount++
    Create-ClassSchedule -Activity $activity -Location $location -IsOnline $false -TimeSlot $timeSlot -Day $day -ClassNumber $classCount -TotalClasses $totalClassTarget -ClassType "count" -SessionCount $sessionCount
    
    Write-Progress-Log "Waiting 500ms before next request..." "Gray"
    Start-Sleep -Milliseconds 500
}

Write-Progress-Log "Creating 8 ONLINE DURATION-BASED classes..." "Cyan"
for ($i = 0; $i -lt 8; $i++) {
    $randomActivityIndex = Get-Random -Minimum 0 -Maximum $allActivities.Count
    
    $activity = $allActivities[$randomActivityIndex]
    $timeSlot = $timeSlots[(Get-Random -Maximum $timeSlots.Count)]
    $day = $weekDays[(Get-Random -Maximum $weekDays.Count)]
    
    # Validate we got valid object
    if (-not $activity) {
        Write-Host "ERROR: Failed to get activity at index $randomActivityIndex" -ForegroundColor Red
        Write-Host "Total activities: $($allActivities.Count)" -ForegroundColor Gray
        continue
    }
    
    $classCount++
    Create-ClassSchedule -Activity $activity -Location $null -IsOnline $true -TimeSlot $timeSlot -Day $day -ClassNumber $classCount -TotalClasses $totalClassTarget -ClassType "duration"
    
    Write-Progress-Log "Waiting 500ms before next request..." "Gray"
    Start-Sleep -Milliseconds 500
}

Write-Progress-Log "Creating 8 ONLINE COUNT-BASED classes..." "Cyan"
for ($i = 0; $i -lt 8; $i++) {
    $randomActivityIndex = Get-Random -Minimum 0 -Maximum $allActivities.Count
    
    $activity = $allActivities[$randomActivityIndex]
    $timeSlot = $timeSlots[(Get-Random -Maximum $timeSlots.Count)]
    $day = $weekDays[(Get-Random -Maximum $weekDays.Count)]
    $sessionCount = Get-Random -Minimum 4 -Maximum 12  # 4-12 sessions
    
    # Validate we got valid object
    if (-not $activity) {
        Write-Host "ERROR: Failed to get activity at index $randomActivityIndex" -ForegroundColor Red
        Write-Host "Total activities: $($allActivities.Count)" -ForegroundColor Gray
        continue
    }
    
    $classCount++
    Create-ClassSchedule -Activity $activity -Location $null -IsOnline $true -TimeSlot $timeSlot -Day $day -ClassNumber $classCount -TotalClasses $totalClassTarget -ClassType "count" -SessionCount $sessionCount
    
    Write-Progress-Log "Waiting 500ms before next request..." "Gray"
    Start-Sleep -Milliseconds 500
}

$step4Elapsed = (Get-Date) - $script:StartTime
$step4Str = "{0:mm}:{0:ss}" -f $step4Elapsed
Write-Progress-Log "STEP 4 COMPLETE (Total Elapsed: $step4Str)" "Green"

# ===========================================================================
# GENERATE FINAL REPORT
# ===========================================================================

$totalElapsed = (Get-Date) - $script:StartTime

Write-Host ""  -ForegroundColor Green
Write-Host "===================================================================" -ForegroundColor Green
Write-Host "              FINAL SUMMARY                              " -ForegroundColor Green
Write-Host "===================================================================" -ForegroundColor Green

Write-Host ""  -ForegroundColor Cyan
Write-Host "TIMING INFORMATION:" -ForegroundColor Cyan
$totalStr = "{0:mm}:{0:ss}" -f $totalElapsed
Write-Host "   Total Execution Time: $totalStr" -ForegroundColor White
Write-Host "   Started: $($script:StartTime.ToString('HH:mm:ss'))" -ForegroundColor Gray
Write-Host "   Completed: $((Get-Date).ToString('HH:mm:ss'))" -ForegroundColor Gray

Write-Host ""  -ForegroundColor Cyan
Write-Host "CREATION SUMMARY:" -ForegroundColor Cyan
Write-Host "   Activities Created: $($script:CreatedActivities.Count)" -ForegroundColor White
Write-Host "   Locations Created: $($script:CreatedLocations.Count)" -ForegroundColor White
Write-Host "   Total Activities Available: $($allActivities.Count)" -ForegroundColor White
Write-Host "   Total Locations Available: $($allLocations.Count)" -ForegroundColor White

$successClasses = ($script:CreatedClasses | Where-Object { $_.Success }).Count
$failedClasses = ($script:CreatedClasses | Where-Object { -not $_.Success }).Count

Write-Host ""  -ForegroundColor Cyan
Write-Host "CLASS CREATION RESULTS:" -ForegroundColor Cyan
Write-Host "   Total Classes Attempted: $($script:CreatedClasses.Count)" -ForegroundColor White
Write-Host "   Successful: $successClasses" -ForegroundColor Green
if ($failedClasses -gt 0) {
    Write-Host "   Failed: $failedClasses" -ForegroundColor Red
} else {
    Write-Host "   Failed: $failedClasses" -ForegroundColor Gray
}

$onlineClasses = ($script:CreatedClasses | Where-Object { $_.IsOnline -and $_.Success }).Count
$inPersonClasses = ($script:CreatedClasses | Where-Object { -not $_.IsOnline -and $_.Success }).Count

Write-Host ""  -ForegroundColor Cyan
Write-Host "BY MODE:" -ForegroundColor Cyan
Write-Host "   Online Classes: $onlineClasses" -ForegroundColor White
Write-Host "   In-Person Classes: $inPersonClasses" -ForegroundColor White

Write-Host ""  -ForegroundColor Cyan
Write-Host "BY CLASS TYPE:" -ForegroundColor Cyan
Write-Host "   Duration-Based (recurring): 16 (8 online + 8 in-person)" -ForegroundColor White
Write-Host "   Count-Based (sessions): 16 (8 online + 8 in-person)" -ForegroundColor White

if ($successClasses -gt 0) {
    Write-Host ""  -ForegroundColor Green
    Write-Host "SUCCESSFUL CLASSES:" -ForegroundColor Green
    $script:CreatedClasses | Where-Object { $_.Success } | ForEach-Object {
        Write-Host "   [$($_.ClassId)] $($_.ClassName)" -ForegroundColor Green
    }
}

if ($failedClasses -gt 0) {
    Write-Host ""  -ForegroundColor Red
    Write-Host "FAILED CLASSES:" -ForegroundColor Red
    $script:CreatedClasses | Where-Object { -not $_.Success } | ForEach-Object {
        Write-Host "   $($_.ClassName)" -ForegroundColor Red
        Write-Host "      Error: $($_.Error)" -ForegroundColor Gray
    }
}

$reportFile = "comprehensive-test-report_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
$reportData = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    ExecutionTime = $totalElapsed.ToString()
    Summary = @{
        ActivitiesCreated = $script:CreatedActivities.Count
        LocationsCreated = $script:CreatedLocations.Count
        TotalActivitiesAvailable = $allActivities.Count
        TotalLocationsAvailable = $allLocations.Count
        ClassesAttempted = $script:CreatedClasses.Count
        ClassesSuccessful = $successClasses
        ClassesFailed = $failedClasses
        OnlineClasses = $onlineClasses
        InPersonClasses = $inPersonClasses
    }
    CreatedActivities = $script:CreatedActivities
    CreatedLocations = $script:CreatedLocations
    CreatedClasses = $script:CreatedClasses
}

$reportData | ConvertTo-Json -Depth 10 | Out-File -FilePath $reportFile -Encoding UTF8
Write-Host ""  -ForegroundColor Cyan
Write-Host "Comprehensive report saved to: $reportFile" -ForegroundColor Cyan

Write-Host ""  -ForegroundColor Green
Write-Host "TEST EXECUTION COMPLETE!" -ForegroundColor Green
Write-Host "Generated Files:" -ForegroundColor Yellow
Write-Host "   - all-activities.json" -ForegroundColor White
Write-Host "   - all-locations.json" -ForegroundColor White
Write-Host "   - $reportFile" -ForegroundColor White

exit 0

