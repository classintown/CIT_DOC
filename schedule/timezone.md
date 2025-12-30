# Timezone Correctness Audit Report
**Date:** 2025-01-27  
**Scope:** Frontend + Backend timezone handling for scheduling (create/edit/update/delete), availability checks, and DB storage

---

## Executive Summary

This audit examines timezone handling across the MEAN-stack application, focusing on:
- Frontend: `instructor-schedule-class.component.ts` and related services
- Backend: Availability/busy-slots endpoints + instructClass create/update/delete flows
- DB schema/storage format for schedules.start/end and timezone fields

**Key Findings:**
- ✅ Frontend uses system timezone detection (`momentTimezone.tz.guess()`) with UTC fallback
- ✅ Backend normalizes timezones (Asia/Calcutta → Asia/Kolkata) and converts to UTC for storage
- ⚠️ **RISK:** Frontend sends ISO strings with 'Z' suffix (already UTC) but also sends timeZone field - potential double conversion risk
- ⚠️ **RISK:** Inconsistent timezone defaults: Some endpoints default to 'Asia/Kolkata', others to 'Asia/Calcutta', some to 'UTC'
- ⚠️ **RISK:** Google Calendar integration uses local timezone correctly, but some legacy endpoints use hardcoded 'UTC'
- ✅ DB storage correctly stores UTC dateTime + separate timeZone field

---

## A) Where Timezone is Sourced and Used

### Frontend

| File Path | Function/Method | Current Behavior | Possible Risk |
|-----------|----------------|------------------|---------------|
| `frontend/src/app/components/instructor/instructor-class-management/instructor-schedule-class/instructor-schedule-class.component.ts` | `getUserTimezone()` (line 5598) | Uses `momentTimezone.tz.guess()` to detect system timezone. Falls back to 'UTC' if detection fails. | ✅ **LOW RISK:** Proper fallback mechanism. However, relies on browser/system timezone which may not match user's intended timezone (e.g., user traveling). |
| `instructor-schedule-class.component.ts` | `buildSchedulesFromForm()` (line ~1770) | Gets timezone via `getUserTimezone()`, creates moment with timezone: `momentTimezone.tz(\`${date} ${time}\`, 'YYYY-MM-DD hh:mm A', tz)`, then calls `.toISOString()` which converts to UTC. Sends both UTC ISO string AND original timezone in request. | ⚠️ **MEDIUM RISK:** Frontend sends `dateTime` as ISO string with 'Z' (UTC) but also sends `timeZone` field. Backend's `unifyToUTC()` will detect the 'Z' and parse as UTC, potentially ignoring the timeZone field. This could cause issues if frontend timezone detection is wrong. |
| `instructor-schedule-class.component.ts` | `buildSchedulesFromForm()` (edit mode, line ~1880) | Same pattern: Gets timezone, creates moment with timezone, converts to ISO, sends both UTC ISO + timeZone. | Same risk as above. |
| `instructor-schedule-class.component.ts` | `fetchBusySlotsIfNeeded()` (line 4587) | Calls `availabilityService.getBusySlots(date, date, timeZone)` where timeZone comes from `getUserTimezone()`. | ✅ **LOW RISK:** Timezone is consistently passed to availability service. |
| `frontend/src/app/services/core/availability/availability.service.ts` | `getBusySlots()` (line 33) | Defaults to `Intl.DateTimeFormat().resolvedOptions().timeZone` if timeZone not provided. Passes timezone as query param to backend. | ✅ **LOW RISK:** Uses browser API as fallback, consistent with component. |
| `availability.service.ts` | `checkAvailability()` (line 18) | Same pattern: Uses `Intl.DateTimeFormat().resolvedOptions().timeZone` as default. | ✅ **LOW RISK:** Consistent with other methods. |
| `availability.service.ts` | `getFreeSlots()` (line 51) | Same pattern: Uses `Intl.DateTimeFormat().resolvedOptions().timeZone` as default. | ✅ **LOW RISK:** Consistent. |

**Frontend Summary:**
- Timezone source: System timezone via `momentTimezone.tz.guess()` or `Intl.DateTimeFormat().resolvedOptions().timeZone`
- **NO hardcoded "Asia/Calcutta" or "Asia/Kolkata" in frontend** ✅
- **NO reading from user profile/institute/settings** ⚠️ (Potential enhancement: Should read from user preferences)
- When calling backend: Always passes timezone as query param or in request body
- **CRITICAL ISSUE:** Frontend sends `dateTime` as ISO string with 'Z' (already UTC) but also sends `timeZone`. Backend may ignore timeZone if it detects 'Z'.

