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

**Mode 2 — User-based email (`ENABLE_USER_BASED_EMAIL_SENDING=true`):**
Emails appear to come FROM the instructor's own Gmail address. Requires the instructor's personal OAuth tokens with Gmail access.

Emails sent this way:
- All of the above but from `instructor@gmail.com` instead of system

**The real question:** Is Mode 2 (user-based sending) actually needed, or can all emails come from the system account?

If Mode 2 is disabled → **NO Gmail scope is needed at sign-in time at all.**
If Mode 2 is needed → Use `gmail.send` (REST API, Sensitive) not `mail.google.com` (SMTP, Restricted). But this requires replacing Nodemailer with Gmail REST API calls.

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

User-Based Email (instructor's own Gmail)
  └── gmail.send           [Sensitive]     ← Only if Mode 2 enabled
      (currently broken — code checks for mail.google.com not gmail.send)

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
| Remove `gmail.send` / `mail.google.com` | User-based email sending disabled (system email still works) |
| Replace `calendar` with `calendar.events` | Secondary CalendarManager breaks entirely — no separate "ClassInTown" calendar |
| Replace `calendar` with `calendar.events` | Google Meet auto-generation breaks (if no custom class_link provided) |
| Remove all Gmail scopes | Only system emails work; instructor's name doesn't appear as sender |

---

## 7. THE ROOT CAUSE SUMMARY

Google is rejecting the app for **three compounding reasons**:

1. **`https://mail.google.com/` is listed in the frontend scope service** — This is a RESTRICTED scope and triggers Google's most stringent review process. Even if the backend currently requests `gmail.send`, having `mail.google.com` anywhere in the codebase/consent screen definition triggers the restricted review.

2. **`calendar` (full scope) is requested** — While only "Sensitive" (not Restricted), it's broader than necessary for basic event management. Google reviewers will ask why a scheduling app needs to create/delete calendars.

3. **The app is requesting all 4 non-trivial scopes at once on initial sign-in** — Google prefers "incremental authorization" where you request minimal scopes at sign-in and ask for more only when needed.

---

## 8. RECOMMENDED SOLUTION — THREE OPTIONS

### Option 1 (Minimal Code Change): Fix the mismatch, argue calendar need
- Fix: Make backend and frontend agree on `gmail.send` (not `mail.google.com`)
- Fix: Switch Nodemailer to Gmail REST API for user-based sending (or disable user-based sending)
- Justify: Explain to Google that secondary calendar creation (`calendars.insert`) is needed to give instructors a dedicated "ClassInTown" calendar separate from their personal events
- **Result**: `gmail.send` (Sensitive) + `calendar` (Sensitive) → both need verification but NOT restricted review

### Option 2 (Recommended): Incremental authorization
- Sign-in: Only request `profile` + `email`
- After sign-in, when instructor sets up their class for the first time: Request `calendar.events` separately with in-app prompt explaining why
- For user-based email: Request `gmail.send` separately only if instructor opts in
- **Result**: Sign-in works immediately without scope friction; extra scopes requested contextually
- **Google loves this pattern** and it's explicitly recommended in their OAuth guidelines

### Option 3 (Easiest): Remove user-based email + secondary calendars
- Remove `ENABLE_USER_BASED_EMAIL_SENDING` feature entirely → all emails from system account → no Gmail scope needed from users
- Disable `SecondaryCalendarManager` (just add events to primary calendar) → use `calendar.events` instead of `calendar`
- **Result**: Only `calendar.events` (Sensitive) needed → much easier Google approval
- **Trade-off**: All emails come from `classintownuat@gmail.com`, no separate ClassInTown calendar

---

## 9. WHAT TO TELL GOOGLE IN YOUR RESUBMISSION

For `https://www.googleapis.com/auth/calendar`:
> "We use this scope to create a dedicated 'ClassInTown' calendar in the instructor's Google account (calendars.insert), manage its lifecycle (calendars.delete), and create class schedule events with Google Meet links (events.insert with conferenceDataVersion). This allows instructors and their students to see class sessions in a separate calendar, preventing clutter in their primary calendar."

For `https://www.googleapis.com/auth/gmail.send`:
> "We use this scope to send transactional emails from the instructor's own Gmail address, including class enrollment confirmations, payment receipts, and session reminders. Students see the email coming from their instructor directly, building trust. Without this scope, all emails come from our system address and students may not recognize the sender."

**Critical: Remove any reference to `https://mail.google.com/` from ALL files before resubmission.** Replace it with `gmail.send` in the frontend scope service and fix the Nodemailer SMTP implementation to use the Gmail REST API instead.

---

## 10. FILES THAT NEED TO BE CHANGED

| File | Issue | Change Needed |
|---|---|---|
| `backend/configs/google/OAuth2.config.js` | Requests `gmail.send` but checks for `mail.google.com` | Fix `createTransporter` check to use `gmail.send` |
| `frontend/src/app/services/google-oauth-scope.service.ts` | Lists `https://mail.google.com/` as Gmail scope | Change to `gmail.send` |
| `backend/configs/google/OAuth2.config.js` | `REQUIRED_SCOPES` checks `mail.google.com` | Update to check `gmail.send` |
| `backend/shared/emailService.js` + `OAuth2.config.js` | Uses Nodemailer SMTP (requires `mail.google.com`) | Switch to Gmail REST API or disable user-based email |
| `backend/services/calendar/secondaryCalendarManager.js` | Creates actual Google Calendars (forces full `calendar` scope) | Either justify or remove secondary calendar feature |
