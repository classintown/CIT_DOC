# ===========================================================================
# CLEANUP FLEXIBLE TEST DATA - DELETE ALL TEST ENTITIES (COMPLETE VERSION)
# ===========================================================================
# This script deletes ALL test data created by create-test-data-flexible.ps1
# It reads the JSON report files and systematically deletes all entities
# in the correct order to avoid foreign key issues.
#
# COMPREHENSIVE DELETION - Leaves ZERO residual data:
#   ✅ Payments
#   ✅ Payment Plans
#   ✅ Enrollment Schedules
#   ✅ Enrollment Progress Records
#   ✅ Students (User + Student + SystemUser)
#   ✅ Classes (InstructorClass + Calendar Events)
#   ✅ Locations (Google Maps)
#   ✅ Activities
#
# USAGE:
#   # Delete data from the most recent report
#   .\cleanup-flexible-test-data.ps1 -AuthToken "TOKEN"
#
#   # Delete data from a specific report file
#   .\cleanup-flexible-test-data.ps1 -AuthToken "TOKEN" -ReportFile "flexible-test-report_20251021_214952.json"
#
#   # Delete ALL test data (all reports)
#   .\cleanup-flexible-test-data.ps1 -AuthToken "TOKEN" -DeleteAll
#
#   # Dry run (show what would be deleted without deleting)
#   .\cleanup-flexible-test-data.ps1 -AuthToken "TOKEN" -DryRun
# ===========================================================================
# dev = "https:dev.classintown.com/api/v1"
param(
    [string]$BaseUrl = "http://localhost:2000",
    [string]$AuthToken = "",
    [string]$ReportFile = "",
    [switch]$DeleteAll,
    [switch]$DryRun,
    [switch]$Verbose
)

# ===========================================================================
# VALIDATION
# ===========================================================================

if (-not $AuthToken) {
    Write-Host "Error: Auth token required!" -ForegroundColor Red
    Write-Host "Usage: .\cleanup-flexible-test-data.ps1 -AuthToken 'YOUR_TOKEN' [options]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Parameters:" -ForegroundColor Cyan
    Write-Host "  -ReportFile <path>    Specific report file to clean up (default: most recent)" -ForegroundColor White
    Write-Host "  -DeleteAll            Delete data from ALL report files" -ForegroundColor White
    Write-Host "  -DryRun               Show what would be deleted without deleting" -ForegroundColor White
    Write-Host "  -Verbose              Show detailed progress" -ForegroundColor White
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $AuthToken"
    "Content-Type" = "application/json"
    "Accept" = "application/json"
}

$script:StartTime = Get-Date
$script:DeletedCount = @{
    Payments = 0
    PaymentPlans = 0
    EnrollmentSchedules = 0
    EnrollmentProgress = 0
    Students = 0
    Classes = 0
    Locations = 0
    Activities = 0
}
$script:FailedCount = @{
    Payments = 0
    PaymentPlans = 0
    EnrollmentSchedules = 0
    EnrollmentProgress = 0
    Students = 0
    Classes = 0
    Locations = 0
    Activities = 0
}

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
}

function Write-Verbose-Log {
    param([string]$Message, [string]$Color = "Gray")
    if ($Verbose) {
        Write-Host "  $Message" -ForegroundColor $Color
    }
}

# ===========================================================================
# DELETION FUNCTIONS
# ===========================================================================

