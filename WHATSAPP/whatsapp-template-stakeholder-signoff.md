# WhatsApp Templates — Stakeholder Sign-off Catalog

> **Purpose:** Budget & product sign-off. Every template listed with business value, data, interactive action, audience, and scenario.  
> **Rule:** No template ships without a clear **action** the user can take (button / deep link / quick reply).  
> **Pricing (India 2026):** Utility/Auth ≈ **₹0.115**/delivered · Marketing ≈ **₹0.863**/delivered · Service (free-form in 24h window) = free.  
> **Related:** `docs/whatsapp-strategy-and-budget.md`

---

## How to read this (sign-off columns)

| Column | Meaning |
|---|---|
| **Template** | Meta template name |
| **To** | Who receives it |
| **Scenario** | When it fires |
| **Solves** | Business value (why pay for this) |
| **Data** | What the message shows |
| **Action** | Interactive CTA / quick reply (required) |
| **Cat** | U=Utility · A=Auth · M=Marketing |
| **Tier** | 🔴 never pause · 🟠 pause at hard budget · 🟢 pause first |
| **Ask** | **KEEP** (in budget) · **BUILD** (new, recommend fund) · **OPTIONAL** · **CUT/DEFER** |

---

## A. Executive summary for budget approval

| Bucket | Count | Est. share of WA volume | Recommendation |
|---|---|---|---|
| 🔴 Critical (OTP, payment confirm/fail, cancel, student reminder) | ~12 | Medium | **Must fund** |
| 🟠 Core product (enrollment, attendance, progress, notes, due) | ~35 | High | **Fund** |
| 🟢 Nice-to-have (digests, task chatter, welcome) | ~25 | Controllable | Fund with soft-pause |
| 🆕 New BUILD (progress, absent, receipt, CRM, certificate…) | ~20 | Grows trust | Fund P0–P2 first |
| CUT/DEFER (low value / sample / spam risk) | ~8 | — | Do not fund |

**Interactive standard (all KEEP/BUILD):** every template gets at least one of:
- **URL button** → deep link in app (Pay / View session / Open note / Claim seat)
- **Quick reply** → Accept / Present / Suggest another (opens 24h free window)

---

## B. Auth & account

| # | Template | To | Scenario | Solves | Data | Action | Cat | Tier | Ask |
|---|---|---|---|---|---|---|---|---|---|
| 1 | `whatsapp_mobile_otp_verification` | User (any role) | Login / signup / verify mobile | Account security; unblocks access | OTP code, expiry hint | Open app / enter code (Auth template) | A | 🔴 | **KEEP** |
| 2 | `welcome_new_user` | New user | After successful registration | Activation / first value | Name, product greeting | **Open dashboard** | U | 🟢 | **KEEP** |
| 3 | `whatsapp_student_welcome` *(new)* | Student | First login / profile complete | Reduce drop-off after signup | Name, next step (browse/enroll) | **Browse classes** | U | 🟢 | **OPTIONAL** |
| 4 | `whatsapp_instructor_onboarding_complete` *(new)* | Instructor | CRM/onboarding finished | Time-to-first-class | Name, checklist done | **Create first class** | U | 🟢 | **BUILD** |
| 5 | Password reset (verify Meta name) | User | Reset requested | Recover access without support ticket | Reset context | **Reset password** link | U/A | 🔴 | **KEEP/BUILD** |
| 6 | Password changed notice | User | Password changed | Fraud alert | Time of change | **Secure account** / contact support | U | 🟠 | **KEEP** |
| 7 | Account validation | User | Email/mobile validation pending | Complete KYC-lite | What to validate | **Verify now** | U | 🟠 | **BUILD** if mobile-first |
| 8 | `user_invitation` (verify Meta) | Invitee | Invited to ClassInTown | Conversion of invite | Inviter, role | **Accept invite** | U | 🟠 | **KEEP** |
| 9 | User status update | Student | Suspended / reactivated | Clarity; reduce support | New status, reason if any | **Open account** / support | U | 🟠 | **KEEP** |

