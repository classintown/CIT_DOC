# 🎯 ClassInTown - Comprehensive Testing Estimation
### Complete Feature Coverage Testing Plan

> **Goal:** Test EVERY feature to the bone. Zero bugs across Frontend, Backend, Database.

---

## 📊 Testing Scope Overview

| Category | Features | Test Cases | Estimated Hours |
|----------|----------|------------|-----------------|
| **1. Authentication & Authorization** | 5 | 403 | 140h |
| **2. Class Management (Core)** | 8 | 450 | 200h |
| **3. Student Management** | 6 | 210 | 100h |
| **4. Payment Management** | 8 | 280 | 140h |
| **5. Calendar & Scheduling** | 6 | 250 | 120h |
| **6. Communications** | 5 | 180 | 85h |
| **7. Listings** | 4 | 140 | 70h |
| **8. Reports & Analytics** | 5 | 170 | 85h |
| **9. Resources & Materials** | 5 | 170 | 85h |
| **10. Business Profile** | 3 | 100 | 50h |
| **11. Support & Help** | 3 | 70 | 35h |
| **12. Load Testing** | - | 80 | 100h |
| **13. Database Testing** | - | 120 | 70h |
| **14. Google Integration Testing** | - | 150 | 80h |
| **TOTAL** | **58 Features** | **2,773 Test Cases** | **1,360 Hours** |

**Team Size:** 4 QA Engineers (1 Senior + 2 Mid + 1 Junior)  
**Timeline:** ~17 weeks (4.2 months) of rigorous testing  
**Cost:** ~$68,000 USD (@ $50/hour)

---

## 🔐 1. AUTHENTICATION & AUTHORIZATION (Security)

> **PRIMARY METHODS:** Google OAuth (70%) + Mobile OTP (25%)  
> **BACKUP METHOD:** Email/Password (5%)

### 1.1 🌟 Google OAuth (PRIMARY - 70% of users)

#### Unit Tests - Frontend (Angular)
| Component/Service | Test Scenario | Frontend | Backend | Database | Priority |
|-------------------|---------------|----------|---------|----------|----------|
| `google-oauth.component.ts` | Google Sign-in button render | ✓ | | | HIGH |
| `google-oauth.component.ts` | Click → Open Google consent | ✓ | | | HIGH |
| `google-oauth.component.ts` | Handle OAuth redirect callback | ✓ | | | HIGH |
| `google-oauth.service.ts` | Receive Google ID token | ✓ | | | HIGH |
| `google-oauth.service.ts` | Validate token client-side | ✓ | | | HIGH |
| `google-oauth.service.ts` | Send token to backend | ✓ | | | HIGH |
| `google-oauth.service.ts` | Store JWT in localStorage | ✓ | | | HIGH |
| `google-oauth.service.ts` | Store user profile data | ✓ | | | HIGH |
| `google-oauth.service.ts` | Store Google refresh token | ✓ | | | HIGH |
| `auth.service.ts` | Handle Google login success | ✓ | | | HIGH |
| `auth.service.ts` | Redirect to role dashboard | ✓ | | | HIGH |
| `auth.service.ts` | Handle Google scope denial | ✓ | | | HIGH |
| `auth.service.ts` | Handle network errors | ✓ | | | MEDIUM |

#### Unit Tests - Backend (Node.js)
| Controller/Service | Test Scenario | Frontend | Backend | Database | Priority |
|-------------------|---------------|----------|---------|----------|----------|
| `auth.controller.js` | Receive Google ID token | | ✓ | | HIGH |
| `auth.controller.js` | Verify Google token with Google API | | ✓ | | HIGH |
| `auth.controller.js` | Extract user email from token | | ✓ | | HIGH |
| `auth.controller.js` | Extract user name from token | | ✓ | | HIGH |
| `auth.controller.js` | Extract Google profile picture | | ✓ | | HIGH |
| `auth.controller.js` | Check if user exists in DB | | ✓ | ✓ | HIGH |
| `auth.controller.js` | Create new user if first-time | | ✓ | ✓ | HIGH |
| `auth.controller.js` | Link Google account to existing user | | ✓ | ✓ | HIGH |
| `auth.controller.js` | Store Google access token | | ✓ | ✓ | HIGH |
| `auth.controller.js` | Store Google refresh token | | ✓ | ✓ | HIGH |
| `auth.controller.js` | Generate ClassInTown JWT token | | ✓ | | HIGH |
| `auth.controller.js` | Return user role & permissions | | ✓ | ✓ | HIGH |
| `auth.controller.js` | Check Google Calendar scope | | ✓ | ✓ | HIGH |
| `auth.controller.js` | Handle revoked Google access | | ✓ | ✓ | MEDIUM |
| `auth.controller.js` | Handle expired Google token | | ✓ | ✓ | HIGH |
| `auth.controller.js` | Refresh Google token | | ✓ | ✓ | HIGH |
| `auth.controller.js` | Rate limiting (10 requests/minute) | | ✓ | | MEDIUM |
| `session.service.js` | Create session with Google metadata | | ✓ | ✓ | HIGH |
| `session.service.js` | Update last login timestamp | | ✓ | ✓ | MEDIUM |
| `google-calendar.service.js` | Sync user events on first login | | ✓ | ✓ | HIGH |

#### Integration Tests
| Scenario | Description | Tests | Priority |
|----------|-------------|-------|----------|
| First-time Google Login | Google OAuth → Create account → Onboarding | 10 | HIGH |
| Returning User Google Login | Google OAuth → JWT → Dashboard | 8 | HIGH |
| Google token validation | Backend verifies token with Google API | 8 | HIGH |
| Account linking | Link Google to existing email account | 8 | HIGH |
| Calendar scope granted | User grants calendar access → Sync enabled | 10 | HIGH |
| Calendar scope denied | User denies calendar → Continue without sync | 6 | MEDIUM |
| Token refresh | Expired token → Auto-refresh → Continue | 8 | HIGH |
| Revoked access | User revokes from Google → Re-authenticate | 6 | MEDIUM |
| Multiple devices | Same Google account on 3 devices | 8 | HIGH |
| Role-based redirect | Instructor/Student/Admin → Correct dashboard | 8 | HIGH |

