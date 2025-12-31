# 🕐 UTC HARDENING PROGRAM - INDEX

**Program Start Date:** 2025-01-XX  
**Status:** 🟡 Planning Phase  
**Last Updated:** 2025-01-XX

---

## 🎯 PROGRAM GOAL STATEMENT

**Backend:** 100% UTC-based for all persistence, comparisons, job scheduling, and business logic. Zero server local timezone assumptions.

**Frontend:** Responsible for user-timezone display and user-input timezone handling. All API communication uses UTC timestamps.

**API Contracts:** Explicit, deterministic, and timezone-agnostic. All timestamps in UTC ISO 8601 format with 'Z' suffix.

**Elimination Target:** All "server local time" assumptions must be removed forever.

---

## 📖 DEFINITIONS

### UTC (Coordinated Universal Time)
- The canonical time standard for all backend operations
- No daylight saving time (DST) transitions
- Deterministic and machine-independent
- Format: ISO 8601 with 'Z' suffix: `"2025-01-15T10:30:00.000Z"`

### User Timezone
- The timezone preference stored in user profile (primary source of truth)
- Fallback: Device/browser detected timezone if profile not set
- Used ONLY for display and user input interpretation
- Format: IANA timezone identifier: `"America/Los_Angeles"`, `"Asia/Kolkata"`, `"Europe/London"`

### Canonical Timestamp Formats

**Backend Storage & API:**
- **Primary:** UTC ISO 8601 string with 'Z': `"2025-01-15T10:30:00.000Z"`
- **Alternative (if needed):** UTC epoch milliseconds: `1736938200000`
- **Never:** Local timezone strings, ambiguous date strings without timezone

**Frontend State:**
- **Store:** UTC ISO strings (same as backend)
- **Display:** Converted to user timezone via centralized service/pipe
- **User Input:** Interpreted in user timezone, converted to UTC before API call

**Database (MongoDB):**
- **Storage:** UTC Date objects (MongoDB default)
- **Queries:** UTC Date objects or UTC epoch milliseconds
- **Indexes:** UTC Date fields

---

## ⚠️ CURRENT KNOWN RISKS

### Backend High-Risk (20 issues)
1. `DateTime.local()` usage in 15+ utility functions
2. OTP expiry using server local time (security risk)
3. Notification scheduling using `new Date()` (server local)
4. Cron jobs scheduled with server timezone
5. Google Calendar events created without UTC enforcement
6. Database queries parsing dates as local time
7. Hardcoded 'Asia/Kolkata' defaults in utilities

### Frontend High-Risk (20 issues)
1. Date picker min boundaries use browser local "today"
2. Countdown timer compares UTC backend time with local "now"
3. Schedule creation uses device timezone, not user profile
4. DatePipe displays UTC times in browser locale (not user profile timezone)
5. Past/future detection uses local time instead of UTC
6. 1,075+ uses of `new Date()` without timezone context
7. 129 template uses of DatePipe without timezone parameter

### Systemic Anti-Patterns
1. **DateTime.local() Default Usage** - Backend utilities default to server timezone
2. **new Date() Without UTC Context** - 100+ backend, 1,075+ frontend occurrences
3. **Device Timezone as Source of Truth** - Frontend uses device timezone instead of user profile
4. **toLocaleString() in Backend** - Notification messages use server locale
5. **Date String Parsing Without Explicit UTC** - Ambiguous parsing causes off-by-one-day errors

---

## 🚫 GLOBAL RULES (Do/Don't)

### ❌ NEVER DO

**Backend:**
- Use `DateTime.local()`, `new Date()`, or `Date.now()` for business logic
- Parse date strings without explicit UTC context
- Use `toLocaleString()` for any business logic or notifications
- Hardcode timezone defaults (Asia/Kolkata, etc.)
- Expose server timezone offset in API responses
- Compare dates from different timezone contexts
- Use server local time for expiry calculations

**Frontend:**
- Use `new Date()` for business logic comparisons
- Use DatePipe without timezone parameter
- Use device timezone as primary source (use user profile)
- Send local timezone strings to backend
- Parse backend UTC responses as local Date objects
- Mix UTC and local time in comparisons

**Both:**
- Make sweeping changes in one phase
- Change code without verification checklist
- Skip rollback planning
- Deploy without testing regression flows

### ✅ ALWAYS DO

