# Count-Based Scheduling - Comprehensive Test Cases
**Date:** 2025-01-27  
**Scope:** All edge cases for count-based class scheduling (create, edit, update, delete)

---

## Test Environment Setup

**Prerequisites:**
- User logged in as Instructor
- At least one Activity created
- At least one Location created (for in-person classes)
- System timezone: Any (test with multiple timezones)
- Current date/time: Note for past date validation tests

**Test Data:**
- Activity: "Yoga Class"
- Location: "Studio A"
- Default timezone: System detected (e.g., "America/New_York", "Asia/Kolkata")

---

## 1. BASIC CREATION TEST CASES

### TC-001: Create Count-Based Class with 2 Slots (09:00 AM - 10:00 AM)
**Objective:** Verify basic count-based class creation with multiple slots

**Steps:**
1. Navigate to Create Class page
2. Select "Count-based" class type
3. Set `classCount` = 2
4. Fill in basic class details (activity, location, etc.)
5. **Slot 1:**
   - Date: Select future date (e.g., 7 days from today)
   - Start Time: 09:00 AM
   - End Time: 10:00 AM
6. **Slot 2:**
   - Date: Select different future date (e.g., 10 days from today)
   - Start Time: 09:00 AM
   - End Time: 10:00 AM
7. Submit form

**Expected Results:**
- ✅ Class created successfully
- ✅ Both slots saved with correct dates and times
- ✅ `schedules` array contains 2 schedule objects
- ✅ Each schedule has `day` = date string (e.g., "2025-02-10")
- ✅ Each slot has `start.dateTime` in UTC, `start.timeZone` = user's timezone
- ✅ Each slot has `end.dateTime` in UTC, `end.timeZone` = user's timezone
- ✅ Google Calendar events created (if not continuous class)
- ✅ No validation errors

**Verify in DB:**
```javascript
{
  classType: "CountBased",
  classCount: 2,
  schedules: [
    {
      day: "2025-02-10", // or actual date
      slots: [{
        start: { dateTime: "2025-02-10T03:30:00.000Z", timeZone: "Asia/Kolkata" },
        end: { dateTime: "2025-02-10T04:30:00.000Z", timeZone: "Asia/Kolkata" }
      }]
    },
    {
      day: "2025-02-13", // or actual date
      slots: [{
        start: { dateTime: "2025-02-13T03:30:00.000Z", timeZone: "Asia/Kolkata" },
        end: { dateTime: "2025-02-13T04:30:00.000Z", timeZone: "Asia/Kolkata" }
      }]
    }
  ]
}
```

---

### TC-002: Create Count-Based Class with Single Slot
**Objective:** Verify minimum slot requirement

**Steps:**
1. Select "Count-based" class type
2. Set `classCount` = 1
3. Fill in basic class details
4. **Slot 1:**
   - Date: Future date
   - Start Time: 09:00 AM
   - End Time: 10:00 AM
5. Submit form

**Expected Results:**
- ✅ Class created successfully
- ✅ Single slot saved correctly
- ✅ No validation errors

---

### TC-003: Create Count-Based Class with Maximum Slots
**Objective:** Verify system handles large number of slots

**Steps:**
1. Select "Count-based" class type
2. Set `classCount` = 50 (or maximum allowed)
3. Fill in basic class details
4. Add 50 slots with different dates
5. Submit form

**Expected Results:**
- ✅ All 50 slots saved correctly
- ✅ No performance issues
- ✅ All dates and times preserved correctly

---

### TC-004: Create Count-Based Class with Same Date, Different Times
**Objective:** Verify multiple slots on same date are allowed

**Steps:**
1. Select "Count-based" class type
2. Set `classCount` = 2
3. Fill in basic class details
4. **Slot 1:**
   - Date: 2025-02-10
   - Start Time: 09:00 AM
   - End Time: 10:00 AM
5. **Slot 2:**
   - Date: 2025-02-10 (SAME DATE)
   - Start Time: 02:00 PM
   - End Time: 03:00 PM
6. Submit form

**Expected Results:**
- ✅ Both slots saved on same date
- ✅ No overlap validation error (different times)
- ✅ Both slots grouped under same `day` in schedules array

---

### TC-005: Create Count-Based Class with Overlapping Times (Same Date)
**Objective:** Verify overlap detection works for same-date slots

**Steps:**
1. Select "Count-based" class type
2. Set `classCount` = 2
3. Fill in basic class details
4. **Slot 1:**
   - Date: 2025-02-10
   - Start Time: 09:00 AM
   - End Time: 10:00 AM
5. **Slot 2:**
   - Date: 2025-02-10 (SAME DATE)
   - Start Time: 09:30 AM (OVERLAPS)
   - End Time: 10:30 AM