---

## C. Enrollment & waitlist

| # | Template | To | Scenario | Solves | Data | Action | Cat | Tier | Ask |
|---|---|---|---|---|---|---|---|---|---|
| 10 | `whatsapp_enrollment_confirmation_student_notification` | Student | Enrollment submitted | Confirmation reduces “did it work?” | Class, instructor, status | **View enrollment** | U | 🟠 | **KEEP** |
| 11 | `whatsapp_student_enrollment_notification` | Student | Enrollment flow notify | Same journey clarity | Class, dates | **View details** | U | 🟠 | **KEEP** |
| 12 | `whatsapp_class_student_enrollment_notification` | Student | Direct class enrollment | Confirm seat | Class, schedule | **Open class** | U | 🟠 | **KEEP** |
| 13 | `whatsapp_new_enrollment_instructor` | Instructor | New enrollment request | Faster approve/reject | Student, class | **Review enrollment** | U | 🟠 | **KEEP** |
| 14 | `whatsapp_class_instructor_enrollment_notification` | Instructor | Student enrolled in class | Ops awareness | Student, class | **Open roster** | U | 🟠 | **KEEP** |
| 15 | `enrollment_status_update` | Student or Instructor | Approved / rejected / waitlisted / cancelled / activated / completed | One template covers status machine | Name, class, **new status** | **View enrollment** | U | 🟠 | **KEEP** |
| 16 | `whatsapp_waitlist_seat_available_student` *(new)* | Student | Waitlist → seat open | Convert waitlist → paid seat | Class, seat, deadline | **Claim seat** (CTA) | U | 🟠 | **BUILD** |
| 17 | Enrollment morning digest (instructor) | Instructor | Daily summary | Batch ops; fewer single pings | Counts by status | **Open enrollments** | U | 🟢 | **KEEP** (pause-friendly) |
| 18 | Enrollment morning digest (student) | Student | Daily summary | Optional awareness | Pending items | **Open dashboard** | U | 🟢 | **OPTIONAL** / prefer email |

---

## D. Schedule, slots & calendar (high UX)

| # | Template | To | Scenario | Solves | Data | Action | Cat | Tier | Ask |
|---|---|---|---|---|---|---|---|---|---|
| 19 | `whatsapp_slot_reminder_student` | Student | 24h / 1h before class | Attendance; fewer no-shows | Student, class, instructor, date, time, remaining | **View session** | U | 🔴 | **KEEP** |
| 20 | `whatsapp_slot_reminder_instructor` | Instructor | Before class | Prep; know headcount | Class, date, time, enrolled count | **Open class** | U | 🟠 | **KEEP** |
| 21 | `whatsapp_slot_readiness_check_instructor` | Instructor | Pre-class readiness | Confirm session will run | Class, date, time, count | **Confirm ready** (deep link) | U | 🟠 | **KEEP** |
| 22 | `whatsapp_slot_cancelled_student` | Student | Session cancelled | Prevent wasted travel | Class, instructor, date, time, reason | **View alternatives** / support | U | 🔴 | **KEEP** |
| 23 | `whatsapp_slot_cancelled_instructor` | Instructor | Cancel ack / ops | Record of cancel | Class, date, time, reason | **Open schedule** | U | 🔴 | **KEEP** |
| 24 | `whatsapp_slot_rescheduled_notification` | Student + Instructor | Time/date changed | Accept new time without chat | Class, old→new date/time | **Accept** / **Suggest another** (quick reply) + **View** | U | 🔴 | **KEEP** + improve buttons |
| 25 | Slot updated (time/place) | Student + Instructor | Venue/time tweak | Same as reschedule clarity | Class, new time/place | **View session** | U | 🔴 | **KEEP** |
| 26 | `whatsapp_schedule_class_creation_notification` | Instructor | Class created | Confirm listing live | Class name, schedule summary | **Manage class** | U | 🟢 | **KEEP** |
| 27 | `whatsapp_schedule_class_update_notification` | Instructor | Class metadata changed | Ops confirmation | What changed | **View class** | U | 🟢 | **KEEP** |
| 28 | Class updated → student | Student | Enrolled class details changed | Keep learners accurate | Class, change summary | **View class** | U | 🟠 | **KEEP** |
| 29 | `whatsapp_schedule_event_creator_notification` | Creator | Calendar event created | Confirm event | Title, time, attendees | **Open event** | U | 🟢 | **KEEP** |
| 30 | `whatsapp_schedule_event_attendees_notification` | Attendees | Invited to event | Show up | Title, time, place | **Add / View event** | U | 🟠 | **KEEP** |
| 31–34 | Event update/cancel (creator + attendees) | Creator / Attendees | Event changed/cancelled | Avoid missed updates | Title, change/cancel reason | **View calendar** | U | 🟠 | **KEEP** |
| 35 | `whatsapp_schedule_event_reminder` | Attendee | Event upcoming | Punctuality | Title, time | **Open event** | U | 🟠 | **KEEP** |

