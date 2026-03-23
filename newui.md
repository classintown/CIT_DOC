# Instructor UX — Brutal Reality Check
### Cross-referencing `INSTRUCTOR_UX_REQUIREMENTS.md` vs actual `cit-` component code

> **Rating key**  
> ✅ DONE — end-to-end working, real API calls, no fake data  
> ⚠️ PARTIAL — UI exists, some API, but critical pieces missing or faked  
> ❌ NOT DONE — pure mock data / zero API / no component / just UI shell

---

## Summary Scorecard

| # | Requirement Area | Status | Honest Note |
|---|---|---|---|
| 1 | Onboarding & Profile Setup | ⚠️ PARTIAL | Auth works, rest is shells |
| 2 | Class & Schedule Creation | ✅ DONE | |
| 3 | Student Management | ⚠️ PARTIAL | CSV import & archive not wired |
| 4 | Attendance Tracking | ⚠️ PARTIAL | Calendar marks, but no dedicated screen |
| 5 | Progress & Performance | ⚠️ PARTIAL | Only a number shown, no depth |
| 6 | Assignments & Grading | ❌ NOT DONE | 100% hardcoded mock data |
| 7 | Notes | ✅ DONE | |
| 8 | Payments & Revenue | ✅ DONE | |
| 9 | Messaging & Communication | ❌ NOT DONE | Zero API calls |
| 10 | Notifications | ❌ NOT DONE | No component at all |
| 11 | Calendar & Availability | ⚠️ PARTIAL | Calendar works, Google sync faked |
| 12 | Dashboard & Analytics | ⚠️ PARTIAL | KPIs real, charts fake |
| 13 | Class Materials & Resources | ❌ NOT DONE | Route exists, page does not |
| 14 | Institute Management | ❌ NOT DONE | No cit- component exists |
| 15 | Discoverability & Marketplace | ❌ NOT DONE | All hardcoded fake data |
| 16 | Account & Security | ⚠️ PARTIAL | Sign-in works, settings missing |

### Count
| | Count |
|---|---|
| ✅ FULLY DONE | **3 / 16** |
| ⚠️ PARTIAL | **6 / 16** |
| ❌ NOT DONE | **7 / 16** |

---

## Detailed Breakdown

---

### 1. 🚀 Onboarding & Profile Setup — ⚠️ PARTIAL

| Feature | Status | Evidence |
|---|---|---|
| Sign up / Sign in (email, Google, Apple) | ✅ | `cit-sign-in-card`, `cit-auth-card`, `cit-social-btn` → real API calls |
| OTP verification & phone input | ✅ | `cit-otp-input`, `cit-phone-input` → working |
| Role selector | ✅ | `cit-role-selector` → working |
| Onboarding stepper | ⚠️ | `cit-onboarding-stepper` → pure UI primitive, no API, no data |
| Profile setup form | ⚠️ | `cit-profile-setup-form` → form exists, not verified if API-connected |
| Upload certificates / credentials | ❌ | `cit-upload-zone` → pure UI component, zero API integration |
| Business profile setup | ❌ | `cit-instructor-website` → **`websiteUrl` is literally hardcoded `'classintown.com/john-doe'`**, all pages/themes/SEO scores are hardcoded arrays — zero API |
| Preview public listing | ❌ | `cit-public-website` exists but not verified to pull real data |

---

### 2. 📅 Class & Schedule Creation — ✅ DONE

| Feature | Status | Evidence |
|---|---|---|
| Create a class | ✅ | `cit-instructor-schedule-class` → 14,000+ line form with full API calls (ActivityFormService, ScheduleService, GoogleMapService, etc.) |
| Edit existing class | ✅ | `cit-instructor-classes-create-wrapper` → detects `:id` param, switches to "Edit Class" mode |
| Class listing with tabs / filters | ✅ | `cit-instructor-classes` → loads from API, filters (mode, category, status, schedule status) |
| Set location / online / Google Meet | ✅ | Present in the create form |
| Set capacity / pricing / payment plan | ✅ | Present in the create form |
| Cancel / reschedule session | ⚠️ | UI buttons exist in calendar, backend route exists, but flow needs verification |