6. Submit form

**Expected Results:**
- ❌ Validation error: "Overlapping time slots detected"
- ❌ Form submission blocked
- ❌ Error message indicates which date has overlap

---

## 2. TIME EDGE CASES

### TC-006: Cross-Day Slot (11:00 PM - 01:00 AM)
**Objective:** Verify cross-day slots are handled correctly

**Steps:**
1. Select "Count-based" class type
2. Set `classCount` = 1
3. Fill in basic class details
4. **Slot 1:**
   - Date: 2025-02-10
   - Start Time: 11:00 PM
   - End Time: 01:00 AM (next day)
5. Submit form

**Expected Results:**
- ✅ Slot created successfully
- ✅ Frontend shows "Cross-Day" indicator
- ✅ `start.dateTime` = 2025-02-10T17:30:00.000Z (UTC, assuming IST)
- ✅ `end.dateTime` = 2025-02-11T19:30:00.000Z (next day in UTC)
- ✅ `isCrossDay` metadata set to `true`
- ✅ `endDate` metadata = 2025-02-11

**Verify in DB:**
```javascript
{
  slots: [{
    start: { dateTime: "2025-02-10T17:30:00.000Z", timeZone: "Asia/Kolkata" },
    end: { dateTime: "2025-02-11T19:30:00.000Z", timeZone: "Asia/Kolkata" }
  }]
}
```

---

### TC-007: Boundary Time - Midnight Start (12:00 AM)
**Objective:** Verify midnight boundary handling

**Steps:**
1. Select "Count-based" class type
2. Set `classCount` = 1
3. **Slot 1:**
   - Date: 2025-02-10
   - Start Time: 12:00 AM
   - End Time: 01:00 AM
4. Submit form

**Expected Results:**
- ✅ Slot created successfully
- ✅ Correct date calculation (midnight = start of day)

---

### TC-008: Boundary Time - 11:59 PM End
**Objective:** Verify end-of-day boundary handling

**Steps:**
1. Select "Count-based" class type
2. Set `classCount` = 1
3. **Slot 1:**
   - Date: 2025-02-10
   - Start Time: 10:00 PM
   - End Time: 11:59 PM
4. Submit form

**Expected Results:**
- ✅ Slot created successfully
- ✅ End time correctly set to 11:59 PM on same day

---

### TC-009: Very Short Duration (15 minutes)
**Objective:** Verify minimum duration handling

**Steps:**
1. Select "Count-based" class type
2. Set `classCount` = 1
3. **Slot 1:**
   - Date: 2025-02-10
   - Start Time: 09:00 AM
   - End Time: 09:15 AM
4. Submit form

**Expected Results:**
- ✅ Slot created successfully (if 15 min is allowed)
- ⚠️ OR validation error if minimum duration enforced

---

### TC-010: Very Long Duration (8 hours)
**Objective:** Verify maximum duration handling

**Steps:**
1. Select "Count-based" class type
2. Set `classCount` = 1
3. **Slot 1:**
   - Date: 2025-02-10
   - Start Time: 09:00 AM
   - End Time: 05:00 PM
4. Submit form

**Expected Results:**
- ✅ Slot created successfully (if 8 hours is allowed)
- ⚠️ OR validation error if maximum duration enforced

---

### TC-011: End Time Before Start Time (Same Day - Invalid)
**Objective:** Verify validation prevents invalid time ranges

**Steps:**
1. Select "Count-based" class type
2. Set `classCount` = 1
3. **Slot 1:**
   - Date: 2025-02-10
   - Start Time: 10:00 AM
   - End Time: 09:00 AM (BEFORE start)
4. Submit form

**Expected Results:**
- ❌ Validation error: "End time must be after start time"
- ❌ Form submission blocked
- ❌ Error shown on slot field

---

### TC-012: End Time Equals Start Time (Invalid)
**Objective:** Verify zero-duration slots are rejected

**Steps:**
1. Select "Count-based" class type
2. Set `classCount` = 1
3. **Slot 1:**
   - Date: 2025-02-10
   - Start Time: 09:00 AM
   - End Time: 09:00 AM (SAME AS START)
4. Submit form

**Expected Results:**
- ❌ Validation error: "End time must be after start time"
- ❌ Form submission blocked

---

## 3. DATE EDGE CASES

### TC-013: Past Date (Should Fail)
**Objective:** Verify past date validation

**Steps:**
1. Select "Count-based" class type
2. Set `classCount` = 1
3. **Slot 1:**
   - Date: Yesterday's date
   - Start Time: 09:00 AM
   - End Time: 10:00 AM
4. Submit form

**Expected Results:**
- ❌ Validation error: "Cannot schedule a slot in the past"
- ❌ Form submission blocked
- ❌ Date picker should disable past dates