### Backend - Availability Endpoints

| File Path | Function/Method | Current Behavior | Possible Risk |
|-----------|----------------|------------------|---------------|
| `backend/controllers/availability/availability.controller.js` | `validateAndNormalizeTimezone()` (line 33) | Normalizes timezone strings: 'Asia/Calcutta' → 'Asia/Kolkata', 'IST' → 'Asia/Kolkata', etc. Defaults to 'Asia/Kolkata' if missing or invalid. | ⚠️ **MEDIUM RISK:** Always defaults to 'Asia/Kolkata' even if user is in different timezone. Should use user's profile timezone or system timezone as fallback. |
| `availability.controller.js` | `getBusySlots()` (line 141) | Extracts `timeZone` from query params, normalizes it via `validateAndNormalizeTimezone()`. Uses normalized timezone for all processing. Response includes `timeZone: userTimeZone` (normalized). | ✅ **LOW RISK:** Correctly uses provided timezone. However, normalization means response may return "Asia/Kolkata" even if request was "Asia/Calcutta" - this is intentional and correct. |
| `availability.controller.js` | `getFreeSlots()` (line 194) | Defaults to 'Asia/Calcutta' if timeZone not provided (line 211), then normalizes. | ⚠️ **MEDIUM RISK:** Hardcoded default 'Asia/Calcutta' should match `getBusySlots` default ('Asia/Kolkata' after normalization). Inconsistency. |
| `availability.controller.js` | `getUserBusySlotsFixed()` (line 1156) | Retrieves schedules from DB (stored in UTC), converts UTC → userTimeZone for date grouping. Groups slots by date in user's timezone. | ✅ **LOW RISK:** Correctly converts stored UTC to requested timezone before grouping by date. |
| `availability.controller.js` | `formatBusySlotsFixed()` (line 1569) | Converts UTC dateTimes to userTimeZone, extracts date in user timezone for grouping: `const dateInUserTZ = startDT.toFormat('yyyy-MM-dd')`. | ✅ **LOW RISK:** Correctly groups by date in requested timezone, not server timezone. |
| `availability.controller.js` | `processScheduleSlotsV2()` (line 2034) | Reads `slot.start.dateTime` (UTC from DB), parses as UTC, converts to `userTimeZone` for filtering. Preserves `originalTimeZone` from slot. | ✅ **LOW RISK:** Proper UTC → user timezone conversion. |

**Backend Availability Summary:**
- Timezone parameter: Extracted from query params, normalized, defaults to 'Asia/Kolkata' if missing
- **Does NOT default to server timezone** ✅
- **Does NOT ignore provided timezone** ✅ (after normalization)
- Date grouping: Converts stored UTC → requested timezone BEFORE grouping by date ✅
- Response timezone: Returns normalized timezone (e.g., "Asia/Kolkata" even if request was "Asia/Calcutta") - this is correct behavior

### Backend - InstructClass Create/Update/Delete

| File Path | Function/Method | Current Behavior | Possible Risk |
|-----------|----------------|------------------|---------------|
| `backend/controllers/instructor/instructor_class.controller.js` | `addNewClass()` - Schedule processing (line 1171) | For each slot: Calls `unifyToUTC(slot.start.dateTime, slot.start.timeZone)` to convert local → UTC. Stores UTC in `dateTime` field, preserves original `timeZone` in separate field. | ⚠️ **MEDIUM RISK:** `unifyToUTC()` checks if dateTime already has 'Z' or offset. If frontend sends ISO with 'Z', it will parse as UTC and ignore the timeZone parameter. This could cause incorrect storage if frontend timezone detection was wrong. |
| `instructor_class.controller.js` | `addNewClass()` - GCal event creation (line 1233) | Uses frontend's local `dateTime` and `timeZone` directly for Google Calendar API (not UTC). This is correct - GCal needs local time + timezone. | ✅ **LOW RISK:** Correctly passes local time + timezone to Google Calendar. |
| `instructor_class.controller.js` | `updateClassById()` - Schedule processing (line ~3104) | Same pattern as create: Uses `unifyToUTC()` to convert to UTC, stores UTC + preserves timeZone. | Same risk as create. |
| `instructor_class.controller.js` | `updateClassById()` - GCal event update (line ~3545) | Uses `unifyToUTC()` for Calendar_Event doc storage, but passes local time + timezone to Google Calendar API. | ✅ **LOW RISK:** Correct handling. |
| `instructor_class.controller.js` | `deleteGoogleCalendarEvents()` (line 4329) | Deletes GCal events by event_id. No timezone conversion needed (just deletion). | ✅ **LOW RISK:** No timezone issues. |
| `backend/shared/dateTime/timeZoneHelpers.js` | `unifyToUTC()` (line 117) | If dateTimeStr has 'Z' or offset, parses as UTC/offset directly. Otherwise, parses as local time in provided timeZone, then converts to UTC. | ⚠️ **MEDIUM RISK:** If frontend sends ISO with 'Z' (UTC), this function will ignore the timeZone parameter. Frontend should send local time WITHOUT 'Z', or backend should trust timeZone field even if 'Z' is present. |
| `timeZoneHelpers.js` | `convertToUserTimeZone()` (line 143) | Converts UTC ISO string to user's timezone. Used for display purposes. | ✅ **LOW RISK:** Correct implementation. |