#### E2E Tests (Playwright)
| User Journey | Steps | Tests | Priority |
|--------------|-------|-------|----------|
| 🔥 Instructor Google Sign-in (New) | Click Google → Consent → Onboarding → Dashboard | 8 | CRITICAL |
| 🔥 Instructor Google Sign-in (Returning) | Click Google → Auto-login → Dashboard | 5 | CRITICAL |
| 🔥 Student Google Sign-in (New) | Click Google → Consent → Browse classes | 8 | CRITICAL |
| 🔥 Student Google Sign-in (Returning) | Click Google → Auto-login → Browse | 5 | CRITICAL |
| Admin Google Sign-in | Click Google → Admin panel | 5 | HIGH |
| Google Calendar Sync | Login → Grant scope → Events sync | 10 | HIGH |
| Switch accounts | Logout → Login with different Google account | 6 | MEDIUM |
| Session persistence | Close browser → Reopen → Still logged in | 5 | HIGH |

**Sub-Total:** **120 test cases (Google OAuth)**

---

### 1.2 🌟 Mobile OTP Login (SECONDARY - 25% of users)

#### Unit Tests - Frontend (Angular)
| Component/Service | Test Scenario | Frontend | Backend | Database | Priority |
|-------------------|---------------|----------|---------|----------|----------|
| `mobile-login.component.ts` | Country code dropdown (India +91) | ✓ | | | HIGH |
| `mobile-login.component.ts` | Mobile number validation (10 digits) | ✓ | | | HIGH |
| `mobile-login.component.ts` | Mobile format validation | ✓ | | | HIGH |
| `mobile-login.component.ts` | Send OTP button enabled/disabled | ✓ | | | HIGH |
| `mobile-login.component.ts` | OTP sent success message | ✓ | | | MEDIUM |
| `mobile-login.component.ts` | OTP input field (6 digits) | ✓ | | | HIGH |
| `mobile-login.component.ts` | Auto-focus on OTP fields | ✓ | | | LOW |
| `mobile-login.component.ts` | Resend OTP button (60s timer) | ✓ | | | HIGH |
| `mobile-login.component.ts` | Verify OTP button click | ✓ | | | HIGH |
| `auth.service.ts` | POST /api/auth/send-otp | ✓ | | | HIGH |
| `auth.service.ts` | POST /api/auth/verify-otp | ✓ | | | HIGH |
| `auth.service.ts` | Store JWT from OTP login | ✓ | | | HIGH |

#### Unit Tests - Backend (Node.js)
| Controller/Service | Test Scenario | Frontend | Backend | Database | Priority |
|-------------------|---------------|----------|---------|----------|----------|
| `auth.controller.js` | Validate mobile number format | | ✓ | | HIGH |
| `auth.controller.js` | Check mobile exists in DB | | ✓ | ✓ | HIGH |
| `auth.controller.js` | Generate random 6-digit OTP | | ✓ | | HIGH |
| `auth.controller.js` | Send SMS via gateway (India) | | ✓ | | HIGH |
| `auth.controller.js` | Send SMS via gateway (Global) | | ✓ | | MEDIUM |
| `auth.controller.js` | Store OTP in DB with 5 min expiry | | ✓ | ✓ | HIGH |
| `auth.controller.js` | Hash OTP before storing | | ✓ | | MEDIUM |
| `auth.controller.js` | Rate limit (3 OTP/hour per mobile) | | ✓ | | HIGH |
| `auth.controller.js` | Verify OTP match | | ✓ | ✓ | HIGH |
| `auth.controller.js` | Check OTP not expired | | ✓ | ✓ | HIGH |
| `auth.controller.js` | Invalidate OTP after successful use | | ✓ | ✓ | HIGH |
| `auth.controller.js` | Block after 3 wrong attempts | | ✓ | ✓ | HIGH |
| `auth.controller.js` | Generate JWT after OTP verify | | ✓ | | HIGH |
| `auth.controller.js` | Create user if first-time mobile | | ✓ | ✓ | HIGH |
| `auth.controller.js` | Link mobile to existing user | | ✓ | ✓ | MEDIUM |
| `session.service.js` | Create session with mobile data | | ✓ | ✓ | HIGH |
| `sms.service.js` | SMS delivery confirmation | | ✓ | | MEDIUM |

#### Integration Tests
| Scenario | Description | Tests | Priority |
|----------|-------------|-------|----------|
| OTP Send → Verify → Login Success | Complete OTP flow | 10 | HIGH |
| First-time Mobile Login | OTP → Create account → Onboarding | 8 | HIGH |
| Returning Mobile Login | OTP → Dashboard | 6 | HIGH |
| OTP Expired (5 min) | Send OTP → Wait → Verify → Error | 6 | HIGH |
| Wrong OTP 3 times | Wrong OTP → Block account | 8 | HIGH |
| Resend OTP | Send → Resend → New OTP works | 6 | MEDIUM |
| Rate limiting | 4th OTP request → Blocked | 6 | MEDIUM |
| Link mobile to Google account | OTP login → Link to Google user | 8 | HIGH |

#### E2E Tests (Playwright)
| User Journey | Steps | Tests | Priority |
|--------------|-------|-------|----------|
| 🔥 Instructor OTP Login (New) | Enter mobile → OTP → Onboarding | 6 | HIGH |
| 🔥 Instructor OTP Login (Returning) | Enter mobile → OTP → Dashboard | 5 | HIGH |
| 🔥 Student OTP Login (New) | Enter mobile → OTP → Browse classes | 6 | HIGH |
| Student OTP Login (Returning) | Enter mobile → OTP → Dashboard | 5 | HIGH |
| OTP Resend Flow | Send → Resend → Verify with new OTP | 5 | MEDIUM |
| Wrong OTP Error | Enter wrong OTP → Error shown | 4 | MEDIUM |

**Sub-Total:** **70 test cases (Mobile OTP)**

---

### 1.3 Google OAuth + Calendar Integration Testing

> **Critical:** Most features depend on Google authentication and Calendar sync

#### Calendar Sync Tests (Post-Authentication)
| Test Scenario | Frontend | Backend | Database | Priority |
|---------------|----------|---------|----------|----------|
| Check if Calendar scope granted | ✓ | ✓ | ✓ | HIGH |
| Sync classes to Google Calendar | | ✓ | ✓ | HIGH |
| Sync Google events to ClassInTown | | ✓ | ✓ | HIGH |
| Two-way sync (create/update/delete) | | ✓ | ✓ | HIGH |
| Handle sync conflicts | | ✓ | ✓ | HIGH |
| Retry failed syncs | | ✓ | ✓ | MEDIUM |
| Rate limit Google API calls | | ✓ | | HIGH |
| Handle API quota exceeded | | ✓ | | MEDIUM |
| Re-request scope if denied initially | ✓ | ✓ | ✓ | HIGH |