---

### TC-014: Today's Date with Past Time
**Objective:** Verify past time validation on today's date

**Steps:**
1. Select "Count-based" class type
2. Set `classCount` = 1
3. **Slot 1:**
   - Date: Today
   - Start Time: 08:00 AM (if current time is 10:00 AM)
   - End Time: 09:00 AM
4. Submit form

**Expected Results:**
- ❌ Validation error: "Cannot schedule a slot in the past"
- ❌ Form submission blocked

---

### TC-015: Today's Date with Future Time
**Objective:** Verify today's date with future time is allowed

**Steps:**
1. Select "Count-based" class type
2. Set `classCount` = 1
3. **Slot 1:**
   - Date: Today
   - Start Time: 2 hours from now
   - End Time: 3 hours from now
4. Submit form

**Expected Results:**
- ✅ Slot created successfully
- ✅ No validation errors

---

### TC-016: Far Future Date (1 year ahead)
**Objective:** Verify far future dates are allowed

**Steps:**
1. Select "Count-based" class type
2. Set `classCount` = 1
3. **Slot 1:**
   - Date: 1 year from today
   - Start Time: 09:00 AM
   - End Time: 10:00 AM
4. Submit form

**Expected Results:**
- ✅ Slot created successfully
- ✅ No validation errors
- ⚠️ OR warning if there's a maximum date limit

---

### TC-017: Leap Year Date (February 29)
**Objective:** Verify leap year date handling

**Steps:**
1. Select "Count-based" class type
2. Set `classCount` = 1
3. **Slot 1:**
   - Date: 2024-02-29 (leap year)
   - Start Time: 09:00 AM
   - End Time: 10:00 AM
4. Submit form

**Expected Results:**
- ✅ Slot created successfully
- ✅ Date correctly stored

---

### TC-018: Non-Leap Year February 29 (Should Fail)
**Objective:** Verify invalid date validation

**Steps:**
1. Select "Count-based" class type
2. Set `classCount` = 1
3. **Slot 1:**
   - Date: 2025-02-29 (NOT a leap year)
   - Start Time: 09:00 AM
   - End Time: 10:00 AM
4. Submit form

**Expected Results:**
- ❌ Date picker should not allow selection
- ❌ OR validation error: "Invalid date"

---

## 4. EDIT/UPDATE TEST CASES

### TC-019: Edit Slot Time (09:00 AM → 11:00 AM)
**Objective:** Verify slot time can be edited

**Steps:**
1. Open existing count-based class
2. Edit Slot 1:
   - Keep same date
   - Change Start Time: 09:00 AM → 11:00 AM
   - Change End Time: 10:00 AM → 12:00 PM
3. Save changes

**Expected Results:**
- ✅ Slot updated successfully
- ✅ Old Google Calendar event deleted (if exists)
- ✅ New Google Calendar event created with new time
- ✅ DB updated with new times
- ✅ No validation errors

**Verify in DB:**
- `start.dateTime` updated to new UTC time
- `end.dateTime` updated to new UTC time
- `timeZone` preserved

---

### TC-020: Edit Slot Date (Change Date Only)
**Objective:** Verify slot date can be edited

**Steps:**
1. Open existing count-based class
2. Edit Slot 1:
   - Change Date: 2025-02-10 → 2025-02-15
   - Keep same times (09:00 AM - 10:00 AM)
3. Save changes

**Expected Results:**
- ✅ Slot updated successfully
- ✅ `day` field updated in schedule
- ✅ `start.dateTime` and `end.dateTime` updated to new date
- ✅ Old Google Calendar event deleted
- ✅ New Google Calendar event created

---

### TC-021: Edit Slot Date and Time Together
**Objective:** Verify both date and time can be edited simultaneously

**Steps:**
1. Open existing count-based class
2. Edit Slot 1:
   - Change Date: 2025-02-10 → 2025-02-15
   - Change Start Time: 09:00 AM → 02:00 PM
   - Change End Time: 10:00 AM → 03:00 PM
3. Save changes

**Expected Results:**
- ✅ Slot updated successfully
- ✅ All fields updated correctly
- ✅ Google Calendar event updated

---

### TC-022: Edit Slot to Past Date (Should Fail)
**Objective:** Verify past date validation on edit

**Steps:**
1. Open existing count-based class with future slot
2. Edit Slot 1:
   - Change Date: Future date → Yesterday
   - Keep same times
3. Save changes

**Expected Results:**
- ❌ Validation error: "Cannot update a slot to a past date"
- ❌ Changes not saved
- ❌ Original slot preserved

---

### TC-023: Edit Slot to Overlapping Time (Should Fail)
**Objective:** Verify overlap detection on edit

