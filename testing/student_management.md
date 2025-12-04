# 🎯 ClassInTown - Comprehensive Testing Estimation
### Complete Feature Coverage Testing Plan

> **Goal:** Test EVERY feature to the bone. Zero bugs across Frontend, Backend, Database.

---

## 📊 Testing Scope Overview

| Category | Features | Test Cases | Estimated Hours |
|----------|----------|------------|-----------------|
| **1. Authentication & Authorization** | 5 | 403 | 140h |
| **2. Class Management (Core)** | 8 | 450 | 200h |
| **3. Student Management** 🔥 | 9 | 2,241 | 400h |
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
| **TOTAL** | **61 Features** | **4,804 Test Cases** | **1,660 Hours** |

**Team Size:** 5 QA Engineers (1 Senior + 3 Mid + 1 Junior)  
**Timeline:** ~21 weeks (5.2 months) of rigorous testing  
**Cost:** ~$95,400 USD (@ $50/hour avg)

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

## 👥 3. STUDENT MANAGEMENT (Learners) - DEEP DIVE

> **Architecture:** All operations require Google OAuth token validation  
> **Database:** MongoDB collections - `students`, `enrollments`, `progress`, `attendance`, `grades`, `notes`  
> **Frontend:** Angular components with reactive forms  
> **Backend:** Node.js REST APIs with JWT middleware  

---

## 📋 STUDENT MANAGEMENT TESTING ARCHITECTURE