**Do not fund WA for:** marketplace class create/update **broadcasts** (push-only; would be Marketing spam).

---

## E. Attendance & absence

| # | Template | To | Scenario | Solves | Data | Action | Cat | Tier | Ask |
|---|---|---|---|---|---|---|---|---|---|
| 36 | `whatsapp_attendance_reminder_instructor` | Instructor | After/near class | Mark attendance → billing trust | Instructor, class, date, enrolled count | **Mark attendance** | U | 🟠 | **BUILD Meta (P0)** |
| 37 | `whatsapp_attendance_morning_instructor` | Instructor | Morning digest of pending | Catch unfinished attendance | Pending count | **Open attendance** | U | 🟢 | **BUILD Meta (P0)** |
| 38 | `whatsapp_attendance_student_confirm` | Student | Confirm attendance | Accurate records; disputes ↓ | Student, class, instructor | **Present** / **Absent** (quick reply) | U | 🟠 | **BUILD Meta (P0)** |
| 39 | `whatsapp_student_absent_student` *(new)* | Student | Marked absent | Transparency; make-up path | Class, date, instructor | **Contact instructor** / view note | U | 🟠 | **BUILD** |
| 40 | `whatsapp_student_absent_parent` *(new)* | Parent | Child marked absent | Parent trust; safety | Child, class, date | **View note** / contact | U | 🟠 | **BUILD** |

---

## F. Payments, plans, refunds, receipts