**Steps:**
1. Open existing count-based class with 2 slots:
   - Slot 1: 2025-02-10, 09:00 AM - 10:00 AM
   - Slot 2: 2025-02-10, 02:00 PM - 03:00 PM
2. Edit Slot 2:
   - Keep same date
   - Change Start Time: 02:00 PM → 09:30 AM (OVERLAPS with Slot 1)
   - Change End Time: 03:00 PM → 10:30 AM
3. Save changes

**Expected Results:**
- ❌ Validation error: "Overlapping time slots detected"
- ❌ Changes not saved
- ❌ Original slot preserved

---

### TC-024: Edit Slot to Cross-Day
**Objective:** Verify slot can be edited to cross-day

**Steps:**
1. Open existing count-based class with same-day slot
2. Edit Slot 1:
   - Keep same date
   - Change Start Time: 09:00 AM → 11:00 PM
   - Change End Time: 10:00 AM → 01:00 AM (next day)
3. Save changes

**Expected Results:**
- ✅ Slot updated successfully
- ✅ Cross-day indicator shown
- ✅ `end.dateTime` updated to next day
- ✅ `isCrossDay` metadata set to `true`

---

### TC-025: Edit Cross-Day Slot to Same-Day
**Objective:** Verify cross-day slot can be edited to same-day

**Steps:**
1. Open existing count-based class with cross-day slot
2. Edit Slot 1:
   - Keep same date
   - Change Start Time: 11:00 PM → 09:00 AM
   - Change End Time: 01:00 AM → 10:00 AM (same day)
3. Save changes

**Expected Results:**
- ✅ Slot updated successfully
- ✅ Cross-day indicator removed
- ✅ `end.dateTime` updated to same day
- ✅ `isCrossDay` metadata set to `false`

---

### TC-026: Add New Slot to Existing Class
**Objective:** Verify new slot can be added to existing class

**Steps:**
1. Open existing count-based class with 2 slots
2. Increase `classCount` to 3
3. Add Slot 3:
   - Date: Future date (different from existing)
   - Start Time: 09:00 AM
   - End Time: 10:00 AM
4. Save changes

**Expected Results:**
- ✅ New slot added successfully
- ✅ `classCount` updated to 3
- ✅ New Google Calendar event created
- ✅ All 3 slots preserved

---

### TC-027: Remove Slot from Existing Class
**Objective:** Verify slot can be removed

**Steps:**
1. Open existing count-based class with 3 slots
2. Delete Slot 2 (remove from UI)
3. Decrease `classCount` to 2 (or auto-decrease)
4. Save changes

**Expected Results:**
- ✅ Slot removed successfully
- ✅ `classCount` updated to 2
- ✅ Google Calendar event deleted
- ✅ DB updated (slot removed from schedules)
- ✅ Remaining 2 slots preserved

---

### TC-028: Remove All Slots (Should Fail or Handle Gracefully)
**Objective:** Verify minimum slot requirement

**Steps:**
1. Open existing count-based class with 2 slots
2. Delete both slots
3. Try to save

**Expected Results:**
- ❌ Validation error: "At least one slot is required"
- ❌ OR system prevents deletion of last slot
- ❌ Changes not saved

---

## 5. TIMEZONE EDGE CASES

### TC-029: Create Slot in Different Timezone (User Travels)
**Objective:** Verify timezone handling when user's system timezone changes

**Steps:**
1. User in "America/New_York" timezone
2. Create count-based class:
   - Slot 1: 2025-02-10, 09:00 AM - 10:00 AM
3. User travels to "Asia/Kolkata" timezone
4. View/edit the same class

**Expected Results:**
- ✅ Slot times displayed correctly in new timezone
- ✅ Original `timeZone` field preserved in DB
- ✅ Times converted for display but stored timezone unchanged

---

### TC-030: Create Slot with Timezone Boundary (DST Change)
**Objective:** Verify DST transition handling

**Steps:**
1. Create count-based class:
   - Slot 1: 2025-03-09 (DST change date in US)
   - Start Time: 02:00 AM
   - End Time: 03:00 AM
2. Submit form

**Expected Results:**
- ✅ Slot created successfully
- ✅ Correct UTC conversion (handles DST)
- ✅ No time shift issues

---

### TC-031: Create Slot with "Asia/Calcutta" vs "Asia/Kolkata"
**Objective:** Verify timezone normalization

**Steps:**
1. Manually set timezone to "Asia/Calcutta" (if possible)
2. Create count-based class:
   - Slot 1: 2025-02-10, 09:00 AM - 10:00 AM
3. Submit form

**Expected Results:**
- ✅ Slot created successfully
- ✅ Backend normalizes to "Asia/Kolkata" (if normalization applied)
- ✅ OR stored as "Asia/Calcutta" (if no normalization in create flow)