#### Google Token Management Tests
| Test Scenario | Frontend | Backend | Database | Priority |
|---------------|----------|---------|----------|----------|
| Store access token securely | | ✓ | ✓ | HIGH |
| Store refresh token securely | | ✓ | ✓ | HIGH |
| Auto-refresh expired access token | | ✓ | ✓ | HIGH |
| Handle token revoked by user | | ✓ | ✓ | HIGH |
| Re-authenticate on token invalid | ✓ | ✓ | | HIGH |
| Token encryption at rest | | | ✓ | MEDIUM |

#### Integration Tests (Google-based Auth)
| Scenario | Description | Tests | Priority |
|----------|-------------|-------|----------|
| 🔥 Google Login → Create Class → Calendar Sync | End-to-end flow | 15 | CRITICAL |
| 🔥 Google Login → Enroll Student → Notification | Full enrollment | 12 | CRITICAL |
| 🔥 Google Login → Schedule Class → Email Sent | Complete scheduling | 12 | CRITICAL |
| Google token in all API calls | Every API validates Google JWT | 20 | HIGH |
| Token expiry → Auto-refresh → Continue | Seamless token refresh | 8 | HIGH |
| Multiple sessions with same Google account | 3 devices, 1 account | 10 | HIGH |

**Sub-Total:** **77 test cases (Google Integration)**

---

### 1.4 Email/Password Login (BACKUP - 5% of users)

> **Note:** Minimal testing, backup method only

#### Basic Tests
| Test Scenario | Tests | Priority |
|---------------|-------|----------|
| Email/password validation | 10 | LOW |
| Login success → Dashboard | 8 | LOW |
| Forgot password flow | 10 | LOW |
| Reset password | 8 | LOW |

**Sub-Total:** **36 test cases (Email/Password - Backup)**

---

### 1.5 Session Management (All Auth Methods)

#### Unit Tests - Frontend
| Test Scenario | Tests | Priority |
|---------------|-------|----------|
| Check Google token on page load | 5 | HIGH |
| Auto-logout on token expiry | 5 | HIGH |
| Warning before session expires (5 min) | 5 | MEDIUM |
| Refresh Google token before expiry | 8 | HIGH |
| Store user role from Google token | 5 | HIGH |
| Persist session across tabs | 5 | MEDIUM |

#### Unit Tests - Backend
| Test Scenario | Tests | Priority |
|---------------|-------|----------|
| Validate Google JWT on each request | 10 | HIGH |
| Check token expiry (24 hours) | 8 | HIGH |
| Invalidate session on logout | 8 | HIGH |
| Handle multiple active sessions | 10 | HIGH |
| Session cleanup (delete old sessions) | 5 | LOW |

#### Integration Tests
| Scenario | Tests | Priority |
|----------|-------|----------|
| Session persistence across devices | 10 | HIGH |
| Concurrent sessions (same user) | 8 | HIGH |
| Force logout from all devices | 8 | MEDIUM |

**Sub-Total:** **100 test cases (Session Management)**

---

## 🔐 AUTHENTICATION TESTING SUMMARY

| Auth Method | Test Cases | Priority | % of Users |
|-------------|------------|----------|------------|
| 🔥 **Google OAuth** | 120 | CRITICAL | 70% |
| 🔥 **Mobile OTP** | 70 | HIGH | 25% |
| **Google Integration** | 77 | CRITICAL | - |
| **Session Management** | 100 | HIGH | 100% |
| **Email/Password (Backup)** | 36 | LOW | 5% |
| **TOTAL** | **403 test cases** | - | - |

### Updated Timeline for Auth Testing
- **Week 1:** Google OAuth (Frontend + Backend) - 40h
- **Week 2:** Mobile OTP + Google Integration - 40h
- **Week 3:** Session Management + E2E flows - 40h
- **Week 4:** Bug fixes + Regression - 20h

**Total Auth Testing:** 140 hours (vs previous 80h)

---

## 🔐 DOWNSTREAM TESTING (Based on Google Token)

> **Important:** ALL features now assume Google OAuth as primary authentication

### How Google Token Affects Other Modules

| Module | Google Token Usage | Additional Tests |
|--------|-------------------|------------------|
| **Class Management** | Token in Authorization header | 20 |
| **Student Management** | User ID from Google token | 15 |
| **Payment Management** | Email from Google token | 15 |
| **Calendar Sync** | Google Calendar API with token | 30 |
| **Communications** | User profile from Google | 10 |
| **Reports** | User permissions from Google | 10 |

**Total Additional Tests:** 100 test cases

---

## 📚 2. CLASS MANAGEMENT (Core Feature - Scheduling)

> **Auth Dependency:** All operations require valid Google token

### 2.1 Duration-based Scheduling

> **Auth Check:** Every test must validate Google token first

#### Unit Tests - Frontend
| Component | Test Scenario | Tests | Auth Check |
|-----------|---------------|-------|------------|
| `instructor-schedule-class.component.ts` | Verify Google token on component init | 5 | ✓ |
| `instructor-schedule-class.component.ts` | Select start date/time | 5 | ✓ |
| `instructor-schedule-class.component.ts` | Select duration (30 min - 4 hours) | 8 | ✓ |
| `instructor-schedule-class.component.ts` | Calculate end time automatically | 5 | - |
| `instructor-schedule-class.component.ts` | Validate past date selection | 5 | - |
| `instructor-schedule-class.component.ts` | Show duration dropdown | 5 | - |
| `instructor-schedule-class.component.ts` | Redirect to login if token invalid | 5 | ✓ |

#### Unit Tests - Backend
| Controller/Service | Test Scenario | Tests | Auth Check |
|-------------------|---------------|-------|------------|
| `class.controller.js` | Validate Google JWT in header | 10 | ✓ |
| `class.controller.js` | Extract instructor ID from token | 5 | ✓ |
| `class.controller.js` | Create class with duration | 10 | ✓ |
| `class.controller.js` | Calculate end time from start + duration | 5 | - |
| `class.controller.js` | Validate duration range | 5 | - |
| `class.service.js` | Save class to database | 8 | ✓ |
| `class.service.js` | Generate class unique ID | 5 | - |
| `google-calendar.service.js` | 🔥 Sync class to Google Calendar | 15 | ✓ |
| `google-calendar.service.js` | 🔥 Handle calendar sync failure | 8 | ✓ |