**Backend:**
- Use `DateTime.utc()` or UTC epoch milliseconds
- Parse all inputs as UTC: `DateTime.fromISO(string, { zone: 'utc' })`
- Store all dates as UTC ISO strings with 'Z' suffix
- Compare dates in UTC only
- Use UTC for all scheduled jobs and cron
- Convert to user timezone ONLY in API response formatting

**Frontend:**
- Convert user input (user timezone) → UTC before API call
- Convert backend UTC → user timezone for display
- Use centralized TimezoneService for all conversions
- Store UTC timestamps in component state
- Use timezone-aware pipes for display

**Both:**
- Make small, reversible changes per phase
- Verify each phase before proceeding
- Document all timestamp format changes
- Maintain backward compatibility where possible

---

## 📋 CANONICAL CONTRACT

### Backend ACCEPTS

**Request Payloads:**
- **Date+Time:** UTC ISO 8601 string with 'Z': `"2025-01-15T10:30:00.000Z"`
- **Date-Only:** UTC ISO date string: `"2025-01-15"` (interpreted as UTC midnight)
- **With Timezone (for validation):** `{ dateTime: "2025-01-15T10:30:00", timeZone: "America/Los_Angeles" }` → Backend converts to UTC using `unifyToUTC()`

**Query Parameters:**
- Date ranges: UTC ISO strings or UTC epoch milliseconds
- Time filters: UTC ISO strings

**Rejection Rules:**
- Ambiguous date strings without timezone (return 400 with clear error)
- Invalid ISO format (return 400)
- Future dates beyond reasonable bounds (return 400)

### Backend RETURNS

**Response Payloads:**
- **All timestamps:** UTC ISO 8601 string with 'Z': `"2025-01-15T10:30:00.000Z"`
- **Date fields:** UTC ISO date string: `"2025-01-15"`
- **Optional (for display):** Include `timeZone` field if original user timezone is known: `{ dateTime: "2025-01-15T10:30:00.000Z", timeZone: "America/Los_Angeles" }`

**Database:**
- All Date fields stored as UTC Date objects
- All queries use UTC Date objects or UTC epoch

### Frontend STORES (Component State)

**Canonical Format:**
- UTC ISO 8601 string with 'Z': `"2025-01-15T10:30:00.000Z"`
- UTC epoch milliseconds (if needed for calculations): `1736938200000`

**Never Store:**
- Local Date objects in state
- Local timezone strings
- Ambiguous date strings

### Frontend DISPLAYS

**User-Facing:**
- Convert UTC → user profile timezone (not device timezone)
- Format using centralized pipe: `{{ utcTime | utcToLocal:'short' }}`
- Show timezone indicator when relevant: `"2:00 PM PST"`

**Internal (Logs/Debug):**
- Can show UTC for debugging
- User-facing must always be user timezone

---

## 📊 PHASE TABLE

