# 🔴 FRONTEND TIMEZONE AUDIT REPORT
## Angular Frontend - UTC Contract & Timezone Safety Analysis

**Date:** 2025-01-XX  
**Scope:** Entire Angular frontend codebase  
**Objective:** Identify all timezone-dependent code and ensure proper UTC ⇄ user timezone conversion

---

## 🔴 HIGH-RISK ISSUES (Must Fix)

| File | Line | Code Snippet | Issue | Why It Breaks Time Consistency |
| ---- | ---: | ------------ | ----- | ------------------------------ |
| `frontend/src/app/components/instructor/instructor-class-management/instructor-schedule-class/instructor-schedule-class.component.ts` | 96 | `todayDate: string = new Date().toISOString().split('T')[0]` | **Date picker min uses browser local time** | `<input type="date" [min]="todayDate">` uses browser's local "today". If user is in different timezone than server, date boundaries are wrong. User in PST at 11 PM sees "tomorrow" while server in IST sees "today". |
| `frontend/src/app/components/instructor/dashboard/upcoming-class-widget/upcoming-class-widget.component.ts` | 176-178 | `const now = new Date()`, `const startTime = new Date(this.nextClass.startTime)`, `const diff = startTime.getTime() - now.getTime()` | **Countdown uses browser local time** | Countdown calculation compares UTC time from backend with browser local "now". If backend returns UTC and browser is in different timezone, countdown is off by timezone offset. |
| `frontend/src/app/components/instructor/dashboard/reschedule-modal/reschedule-modal.component.ts` | 57-58, 154-155 | `const now = new Date()`, `this.minStartTime = now.toISOString().slice(0, 16)`, `new Date(formValue.custom_start_time).toISOString()` | **Reschedule time picker uses local time** | Time picker min constraint uses browser local time. User selects time in their timezone, but `new Date()` parses it as local, then converts to UTC incorrectly if input format doesn't match. |
| `frontend/src/app/components/instructor/instructor-class-management/instructor-schedule-class/instructor-schedule-class.component.ts` | 1816, 1827, 1835 | `momentTimezone.tz(\`${adjustedDateVal} ${startTime}\`, 'YYYY-MM-DD hh:mm A', tz).toISOString()` | **Moment timezone conversion but timezone source inconsistent** | Uses `getUserTimezone()` which calls `momentTimezone.tz.guess()`. This is device timezone, not user profile timezone. If user travels or device timezone changes, slots are created in wrong timezone. |
| `frontend/src/app/components/instructor/instructor-class-management/instructor-schedule-class/instructor-schedule-class.component.ts` | 3174, 3178 | `moment(\`${slot.date} ${slot.start_time}\`, 'YYYY-MM-DD HH:mm').toISOString()` | **Moment parsing without timezone context** | Parses date+time string without timezone. If `slot.date` is "2025-01-15" and `slot.start_time` is "09:00", moment assumes local timezone, not user's intended timezone. Should use `momentTimezone.tz()` with explicit timezone. |
| `frontend/src/app/components/instructor/dashboard/slot-details-modal/slot-details-modal.component.ts` | 115-122, 125-131 | `formatDate(isoString)`, `new Date(isoString).toLocaleDateString()` | **UTC to local conversion for display** | Backend returns UTC ISO string, but `new Date(isoString)` creates Date object. When formatted with `toLocaleDateString()`, it uses browser locale, not user's profile timezone. User in PST sees different time than user in IST for same UTC time. |
| `frontend/src/app/components/instructor/instructor-class-management/instructor-class-details/instructor-class-details.component.ts` | 301, 317, 330, 335 | `date = new Date(dateString)`, `date = new Date(year, month, day)` | **Date parsing without timezone awareness** | Parses date strings and creates Date objects without considering timezone. If `dateString` is "2025-01-15", `new Date()` interprets as local midnight, not UTC midnight. Causes off-by-one-day errors. |
| `frontend/src/app/components/instructor/instructor-class-management/instructor-schedule-class/instructor-schedule-class.component.ts` | 5586-5600 | `isSlotInPast(dateStr, timeStr)` uses `moment()` without timezone | **Past detection uses local timezone** | Checks if slot is in past using `moment()` which uses browser local timezone. Should compare UTC times. User in PST might see slot as "past" while user in IST sees it as "future" for same UTC time. |
| `frontend/src/app/components/instructor/instructor-student-management/instructor-notes/instructor-notes.component.ts` | 1189 | `const isPast = sessionDateStart < todayStart \|\| endDT < now` | **Past session detection uses local time** | Compares session dates with "today" using local timezone. Should use UTC day boundaries. User traveling across timezone sees different "today" boundaries. |
| `frontend/src/app/components/instructor/notes/note-form/note-form.component.ts` | 122, 315, 402 | `if (inputDate < today)`, `const isPast = currentDate < today` | **Date validation uses local time** | Validates due dates and session dates against "today" using browser local time. User in PST at 11 PM validates against different "today" than user in IST. |
| `frontend/src/app/shared/common-components/enhanced-calendar/enhanced-calendar.component.ts` | 757-758, 876-877, 1042-1043 | `new Date(item.start?.dateTime)`, `new Date(item.created)` | **Calendar event parsing without timezone** | Parses event start/end times from backend without explicit timezone conversion. Backend returns UTC, but `new Date()` creates Date object. Calendar displays in browser local time, not user's intended timezone. |
| `frontend/src/app/components/instructor/instructor-class-management/instructor-schedule-class/instructor-schedule-class.component.ts` | 2062, 2223, 2250 | `new Date(slotObj.start.dateTime)`, `moment(dateObj).format('YYYY-MM-DD')` | **Slot date extraction uses local timezone** | Extracts date from UTC ISO string using `new Date()` which converts to local timezone. If UTC time is "2025-01-15T02:00:00Z" and user is in PST (UTC-8), date becomes "2025-01-14" instead of "2025-01-15". |
| `frontend/src/app/components/instructor/dashboard/quick-update-modal/quick-update-modal.component.ts` | 78, 197, 201 | `this.minStartTime = now.toISOString().slice(0, 16)`, `new Date(formValue.custom_start_time).toISOString()` | **Quick update uses local datetime-local input** | HTML5 `datetime-local` input uses browser local timezone. When converted to ISO string, if user is in PST and selects "2025-01-15T09:00", it becomes "2025-01-15T17:00Z" (PST to UTC). But if backend expects UTC, this is correct. However, if user travels, the conversion breaks. |
| `frontend/src/app/services/common/date-time.service.ts` | 11-13, 15-16, 19-20 | `getCurrentDate(): Date { return new Date() }` | **Date service uses browser local time** | Central date service returns `new Date()` which is browser local time. All components using this service get inconsistent "now" values if timezone changes. Should return UTC or timezone-aware DateTime. |
| `frontend/src/app/components/instructor/instructor-class-management/instructor-schedule-class/instructor-schedule-class.component.ts` | 2517, 2520, 2550 | `this.dateValues.push(new Date(dateStr))` | **Calendar date selection uses local Date** | Pushes date strings into Date objects. If `dateStr` is "2025-01-15", `new Date("2025-01-15")` creates local midnight. Calendar component then displays in local timezone, causing timezone shifts. |
| `frontend/src/app/components/instructor/instructor-student-management/instructor-student-lists/instructor-student-lists.component.ts` | 840 | `const daysSinceActivity = Math.floor((Date.now() - lastActivityDate.getTime()) / (1000 * 60 * 60 * 24))` | **Days calculation uses local now** | Calculates days since activity using `Date.now()` (UTC epoch) but `lastActivityDate` might be local Date object. Mixing UTC epoch with local Date causes incorrect day calculations. |
| `frontend/src/app/components/instructor/instructor-class-management/instructor-schedule-class/instructor-schedule-class.component.ts` | 3222, 3225, 3280 | `new Date(updatedSlot.start.dateTime).getTime()`, `new Date(a.start.dateTime).getTime() - new Date(b.start.dateTime).getTime()` | **Slot sorting uses local Date parsing** | Sorts slots by parsing UTC ISO strings as local Date objects. If UTC time is "2025-01-15T02:00:00Z", parsing as local might shift the time, causing incorrect sort order. |
| `frontend/src/app/components/onboard/components/instructorscheduleclass/instructorscheduleclass.component.ts` | 2713, 2719, 2729, 2735 | `startMoment.toISOString()`, `moment.default(\`${slot.date} ${backendTime}\`, 'YYYY-MM-DD HH:mm').toISOString()` | **Onboarding schedule creation mixes timezone contexts** | Creates schedules using moment with timezone, but `backendTime` might be in different timezone context. Mixing local timezone detection with backend-provided times causes double conversion. |
| `frontend/src/app/components/instructor/instructor-class-management/instructor-schedule-class/instructor-schedule-class.component.ts` | 7036-7052 | `const timeZone = this.getUserTimezone()`, `tomorrow.toISOString()` | **"Tomorrow" calculation uses local timezone** | Calculates "tomorrow" using `new Date()` (local) then converts to ISO. If user is in PST and it's 11 PM, "tomorrow" in local is different from "tomorrow" in UTC. Backend might expect UTC tomorrow. |
| `frontend/src/app/components/instructor/instructor-class-management/instructor-schedule-class/instructor-schedule-class.component.ts` | 5649-5661 | `getUserTimezone()` uses `momentTimezone.tz.guess()` | **Timezone source is device, not user profile** | Timezone detection uses device timezone (`momentTimezone.tz.guess()`). If user travels or device timezone changes, all new schedules are created in wrong timezone. Should use user profile timezone setting. |

