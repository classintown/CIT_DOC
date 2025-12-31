# PHASE 03: Backend - Normalize API Responses + Request Parsing

**Status:** 🟡 Not Started  
**Scope:** Backend Only  
**Risk Level:** 🟠 Medium (API contract changes, but backward compatible)

---

## 🎯 OBJECTIVE

Ensure all API endpoints consistently accept UTC timestamps in requests and return UTC timestamps in responses. Add validation to reject ambiguous date formats.

**Goal:** Make API contracts explicit and deterministic. All date/time inputs converted to UTC, all outputs in UTC.

---

## 🚨 WHY THIS PHASE EXISTS

**Risk It Reduces:**
- Ambiguous date parsing causing off-by-one-day errors
- Inconsistent API responses (some UTC, some local)
- Database queries with wrong date ranges
- Frontend receiving mixed timezone formats

**Current Issues (from audit):**
- Controllers parsing dates without explicit UTC: `new Date(dateString)`
- Database queries using local time: `query.startTime.$gte = new Date(startDate)`
- Google Calendar events created without UTC enforcement
- API responses sometimes include local timezone strings

**Impact if Not Fixed:**
- Users in different timezones get different results
- Date range queries miss data
- Google Calendar events created at wrong times
- Frontend cannot reliably parse backend responses

---

## 📋 SCOPE

**Backend Files to Modify:**
1. `backend/controllers/calendar/calendar.controller.js` (Google Calendar events)
2. `backend/controllers/admin/admin.controller.js` (date range queries)
3. `backend/controllers/instructor/instructor_class.controller.js` (slot parsing)
4. `backend/controllers/instructor/class-slot.controller.js` (slot time calculations)
5. `backend/routes/enrollments.routes.js` (date filters)
6. `backend/services/class/classEnrollmentService.js` (enrollment timestamps)
7. All controllers with `$gte`/`$lte` date queries

**Backend Files to Create:**
1. `backend/middlewares/dateValidation.middleware.js` (NEW - validate date inputs)
2. `backend/shared/validators/dateValidators.js` (NEW - date validation utilities)

**Backend Files to Review:**
- All controllers accepting date/time parameters
- All routes with date filters
- All services creating/updating date fields

---

## 📁 EXACT FILE LIST TO CHANGE

### Primary Targets (This Phase)

1. **`backend/controllers/calendar/calendar.controller.js`**
   - Lines 78, 102: `new Date(calendarEvent.start_date)` → UTC parsing
   - Lines 1421, 1425: `new Date(StartTime).toISOString()` → ensure UTC
   - Lines 168-174: Default timezone handling

2. **`backend/controllers/admin/admin.controller.js`**
   - Lines 2132-2133: `new Date(startDate)`, `new Date(endDate)` → UTC parsing
   - All date range queries

3. **`backend/controllers/instructor/instructor_class.controller.js`**
   - Lines 594-595: `new Date(slot.start.dateTime)` → UTC parsing
   - Lines 5316-5317: Week boundaries → UTC calculation

4. **`backend/controllers/instructor/class-slot.controller.js`**
   - Lines 41-42: `new Date()`, `new Date(now.getTime() + ...)` → UTC

5. **`backend/routes/enrollments.routes.js`**
   - Lines 3457-3458, 6058-6059, 6208-6209: Date filter parsing → UTC

6. **`backend/services/class/classEnrollmentService.js`**
   - Lines 165, 169, 201-202, 205: Timestamp creation → UTC
   - Lines 1253-1256: Already uses `unifyToUTC()` (good pattern, ensure consistent)

### Files to Create (This Phase)

1. **`backend/middlewares/dateValidation.middleware.js`** (NEW)
   - Validate date inputs in request body/query
   - Reject ambiguous formats
   - Convert to UTC ISO strings

2. **`backend/shared/validators/dateValidators.js`** (NEW)
   - `parseAndValidateDate()` - parse with UTC context
   - `parseDateRange()` - parse start/end dates as UTC
   - `validateISOString()` - ensure valid UTC ISO format

---

## 🚫 RULES FOR THIS PHASE

**DO NOT:**
- Change API response structure (only timestamp format)
- Modify frontend code
- Change database schemas
- Break existing API contracts (maintain backward compatibility)
- Modify notification scheduling logic (only request/response parsing)

**ONLY:**
- Parse all date inputs as UTC
- Return all date outputs as UTC ISO strings
- Add validation for ambiguous formats
- Fix date range queries to use UTC
- Ensure Google Calendar events use UTC