#### Integration Tests
| Scenario | Tests | Auth Check |
|----------|-------|------------|
| 🔥 Google Login → Create class → Save DB → Sync Calendar | 20 | ✓ |
| Create class → Send notification → Email sent | 10 | ✓ |
| Token expired during creation → Refresh → Continue | 10 | ✓ |

**Sub-Total:** **144 test cases (up from ~40)**

---

### 2.2 Count-based Scheduling

#### Tests
| Scenario | Frontend | Backend | Database | Total |
|----------|----------|---------|----------|-------|
| Select number of classes (1-100) | 5 | 5 | 3 | 13 |
| Calculate total price (count × price) | 5 | 5 | 2 | 12 |
| Create multiple class instances | 0 | 10 | 5 | 15 |

---

### 2.3 Edit/Delete Classes

#### Tests
| Scenario | Frontend | Backend | Database | Total |
|----------|----------|---------|----------|-------|
| Edit class details | 8 | 10 | 5 | 23 |
| Delete single class | 5 | 8 | 5 | 18 |
| Delete recurring classes | 5 | 10 | 8 | 23 |
| Notify enrolled students on change | 0 | 10 | 5 | 15 |

---

### 2.4 Availability Conflict Detection

#### Tests
| Scenario | Frontend | Backend | Database | Total |
|----------|----------|---------|----------|-------|
| Detect instructor double-booking | 10 | 15 | 10 | 35 |
| Detect venue double-booking | 8 | 12 | 8 | 28 |
| Show conflict warning | 5 | 0 | 0 | 5 |
| Prevent conflicting class creation | 5 | 10 | 5 | 20 |

---

### 2.5 Online vs In-person Classes

#### Tests
| Scenario | Frontend | Backend | Database | Total |
|----------|----------|---------|----------|-------|
| Select class mode (online/in-person) | 5 | 5 | 3 | 13 |
| Show meeting link for online | 8 | 8 | 5 | 21 |
| Show venue for in-person | 8 | 8 | 5 | 21 |
| Hybrid mode support | 10 | 10 | 5 | 25 |

---

### 2.6 Continuous Class Mode

#### Tests
| Scenario | Tests |
|----------|-------|
| Create open-ended class | 15 |
| Enroll students anytime | 15 |
| Track progress without end date | 20 |

---

### 2.7 Payment Plan Setup

#### Tests
| Scenario | Tests |
|----------|-------|
| Set one-time payment | 10 |
| Set installment plan | 20 |
| Set per-class payment | 15 |
| Custom payment plan | 15 |

---

**Class Management Total:** 320 test cases

---

## 👥 3. STUDENT MANAGEMENT (Learners)

### 3.1 Student CRUD Operations

#### Unit Tests
| Operation | Frontend | Backend | Database | Total |
|-----------|----------|---------|----------|-------|
| Create student | 10 | 15 | 10 | 35 |
| Read student details | 5 | 8 | 5 | 18 |
| Update student info | 10 | 12 | 8 | 30 |
| Delete student | 8 | 10 | 10 | 28 |

---

### 3.2 Bulk Import

#### Tests
| Scenario | Frontend | Backend | Database | Total |
|----------|----------|---------|----------|-------|
| Upload CSV file | 5 | 10 | 0 | 15 |
| Validate CSV format | 10 | 15 | 0 | 25 |
| Import 100 students | 0 | 10 | 15 | 25 |
| Handle duplicate emails | 5 | 10 | 8 | 23 |
| Show import errors | 5 | 0 | 0 | 5 |

---

### 3.3 Progress Tracking

#### Tests
| Scenario | Tests |
|----------|-------|
| Track attendance | 20 |
| Track assignments completed | 20 |
| Calculate progress percentage | 15 |
| Show progress dashboard | 15 |

---

### 3.4 Attendance Management

#### Tests
| Scenario | Tests |
|----------|-------|
| Mark present/absent | 15 |
| Bulk attendance marking | 15 |
| Attendance reports | 10 |

---

### 3.5 Grading & Assessment

#### Tests
| Scenario | Tests |
|----------|-------|
| Enter grades | 15 |
| Calculate GPA | 10 |
| Grade reports | 10 |

---

### 3.6 Student Notes

#### Tests
| Scenario | Tests |
|----------|-------|
| Add notes per student | 10 |
| Edit/Delete notes | 10 |
| View note history | 10 |

---

**Student Management Total:** 180 test cases

---

## 💳 4. PAYMENT MANAGEMENT (Billing)

### 4.1 Payment List & Filtering

#### Tests
| Scenario | Frontend | Backend | Database | Total |
|----------|----------|---------|----------|-------|
| List all payments | 5 | 8 | 5 | 18 |
| Filter by date range | 8 | 10 | 5 | 23 |
| Filter by status | 5 | 8 | 5 | 18 |
| Filter by student | 5 | 8 | 5 | 18 |

---

### 4.2 Payment Verification

#### Tests
| Scenario | Tests |
|----------|-------|
| Verify Razorpay payment signature | 15 |
| Verify payment status | 10 |
| Handle payment failure | 15 |
| Handle payment pending | 10 |

---

### 4.3 Bulk Verification

#### Tests
| Scenario | Tests |
|----------|-------|
| Verify multiple payments | 15 |
| Export verification report | 10 |

---

### 4.4 Receipt Generation

#### Tests
| Scenario | Tests |
|----------|-------|
| Generate PDF receipt | 15 |
| Email receipt to student | 15 |
| Download receipt | 10 |

---

### 4.5 Payment Analytics

#### Tests
| Scenario | Tests |
|----------|-------|
| Revenue dashboard | 20 |
| Payment trends | 15 |
| Outstanding payments | 15 |

---

### 4.6 Export Functionality

#### Tests
| Scenario | Tests |
|----------|-------|
| Export to Excel | 10 |
| Export to CSV | 10 |
| Export to PDF | 10 |

---

### 4.7 Refund Processing

#### Tests
| Scenario | Tests |
|----------|-------|
| Initiate refund | 15 |
| Process refund via Razorpay | 20 |
| Refund status tracking | 15 |

---

**Payment Management Total:** 240 test cases

---

## 📅 5. CALENDAR & SCHEDULING (Time)