| # | Template | To | Scenario | Solves | Data | Action | Cat | Tier | Ask |
|---|---|---|---|---|---|---|---|---|---|
| 41 | `whatsapp_payment_confirmation_student` | Student | Payment success | Trust; reduce “did money go?” tickets | Amount, class/plan, ref | **View receipt** | U | 🔴 | **KEEP** |
| 42 | `whatsapp_payment_confirmation_instructor` | Instructor | Payment received | Cashflow visibility | Student, amount, class | **View payment** | U | 🔴 | **KEEP** |
| 43 | `payment_failed` | Student | Gateway failure | Recover conversion | Amount, reason code | **Retry payment** | U | 🔴 | **KEEP** |
| 44 | `payment_refunded` | Student (+ instr) | Refund done | Close loop | Amount, reason | **View refund** | U | 🟠 | **KEEP** |
| 45 | `payment_verified` | Student + Instructor | Manual verify OK | Unlock access | Amount, plan | **Open enrollment** | U | 🟠 | **KEEP** |
| 46 | `payment_verification_rejected` | Student + Instructor | Proof rejected | Fix proof fast | Reason | **Resubmit proof** | U | 🟠 | **KEEP** |
| 47 | `payment_status_update` | Student/Instructor | Generic payment status | Catch-all clarity | Status, amount | **View payment** | U | 🟠 | **KEEP** |
| 48 | `payment_due_reminder` | Student | Installment due soon | Collections | Amount, due date, class | **Pay now** | U | 🟠 | **KEEP** |
| 49 | `payment_overdue_student` | Student | Past due | Collections escalation | Amount, days overdue | **Pay now** | U | 🟠 | **KEEP** |
| 50 | `payment_overdue_instructor` | Instructor | Student overdue | Instructor can chase | Student, amount | **View collections** | U | 🟠 | **KEEP** |
| 51 | `payment_due_reminder_instructor` | Instructor | Due digest | Ops batching | List summary | **Open dues** | U | 🟢 | **KEEP** |
| 52 | `whatsapp_payment_plan_created_*` | Student / Instructor | Plan created | Align on installments | Plan name, totals, dates | **View plan** | U | 🟠 | **KEEP** |
| 53 | `whatsapp_payment_plan_updated_*` | Student / Instructor | Plan changed | Avoid surprise amounts | What changed | **View plan** | U | 🟠 | **KEEP** (student was email-only → fund WA) |
| 54 | `whatsapp_payment_plan_assigned_*` | Student / Instructor | Plan assigned | Start paying | Plan, first due | **Pay / View** | U | 🟠 | **KEEP** |
| 55 | `whatsapp_payment_plan_pending_send_instructor_notification` | Instructor | Plan ready to send | Nudge send | Student, plan | **Send plan** | U | 🟢 | **KEEP** |
| 56 | `whatsapp_payment_plan_completed_*` | Student / Instructor | Plan fully paid | Celebration + closure | Totals | **View receipt** | U | 🟠 | **KEEP** |
| 57 | `whatsapp_payment_plan_cancelled_*` | Student / Instructor | Plan cancelled | Stop wrong payments | Reason | **View status** | U | 🟠 | **KEEP** |
| 58 | `whatsapp_partial_payment_*` | Student / Instructor | Partial paid | Remaining balance clear | Paid, remaining | **Pay balance** / view | U | 🟠 | **KEEP** |
| 59 | `whatsapp_payment_receipt_student` *(new)* | Student | Formal receipt | Accounting / school admin | Amount, tax/ref, date | **Download receipt** | U | 🟠 | **BUILD** |
| 60 | Payment plan timeline *(new WA)* | Student (+ instr) | Installment schedule shared | Predictability | Dates + amounts | **View timeline** / Pay next | U | 🟠 | **BUILD** |

**Admin reconciliation alerts:** email only — **CUT from WA budget**.

---

## G. Progress *(currently broken: free-form text — must become templates)*

| # | Template | To | Scenario | Solves | Data | Action | Cat | Tier | Ask |
|---|---|---|---|---|---|---|---|---|---|
| 61 | `whatsapp_progress_update_student` *(new)* | Student | Instructor records metrics | Learning feedback loop | Class, session/date, metrics, note | **View progress** | U | 🟠 | **BUILD (P0)** |
| 62 | `whatsapp_progress_update_parent` *(new)* | Parent | Same, guardian copy | Parent engagement / retention | Child, class, metrics | **View progress** | U | 🟠 | **BUILD (P0)** |
| 63 | `whatsapp_progress_update_instructor` *(new)* | Instructor | Ack after save | Optional confirmation | Student, class | **Open notes** | U | 🟢 | **OPTIONAL** |
| 64 | `whatsapp_progress_milestone_student` *(new)* | Student | Goal/milestone hit | Motivation | Milestone name | **View milestone** | U | 🟢 | **OPTIONAL** |

---

## H. Student notes *(not session notes)*

> **Session notes** (`/session-notes`) = instructor private prep → **no WhatsApp** (CUT by design).

