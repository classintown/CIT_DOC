# 🎯 INSTRUCTOR MODULE - COMPREHENSIVE TESTING STRATEGY
## Complete End-to-End Testing Documentation

> **Mission**: Zero bugs in production. Every feature tested. Every edge case covered. Every user journey validated.

---

## 📋 TABLE OF CONTENTS

1. [Executive Summary](#executive-summary)
2. [Module Architecture Overview](#module-architecture-overview)
3. [Testing Frameworks & Tools](#testing-frameworks--tools)
4. [Testing Pyramid Strategy](#testing-pyramid-strategy)
5. [Feature-by-Feature Test Coverage](#feature-by-feature-test-coverage)
6. [Critical User Journeys](#critical-user-journeys)
7. [API Integration Testing](#api-integration-testing)
8. [State Management Testing](#state-management-testing)
9. [Error Handling & Edge Cases](#error-handling--edge-cases)
10. [Performance Testing](#performance-testing)
11. [Security Testing](#security-testing)
12. [Accessibility Testing](#accessibility-testing)
13. [Cross-Browser & Device Testing](#cross-browser--device-testing)
14. [Test Data Management](#test-data-management)
15. [Continuous Testing Strategy](#continuous-testing-strategy)
16. [Test Execution Plan](#test-execution-plan)
17. [Bug Prevention Checklist](#bug-prevention-checklist)

---

## 1. EXECUTIVE SUMMARY

### 🎓 Module Scope
The Instructor Module is the core platform for instructors to manage their teaching business, including:
- **Authentication & Authorization**
- **Class Management** (Schedule, Edit, Cancel)
- **Student Management** (Enrollment, Attendance, Progress Tracking)
- **Payment Management** (Receipts, Analytics, Verification)
- **Calendar & Scheduling**
- **Communications** (Chat, Messages, Announcements, Forum)
- **Resources & Materials**
- **Reports & Analytics**
- **Business Profile & Banking**
- **Settings & Permissions**
- **Tasks Management**
- **Support & Help Desk**

### 📊 Testing Statistics Target
- **Unit Test Coverage**: 90%+ line coverage
- **Integration Test Coverage**: 85%+ feature coverage
- **E2E Test Coverage**: 100% critical user journeys
- **API Test Coverage**: 100% endpoints used by instructor module
- **Performance**: All pages load < 3 seconds
- **Accessibility**: WCAG 2.1 AA compliance
- **Browser Support**: Chrome, Firefox, Safari, Edge (latest 2 versions)

---

## 2. MODULE ARCHITECTURE OVERVIEW

### 🏗️ Frontend Architecture

```
frontend/src/app/components/instructor/
├── instructor-auths/                    # Authentication flows
├── instructor-dashboard/                # Main dashboard & home
├── instructor-business-account/         # Business profile & banking
├── instructor-calendar/                 # Calendar integration
├── instructor-class-management/         # Class scheduling & management
│   ├── instructor-schedule-class/       # Create/edit class schedules
│   ├── instructor-my-classes/           # View & manage classes
│   ├── instructor-class-details/        # Detailed class view
│   └── attendance/                      # Attendance tracking
├── instructor-student-management/       # Student operations
│   ├── instructor-student-lists/        # Student list & CRUD
│   ├── progress-tracking/               # Student progress
│   ├── grading/                         # Grade management
│   └── instructor-notes/                # Student notes
├── instructor-listings/                 # Activities & locations
│   ├── instructor-activities/           # Activity management
│   ├── instructor-locations/            # Location management
│   ├── enrollment-list/                 # Enrollment tracking
│   └── payment-plan-list/               # Payment plans
├── payments/                            # Payment management
│   ├── payments-list/                   # Payment history
│   ├── enhanced-payments-list/          # Advanced payment features
│   └── payment-checkout/                # Checkout process
├── instructor-communications/           # Communication tools
│   ├── chat/                            # Real-time chat
│   ├── instructor-messages/             # Direct messages
│   ├── instructor-announcements/        # Announcements
│   └── instructor-forum/                # Discussion forum
├── instructor-resources/                # Learning resources
│   ├── instructor-library/              # Resource library
│   └── instructor-assignment-uploads/   # Assignment management
├── instructor-reports/                  # Analytics & reports
│   ├── instructor-performance/          # Performance metrics
│   └── instructor-feedback/             # Feedback analysis
├── instructor-settings/                 # User settings
│   ├── instructor-profile-settings/     # Profile management
│   └── instructor-notifications/        # Notification preferences
├── instructor-permission/               # Role & permissions
│   └── user-permission/                 # User management
├── tasks/                              # Task management
│   ├── task-list/                      # Task listing
│   ├── task-dashboard/                 # Task overview
│   └── task-progress/                  # Task tracking
└── instructor-support/                 # Help & support
    └── instructor-help-desk/           # Support tickets
```

### 🔌 Service Layer Architecture

```
frontend/src/app/services/
├── instructor/                         # Instructor-specific services
│   ├── enhanced-payments.service.ts
│   ├── instructor-class-details.service.ts
│   ├── receipt-management.service.ts
│   ├── payment-analytics.service.ts
│   ├── payment-calendar.service.ts
│   ├── assignment.service.ts
│   ├── grading.service.ts
│   └── library-resource.service.ts
├── common/                            # Shared services
│   ├── auth/                          # Authentication services
│   ├── error-handling/                # Error management
│   ├── loading/                       # Loading states
│   ├── message/                       # Toast notifications
│   ├── modal/                         # Modal dialogs
│   ├── calendar/                      # Calendar utilities
│   ├── geolocation/                   # Location services
│   ├── user-preferences/              # User preferences
│   └── validations/                   # Form validation
└── core/                             # Core application services
```

### 🔗 Backend API Endpoints

```
Backend API Structure:
/api/instructor/
├── /classes                           # Class management
│   ├── GET /                          # List classes
│   ├── POST /                         # Create class
│   ├── GET /:id                       # Get class details
│   ├── PUT /:id                       # Update class
│   ├── DELETE /:id                    # Delete class
│   ├── GET /:id/analytics             # Class analytics
│   ├── GET /:id/sessions              # Class sessions
│   ├── GET /:id/students              # Class students
│   └── GET /:id/materials             # Class materials
├── /payments                          # Payment management
│   ├── GET /                          # List payments
│   ├── POST /                         # Create payment
│   ├── PATCH /:id/verify              # Verify payment
│   ├── POST /bulk-verify              # Bulk verify
│   └── GET /export                    # Export payments
├── /calendar                          # Calendar operations
│   ├── POST /                         # Schedule event
│   ├── GET /events                    # Get events
│   ├── PUT /events/:id                # Update event
│   ├── DELETE /events/:id             # Delete event
│   └── GET /availability              # Check availability
├── /students                          # Student management
│   ├── GET /                          # List students
│   ├── POST /                         # Add student
│   ├── GET /:id                       # Get student details
│   ├── PUT /:id                       # Update student
│   └── DELETE /:id                    # Remove student
├── /enrollment                        # Enrollment management
│   ├── GET /                          # List enrollments
│   ├── POST /                         # Create enrollment
│   ├── PATCH /:id/status              # Update status
│   └── GET /enhanced-payments         # Enhanced payment list
├── /receipts                          # Receipt management
│   ├── GET /                          # List receipts
│   ├── POST /generate                 # Generate receipt
│   ├── GET /:id/download              # Download receipt
│   └── POST /:id/send-email           # Email receipt
├── /resources                         # Resource management
│   ├── GET /                          # List resources
│   ├── POST /                         # Upload resource
│   └── DELETE /:id                    # Delete resource
└── /reports                           # Analytics & reports
    ├── GET /performance               # Performance metrics
    ├── GET /feedback                  # Feedback summary
    └── GET /export                    # Export reports
```

---

## 3. TESTING FRAMEWORKS & TOOLS

### 🛠️ Current Tech Stack

#### Unit & Integration Testing
- **Framework**: Jasmine 4.6+
- **Test Runner**: Karma 6.4+
- **Coverage Tool**: Istanbul (via Angular CLI)
- **Assertions**: Jasmine matchers
- **Mocking**: Jasmine spies

#### End-to-End Testing
- **Framework**: Playwright 1.52+
- **Browsers**: Chromium, Firefox, WebKit
- **Reporter**: HTML Reporter
- **Visual Testing**: Playwright Screenshots
- **Network Mocking**: Playwright Route Mocking

#### API Testing
- **Tool**: Playwright API Testing
- **Alternative**: Postman/Newman for standalone API tests
- **Schema Validation**: JSON Schema validators

#### Additional Tools
- **Linting**: ESLint + Angular ESLint
- **Code Quality**: SonarQube (recommended)
- **Performance**: Lighthouse CI
- **Accessibility**: axe-core, Pa11y
- **Visual Regression**: Percy or Chromatic (recommended)

### 📦 Installation & Setup

```bash
# Install dependencies (if not already installed)
cd frontend
npm install

# Install Playwright browsers
npx playwright install

# Install additional testing utilities
npm install --save-dev @axe-core/playwright pa11y lighthouse
```

---

## 4. TESTING PYRAMID STRATEGY

### 🔺 Testing Pyramid

```
                    E2E Tests
                   (Critical Flows)
                  [200-300 tests]
                 /              \
                /                \
           Integration Tests
         (Component + Service)
          [500-700 tests]
         /                    \
        /                      \
    Unit Tests
  (Pure Logic)
 [1500-2000 tests]
```

### 📊 Test Distribution

| Test Type | Count Target | Execution Time | Frequency |
|-----------|--------------|----------------|-----------|
| **Unit Tests** | 1500-2000 | < 5 min | Every commit |
| **Integration Tests** | 500-700 | < 15 min | Every PR |
| **E2E Tests (Smoke)** | 50 critical | < 10 min | Every deployment |
| **E2E Tests (Full)** | 200-300 | < 60 min | Nightly |
| **Performance Tests** | 20-30 scenarios | < 30 min | Weekly |
| **Accessibility Tests** | All pages | < 20 min | Every PR |

---

## 5. FEATURE-BY-FEATURE TEST COVERAGE

### 🔐 5.1 AUTHENTICATION & AUTHORIZATION

#### Features to Test
1. **Email/Password Login**
2. **Mobile OTP Login**
3. **Google OAuth Login**
4. **Forgot Password**
5. **Reset Password**
6. **Session Management**
7. **Auto Logout**
8. **Remember Me**
9. **Multi-Device Sessions**

#### Unit Tests (30+ tests)

```typescript
// frontend/src/app/components/instructor/instructor-auths/instructor-login-modal-v2/instructor-login-modal-v2.component.spec.ts

describe('InstructorLoginModalV2Component - Unit Tests', () => {
  
  describe('Form Initialization', () => {
    it('should create login form with empty fields', () => {});
    it('should initialize OTP form with validation', () => {});
    it('should set default form mode to email login', () => {});
  });

  describe('Email Login', () => {
    it('should validate email format', () => {});
    it('should validate password min length', () => {});
    it('should call authService.login with correct params', () => {});
    it('should handle successful login response', () => {});
    it('should navigate to dashboard on success', () => {});
    it('should display error message on invalid credentials', () => {});
    it('should handle network errors gracefully', () => {});
    it('should store token in localStorage when rememberMe is true', () => {});
    it('should not store token when rememberMe is false', () => {});
  });

  describe('Mobile OTP Login', () => {
    it('should validate mobile number format', () => {});
    it('should send OTP on valid mobile number', () => {});
    it('should display OTP input after sending OTP', () => {});
    it('should validate OTP length (4-6 digits)', () => {});
    it('should verify OTP and login on correct OTP', () => {});
    it('should display error on incorrect OTP', () => {});
    it('should allow resending OTP after timeout', () => {});
    it('should disable resend button during cooldown', () => {});
  });

  describe('Google OAuth', () => {
    it('should initiate Google OAuth flow', () => {});
    it('should handle OAuth success callback', () => {});
    it('should handle OAuth cancellation', () => {});
    it('should handle OAuth errors', () => {});
  });

  describe('Form Validation', () => {
    it('should mark all fields as touched on submit with invalid form', () => {});
    it('should display validation errors for each field', () => {});
    it('should disable submit button when form is invalid', () => {});
    it('should enable submit button when form is valid', () => {});
  });

  describe('UI States', () => {
    it('should show loading spinner during login', () => {});
    it('should disable form during login', () => {});
    it('should hide loading spinner after login completes', () => {});
    it('should switch between email and mobile login modes', () => {});
  });

  describe('Session Management', () => {
    it('should get user location after successful login', () => {});
    it('should initialize push notifications', () => {});
    it('should close modal after successful login', () => {});
  });
});
```

#### Integration Tests (15+ tests)

```typescript
describe('InstructorLoginModalV2Component - Integration Tests', () => {
  
  it('should complete full email login flow', () => {
    // Test email login + navigation + session setup
  });
  
  it('should complete full mobile OTP flow', () => {
    // Test mobile + OTP send + verification + navigation
  });
  
  it('should handle login with expired token', () => {
    // Test token expiration and re-login
  });
  
  it('should sync user data after login', () => {
    // Test that user profile, preferences load correctly
  });
  
  it('should handle concurrent login attempts', () => {
    // Test race condition handling
  });
});
```

#### E2E Tests (20+ tests)

```typescript
// frontend/e2e/instructor-auth.spec.ts

import { test, expect } from '@playwright/test';

test.describe('Instructor Authentication E2E Tests', () => {
  
  test('should login with valid email and password', async ({ page }) => {
    await page.goto('/instructor/login');
    await page.fill('[name="email"]', 'instructor@test.com');
    await page.fill('[name="password"]', 'ValidPassword123!');
    await page.click('button[type="submit"]');
    
    await expect(page).toHaveURL(/\/instructor\/dashboard/);
    await expect(page.locator('text=Welcome')).toBeVisible();
  });
  
  test('should show error message for invalid credentials', async ({ page }) => {
    await page.goto('/instructor/login');
    await page.fill('[name="email"]', 'invalid@test.com');
    await page.fill('[name="password"]', 'WrongPassword');
    await page.click('button[type="submit"]');
    
    await expect(page.locator('text=Invalid credentials')).toBeVisible();
    await expect(page).toHaveURL(/\/instructor\/login/);
  });
  
  test('should complete mobile OTP login flow', async ({ page }) => {
    // Mock OTP API
    await page.route('**/api/auth/send-otp', async (route) => {
      await route.fulfill({ 
        status: 200, 
        body: JSON.stringify({ success: true, message: 'OTP sent' }) 
      });
    });
    
    await page.goto('/instructor/login');
    await page.click('text=Login with Mobile');
    await page.fill('[name="mobile"]', '+919876543210');
    await page.click('button:has-text("Send OTP")');
    
    await expect(page.locator('[name="otp"]')).toBeVisible();
    await page.fill('[name="otp"]', '123456');
    await page.click('button:has-text("Verify")');
    
    await expect(page).toHaveURL(/\/instructor\/dashboard/);
  });
  
  test('should handle session timeout and auto logout', async ({ page }) => {
    // Login first
    await loginAsInstructor(page);
    
    // Simulate session expiration by clearing token
    await page.evaluate(() => localStorage.removeItem('access_token'));
    
    // Try to access protected route
    await page.goto('/instructor/class-management/schedule-class');
    
    // Should redirect to login
    await expect(page).toHaveURL(/\/instructor\/login/);
    await expect(page.locator('text=Session expired')).toBeVisible();
  });
  
  test('should remember me and persist session', async ({ page, context }) => {
    await page.goto('/instructor/login');
    await page.fill('[name="email"]', 'instructor@test.com');
    await page.fill('[name="password"]', 'ValidPassword123!');
    await page.check('[name="rememberMe"]');
    await page.click('button[type="submit"]');
    
    await expect(page).toHaveURL(/\/instructor\/dashboard/);
    
    // Close and reopen browser
    await page.close();
    const newPage = await context.newPage();
    await newPage.goto('/instructor/dashboard');
    
    // Should still be logged in
    await expect(newPage).toHaveURL(/\/instructor\/dashboard/);
    await expect(newPage.locator('text=Welcome')).toBeVisible();
  });
  
  test('should handle Google OAuth login', async ({ page }) => {
    await page.goto('/instructor/login');
    
    // Mock Google OAuth popup
    const popupPromise = page.waitForEvent('popup');
    await page.click('button:has-text("Sign in with Google")');
    const popup = await popupPromise;
    
    // Simulate OAuth success
    await popup.evaluate(() => {
      window.opener.postMessage({
        type: 'GOOGLE_AUTH_SUCCESS',
        token: 'mock-oauth-token'
      }, '*');
    });
    
    await expect(page).toHaveURL(/\/instructor\/dashboard/);
  });
  
  test('should logout and clear session', async ({ page }) => {
    await loginAsInstructor(page);
    
    await page.click('[aria-label="User menu"]');
    await page.click('text=Logout');
    
    await expect(page).toHaveURL(/\/instructor\/login/);
    
    // Try to access protected route
    await page.goto('/instructor/dashboard');
    await expect(page).toHaveURL(/\/instructor\/login/);
  });
});
```

---

### 📚 5.2 CLASS MANAGEMENT

#### Features to Test
1. **Schedule Class (Duration-based)**
2. **Schedule Class (Count-based)**
3. **Edit Class Schedule**
4. **Delete Class**
5. **View My Classes**
6. **Class Details View**
7. **Attendance Tracking**
8. **Class Analytics**
9. **Availability Conflict Detection**
10. **Continuous Class Mode**
11. **Online vs In-person Classes**
12. **Payment Plan Setup**

#### Unit Tests (80+ tests)

```typescript
// frontend/src/app/components/instructor/instructor-class-management/instructor-schedule-class/instructor-schedule-class.component.spec.ts

describe('InstructorScheduleClassComponent - Unit Tests', () => {
  
  describe('Form Initialization', () => {
    it('should initialize with duration-based mode', () => {});
    it('should create form with all required controls', () => {});
    it('should add one empty time slot by default', () => {});
    it('should set default duration to 3 months', () => {});
    it('should initialize payment form controls', () => {});
  });

  describe('Duration-based Scheduling', () => {
    it('should add new time slot', () => {});
    it('should remove time slot', () => {});
    it('should not allow removing last time slot', () => {});
    it('should add individual slot within time slot', () => {});
    it('should remove individual slot', () => {});
    it('should populate calendar dates based on selected days', () => {});
    it('should handle multiple days selection', () => {});
    it('should generate correct date range for selected duration', () => {});
    it('should skip past dates when generating calendar', () => {});
  });

  describe('Count-based Scheduling', () => {
    it('should switch to count mode', () => {});
    it('should clear duration slots when switching to count', () => {});
    it('should add count time slot', () => {});
    it('should remove count time slot', () => {});
    it('should auto-fill day when date is selected', () => {});
    it('should validate date is in future', () => {});
    it('should sort count slots by date', () => {});
  });

  describe('Continuous Class Mode', () => {
    it('should set duration to 12 months when continuous enabled', () => {});
    it('should disable duration dropdown when continuous', () => {});
    it('should enable duration dropdown when continuous disabled', () => {});
    it('should reset duration when switching back from continuous', () => {});
  });

  describe('Availability Checking', () => {
    it('should call availability API for duration-based slots', () => {});
    it('should call availability API for count-based slots', () => {});
    it('should detect time conflicts', () => {});
    it('should mark conflicting slots in UI', () => {});
    it('should clear conflicts when slot times are changed', () => {});
    it('should check availability on location change', () => {});
    it('should check availability on instructor change', () => {});
    it('should debounce availability checks', () => {});
  });

  describe('Form Validation', () => {
    it('should validate activity is selected', () => {});
    it('should validate location for in-person classes', () => {});
    it('should validate class link for online classes', () => {});
    it('should validate capacity is positive number', () => {});
    it('should validate start time is before end time', () => {});
    it('should validate at least one time slot exists', () => {});
    it('should validate date is in future for count-based', () => {});
    it('should mark form as invalid when required fields empty', () => {});
  });

  describe('Payment Configuration', () => {
    it('should toggle full price option', () => {});
    it('should calculate drop-in price (125% of full)', () => {});
    it('should calculate monthly price (30% of full)', () => {});
    it('should disable other prices when free activity enabled', () => {});
    it('should validate at least one price option is enabled', () => {});
    it('should handle custom price inputs', () => {});
  });

  describe('Online vs In-person', () => {
    it('should show location field when in-person', () => {});
    it('should show class link field when online', () => {});
    it('should validate class link URL format', () => {});
    it('should skip availability check for online classes', () => {});
  });

  describe('Form Submission', () => {
    it('should call create API for new schedule', () => {});
    it('should call update API for editing schedule', () => {});
    it('should format data correctly for duration-based', () => {});
    it('should format data correctly for count-based', () => {});
    it('should include payment details in submission', () => {});
    it('should navigate to my-classes on success', () => {});
    it('should show error message on failure', () => {});
    it('should not submit if form is invalid', () => {});
  });

  describe('Edit Mode', () => {
    it('should load schedule data by ID', () => {});
    it('should populate form with loaded data', () => {});
    it('should handle duration-based schedule in edit', () => {});
    it('should handle count-based schedule in edit', () => {});
    it('should preserve past slots in edit mode', () => {});
    it('should only show future slots for editing', () => {});
  });

  describe('UI State Management', () => {
    it('should show loading indicator during API calls', () => {});
    it('should disable form during submission', () => {});
    it('should enable form after submission completes', () => {});
    it('should show success toast on save', () => {});
    it('should show error toast on failure', () => {});
  });

  describe('Activity & Location Filtering', () => {
    it('should load activities on init', () => {});
    it('should filter activities by search term', () => {});
    it('should load locations on init', () => {});
    it('should filter locations by search term', () => {});
  });
});
```

#### Integration Tests (40+ tests)

```typescript
describe('InstructorScheduleClassComponent - Integration Tests', () => {
  
  it('should create duration-based class with full workflow', async () => {
    // Select activity -> location -> time slots -> payment -> submit
  });
  
  it('should create count-based class with full workflow', async () => {
    // Switch mode -> add slots -> payment -> submit
  });
  
  it('should edit existing class and save changes', async () => {
    // Load schedule -> modify -> save -> verify
  });
  
  it('should detect and resolve availability conflicts', async () => {
    // Add slot -> detect conflict -> change time -> verify no conflict
  });
  
  it('should switch between online and in-person', async () => {
    // Toggle online -> verify UI changes -> submit
  });
  
  it('should calculate prices dynamically', async () => {
    // Enter full price -> verify calculations -> submit
  });
});
```

#### E2E Tests (30+ tests)

```typescript
// frontend/e2e/instructor-class-management.spec.ts

test.describe('Class Management E2E Tests', () => {
  
  test.beforeEach(async ({ page }) => {
    await loginAsInstructor(page);
    await page.goto('/instructor/class-management/schedule-class');
  });

  test('should create a duration-based class successfully', async ({ page }) => {
    // Mock APIs
    await mockActivitiesAPI(page);
    await mockLocationsAPI(page);
    await mockAvailabilityAPI(page);
    
    // Fill form
    await page.click('[data-testid="activity-dropdown"]');
    await page.click('text=Yoga');
    
    await page.click('[data-testid="location-dropdown"]');
    await page.click('text=Main Studio');
    
    await page.fill('[name="capacity"]', '20');
    
    // Add time slot
    await page.selectOption('[name="day"]', 'Monday');
    await page.fill('[name="start_time"]', '10:00');
    await page.fill('[name="end_time"]', '11:00');
    
    await page.selectOption('[name="duration"]', '3');
    
    // Next to payment
    await page.click('button:has-text("Next: Payment Details")');
    
    // Fill payment
    await page.fill('[name="full_price"]', '10000');
    
    // Verify auto-calculations
    await expect(page.locator('[name="drop_in_price"]')).toHaveValue('12500');
    await expect(page.locator('[name="monthly_price"]')).toHaveValue('3000');
    
    // Submit
    await page.click('button:has-text("Save")');
    
    // Verify navigation and success
    await expect(page).toHaveURL(/\/my-classes/);
    await expect(page.locator('text=Class created successfully')).toBeVisible();
  });
  
  test('should create count-based class successfully', async ({ page }) => {
    // Switch to count mode
    await page.click('input[value="count"]');
    
    // Select activity and location
    await page.click('[data-testid="activity-dropdown"]');
    await page.click('text=Dance');
    
    await page.click('[data-testid="location-dropdown"]');
    await page.click('text=Studio B');
    
    await page.fill('[name="capacity"]', '15');
    
    // Add first slot
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    await page.fill('[name="date-0"]', tomorrow.toISOString().split('T')[0]);
    await page.fill('[name="start-0"]', '14:00');
    await page.fill('[name="end-0"]', '15:00');
    
    // Add second slot
    await page.click('button:has-text("Add Slot")');
    const nextWeek = new Date();
    nextWeek.setDate(nextWeek.getDate() + 7);
    await page.fill('[name="date-1"]', nextWeek.toISOString().split('T')[0]);
    await page.fill('[name="start-1"]', '14:00');
    await page.fill('[name="end-1"]', '15:00');
    
    // Payment details
    await page.click('button:has-text("Next: Payment Details")');
    await page.fill('[name="full_price"]', '8000');
    
    // Submit
    await page.click('button:has-text("Save")');
    
    await expect(page).toHaveURL(/\/my-classes/);
    await expect(page.locator('text=Class created successfully')).toBeVisible();
  });
  
  test('should show validation errors for incomplete form', async ({ page }) => {
    // Try to submit without filling anything
    await page.click('button:has-text("Next: Payment Details")');
    
    // Verify errors
    await expect(page.locator('text=Activity is required')).toBeVisible();
    await expect(page.locator('text=Capacity is required')).toBeVisible();
    
    // Should not navigate away
    await expect(page).toHaveURL(/\/schedule-class/);
  });
  
  test('should detect and show availability conflicts', async ({ page }) => {
    // Mock conflict in availability
    await page.route('**/api/instructor/availability/busy-slots', async (route) => {
      await route.fulfill({
        status: 200,
        body: JSON.stringify({
          success: true,
          data: {
            busySlots: {
              'Monday': [{ start: '10:00', end: '11:00' }]
            }
          }
        })
      });
    });
    
    await page.click('[data-testid="activity-dropdown"]');
    await page.click('text=Yoga');
    
    await page.click('[data-testid="location-dropdown"]');
    await page.click('text=Main Studio');
    
    await page.fill('[name="capacity"]', '20');
    await page.selectOption('[name="day"]', 'Monday');
    await page.fill('[name="start_time"]', '10:00');
    await page.fill('[name="end_time"]', '11:00');
    
    // Wait for conflict detection
    await expect(page.locator('.conflict-warning')).toBeVisible();
    await expect(page.locator('text=Time slot conflicts')).toBeVisible();
  });
  
  test('should edit existing class', async ({ page }) => {
    // Navigate to my classes
    await page.goto('/instructor/class-management/my-classes');
    
    // Click edit on first class
    await page.click('[data-testid="edit-class-btn"]').first();
    
    // Verify form is populated
    await expect(page.locator('[name="capacity"]')).not.toHaveValue('');
    
    // Change capacity
    await page.fill('[name="capacity"]', '25');
    
    // Save changes
    await page.click('button:has-text("Save")');
    
    await expect(page).toHaveURL(/\/my-classes/);
    await expect(page.locator('text=Class updated successfully')).toBeVisible();
  });
  
  test('should handle continuous class mode', async ({ page }) => {
    await page.click('[data-testid="activity-dropdown"]');
    await page.click('text=Yoga');
    
    await page.click('[data-testid="location-dropdown"]');
    await page.click('text=Main Studio');
    
    await page.fill('[name="capacity"]', '20');
    await page.selectOption('[name="day"]', 'Monday');
    await page.fill('[name="start_time"]', '10:00');
    await page.fill('[name="end_time"]', '11:00');
    
    // Enable continuous
    await page.check('[name="is_continuous"]');
    
    // Verify duration is set to 12 and disabled
    await expect(page.locator('[name="duration"]')).toHaveValue('12');
    await expect(page.locator('[name="duration"]')).toBeDisabled();
    
    // Disable continuous
    await page.uncheck('[name="is_continuous"]');
    
    // Verify duration is enabled
    await expect(page.locator('[name="duration"]')).not.toBeDisabled();
  });
  
  test('should switch between online and in-person mode', async ({ page }) => {
    // Check online
    await page.check('[name="is_online"]');
    
    // Verify location field is hidden, link field is shown
    await expect(page.locator('[data-testid="location-dropdown"]')).not.toBeVisible();
    await expect(page.locator('[name="class_link"]')).toBeVisible();
    
    // Uncheck online
    await page.uncheck('[name="is_online"]');
    
    // Verify location field is shown, link field is hidden
    await expect(page.locator('[data-testid="location-dropdown"]')).toBeVisible();
    await expect(page.locator('[name="class_link"]')).not.toBeVisible();
  });
});
```

---

### 👥 5.3 STUDENT MANAGEMENT

#### Features to Test
1. **Student List (View, Filter, Sort)**
2. **Add New Student**
3. **Edit Student Details**
4. **Delete Student**
5. **Bulk Import Students**
6. **Progress Tracking**
7. **Attendance Management**
8. **Grading & Assessment**
9. **Student Notes**
10. **Student Detail View**

#### Test Coverage Summary

```
Unit Tests:        60+ tests
Integration Tests: 25+ tests
E2E Tests:         20+ tests
Total:             105+ tests
```

#### Key Test Scenarios

```typescript
// Student List
- Load and display student list
- Pagination (10, 25, 50, 100 per page)
- Search by name, email, mobile
- Filter by class, status, enrollment date
- Sort by name, date, attendance
- Export student list (CSV, Excel)

// CRUD Operations
- Create student with all required fields
- Validate email format and uniqueness
- Validate mobile number format
- Upload student profile image
- Edit student information
- Delete student (with confirmation)
- Bulk import from CSV/Excel
- Handle import errors gracefully

// Progress Tracking
- View student progress by class
- Update progress metrics
- Track milestone completion
- Generate progress reports
- Visualize progress charts

// Attendance
- Mark attendance for class session
- Bulk mark attendance
- View attendance history
- Calculate attendance percentage
- Generate attendance reports

// Grading
- Create grading rubric
- Assign grades to students
- View grade distribution
- Export grade reports
- Send grade notifications

// Notes
- Add notes for students
- Edit and delete notes
- Tag notes by category
- Search notes
- Filter notes by date/category
```

---

### 💰 5.4 PAYMENT MANAGEMENT

#### Features to Test
1. **Payment List (Enhanced)**
2. **Payment Verification**
3. **Bulk Payment Verification**
4. **Receipt Generation**
5. **Receipt Management**
6. **Payment Analytics**
7. **Payment Calendar**
8. **Export Payments**
9. **Refund Processing**
10. **Payment Trends**

#### Test Coverage Summary

```
Unit Tests:        70+ tests
Integration Tests: 30+ tests
E2E Tests:         25+ tests
Total:             125+ tests
```

---

### 📅 5.5 CALENDAR & SCHEDULING

#### Features to Test
1. **Calendar View (Month, Week, Day)**
2. **Event Creation**
3. **Event Editing**
4. **Event Deletion**
5. **Recurring Events**
6. **Availability Management**
7. **Conflict Detection**
8. **Google Calendar Integration**
9. **Event Reminders**
10. **Calendar Sync**

---

### 💬 5.6 COMMUNICATIONS

#### Features to Test
1. **Real-time Chat**
2. **Direct Messages**
3. **Announcements**
4. **Forum Discussions**
5. **Notifications**
6. **Email Integration**
7. **Message Search**
8. **File Attachments**
9. **Read Receipts**
10. **Typing Indicators**

---

### 📊 5.7 REPORTS & ANALYTICS

#### Features to Test
1. **Performance Dashboard**
2. **Revenue Analytics**
3. **Student Analytics**
4. **Attendance Reports**
5. **Feedback Analysis**
6. **Custom Reports**
7. **Data Export**
8. **Scheduled Reports**
9. **Visual Charts**
10. **Comparative Analysis**

---

### 📚 5.8 RESOURCES & MATERIALS

#### Features to Test
1. **Resource Library**
2. **File Upload**
3. **File Download**
4. **File Preview**
5. **Assignment Management**
6. **Assignment Submission**
7. **Assignment Grading**
8. **Resource Categories**
9. **Search & Filter**
10. **Access Control**

---

## 6. CRITICAL USER JOURNEYS

### 🎯 Journey 1: Complete Class Creation & Management

```
Steps:
1. Login as instructor
2. Navigate to Schedule Class
3. Select activity and location
4. Configure time slots
5. Set pricing
6. Save class
7. View in My Classes
8. Edit class details
9. Add students to class
10. Mark attendance
11. Track progress
12. Generate reports

Test Coverage: E2E test for complete flow
```

### 🎯 Journey 2: Student Enrollment to Payment

```
Steps:
1. Create enrollment
2. Generate payment plan
3. Send payment link to student
4. Student makes payment
5. Verify payment
6. Generate receipt
7. Send receipt via email
8. Update enrollment status

Test Coverage: E2E test with API mocking
```

### 🎯 Journey 3: Comprehensive Reporting

```
Steps:
1. Navigate to Reports
2. Select date range
3. Filter by class/student
4. View analytics
5. Export to PDF/Excel
6. Schedule recurring reports
7. Share with stakeholders

Test Coverage: E2E + Performance testing
```

---

## 7. API INTEGRATION TESTING

### 🔌 Test Strategy

```typescript
// Example API integration test structure

describe('Instructor API Integration Tests', () => {
  
  describe('Class Management APIs', () => {
    
    test('POST /api/instructor/classes - Create class', async ({ request }) => {
      const response = await request.post('/api/instructor/classes', {
        data: {
          activity_id: 'activity123',
          location_id: 'location456',
          capacity: 20,
          time_slots: [
            { day: 'Monday', start: '10:00', end: '11:00' }
          ],
          duration: 3,
          payment: {
            full_price: 10000,
            drop_in_price: 12500,
            monthly_price: 3000
          }
        },
        headers: {
          'Authorization': `Bearer ${authToken}`
        }
      });
      
      expect(response.ok()).toBeTruthy();
      expect(response.status()).toBe(201);
      
      const data = await response.json();
      expect(data.success).toBe(true);
      expect(data.data).toHaveProperty('_id');
      expect(data.data.capacity).toBe(20);
    });
    
    test('GET /api/instructor/classes - List classes', async ({ request }) => {
      const response = await request.get('/api/instructor/classes', {
        params: { page: 1, limit: 10 },
        headers: { 'Authorization': `Bearer ${authToken}` }
      });
      
      expect(response.ok()).toBeTruthy();
      const data = await response.json();
      expect(data.data).toBeInstanceOf(Array);
      expect(data.total).toBeGreaterThanOrEqual(0);
    });
    
    test('GET /api/instructor/classes/:id - Get class details', async ({ request }) => {
      const classId = 'class123';
      const response = await request.get(`/api/instructor/classes/${classId}`, {
        headers: { 'Authorization': `Bearer ${authToken}` }
      });
      
      expect(response.ok()).toBeTruthy();
      const data = await response.json();
      expect(data.data._id).toBe(classId);
      expect(data.data).toHaveProperty('activity_name');
      expect(data.data).toHaveProperty('capacity');
    });
    
    test('PUT /api/instructor/classes/:id - Update class', async ({ request }) => {
      const classId = 'class123';
      const response = await request.put(`/api/instructor/classes/${classId}`, {
        data: { capacity: 25 },
        headers: { 'Authorization': `Bearer ${authToken}` }
      });
      
      expect(response.ok()).toBeTruthy();
      const data = await response.json();
      expect(data.data.capacity).toBe(25);
    });
    
    test('DELETE /api/instructor/classes/:id - Delete class', async ({ request }) => {
      const classId = 'class123';
      const response = await request.delete(`/api/instructor/classes/${classId}`, {
        headers: { 'Authorization': `Bearer ${authToken}` }
      });
      
      expect(response.ok()).toBeTruthy();
      expect(response.status()).toBe(200);
    });
  });
  
  describe('Payment APIs', () => {
    
    test('GET /api/enrollment/enhanced-payments', async ({ request }) => {
      const response = await request.get('/api/enrollment/enhanced-payments', {
        params: { 
          page: 1, 
          limit: 15, 
          status: 'completed' 
        },
        headers: { 'Authorization': `Bearer ${authToken}` }
      });
      
      expect(response.ok()).toBeTruthy();
      const data = await response.json();
      expect(data.data).toBeInstanceOf(Array);
    });
    
    test('PATCH /api/enrollment/payments/:id/verify', async ({ request }) => {
      const paymentId = 'payment123';
      const response = await request.patch(
        `/api/enrollment/payments/${paymentId}/verify`,
        {
          data: { status: 'verified', notes: 'Verified by instructor' },
          headers: { 'Authorization': `Bearer ${authToken}` }
        }
      );
      
      expect(response.ok()).toBeTruthy();
      const data = await response.json();
      expect(data.data.verificationStatus.instructor).toBe(true);
    });
  });
  
  describe('Error Handling', () => {
    
    test('should return 401 for unauthenticated requests', async ({ request }) => {
      const response = await request.get('/api/instructor/classes');
      expect(response.status()).toBe(401);
    });
    
    test('should return 400 for invalid request body', async ({ request }) => {
      const response = await request.post('/api/instructor/classes', {
        data: { invalid_field: 'invalid_value' },
        headers: { 'Authorization': `Bearer ${authToken}` }
      });
      
      expect(response.status()).toBe(400);
      const data = await response.json();
      expect(data.success).toBe(false);
      expect(data.message).toContain('validation');
    });
    
    test('should return 404 for non-existent resource', async ({ request }) => {
      const response = await request.get('/api/instructor/classes/nonexistent', {
        headers: { 'Authorization': `Bearer ${authToken}` }
      });
      
      expect(response.status()).toBe(404);
    });
  });
});
```

### 📋 API Test Checklist

For each API endpoint, test:

- ✅ **Success Response** (200/201)
- ✅ **Request Validation** (400)
- ✅ **Authentication** (401)
- ✅ **Authorization** (403)
- ✅ **Not Found** (404)
- ✅ **Server Error** (500)
- ✅ **Rate Limiting** (429)
- ✅ **Request Timeout**
- ✅ **Network Failure**
- ✅ **Response Schema Validation**
- ✅ **Pagination**
- ✅ **Filtering**
- ✅ **Sorting**
- ✅ **Search**

---

## 8. STATE MANAGEMENT TESTING

### 📦 Service State Testing

```typescript
describe('EnhancedPaymentsService - State Management', () => {
  
  it('should maintain payments state', () => {
    const service = TestBed.inject(EnhancedPaymentsService);
    const mockPayments = [/* mock data */];
    
    service.updatePaymentsState(mockPayments);
    
    service.payments$.subscribe(payments => {
      expect(payments).toEqual(mockPayments);
    });
  });
  
  it('should update stats in real-time', () => {
    const service = TestBed.inject(EnhancedPaymentsService);
    const mockStats = {
      totalPayments: 100,
      totalAmount: 50000,
      // ... more stats
    };
    
    service.updateStatsState(mockStats);
    
    service.stats$.subscribe(stats => {
      expect(stats).toEqual(mockStats);
    });
  });
  
  it('should handle concurrent state updates', (done) => {
    const service = TestBed.inject(EnhancedPaymentsService);
    
    // Simulate rapid updates
    service.updatePaymentsState([/* data 1 */]);
    service.updatePaymentsState([/* data 2 */]);
    service.updatePaymentsState([/* data 3 */]);
    
    // Should have latest data
    service.payments$.pipe(take(1)).subscribe(payments => {
      expect(payments).toEqual([/* data 3 */]);
      done();
    });
  });
});
```

---

## 9. ERROR HANDLING & EDGE CASES

### 🚨 Error Scenarios to Test

#### Network Errors
```typescript
test('should handle network timeout', async ({ page }) => {
  await page.route('**/api/instructor/classes', async (route) => {
    await new Promise(resolve => setTimeout(resolve, 30000)); // Timeout
  });
  
  await page.goto('/instructor/class-management/my-classes');
  
  await expect(page.locator('text=Request timeout')).toBeVisible();
});

test('should handle network offline', async ({ page, context }) => {
  await context.setOffline(true);
  
  await page.goto('/instructor/class-management/schedule-class');
  await page.click('button:has-text("Save")');
  
  await expect(page.locator('text=No internet connection')).toBeVisible();
});
```

#### Form Validation Errors
```typescript
test('should validate email format', async ({ page }) => {
  await page.fill('[name="email"]', 'invalid-email');
  await page.blur('[name="email"]');
  
  await expect(page.locator('text=Invalid email format')).toBeVisible();
});

test('should validate mobile number', async ({ page }) => {
  await page.fill('[name="mobile"]', '123'); // Too short
  await page.blur('[name="mobile"]');
  
  await expect(page.locator('text=Invalid mobile number')).toBeVisible();
});
```

#### API Errors
```typescript
test('should handle 500 server error', async ({ page }) => {
  await page.route('**/api/instructor/classes', async (route) => {
    await route.fulfill({ status: 500, body: 'Internal Server Error' });
  });
  
  await page.goto('/instructor/class-management/my-classes');
  
  await expect(page.locator('text=Something went wrong')).toBeVisible();
});

test('should handle 403 forbidden', async ({ page }) => {
  await page.route('**/api/instructor/classes', async (route) => {
    await route.fulfill({ status: 403, body: 'Forbidden' });
  });
  
  await page.goto('/instructor/class-management/my-classes');
  
  await expect(page.locator('text=Access denied')).toBeVisible();
});
```

### 🔍 Edge Cases

```typescript
// Boundary Values
- Test capacity = 0
- Test capacity = 1000
- Test negative capacity
- Test very long strings in text fields
- Test special characters in input
- Test Unicode characters
- Test empty arrays/objects

// Race Conditions
- Double-click submit button
- Rapid form changes
- Concurrent API calls
- Multiple browser tabs
- Session expiration during action

// Data Issues
- Missing required data
- Null/undefined values
- Malformed JSON responses
- Large datasets (1000+ records)
- Empty lists/arrays
- Duplicate entries

// Browser Specific
- Browser back/forward buttons
- Page reload during action
- Tab switching
- Window resizing
- Browser extensions interference
```

---

## 10. PERFORMANCE TESTING

### ⚡ Performance Metrics

```typescript
// Lighthouse CI Configuration
// .lighthouserc.json

{
  "ci": {
    "collect": {
      "url": [
        "http://localhost:4200/instructor/dashboard",
        "http://localhost:4200/instructor/class-management/schedule-class",
        "http://localhost:4200/instructor/class-management/my-classes",
        "http://localhost:4200/instructor/student-management",
        "http://localhost:4200/instructor/payments"
      ],
      "numberOfRuns": 3
    },
    "assert": {
      "preset": "lighthouse:recommended",
      "assertions": {
        "first-contentful-paint": ["error", { "maxNumericValue": 2000 }],
        "largest-contentful-paint": ["error", { "maxNumericValue": 3000 }],
        "cumulative-layout-shift": ["error", { "maxNumericValue": 0.1 }],
        "total-blocking-time": ["error", { "maxNumericValue": 300 }],
        "speed-index": ["error", { "maxNumericValue": 3000 }],
        "interactive": ["error", { "maxNumericValue": 4000 }]
      }
    },
    "upload": {
      "target": "temporary-public-storage"
    }
  }
}
```

### 📊 Performance Test Cases

```typescript
test.describe('Performance Tests', () => {
  
  test('should load dashboard in < 3 seconds', async ({ page }) => {
    const startTime = Date.now();
    
    await page.goto('/instructor/dashboard');
    await page.waitForLoadState('networkidle');
    
    const loadTime = Date.now() - startTime;
    expect(loadTime).toBeLessThan(3000);
  });
  
  test('should handle 1000 students without performance degradation', async ({ page }) => {
    await page.goto('/instructor/student-management');
    
    // Measure initial load time
    const startTime = Date.now();
    await page.waitForLoadState('networkidle');
    const initialLoadTime = Date.now() - startTime;
    
    // Load 1000 students
    await mockLargeStudentList(page, 1000);
    await page.reload();
    
    const reloadStartTime = Date.now();
    await page.waitForLoadState('networkidle');
    const reloadTime = Date.now() - reloadStartTime;
    
    // Reload time should not be significantly longer
    expect(reloadTime).toBeLessThan(initialLoadTime * 1.5);
  });
  
  test('should handle rapid navigation without memory leaks', async ({ page }) => {
    const routes = [
      '/instructor/dashboard',
      '/instructor/class-management/my-classes',
      '/instructor/student-management',
      '/instructor/payments',
      '/instructor/calendar'
    ];
    
    for (let i = 0; i < 10; i++) {
      for (const route of routes) {
        await page.goto(route);
        await page.waitForLoadState('networkidle');
      }
    }
    
    // Check memory usage (browser-specific)
    const metrics = await page.metrics();
    expect(metrics.JSHeapUsedSize).toBeLessThan(100 * 1024 * 1024); // < 100MB
  });
  
  test('should render large tables efficiently', async ({ page }) => {
    await mockLargePaymentList(page, 500);
    await page.goto('/instructor/payments');
    
    const startTime = Date.now();
    await page.waitForSelector('table tbody tr');
    const renderTime = Date.now() - startTime;
    
    expect(renderTime).toBeLessThan(2000);
    
    // Test scrolling performance
    await page.evaluate(() => {
      window.scrollTo(0, document.body.scrollHeight);
    });
    
    await page.waitForTimeout(100);
    expect(await page.locator('table tbody tr').count()).toBeGreaterThan(0);
  });
  
  test('should optimize image loading', async ({ page }) => {
    await page.goto('/instructor/student-management');
    
    // Check that images use lazy loading
    const images = await page.locator('img').all();
    for (const img of images) {
      const loading = await img.getAttribute('loading');
      expect(loading).toBe('lazy');
    }
  });
});
```

---

## 11. SECURITY TESTING

### 🔒 Security Test Cases

```typescript
test.describe('Security Tests', () => {
  
  test('should not expose sensitive data in localStorage', async ({ page }) => {
    await loginAsInstructor(page);
    
    const localStorage = await page.evaluate(() => {
      return Object.keys(localStorage).map(key => ({
        key,
        value: localStorage.getItem(key)
      }));
    });
    
    for (const item of localStorage) {
      // Should not store plain passwords
      expect(item.value).not.toContain('password');
      expect(item.value).not.toContain('secret');
      
      // Tokens should be encrypted or hashed
      if (item.key.includes('token')) {
        expect(item.value.length).toBeGreaterThan(50); // Ensure it's a proper token
      }
    }
  });
  
  test('should sanitize user inputs to prevent XSS', async ({ page }) => {
    await loginAsInstructor(page);
    await page.goto('/instructor/student-management/create');
    
    const xssPayload = '<script>alert("XSS")</script>';
    await page.fill('[name="name"]', xssPayload);
    await page.click('button:has-text("Save")');
    
    // Should not execute script
    const alerts = [];
    page.on('dialog', dialog => {
      alerts.push(dialog.message());
      dialog.dismiss();
    });
    
    await page.waitForTimeout(1000);
    expect(alerts).toHaveLength(0);
  });
  
  test('should validate CSRF tokens', async ({ page, request }) => {
    // Try to make request without CSRF token
    const response = await request.post('/api/instructor/classes', {
      data: { /* class data */ }
      // No CSRF token
    });
    
    expect(response.status()).toBe(403);
  });
  
  test('should enforce rate limiting', async ({ page, request }) => {
    const requests = [];
    
    // Make 100 rapid requests
    for (let i = 0; i < 100; i++) {
      requests.push(
        request.get('/api/instructor/classes', {
          headers: { 'Authorization': `Bearer ${authToken}` }
        })
      );
    }
    
    const responses = await Promise.all(requests);
    
    // Some should be rate limited
    const rateLimited = responses.filter(r => r.status() === 429);
    expect(rateLimited.length).toBeGreaterThan(0);
  });
  
  test('should prevent SQL injection in search', async ({ page }) => {
    await loginAsInstructor(page);
    await page.goto('/instructor/student-management');
    
    const sqlInjection = "'; DROP TABLE students; --";
    await page.fill('[name="search"]', sqlInjection);
    await page.press('[name="search"]', 'Enter');
    
    // Should handle gracefully without error
    await expect(page.locator('text=No students found')).toBeVisible();
  });
  
  test('should enforce authentication on protected routes', async ({ page }) => {
    // Try to access without login
    await page.goto('/instructor/dashboard');
    
    // Should redirect to login
    await expect(page).toHaveURL(/\/instructor\/login/);
  });
  
  test('should enforce role-based access control', async ({ page }) => {
    // Login as student
    await loginAsStudent(page);
    
    // Try to access instructor routes
    await page.goto('/instructor/dashboard');
    
    // Should show access denied or redirect
    await expect(page.locator('text=Access denied')).toBeVisible();
  });
});
```

---

## 12. ACCESSIBILITY TESTING

### ♿ Accessibility Standards

**Target**: WCAG 2.1 Level AA Compliance

```typescript
// Using @axe-core/playwright

import { injectAxe, checkA11y } from 'axe-playwright';

test.describe('Accessibility Tests', () => {
  
  test.beforeEach(async ({ page }) => {
    await loginAsInstructor(page);
  });
  
  test('Dashboard should be accessible', async ({ page }) => {
    await page.goto('/instructor/dashboard');
    await injectAxe(page);
    
    const violations = await checkA11y(page);
    expect(violations).toHaveLength(0);
  });
  
  test('Schedule Class form should be accessible', async ({ page }) => {
    await page.goto('/instructor/class-management/schedule-class');
    await injectAxe(page);
    
    // Check specific WCAG rules
    const violations = await checkA11y(page, null, {
      rules: {
        'color-contrast': { enabled: true },
        'label': { enabled: true },
        'aria-required-attr': { enabled: true }
      }
    });
    
    expect(violations).toHaveLength(0);
  });
  
  test('should support keyboard navigation', async ({ page }) => {
    await page.goto('/instructor/class-management/schedule-class');
    
    // Tab through form elements
    await page.keyboard.press('Tab');
    await expect(page.locator('[name="activity"]')).toBeFocused();
    
    await page.keyboard.press('Tab');
    await expect(page.locator('[name="location"]')).toBeFocused();
    
    await page.keyboard.press('Tab');
    await expect(page.locator('[name="capacity"]')).toBeFocused();
  });
  
  test('should have proper ARIA labels', async ({ page }) => {
    await page.goto('/instructor/class-management/my-classes');
    
    const buttons = await page.locator('button').all();
    for (const button of buttons) {
      const ariaLabel = await button.getAttribute('aria-label');
      const text = await button.textContent();
      
      // Either has aria-label or visible text
      expect(ariaLabel || text).toBeTruthy();
    }
  });
  
  test('should announce dynamic content changes to screen readers', async ({ page }) => {
    await page.goto('/instructor/class-management/schedule-class');
    
    // Check for aria-live regions
    const liveRegions = await page.locator('[aria-live]').count();
    expect(liveRegions).toBeGreaterThan(0);
    
    // Trigger form submission
    await page.click('button:has-text("Save")');
    
    // Success message should be in aria-live region
    const successMsg = page.locator('[aria-live] text=successfully');
    await expect(successMsg).toBeVisible();
  });
  
  test('should have sufficient color contrast', async ({ page }) => {
    await page.goto('/instructor/dashboard');
    await injectAxe(page);
    
    const violations = await checkA11y(page, null, {
      rules: { 'color-contrast': { enabled: true } }
    });
    
    expect(violations).toHaveLength(0);
  });
  
  test('should have proper heading hierarchy', async ({ page }) => {
    await page.goto('/instructor/dashboard');
    
    const headings = await page.locator('h1, h2, h3, h4, h5, h6').all();
    
    let previousLevel = 0;
    for (const heading of headings) {
      const tagName = await heading.evaluate(el => el.tagName);
      const level = parseInt(tagName.replace('H', ''));
      
      // Level should not skip (e.g., h1 -> h3)
      expect(level).toBeLessThanOrEqual(previousLevel + 1);
      previousLevel = level;
    }
  });
});
```

---

## 13. CROSS-BROWSER & DEVICE TESTING

### 🌐 Browser Matrix

| Browser | Versions | Priority |
|---------|----------|----------|
| Chrome | Latest 2 | P0 |
| Firefox | Latest 2 | P0 |
| Safari | Latest 2 | P0 |
| Edge | Latest 2 | P1 |
| Chrome Mobile | Latest | P1 |
| Safari Mobile | Latest | P1 |

### 📱 Device Matrix

| Device Type | Screen Sizes | Priority |
|-------------|--------------|----------|
| Desktop | 1920x1080, 1366x768 | P0 |
| Tablet | 768x1024, 1024x768 | P1 |
| Mobile | 375x667, 414x896 | P0 |

### 🧪 Cross-Browser Test Example

```typescript
// playwright.config.ts

export default defineConfig({
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },
    {
      name: 'Mobile Chrome',
      use: { ...devices['Pixel 5'] },
    },
    {
      name: 'Mobile Safari',
      use: { ...devices['iPhone 12'] },
    },
    {
      name: 'Tablet',
      use: { ...devices['iPad Pro'] },
    },
  ],
});

// Run: npx playwright test --project=chromium
// Run: npx playwright test --project=firefox
// Run: npx playwright test --project=webkit
// Run all: npx playwright test
```

---

## 14. TEST DATA MANAGEMENT

### 📊 Test Data Strategy

#### Test Data Categories

1. **Valid Data**
   - Standard test users
   - Sample classes
   - Test students
   - Mock payments

2. **Edge Case Data**
   - Boundary values
   - Special characters
   - Maximum lengths
   - Minimum values

3. **Invalid Data**
   - Malformed inputs
   - Missing required fields
   - Invalid formats
   - SQL injection attempts

#### Test Data Setup

```typescript
// test-data/instructor-test-data.ts

export const TEST_INSTRUCTORS = {
  valid: {
    email: 'instructor@test.com',
    password: 'TestPass123!',
    fullName: 'Test Instructor',
    mobile: '+919876543210'
  },
  withoutClasses: {
    email: 'new.instructor@test.com',
    password: 'TestPass123!',
    fullName: 'New Instructor',
    mobile: '+919876543211'
  }
};

export const TEST_ACTIVITIES = [
  {
    _id: 'activity1',
    activity_name: 'Yoga',
    category: 'Fitness',
    description: 'Yoga classes for all levels'
  },
  {
    _id: 'activity2',
    activity_name: 'Dance',
    category: 'Arts',
    description: 'Dance classes'
  }
];

export const TEST_LOCATIONS = [
  {
    _id: 'location1',
    title: 'Main Studio',
    address: '123 Main St, City',
    latitude: 12.9716,
    longitude: 77.5946
  }
];

export const TEST_CLASSES = [
  {
    _id: 'class1',
    activity_id: 'activity1',
    location_id: 'location1',
    capacity: 20,
    classType: 'duration',
    duration: 3,
    time_slots: [
      { day: 'Monday', slots: [{ start: '10:00', end: '11:00' }] }
    ]
  }
];
```

#### Data Cleanup

```typescript
// test-helpers/cleanup.ts

export async function cleanupTestData() {
  // Delete test classes
  await deleteTestClasses();
  
  // Delete test students
  await deleteTestStudents();
  
  // Delete test payments
  await deleteTestPayments();
  
  // Reset instructor state
  await resetInstructorData();
}

// Use in tests
test.afterEach(async () => {
  await cleanupTestData();
});
```

---

## 15. CONTINUOUS TESTING STRATEGY

### 🔄 CI/CD Integration

```yaml
# .github/workflows/test.yml

name: Continuous Testing

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: cd frontend && npm ci
      - run: cd frontend && npm run test -- --watch=false --browsers=ChromeHeadless
      - run: cd frontend && npm run test -- --code-coverage
      - uses: codecov/codecov-action@v3
        with:
          files: ./frontend/coverage/lcov.info

  integration-tests:
    runs-on: ubuntu-latest
    needs: unit-tests
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - run: cd frontend && npm ci
      - run: npm run test:integration

  e2e-tests:
    runs-on: ubuntu-latest
    needs: integration-tests
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - run: cd frontend && npm ci
      - run: cd frontend && npx playwright install
      - run: cd frontend && npx playwright test
      - uses: actions/upload-artifact@v3
        if: always()
        with:
          name: playwright-report
          path: frontend/playwright-report/

  accessibility-tests:
    runs-on: ubuntu-latest
    needs: unit-tests
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - run: cd frontend && npm ci
      - run: npm run test:a11y

  performance-tests:
    runs-on: ubuntu-latest
    needs: e2e-tests
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - run: cd frontend && npm ci
      - run: npm run lighthouse
```

---

## 16. TEST EXECUTION PLAN

### 📅 Testing Schedule

#### Daily (Automated)
- ✅ Unit tests on every commit
- ✅ Linting & code quality checks
- ✅ Quick smoke tests (critical paths)

#### Per Pull Request (Automated)
- ✅ Full unit test suite
- ✅ Integration tests
- ✅ Accessibility tests
- ✅ Code coverage report (min 90%)

#### Pre-Deployment (Automated + Manual)
- ✅ Full E2E test suite
- ✅ Performance tests
- ✅ Security scan
- ✅ Cross-browser tests
- ✅ Manual exploratory testing (30 min)

#### Weekly (Automated)
- ✅ Performance regression tests
- ✅ Load testing
- ✅ Security vulnerability scan
- ✅ Accessibility audit

#### Monthly (Manual)
- ✅ Comprehensive manual testing
- ✅ User acceptance testing
- ✅ Edge case exploration
- ✅ Device compatibility testing

### 🎯 Test Execution Checklist

Before each release:

- [ ] All unit tests passing (1500+ tests)
- [ ] All integration tests passing (500+ tests)
- [ ] All E2E tests passing (200+ tests)
- [ ] Code coverage > 90%
- [ ] No critical security vulnerabilities
- [ ] Performance benchmarks met
- [ ] Accessibility score > 95
- [ ] Cross-browser tests passing
- [ ] Manual testing sign-off
- [ ] Test report generated and reviewed

---

## 17. BUG PREVENTION CHECKLIST

### ✅ Pre-Development

- [ ] Requirements clearly defined
- [ ] User stories have acceptance criteria
- [ ] Edge cases identified
- [ ] API contracts documented
- [ ] Test cases written before coding

### ✅ During Development

- [ ] Write unit tests alongside code
- [ ] Follow coding standards
- [ ] Use TypeScript strict mode
- [ ] Lint code continuously
- [ ] Handle errors gracefully
- [ ] Validate all inputs
- [ ] Use proper error boundaries
- [ ] Add loading states
- [ ] Implement retry logic
- [ ] Log errors properly

### ✅ Before Commit

- [ ] Run unit tests locally
- [ ] Run linter
- [ ] Test manually in browser
- [ ] Check for console errors
- [ ] Review code changes
- [ ] Update documentation
- [ ] Add/update tests for changes

### ✅ Code Review

- [ ] Tests cover new functionality
- [ ] Edge cases handled
- [ ] Error handling present
- [ ] No hardcoded values
- [ ] Accessibility considered
- [ ] Performance optimized
- [ ] Security reviewed
- [ ] Documentation updated

### ✅ Before Deployment

- [ ] All tests passing in CI/CD
- [ ] Manual testing completed
- [ ] Performance benchmarks met
- [ ] Security scan passed
- [ ] Database migrations tested
- [ ] Rollback plan ready
- [ ] Monitoring alerts configured

---

## 📊 APPENDIX A: TEST METRICS & KPIs

### Key Metrics to Track

1. **Test Coverage**
   - Line Coverage: Target > 90%
   - Branch Coverage: Target > 85%
   - Function Coverage: Target > 90%

2. **Test Execution**
   - Total Tests: ~2000+
   - Pass Rate: Target > 98%
   - Execution Time: < 60 min (full suite)
   - Flaky Tests: < 2%

3. **Defect Metrics**
   - Defects Found in Testing: Track trend
   - Defects Found in Production: Target < 5/release
   - Defect Resolution Time: Target < 48 hours
   - Defect Recurrence Rate: Target < 5%

4. **Performance Metrics**
   - Page Load Time: < 3 seconds
   - API Response Time: < 500ms
   - Time to Interactive: < 4 seconds
   - Lighthouse Score: > 90

---

## 📚 APPENDIX B: TESTING RESOURCES

### Documentation
- [Playwright Documentation](https://playwright.dev/)
- [Jasmine Documentation](https://jasmine.github.io/)
- [Angular Testing Guide](https://angular.io/guide/testing)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)

### Tools
- **VS Code Extensions**: Playwright Test, Jest, ESLint
- **Browser Extensions**: axe DevTools, WAVE
- **CI/CD**: GitHub Actions, Jenkins, CircleCI
- **Monitoring**: Sentry, LogRocket, New Relic

---

## 🎉 CONCLUSION

This comprehensive testing strategy ensures:

✅ **Zero Critical Bugs** - Every feature tested thoroughly  
✅ **Complete Coverage** - Unit, Integration, E2E, Performance, Security  
✅ **Automated Testing** - CI/CD pipeline runs all tests  
✅ **User Confidence** - Extensive manual testing complements automation  
✅ **Continuous Improvement** - Metrics tracked and analyzed  
✅ **Fast Feedback** - Tests run quickly and provide clear results  

**With this strategy, your instructor module will be production-ready with minimal bugs!**

---

## 📞 SUPPORT

For questions or clarifications about testing strategy:
- Review this document
- Check test examples in codebase
- Run test commands locally
- Review test reports in CI/CD

**Happy Testing! 🚀**