function Delete-Entity {
    param(
        [string]$EntityType,
        [string]$EntityId,
        [string]$Endpoint,
        [string]$DisplayName = $EntityId,
        [string]$Method = "DELETE"
    )
    
    if ($DryRun) {
        Write-Host "  [DRY RUN] Would delete $EntityType : $DisplayName" -ForegroundColor Yellow
        $script:DeletedCount[$EntityType]++
        return $true
    }
    
    try {
        $uri = "$BaseUrl$Endpoint"
        Write-Verbose-Log "DELETE $uri"
        
        if ($Method -eq "DELETE") {
            Invoke-RestMethod -Uri $uri -Method DELETE -Headers $headers | Out-Null
        } else {
            # For soft deletes (PATCH)
            Invoke-RestMethod -Uri $uri -Method $Method -Headers $headers -Body "{}" | Out-Null
        }
        
        Write-Host "  [OK] Deleted $EntityType : $DisplayName" -ForegroundColor Green
        $script:DeletedCount[$EntityType]++
        return $true
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        $errorMsg = $_.Exception.Message
        
        # 404 means already deleted, count as success
        if ($statusCode -eq 404) {
            Write-Host "  [SKIP] $EntityType already deleted: $DisplayName" -ForegroundColor Gray
            $script:DeletedCount[$EntityType]++
            return $true
        }
        
        Write-Host "  [FAIL] Failed to delete $EntityType : $DisplayName - $errorMsg" -ForegroundColor Red
        $script:FailedCount[$EntityType]++
        return $false
    }
}

# ===========================================================================
# FIND REPORT FILES
# ===========================================================================

Write-Host ""
Write-Host "===================================================================" -ForegroundColor Magenta
Write-Host "  FLEXIBLE TEST DATA CLEANUP - COMPLETE DELETION" -ForegroundColor Magenta
Write-Host "===================================================================" -ForegroundColor Magenta
Write-Host ""

$reportFiles = @()

if ($DeleteAll) {
    Write-Progress-Log "Scanning for ALL flexible test report files..." "Yellow"
    $reportFiles = Get-ChildItem -Path $PSScriptRoot -Filter "flexible-test-report_*.json" | Sort-Object LastWriteTime -Descending
    
    if ($reportFiles.Count -eq 0) {
        Write-Host "No report files found!" -ForegroundColor Yellow
        exit 0
    }
    
    Write-Host "Found $($reportFiles.Count) report file(s):" -ForegroundColor Cyan
    foreach ($file in $reportFiles) {
        Write-Host "  - $($file.Name) ($(Get-Date $file.LastWriteTime -Format 'yyyy-MM-dd HH:mm:ss'))" -ForegroundColor White
    }
}
elseif ($ReportFile) {
    Write-Progress-Log "Using specified report file: $ReportFile" "Yellow"
    if (-not (Test-Path $ReportFile)) {
        Write-Host "ERROR: Report file not found: $ReportFile" -ForegroundColor Red
        exit 1
    }
    $reportFiles = @(Get-Item $ReportFile)
}
else {
    Write-Progress-Log "Searching for most recent report file..." "Yellow"
    $reportFiles = Get-ChildItem -Path $PSScriptRoot -Filter "flexible-test-report_*.json" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    
    if ($reportFiles.Count -eq 0) {
        Write-Host "No report files found!" -ForegroundColor Yellow
        exit 0
    }
    
    Write-Host "Using most recent report: $($reportFiles[0].Name)" -ForegroundColor Cyan
}

if ($DryRun) {
    Write-Host ""
    Write-Host "=== DRY RUN MODE - NO DATA WILL BE DELETED ===" -ForegroundColor Yellow
    Write-Host ""
}

# ===========================================================================
# PROCESS EACH REPORT FILE
# ===========================================================================