| # | Template | To | Scenario | Solves | Data | Action | Cat | Tier | Ask |
|---|---|---|---|---|---|---|---|---|---|
| 65 | `whatsapp_note_creation_instructor_notification` | Instructor | Note created | Confirm sent to N students | Title, due, priority, scope, count | **Track notes** | U | 🟢 | **KEEP** |
| 66 | `whatsapp_note_assignment_student_notification` | Student | Note assigned | Homework / feedback delivery | Title, instructor, due, priority, scope | **Open note** | U | 🟠 | **KEEP** |
| 67 | `whatsapp_note_parent_notification` | Parent | Note shared to guardian | Family loop | Child, title, instructor | **View note** | U | 🟠 | **KEEP** |
| 68 | `whatsapp_note_status_instructor_notification` | Instructor | Student marked done/read | Close loop | Student, status | **View note** | U | 🟢 | **KEEP** |
| 69 | `whatsapp_note_status_student_confirmation` | Student | Status ack | Confirmation | Note title, status | **Open note** | U | 🟢 | **KEEP** |
| 70 | `whatsapp_note_deletion_student_notification` | Student | Note deleted | Avoid confusion | Title | **Open notes list** | U | 🟢 | **KEEP** / prefer email |
| 71 | `whatsapp_note_updated_student` *(new)* | Student | Note content edited | Updated homework not missed | What changed, due | **Open note** | U | 🟠 | **BUILD** |
| 72 | Note updated → parent *(new optional)* | Parent | Material change | Parent awareness | Child, title | **View note** | U | 🟢 | **OPTIONAL** |

---

## I. Tasks

| # | Template | To | Scenario | Solves | Data | Action | Cat | Tier | Ask |
|---|---|---|---|---|---|---|---|---|---|
| 73 | `whatsapp_task_assignment_recipient_notification` | Assignee | Task assigned | Execution | Task, due, priority | **Open task** | U | 🟢 | **KEEP** |
| 74 | `whatsapp_task_creation_sender_notification` | Creator | Task created | Ack | Task summary | **Open task** | U | 🟢 | **OPTIONAL** |
| 75 | `task_status_update_recipient` / `sender` | Both | Status changed | Coordination | Status, due | **Open task** | U | 🟢 | **KEEP** |
| 76 | `whatsapp_task_update_*` | Both | Details changed | Avoid stale work | Fields changed | **Open task** | U | 🟢 | **KEEP** |
| 77 | `task_reminder_recipient` | Assignee | Reminder before due | On-time completion | Due date | **Open task** | U | 🟢 | **KEEP** if wired |
| 78 | `task_over_due_notification` | Assignee | Overdue | Escalation | Days late | **Open task** | U | 🟢 | **KEEP** if wired |
| 79 | `task_completion_sender` | Creator | Completed | Close loop | Task name | **Review task** | U | 🟢 | **KEEP** |
| 80 | `task_not_updated_reminder_sender` | Creator | Stale task | Nudge follow-up | Task, last update | **Open task** | U | 🟢 | **OPTIONAL** |
| 81 | `task_deletion_recipient` | Assignee | Deleted | Stop work | Task name | **Open tasks** | U | 🟢 | **DEFER** (email enough) |

---

## J. CRM / subscriptions / marketplace / certificates / family