---

## 6. CONFLICT DETECTION TEST CASES

### TC-032: Overlap with Existing Class (Same Instructor)
**Objective:** Verify conflict detection with other classes

**Steps:**
1. Create Class A:
   - Slot 1: 2025-02-10, 09:00 AM - 10:00 AM
2. Create Class B (same instructor):
   - Slot 1: 2025-02-10, 09:30 AM - 10:30 AM (OVERLAPS)
3. Submit Class B

**Expected Results:**
- ❌ Validation error: "Time slot overlaps with existing class"
- ❌ Form submission blocked
- ❌ Error indicates which class conflicts

---

### TC-033: Overlap with Existing Class (Different Date)
**Objective:** Verify no false positives for different dates

**Steps:**
1. Create Class A:
   - Slot 1: 2025-02-10, 09:00 AM - 10:00 AM
2. Create Class B (same instructor):
   - Slot 1: 2025-02-11, 09:00 AM - 10:00 AM (SAME TIME, DIFFERENT DATE)
3. Submit Class B

**Expected Results:**
- ✅ Class B created successfully
- ✅ No conflict detected (different dates)

---

### TC-034: Adjacent Slots (No Overlap)
**Objective:** Verify adjacent slots don't trigger overlap

**Steps:**
1. Create Class A:
   - Slot 1: 2025-02-10, 09:00 AM - 10:00 AM
2. Create Class B (same instructor):
   - Slot 1: 2025-02-10, 10:00 AM - 11:00 AM (ADJACENT, NO OVERLAP)
3. Submit Class B

**Expected Results:**
- ✅ Class B created successfully
- ✅ No conflict detected

---

### TC-035: Overlap Detection with Busy Slots
**Objective:** Verify conflict with availability/busy slots

**Steps:**
1. Instructor has busy slot:
   - 2025-02-10, 09:00 AM - 10:00 AM
2. Create count-based class:
   - Slot 1: 2025-02-10, 09:30 AM - 10:30 AM (OVERLAPS)
3. Submit form

**Expected Results:**
- ❌ Validation error: "Time slot conflicts with your availability"
- ❌ OR warning shown (if conflicts allowed)
- ❌ Form submission blocked (if conflicts not allowed)

---

## 7. BULK OPERATIONS TEST CASES

### TC-036: Create Multiple Slots with Same Time Pattern
**Objective:** Verify bulk slot creation

**Steps:**
1. Select "Count-based" class type
2. Set `classCount` = 5
3. Add 5 slots, all with:
   - Start Time: 09:00 AM
   - End Time: 10:00 AM
   - Dates: 5 consecutive days
4. Submit form

**Expected Results:**
- ✅ All 5 slots created successfully
- ✅ All slots have same time pattern
- ✅ Dates correctly assigned
- ✅ No performance issues

---

### TC-037: Edit Multiple Slots Simultaneously
**Objective:** Verify bulk edit functionality

**Steps:**
1. Open existing count-based class with 5 slots
2. Select all slots
3. Change time for all: 09:00 AM → 11:00 AM
4. Save changes

**Expected Results:**
- ✅ All slots updated successfully
- ✅ All Google Calendar events updated
- ✅ No partial updates

---

### TC-038: Delete Multiple Slots
**Objective:** Verify bulk delete functionality

**Steps:**
1. Open existing count-based class with 5 slots
2. Select slots 2, 3, 4
3. Delete selected slots
4. Save changes

**Expected Results:**
- ✅ Selected slots deleted
- ✅ `classCount` updated to 2
- ✅ Remaining slots preserved
- ✅ Google Calendar events deleted

---

## 8. VALIDATION EDGE CASES

### TC-039: Empty Date Field
**Objective:** Verify required field validation

**Steps:**
1. Select "Count-based" class type
2. Set `classCount` = 1
3. Leave date field empty
4. Set times: 09:00 AM - 10:00 AM
5. Submit form

**Expected Results:**
- ❌ Validation error: "Date is required"
- ❌ Form submission blocked

---

### TC-040: Empty Start Time Field
**Objective:** Verify required start time validation

**Steps:**
1. Select "Count-based" class type
2. Set `classCount` = 1
3. Set date: Future date
4. Leave start time empty
5. Set end time: 10:00 AM
6. Submit form

**Expected Results:**
- ❌ Validation error: "Start time is required"
- ❌ Form submission blocked

---

### TC-041: Empty End Time Field
**Objective:** Verify required end time validation

**Steps:**
1. Select "Count-based" class type
2. Set `classCount` = 1
3. Set date: Future date
4. Set start time: 09:00 AM
5. Leave end time empty
6. Submit form