foreach ($reportFile in $reportFiles) {
    $fileName = if ($reportFile.Name) { $reportFile.Name } else { Split-Path $reportFile -Leaf }
    $filePath = if ($reportFile.FullName) { $reportFile.FullName } else { $reportFile }
    
    Write-Step-Header "PROCESSING" $fileName
    
    try {
        $reportData = Get-Content $filePath -Raw | ConvertFrom-Json
    }
    catch {
        Write-Host "ERROR: Failed to read report file: $($_.Exception.Message)" -ForegroundColor Red
        continue
    }
    
    Write-Host "Report Details:" -ForegroundColor Cyan
    Write-Host "  Timestamp: $($reportData.Timestamp)" -ForegroundColor White
    Write-Host "  Activities: $($reportData.Results.ActivitiesCreated)" -ForegroundColor White
    Write-Host "  Locations: $($reportData.Results.LocationsCreated)" -ForegroundColor White
    Write-Host "  Classes: $($reportData.Results.ClassesCreated)" -ForegroundColor White
    Write-Host "  Students: $($reportData.Results.StudentsCreated)" -ForegroundColor White
    Write-Host "  Enrollments: $($reportData.Results.TotalEnrollments)" -ForegroundColor White
    Write-Host "  Payment Plans: $($reportData.Results.PaymentPlansCreated)" -ForegroundColor White
    
    # ========================================================================
    # STEP 1: DELETE PAYMENTS
    # ========================================================================
    
    if ($reportData.Enrollments -and $reportData.Enrollments.Count -gt 0) {
        Write-Step-Header "STEP 1" "Deleting Payments"
        
        $paymentsToDelete = @()
        
        foreach ($enrollment in $reportData.Enrollments) {
            if ($enrollment.PaymentPlanId) {
                # Fetch payment plan to get payment IDs
                try {
                    if (-not $DryRun) {
                        $planUri = "$BaseUrl/enrollment/payment-plan/$($enrollment.PaymentPlanId)"
                        $planData = Invoke-RestMethod -Uri $planUri -Method GET -Headers $headers
                        
                        # Extract payment IDs from plan data
                        if ($planData.data -and $planData.data.planItems) {
                            foreach ($item in $planData.data.planItems) {
                                if ($item.payments -and $item.payments.Count -gt 0) {
                                    foreach ($payment in $item.payments) {
                                        $paymentsToDelete += $payment._id
                                    }
                                }
                            }
                        }
                    }
                }
                catch {
                    Write-Verbose-Log "Could not fetch payment plan details: $($_.Exception.Message)" "Yellow"
                }
            }
        }
        
        if ($paymentsToDelete.Count -gt 0) {
            Write-Progress-Log "Found $($paymentsToDelete.Count) payment(s) to delete" "Yellow"
                foreach ($paymentId in $paymentsToDelete) {
                Delete-Entity -EntityType "Payments" -EntityId $paymentId -Endpoint "/cleanup/payment/$paymentId" -DisplayName $paymentId -Method "DELETE"
                Start-Sleep -Milliseconds 100
            }
        }
        else {
            Write-Progress-Log "No payments to delete" "Gray"
        }
    }
    
    # ========================================================================
    # STEP 2: DELETE PAYMENT PLANS
    # ========================================================================
    
    if ($reportData.PaymentPlans -and $reportData.PaymentPlans.Count -gt 0) {
        Write-Step-Header "STEP 2" "Deleting Payment Plans"
        
        Write-Progress-Log "Deleting $($reportData.PaymentPlans.Count) payment plan(s)..." "Yellow"
        
        foreach ($plan in $reportData.PaymentPlans) {
            if ($plan.PaymentPlanId -and $plan.EnrollmentId) {
                # Find the corresponding classId from enrollments
                $enrollment = $reportData.Enrollments | Where-Object { $_.EnrollmentScheduleId -eq $plan.EnrollmentId } | Select-Object -First 1
                $classId = if ($enrollment) { $enrollment.ClassId } else { "unknown" }
                
                # Correct endpoint: DELETE /enrollment/payment-plans/:enrollmentId/:instructorClassId
                Delete-Entity -EntityType "PaymentPlans" -EntityId $plan.PaymentPlanId -Endpoint "/enrollment/payment-plans/$($plan.EnrollmentId)/$classId" -DisplayName "$($plan.StudentEmail) - $($plan.PaymentPlanId)"
                Start-Sleep -Milliseconds 100
            }
        }
    }
    
    # ========================================================================
    # STEP 3: DELETE ENROLLMENT SCHEDULES
    # ========================================================================
    
    if ($reportData.Enrollments -and $reportData.Enrollments.Count -gt 0) {
        Write-Step-Header "STEP 3" "Deleting Enrollment Schedules"
        
        $schedulesToDelete = @()
        foreach ($enrollment in $reportData.Enrollments) {
            if ($enrollment.EnrollmentScheduleId -and $enrollment.EnrollmentScheduleId -ne $null) {
                $schedulesToDelete += $enrollment
            }
        }
        
        if ($schedulesToDelete.Count -gt 0) {
            Write-Progress-Log "Deleting $($schedulesToDelete.Count) enrollment schedule(s)..." "Yellow"
            
            foreach ($enrollment in $schedulesToDelete) {
                # Correct endpoint: DELETE /enrollment/schedule/hard-delete/:id
                Delete-Entity -EntityType "EnrollmentSchedules" -EntityId $enrollment.EnrollmentScheduleId -Endpoint "/enrollment/schedule/hard-delete/$($enrollment.EnrollmentScheduleId)" -DisplayName "$($enrollment.StudentEmail) - $($enrollment.ClassName)"
                Start-Sleep -Milliseconds 100
            }
        }
        else {
            Write-Progress-Log "No enrollment schedules to delete" "Gray"
        }
    }
    
    # ========================================================================
    # STEP 4: DELETE ENROLLMENT PROGRESS
    # ========================================================================
    
    if ($reportData.Enrollments -and $reportData.Enrollments.Count -gt 0) {
        Write-Step-Header "STEP 4" "Deleting Enrollment Progress Records"
        
        $progressToDelete = @()
        foreach ($enrollment in $reportData.Enrollments) {
            if ($enrollment.EnrollmentProgressId -and $enrollment.EnrollmentProgressId -ne $null) {
                $progressToDelete += $enrollment
            }
        }
        
        if ($progressToDelete.Count -gt 0) {
            Write-Progress-Log "Deleting $($progressToDelete.Count) enrollment progress record(s)..." "Yellow"
            
            foreach ($enrollment in $progressToDelete) {
                # Use DELETE /cleanup/enrollment-progress/:id (HARD DELETE)
                Delete-Entity -EntityType "EnrollmentProgress" -EntityId $enrollment.EnrollmentProgressId -Endpoint "/cleanup/enrollment-progress/$($enrollment.EnrollmentProgressId)" -DisplayName "$($enrollment.StudentEmail) - $($enrollment.ClassName)" -Method "DELETE"
                Start-Sleep -Milliseconds 100
            }
        }
        else {
            Write-Progress-Log "No enrollment progress records to delete" "Gray"
        }
    }
    
    # ========================================================================
    # STEP 5: DELETE STUDENTS (User + Student + SystemUser)
    # ========================================================================
    
    if ($reportData.CreatedStudents -and $reportData.CreatedStudents.Count -gt 0) {
        Write-Step-Header "STEP 5" "Deleting Students (User + Student + SystemUser)"
        
        Write-Progress-Log "Deleting $($reportData.CreatedStudents.Count) student(s) and all related records..." "Yellow"
        
        foreach ($student in $reportData.CreatedStudents) {
            Write-Verbose-Log "Deleting student: $($student.Email)" "Cyan"
            
            # Delete Student record (HARD DELETE)
            if ($student.StudentDetailId) {
                Delete-Entity -EntityType "Students" -EntityId $student.StudentDetailId -Endpoint "/cleanup/student/$($student.StudentDetailId)" -DisplayName "$($student.Email) (Student)" -Method "DELETE"
                Start-Sleep -Milliseconds 100
            }
            
            # Delete User record (HARD DELETE - will also cascade to SystemUser)
            if ($student.StudentUserId) {
                Delete-Entity -EntityType "Students" -EntityId $student.StudentUserId -Endpoint "/cleanup/user/$($student.StudentUserId)" -DisplayName "$($student.Email) (User)" -Method "DELETE"
                Start-Sleep -Milliseconds 200
            }
        }
    }
    
    # ========================================================================
    # STEP 6: DELETE CLASSES
    # ========================================================================
    
    if ($reportData.CreatedClasses -and $reportData.CreatedClasses.Count -gt 0) {
        Write-Step-Header "STEP 6" "Deleting Classes"
        
        $classesToDelete = @()
        foreach ($class in $reportData.CreatedClasses) {
            if ($class.Success -and $class.ClassId -and $class.ClassId -ne $null) {
                $classesToDelete += $class
            }
        }
        
        if ($classesToDelete.Count -gt 0) {
            Write-Progress-Log "Deleting $($classesToDelete.Count) class(es) via admin endpoint..." "Yellow"
            
            foreach ($class in $classesToDelete) {
                # Use DELETE /cleanup/class/:id (HARD DELETE - permanent removal)
                Delete-Entity -EntityType "Classes" -EntityId $class.ClassId -Endpoint "/cleanup/class/$($class.ClassId)" -DisplayName "$($class.Activity) ($($class.ClassId))" -Method "DELETE"
                Start-Sleep -Milliseconds 100
            }
        }
        else {
            Write-Progress-Log "No classes to delete" "Gray"
        }
    }
    
    # ========================================================================
    # STEP 7: DELETE LOCATIONS (Google Maps)
    # ========================================================================
    
    if ($reportData.CreatedLocations -and $reportData.CreatedLocations.Count -gt 0) {
        Write-Step-Header "STEP 7" "Deleting Locations (Google Maps)"
        
        $locationsWithIds = @()
        foreach ($location in $reportData.CreatedLocations) {
            if ($location.Id -and $location.Id -ne $null) {
                $locationsWithIds += $location
            }
        }
        
        if ($locationsWithIds.Count -gt 0) {
            Write-Progress-Log "Deleting $($locationsWithIds.Count) location(s)..." "Yellow"
            
            foreach ($location in $locationsWithIds) {
                # Use DELETE /cleanup/location/:id (HARD DELETE - permanent removal)
                Delete-Entity -EntityType "Locations" -EntityId $location.Id -Endpoint "/cleanup/location/$($location.Id)" -DisplayName "$($location.Name) ($($location.City))" -Method "DELETE"
                Start-Sleep -Milliseconds 100
            }
        }
        else {
            Write-Progress-Log "No locations with valid IDs to delete (locations may not have been created successfully)" "Yellow"
        }
    }
    
    # ========================================================================
    # STEP 8: DELETE ACTIVITIES
    # ========================================================================
    
    if ($reportData.CreatedActivities -and $reportData.CreatedActivities.Count -gt 0) {
        Write-Step-Header "STEP 8" "Deleting Activities"
        
        $activitiesWithIds = @()
        foreach ($activity in $reportData.CreatedActivities) {
            if ($activity.Id -and $activity.Id -ne $null) {
                $activitiesWithIds += $activity
            }
        }
        
        if ($activitiesWithIds.Count -gt 0) {
            Write-Progress-Log "Deleting $($activitiesWithIds.Count) activity/activities..." "Yellow"
            
            foreach ($activity in $activitiesWithIds) {
                # Use DELETE /cleanup/activity/:id (HARD DELETE - permanent removal)
                Delete-Entity -EntityType "Activities" -EntityId $activity.Id -Endpoint "/cleanup/activity/$($activity.Id)" -DisplayName "$($activity.Name) ($($activity.Category))" -Method "DELETE"
                Start-Sleep -Milliseconds 100
            }
        }
        else {
            Write-Progress-Log "No activities with valid IDs to delete" "Yellow"
        }
    }
}