**Backend Create/Update/Delete Summary:**
- Storage: Converts local time → UTC using `unifyToUTC()`, stores UTC in `dateTime`, preserves `timeZone` separately ✅
- TimeZone persistence: Stored exactly as passed (after normalization in availability endpoints) ✅
- Google Calendar: Uses local time + timezone (correct) ✅
- **CRITICAL ISSUE:** `unifyToUTC()` may ignore `timeZone` parameter if `dateTime` already has 'Z' suffix. Frontend sends ISO with 'Z', so timeZone field may be ignored.

### Backend - Google Calendar Integration

| File Path | Function/Method | Current Behavior | Possible Risk |
|-----------|----------------|------------------|---------------|
| `backend/services/calendar/googleCalendarService.js` | `createEventOnCalendar()` (line 1434) | Ensures timezone is set, defaults to `DEFAULT_TIMEZONE` if not provided. Uses `eventData.start.timeZone` and `eventData.end.timeZone` directly. | ⚠️ **LOW-MEDIUM RISK:** Depends on what `DEFAULT_TIMEZONE` is. Should verify it's not hardcoded to 'Asia/Calcutta' or 'Asia/Kolkata'. |
| `backend/controllers/calendar/calendar.controller.js` | `scheduleEvent()` (line 112) | Defaults to `TimeZones.India` (likely 'Asia/Kolkata') if timeZone not provided (line 168, 172). | ⚠️ **MEDIUM RISK:** Hardcoded default to India timezone. Should use user's timezone or system timezone. |
| `calendar.controller.js` | `createInstructorCalendarEvent()` (line 1377) | **HARDCODED to 'UTC'** for both start and end timeZone (line 1421, 1425). | ⚠️ **HIGH RISK:** This endpoint hardcodes timezone to UTC, which is incorrect for Google Calendar events. Should use the timezone from the event data. |
| `calendar.controller.js` | `updateCalendarFromInstructor()` (line 1559) | Also **HARDCODED to 'UTC'** (line 1651, 1655). | ⚠️ **HIGH RISK:** Same issue as above. |

**Google Calendar Summary:**
- Main instructClass flow: Correctly passes local time + timezone ✅
- Legacy calendar endpoints: Some hardcode to 'UTC', some default to 'Asia/Kolkata' ⚠️
- **RISK:** Inconsistent timezone handling in legacy calendar endpoints

---

## B) DB Storage Assessment

### Schema Definition

**File:** `backend/models/instructor/instructor_class.model.js`

```javascript
start: {
  dateTime: {
    type: String,
    required: true
  },
  timeZone: {
    type: String,
    enum: Object.values(TimeZones),
    required: true
  }
},
end: {
  dateTime: {
    type: String,
    required: true
  },
  timeZone: {
    type: String,
    enum: Object.values(TimeZones),
    required: true
  }
}
```

### What is Stored

