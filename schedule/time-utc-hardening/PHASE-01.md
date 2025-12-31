# PHASE 01: Establish Canonical Time Contract + Guardrails

**Status:** 🟡 Not Started  
**Scope:** Both (Backend + Frontend)  
**Risk Level:** 🟢 Low (Documentation only, no code changes)

---

## 🎯 OBJECTIVE

Establish the canonical time contract, coding rules, and guardrails BEFORE making any code changes. This phase creates the foundation for all subsequent phases.

**Goal:** Define "what good looks like" so all code changes have a clear target.

---

## 🚨 WHY THIS PHASE EXISTS

**Risk It Reduces:**
- Inconsistent fixes across codebase (different patterns in different files)
- Misunderstanding of UTC vs local time requirements
- Lack of clear rollback criteria
- Team confusion about "correct" patterns

**Without This Phase:**
- Developers might implement conflicting solutions
- No clear definition of "done"
- Hard to verify correctness
- Difficult to maintain consistency

---

## 📋 SCOPE

**Backend:**
- Document canonical timestamp formats
- Define UTC-only rules
- Identify central utility functions to standardize
- Document API contract requirements

**Frontend:**
- Document user timezone source of truth
- Define UTC ⇄ user timezone conversion patterns
- Identify central service/pipe approach
- Document display formatting rules

**Both:**
- Create coding standards document
- Define verification checklists
- Establish rollback procedures

---

## 📁 FILES TO CREATE/MODIFY

### New Files (Documentation Only)
- `time-utc-hardening/INDEX.md` ✅ (already created)
- `time-utc-hardening/phases/PHASE-01.md` ✅ (this file)
- `time-utc-hardening/CONTRACT.md` (canonical API contract)
- `time-utc-hardening/CODING_STANDARDS.md` (do's and don'ts)
- `time-utc-hardening/VERIFICATION_CHECKLIST.md` (regression tests)

### Files to Review (Read-Only)
- `backend/shared/dateTime/dateFunctions.js` (identify functions to standardize)
- `backend/shared/dateTime/timeZoneHelpers.js` (identify good patterns)
- `frontend/src/app/services/common/date-time.service.ts` (identify what exists)
- `frontend/src/app/components/instructor/instructor-class-management/instructor-schedule-class/instructor-schedule-class.component.ts` (identify conversion patterns)

---

## 🚫 RULES FOR THIS PHASE

**DO NOT:**
- Modify any code files
- Change any existing functionality
- Add new dependencies
- Create new services or utilities (yet)
- Run any migrations

**ONLY:**
- Create documentation files
- Review existing code patterns
- Define standards and contracts
- Identify target files for future phases

---

## 📝 STEP-BY-STEP IMPLEMENTATION PLAN

### Step 1: Create Canonical Contract Document
**File:** `time-utc-hardening/CONTRACT.md`

**Content:**
- Backend API request/response formats
- Frontend state storage formats
- Database storage formats
- Conversion patterns (user tz → UTC, UTC → user tz)
- Examples for each format

**Verification:** Document reviewed by team

### Step 2: Create Coding Standards Document
**File:** `time-utc-hardening/CODING_STANDARDS.md`

**Content:**
- Backend "NEVER DO" list (DateTime.local(), new Date(), etc.)
- Frontend "NEVER DO" list (new Date() for logic, DatePipe without tz, etc.)
- Backend "ALWAYS DO" list (DateTime.utc(), UTC parsing, etc.)
- Frontend "ALWAYS DO" list (UTC storage, user tz display, etc.)
- Code examples (good vs bad)

**Verification:** Standards approved by tech lead

### Step 3: Create Verification Checklist
**File:** `time-utc-hardening/VERIFICATION_CHECKLIST.md`

**Content:**
- Regression flow test cases
- API contract validation tests
- Timezone conversion verification steps
- Database query verification
- UI display verification

**Verification:** Checklist reviewed by QA

### Step 4: Identify Central Utilities to Standardize
**Document in:** `time-utc-hardening/UTILITY_INVENTORY.md`

**Content:**
- List of backend date/time utility functions
- List of frontend date/time services
- Which ones to keep/modify/replace
- Migration path for each

**Verification:** Inventory reviewed by team

### Step 5: Document Current State
**Document in:** `time-utc-hardening/CURRENT_STATE.md`

**Content:**
- Summary of audit findings
- High-risk areas identified
- Medium-risk areas identified
- Safe patterns to preserve

**Verification:** State documented accurately

---

## 🚀 SAFE ROLLOUT NOTES

**This Phase:**
- Zero code changes = zero deployment risk
- Documentation only = can be updated anytime
- No feature flags needed
- No database changes

**Communication:**
- Share documentation with team for review
- Get approval on contracts before Phase 2
- Ensure team understands new standards

---

## ✅ VERIFICATION CHECKLIST

### Documentation Completeness
- [ ] CONTRACT.md created with all timestamp formats
- [ ] CODING_STANDARDS.md created with do's/don'ts
- [ ] VERIFICATION_CHECKLIST.md created with test cases
- [ ] UTILITY_INVENTORY.md created with utility list
- [ ] CURRENT_STATE.md created with audit summary

### Team Review
- [ ] Backend team reviewed CONTRACT.md
- [ ] Frontend team reviewed CONTRACT.md
- [ ] Tech lead approved CODING_STANDARDS.md
- [ ] QA reviewed VERIFICATION_CHECKLIST.md
- [ ] Team understands new patterns

### No Code Changes
- [ ] Zero files modified (only new docs created)
- [ ] No tests added
- [ ] No dependencies added
- [ ] No migrations created

---

## 🔄 ROLLBACK PLAN

**Rollback Required:** No (documentation only)

**If Issues Found:**
- Update documentation files
- No code to revert
- No deployment needed

---

## ✅ EXIT CRITERIA

Phase 01 is complete when:

1. ✅ All documentation files created and reviewed
2. ✅ Canonical contract defined and approved
3. ✅ Coding standards documented and approved
4. ✅ Verification checklist created and reviewed
5. ✅ Team understands new patterns
6. ✅ INDEX.md updated with Phase 01 status
7. ✅ Ready to proceed to Phase 02

**Sign-off Required From:**
- Backend Tech Lead
- Frontend Tech Lead
- QA Lead
- Product Owner (for contract approval)

---

## 📊 ESTIMATED EFFORT

- **Documentation Creation:** 4-6 hours
- **Team Review:** 2-4 hours
- **Revisions:** 2-4 hours
- **Total:** 8-14 hours

---

## 🔗 NEXT PHASE

After Phase 01 completion, proceed to:
**[PHASE-02: Backend - Stop Implicit Local Time Creation](./PHASE-02.md)**

---

**Last Updated:** 2025-01-XX

