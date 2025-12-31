# PHASE 02: Backend - Stop Implicit Local Time Creation

**Status:** 🟡 Not Started  
**Scope:** Backend Only  
**Risk Level:** 🟠 Medium (Core utility changes, but reversible)

---

## 🎯 OBJECTIVE

Eliminate all `DateTime.local()`, `new Date()`, and server timezone-dependent date creation in backend business logic. Replace with explicit UTC operations.

**Goal:** Make backend date/time operations deterministic and timezone-independent.

---

## 🚨 WHY THIS PHASE EXISTS

**Risk It Reduces:**
- Server timezone changes breaking scheduling logic
- Non-deterministic behavior across deployments
- OTP/token expiry failures when server timezone changes
- Cron jobs firing at wrong times

**Current Issues (from audit):**
- 20 high-risk backend issues using local time
- `DateTime.local()` in 15+ utility functions
- OTP expiry using server local time (security risk)
- Cron jobs scheduled with server timezone

**Impact if Not Fixed:**
- System breaks when deployed to different timezone
- Security vulnerabilities (OTP expiry)
- User-facing bugs (notifications at wrong times)

---

## 📋 SCOPE

**Backend Files to Modify:**
1. `backend/shared/dateTime/dateFunctions.js` (core utilities)
2. `backend/shared/utils/timeUtils.js` (cron scheduling)
3. `backend/services/otp/otp.service.js` (OTP expiry - CRITICAL)
4. `backend/shared/jobs/agenda.js` (job scheduling)
5. `backend/shared/dateTime/dateFunctions.js` (expiration calculations)

**Backend Files to Review (but not change yet):**
- Controllers (will be fixed in Phase 03)
- API routes (will be fixed in Phase 03)
- Models (will be fixed in Phase 03)

---

## 📁 EXACT FILE LIST TO CHANGE

### Primary Targets (This Phase)

1. **`backend/shared/dateTime/dateFunctions.js`**
   - Lines 58, 201, 204-205: `DateTime.local()` → `DateTime.utc()`
   - Lines 209-222: `getStartDateTimeWithTimeZone()` - remove hardcoded 'Asia/Kolkata'
   - Lines 225-237: `getStartDateTime()`, `getEndDateTime()` - ensure UTC
   - Lines 241-269: `addDaysToDate()`, `subtractDaysFromDate()` - use UTC
   - Lines 287-299: `calculateExpirationDate()` - use UTC

2. **`backend/shared/utils/timeUtils.js`**
   - Lines 22, 25-33: `calculateNextRunTimeUTC()` - fix to use UTC from start
   - Currently uses `DateTime.local()` then converts to UTC (wrong)

3. **`backend/services/otp/otp.service.js`**
   - Lines 22, 60: Replace `new Date(Date.now() + OTP_EXPIRATION)` with UTC epoch
   - Line 60: Replace `new Date() < otpEntry.expiresAt` with UTC comparison

4. **`backend/shared/jobs/agenda.js`**
   - Lines 52, 60, 202: Replace `new Date()` with `DateTime.utc().toJSDate()`

5. **`backend/shared/dateTime/dateFunctions.js`**
   - Lines 45-55: `calculateExpirationDate()` - ensure uses UTC epoch

### Files to Create (This Phase)

1. **`backend/shared/dateTime/utcHelpers.js`** (NEW)
   - Centralized UTC utility functions
   - `getUtcNow()`, `getUtcDate()`, `getUtcEpoch()`
   - Migration helpers for existing code

---

## 🚫 RULES FOR THIS PHASE

**DO NOT:**
- Change API request/response formats (Phase 03)
- Modify controllers (Phase 03)
- Change database schemas
- Modify frontend code
- Change Google Calendar integration (Phase 06)
- Modify notification scheduling logic (only fix time creation)

**ONLY:**
- Replace `DateTime.local()` with `DateTime.utc()`
- Replace `new Date()` with UTC-aware alternatives
- Fix utility functions to use UTC
- Fix OTP expiry to use UTC
- Fix cron scheduling to use UTC

---

## 📝 STEP-BY-STEP IMPLEMENTATION PLAN

### Step 1: Create UTC Helper Utilities
**File:** `backend/shared/dateTime/utcHelpers.js` (NEW)

**Content:**
```javascript
const { DateTime } = require('luxon');

module.exports = {
  // Get current UTC time as Date object
  getUtcNow: () => DateTime.utc().toJSDate(),
  
  // Get current UTC time as ISO string
  getUtcNowISO: () => DateTime.utc().toISO(),
  
  // Get current UTC epoch milliseconds
  getUtcEpoch: () => Date.now(), // Date.now() is already UTC epoch
  
  // Create UTC Date from ISO string (explicit UTC parsing)
  parseUtcISO: (isoString) => {
    return DateTime.fromISO(isoString, { zone: 'utc' }).toJSDate();
  },
  
  // Add duration to UTC now
  addToUtcNow: (duration) => {
    return DateTime.utc().plus(duration).toJSDate();
  }
};
```

**Verification:** Unit tests for each function

### Step 2: Fix dateFunctions.js - Core Utilities
**File:** `backend/shared/dateTime/dateFunctions.js`

**Changes:**
- Line 58: `getCurrentDate: () => DateTime.local()` → `getCurrentDate: () => DateTime.utc()`
- Line 201: `getCurrentDateTime: () => DateTime.local().toJSDate()` → `getCurrentDateTime: () => DateTime.utc().toJSDate()`
- Line 204-205: `getAddHoursToCurrentDate()` → use `DateTime.utc()`
- Lines 209-222: Remove hardcoded 'Asia/Kolkata', require timezone parameter
- Lines 287-299: `calculateExpirationDate()` → use `DateTime.utc()`