> **Note:** The class creation component is enormous and well-built but is so large (14k lines) it is a maintainability risk.

---

### 3. 👥 Student Management — ⚠️ PARTIAL

| Feature | Status | Evidence |
|---|---|---|
| View student list | ✅ | `cit-instructor-students` → `studentService.getFilteredStudents()` — real API, paginated |
| Search & filter students | ✅ | Server-side search + tab filter (all / enrolled / prospective / archived) |
| Student statistics (counts) | ✅ | `studentService.getStudentStatistics()` — real API |
| Add student manually | ✅ | `onAddStudentSubmit()` → `studentService.createStudent()` — real API |
| Delete student | ✅ | `studentService.deleteStudent()` — real API |
| View student full profile | ✅ | `forkJoin` loading attendance + payment + progress + enrollment in parallel from real APIs |
| Bulk select + bulk delete | ✅ | Works via loop of `deleteStudent()` calls |
| **Bulk import / CSV upload** | ❌ | `confirmImport()` → **just shows a toast and navigates to list. Zero API call. Students are never actually imported.** |
| **Archive student** | ❌ | Archive tab exists. But `onBulkAction()` only handles `'delete'`, never calls an archive API. Archiving does nothing. |
| **Directly enroll student into a class** | ❌ | No enroll-to-class button / modal in `cit-instructor-students`. Student can be added but not enrolled from this page. |
| Check schedule conflicts before enrolling | ❌ | Not visible in any cit- component |

---

### 4. ✅ Attendance Tracking — ⚠️ PARTIAL

| Feature | Status | Evidence |
|---|---|---|
| View attendance per session in calendar | ✅ | `cit-instructor-calendar` loads attendees via `ClassSlotService` — real API |
| Mark attendance inside calendar detail | ⚠️ | UI for marking present/absent exists in calendar, but API persistence needs verification |
| Attendance history per student | ✅ | Student profile `Attendance` tab → `studentService.getStudentAttendanceData()` — real API |
| Attendance % automatically shown | ✅ | Shown in student profile from real API data |
| **Dedicated attendance marking screen** | ❌ | No standalone session attendance page. Marking only accessible via calendar event detail. Not obvious to find. |

---

### 5. 📊 Progress & Performance Tracking — ⚠️ PARTIAL

| Feature | Status | Evidence |
|---|---|---|
| Comprehensive progress score per student | ⚠️ | Student profile shows `completionPercentage` from `getStudentProgressData()` — real API, but just one number |
| Breakdown (attendance 40% / assignments 30% / performance 20%) | ❌ | Number shown but the breakdown is not displayed to the instructor in the UI |
| Custom performance metrics | ❌ | No UI for creating or viewing custom metrics in any cit- component |
| Progress trends over time | ❌ | No chart or trend line in any component |
| Compare students side by side | ❌ | Not present anywhere |
| Export / download progress report | ❌ | Not present in any component |

---

### 6. 📝 Assignments & Grading — ❌ NOT DONE

| Feature | Status | Evidence |
|---|---|---|
| Create assignments | ❌ | No assignment creation modal/form in any cit- component |
| View submitted assignments | ❌ | `allTasks` in `cit-instructor-students` is **fully hardcoded mock data** (hardcoded Photography task with hardcoded student "Olivia Carter") |
| Grade submissions / give feedback | ❌ | `saveFeedback()` only updates local in-memory array — **zero API call** |
| See graded vs ungraded at a glance | ❌ | Only works on the mock local data |
| Assessment scores update progress | ❌ | Backend supports it, frontend never calls it |
| Assignment priority levels | ❌ | Not present |

> **Blunt truth:** The entire Assignments & Grading area is a UI mockup. It looks like it works but is completely disconnected from the backend.

---

### 7. 🗒️ Notes — ✅ DONE