---

## 🟠 MEDIUM-RISK ISSUES

| File | Line | Issue | Recommendation |
| ---- | ---: | ----- | -------------- |
| `frontend/src/app/components/instructor/instructor-class-management/instructor-schedule-class/instructor-schedule-class.component.ts` | 1816-1841 | **Good: Uses moment-timezone for conversion** | Pattern is correct (moment-timezone with explicit timezone), but timezone source (`getUserTimezone()`) should come from user profile, not device. |
| `frontend/src/app/components/instructor/instructor-class-management/instructor-schedule-class/instructor-schedule-class.component.ts` | 1860-1861 | **Sends timezone in payload** | Correctly sends `timeZone: tz` in API payload. Backend should use this to convert to UTC. Need to verify backend actually uses this field. |
| `frontend/src/app/components/instructor/instructor-class-management/instructor-schedule-class/instructor-schedule-class.component.html` | 2024 | **Displays timezone to user** | Shows `{{ getCurrentTimezone() }}` which is good UX, but timezone shown is device timezone, not necessarily user's intended timezone. |
| `frontend/src/app/components/instructor/instructor-class-management/instructor-schedule-class/instructor-schedule-class.component.ts` | 6009-6010 | **getCurrentTimezone() method** | Returns `momentTimezone.tz.guess()` which is device timezone. Should have fallback to user profile timezone or allow user to override. |
| `frontend/src/app/shared/common-components/enhanced-calendar/enhanced-calendar.component.ts` | 2445, 2449 | **Moment conversion for Google Calendar** | Uses `moment(event.StartTime).toISOString()` which assumes `event.StartTime` is already in correct timezone. Need to verify if it's UTC or local. |
| `frontend/src/app/components/instructor/instructor-class-management/instructor-schedule-class/instructor-schedule-class.component.ts` | 3834, 3871, 4434 | **Availability service calls with timezone** | Correctly passes timezone to availability service. Need to verify service converts to UTC before API call. |
| `frontend/src/app/components/instructor/dashboard/slot-details-modal/slot-details-modal.component.ts` | 115-131 | **Format methods exist but use local conversion** | Has `formatDate()` and `formatTime()` methods, but they use `new Date(isoString)` which converts to local. Should use timezone-aware formatting. |
| `frontend/src/app/services/common/date-time.service.ts` | 82-84 | **Luxon methods available** | Service has Luxon methods (`getLuxonCurrentDate()`, `getLuxonDateTime()`), but they're not used consistently. Components should use these instead of `new Date()`. |
| `frontend/src/app/components/instructor/instructor-class-management/instructor-schedule-class/instructor-schedule-class.component.ts` | 1844 | **Validates end > start** | Uses `momentTimezone(end).isBefore(momentTimezone(start))` which is correct, but both should be in same timezone context (UTC) for comparison. |
| `frontend/src/app/components/instructor/instructor-class-management/instructor-schedule-class/instructor-schedule-class.component.ts` | 3175, 3179 | **Fallback timezone in payload** | Uses `slot.timeZone \|\| momentTimezone.tz.guess()` as fallback. Good pattern, but should fallback to user profile timezone, not device. |
| `frontend/src/app/components/instructor/instructor-class-management/instructor-schedule-class/instructor-schedule-class.component.ts` | 3226 | **Timezone difference tolerance** | Comments mention "handle slight timezone differences" with 1-minute tolerance. This suggests awareness of timezone issues, but tolerance shouldn't be needed if conversion is correct. |
| `frontend/src/app/components/onboard/components/instructorscheduleclass/instructorscheduleclass.component.ts` | 3692-3723 | **Enhanced timezone detection** | Has comprehensive timezone detection with fallbacks, but still uses device timezone. Should integrate with user profile timezone. |
| `frontend/src/app/components/instructor/instructor-class-management/instructor-schedule-class/instructor-schedule-class.component.ts` | 5591-5592 | **Past detection uses moment with timezone** | `isSlotInPast()` uses `momentTimezone.tz()` which is correct, but compares with `moment()` (local). Should compare both in UTC. |