### Testing Layers
```
┌─────────────────────────────────────────────────────────────┐
│                    TESTING PYRAMID                           │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│                    E2E Tests (15%)                          │
│               ┌──────────────────────┐                      │
│               │  User Journeys       │                      │
│               │  Critical Flows      │                      │
│               └──────────────────────┘                      │
│                                                              │
│              Integration Tests (35%)                         │
│         ┌────────────────────────────────┐                  │
│         │  API + Database + Auth         │                  │
│         │  Multi-component workflows     │                  │
│         └────────────────────────────────┘                  │
│                                                              │
│                Unit Tests (50%)                              │
│    ┌──────────────────────────────────────────┐            │
│    │  Components, Services, Controllers        │            │
│    │  Validators, Utilities, Models           │            │
│    └──────────────────────────────────────────┘            │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔐 3.1 STUDENT CRUD OPERATIONS (Foundation)

> **Critical Flow:** Google OAuth → Create Student → Save DB → Assign to Class → Track Progress

---

### 3.1.1 CREATE STUDENT - Frontend Testing

#### Component: `student-create.component.ts`

| Test ID | Test Scenario | Test Steps | Expected Result | Priority |
|---------|--------------|------------|-----------------|----------|
| SC-F-001 | Component initialization | Load component | Form rendered with all fields | HIGH |
| SC-F-002 | Google token validation | Check token on ngOnInit | If invalid, redirect to login | CRITICAL |
| SC-F-003 | Form fields render | Check DOM | First name, last name, email, mobile visible | HIGH |
| SC-F-004 | Optional fields render | Check DOM | DOB, gender, address, parent info visible | MEDIUM |
| SC-F-005 | Profile picture upload | Check file input | Accept .jpg, .png, max 5MB | HIGH |
| SC-F-006 | Email validation - valid | Enter: test@example.com | No error | HIGH |
| SC-F-007 | Email validation - invalid | Enter: invalid-email | Show error: "Invalid email format" | HIGH |
| SC-F-008 | Email validation - duplicate | Enter existing email | API error: "Email already exists" | CRITICAL |
| SC-F-009 | Mobile validation - valid (India) | Enter: +91 9876543210 | No error | HIGH |
| SC-F-010 | Mobile validation - invalid | Enter: 123 | Show error: "Invalid mobile number" | HIGH |
| SC-F-011 | Mobile validation - duplicate | Enter existing mobile | API error: "Mobile already registered" | HIGH |
| SC-F-012 | First name validation | Enter: A | Show error: "Min 2 characters" | MEDIUM |
| SC-F-013 | First name validation | Leave empty | Show error: "First name required" | HIGH |
| SC-F-014 | Last name validation | Enter: B | Show error: "Min 2 characters" | MEDIUM |
| SC-F-015 | Age validation | DOB → Calculate age → Show age | Auto-calculate age | MEDIUM |
| SC-F-016 | Minor detection | Age < 18 | Show parent/guardian fields | HIGH |
| SC-F-017 | Parent email required | Minor + no parent email | Show error | MEDIUM |
| SC-F-018 | Gender dropdown | Select: Male/Female/Other | Selected value displayed | LOW |
| SC-F-019 | Country code dropdown | Show all countries | Default: India (+91) | MEDIUM |
| SC-F-020 | Address autocomplete | Start typing address | Google Maps suggestions | MEDIUM |
| SC-F-021 | Profile picture preview | Upload image | Show preview before save | MEDIUM |
| SC-F-022 | Profile picture size check | Upload 10MB file | Show error: "Max 5MB" | HIGH |
| SC-F-023 | Profile picture format check | Upload .pdf | Show error: "Only images allowed" | HIGH |
| SC-F-024 | Submit button disabled | Form invalid | Button disabled | HIGH |
| SC-F-025 | Submit button enabled | Form valid | Button enabled | HIGH |
| SC-F-026 | Loading spinner on submit | Click submit | Show spinner | MEDIUM |
| SC-F-027 | Success message | API success | Show: "Student created successfully" | HIGH |
| SC-F-028 | Error message display | API error | Show error from backend | HIGH |
| SC-F-029 | Redirect after success | Student created | Redirect to student list | HIGH |
| SC-F-030 | Cancel button | Click cancel | Discard changes, go back | MEDIUM |
| SC-F-031 | Unsaved changes warning | Edit + Navigate away | Show confirmation dialog | MEDIUM |
| SC-F-032 | Clear form button | Click clear | Reset all fields | LOW |
| SC-F-033 | Form validation on blur | Leave email field | Validate immediately | MEDIUM |
| SC-F-034 | Form validation on submit | Click submit | Validate all fields | HIGH |
| SC-F-035 | Multiple validation errors | Invalid email + mobile | Show all errors | HIGH |
| SC-F-036 | Token expired during form | Token expires mid-form | Refresh token automatically | HIGH |
| SC-F-037 | Network error handling | API unreachable | Show: "Network error, try again" | HIGH |
| SC-F-038 | Responsive design - mobile | Load on mobile | Form responsive, fields stack | MEDIUM |
| SC-F-039 | Responsive design - tablet | Load on tablet | Form adapts to screen | MEDIUM |
| SC-F-040 | Keyboard navigation | Tab through fields | All fields accessible | LOW |
| SC-F-041 | Screen reader support | Use screen reader | ARIA labels present | LOW |
| SC-F-042 | Emergency contact field | Add emergency contact | Field accepts name + mobile | MEDIUM |
| SC-F-043 | Medical info field | Add allergies/medical notes | Text area accepts input | LOW |
| SC-F-044 | Blood group dropdown | Select blood group | Optional field | LOW |
| SC-F-045 | Language preference | Select: English/Hindi | Default: English | LOW |

**Sub-Total:** 45 Frontend Unit Tests (Create)

---

### 3.1.2 CREATE STUDENT - Backend Testing

#### Controller: `student.controller.js`

| Test ID | Test Scenario | Test Steps | Expected Result | Priority |
|---------|--------------|------------|-----------------|----------|
| SC-B-001 | POST /api/students endpoint | Send request | Route exists | HIGH |
| SC-B-002 | Google JWT validation | No token | Return 401 Unauthorized | CRITICAL |
| SC-B-003 | Google JWT validation | Invalid token | Return 401 Unauthorized | CRITICAL |
| SC-B-004 | Google JWT validation | Expired token | Return 401 Token Expired | CRITICAL |
| SC-B-005 | Google JWT validation | Valid token | Proceed to create | HIGH |
| SC-B-006 | Extract instructor ID | From JWT payload | Get instructor_id | HIGH |
| SC-B-007 | Request body validation | Empty body | Return 400 Bad Request | HIGH |
| SC-B-008 | Required fields check | Missing first_name | Return 400 "First name required" | HIGH |
| SC-B-009 | Required fields check | Missing last_name | Return 400 "Last name required" | HIGH |
| SC-B-010 | Required fields check | Missing email | Return 400 "Email required" | HIGH |
| SC-B-011 | Email format validation | Invalid email | Return 400 "Invalid email" | HIGH |
| SC-B-012 | Email uniqueness check | Duplicate email | Return 409 "Email exists" | CRITICAL |
| SC-B-013 | Mobile format validation | Invalid mobile | Return 400 "Invalid mobile" | HIGH |
| SC-B-014 | Mobile uniqueness check | Duplicate mobile | Return 409 "Mobile exists" | HIGH |
| SC-B-015 | Mobile format - India | +91 9876543210 | Accept | HIGH |
| SC-B-016 | Mobile format - US | +1 2025551234 | Accept | MEDIUM |
| SC-B-017 | Mobile format - Global | Various formats | Accept valid formats | MEDIUM |
| SC-B-018 | Name length validation | First name < 2 chars | Return 400 | MEDIUM |
| SC-B-019 | Name length validation | First name > 50 chars | Return 400 | MEDIUM |
| SC-B-020 | Name special chars | Name with numbers | Return 400 "Only letters allowed" | MEDIUM |
| SC-B-021 | Age calculation | DOB provided | Calculate age correctly | MEDIUM |
| SC-B-022 | Minor detection | Age < 18 | Require parent details | HIGH |
| SC-B-023 | Parent email validation | Minor without parent email | Return 400 | HIGH |
| SC-B-024 | Profile picture upload | Valid image | Upload to cloud storage | HIGH |
| SC-B-025 | Profile picture upload | File > 5MB | Return 400 "File too large" | HIGH |
| SC-B-026 | Profile picture upload | Invalid file type | Return 400 "Invalid file type" | HIGH |
| SC-B-027 | Image compression | Upload 5MB image | Compress to < 1MB | MEDIUM |
| SC-B-028 | Cloud storage integration | Upload success | Return URL | HIGH |
| SC-B-029 | Cloud storage error | Upload fails | Rollback, return error | HIGH |
| SC-B-030 | Generate student ID | Auto-generate | Format: STU-{timestamp}-{random} | HIGH |
| SC-B-031 | Student ID uniqueness | Check ID collision | Regenerate if exists | MEDIUM |
| SC-B-032 | Set default values | New student | active: true, created_at: now | HIGH |
| SC-B-033 | Set instructor reference | From JWT | Link student to instructor | HIGH |
| SC-B-034 | Business reference | From instructor profile | Link to business | HIGH |
| SC-B-035 | Database transaction | Start transaction | All or nothing | HIGH |
| SC-B-036 | Save to database | Insert student doc | Return saved document | HIGH |
| SC-B-037 | Database error handling | DB connection lost | Return 500, rollback | HIGH |
| SC-B-038 | Duplicate key error | Email/mobile duplicate | Return 409 | HIGH |
| SC-B-039 | Create activity log | Student created | Log: "Student XYZ created by instructor ABC" | MEDIUM |
| SC-B-040 | Send welcome email | After creation | Email to student | HIGH |
| SC-B-041 | Send notification to parent | If minor | Email to parent | MEDIUM |
| SC-B-042 | Welcome SMS | Send SMS to mobile | SMS delivery confirmation | MEDIUM |
| SC-B-043 | Response structure | Success | Return: {success: true, data: student, message} | HIGH |
| SC-B-044 | Response sanitization | Remove sensitive fields | Don't return: password_hash, internal_ids | MEDIUM |
| SC-B-045 | Rate limiting | 10 creates/minute | Exceed → 429 Too Many Requests | MEDIUM |
| SC-B-046 | Concurrent requests | 2 creates with same email | One succeeds, one fails | HIGH |
| SC-B-047 | SQL injection prevention | Malicious input | Sanitize, no SQL executed | CRITICAL |
| SC-B-048 | XSS prevention | Script in name field | Escape HTML | CRITICAL |
| SC-B-049 | Input length validation | Very long input | Truncate or reject | MEDIUM |
| SC-B-050 | Timezone handling | Store timestamps | UTC format | MEDIUM |
| SC-B-051 | Multi-tenant isolation | Instructor A creates student | Student not visible to Instructor B | CRITICAL |
| SC-B-052 | Audit trail | Create student | Record in audit_logs collection | MEDIUM |
| SC-B-053 | Rollback on email failure | Student created but email fails | Don't rollback (email is async) | LOW |
| SC-B-054 | Performance | Create 1 student | Response time < 500ms | HIGH |
| SC-B-055 | Performance | Concurrent 100 creates | All succeed, < 3s total | MEDIUM |

**Sub-Total:** 55 Backend Unit Tests (Create)

---

### 3.1.3 CREATE STUDENT - Database Testing

| Test ID | Test Scenario | Test Steps | Expected Result | Priority |
|---------|--------------|------------|------------------|----------|
| SC-DB-001 | Insert student document | Insert with all fields | Success | HIGH |
| SC-DB-002 | Unique index on email | Insert duplicate email | Error: Duplicate key | CRITICAL |
| SC-DB-003 | Unique index on mobile | Insert duplicate mobile | Error: Duplicate key | CRITICAL |
| SC-DB-004 | Unique index on student_id | Insert duplicate student_id | Error: Duplicate key | HIGH |
| SC-DB-005 | Schema validation | Missing required field | Validation error | HIGH |
| SC-DB-006 | Schema validation | Invalid data type | Validation error | HIGH |
| SC-DB-007 | Default values | Insert without created_at | Auto-set to current timestamp | MEDIUM |
| SC-DB-008 | Foreign key - instructor_id | Invalid instructor_id | Reject or cascade | HIGH |
| SC-DB-009 | Foreign key - business_id | Invalid business_id | Reject or cascade | HIGH |
| SC-DB-010 | Index performance | Query by email | Use index, < 50ms | HIGH |
| SC-DB-011 | Index performance | Query by mobile | Use index, < 50ms | HIGH |
| SC-DB-012 | Full-text search index | Search student name | Return results | MEDIUM |
| SC-DB-013 | Data consistency | Insert + immediate read | Data matches | HIGH |
| SC-DB-014 | Transaction rollback | Error mid-transaction | No partial data | HIGH |
| SC-DB-015 | Storage size | Insert 10,000 students | Monitor collection size | MEDIUM |
| SC-DB-016 | Embedded documents | Store parent info | Nested object stored | MEDIUM |
| SC-DB-017 | Array fields | Store emergency contacts | Array with multiple objects | MEDIUM |
| SC-DB-018 | Date storage | Store DOB | ISO format stored | MEDIUM |
| SC-DB-019 | Null handling | Optional fields null | Accept null values | MEDIUM |
| SC-DB-020 | Document size limit | Very large document | Within 16MB limit | LOW |

**Sub-Total:** 20 Database Tests (Create)

---

### 3.1.4 READ STUDENT - Complete Testing

#### Frontend Tests

| Test ID | Test Scenario | Tests | Priority |
|---------|--------------|-------|----------|
| SR-F-001 | Load student list component | 5 | HIGH |
| SR-F-002 | Fetch students from API | 5 | HIGH |
| SR-F-003 | Display students in table/grid | 8 | HIGH |
| SR-F-004 | Pagination (10/25/50/100 per page) | 10 | HIGH |
| SR-F-005 | Sort by name (A-Z, Z-A) | 5 | MEDIUM |
| SR-F-006 | Sort by created date | 5 | MEDIUM |
| SR-F-007 | Search by name | 8 | HIGH |
| SR-F-008 | Search by email | 5 | HIGH |
| SR-F-009 | Search by mobile | 5 | HIGH |
| SR-F-010 | Filter by status (active/inactive) | 5 | MEDIUM |
| SR-F-011 | Filter by enrollment status | 5 | MEDIUM |
| SR-F-012 | View student details modal | 8 | HIGH |
| SR-F-013 | Student profile picture display | 5 | MEDIUM |
| SR-F-014 | Empty state (no students) | 5 | MEDIUM |
| SR-F-015 | Loading skeleton | 3 | LOW |

#### Backend Tests

| Test ID | Test Scenario | Tests | Priority |
|---------|--------------|-------|----------|
| SR-B-001 | GET /api/students | 10 | HIGH |
| SR-B-002 | GET /api/students/:id | 10 | HIGH |
| SR-B-003 | Token validation | 5 | CRITICAL |
| SR-B-004 | Multi-tenant filtering | 10 | CRITICAL |
| SR-B-005 | Pagination logic | 8 | HIGH |
| SR-B-006 | Search query optimization | 8 | HIGH |
| SR-B-007 | Filter logic | 8 | MEDIUM |
| SR-B-008 | Sort logic | 5 | MEDIUM |
| SR-B-009 | Response caching (Redis) | 10 | MEDIUM |
| SR-B-010 | Cache invalidation | 8 | MEDIUM |
| SR-B-011 | Aggregate student stats | 10 | MEDIUM |

#### Database Tests

| Test ID | Test Scenario | Tests | Priority |
|---------|--------------|-------|----------|
| SR-DB-001 | Query performance (1000 records) | 5 | HIGH |
| SR-DB-002 | Query performance (10,000 records) | 5 | HIGH |
| SR-DB-003 | Index usage verification | 5 | HIGH |
| SR-DB-004 | Complex queries (joins/lookups) | 10 | MEDIUM |

**Sub-Total:** 196 Tests (Read Operations)

---

### 3.1.5 UPDATE STUDENT - Complete Testing

#### Frontend Tests (40 tests)
- Form pre-population with existing data
- Partial update support
- Validation on update
- Optimistic UI updates
- Rollback on error

#### Backend Tests (50 tests)
- PUT /api/students/:id
- PATCH /api/students/:id (partial)
- Validate student ownership
- Update timestamp tracking
- Version conflict handling
- Audit log of changes

#### Database Tests (30 tests)
- Update operations
- Partial updates
- Update performance
- Concurrent update handling
- Optimistic locking

**Sub-Total:** 120 Tests (Update)

---

### 3.1.6 DELETE STUDENT - Complete Testing

#### Frontend Tests (25 tests)
- Delete confirmation dialog
- Soft delete vs hard delete option
- Cascade delete warning
- Undo delete functionality

#### Backend Tests (40 tests)
- DELETE /api/students/:id
- Soft delete (set active: false)
- Hard delete (permanent removal)
- Cascade delete enrollments
- Check for dependencies (enrollments, payments)
- Prevent delete if active enrollments

#### Database Tests (25 tests)
- Soft delete operations
- Hard delete operations
- Referential integrity
- Cascade behavior

**Sub-Total:** 90 Tests (Delete)

---

## 📊 3.2 BULK OPERATIONS (Scalability)

### 3.2.1 BULK IMPORT STUDENTS

#### Frontend Tests - CSV Upload

| Test ID | Test Scenario | Test Steps | Expected Result | Priority |
|---------|--------------|------------|------------------|----------|
| BI-F-001 | File upload component | Render upload area | Drag & drop + file picker | HIGH |
| BI-F-002 | Download CSV template | Click template link | Download sample CSV | HIGH |
| BI-F-003 | CSV template format | Open template | Headers: first_name, last_name, email, mobile... | HIGH |
| BI-F-004 | File type validation | Upload .xlsx | Show error: "Only CSV allowed" | HIGH |
| BI-F-005 | File size validation | Upload 50MB file | Show error: "Max 10MB" | HIGH |
| BI-F-006 | CSV parsing - valid | Upload valid CSV | Parse and show preview | HIGH |
| BI-F-007 | CSV parsing - invalid | Upload malformed CSV | Show error with line number | HIGH |
| BI-F-008 | Data preview table | After parse | Show first 10 rows | HIGH |
| BI-F-009 | Validation errors display | Invalid emails in CSV | Highlight errors in preview | HIGH |
| BI-F-010 | Row count display | Valid CSV | Show: "100 students found" | MEDIUM |
| BI-F-011 | Duplicate detection | Duplicate emails | Warn before import | HIGH |
| BI-F-012 | Column mapping | CSV headers don't match | Allow user to map columns | MEDIUM |
| BI-F-013 | Import progress bar | Click import | Show progress 0-100% | HIGH |
| BI-F-014 | Success summary | Import complete | Show: "95 success, 5 failed" | HIGH |
| BI-F-015 | Error report download | Failures occurred | Download CSV with errors | HIGH |
| BI-F-016 | Cancel import | Mid-import cancel | Stop and rollback | MEDIUM |
| BI-F-017 | Re-import after fix | Fix errors | Upload corrected CSV | MEDIUM |
| BI-F-018 | Empty CSV handling | Upload empty file | Show error | MEDIUM |
| BI-F-019 | Special characters | Names with accents | Handle UTF-8 correctly | MEDIUM |
| BI-F-020 | Large file handling | 5000 rows | Process without hanging | HIGH |

#### Backend Tests - Bulk Processing

| Test ID | Test Scenario | Test Steps | Expected Result | Priority |
|---------|--------------|------------|------------------|----------|
| BI-B-001 | POST /api/students/bulk-import | Endpoint exists | 200 OK | HIGH |
| BI-B-002 | CSV parsing | Parse CSV buffer | Extract rows | HIGH |
| BI-B-003 | Validate each row | Check all 100 rows | Return validation results | HIGH |
| BI-B-004 | Email validation | Invalid emails | Mark as failed | HIGH |
| BI-B-005 | Duplicate email check | Check against DB | Skip or fail duplicates | HIGH |
| BI-B-006 | Batch insert | 100 valid students | Insert in batches of 20 | HIGH |
| BI-B-007 | Transaction handling | Error on row 50 | Rollback or continue? | HIGH |
| BI-B-008 | Partial success | 90 success, 10 fail | Return detailed results | HIGH |
| BI-B-009 | Performance | Import 1000 students | Complete in < 30s | HIGH |
| BI-B-010 | Performance | Import 5000 students | Complete in < 2min | MEDIUM |
| BI-B-011 | Concurrent imports | 2 instructors import | No conflicts | MEDIUM |
| BI-B-012 | Memory management | Large CSV | No memory leaks | HIGH |
| BI-B-013 | Background job | Large import | Queue with Bull/Agenda | MEDIUM |
| BI-B-014 | Progress tracking | Async import | Update progress in real-time | MEDIUM |
| BI-B-015 | Email notifications | Import complete | Email summary to instructor | LOW |

#### Database Tests

| Test ID | Test Scenario | Tests | Priority |
|---------|--------------|-------|----------|
| BI-DB-001 | Bulk insert performance | 1000 records | < 10s | HIGH |
| BI-DB-002 | Transaction size limits | Very large transaction | Handle gracefully | MEDIUM |
| BI-DB-003 | Index impact | Bulk insert with indexes | Monitor performance | MEDIUM |
| BI-DB-004 | Rollback large transaction | Error mid-import | Full rollback | HIGH |

**Sub-Total:** 150 Tests (Bulk Import)

---

### 3.2.2 BULK EXPORT STUDENTS

| Test ID | Category | Tests | Priority |
|---------|----------|-------|----------|
| BE-001 | Export to CSV | 15 | HIGH |
| BE-002 | Export to Excel | 15 | HIGH |
| BE-003 | Export to PDF | 15 | MEDIUM |
| BE-004 | Export filtered data | 10 | HIGH |
| BE-005 | Export selected students | 10 | MEDIUM |
| BE-006 | Export with custom columns | 10 | MEDIUM |
| BE-007 | Large export (5000+ rows) | 10 | HIGH |

**Sub-Total:** 85 Tests (Bulk Export)

---

### 3.2.3 BULK UPDATE OPERATIONS

| Test ID | Scenario | Tests | Priority |
|---------|----------|-------|----------|
| BU-001 | Bulk status change (active/inactive) | 15 | HIGH |
| BU-002 | Bulk assign to class | 20 | HIGH |
| BU-003 | Bulk send messages | 15 | MEDIUM |
| BU-004 | Bulk delete (soft) | 15 | MEDIUM |
| BU-005 | Bulk tag assignment | 10 | LOW |

**Sub-Total:** 75 Tests (Bulk Update)

---

## 📈 3.3 PROGRESS TRACKING (Learning Analytics)

### 3.3.1 Attendance Tracking

| Test ID | Feature | Tests | Priority |
|---------|---------|-------|----------|
| PT-AT-001 | Mark attendance (present/absent/late) | 20 | HIGH |
| PT-AT-002 | Bulk attendance marking | 20 | HIGH |
| PT-AT-003 | Attendance history view | 15 | HIGH |
| PT-AT-004 | Attendance percentage calculation | 15 | HIGH |
| PT-AT-005 | Attendance reports (per student) | 15 | HIGH |
| PT-AT-006 | Attendance reports (per class) | 15 | MEDIUM |
| PT-AT-007 | Attendance alerts (< 75%) | 15 | MEDIUM |
| PT-AT-008 | QR code attendance (optional) | 20 | LOW |
| PT-AT-009 | Geofence attendance (optional) | 15 | LOW |
| PT-AT-010 | Attendance export | 10 | MEDIUM |

**Sub-Total:** 160 Tests (Attendance)

---

### 3.3.2 Assignment Tracking

| Test ID | Feature | Tests | Priority |
|---------|---------|-------|----------|
| PT-AS-001 | Track assignments submitted | 20 | HIGH |
| PT-AS-002 | Track submission deadlines | 15 | HIGH |
| PT-AS-003 | Late submission handling | 15 | MEDIUM |
| PT-AS-004 | Assignment completion rate | 15 | MEDIUM |
| PT-AS-005 | Assignment grade tracking | 20 | HIGH |

**Sub-Total:** 85 Tests (Assignment Tracking)

---

### 3.3.3 Overall Progress Dashboard

| Test ID | Feature | Tests | Priority |
|---------|---------|-------|----------|
| PT-PD-001 | Progress percentage per student | 20 | HIGH |
| PT-PD-002 | Progress percentage per class | 20 | HIGH |
| PT-PD-003 | Completion milestones | 15 | MEDIUM |
| PT-PD-004 | Learning curve visualization | 15 | MEDIUM |
| PT-PD-005 | Progress comparison (student vs class avg) | 15 | LOW |
| PT-PD-006 | Progress alerts (falling behind) | 15 | MEDIUM |
| PT-PD-007 | Export progress reports | 10 | MEDIUM |

**Sub-Total:** 110 Tests (Progress Dashboard)

---

## 📝 3.4 GRADING & ASSESSMENT (Evaluation)

### 3.4.1 Grade Entry & Management

| Test ID | Feature | Tests | Priority |
|---------|---------|-------|----------|
| GA-001 | Enter grades (numeric) | 20 | HIGH |
| GA-002 | Enter grades (letter: A, B, C) | 15 | MEDIUM |
| GA-003 | Enter grades (pass/fail) | 10 | MEDIUM |
| GA-004 | Grade validation (0-100) | 15 | HIGH |
| GA-005 | Bulk grade entry | 20 | HIGH |
| GA-006 | Grade history tracking | 15 | MEDIUM |
| GA-007 | Grade edit/update | 15 | MEDIUM |
| GA-008 | Grade delete/void | 10 | LOW |

**Sub-Total:** 120 Tests (Grade Entry)

---

### 3.4.2 Grade Calculations

| Test ID | Feature | Tests | Priority |
|---------|---------|-------|----------|
| GC-001 | Calculate average grade | 15 | HIGH |
| GC-002 | Calculate GPA | 20 | HIGH |
| GC-003 | Calculate weighted grades | 20 | MEDIUM |
| GC-004 | Calculate class rank | 15 | LOW |
| GC-005 | Calculate percentile | 15 | LOW |

**Sub-Total:** 85 Tests (Grade Calculations)

---

### 3.4.3 Grade Reports

| Test ID | Feature | Tests | Priority |
|---------|---------|-------|----------|
| GR-001 | Individual grade report | 20 | HIGH |
| GR-002 | Class grade report | 20 | HIGH |
| GR-003 | Grade distribution chart | 15 | MEDIUM |
| GR-004 | Grade trends over time | 15 | MEDIUM |
| GR-005 | Export grade reports (PDF) | 15 | HIGH |
| GR-006 | Email grade reports | 15 | MEDIUM |

**Sub-Total:** 100 Tests (Grade Reports)

---

## 📋 3.5 STUDENT NOTES & COMMUNICATION

### 3.5.1 Instructor Notes (Private)

| Test ID | Feature | Tests | Priority |
|---------|---------|-------|----------|
| SN-001 | Add note per student | 15 | HIGH |
| SN-002 | Edit note | 10 | MEDIUM |
| SN-003 | Delete note | 10 | MEDIUM |
| SN-004 | View note history | 15 | MEDIUM |
| SN-005 | Search notes | 10 | MEDIUM |
| SN-006 | Tag notes (behavioral, academic, medical) | 15 | MEDIUM |
| SN-007 | Attach files to notes | 15 | LOW |
| SN-008 | Note timestamps & author | 10 | LOW |

**Sub-Total:** 100 Tests (Student Notes)

---

### 3.5.2 Student Communication

| Test ID | Feature | Tests | Priority |
|---------|---------|-------|----------|
| SC-001 | Send direct message to student | 20 | HIGH |
| SC-002 | Send message to parent | 20 | HIGH |
| SC-003 | Send bulk messages | 20 | HIGH |
| SC-004 | Email student | 15 | HIGH |
| SC-005 | SMS student | 15 | MEDIUM |
| SC-006 | Communication history | 15 | MEDIUM |

**Sub-Total:** 105 Tests (Communication)

---

## 🔐 3.6 SECURITY & ACCESS CONTROL

| Test ID | Feature | Tests | Priority |
|---------|---------|-------|----------|
| SEC-001 | Multi-tenant isolation | 25 | CRITICAL |
| SEC-002 | Role-based access (instructor only) | 20 | CRITICAL |
| SEC-003 | Student data encryption at rest | 15 | HIGH |
| SEC-004 | PII (Personal Identifiable Info) protection | 20 | HIGH |
| SEC-005 | GDPR compliance - data export | 15 | HIGH |
| SEC-006 | GDPR compliance - data deletion | 15 | HIGH |
| SEC-007 | Audit logs for all student operations | 20 | MEDIUM |

**Sub-Total:** 130 Tests (Security)

---

## 🚀 3.7 PERFORMANCE & LOAD TESTING

| Test ID | Scenario | Tests | Priority |
|---------|----------|-------|----------|
| PERF-001 | Load 1000 students in list | 10 | HIGH |
| PERF-002 | Search with 10,000 students | 10 | HIGH |
| PERF-003 | Bulk import 5000 students | 10 | HIGH |
| PERF-004 | Concurrent read operations (100 users) | 10 | HIGH |
| PERF-005 | Concurrent write operations (50 users) | 10 | MEDIUM |
| PERF-006 | API response time < 500ms | 15 | HIGH |
| PERF-007 | Database query optimization | 15 | HIGH |

**Sub-Total:** 80 Tests (Performance)

---

## 🔄 3.8 INTEGRATION TESTING

| Test ID | Integration Flow | Tests | Priority |
|---------|------------------|-------|----------|
| INT-001 | Google OAuth → Create Student → DB | 20 | CRITICAL |
| INT-002 | Create Student → Enroll in Class | 25 | CRITICAL |
| INT-003 | Create Student → Send Welcome Email | 20 | HIGH |
| INT-004 | Mark Attendance → Update Progress | 20 | HIGH |
| INT-005 | Enter Grades → Calculate GPA → Update Profile | 25 | HIGH |
| INT-006 | Student Payment → Update Enrollment Status | 25 | HIGH |
| INT-007 | Delete Student → Cascade Effects | 20 | HIGH |
| INT-008 | Bulk Import → Welcome Emails → Calendar Events | 25 | MEDIUM |

**Sub-Total:** 180 Tests (Integration)

---

## 🎭 3.9 END-TO-END USER JOURNEYS

| Journey ID | User Journey | Steps | Tests | Priority |
|------------|--------------|-------|-------|----------|
| E2E-001 | Instructor creates first student | Login → Create → Save → View | 15 | CRITICAL |
| E2E-002 | Instructor imports 100 students | Login → Upload CSV → Map → Import → View Results | 20 | CRITICAL |
| E2E-003 | Instructor views student progress | Login → Student List → Select Student → View Progress | 15 | HIGH |
| E2E-004 | Instructor marks attendance for class | Login → Class → Attendance → Mark All → Save | 15 | HIGH |
| E2E-005 | Instructor enters grades | Login → Student → Grades → Enter → Calculate GPA | 15 | HIGH |
| E2E-006 | Instructor sends message to student | Login → Student → Message → Send | 10 | HIGH |
| E2E-007 | Instructor exports student data | Login → Students → Export → Download CSV | 10 | MEDIUM |
| E2E-008 | Instructor updates student info | Login → Student → Edit → Save | 10 | MEDIUM |
| E2E-009 | Instructor deletes student | Login → Student → Delete → Confirm → Verify Cascade | 15 | MEDIUM |
| E2E-010 | Full student lifecycle | Create → Enroll → Attend → Grade → Complete → Archive | 25 | CRITICAL |

**Sub-Total:** 150 Tests (E2E)

---

## 📊 STUDENT MANAGEMENT TESTING SUMMARY

```
┌─────────────────────────────────────────────────────────────┐
│        STUDENT MANAGEMENT TESTING BREAKDOWN                  │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  3.1  CRUD Operations                                        │
│       ├─ Create (Frontend)              45 tests            │
│       ├─ Create (Backend)               55 tests            │
│       ├─ Create (Database)              20 tests            │
│       ├─ Read Operations               196 tests            │
│       ├─ Update Operations             120 tests            │
│       └─ Delete Operations              90 tests            │
│       SUB-TOTAL:                       526 tests            │
│                                                              │
│  3.2  Bulk Operations                                        │
│       ├─ Bulk Import                   150 tests            │
│       ├─ Bulk Export                    85 tests            │
│       └─ Bulk Update                    75 tests            │
│       SUB-TOTAL:                       310 tests            │
│                                                              │
│  3.3  Progress Tracking                                      │
│       ├─ Attendance Tracking           160 tests            │
│       ├─ Assignment Tracking            85 tests            │
│       └─ Progress Dashboard            110 tests            │
│       SUB-TOTAL:                       355 tests            │
│                                                              │
│  3.4  Grading & Assessment                                   │
│       ├─ Grade Entry                   120 tests            │
│       ├─ Grade Calculations             85 tests            │
│       └─ Grade Reports                 100 tests            │
│       SUB-TOTAL:                       305 tests            │
│                                                              │
│  3.5  Notes & Communication                                  │
│       ├─ Student Notes                 100 tests            │
│       └─ Communication                 105 tests            │
│       SUB-TOTAL:                       205 tests            │
│                                                              │
│  3.6  Security & Access Control        130 tests            │
│  3.7  Performance & Load Testing        80 tests            │
│  3.8  Integration Testing              180 tests            │
│  3.9  End-to-End Journeys              150 tests            │
│                                                              │
│  ═══════════════════════════════════════════════════════    │
│  GRAND TOTAL:                        2,241 tests            │
│  ═══════════════════════════════════════════════════════    │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## ⏱️ STUDENT MANAGEMENT TESTING TIMELINE