| Feature | Status | Evidence |
|---|---|---|
| Create student note | ✅ | `submitStudentNote()` → `studentService.createStudentNote()` — real API |
| Create session note | ✅ | `submitSessionNote()` → `studentService.createSessionNote()` — real API |
| Edit note | ✅ | `studentService.updateNote()` — real API |
| Delete note | ✅ | `studentService.deleteNote()` — real API |
| Archive note | ✅ | `studentService.archiveNote()` — real API |
| Filter notes (all / student / session) | ✅ | Client-side filter on loaded data |
| Notify students on new note | ⚠️ | `notify_recipients` field sent in payload; backend handles it but not verified end-to-end |
| Label notes | ✅ | Labels sent in API payload |

---

### 8. 💰 Payments & Revenue — ✅ DONE

| Feature | Status | Evidence |
|---|---|---|
| View payment stats (total, pending, overdue) | ✅ | `cit-payment` → `loadDashboardStats()` via `EnhancedPaymentsService` — real API |
| View full payment list with filters | ✅ | `loadPayments()` — real API, paginated |
| View pending payments | ✅ | `loadPendingPayments()` — real API |
| Verify / confirm a payment | ✅ | `verifyPaymentAsInstructor()` — real API, in both dashboard and payment page |
| Add payment manually | ✅ | `addPayment` form with student typeahead — API-connected |
| Request payment from student | ✅ | `reqPayment` form — API-connected |
| Dashboard pending payments count + amount | ✅ | Real API in `cit-instructor-dashboard-v2` |
| **Revenue chart** | ❌ | `cit-instr-dash-revenue` has **hardcoded chart data `[95, 150, 175, 230, 285...]`**. Dashboard loads revenue API but only `console.log`'s it — never passed to the chart. |
| Download receipts | ⚠️ | Backend generates receipts; no download button verified in cit- components |

---

### 9. 💬 Messaging & Communication — ❌ NOT DONE

| Feature | Status | Evidence |
|---|---|---|
| Chat with individual students | ❌ | `cit-instr-comm` — **zero service injection, zero HTTP calls** |
| Send group message / announcement | ❌ | `submitAnnouncement()` just clears the form fields. Nothing is saved or sent. |
| Receive & reply to inquiries | ❌ | Not present |
| Real-time message notifications | ❌ | Not present |
| Message history | ❌ | All message lists are hardcoded |

> **Blunt truth:** `cit-instr-comm` is a complete UI mockup. The entire communications section is non-functional.

---

### 10. 🔔 Notifications — ❌ NOT DONE

| Feature | Status | Evidence |
|---|---|---|
| Send push notifications to students | ❌ | No component in cit- set for this |
| Notification center / inbox | ❌ | Topbar has a bell icon but no notification list/panel component exists |
| Receive notifications (enrollment, payment, etc.) | ❌ | Not wired to any cit- component |
| WhatsApp / Email triggered notifications | ⚠️ | Backend sends them, but instructor cannot see delivery status in the UI |
| Notification delivery tracking | ❌ | Not present |

---

### 11. 🗓️ Calendar & Availability — ⚠️ PARTIAL

| Feature | Status | Evidence |
|---|---|---|
| Visual calendar of sessions | ✅ | `cit-instructor-calendar` → `ClassSlotService.getUpcomingSlots()` — real API, month/week/day views |
| Attendance marking from calendar | ⚠️ | UI exists in event detail, API call not verified |
| Google Calendar sync UI | ⚠️ | Settings page exists with toggle, but `connected: false` is **hardcoded**. No OAuth flow for calendar. |
| Google Meet link on sessions | ✅ | Shown in calendar events from API data |
| **Set weekly availability** | ❌ | Backend `availability.routes.js` exists, but no dedicated cit- availability page/component |
| Conflict detection | ❌ | Backend does it; not surfaced in any cit- component |

---

### 12. 📈 Dashboard & Analytics — ⚠️ PARTIAL