---

## 📝 STEP-BY-STEP IMPLEMENTATION PLAN

### Step 1: Create Date Validation Utilities
**File:** `backend/shared/validators/dateValidators.js` (NEW)

**Content:**
```javascript
const { DateTime } = require('luxon');

module.exports = {
  // Parse date string as UTC, throw if invalid
  parseAsUTC: (dateString) => {
    if (!dateString) return null;
    
    // If already UTC ISO with 'Z', parse directly
    if (dateString.endsWith('Z')) {
      const dt = DateTime.fromISO(dateString, { zone: 'utc' });
      if (!dt.isValid) throw new Error(`Invalid UTC ISO string: ${dateString}`);
      return dt.toJSDate();
    }
    
    // If has timezone offset, parse and convert to UTC
    if (/[+-]\d{2}:\d{2}$/.test(dateString)) {
      const dt = DateTime.fromISO(dateString);
      if (!dt.isValid) throw new Error(`Invalid ISO string: ${dateString}`);
      return dt.toUTC().toJSDate();
    }
    
    // Date-only string - treat as UTC midnight
    if (/^\d{4}-\d{2}-\d{2}$/.test(dateString)) {
      return DateTime.fromISO(`${dateString}T00:00:00.000Z`, { zone: 'utc' }).toJSDate();
    }
    
    // Ambiguous format - reject
    throw new Error(`Ambiguous date format (must be UTC ISO): ${dateString}`);
  },
  
  // Parse date range (start, end) as UTC
  parseDateRange: (startDate, endDate) => {
    return {
      start: startDate ? this.parseAsUTC(startDate) : null,
      end: endDate ? this.parseAsUTC(endDate) : null
    };
  },
  
  // Validate and convert to UTC ISO string
  toUTCISO: (date) => {
    if (!date) return null;
    if (typeof date === 'string') {
      return DateTime.fromISO(date, { zone: 'utc' }).toISO();
    }
    if (date instanceof Date) {
      return DateTime.fromJSDate(date, { zone: 'utc' }).toISO();
    }
    throw new Error('Invalid date type');
  }
};
```

**Verification:** Unit tests for each function

### Step 2: Create Date Validation Middleware
**File:** `backend/middlewares/dateValidation.middleware.js` (NEW)

**Content:**
- Validate date fields in request body
- Validate date query parameters
- Convert to UTC before passing to controllers
- Return 400 for invalid/ambiguous formats

**Verification:** Test with valid/invalid date inputs

### Step 3: Fix Calendar Controller
**File:** `backend/controllers/calendar/calendar.controller.js`

**Changes:**
- Line 78: `new Date(calendarEvent.start_date)` → use `parseAsUTC()`
- Line 102: `new Date(calendarEvent.end_date)` → use `parseAsUTC()`
- Lines 1421, 1425: Ensure UTC parsing before Google Calendar API
- Lines 168-174: Remove hardcoded 'TimeZones.India' default

**Verification:** Test calendar event creation/update

### Step 4: Fix Admin Controller Date Queries
**File:** `backend/controllers/admin/admin.controller.js`

**Changes:**
- Lines 2132-2133: `new Date(startDate)` → `parseAsUTC(startDate)`
- All `$gte`/`$lte` queries use UTC Date objects

**Verification:** Test admin date range filters

### Step 5: Fix Instructor Class Controller
**File:** `backend/controllers/instructor/instructor_class.controller.js`

**Changes:**
- Lines 594-595: `new Date(slot.start.dateTime)` → UTC parsing
- Lines 5316-5317: Week boundaries calculated in UTC

**Verification:** Test class listing, week boundaries

### Step 6: Fix Enrollment Routes Date Filters
**File:** `backend/routes/enrollments.routes.js`

**Changes:**
- All `new Date(startDate)` → `parseAsUTC(startDate)`
- All `new Date(endDate)` → `parseAsUTC(endDate)`
- Ensure all date range queries use UTC

**Verification:** Test enrollment date filters

### Step 7: Add Response Normalization
**File:** Create `backend/middlewares/responseNormalization.middleware.js` (optional)

**Content:**
- Intercept responses
- Convert all Date objects to UTC ISO strings
- Ensure consistent format

**Verification:** Test API responses are UTC ISO

### Step 8: Update All Controllers
**Search for:** All controllers with date parsing