| Phase | Title | Scope | Files Touched | Status | QA Checklist | Rollback Notes | Owner | Date |
| ----- | ----- | ----- | ------------- | ------ | ------------ | -------------- | ----- | ---- |
| 01 | Establish Canonical Time Contract + Guardrails | Both | Documentation, lint rules | 🟡 Not Started | [See PHASE-01.md](#) | N/A (docs only) | TBD | - |
| 02 | Backend: Stop Implicit Local Time Creation | Backend | dateFunctions.js, timeUtils.js, otp.service.js | 🟡 Not Started | [See PHASE-02.md](#) | Revert utility changes | TBD | - |
| 03 | Backend: Normalize API Responses + Request Parsing | Backend | Controllers, middleware, validators | 🟡 Not Started | [See PHASE-03.md](#) | Revert controller changes | TBD | - |
| 04 | Frontend: Centralize Conversion + Formatting | Frontend | TimezoneService, pipes, components | 🟡 Not Started | [See PHASE-04.md](#) | Revert service/pipe changes | TBD | - |
| 05 | Scheduling-Specific Edge Hardening | Both | Scheduling components, slot logic | 🟡 Not Started | [See PHASE-05.md](#) | Revert scheduling changes | TBD | - |
| 06 | External Integrations (Google Calendar) | Backend | calendar.controller.js, googleCalendarService.js | 🟡 Not Started | [See PHASE-06.md](#) | Revert calendar changes | TBD | - |
| 07 | Final Audit + Regression Checklist | Both | All touched files | 🟡 Not Started | [See PHASE-07.md](#) | Full system rollback | TBD | - |

**Status Legend:**
- 🟡 Not Started
- 🟠 In Progress
- 🟢 Done
- 🔴 Blocked

---

## 🔄 REGRESSION FLOWS (Must Never Break)

These flows must be verified after EVERY phase:

### 1. Count-Based Scheduling Create/Edit
- **Flow:** Instructor creates count-based class with specific dates/times
- **Verify:** Slots created at correct UTC times, displayed in user timezone
- **Test:** Create class, edit slot times, verify Google Calendar sync

### 2. Slot Generation
- **Flow:** Duration-based recurring slot generation
- **Verify:** Slots generated at correct UTC times, no timezone shifts
- **Test:** Create weekly recurring class, verify all slots correct

### 3. Conflict Detection
- **Flow:** System detects overlapping slots
- **Verify:** Conflicts detected using UTC comparison
- **Test:** Create overlapping slots, verify conflict warning

### 4. Session List Sorting
- **Flow:** Sessions sorted by start time
- **Verify:** Sorting uses UTC timestamps, display shows user timezone
- **Test:** View session list, verify chronological order

### 5. Notification Timestamps
- **Flow:** Notifications sent with correct times
- **Verify:** Notification times displayed in user timezone
- **Test:** Receive notification, verify time display

### 6. OTP Expiry
- **Flow:** OTP expires after 5 minutes
- **Verify:** Expiry calculated in UTC, works across timezones
- **Test:** Request OTP, wait 5 minutes, verify expiry

### 7. Calendar Event Creation
- **Flow:** Class creation syncs to Google Calendar
- **Verify:** Events created with correct UTC times
- **Test:** Create class, verify Google Calendar event time

### 8. Timezone-Based UI Display
- **Flow:** All times displayed in user timezone
- **Verify:** Consistent timezone across all UI components
- **Test:** View dashboard, class details, notifications - all show user timezone

---

## ✅ DEFINITION OF DONE

The program is complete when ALL of the following are true:

### Backend
- ✅ Zero `DateTime.local()` usage in business logic
- ✅ Zero `new Date()` usage for business logic (only for UTC epoch)
- ✅ All database writes use UTC Date objects or UTC ISO strings
- ✅ All date comparisons use UTC
- ✅ All scheduled jobs use UTC
- ✅ All API responses return UTC timestamps
- ✅ All API request parsing converts to UTC
- ✅ No hardcoded timezone defaults
- ✅ No `toLocaleString()` in business logic
- ✅ All logs use UTC timestamps

### Frontend
- ✅ Centralized TimezoneService implemented and used
- ✅ UTC-to-Local pipe implemented and used in all templates
- ✅ All API payloads send UTC timestamps
- ✅ All backend responses parsed as UTC
- ✅ All display uses user profile timezone (not device)
- ✅ Zero `new Date()` usage for business logic
- ✅ All DatePipe usage includes timezone parameter
- ✅ All date comparisons use UTC

### System-Wide
- ✅ No double conversion (UTC → local → UTC)
- ✅ Reproducible behavior across machines/timezones
- ✅ Verified on QA environment
- ✅ All regression flows pass
- ✅ Documentation updated
- ✅ Team trained on new patterns

---

## 📝 CHANGE LOG

| Date | Phase | Change | Author |
| ---- | ----- | ------ | ------ |
| 2025-01-XX | - | Program initialized | TBD |

---

## 🔗 RELATED DOCUMENTATION

- [Backend Timezone Audit Report](../BACKEND_TIMEZONE_AUDIT_REPORT.md)
- [Frontend Timezone Audit Report](../FRONTEND_TIMEZONE_AUDIT_REPORT.md)
- [Phase 01: Canonical Contract](./phases/PHASE-01.md)
- [Phase 02: Backend Local Time Elimination](./phases/PHASE-02.md)
- [Phase 03: API Normalization](./phases/PHASE-03.md)
- [Phase 04: Frontend Centralization](./phases/PHASE-04.md)
- [Phase 05: Scheduling Hardening](./phases/PHASE-05.md)
- [Phase 06: External Integrations](./phases/PHASE-06.md)
- [Phase 07: Final Audit](./phases/PHASE-07.md)

---

**Last Updated:** 2025-01-XX  
**Next Review:** After each phase completion