| Week | Focus Area | Tests | Hours |
|------|------------|-------|-------|
| **Week 1** | CRUD - Create Operations (F+B+DB) | 120 | 40h |
| **Week 2** | CRUD - Read/Update/Delete | 406 | 40h |
| **Week 3** | Bulk Operations | 310 | 40h |
| **Week 4** | Progress Tracking | 355 | 40h |
| **Week 5** | Grading & Assessment | 305 | 40h |
| **Week 6** | Notes & Communication | 205 | 40h |
| **Week 7** | Security & Performance | 210 | 40h |
| **Week 8** | Integration Tests | 180 | 40h |
| **Week 9** | E2E Journeys + Bug Fixes | 150 | 40h |
| **Week 10** | Regression & Final Sign-off | - | 40h |

**Total:** 10 weeks, 400 hours, 2,241 tests

---

## 💰 STUDENT MANAGEMENT COST ESTIMATE

| Resource | Role | Hours | Rate | Cost |
|----------|------|-------|------|------|
| Senior QA | Lead + Security + Integration | 120h | $60/h | $7,200 |
| QA Engineer 1 | CRUD + Bulk Ops | 160h | $50/h | $8,000 |
| QA Engineer 2 | Progress + Grading | 160h | $50/h | $8,000 |
| Junior QA | E2E + Support | 120h | $35/h | $4,200 |
| **TOTAL** | | **560h** | | **$27,400** |