**Changes:**
- Replace `new Date(dateString)` with `parseAsUTC(dateString)`
- Ensure all responses return UTC ISO strings
- Add validation errors for invalid dates

**Verification:** Run full API test suite

---

## 🚀 SAFE ROLLOUT NOTES

### Feature Flags
- **Not needed** (backward compatible - same API, just UTC parsing)

### Deployment Strategy
1. Deploy to **dev** environment first
2. Test all API endpoints with date parameters
3. Verify responses are UTC ISO strings
4. Deploy to **QA** environment
5. Run full regression tests
6. Deploy to **production** (low risk, parsing only)

### Backward Compatibility
- **Maintained:** API endpoints accept same formats
- **Behavior Change:** Ambiguous formats now rejected (400 error)
- **Impact:** Low (frontend should already send UTC ISO)

### API Versioning
- If breaking changes needed, use API versioning
- Document deprecated date formats
- Provide migration guide

### Monitoring
- Monitor 400 errors (invalid date formats)
- Monitor API response times (should not increase)
- Monitor error rates (should not increase)

---

## ✅ VERIFICATION CHECKLIST

### API Request Validation
- [ ] Valid UTC ISO strings accepted
- [ ] Ambiguous date strings rejected (400 error)
- [ ] Date-only strings treated as UTC midnight
- [ ] Invalid formats return clear error messages

### API Response Format
- [ ] All date fields are UTC ISO strings with 'Z'
- [ ] No local timezone strings in responses
- [ ] Consistent format across all endpoints
- [ ] Date objects converted to UTC ISO

### Database Queries
- [ ] All date range queries use UTC Date objects
- [ ] No timezone shifts in query results
- [ ] Date filters work correctly across timezones

### Integration Tests
- [ ] Calendar event creation uses UTC
- [ ] Date range queries return correct results
- [ ] Enrollment filters work correctly
- [ ] Admin date filters work correctly

### Manual Verification
- [ ] Create calendar event, verify UTC timestamp
- [ ] Query with date range, verify results
- [ ] Check API responses for UTC ISO format
- [ ] Verify no `new Date(dateString)` in controllers (grep)

### Regression Flows
- [ ] Calendar event creation still works
- [ ] Date range queries still work
- [ ] Enrollment date filters still work
- [ ] Admin date filters still work
- [ ] No new 400 errors for valid requests

### Code Review
- [ ] All date parsing uses `parseAsUTC()`
- [ ] All responses return UTC ISO strings
- [ ] Validation errors are clear
- [ ] No hardcoded timezone defaults

---

## 🔄 ROLLBACK PLAN

### If Issues Found

**Immediate Rollback:**
1. Revert commits for this phase
2. Restore original date parsing
3. Redeploy previous version

**Files to Revert:**
- All modified controllers
- `backend/middlewares/dateValidation.middleware.js` (delete)
- `backend/shared/validators/dateValidators.js` (delete)

**Rollback Time:** < 10 minutes (git revert)

**Data Impact:** None (no database changes)

### Partial Rollback
- If specific endpoint has issues, revert that controller only
- Keep validation utilities for future use

### API Compatibility
- If breaking changes, maintain old endpoint with deprecation notice
- Provide migration path for frontend

---

## ✅ EXIT CRITERIA

Phase 03 is complete when:

1. ✅ All date inputs parsed as UTC
2. ✅ All date outputs are UTC ISO strings
3. ✅ Ambiguous date formats rejected with clear errors
4. ✅ Database queries use UTC Date objects
5. ✅ Google Calendar events use UTC
6. ✅ Unit tests pass
7. ✅ Integration tests pass
8. ✅ API tests pass
9. ✅ Regression flows verified
10. ✅ Deployed to QA and verified
11. ✅ INDEX.md updated with Phase 03 status
12. ✅ Ready to proceed to Phase 04

**Sign-off Required From:**
- Backend Tech Lead
- QA Lead (API tests passed)
- Frontend Tech Lead (API contract verified)

---

## 📊 ESTIMATED EFFORT

- **Code Changes:** 12-16 hours
- **Testing:** 6-8 hours
- **Code Review:** 4-6 hours
- **Deployment & Verification:** 4-6 hours
- **Total:** 26-36 hours

---

## 🔗 NEXT PHASE

After Phase 03 completion, proceed to:
**[PHASE-04: Frontend - Centralize Conversion + Formatting](./PHASE-04.md)**

---

**Last Updated:** 2025-01-XX