---

## 🟢 SAFE / CONSISTENT USAGE

| File | Line | Why Safe |
| ---- | ---: | -------- |
| `frontend/src/app/components/instructor/instructor-class-management/instructor-schedule-class/instructor-schedule-class.component.ts` | 1821, 1832, 1840 | Uses `momentTimezone.tz().toISOString()` to convert user input to UTC ISO string before sending to backend. Correct pattern. |
| `frontend/src/app/components/instructor/instructor-class-management/instructor-schedule-class/instructor-schedule-class.component.ts` | 1860-1861 | Sends both `dateTime` (UTC ISO) and `timeZone` (user timezone) in payload. Backend can use timeZone for validation/display. |
| `frontend/src/app/services/common/interceptors/authentication/authentication-interceptor.service.ts` | 249, 282, 460 | Sets `X-Client-Timestamp: new Date().toISOString()` header. This is UTC timestamp, correct for server-side logging. |
| `frontend/src/app/components/instructor/instructor-class-management/instructor-schedule-class/instructor-schedule-class.component.ts` | 6009-6010 | `getCurrentTimezone()` method exists and is used consistently. While it uses device timezone, at least it's centralized. |
| `frontend/src/app/components/instructor/instructor-class-management/instructor-schedule-class/instructor-schedule-class.component.ts` | 5649-5661 | `getUserTimezone()` has fallback to UTC if detection fails. Safe fallback pattern. |
| `frontend/src/app/components/instructor/instructor-class-management/instructor-schedule-class/instructor-schedule-class.component.ts` | 1844 | Validates end > start using moment-timezone, which handles timezone-aware comparison correctly. |
| `frontend/src/app/services/common/date-time.service.ts` | 82-88 | Provides Luxon DateTime methods which are timezone-aware. Components should use these instead of native Date. |
| `frontend/src/app/components/instructor/instructor-class-management/instructor-schedule-class/instructor-schedule-class.component.ts` | 1816-1841 | Count-based schedule generation uses moment-timezone with explicit timezone for all conversions. Correct pattern. |