---

## ✅ ACCEPTANCE CRITERIA (Student Management)

| Metric | Target | Status |
|--------|--------|--------|
| Total Tests | 2,241 | ⏳ Planned |
| Pass Rate | 100% | ⏳ Pending |
| Code Coverage | > 85% | ⏳ Pending |
| Critical Bugs | 0 | ⏳ Pending |
| High Priority Bugs | 0 | ⏳ Pending |
| API Response Time | < 500ms | ⏳ Pending |
| Bulk Import (1000 students) | < 30s | ⏳ Pending |
| Search Performance (10K students) | < 1s | ⏳ Pending |
| Security Audit | Passed | ⏳ Pending |
| GDPR Compliance | 100% | ⏳ Pending |

---

**Student Management Testing:** Updated from 180 tests → **2,241 tests** (12x increase)  
**Status:** Ready for execution by dedicated QA team

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
│  Total Features:                61                           │
│  Total Test Cases:              4,804 (↑ from 2,773)        │
│  Total Testing Hours:           1,660 hours (↑ from 1,360)  │
│  Timeline:                      21 weeks (↑ from 17)         │
│  Team Size:                     5 engineers                  │
│  Budget:                        $95,400 USD (↑ from $68k)   │
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
│  🔥 STUDENT MANAGEMENT (EXPANDED):                           │
│                                                              │
│  CRUD Operations:               526 tests                   │
│  Bulk Operations:               310 tests                   │
│  Progress Tracking:             355 tests                   │
│  Grading & Assessment:          305 tests                   │
│  Notes & Communication:         205 tests                   │
│  Security & Performance:        210 tests                   │
│  Integration Tests:             180 tests                   │
│  E2E Journeys:                  150 tests                   │
│  STUDENT TOTAL:               2,241 tests (12x increase)    │
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