| Field | Format | Example | Correct? |
|-------|--------|---------|----------|
| `schedules[].slots[].start.dateTime` | ISO 8601 UTC string (with 'Z' suffix) | `"2025-06-10T03:30:00.000Z"` | ✅ **YES** - Stored as UTC |
| `schedules[].slots[].start.timeZone` | IANA timezone string | `"Asia/Kolkata"` or `"Asia/Calcutta"` | ⚠️ **MOSTLY** - Stored as provided, but may contain both "Asia/Calcutta" and "Asia/Kolkata" due to normalization inconsistencies |
| `schedules[].slots[].end.dateTime` | ISO 8601 UTC string (with 'Z' suffix) | `"2025-06-10T04:30:00.000Z"` | ✅ **YES** - Stored as UTC |
| `schedules[].slots[].end.timeZone` | IANA timezone string | `"Asia/Kolkata"` or `"Asia/Calcutta"` | ⚠️ **MOSTLY** - Same as start.timeZone |

### Storage Correctness Analysis

**✅ CORRECT:**
- All `dateTime` fields are stored in UTC (ISO strings with 'Z' suffix)
- `timeZone` fields are stored separately (not embedded in dateTime)
- Schema enforces timeZone via enum validation

**⚠️ POTENTIAL ISSUES:**
1. **Mixed timezone strings in DB:** Due to normalization happening only in availability endpoints (not in create/update), the DB may contain both "Asia/Calcutta" and "Asia/Kolkata" for the same timezone. This is functionally equivalent but inconsistent.
2. **No validation that dateTime is actually UTC:** The schema doesn't enforce that `dateTime` must end with 'Z'. If a bug introduces a non-UTC string, it won't be caught at the schema level.
3. **timeZone field may not match actual dateTime timezone:** If `unifyToUTC()` ignores the timeZone parameter (due to 'Z' detection), the stored timeZone may not reflect the actual timezone used for conversion.

### Consistency Check

- **Are all dateTimes UTC?** ✅ Yes, backend converts to UTC before storage
- **Are timeZones stored separately?** ✅ Yes, in separate fields
- **Is there a mix of "Asia/Calcutta" vs "Asia/Kolkata"?** ⚠️ Possibly - normalization only happens in availability endpoints, not in create/update flows
- **Are there null/undefined timezone values?** ✅ No - schema requires timeZone field

---

## C) Timezone Correctness Assertions

### Rules That Must Always Hold

1. **✅ ASSERTION: All stored dateTimes must be UTC and timezone stored separately**
   - **Status:** ✅ **HELD** - Backend converts to UTC via `unifyToUTC()` before storage
   - **Risk:** ⚠️ Frontend sends ISO with 'Z', which may cause `unifyToUTC()` to ignore timeZone parameter

2. **✅ ASSERTION: busy-slots must group by requested timezone date, not server timezone**
   - **Status:** ✅ **HELD** - `formatBusySlotsFixed()` converts UTC → userTimeZone before extracting date for grouping
   - **Code Evidence:** `const dateInUserTZ = startDT.toFormat('yyyy-MM-dd')` (line 1602 in availability.controller.js)

3. **✅ ASSERTION: create/edit/update/delete must not introduce date rollover bugs**
   - **Status:** ⚠️ **PARTIALLY HELD** - Frontend handles cross-day slots correctly, but backend's `unifyToUTC()` behavior with 'Z' suffix could cause issues
   - **Risk:** If frontend sends UTC ISO but timezone is wrong, backend may store incorrect UTC time

4. **✅ ASSERTION: Timezone normalization must be consistent across all endpoints**
   - **Status:** ⚠️ **NOT HELD** - Normalization happens in availability endpoints but not in create/update flows
   - **Evidence:** `validateAndNormalizeTimezone()` only used in availability.controller.js, not in instructor_class.controller.js

5. **✅ ASSERTION: Google Calendar events must use local time + timezone, not UTC**
   - **Status:** ✅ **HELD** (main flow) / ⚠️ **NOT HELD** (legacy endpoints)
   - **Main flow:** Correctly passes local time + timezone
   - **Legacy endpoints:** `createInstructorCalendarEvent()` hardcodes 'UTC'

6. **✅ ASSERTION: Frontend must send local time (without 'Z') OR backend must trust timeZone field even if 'Z' is present**
   - **Status:** ❌ **NOT HELD** - Frontend sends ISO with 'Z' (UTC), backend's `unifyToUTC()` may ignore timeZone parameter
   - **Risk:** High - Could cause incorrect time storage if frontend timezone detection is wrong