### 5.1 Calendar Views

#### Tests
| View Type | Tests |
|-----------|-------|
| Day view | 8 |
| Week view | 10 |
| Month view | 10 |
| Agenda view | 8 |

---

### 5.2 Event Management

#### Tests
| Scenario | Tests |
|----------|-------|
| Create event | 15 |
| Edit event | 15 |
| Delete event | 10 |
| Drag & drop to reschedule | 15 |

---

### 5.3 Recurring Events

#### Tests
| Scenario | Tests |
|----------|-------|
| Daily recurring | 10 |
| Weekly recurring | 10 |
| Monthly recurring | 10 |
| Custom recurring pattern | 15 |

---

### 5.4 Google Calendar Integration

#### Tests
| Scenario | Tests |
|----------|-------|
| Sync to Google Calendar | 20 |
| Two-way sync | 20 |
| Handle sync conflicts | 15 |

---

### 5.5 Availability Management

#### Tests
| Scenario | Tests |
|----------|-------|
| Set available time slots | 15 |
| Block time slots | 10 |
| Show availability to students | 10 |

---

### 5.6 Reminders

#### Tests
| Scenario | Tests |
|----------|-------|
| Email reminders (24h before) | 15 |
| SMS reminders | 10 |
| Push notification reminders | 10 |

---

**Calendar & Scheduling Total:** 180 test cases

---

## 💬 6. COMMUNICATIONS (Messaging)

### 6.1 Real-time Chat

#### Tests
| Scenario | Frontend | Backend | Database | Total |
|----------|----------|---------|----------|-------|
| Send message (Socket.io) | 10 | 15 | 10 | 35 |
| Receive message in real-time | 10 | 15 | 5 | 30 |
| Message delivery status | 8 | 10 | 5 | 23 |
| Typing indicator | 5 | 5 | 0 | 10 |

---

### 6.2 Direct Messages

#### Tests
| Scenario | Tests |
|----------|-------|
| Send 1-on-1 message | 15 |
| Message history | 10 |
| Search messages | 10 |

---

### 6.3 Announcements

#### Tests
| Scenario | Tests |
|----------|-------|
| Create announcement | 15 |
| Send to all students | 15 |
| Send to specific class | 10 |

---

### 6.4 Forum Discussions

#### Tests
| Scenario | Tests |
|----------|-------|
| Create forum thread | 10 |
| Reply to thread | 10 |
| Upvote/Downvote | 5 |

---

### 6.5 Notifications

#### Tests
| Scenario | Tests |
|----------|-------|
| Push notifications (OneSignal) | 20 |
| Email notifications | 15 |
| In-app notifications | 15 |

---

**Communications Total:** 150 test cases

---

## 📋 7. LISTINGS (Source)

### 7.1 Activities

#### Tests
| Scenario | Tests |
|----------|-------|
| Create activity | 15 |
| Edit activity | 10 |
| Delete activity | 10 |
| List all activities | 10 |

---

### 7.2 Venues

#### Tests
| Scenario | Tests |
|----------|-------|
| Add venue | 15 |
| Edit venue | 10 |
| Google Maps integration | 15 |

---

### 7.3 Enrollments

#### Tests
| Scenario | Tests |
|----------|-------|
| View enrollments per class | 15 |
| Enrollment status tracking | 10 |

---

### 7.4 Payment Plan

#### Tests
| Scenario | Tests |
|----------|-------|
| View payment plans | 10 |
| Edit payment plans | 10 |

---

**Listings Total:** 120 test cases

---

## 📊 8. REPORTS & ANALYTICS (Insights)

### 8.1 Performance Dashboard

#### Tests
| Scenario | Tests |
|----------|-------|
| Instructor performance metrics | 20 |
| Student engagement metrics | 20 |
| Revenue metrics | 20 |

---

### 8.2 Revenue Analytics

#### Tests
| Scenario | Tests |
|----------|-------|
| Total revenue chart | 15 |
| Revenue by class | 15 |
| Revenue forecasting | 10 |

---

### 8.3 Student Analytics

#### Tests
| Scenario | Tests |
|----------|-------|
| Student retention rate | 15 |
| Student attendance trends | 15 |

---

### 8.4 Attendance Reports

#### Tests
| Scenario | Tests |
|----------|-------|
| Class-wise attendance | 10 |
| Student-wise attendance | 10 |

---

### 8.5 Custom Reports

#### Tests
| Scenario | Tests |
|----------|-------|
| Create custom report | 15 |
| Export custom report | 10 |

---

**Reports & Analytics Total:** 150 test cases

---

## 📚 9. RESOURCES & MATERIALS (Content)

### 9.1 Resource Library

#### Tests
| Scenario | Tests |
|----------|-------|
| Upload document | 15 |
| Upload video | 15 |
| Organize in folders | 10 |

---

### 9.2 File Upload/Download

#### Tests
| Scenario | Tests |
|----------|-------|
| Upload file (PDF, DOCX, images) | 20 |
| Download file | 10 |
| File size validation (max 10MB) | 10 |

---

### 9.3 Assignment Management

#### Tests
| Scenario | Tests |
|----------|-------|
| Create assignment | 15 |
| Submit assignment | 15 |
| Grade assignment | 15 |

---

### 9.4 Assignment Grading

#### Tests
| Scenario | Tests |
|----------|-------|
| Grade multiple assignments | 15 |
| Provide feedback | 10 |

---

### 9.5 Access Control

#### Tests
| Scenario | Tests |
|----------|-------|
| Role-based access | 20 |
| Permission checks | 15 |

---

**Resources & Materials Total:** 150 test cases

---

## 🏢 10. BUSINESS PROFILE (Org)

### 10.1 Profile Management

#### Tests
| Scenario | Tests |
|----------|-------|
| Update business details | 20 |
| Upload logo | 10 |

---

### 10.2 Banking Details

#### Tests
| Scenario | Tests |
|----------|-------|
| Add bank account | 15 |
| Verify bank account | 10 |
| Update bank details | 10 |

---

### 10.3 Settings & Preferences

#### Tests
| Scenario | Tests |
|----------|-------|
| Update settings | 15 |
| Notification preferences | 10 |

---

**Business Profile Total:** 90 test cases

---

## 🆘 11. SUPPORT & HELP (Care)

### 11.1 Help Desk

#### Tests
| Scenario | Tests |
|----------|-------|
| Submit ticket | 15 |
| View ticket status | 10 |