**Expected Results:**
- ❌ Validation error: "End time is required"
- ❌ Form submission blocked

---

### TC-042: Invalid Time Format
**Objective:** Verify time format validation

**Steps:**
1. Select "Count-based" class type
2. Set `classCount` = 1
3. Set date: Future date
4. Manually enter invalid time: "25:00" or "abc"
5. Submit form

**Expected Results:**
- ❌ Validation error: "Invalid time format"
- ❌ Form submission blocked
- ❌ Time picker should prevent invalid input

---

### TC-043: classCount Mismatch (More Slots than Count)
**Objective:** Verify classCount validation

**Steps:**
1. Select "Count-based" class type
2. Set `classCount` = 2
3. Add 3 slots
4. Submit form

**Expected Results:**
- ⚠️ System auto-adjusts `classCount` to 3
- ✅ OR validation error: "Number of slots must match classCount"
- ✅ OR all 3 slots saved (if auto-adjust enabled)

---

### TC-044: classCount Mismatch (Fewer Slots than Count)
**Objective:** Verify minimum slot requirement

**Steps:**
1. Select "Count-based" class type
2. Set `classCount` = 5
3. Add only 2 slots
4. Submit form

**Expected Results:**
- ❌ Validation error: "All slots must be filled"
- ❌ OR system auto-adjusts `classCount` to 2
- ❌ Form submission blocked (if validation enforced)

---

## 9. UI/UX EDGE CASES

### TC-045: Calendar Date Selection
**Objective:** Verify calendar picker works correctly

**Steps:**
1. Select "Count-based" class type
2. Click date picker for Slot 1
3. Select date from calendar
4. Verify date is populated

**Expected Results:**
- ✅ Calendar opens correctly
- ✅ Past dates disabled
- ✅ Selected date populated in field
- ✅ Day name auto-populated (if applicable)

---

### TC-046: Time Picker Selection
**Objective:** Verify time picker works correctly

**Steps:**
1. Select "Count-based" class type
2. Click start time picker
3. Select 09:00 AM
4. Click end time picker
5. Select 10:00 AM

**Expected Results:**
- ✅ Time picker opens correctly
- ✅ 12-hour format displayed (AM/PM)
- ✅ Selected times populated
- ✅ End time options disabled if before start time

---

### TC-047: Auto-Increase classCount on Slot Addition
**Objective:** Verify automatic classCount adjustment

**Steps:**
1. Select "Count-based" class type
2. Set `classCount` = 2
3. Add Slot 1: Date + Time
4. Add Slot 2: Date + Time
5. Add Slot 3: Date + Time (exceeds classCount)

**Expected Results:**
- ✅ `classCount` auto-increases to 3
- ✅ New slot added successfully
- ✅ No validation errors

---

### TC-048: Slot Removal Updates classCount
**Objective:** Verify classCount decreases on slot removal

**Steps:**
1. Open existing count-based class with 3 slots
2. Delete Slot 2
3. Verify classCount

**Expected Results:**
- ✅ `classCount` auto-decreases to 2
- ✅ OR remains 3 (if manual adjustment required)

---

## 10. ERROR HANDLING TEST CASES

### TC-049: Network Error During Creation
**Objective:** Verify error handling on network failure

**Steps:**
1. Select "Count-based" class type
2. Fill in all required fields
3. Disconnect network
4. Submit form

**Expected Results:**
- ❌ Error message: "Network error. Please try again."
- ❌ Form data preserved (not lost)
- ❌ User can retry after reconnection

---

### TC-050: Server Error During Update
**Objective:** Verify error handling on server error

**Steps:**
1. Open existing count-based class
2. Edit slot
3. Simulate server error (500)
4. Save changes

**Expected Results:**
- ❌ Error message: "Server error. Please try again."
- ❌ Original slot data preserved
- ❌ Changes not saved

---

### TC-051: Concurrent Edit Conflict
**Objective:** Verify handling of concurrent edits

**Steps:**
1. User A opens count-based class
2. User B opens same class (different session)
3. User A edits Slot 1
4. User B edits Slot 1
5. User A saves
6. User B saves

**Expected Results:**
- ⚠️ Last save wins (if no version control)
- ✅ OR conflict detection and merge (if version control implemented)
- ✅ OR error: "Class was modified by another user"

---

## 11. GOOGLE CALENDAR INTEGRATION TEST CASES

### TC-052: Google Calendar Event Creation
**Objective:** Verify GCal events created for count-based slots

**Steps:**
1. Create count-based class (not continuous):
   - Slot 1: 2025-02-10, 09:00 AM - 10:00 AM
   - Slot 2: 2025-02-13, 09:00 AM - 10:00 AM
2. Submit form