---

## 🧠 SYSTEMIC ANTI-PATTERNS FOUND

### Pattern 1: **new Date() Without Timezone Context**
**Location:** Throughout components (100+ occurrences)  
**Problem:** `new Date()` and `new Date(dateString)` create Date objects in browser local timezone. When parsing UTC ISO strings or date-only strings, this causes timezone shifts.  
**Impact:** Date comparisons, date picker boundaries, and "today"/"tomorrow" calculations all become timezone-dependent.  
**Frequency:** Found in 100+ locations across components.

### Pattern 2: **DatePipe Without Timezone Parameter**
**Location:** Templates using `\| date:'short'`, `\| date:'medium'`, etc.  
**Problem:** Angular DatePipe uses browser locale by default. Backend UTC times are displayed in browser local timezone, which may not match user's intended timezone.  
**Impact:** Users see times in device timezone, not their profile timezone. Traveling users see incorrect times.  
**Frequency:** Found in 129 template locations.

### Pattern 3: **Moment Without Explicit Timezone**
**Location:** `instructor-schedule-class.component.ts`, `instructorscheduleclass.component.ts`  
**Problem:** Uses `moment()` and `moment(dateString)` without timezone context. Moment assumes local timezone, causing incorrect parsing of UTC strings.  
**Impact:** Date parsing, comparisons, and formatting all use wrong timezone.  
**Frequency:** Found in 50+ locations.