7. **✅ ASSERTION: Default timezone must be consistent across all endpoints**
   - **Status:** ⚠️ **NOT HELD** - Some default to 'Asia/Kolkata', some to 'Asia/Calcutta', some to 'UTC'
   - **Evidence:**
     - `getBusySlots()`: Defaults to 'Asia/Kolkata' (after normalization)
     - `getFreeSlots()`: Defaults to 'Asia/Calcutta' (before normalization)
     - `createInstructorCalendarEvent()`: Defaults to 'UTC'

8. **✅ ASSERTION: User's timezone preference should be read from profile/settings if available**
   - **Status:** ❌ **NOT IMPLEMENTED** - Frontend always uses system timezone, backend always uses request parameter or default
   - **Risk:** Medium - Users traveling or using VPN may see incorrect times

---

## D) Risk Summary

### 🔴 **HIGH RISK**
1. **Frontend sends UTC ISO with 'Z' but also sends timeZone field**
   - **Impact:** Backend's `unifyToUTC()` may ignore timeZone parameter, causing incorrect storage
   - **Location:** Frontend sends `dateTime: startMoment.toISOString()` (UTC) + `timeZone: tz` (local)
   - **Fix Required:** Either frontend sends local time without 'Z', or backend trusts timeZone field even if 'Z' is present

2. **Legacy calendar endpoints hardcode timezone to 'UTC'**
   - **Impact:** Google Calendar events created via legacy endpoints will show incorrect times
   - **Location:** `createInstructorCalendarEvent()`, `updateCalendarFromInstructor()`
   - **Fix Required:** Use timezone from event data, not hardcoded 'UTC'

### 🟡 **MEDIUM RISK**
1. **Inconsistent timezone defaults across endpoints**
   - **Impact:** Different endpoints may behave differently when timezone is missing
   - **Location:** Various endpoints default to 'Asia/Kolkata', 'Asia/Calcutta', or 'UTC'
   - **Fix Required:** Standardize default timezone (preferably from user profile or system)

2. **Timezone normalization only in availability endpoints**
   - **Impact:** DB may contain both "Asia/Calcutta" and "Asia/Kolkata" for same timezone
   - **Location:** `validateAndNormalizeTimezone()` only used in availability.controller.js
   - **Fix Required:** Apply normalization in create/update flows as well

3. **No user timezone preference support**
   - **Impact:** Users cannot override system-detected timezone
   - **Location:** Frontend always uses `momentTimezone.tz.guess()`
   - **Fix Required:** Read timezone from user profile/settings if available

### 🟢 **LOW RISK**
1. **System timezone detection fallback**
   - **Impact:** If detection fails, falls back to UTC (safe but may not match user's intent)
   - **Location:** `getUserTimezone()` in frontend component
   - **Fix Required:** Consider user profile timezone as fallback before UTC

---

## E) Recommendations (For Future Reference - Not Implemented)

1. **Frontend:** Send local time WITHOUT 'Z' suffix, or ensure backend trusts timeZone field even if 'Z' is present
2. **Backend:** Apply timezone normalization in create/update flows, not just availability endpoints
3. **Backend:** Standardize default timezone across all endpoints (use user profile or system timezone)
4. **Backend:** Fix legacy calendar endpoints to use timezone from event data, not hardcoded 'UTC'
5. **Frontend/Backend:** Implement user timezone preference support (read from user profile/settings)
6. **DB:** Consider adding validation to ensure dateTime always ends with 'Z' (UTC indicator)

---

## F) Code References

### Key Files
- Frontend Component: `frontend/src/app/components/instructor/instructor-class-management/instructor-schedule-class/instructor-schedule-class.component.ts`
- Frontend Service: `frontend/src/app/services/core/availability/availability.service.ts`
- Backend Controller (InstructClass): `backend/controllers/instructor/instructor_class.controller.js`
- Backend Controller (Availability): `backend/controllers/availability/availability.controller.js`
- Timezone Helpers: `backend/shared/dateTime/timeZoneHelpers.js`
- Schema: `backend/models/instructor/instructor_class.model.js`

### Key Functions
- `getUserTimezone()` - Frontend timezone detection
- `unifyToUTC()` - Backend local → UTC conversion
- `convertToUserTimeZone()` - Backend UTC → local conversion
- `validateAndNormalizeTimezone()` - Backend timezone normalization
- `getUserBusySlotsFixed()` - Backend busy slots retrieval
- `formatBusySlotsFixed()` - Backend busy slots formatting

---

**End of Report**