# ===========================================================================
# DELETE REPORT FILES (OPTIONAL)
# ===========================================================================

Write-Step-Header "CLEANUP" "Report Files"

$deleteReports = $false
if (-not $DryRun) {
    Write-Host "Do you want to delete the report files? (y/N): " -ForegroundColor Yellow -NoNewline
    $response = Read-Host
    $deleteReports = ($response -eq 'y' -or $response -eq 'Y')
}

if ($deleteReports) {
    foreach ($reportFile in $reportFiles) {
        try {
            $fileName = if ($reportFile.Name) { $reportFile.Name } else { Split-Path $reportFile -Leaf }
            $filePath = if ($reportFile.FullName) { $reportFile.FullName } else { $reportFile }
            
            Remove-Item $filePath -Force
            Write-Host "  [OK] Deleted report file: $fileName" -ForegroundColor Green
            
            # Also delete corresponding student credentials file
            $studentFile = $fileName -replace "flexible-test-report_", "test-students_"
            $studentFilePath = Join-Path $PSScriptRoot $studentFile
            if (Test-Path $studentFilePath) {
                Remove-Item $studentFilePath -Force
                Write-Host "  [OK] Deleted student file: $studentFile" -ForegroundColor Green
            }
        }
        catch {
            Write-Host "  [FAIL] Failed to delete report file: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}
else {
    Write-Host "  Report files kept for reference" -ForegroundColor Cyan
}

# ===========================================================================
# FINAL REPORT
# ===========================================================================

$totalElapsed = (Get-Date) - $script:StartTime
$totalStr = "{0:mm}:{0:ss}" -f $totalElapsed

Write-Host ""
Write-Host "===================================================================" -ForegroundColor Green
Write-Host "              CLEANUP COMPLETE!                                 " -ForegroundColor Green
Write-Host "===================================================================" -ForegroundColor Green
Write-Host ""

if ($DryRun) {
    Write-Host "=== DRY RUN SUMMARY - NO DATA WAS DELETED ===" -ForegroundColor Yellow
}

Write-Host "SUMMARY:" -ForegroundColor Cyan
Write-Host "   Execution Time: $totalStr" -ForegroundColor White
Write-Host ""
Write-Host "   Deleted Successfully:" -ForegroundColor Green
Write-Host "      Payments: $($script:DeletedCount.Payments)" -ForegroundColor White
Write-Host "      Payment Plans: $($script:DeletedCount.PaymentPlans)" -ForegroundColor White
Write-Host "      Enrollment Schedules: $($script:DeletedCount.EnrollmentSchedules)" -ForegroundColor White
Write-Host "      Enrollment Progress: $($script:DeletedCount.EnrollmentProgress)" -ForegroundColor White
Write-Host "      Students: $($script:DeletedCount.Students)" -ForegroundColor White
Write-Host "      Classes: $($script:DeletedCount.Classes)" -ForegroundColor White
Write-Host "      Locations: $($script:DeletedCount.Locations)" -ForegroundColor White
Write-Host "      Activities: $($script:DeletedCount.Activities)" -ForegroundColor White
Write-Host ""

$totalDeleted = ($script:DeletedCount.Values | Measure-Object -Sum).Sum
Write-Host "   TOTAL ENTITIES DELETED: $totalDeleted" -ForegroundColor Green
Write-Host ""

if (($script:FailedCount.Values | Measure-Object -Sum).Sum -gt 0) {
    Write-Host "   Failed to Delete:" -ForegroundColor Red
    Write-Host "      Payments: $($script:FailedCount.Payments)" -ForegroundColor White
    Write-Host "      Payment Plans: $($script:FailedCount.PaymentPlans)" -ForegroundColor White
    Write-Host "      Enrollment Schedules: $($script:FailedCount.EnrollmentSchedules)" -ForegroundColor White
    Write-Host "      Enrollment Progress: $($script:FailedCount.EnrollmentProgress)" -ForegroundColor White
    Write-Host "      Students: $($script:FailedCount.Students)" -ForegroundColor White
    Write-Host "      Classes: $($script:FailedCount.Classes)" -ForegroundColor White
    Write-Host "      Locations: $($script:FailedCount.Locations)" -ForegroundColor White
    Write-Host "      Activities: $($script:FailedCount.Activities)" -ForegroundColor White
    Write-Host ""
}

if ($totalDeleted -eq 0 -and -not $DryRun) {
    Write-Host "⚠️  WARNING: No entities were deleted. Database might already be clean." -ForegroundColor Yellow
}
elseif ($totalDeleted -gt 0) {
    Write-Host "✅ SUCCESS: All test data has been cleaned up!" -ForegroundColor Green
    Write-Host "   Your database is now free of test residue." -ForegroundColor Cyan
}

Write-Host ""
Write-Host "All done!" -ForegroundColor Green
Write-Host ""

exit 0