- [ ] 4,804 test cases written
- [ ] 100% tests passing
- [ ] 🔥 Google OAuth: 100% tests passing
- [ ] 🔥 Mobile OTP: 100% tests passing
- [ ] 🔥 Google Calendar Sync: All scenarios tested
- [ ] 🔥 Google token validation in ALL APIs
- [ ] 🔥 Student Management: 2,241 tests passing (zero bugs)
- [ ] 🔥 Student CRUD: Multi-tenant isolation verified
- [ ] 🔥 Student Security: PII protection + GDPR compliant
- [ ] 🔥 Student Performance: Bulk import 5000 students < 2min
- [ ] Load testing: 13,500 concurrent users handled
- [ ] Database: 10M documents, < 200ms query time
- [ ] API: < 2s response time
- [ ] Google API rate limiting handled
- [ ] Zero critical/high bugs
- [ ] Code coverage > 80% (Student: > 85%)
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

| Category | Original Tests | Deep-Dive Tests | Total Tests |
|----------|---------------|-----------------|-------------|
| Core Features (1-2) | 853 | 0 | 853 |
| **Student Management (3)** 🔥 | **180** | **+2,061** | **2,241** |
| Core Features (4-11) | 1,460 | 0 | 1,460 |
| Load Testing | 50 | 30 | 80 |
| Database Testing | 100 | 20 | 120 |
| Google Integration | 150 | 0 | 150 |
| **Missing Features (1-25)** | **0** | **1,065** | **1,065** |
| **GRAND TOTAL** | **2,793** | **+3,176** | **5,969** |

### Realistic Estimates (Prioritized)

| Metric | Phase 1 (Critical) | Phase 2 (With Deep-Dive) |
|--------|-------------------|-------------------------|
| Total Test Cases | 2,773 | **4,804** |
| Total Hours | 1,360h | **1,660h** |
| Timeline | 17 weeks | **21 weeks (5.2 months)** |
| Team Size | 4 engineers | **5 engineers** |
| Budget | $68,000 | **$95,400** |

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