---

### 11.2 Support Tickets

#### Tests
| Scenario | Tests |
|----------|-------|
| Create ticket | 10 |
| Assign ticket | 10 |
| Close ticket | 5 |

---

### 11.3 FAQ

#### Tests
| Scenario | Tests |
|----------|-------|
| View FAQ | 5 |
| Search FAQ | 5 |

---

**Support & Help Total:** 60 test cases

---

## 🔥 12. LOAD TESTING & PERFORMANCE

### 12.1 Concurrent Users

| User Type | Concurrent Users | Expected Response Time | Tests |
|-----------|------------------|------------------------|-------|
| Students browsing classes | 1,000 | < 2s | 10 |
| Instructors scheduling | 500 | < 3s | 10 |
| Payment processing | 200 | < 5s | 10 |
| Real-time chat | 500 | < 1s | 10 |
| Admin dashboard | 50 | < 3s | 10 |

---

### 12.2 Geographic Distribution

| Region | Users | Latency Target | Tests |
|--------|-------|----------------|-------|
| India (Mumbai) | 5,000 | < 1s | 5 |
| India (Delhi) | 3,000 | < 1.5s | 5 |
| Global (US) | 1,000 | < 3s | 5 |
| Global (Europe) | 500 | < 4s | 5 |

---

### 12.3 Feature-Specific Load Testing

| Feature | Concurrent Operations | Target | Tests |
|---------|----------------------|--------|-------|
| Class scheduling | 100 classes/minute | < 3s each | 10 |
| Student enrollment | 500 enrollments/minute | < 5s each | 10 |
| Payment processing | 200 payments/minute | < 8s each | 10 |
| Message sending | 1,000 messages/minute | < 1s each | 10 |
| File uploads | 50 uploads/minute | < 10s for 5MB | 10 |

---

### 12.4 Database Load Testing

| Operation | Target QPS | Tests |
|-----------|-----------|-------|
| Read operations | 10,000 QPS | 10 |
| Write operations | 2,000 QPS | 10 |
| Complex queries | 500 QPS | 10 |
| Aggregation pipelines | 100 QPS | 10 |

---

### 12.5 Tools & Benchmarks

**Load Testing Tools:**
- Apache JMeter
- k6
- Artillery
- Locust

**Benchmarks:**
- **Peak Load:** 10,000 concurrent users (India)
- **Average Response Time:** < 2 seconds
- **Error Rate:** < 0.1%
- **Database Uptime:** 99.9%
- **API Availability:** 99.95%

**Load Testing Total:** 50 test scenarios, 80 hours

---

## 💾 13. DATABASE TESTING

### 13.1 Data Integrity

| Test Scenario | Tests |
|---------------|-------|
| Foreign key constraints | 10 |
| Unique constraints | 10 |
| Not null constraints | 10 |
| Data type validation | 10 |

---

### 13.2 CRUD Operations

| Collection | Create | Read | Update | Delete | Total |
|------------|--------|------|--------|--------|-------|
| users | 2 | 2 | 2 | 2 | 8 |
| classes | 2 | 2 | 2 | 2 | 8 |
| enrollments | 2 | 2 | 2 | 2 | 8 |
| payments | 2 | 2 | 2 | 2 | 8 |
| messages | 2 | 2 | 2 | 2 | 8 |

---

### 13.3 Query Performance

| Query Type | Target Time | Tests |
|------------|-------------|-------|
| Simple SELECT | < 50ms | 5 |
| JOIN queries | < 200ms | 5 |
| Aggregation | < 500ms | 5 |
| Full-text search | < 300ms | 5 |

---

### 13.4 Backup & Recovery

| Test Scenario | Tests |
|---------------|-------|
| Backup creation | 5 |
| Backup restoration | 5 |
| Point-in-time recovery | 5 |

---

### 13.5 Transactions

| Test Scenario | Tests |
|---------------|-------|
| ACID compliance | 10 |
| Rollback on failure | 10 |

---

**Database Testing Total:** 100 test cases

---

## 📈 TESTING TIMELINE

```
┌─────────────────────────────────────────────────────────────┐
│                    TESTING TIMELINE (17 Weeks)               │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Week 1-2:   🔥 Google OAuth + Mobile OTP (Critical)        │
│  Week 3:     🔥 Google Calendar Integration                 │
│  Week 4:     Session Management + Token Testing             │
│  Week 5-6:   Class Management (with Google token)           │
│  Week 7-8:   Student & Payment (with Google token)          │
│  Week 9-10:  Calendar, Comms, Listings (Google-based)       │
│  Week 11:    Resources, Business Profile, Support           │
│  Week 12-13: Integration Tests (Full Google-based flows)    │
│  Week 14:    E2E Tests (User Journeys with Google auth)     │
│  Week 15:    Load Testing (13,500 concurrent users)         │
│  Week 16:    Database + Google API Testing                  │
│  Week 17:    Bug Fixing + Regression + Final Sign-off       │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 👥 RESOURCE ALLOCATION

| Role | Count | Hours/Week | Total Cost |
|------|-------|------------|------------|
| Senior QA Engineer (Google OAuth expert) | 1 | 40h | $24,000 |
| QA Engineers (Mid-level) | 2 | 40h each | $32,000 |
| Junior QA Engineer | 1 | 40h | $12,000 |
| **TOTAL** | **4** | **160h/week** | **$68,000** |

---

## 🎯 LOAD TESTING BENCHMARKS

### User Capacity by Region

| Region | Max Concurrent Users | Classes/Day | Payments/Day |
|--------|---------------------|-------------|--------------|
| **India** | 10,000 | 5,000 | 2,000 |
| **Global (US)** | 2,000 | 1,000 | 400 |
| **Global (Europe)** | 1,000 | 500 | 200 |
| **Global (Other)** | 500 | 250 | 100 |
| **TOTAL** | **13,500** | **6,750** | **2,700** |

### Infrastructure Requirements

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| API Servers | 2 instances | 4 instances (load balanced) |
| Database | 1 primary, 1 replica | 1 primary, 2 replicas |
| Redis Cache | 1 instance | 2 instances (HA) |
| CDN | Yes | Cloudflare/AWS CloudFront |
| Auto-scaling | Yes | Min: 2, Max: 10 instances |

---

## 🔍 DATABASE PERFORMANCE TARGETS

| Metric | Target |
|--------|--------|
| **Collections** | 30+ collections |
| **Documents** | 10 million+ |
| **Read QPS** | 10,000 queries/second |
| **Write QPS** | 2,000 queries/second |
| **Storage** | 500 GB |
| **Indexes** | Optimized for all queries |
| **Backup** | Daily automated |
| **Recovery Time** | < 4 hours |

---

## ✅ ACCEPTANCE CRITERIA

### Zero Bugs Policy

| Category | Acceptance |
|----------|------------|
| **Critical Bugs** | 0 |
| **High Priority Bugs** | 0 |
| **Medium Priority Bugs** | < 5 |
| **Low Priority Bugs** | < 10 |
| **Code Coverage** | > 80% |
| **E2E Pass Rate** | 100% |
| **Load Test Pass** | All scenarios pass |
| **Database Tests** | 100% pass |

---

## 📊 FINAL METRICS

```
┌─────────────────────────────────────────────────────────────┐
│                    TESTING METRICS SUMMARY                   │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Total Features:                58                           │
│  Total Test Cases:              2,773 (↑ from 1,940)        │
│  Total Testing Hours:           1,360 hours (↑ from 1,040)  │
│  Timeline:                      17 weeks (↑ from 14)         │
│  Team Size:                     4 engineers                  │
│  Budget:                        $68,000 USD (↑ from $52k)   │
│                                                              │
│  ─────────────────────────────────────────────────────────  │
│  🔥 PRIMARY AUTH:                                            │
│                                                              │
│  Google OAuth Tests:            120 (CRITICAL)              │
│  Mobile OTP Tests:              70 (HIGH)                   │
│  Google Integration Tests:      150 (CRITICAL)              │
│  Google Token in all APIs:      100% coverage               │
│  Google Calendar Sync Tests:    77 (CRITICAL)               │
│                                                              │
│  ─────────────────────────────────────────────────────────  │
│                                                              │
│  Max Concurrent Users (India):  10,000                       │
│  Max Concurrent Users (Global): 3,500                        │
│  Total User Capacity:           13,500                       │
│  Classes Handled/Day:           6,750                        │
│  Payments Handled/Day:          2,700                        │
│  Database Size:                 500 GB                       │
│  API Response Time:             < 2 seconds                  │
│  Google API Rate Limit:         Handled via queueing         │
│  Uptime Target:                 99.9%                        │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 🚀 DEPLOYMENT READINESS CHECKLIST