| Feature | Status | Evidence |
|---|---|---|
| Total students KPI | ✅ | `studentService.getStudentCount()` — real API |
| Monthly revenue KPI | ✅ | `paymentService.getMonthlyRevenue()` — real API |
| Upcoming classes this week KPI | ✅ | `scheduleService.getInstructorClassCountThisWeek()` — real API |
| Pending payments KPI (count + amount) | ✅ | `enhancedPaymentsService.getPendingPayments()` — real API |
| Recent enrollments list | ✅ | Enrollment API — real |
| Upcoming classes list with attendees | ✅ | `classSlotService.getUpcomingSlots()` — real API |
| **Revenue analytics chart** | ❌ | API called, data only `console.log`'d. Chart (`cit-instr-dash-revenue`) renders **hardcoded dummy numbers** `[95, 150, 175, 230, 285, 360, 415, 458, 475]` |
| **Reports page** | ❌ | `cit-instructor-reports` — `revenue = '₹8,25,000'` hardcoded. All report items, export history, and scheduled reports are **static hardcoded arrays**. Zero API. |
| Performance distribution (excellent/good/fair/poor) | ❌ | Backend calculates it, no cit- component shows it |
| Listing analytics (views, leads per class) | ❌ | `cit-listing` shows fake hardcoded view/lead counts |

---

### 13. 📚 Class Materials & Resources — ❌ NOT DONE

| Feature | Status | Evidence |
|---|---|---|
| Upload materials per class / session | ❌ | `cit-upload-zone` is a pure UI primitive with no API integration |
| View/manage uploaded materials | ❌ | Route `/instructor/dashboard/resources` is in the sidebar nav, but **no dedicated cit- page component exists** for it |
| Students access materials | ❌ | Not present on instructor side |

---

### 14. 🏛️ Institute / Organisation Management — ❌ NOT DONE

| Feature | Status | Evidence |
|---|---|---|
| Manage instructors under institute | ❌ | No cit- component for this |
| Shared student pool view | ❌ | Not present |
| Institute-branded classes | ❌ | Not surfaced in any cit- component |

---

### 15. 🌍 Discoverability & Marketplace — ❌ NOT DONE

| Feature | Status | Evidence |
|---|---|---|
| View/manage public listing | ❌ | `cit-listing` → all `views`, `leads`, `ActiveListingRow` data is **hardcoded mock**. No API. |
| Instructor website / public profile editor | ❌ | `cit-instructor-website` → `websiteUrl = 'classintown.com/john-doe'` hardcoded. Pages, themes, SEO scores — **100% fake data, zero API** |
| Inquiry management | ❌ | `cit-enquiry-card` is a display primitive; no inquiry list page in cit- set |

---

### 16. 🔐 Account & Security — ⚠️ PARTIAL

| Feature | Status | Evidence |
|---|---|---|
| Secure sign-in with session | ✅ | `cit-sign-in-card`, `cit-auth-card` — working |
| Google / Apple sign-in | ✅ | `cit-social-btn` — working |
| Phone verification with country code | ✅ | `cit-phone-input`, `cit-otp-input` — working |
| Role-based routing | ✅ | Working |
| **Change password** | ❌ | No cit- component or page for account settings |
| **Link / unlink social accounts** | ❌ | No account management page in cit- set |
| **Auto-logout on inactivity** | ⚠️ | Backend has session timeout logic; UI handling not verified in cit- components |

---

## The 3 Things Fully Done

1. **Class creation & editing** — solid, deeply API-connected
2. **Notes (student + session)** — full CRUD with real API
3. **Payments page** — list, pending, verify, add, request — all real API

## The 7 Most Critical Gaps

| Priority | Gap | Impact |
|---|---|---|
| 🔴 1 | Messaging is a dummy UI | Instructors cannot communicate with students at all |
| 🔴 2 | Assignments are hardcoded mock | Core teaching feature is completely fake |
| 🔴 3 | Revenue chart shows fake numbers | Instructor sees wrong financial picture |
| 🔴 4 | Reports page is 100% fake | Instructor cannot generate or export any real report |
| 🔴 5 | Bulk CSV import silently fails | Instructor adds 50 students, nothing happens |
| 🟠 6 | No notification center | Instructor never knows when a student enrolled or paid |
| 🟠 7 | No resources/materials page | Class materials feature is completely absent |