| # | Template | To | Scenario | Solves | Data | Action | Cat | Tier | Ask |
|---|---|---|---|---|---|---|---|---|---|
| 82 | CRM OTP signup/login (`crm_otp_*`) | Instructor/BDM | CRM auth | Secure CRM access | OTP | Enter OTP | A | 🔴 | **KEEP** |
| 83 | CRM onboarding invite *(new)* | Instructor | Invited onto platform | Activation | Invite context | **Complete onboarding** | U | 🟠 | **BUILD** |
| 84 | Subscription assigned *(new)* | Instructor | Plan assigned | Entitlement clarity | Plan, dates | **View subscription** | U | 🟠 | **BUILD** |
| 85 | Subscription expiry reminder *(new)* | Instructor | Expiring soon | Retention / renew | Expiry date | **Renew now** | U | 🟠 | **BUILD** |
| 86 | Platform access granted *(new)* | Instructor | Access activated | Unblock teaching | What unlocked | **Open dashboard** | U | 🟠 | **BUILD** |
| 87 | Inquiry response *(new)* | Marketplace lead | Instructor replied | Lead → enrollment | Class, reply snippet | **View reply / Enroll** | U | 🟠 | **BUILD** |
| 88 | `whatsapp_certificate_ready_student` *(new)* | Student | Certificate issued | Proof of completion | Course, cert id | **Download certificate** | U | 🟠 | **BUILD** |
| 89 | `whatsapp_parent_invite` *(new)* | Parent | Family link invite | Parent portal adoption | Child name | **Accept invite** | U | 🟠 | **BUILD** |
| 90 | `whatsapp_class_announcement` *(new)* | Enrolled students | Instructor announcement | Class ops broadcast | Message summary | **View announcement** | U | 🟠 | **OPTIONAL** (opt-in) |
| 91 | `whatsapp_winback_student` *(new)* | Lapsed student | Re-engage | Revenue | Last activity | **Browse classes** | M | 🟢 | **OPTIONAL** (separate M budget) |
| 92 | `whatsapp_new_class_announcement` *(new)* | Opt-in audience | Promo new batch | Marketing | Class, offer | **View class** | M | 🟢 | **OPTIONAL** (separate M budget) |

---

## K. Explicit CUT / do-not-fund on WhatsApp

| Item | Why |
|---|---|
| Session notes (all CRUD) | Private instructor notes; no student value |
| Class create/update marketplace broadcasts | Spam + Marketing cost; keep push |
| Activity / location CRUD | Instructor ops; push enough |
| Chat every message | Noise; push/in-app |
| Admin reconciliation / compensation alerts | Internal email |
| `general_message` as product notify | Not a template; unreliable outside 24h |
| Progress free-form `sendGeneralMessage` | Replace with #61–62 |

---

## L. Interactive action standard (for Meta submission)

Every **KEEP/BUILD** template must ship with:

| Pattern | Use when | Example |
|---|---|---|
| **URL button** | Deep link into app screen | Pay now, View session, Open note, Claim seat, Download certificate |
| **Quick reply** | One-tap decision | Accept new time / Suggest another · Present / Absent |
| **Auth button** (OTP) | Verification only | Copy code / open app |

If a template has **no action**, it does not qualify for this budget — rewrite or cut.

---

## M. Suggested phased budget ask (sign-off options)

### Option 1 — Core trust (recommended minimum)
Fund: Auth + Slots (19–25) + Payment confirm/fail/due + Enrollment status + Attendance Meta P0 + Progress P0 + Student note assign/parent  
**Rough template count to operate:** ~40–45 active  

### Option 2 — Full product utility
Option 1 + all payment plan templates + notes full set + tasks keep + CRM/subscription + receipt + absent parent + waitlist seat + certificate + parent invite  
**Rough template count:** ~75–85  

### Option 3 — Full + marketing
Option 2 + win-back + new-class promo (separate **Marketing** sub-budget at ₹0.863/msg)  
**Rough template count:** ~90–95  

---

## N. Sign-off checklist

| Decision | Owner | Choice |
|---|---|---|
| Budget option (1 / 2 / 3) | Stakeholder | ________ |
| Org monthly WA cap (INR) | Finance | ________ |
| Default per-instructor monthly cap (INR) | Product | ________ |
| Enable Marketing templates? | Marketing | Yes / No |
| Pause order (🟢 then 🟠; 🔴 never) | Product | Agree / Change |
| Session notes stay silent | Product | Agree |
| Progress must use Utility templates (no free-form) | Eng | Agree |

**Sign-off**

| Role | Name | Date | Signature |
|---|---|---|---|
| Product | | | |
| Engineering | | | |
| Finance / budget | | | |
| Ops / support | | | |

---

### Counts (for the cover slide)

| | Count |
|---|---|
| Catalogued in this sign-off (incl. new + optional) | **~92** |
| Recommended CUT/DEFER | **~8+** |
| Interactive (action required) | **100% of KEEP/BUILD** |
| Session notes on WA | **0** (by design) |