- [ ] 2,773 test cases written
- [ ] 100% tests passing
- [ ] 🔥 Google OAuth: 100% tests passing
- [ ] 🔥 Mobile OTP: 100% tests passing
- [ ] 🔥 Google Calendar Sync: All scenarios tested
- [ ] 🔥 Google token validation in ALL APIs
- [ ] Load testing: 13,500 concurrent users handled
- [ ] Database: 10M documents, < 200ms query time
- [ ] API: < 2s response time
- [ ] Google API rate limiting handled
- [ ] Zero critical/high bugs
- [ ] Code coverage > 80%
- [ ] Security audit passed (Google OAuth flows)
- [ ] Backup & recovery tested
- [ ] Monitoring & alerts configured

---

## 🔍 POTENTIALLY MISSING FEATURES TO TEST

### Missing Test Coverage Areas

| Feature Area | Description | Additional Tests | Priority |
|--------------|-------------|------------------|----------|
| **1. Email Notifications** | | | |
| Welcome email (Google signup) | After first Google login | 10 | HIGH |
| Class reminder emails | 24h before class | 10 | HIGH |
| Payment confirmation emails | After successful payment | 10 | HIGH |
| Enrollment confirmation | Student enrolled → Email | 10 | HIGH |
| **2. Push Notifications** | | | |
| OneSignal integration | Browser push notifications | 15 | HIGH |
| Mobile app notifications | If mobile app exists | 15 | MEDIUM |
| Notification preferences | User can enable/disable | 10 | MEDIUM |
| **3. Image Uploads** | | | |
| Profile picture upload | User/Instructor profiles | 15 | HIGH |
| Activity image upload | Activity listings | 15 | HIGH |
| Class thumbnail upload | Class cards | 15 | MEDIUM |
| Resource file upload | PDF, DOCX, images | 20 | HIGH |
| File size validation (max 10MB) | Reject large files | 10 | HIGH |
| Image compression | Auto-compress before upload | 10 | MEDIUM |
| **4. Search Functionality** | | | |
| Search classes by name | Full-text search | 15 | HIGH |
| Search by activity type | Filter classes | 10 | HIGH |
| Search by location | Geo-based search | 15 | HIGH |
| Search by instructor | Find instructor's classes | 10 | MEDIUM |
| Search by date range | Available classes | 10 | HIGH |
| Auto-complete/suggestions | As user types | 10 | MEDIUM |
| **5. Filters & Sorting** | | | |
| Filter by price range | Min-max price | 10 | HIGH |
| Filter by online/in-person | Mode filter | 8 | HIGH |
| Sort by popularity | Most enrolled | 8 | MEDIUM |
| Sort by price (low to high) | Price sorting | 8 | MEDIUM |
| Sort by rating | If rating system exists | 10 | LOW |
| **6. Reviews & Ratings** | | | |
| Student can rate class | 1-5 stars | 15 | MEDIUM |
| Student can write review | Text review | 15 | MEDIUM |
| Instructor can reply to reviews | Response system | 10 | LOW |
| Display average rating | On class cards | 8 | MEDIUM |
| **7. Attendance Tracking** | | | |
| Mark attendance (Instructor) | Present/Absent/Late | 15 | HIGH |
| QR code attendance | Students scan QR | 20 | LOW |
| Geofence attendance | Location-based | 15 | LOW |
| Attendance reports | Export to Excel | 10 | MEDIUM |
| **8. Certificate Generation** | | | |
| Auto-generate on completion | PDF certificate | 20 | LOW |
| Customizable templates | Instructor can customize | 15 | LOW |
| Email certificate to student | Auto-send | 10 | LOW |
| **9. Waitlist Management** | | | |
| Add student to waitlist | Class full | 15 | MEDIUM |
| Auto-notify when spot opens | Email + Push | 15 | MEDIUM |
| Waitlist priority (FIFO) | First come first serve | 10 | MEDIUM |
| **10. Recurring Payments** | | | |
| Monthly subscriptions | Razorpay subscription | 25 | HIGH |
| Auto-charge on due date | Automated billing | 20 | HIGH |
| Failed payment retry | 3 retry attempts | 15 | HIGH |
| Subscription cancellation | User can cancel | 15 | MEDIUM |
| **11. Refund Policies** | | | |
| Define refund rules | Per class settings | 10 | MEDIUM |
| Auto-refund if class canceled | Automated refunds | 15 | HIGH |
| Partial refunds | Percentage-based | 10 | MEDIUM |
| **12. Multi-language Support** | | | |
| English (default) | All content | 20 | HIGH |
| Hindi | Translation | 20 | MEDIUM |
| Other Indian languages | Regional support | 15 | LOW |
| **13. Accessibility (A11y)** | | | |
| Screen reader support | ARIA labels | 25 | MEDIUM |
| Keyboard navigation | Tab through forms | 20 | MEDIUM |
| Color contrast (WCAG) | Accessibility standards | 15 | LOW |
| **14. Analytics & Tracking** | | | |
| Google Analytics integration | Page views, events | 15 | MEDIUM |
| Track user journeys | Funnel analysis | 15 | MEDIUM |
| Track conversions | Sign-ups, payments | 15 | MEDIUM |
| **15. Admin Dashboard** | | | |
| User management (CRUD) | Create/Edit/Delete users | 20 | HIGH |
| Class approval workflow | Admin approves classes | 15 | MEDIUM |
| Payment dispute resolution | Handle disputes | 15 | MEDIUM |
| System health monitoring | Uptime, errors | 15 | HIGH |
| **16. Instructor Payouts** | | | |
| Calculate instructor earnings | After class completion | 20 | HIGH |
| Payout schedule (weekly/monthly) | Automated payouts | 20 | HIGH |
| Payout via bank transfer | Integration with payment gateway | 20 | HIGH |
| Payout history | Track past payouts | 10 | MEDIUM |
| **17. Tax & Invoicing** | | | |
| GST calculation (India) | 18% tax on services | 20 | HIGH |
| Invoice generation | PDF invoices | 15 | HIGH |
| Tax reports for compliance | Annual reports | 15 | MEDIUM |
| **18. Bulk Operations** | | | |
| Bulk enroll students | CSV upload | 15 | MEDIUM |
| Bulk send messages | To all students | 15 | MEDIUM |
| Bulk class cancellation | Cancel multiple classes | 10 | LOW |
| **19. Offline Mode** | | | |
| Cache data locally | PWA support | 20 | LOW |
| Sync when online | Background sync | 15 | LOW |
| **20. Social Sharing** | | | |
| Share class on Facebook | Social media integration | 10 | LOW |
| Share on WhatsApp | Direct WhatsApp share | 10 | MEDIUM |
| Share on Twitter/X | Social sharing | 5 | LOW |
| **21. Promo Codes & Discounts** | | | |
| Create promo codes | Admin/Instructor | 20 | HIGH |
| Apply discount at checkout | Percentage or fixed | 20 | HIGH |
| Limit promo code usage | Max uses, expiry | 15 | MEDIUM |
| Track promo code effectiveness | Analytics | 10 | LOW |
| **22. Error Handling & Logging** | | | |
| Frontend error boundaries | Catch React errors | 15 | HIGH |
| Backend error logging | Winston/Sentry | 15 | HIGH |
| User-friendly error messages | No technical jargon | 20 | HIGH |
| Retry mechanisms | Auto-retry failed requests | 15 | MEDIUM |
| **23. Data Export** | | | |
| Export student data | GDPR compliance | 15 | HIGH |
| Export class data | Excel/CSV | 10 | MEDIUM |
| Export payment data | Accounting | 15 | HIGH |
| **24. Data Privacy & GDPR** | | | |
| Privacy policy display | Legal compliance | 10 | MEDIUM |
| Terms & conditions | User agreement | 10 | MEDIUM |
| Data deletion request | User can request deletion | 20 | HIGH |
| Cookie consent | GDPR compliance | 10 | MEDIUM |
| **25. Performance Optimization** | | | |
| Lazy loading images | Improve load time | 15 | HIGH |
| Code splitting | Reduce bundle size | 15 | HIGH |
| CDN for static assets | Faster delivery | 10 | MEDIUM |
| Database query optimization | Indexes, caching | 20 | HIGH |