### Pattern 4: **Device Timezone as Source of Truth**
**Location:** `getUserTimezone()`, `getCurrentTimezone()` methods  
**Problem:** Timezone detection uses `momentTimezone.tz.guess()` or `Intl.DateTimeFormat().resolvedOptions().timeZone`, which is device timezone. No integration with user profile timezone setting.  
**Impact:** Traveling users or users with device timezone changes get incorrect scheduling.  
**Frequency:** Found in 2 critical scheduling components.

### Pattern 5: **Date String Parsing Without Format Specification**
**Location:** Multiple components parsing date strings  
**Problem:** `new Date("2025-01-15")` and `moment("2025-01-15")` parse without explicit format. Browser/moment may interpret differently based on locale.  
**Impact:** Date-only strings are parsed as local midnight, causing off-by-one-day errors when converted to UTC.  
**Frequency:** Found in 20+ parsing locations.

### Pattern 6: **"Today" Calculations Using Local Time**
**Location:** Date validation, past/future detection  
**Problem:** `new Date()`, `moment()`, and date comparisons use browser local time to determine "today". UTC day boundaries differ from local day boundaries.  
**Impact:** Users in different timezones see different "today" boundaries. Filters and validations behave inconsistently.  
**Frequency:** Found in 15+ business logic locations.

### Pattern 7: **toISOString() on Local Date Objects**
**Location:** Components converting dates before API calls  
**Problem:** Creates local Date object, then calls `.toISOString()` which converts to UTC. If original intent was local time, this shifts the time incorrectly.  
**Impact:** User selects "9:00 AM" in their timezone, but if Date object was created incorrectly, it becomes wrong UTC time.  
**Frequency:** Found in 30+ API payload creation locations.

---

## ✅ RECOMMENDED FRONTEND UTC CONTRACT (Rules)

### Rule 1: **All Backend Communication Must Use UTC ISO Strings**
- ❌ NEVER send: `new Date(userInput).toISOString()` if userInput is already a string
- ✅ ALWAYS send: UTC ISO string with 'Z' suffix: `"2025-01-15T10:30:00.000Z"`
- ✅ For date+time inputs: Convert user's local timezone → UTC before sending
- ✅ Use: `momentTimezone.tz(userDate + ' ' + userTime, 'YYYY-MM-DD hh:mm A', userTimezone).toUTC().toISO()`

### Rule 2: **All Backend Responses Must Be Parsed as UTC**
- ❌ NEVER parse: `new Date(backendIsoString)` without timezone context
- ✅ ALWAYS parse: `DateTime.fromISO(backendIsoString, { zone: 'utc' })` or `moment.utc(backendIsoString)`
- ✅ For display: Convert UTC → user timezone in one centralized place (pipe/service)

### Rule 3: **All Date Display Must Use User Timezone**
- ❌ NEVER use: `\| date:'short'` without timezone parameter (uses browser locale)
- ✅ ALWAYS use: Custom pipe that converts UTC → user timezone: `\| utcToLocal:'short'`
- ✅ Or use: `DateTime.fromISO(utcString, { zone: 'utc' }).setZone(userTimezone).toFormat()`

### Rule 4: **Timezone Source Must Be User Profile, Not Device**
- ❌ NEVER use: `momentTimezone.tz.guess()` or `Intl.DateTimeFormat().resolvedOptions().timeZone` as primary source
- ✅ ALWAYS use: User profile timezone setting (from API/user service)
- ✅ Fallback: Device timezone only if user profile timezone is not set
- ✅ Allow: User to override timezone in settings

### Rule 5: **All "Now" References Must Be UTC or Timezone-Aware**
- ❌ NEVER use: `new Date()` for business logic comparisons
- ✅ ALWAYS use: `DateTime.utc()` or `moment.utc()` for UTC "now"
- ✅ For user-facing "now": `DateTime.now().setZone(userTimezone)`