**Expected Results:**
- ✅ 2 Google Calendar events created
- ✅ Events have correct start/end times
- ✅ Events have correct timezone
- ✅ `event_id` stored in DB for each slot

---

### TC-053: Google Calendar Event Update
**Objective:** Verify GCal events updated on slot edit

**Steps:**
1. Open existing count-based class
2. Edit Slot 1:
   - Change time: 09:00 AM → 11:00 AM
3. Save changes

**Expected Results:**
- ✅ Old Google Calendar event deleted
- ✅ New Google Calendar event created with new time
- ✅ `event_id` updated in DB

---

### TC-054: Google Calendar Event Deletion
**Objective:** Verify GCal events deleted on slot removal

**Steps:**
1. Open existing count-based class with 2 slots
2. Delete Slot 1
3. Save changes

**Expected Results:**
- ✅ Google Calendar event deleted
- ✅ `event_id` removed from DB
- ✅ Remaining slot's event preserved

---

### TC-055: Google Calendar API Failure
**Objective:** Verify handling of GCal API failures

**Steps:**
1. Create count-based class
2. Simulate Google Calendar API failure
3. Submit form

**Expected Results:**
- ⚠️ Class creation continues (if GCal is non-blocking)
- ⚠️ OR class creation fails with rollback (if GCal is blocking)
- ✅ Error logged appropriately
- ✅ User notified of issue

---

## 12. DATA PERSISTENCE TEST CASES

### TC-056: Form Data Persistence on Page Refresh
**Objective:** Verify form data is preserved

**Steps:**
1. Select "Count-based" class type
2. Fill in 2 slots with dates and times
3. Refresh page (F5)

**Expected Results:**
- ⚠️ Form data lost (expected for new class)
- ✅ OR form data preserved (if auto-save implemented)

---

### TC-057: Form Data Persistence on Navigation Away
**Objective:** Verify data handling on navigation

**Steps:**
1. Select "Count-based" class type
2. Fill in 2 slots
3. Navigate away from page
4. Return to page

**Expected Results:**
- ⚠️ Form data lost (expected)
- ✅ OR warning: "You have unsaved changes"
- ✅ OR auto-save implemented

---

## 13. PERFORMANCE TEST CASES

### TC-058: Large Number of Slots (100+)
**Objective:** Verify performance with many slots

**Steps:**
1. Select "Count-based" class type
2. Set `classCount` = 100
3. Add 100 slots with different dates
4. Submit form

**Expected Results:**
- ✅ All slots saved successfully
- ✅ Acceptable response time (< 10 seconds)
- ✅ No browser freezing
- ✅ No memory issues

---

### TC-059: Rapid Slot Addition/Removal
**Objective:** Verify UI responsiveness

**Steps:**
1. Select "Count-based" class type
2. Rapidly add 10 slots
3. Rapidly remove 5 slots
4. Rapidly add 3 more slots

**Expected Results:**
- ✅ UI remains responsive
- ✅ No lag or freezing
- ✅ All operations complete correctly

---

## 14. BOUNDARY CONDITIONS

### TC-060: Minimum classCount (1)
**Objective:** Verify minimum value handling

**Steps:**
1. Select "Count-based" class type
2. Set `classCount` = 1
3. Add 1 slot
4. Submit form

**Expected Results:**
- ✅ Class created successfully
- ✅ Single slot saved

---

### TC-061: Maximum classCount (System Limit)
**Objective:** Verify maximum value handling

**Steps:**
1. Select "Count-based" class type
2. Set `classCount` = 1000 (or system max)
3. Add maximum slots
4. Submit form

**Expected Results:**
- ✅ OR class created successfully (if limit allows)
- ❌ OR validation error: "Maximum classCount exceeded"

---

### TC-062: Same Date, Maximum Overlapping Slots
**Objective:** Verify system handles many slots on same date

**Steps:**
1. Select "Count-based" class type
2. Set `classCount` = 10
3. Add 10 slots, all on same date (2025-02-10):
   - Slot 1: 09:00 AM - 10:00 AM
   - Slot 2: 10:00 AM - 11:00 AM
   - Slot 3: 11:00 AM - 12:00 PM
   - ... (non-overlapping)
4. Submit form

**Expected Results:**
- ✅ All slots saved on same date
- ✅ No overlap validation errors
- ✅ All slots grouped correctly

---

## 15. INTEGRATION TEST CASES

### TC-063: Count-Based Class with Online Mode
**Objective:** Verify online class handling

**Steps:**
1. Create count-based class
2. Set `is_online` = true
3. Add 2 slots: 2025-02-10, 09:00 AM - 10:00 AM
4. Submit form