**Additional Test Cases:** **1,065 tests**

---

## 📊 UPDATED TESTING SCOPE

| Category | Original Tests | Missing Tests | Total Tests |
|----------|---------------|---------------|-------------|
| Core Features (1-11) | 1,940 | 0 | 1,940 |
| Load Testing | 50 | 30 | 80 |
| Database Testing | 100 | 20 | 120 |
| Google Integration | 150 | 0 | 150 |
| **Missing Features (1-25)** | **0** | **1,065** | **1,065** |
| **GRAND TOTAL** | **2,240** | **1,115** | **3,838** |

### Updated Estimates

| Metric | Original | With Missing Features |
|--------|----------|----------------------|
| Total Test Cases | 2,773 | **3,838** |
| Total Hours | 1,360h | **1,920h** |
| Timeline | 17 weeks | **24 weeks (6 months)** |
| Team Size | 4 engineers | **5 engineers** |
| Budget | $68,000 | **$96,000** |

---

## 🎯 PRIORITIZED TESTING ROADMAP

### Phase 1: Critical Features (Weeks 1-12)
- Google OAuth + Mobile OTP
- Class Management
- Student Enrollment
- Payment Processing
- Calendar Sync
- **Sub-Total:** 2,773 tests

### Phase 2: Important Missing Features (Weeks 13-20)
- Email & Push Notifications (80 tests)
- Image Uploads (85 tests)
- Search & Filters (81 tests)
- Recurring Payments (75 tests)
- Admin Dashboard (50 tests)
- Instructor Payouts (70 tests)
- Tax & Invoicing (50 tests)
- Promo Codes (55 tests)
- Error Handling (50 tests)
- Data Export (40 tests)
- **Sub-Total:** 636 tests

### Phase 3: Nice-to-Have Features (Weeks 21-24)
- Reviews & Ratings (48 tests)
- Waitlist (40 tests)
- Certificates (45 tests)
- Multi-language (55 tests)
- Accessibility (60 tests)
- Social Sharing (25 tests)
- Offline Mode (35 tests)
- Other features (161 tests)
- **Sub-Total:** 429 tests

---

*Document Created: December 3, 2025*  
*Version: 1.0*  
*Status: Ready for Execution*