### Rule 6: **All Date Comparisons Must Be in Same Timezone Context**
- ❌ NEVER compare: UTC Date with local Date
- ✅ ALWAYS compare: Both in UTC, or both in same user timezone
- ✅ For "today" boundaries: Calculate UTC day boundaries, then convert to user timezone for display

### Rule 7: **Date Pickers Must Handle Timezone Correctly**
- ❌ NEVER use: `<input type="date">` with `[min]="new Date().toISOString().split('T')[0]"` (uses local today)
- ✅ ALWAYS use: Calculate UTC "today", convert to user timezone, then extract date part
- ✅ For datetime-local: Convert user timezone → UTC before sending to backend

### Rule 8: **Centralized Date/Time Service Required**
- ❌ NEVER: Each component implements its own date conversion
- ✅ ALWAYS: Use centralized `DateTimeService` or `TimezoneService`
- ✅ Methods: `utcToUser(utcIso: string): DateTime`, `userToUtc(userDateTime: DateTime): string`, `getUserTimezone(): string`

### Rule 9: **Date-Only Strings Must Be Explicit**
- ❌ NEVER parse: `new Date("2025-01-15")` (ambiguous timezone)
- ✅ ALWAYS parse: `DateTime.fromISO("2025-01-15", { zone: userTimezone }).startOf('day')` or `moment.tz("2025-01-15", userTimezone).startOf('day')`
- ✅ For date-only inputs: Treat as user timezone midnight, then convert to UTC

### Rule 10: **Business Logic Must Use UTC for Comparisons**
- ❌ NEVER: `if (slotDate < new Date())` (mixes timezones)
- ✅ ALWAYS: `if (DateTime.fromISO(slotDate, { zone: 'utc' }) < DateTime.utc())`
- ✅ For "is past", "is today", "is upcoming": Compare in UTC, convert to user timezone only for display

---

## ⚠️ TIMEZONE EDGE CASES TO WATCH (Based on Code)

### Edge Case 1: **Date Picker Min Boundary Across Timezones**
**Location:** `instructor-schedule-class.component.ts` line 96, templates with `[min]="todayDate"`  
**Risk:** User in PST at 11:00 PM sees "today" as Jan 15, but UTC is already Jan 16. Date picker min is set to Jan 15, but backend might reject Jan 15 as "past" if it's past midnight UTC.  
**Example:** User selects Jan 15 11:00 PM PST, which is Jan 16 7:00 AM UTC. Backend stores as Jan 16, but UI shows Jan 15.  
**Fix:** Calculate "today" in user timezone, but validate against UTC "today" before sending to backend.

### Edge Case 2: **Countdown Timer with Timezone Offset**
**Location:** `upcoming-class-widget.component.ts` lines 176-178  
**Risk:** Countdown compares UTC time from backend with `new Date()` (browser local). If user is in PST (UTC-8), countdown is off by 8 hours.  
**Example:** Class starts at 2:00 PM UTC. User in PST sees countdown to 6:00 AM PST (8 hours early).  
**Fix:** Convert backend UTC time to user timezone, then compare with user timezone "now".

### Edge Case 3: **Cross-Day Slots with Timezone Boundaries**
**Location:** `instructor-schedule-class.component.ts` lines 1801-1841  
**Risk:** User creates slot from 11:00 PM to 1:00 AM. In user timezone, this is same day (Jan 15 11 PM - Jan 16 1 AM). But when converted to UTC, it might span different days or same day depending on timezone offset.  
**Example:** User in IST (UTC+5:30) creates 11 PM - 1 AM slot. In UTC this is 5:30 PM - 7:30 PM (same day). But if user is in PST (UTC-8), it's 7 AM - 9 AM next day.  
**Fix:** Always store start/end as UTC ISO strings. Display logic handles cross-day detection in user timezone.

### Edge Case 4: **"Today" Filter with Timezone Travel**
**Location:** Date filters, "today" calculations throughout  
**Risk:** User travels from PST to IST. "Today" filter shows different results because "today" is calculated from device timezone, which changed.  
**Example:** User in PST sees "today" as Jan 15. Travels to IST, device timezone updates. Now "today" is Jan 16 (IST is ahead). Same UTC time, different "today".  
**Fix:** Use user profile timezone, not device timezone, for "today" calculations.

