# Google OAuth Scope Analysis — ClassInTown
**Why Google Keeps Rejecting Us & What We Actually Need**

---

## 1. WHAT SCOPES ARE CURRENTLY BEING REQUESTED

### Backend (`backend/configs/google/OAuth2.config.js`)
```
https://www.googleapis.com/auth/userinfo.profile
https://www.googleapis.com/auth/userinfo.email
https://www.googleapis.com/auth/gmail.send          ← requested here
https://www.googleapis.com/auth/calendar            ← full calendar scope
```

### Frontend (`frontend/src/app/services/google-oauth-scope.service.ts`)
```
https://www.googleapis.com/auth/userinfo.profile
https://www.googleapis.com/auth/userinfo.email
https://mail.google.com/                            ← DIFFERENT from backend!
https://www.googleapis.com/auth/calendar
```

---

## 2. THE CRITICAL BUG — GMAIL SCOPE MISMATCH

**This is a real code inconsistency that is causing both the Google rejection AND a broken feature.**

| Location | Gmail Scope Used |
|---|---|
| Backend `OAuth2.config.js` SCOPES array | `gmail.send` |
| Frontend `google-oauth-scope.service.ts` | `https://mail.google.com/` |
| Backend `createTransporter()` scope check | `mail.google.com` (SMTP check) |
| Backend `validateRequiredScopes()` | `gmail.send` OR `mail.google.com` |

### Why this breaks user-based email sending right now:
When a user signs in, the backend requests `gmail.send`. After auth, `createTransporter()` checks:
```javascript
const hasGmailScope = userTokenScope.includes('https://mail.google.com/') ||
                      userTokenScope.includes('mail.google.com');
```
`gmail.send` does NOT contain `mail.google.com` → **check FAILS → falls back to system email**.

So the entire "send email FROM the instructor's own address" feature is broken for users who signed in with current scopes.

### Why they are different scopes entirely:
- `https://www.googleapis.com/auth/gmail.send` → Gmail **REST API** sending
- `https://mail.google.com/` → Gmail **SMTP** access (used by Nodemailer)

Nodemailer with `service: 'gmail'` uses **SMTP**, not the REST API. For SMTP OAuth2, Google requires `https://mail.google.com/`.

---

## 3. GOOGLE'S SCOPE CLASSIFICATION — WHY THEY REJECT US

| Scope | Classification | Google's Requirement |
|---|---|---|
| `userinfo.profile` | **Non-sensitive** | No review needed |
| `userinfo.email` | **Non-sensitive** | No review needed |
| `gmail.send` | **Sensitive** | Needs verification + demo video + policy pages |
| `calendar.events` | **Sensitive** | Needs verification + demo video + policy pages |
| `calendar` (full) | **Sensitive** | Needs verification + demo video + policy pages |
| `https://mail.google.com/` | ⛔ **RESTRICTED** | Security assessment + penetration test + legal review + Google manual approval |

**`https://mail.google.com/` is a RESTRICTED scope.** This is almost certainly the primary reason Google keeps rejecting the app. Restricted scopes require a formal security audit by a Google-approved assessor before approval can be granted. This costs money and takes months.

The frontend scope service lists `https://mail.google.com/` — even if the backend actually requests `gmail.send`, this frontend definition likely appeared in the OAuth consent screen review submission and triggered rejection.

---

## 4. WHAT EACH SCOPE IS ACTUALLY USED FOR (END TO END)

### A. `userinfo.profile` + `userinfo.email`
**Used for:** Sign-in and account creation only.
- Read Google profile (name, photo)
- Read Google email address
- Create/link SystemUser account in our DB

**Can we remove?** No. These are the core sign-in scopes.
**Google issue?** None. These are free scopes.

---

### B. Gmail Scope (the problematic one)

The platform sends emails in two distinct modes:

**Mode 1 — System email (classintownuat@gmail.com):**
Uses a pre-configured system refresh token stored in the `GoogleToken` DB collection. This is the SYSTEM account's own token, set up once by the admin. **This does NOT require any scope from the signing-in user.**