**Expected Results:**
- ✅ Class created successfully
- ✅ `is_online` flag set correctly
- ✅ Google Meet link generated (if applicable)
- ✅ Location field handled appropriately

---

### TC-064: Count-Based Class with In-Person Mode
**Objective:** Verify in-person class handling

**Steps:**
1. Create count-based class
2. Set `is_online` = false
3. Select location
4. Add 2 slots: 2025-02-10, 09:00 AM - 10:00 AM
5. Submit form

**Expected Results:**
- ✅ Class created successfully
- ✅ Location assigned correctly
- ✅ No Google Meet link generated

---

### TC-065: Count-Based Class Enrollment Impact
**Objective:** Verify enrollment works with count-based classes

**Steps:**
1. Create count-based class with 5 slots
2. Enroll students
3. Verify students see all 5 slots

**Expected Results:**
- ✅ Students can enroll
- ✅ All slots visible to enrolled students
- ✅ Enrollment data stored correctly

---

## 16. REGRESSION TEST CASES

### TC-066: Edit Slot After Student Enrollment
**Objective:** Verify slot editing after enrollment

**Steps:**
1. Create count-based class with 2 slots
2. Enroll 3 students
3. Edit Slot 1:
   - Change time: 09:00 AM → 11:00 AM
4. Save changes

**Expected Results:**
- ✅ Slot updated successfully
- ✅ Enrolled students notified (if notifications enabled)
- ✅ Enrollment data preserved
- ✅ Google Calendar events updated for all attendees

---

### TC-067: Delete Slot After Student Enrollment
**Objective:** Verify slot deletion after enrollment

**Steps:**
1. Create count-based class with 3 slots
2. Enroll 5 students
3. Delete Slot 2
4. Save changes

**Expected Results:**
- ✅ Slot deleted successfully
- ✅ Enrolled students notified (if notifications enabled)
- ✅ Enrollment data updated (students removed from deleted slot)
- ✅ Google Calendar events deleted for all attendees

---

## TEST EXECUTION CHECKLIST

### Pre-Test Setup
- [ ] Test environment configured
- [ ] Test user accounts created (Instructor)
- [ ] Test activities created
- [ ] Test locations created
- [ ] Google Calendar API configured
- [ ] System timezone noted

### Test Execution
- [ ] Execute all test cases in sequence
- [ ] Document actual results vs expected results
- [ ] Capture screenshots for failures
- [ ] Log all errors and warnings
- [ ] Verify database state after each test

### Post-Test Verification
- [ ] All test cases executed
- [ ] All failures documented
- [ ] Database state verified
- [ ] Google Calendar events verified
- [ ] Test report generated

---

## TEST DATA TEMPLATES

### Template 1: Basic 2-Slot Class
```json
{
  "classType": "CountBased",
  "classCount": 2,
  "schedules": [
    {
      "day": "2025-02-10",
      "slots": [{
        "start": { "dateTime": "2025-02-10T03:30:00.000Z", "timeZone": "Asia/Kolkata" },
        "end": { "dateTime": "2025-02-10T04:30:00.000Z", "timeZone": "Asia/Kolkata" }
      }]
    },
    {
      "day": "2025-02-13",
      "slots": [{
        "start": { "dateTime": "2025-02-13T03:30:00.000Z", "timeZone": "Asia/Kolkata" },
        "end": { "dateTime": "2025-02-13T04:30:00.000Z", "timeZone": "Asia/Kolkata" }
      }]
    }
  ]
}
```

### Template 2: Cross-Day Slot
```json
{
  "classType": "CountBased",
  "classCount": 1,
  "schedules": [
    {
      "day": "2025-02-10",
      "slots": [{
        "start": { "dateTime": "2025-02-10T17:30:00.000Z", "timeZone": "Asia/Kolkata" },
        "end": { "dateTime": "2025-02-11T19:30:00.000Z", "timeZone": "Asia/Kolkata" },
        "isCrossDay": true
      }]
    }
  ]
}
```

---

## NOTES

1. **Timezone Considerations:**
   - All times should be tested in multiple timezones
   - Verify UTC conversion is correct
   - Verify timezone field is preserved

2. **Date Format:**
   - Dates stored as strings: "YYYY-MM-DD"
   - dateTime stored as ISO 8601 UTC strings

3. **Validation Rules:**
   - Past dates/times: Rejected
   - Overlapping slots: Rejected (same date)
   - End before start: Rejected
   - Empty required fields: Rejected

4. **Google Calendar:**
   - Events created for non-continuous classes
   - Events use local time + timezone (not UTC)
   - Events deleted when slots removed

5. **Edge Cases to Watch:**
   - DST transitions
   - Leap years
   - Timezone changes
   - Concurrent edits
   - Network failures

---

**End of Test Cases Document**