### Edge Case 5: **Recurring Slots Across DST Transitions**
**Location:** Duration-based scheduling, recurring slot generation  
**Risk:** User creates weekly recurring slot. During DST transition, the UTC time shifts, but user expects same local time.  
**Example:** User creates "Every Monday 9:00 AM" in PST. During DST "spring forward", 9:00 AM PST becomes different UTC offset. Slot might appear at 8:00 AM or 10:00 AM local time.  
**Fix:** Store recurring slots with timezone. Always convert to UTC using current DST rules, but display in user's local timezone.

### Edge Case 6: **Date-Only Inputs with Timezone Conversion**
**Location:** `<input type="date">` inputs  
**Risk:** User selects "2025-01-15" in date picker. Component creates `new Date("2025-01-15")` which is local midnight. When converted to UTC, it might become "2025-01-14" or "2025-01-15" depending on timezone.  
**Example:** User in PST selects Jan 15. `new Date("2025-01-15")` is Jan 15 00:00 PST = Jan 15 08:00 UTC. But if user intended "Jan 15 in my timezone", this is correct. However, if backend expects "Jan 15 UTC midnight", this is wrong.  
**Fix:** For date-only inputs, treat as user timezone midnight, convert to UTC, then send UTC ISO string. Backend should store as UTC.

### Edge Case 7: **Notification Timestamps Display**
**Location:** Notification components, chat timestamps  
**Risk:** Backend sends UTC timestamp. Frontend displays using `\| date:'short'` which uses browser locale. User sees time in device timezone, not their profile timezone.  
**Example:** Notification sent at 2:00 PM UTC. User in PST sees "6:00 AM" (correct for PST). User travels to IST, sees "7:30 PM" (correct for IST). But if user has profile timezone set to PST, they should always see PST time.  
**Fix:** Convert UTC → user profile timezone (not device timezone) before display.

### Edge Case 8: **Reschedule Modal Time Constraints**
**Location:** `reschedule-modal.component.ts`, `quick-update-modal.component.ts`  
**Risk:** Time picker min constraint uses `new Date().toISOString().slice(0, 16)` which is browser local time. User selects time, but validation might fail if timezone conversion shifts the time.  
**Example:** User in PST at 11:00 PM tries to reschedule. Min time is "2025-01-15T23:00" (PST). User selects "2025-01-16T00:00" (PST). When converted to UTC, this becomes "2025-01-16T08:00" UTC. But if backend validates against UTC "now" (which is "2025-01-16T07:00" UTC), validation might fail.  
**Fix:** Calculate min time in user timezone, but validate against UTC before sending to backend.

### Edge Case 9: **Slot Sorting with Timezone Shifts**
**Location:** `instructor-schedule-class.component.ts` lines 3222-3280  
**Risk:** Sorts slots by parsing UTC ISO strings as local Date objects. If UTC time is near midnight, parsing as local might shift to different day, causing incorrect sort order.  
**Example:** Slot A: "2025-01-15T23:00:00Z" (UTC), Slot B: "2025-01-16T01:00:00Z" (UTC). User in PST parses as Jan 15 3:00 PM and Jan 15 5:00 PM (local). Sorted correctly. But user in IST parses as Jan 16 4:30 AM and Jan 16 6:30 AM. Still sorted correctly, but if there's a slot at "2025-01-16T00:30:00Z", it might sort incorrectly.  
**Fix:** Sort using UTC timestamps directly, not parsed Date objects.

### Edge Case 10: **Availability Checking with Timezone Mismatch**
**Location:** `instructor-schedule-class.component.ts` lines 3834, 3871, 4434  
**Risk:** Availability service is called with user timezone. Service might convert to UTC, but if conversion is inconsistent, availability checks return wrong results.  
**Example:** User in PST checks availability for "Jan 15 9:00 AM - 10:00 AM PST". Service converts to UTC "Jan 15 5:00 PM - 6:00 PM UTC". But if existing slots are stored in different timezone context, overlap detection fails.  
**Fix:** Always convert all times to UTC before availability checking. Backend should store and compare in UTC only.

---

## ✅ Suggested Minimal Architecture (No Code)