**Verification:** Run existing tests, verify no regressions

### Step 3: Fix timeUtils.js - Cron Scheduling
**File:** `backend/shared/utils/timeUtils.js`

**Changes:**
- Line 22: `const now = DateTime.local()` → `const now = DateTime.utc()`
- Lines 25-33: Create target time in UTC, not local
- Ensure conversion to UTC is explicit

**Verification:** Test cron job scheduling with different server timezones

### Step 4: Fix otp.service.js - OTP Expiry (CRITICAL)
**File:** `backend/services/otp/otp.service.js`

**Changes:**
- Line 22: `const expiresAt = new Date(Date.now() + OTP_EXPIRATION)`
  - Change to: `const expiresAt = new Date(Date.now() + OTP_EXPIRATION)` (Date.now() is UTC epoch, this is actually OK, but make explicit)
  - Better: Use `DateTime.utc().plus({ minutes: 5 }).toJSDate()`
- Line 60: `new Date() < otpEntry.expiresAt`
  - Change to: `Date.now() < otpEntry.expiresAt.getTime()` (compare UTC epochs)

**Verification:** Test OTP creation and expiry across timezones

### Step 5: Fix agenda.js - Job Scheduling
**File:** `backend/shared/jobs/agenda.js`

**Changes:**
- Lines 52, 60, 202: `const now = new Date()` → `const now = DateTime.utc().toJSDate()`
- Or use: `const now = new Date()` (acceptable since Date stores UTC internally, but be explicit)

**Verification:** Test job scheduling with UTC times

### Step 6: Update All Callers
**Search for:** All files importing/using modified functions

**Changes:**
- Update imports if function signatures change
- Verify callers handle UTC correctly
- Add comments where UTC is now explicit

**Verification:** Run full test suite

---

## 🚀 SAFE ROLLOUT NOTES

### Feature Flags
- **Not needed** (internal utilities only, no API changes)

### Deployment Strategy
1. Deploy to **dev** environment first
2. Run verification checklist
3. Deploy to **QA** environment
4. Run full regression tests
5. Deploy to **production** (low risk, utilities only)

### Backward Compatibility
- **Maintained:** Function signatures remain same (return types unchanged)
- **Behavior Change:** Functions now return UTC instead of local (intended)
- **Impact:** Low (callers should already handle UTC, but verify)

### Monitoring
- Monitor OTP expiry rates (should not change)
- Monitor cron job execution times (should be consistent)
- Monitor error rates (should not increase)

---

## ✅ VERIFICATION CHECKLIST

### Unit Tests
- [ ] UTC helper functions have unit tests
- [ ] dateFunctions.js utilities tested with UTC
- [ ] timeUtils.js cron scheduling tested
- [ ] otp.service.js expiry tested across timezones
- [ ] agenda.js job scheduling tested

### Integration Tests
- [ ] OTP creation and verification works
- [ ] Cron jobs fire at correct UTC times
- [ ] Scheduled notifications fire at correct times
- [ ] Expiration calculations are correct

### Manual Verification
- [ ] Create OTP, verify expiry after 5 minutes
- [ ] Schedule cron job, verify execution time
- [ ] Check server logs for UTC timestamps
- [ ] Verify no `DateTime.local()` in modified files (grep)

### Regression Flows
- [ ] OTP expiry still works
- [ ] Token expiry still works
- [ ] Cron jobs still execute
- [ ] Scheduled notifications still fire
- [ ] No new errors in logs

### Code Review
- [ ] All `DateTime.local()` replaced with `DateTime.utc()`
- [ ] All `new Date()` usage reviewed and justified
- [ ] No hardcoded timezone defaults
- [ ] Comments added where UTC is now explicit

---

## 🔄 ROLLBACK PLAN

### If Issues Found

**Immediate Rollback:**
1. Revert commits for this phase
2. Restore original utility functions
3. Redeploy previous version

**Files to Revert:**
- `backend/shared/dateTime/dateFunctions.js`
- `backend/shared/utils/timeUtils.js`
- `backend/services/otp/otp.service.js`
- `backend/shared/jobs/agenda.js`
- Delete `backend/shared/dateTime/utcHelpers.js` (if created)

**Rollback Time:** < 5 minutes (git revert)

**Data Impact:** None (no database changes)

### Partial Rollback
- If only one utility has issues, revert that file only
- Keep other improvements

---

## ✅ EXIT CRITERIA

Phase 02 is complete when:

1. ✅ All `DateTime.local()` replaced with `DateTime.utc()` in target files
2. ✅ OTP expiry uses UTC epoch comparison
3. ✅ Cron scheduling uses UTC
4. ✅ All utility functions return UTC
5. ✅ Unit tests pass
6. ✅ Integration tests pass
7. ✅ Regression flows verified
8. ✅ Deployed to QA and verified
9. ✅ INDEX.md updated with Phase 02 status
10. ✅ Ready to proceed to Phase 03

**Sign-off Required From:**
- Backend Tech Lead
- QA Lead (regression tests passed)

---

## 📊 ESTIMATED EFFORT

- **Code Changes:** 8-12 hours
- **Testing:** 4-6 hours
- **Code Review:** 2-4 hours
- **Deployment & Verification:** 2-4 hours
- **Total:** 16-26 hours

---

## 🔗 NEXT PHASE

After Phase 02 completion, proceed to:
**[PHASE-03: Backend - Normalize API Responses + Request Parsing](./PHASE-03.md)**

---

**Last Updated:** 2025-01-XX