Emails sent this way:
- OTP verification
- Registration confirmation
- Student enrollment notification (to instructor)
- Student enrollment confirmation (to student)
- Payment receipts
- Class reminders
- Task assignment/update/deletion notifications
- Waitlist notifications
- Password change confirmation
- Payment plan created/updated emails

**Mode 2 — User-based email (`ENABLE_USER_BASED_EMAIL_SENDING=true`) — REQUIRED:**
Emails appear to come FROM the instructor's own Gmail address. Students see `Rahul Sharma <rahul@gmail.com>` as the sender, not a generic platform address. This is a core trust feature we are keeping.

Emails sent this way (from instructor's address):
- Class enrollment confirmation → to student
- Payment receipt → to student
- Session reminders → to students
- Class update/cancellation → to students
- Task assignments → to students

**Conclusion:** `gmail.send` scope (REST API, Sensitive) **must** be requested.
`mail.google.com` (SMTP, **Restricted**) must **never** be used.
This requires replacing the current Nodemailer SMTP approach with Gmail REST API calls.

---

### C. Calendar Scope

The platform uses these Google Calendar API operations:

**Operations that only need `calendar.events` (Sensitive):**
| Operation | Method | Purpose |
|---|---|---|
| Create class event | `calendar.events.insert` | New class slot → Google Calendar event |
| Update class event | `calendar.events.update` | Edit class details |
| Patch class event | `calendar.events.patch` | Add attendees, update meet link |
| Delete class event | `calendar.events.delete` | Cancel class slot |
| Get class event | `calendar.events.get` | Retrieve event details |
| List events | `calendar.events.list` | Sync/check existing events |
| Google Meet link | `conferenceDataVersion: 1` | Auto-create Meet link |

**Operations that REQUIRE the full `calendar` scope:**
| Operation | Method | Purpose |
|---|---|---|
| Create ClassInTown calendar | `calendar.calendars.insert` | `SecondaryCalendarManager` — creates a separate "ClassInTown" calendar in the user's Google Calendar |
| Delete ClassInTown calendar | `calendar.calendars.delete` | Remove the ClassInTown calendar |
| Get calendar metadata | `calendar.calendars.get` | Verify secondary calendar exists |
| List user's calendars | `calendar.calendarList.list` | Find existing ClassInTown calendar |
| Subscribe to calendar | `calendar.calendarList.insert` | Add calendar to user's list |

**The secondary calendar feature** (`SecondaryCalendarManager.js`) is what forces the full `calendar` scope. It creates a dedicated "ClassInTown" calendar inside the instructor's Google Calendar account, separate from their primary calendar.

**Important finding on Google Meet links:**
The code actually OVERRIDES the auto-generated Meet link with the instructor's own `class_link`:
```javascript
// From instructor_class.controller.js
if (sanitizedClassLink && sanitizedClassLink.trim() !== '') {
  eventData.hangoutLink = sanitizedClassLink; // Override Meet link with Zoom/custom link
}
```
So `conferenceDataVersion: 1` is only used when no `class_link` is provided. If all classes are required to have a `class_link`, the `conferenceDataVersion` (and its scope requirement) is not strictly necessary.

---

## 5. SCOPE DEPENDENCY MAP

```
Sign In
  └── userinfo.profile     [Non-sensitive] ← ALWAYS NEEDED
  └── userinfo.email       [Non-sensitive] ← ALWAYS NEEDED

System Email (classintownuat@gmail.com)
  └── NO USER SCOPE NEEDED ← System token pre-configured in DB

User-Based Email (instructor's own Gmail) — REQUIRED FEATURE
  └── gmail.send           [Sensitive]     ← MUST be requested
      CURRENTLY BROKEN: code checks for mail.google.com instead of gmail.send
      FIX NEEDED: replace Nodemailer SMTP with Gmail REST API

Class Scheduling (events only)
  └── calendar.events      [Sensitive]     ← Insert/Update/Delete/Get/List events

Secondary Calendar (ClassInTown sub-calendar)
  └── calendar (full)      [Sensitive]     ← Insert/Delete/Get calendars + calendarList

Google Meet Auto-Generation
  └── calendar (full)      [Sensitive]     ← conferenceDataVersion: 1
      (only needed if no class_link provided)
```

---

## 6. WHY NARROWING SCOPES BREAKS FUNCTIONALITY

| If Google says: "Remove this scope" | What breaks |
|---|---|
| Remove `gmail.send` | ❌ All instructor-sent emails fall back to system address — students don't recognize sender, trust drops |
| Replace `calendar` with `calendar.events` | ❌ `SecondaryCalendarManager` breaks — no dedicated "ClassInTown" calendar for instructors |
| Replace `calendar` with `calendar.events` | ❌ Google Meet auto-link generation breaks when no custom `class_link` is provided |
| Use `calendar.events` + always require `class_link` | ⚠️ Possible workaround — but forces instructors to always provide an external meeting link |

---

## 7. THE ROOT CAUSE SUMMARY

Google is rejecting the app for **three compounding reasons**:

1. **`https://mail.google.com/` is listed in the frontend scope service** — This is a RESTRICTED scope and triggers Google's most stringent review process. Even if the backend currently requests `gmail.send`, having `mail.google.com` anywhere in the codebase/consent screen definition triggers the restricted review.

2. **`calendar` (full scope) is requested** — While only "Sensitive" (not Restricted), it's broader than necessary for basic event management. Google reviewers will ask why a scheduling app needs to create/delete calendars.

3. **The app is requesting all 4 non-trivial scopes at once on initial sign-in** — Google prefers "incremental authorization" where you request minimal scopes at sign-in and ask for more only when needed.

---

## 8. DECISION: USER-BASED EMAIL SENDING IS REQUIRED

**We want instructors' emails to come FROM their own Gmail address** — students must see the instructor's name/email as the sender, not a generic ClassInTown address. This is a core trust feature.

This decision locks in the following:
- `https://www.googleapis.com/auth/gmail.send` **must** be requested
- `https://mail.google.com/` **must NOT** be used (it is a Restricted scope — Google will never approve without a costly security audit)
- The current Nodemailer SMTP approach must be **replaced** with the Gmail REST API

---

## 9. THE ONLY CORRECT PATH FORWARD

### Step 1 — Replace Nodemailer SMTP with Gmail REST API

**Why:** Nodemailer SMTP requires `https://mail.google.com/` (Restricted). The Gmail REST API's send endpoint uses `gmail.send` (Sensitive). Same result — email goes out from the instructor's address — but a completely different technical path.

**How it works with Gmail REST API:**
```
POST https://gmail.googleapis.com/gmail/v1/users/me/messages/send
Authorization: Bearer {instructor_access_token}
Body: { raw: "<base64-encoded RFC 2822 email>" }
```
The `me` in the URL means "the authenticated user" — i.e., the instructor. The email is sent from their Gmail account. Access token is the instructor's OAuth token obtained at sign-in with `gmail.send` scope.

**Emails affected (all must move from Nodemailer to REST API for user-based sending):**
- Class enrollment confirmation → to student (sent from instructor)
- Enrollment notification → to instructor (sent from system — no change needed)
- Payment receipt → to student (sent from instructor)
- Session reminders → to students (sent from instructor)
- Class update notifications → to students (sent from instructor)
- Task assignments → to students (sent from instructor)

**Emails that stay on system account (no instructor token needed):**
- OTP verification → always from system
- Password reset → always from system
- Admin notifications → always from system

### Step 2 — Fix the scope check in `createTransporter`

Currently the check is wrong for `gmail.send`:
```javascript
// CURRENT (BROKEN for gmail.send):
const hasGmailScope = userTokenScope.includes('https://mail.google.com/') ||
                      userTokenScope.includes('mail.google.com');

// FIXED:
const hasGmailScope = userTokenScope.includes('gmail.send') ||
                      userTokenScope.includes('mail.google.com'); // keep for backward compat
```

### Step 3 — Fix the frontend scope service

```typescript
// CURRENT (WRONG — Restricted scope):
{
  id: 'gmail',
  name: 'https://mail.google.com/',   // ← This triggers Restricted review
  ...
}

// FIXED (Sensitive scope):
{
  id: 'gmail',
  name: 'https://www.googleapis.com/auth/gmail.send',  // ← Sensitive only
  ...
}
```

### Step 4 — Unify backend REQUIRED_SCOPES validation

```javascript
// CURRENT (accepts either — confusing):
scope.includes('mail.google.com') || scope.includes('gmail.send')

// FIXED (only accept gmail.send going forward):
scope.includes('gmail.send')
```

### Step 5 — Justify the full `calendar` scope to Google

Since user-based email is kept, the final scope set requested at sign-in is:
```
userinfo.profile    [Non-sensitive] — authentication
userinfo.email      [Non-sensitive] — authentication
gmail.send          [Sensitive]     — send from instructor's own address
calendar            [Sensitive]     — secondary calendars + events + Meet links
```

Use incremental auth: request `gmail.send` and `calendar` only when the instructor first configures their class/profile, not at initial sign-in. This is the pattern Google recommends and approves fastest.

---

## 10. WHAT TO TELL GOOGLE IN YOUR RESUBMISSION

### For `https://www.googleapis.com/auth/gmail.send`:
> "ClassInTown is an instructor-student platform where instructors teach classes to enrolled students. When an instructor enrolls a student, confirms payment, sends class reminders, or assigns tasks, the email must come FROM the instructor's Gmail address — not a generic platform address — so students trust and recognize the sender. We use the Gmail API send endpoint (`POST /gmail/v1/users/me/messages/send`) with the instructor's OAuth token to achieve this. We do NOT read, modify, or delete any emails. We only send. The `gmail.send` scope is the minimum scope that allows sending via the Gmail REST API."

### For `https://www.googleapis.com/auth/calendar`:
> "ClassInTown creates a dedicated 'ClassInTown' calendar in the instructor's Google account (separate from their personal calendar) using `calendars.insert`. This keeps teaching sessions visually separated from personal events. We also create, update, and delete calendar events for each class session (`events.insert/update/delete`) and generate Google Meet links for online classes (`conferenceDataVersion: 1`). The full `calendar` scope is required because `calendar.events` alone does not allow creating or deleting calendars — only managing events within an existing calendar."

---

## 11. FILES THAT NEED TO BE CHANGED

| File | Issue | Required Change |
|---|---|---|
| `frontend/src/app/services/google-oauth-scope.service.ts` | Lists `https://mail.google.com/` (Restricted) | Replace with `https://www.googleapis.com/auth/gmail.send` |
| `backend/configs/google/OAuth2.config.js` — `createTransporter()` | Scope check looks for `mail.google.com` only | Add `gmail.send` to the scope check (fix the bug) |
| `backend/configs/google/OAuth2.config.js` — `validateRequiredScopes()` | Checks `mail.google.com` in `missingFeatures` message | Update message and check to reference `gmail.send` |
| `backend/shared/emailService.js` | User-based emails go via Nodemailer SMTP | Replace with Gmail REST API calls for instructor-sent emails |
| `backend/configs/google/OAuth2.config.js` — `createTransporter()` | Builds a Nodemailer SMTP transporter for user tokens | Build a Gmail REST API sender instead when user tokens are available |
| `backend/services/calendar/secondaryCalendarManager.js` | Creates real Google Calendars | No code change — but must be justified to Google in resubmission |

---

## 12. SCOPE DEPENDENCY MAP (FINAL — WITH USER-BASED EMAIL)

```
Sign-In (initial)
  ├── userinfo.profile     [Non-sensitive] ← Always, no review needed
  └── userinfo.email       [Non-sensitive] ← Always, no review needed

After sign-in → "Connect Google" step (incremental auth):
  ├── gmail.send           [Sensitive] ← Send emails FROM instructor's own Gmail
  │     Used by: Gmail REST API → POST /gmail/v1/users/me/messages/send
  │     Emails: enrollment confirms, payment receipts, reminders, task assignments
  │     NOT used for: system emails (OTP, password reset) — those use system account
  │
  └── calendar             [Sensitive] ← Full calendar management
        Used by:
          calendar.events.insert/update/delete/patch/get/list → class session events
          calendar.calendars.insert/delete/get             → secondary ClassInTown calendar
          calendar.calendarList.list/insert                → calendar subscription management
          conferenceDataVersion: 1                         → Google Meet link generation

System Emails (no user token needed):
  └── OTP, password reset, admin notifications → classintownuat@gmail.com system account
```