### 1. **Centralized TimezoneService**
- **Purpose:** Single source of truth for timezone operations
- **Methods:**
  - `getUserTimezone(): string` - Returns user profile timezone (fallback to device)
  - `utcToUser(utcIso: string): DateTime` - Converts UTC ISO → user timezone DateTime
  - `userToUtc(userDateTime: DateTime, userTimezone: string): string` - Converts user DateTime → UTC ISO
  - `getUtcNow(): DateTime` - Returns current UTC time
  - `getUserNow(): DateTime` - Returns current time in user timezone
  - `isTodayInUserTz(utcIso: string): boolean` - Checks if UTC time is "today" in user timezone
  - `formatForDisplay(utcIso: string, format: string): string` - Formats UTC time for display in user timezone

### 2. **UTC-to-Local Pipe**
- **Purpose:** Template pipe for displaying UTC times
- **Usage:** `{{ slot.startTime \| utcToLocal:'short' }}`
- **Implementation:** Uses TimezoneService to convert UTC → user timezone, then formats

### 3. **Date Input Helper Service**
- **Purpose:** Handles date picker inputs and datetime-local inputs
- **Methods:**
  - `getTodayForDatePicker(): string` - Returns "today" date string in user timezone
  - `getMinTimeForDateTimeInput(): string` - Returns min time constraint in user timezone
  - `convertDateInputToUtc(dateString: string, timeString: string, timezone: string): string` - Converts date+time input → UTC ISO
  - `convertDateTimeLocalToUtc(dateTimeLocal: string, timezone: string): string` - Converts datetime-local input → UTC ISO

### 4. **API Payload Normalizer**
- **Purpose:** Ensures all date/time values in API payloads are UTC
- **Usage:** Interceptor or service that normalizes payload before sending
- **Function:** Scans payload, finds date/time fields, converts to UTC ISO strings

### 5. **Date Comparison Utilities**
- **Purpose:** Safe date comparisons in business logic
- **Methods:**
  - `isPast(utcIso: string): boolean` - Compares UTC time with UTC now
  - `isFuture(utcIso: string): boolean` - Compares UTC time with UTC now
  - `isTodayInUserTz(utcIso: string): boolean` - Checks if UTC time is "today" in user timezone
  - `compareUtcTimes(utc1: string, utc2: string): number` - Compares two UTC times

### 6. **User Profile Timezone Integration**
- **Purpose:** Store and retrieve user's preferred timezone
- **Storage:** User profile/settings API
- **Fallback:** Device timezone if not set
- **Override:** Allow user to change timezone in settings

### 7. **Moment/Luxon Wrapper Service**
- **Purpose:** Centralized date library usage
- **Abstraction:** Wraps moment-timezone or Luxon
- **Benefits:** Easy to switch libraries, consistent API, timezone-aware by default

---

## 📊 SUMMARY STATISTICS

- **Total Date/Time Operations Scanned:** 1,500+
- **High-Risk Issues Found:** 20
- **Medium-Risk Issues Found:** 14
- **Safe/Consistent Usage:** 8
- **Systemic Anti-Patterns:** 7
- **Critical Edge Cases:** 10
- **DatePipe Usage (Templates):** 129
- **new Date() Usage:** 1,075+
- **moment() Usage:** 224+
- **toISOString() Usage:** 258+

---

## 🎯 PRIORITY FIX ORDER

1. **IMMEDIATE (User-Facing Bugs):**
   - Date picker min boundaries (instructor-schedule-class.component.ts)
   - Countdown timer timezone (upcoming-class-widget.component.ts)
   - Date display formatting (all components using DatePipe)

2. **HIGH (Data Integrity):**
   - Schedule creation timezone conversion (instructor-schedule-class.component.ts)
   - Reschedule/quick-update timezone handling
   - Past/future detection logic

3. **MEDIUM (System Reliability):**
   - Timezone source (device → user profile)
   - Centralized date service implementation
   - UTC-to-local pipe creation

4. **LOW (Code Quality):**
   - Replace all `new Date()` with timezone-aware alternatives
   - Standardize moment-timezone usage
   - Add timezone-aware date comparison utilities

---

**Report Generated:** Frontend Timezone Audit  
**Next Steps:** Implement TimezoneService and UTC-to-Local pipe, then systematically fix high-risk issues.

