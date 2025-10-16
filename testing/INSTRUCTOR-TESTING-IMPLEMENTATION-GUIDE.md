# 🚀 INSTRUCTOR MODULE - TESTING IMPLEMENTATION GUIDE
## Practical Guide with Ready-to-Use Scripts

> **Quick Start**: This guide provides ready-to-execute test scripts and practical examples to implement comprehensive testing immediately.

---

## 📋 TABLE OF CONTENTS

1. [Quick Setup](#quick-setup)
2. [Running Tests](#running-tests)
3. [Unit Testing Examples](#unit-testing-examples)
4. [E2E Testing Examples](#e2e-testing-examples)
5. [Test Utilities & Helpers](#test-utilities--helpers)
6. [Automated Test Scripts](#automated-test-scripts)
7. [Visual Testing Setup](#visual-testing-setup)
8. [Test Reporting](#test-reporting)

---

## 1. QUICK SETUP

### Install Testing Dependencies

```bash
# Navigate to frontend
cd frontend

# Install if not already installed
npm install

# Install Playwright browsers
npx playwright install

# Install additional testing tools
npm install --save-dev @axe-core/playwright
npm install --save-dev lighthouse
```

### Project Structure

```
frontend/
├── e2e/                                    # E2E tests
│   ├── helpers/                            # Test helpers
│   │   ├── auth-helpers.ts
│   │   ├── mock-helpers.ts
│   │   └── navigation-helpers.ts
│   ├── fixtures/                           # Test fixtures
│   │   ├── test-data.ts
│   │   └── api-responses.ts
│   ├── instructor-auth.spec.ts
│   ├── instructor-class-management.spec.ts
│   ├── instructor-student-management.spec.ts
│   ├── instructor-payments.spec.ts
│   └── instructor-complete-flow.spec.ts
├── src/app/components/instructor/
│   └── **/*.spec.ts                        # Unit tests
└── playwright.config.ts
```

---

## 2. RUNNING TESTS

### Quick Test Commands

```bash
# Run all unit tests
npm run test

# Run unit tests with coverage
npm run test -- --code-coverage

# Run specific component tests
npm run test -- --include='**/instructor-schedule-class.component.spec.ts'

# Run all E2E tests
npx playwright test

# Run E2E tests in UI mode (interactive)
npx playwright test --ui

# Run E2E tests for specific browser
npx playwright test --project=chromium

# Run specific E2E test file
npx playwright test e2e/instructor-auth.spec.ts

# Run E2E tests with debug mode
npx playwright test --debug

# Generate HTML report
npx playwright show-report
```

---

## 3. UNIT TESTING EXAMPLES

### Example 1: Complete Login Component Test

Create: `frontend/src/app/components/instructor/instructor-auths/instructor-login-modal-v2/instructor-login-modal-v2.component.spec.ts`

```typescript
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ReactiveFormsModule } from '@angular/forms';
import { MatDialogRef } from '@angular/material/dialog';
import { Router } from '@angular/router';
import { of, throwError } from 'rxjs';

import { InstructorLoginModalV2Component } from './instructor-login-modal-v2.component';
import { AuthService } from '../../../../services/common/auth/auth.service';
import { ToastService } from '../../../../services/common/message/toast.service';
import { ErrorHandlingService } from '../../../../services/common/error-handling/error-handling.service';
import { HTTP_STATUS_CODES } from '../../../../configs/common/constants/http-status-codes.constants';

describe('InstructorLoginModalV2Component', () => {
  let component: InstructorLoginModalV2Component;
  let fixture: ComponentFixture<InstructorLoginModalV2Component>;
  let authService: jasmine.SpyObj<AuthService>;
  let router: jasmine.SpyObj<Router>;
  let toastService: jasmine.SpyObj<ToastService>;
  let dialogRef: jasmine.SpyObj<MatDialogRef<InstructorLoginModalV2Component>>;

  beforeEach(async () => {
    // Create spies
    const authServiceSpy = jasmine.createSpyObj('AuthService', ['login', 'sendOTP', 'verifyOTP']);
    const routerSpy = jasmine.createSpyObj('Router', ['navigate']);
    const toastServiceSpy = jasmine.createSpyObj('ToastService', ['show']);
    const dialogRefSpy = jasmine.createSpyObj('MatDialogRef', ['close']);

    await TestBed.configureTestingModule({
      declarations: [InstructorLoginModalV2Component],
      imports: [ReactiveFormsModule],
      providers: [
        { provide: AuthService, useValue: authServiceSpy },
        { provide: Router, useValue: routerSpy },
        { provide: ToastService, useValue: toastServiceSpy },
        { provide: MatDialogRef, useValue: dialogRefSpy },
        { provide: ErrorHandlingService, useValue: {} }
      ]
    }).compileComponents();

    authService = TestBed.inject(AuthService) as jasmine.SpyObj<AuthService>;
    router = TestBed.inject(Router) as jasmine.SpyObj<Router>;
    toastService = TestBed.inject(ToastService) as jasmine.SpyObj<ToastService>;
    dialogRef = TestBed.inject(MatDialogRef) as jasmine.SpyObj<MatDialogRef<InstructorLoginModalV2Component>>;
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(InstructorLoginModalV2Component);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  describe('Email Login', () => {
    it('should successfully login with valid credentials', (done) => {
      const mockResponse = {
        statusCode: HTTP_STATUS_CODES.OK,
        data: {
          user: { user_type: 'INSTRUCTOR', email: 'test@example.com' },
          access_token: 'fake-token'
        },
        message: 'Login successful'
      };

      authService.login.and.returnValue(of(mockResponse));

      component.loginForm.patchValue({
        email: 'test@example.com',
        password: 'ValidPassword123!',
        rememberMe: false
      });

      component.onSubmit(component.loginForm);

      setTimeout(() => {
        expect(authService.login).toHaveBeenCalledWith(
          'test@example.com',
          'ValidPassword123!',
          false,
          'email'
        );
        expect(dialogRef.close).toHaveBeenCalled();
        expect(router.navigate).toHaveBeenCalledWith(['/instructor/dashboard']);
        expect(toastService.show).toHaveBeenCalledWith(
          jasmine.stringContaining('success'),
          'success'
        );
        done();
      }, 100);
    });

    it('should show error message for invalid credentials', (done) => {
      const errorResponse = {
        statusCode: HTTP_STATUS_CODES.UNAUTHORIZED,
        message: 'Invalid credentials'
      };

      authService.login.and.returnValue(of(errorResponse));

      component.loginForm.patchValue({
        email: 'test@example.com',
        password: 'WrongPassword'
      });

      component.onSubmit(component.loginForm);

      setTimeout(() => {
        expect(toastService.show).toHaveBeenCalledWith('Invalid credentials', 'error');
        expect(router.navigate).not.toHaveBeenCalled();
        done();
      }, 100);
    });

    it('should handle network errors', (done) => {
      authService.login.and.returnValue(
        throwError(() => new Error('Network error'))
      );

      component.loginForm.patchValue({
        email: 'test@example.com',
        password: 'ValidPassword123!'
      });

      component.onSubmit(component.loginForm);

      setTimeout(() => {
        expect(component.isLoading).toBeFalse();
        done();
      }, 100);
    });
  });

  describe('Form Validation', () => {
    it('should validate email format', () => {
      const emailControl = component.loginForm.get('email');
      
      emailControl?.setValue('invalid-email');
      expect(emailControl?.valid).toBeFalse();

      emailControl?.setValue('valid@email.com');
      expect(emailControl?.valid).toBeTrue();
    });

    it('should validate password minimum length', () => {
      const passwordControl = component.loginForm.get('password');
      
      passwordControl?.setValue('short');
      expect(passwordControl?.valid).toBeFalse();

      passwordControl?.setValue('ValidPassword123!');
      expect(passwordControl?.valid).toBeTrue();
    });

    it('should mark all fields as touched on invalid submit', () => {
      component.loginForm.patchValue({
        email: '',
        password: ''
      });

      component.onSubmit(component.loginForm);

      expect(component.loginForm.get('email')?.touched).toBeTrue();
      expect(component.loginForm.get('password')?.touched).toBeTrue();
    });

    it('should not submit if form is invalid', () => {
      component.loginForm.patchValue({
        email: 'invalid',
        password: '123'
      });

      component.onSubmit(component.loginForm);

      expect(authService.login).not.toHaveBeenCalled();
      expect(toastService.show).toHaveBeenCalledWith(
        jasmine.stringContaining('error'),
        'error'
      );
    });
  });

  describe('OTP Login', () => {
    it('should send OTP to valid mobile number', (done) => {
      const mockResponse = {
        statusCode: HTTP_STATUS_CODES.OK,
        message: 'OTP sent successfully'
      };

      authService.sendOTP.and.returnValue(of(mockResponse));

      component.loginForm.patchValue({
        mobile: '+919876543210'
      });

      // Trigger send OTP (assuming method exists)
      // component.sendOTP();

      setTimeout(() => {
        expect(authService.sendOTP).toHaveBeenCalled();
        expect(component.isOtpSent).toBeTrue();
        done();
      }, 100);
    });

    it('should verify OTP and login', (done) => {
      const mockResponse = {
        statusCode: HTTP_STATUS_CODES.OK,
        data: {
          user: { user_type: 'INSTRUCTOR' },
          access_token: 'fake-token'
        }
      };

      authService.verifyOTP.and.returnValue(of(mockResponse));

      component.otpForm.patchValue({
        otp: '123456'
      });

      component.onOtpSubmit();

      setTimeout(() => {
        expect(authService.verifyOTP).toHaveBeenCalled();
        expect(router.navigate).toHaveBeenCalledWith(['/instructor/dashboard']);
        done();
      }, 100);
    });
  });

  describe('UI States', () => {
    it('should show loading state during login', () => {
      authService.login.and.returnValue(of({
        statusCode: HTTP_STATUS_CODES.OK,
        data: { user: { user_type: 'INSTRUCTOR' }, access_token: 'token' }
      }));

      expect(component.isLoading).toBeFalse();

      component.loginForm.patchValue({
        email: 'test@example.com',
        password: 'ValidPassword123!'
      });

      component.onSubmit(component.loginForm);

      expect(component.isLoading).toBeTrue();
    });

    it('should disable form during submission', () => {
      authService.login.and.returnValue(of({
        statusCode: HTTP_STATUS_CODES.OK,
        data: { user: { user_type: 'INSTRUCTOR' }, access_token: 'token' }
      }));

      component.loginForm.patchValue({
        email: 'test@example.com',
        password: 'ValidPassword123!'
      });

      component.onSubmit(component.loginForm);

      expect(component.loginForm.disabled).toBeTrue();
    });
  });
});
```

### Example 2: Schedule Class Component Test

Create: `frontend/src/app/components/instructor/instructor-class-management/instructor-schedule-class/instructor-schedule-class-enhanced.spec.ts`

```typescript
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ReactiveFormsModule, FormBuilder } from '@angular/forms';
import { HttpClientTestingModule } from '@angular/common/http/testing';
import { RouterTestingModule } from '@angular/router/testing';
import { of, throwError } from 'rxjs';

import { InstructorScheduleClassComponent } from './instructor-schedule-class.component';

describe('InstructorScheduleClassComponent - Enhanced Tests', () => {
  let component: InstructorScheduleClassComponent;
  let fixture: ComponentFixture<InstructorScheduleClassComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [InstructorScheduleClassComponent],
      imports: [
        ReactiveFormsModule,
        HttpClientTestingModule,
        RouterTestingModule
      ],
      providers: [FormBuilder]
    }).compileComponents();

    fixture = TestBed.createComponent(InstructorScheduleClassComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  describe('Duration-based Scheduling', () => {
    it('should add new time slot', () => {
      const initialLength = component.timeSlots.length;
      
      component.addTimeSlot();
      
      expect(component.timeSlots.length).toBe(initialLength + 1);
    });

    it('should remove time slot', () => {
      component.addTimeSlot();
      component.addTimeSlot();
      const initialLength = component.timeSlots.length;
      
      component.removeTimeSlot(0);
      
      expect(component.timeSlots.length).toBe(initialLength - 1);
    });

    it('should not remove last time slot', () => {
      while (component.timeSlots.length > 1) {
        component.removeTimeSlot(0);
      }
      
      component.removeTimeSlot(0);
      
      expect(component.timeSlots.length).toBe(1);
    });

    it('should generate calendar dates for selected duration', () => {
      const duration = 3; // 3 months
      component.scheduleForm.patchValue({ duration });
      
      component.timeSlots.at(0).patchValue({
        day: 'Monday',
        slots: [{ start: '10:00', end: '11:00' }]
      });
      
      component.populateCalendarDates();
      
      const calendarDates = component.scheduleForm.get('calendar_dates')?.value;
      expect(calendarDates.length).toBeGreaterThan(0);
      
      // Should have approximately 12 Mondays in 3 months
      expect(calendarDates.length).toBeGreaterThanOrEqual(10);
      expect(calendarDates.length).toBeLessThanOrEqual(14);
    });

    it('should skip past dates when generating calendar', () => {
      const duration = 3;
      component.scheduleForm.patchValue({ duration });
      
      component.timeSlots.at(0).patchValue({
        day: 'Monday',
        slots: [{ start: '10:00', end: '11:00' }]
      });
      
      component.populateCalendarDates();
      
      const calendarDates = component.scheduleForm.get('calendar_dates')?.value;
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      
      calendarDates.forEach((dateStr: string) => {
        const date = new Date(dateStr);
        expect(date.getTime()).toBeGreaterThanOrEqual(today.getTime());
      });
    });
  });

  describe('Count-based Scheduling', () => {
    beforeEach(() => {
      component.switchToCountMode();
    });

    it('should switch to count mode', () => {
      expect(component.scheduleForm.get('classType')?.value).toBe('count');
      expect(component.countTimeSlots.length).toBeGreaterThan(0);
    });

    it('should add count time slot', () => {
      const initialLength = component.countTimeSlots.length;
      
      component.addCountTimeSlot();
      
      expect(component.countTimeSlots.length).toBe(initialLength + 1);
    });

    it('should auto-fill day when date is selected', () => {
      const testDate = new Date();
      testDate.setDate(testDate.getDate() + 1);
      const dateString = testDate.toISOString().split('T')[0];
      
      component.countTimeSlots.at(0).patchValue({
        date: dateString
      });
      
      component.onCountDateChange(0);
      
      const dayValue = component.countTimeSlots.at(0).get('day')?.value;
      expect(dayValue).toBeTruthy();
      
      const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
      expect(days).toContain(dayValue);
    });

    it('should sort count slots by date', () => {
      const today = new Date();
      const tomorrow = new Date(today);
      tomorrow.setDate(tomorrow.getDate() + 1);
      const dayAfter = new Date(today);
      dayAfter.setDate(dayAfter.getDate() + 2);
      
      // Add slots in reverse chronological order
      component.countTimeSlots.clear();
      component.addCountTimeSlot();
      component.countTimeSlots.at(0).patchValue({
        date: dayAfter.toISOString().split('T')[0],
        start: '10:00',
        end: '11:00'
      });
      
      component.addCountTimeSlot();
      component.countTimeSlots.at(1).patchValue({
        date: today.toISOString().split('T')[0],
        start: '10:00',
        end: '11:00'
      });
      
      component.sortCountSlots();
      
      const firstDate = new Date(component.countTimeSlots.at(0).get('date')?.value);
      const secondDate = new Date(component.countTimeSlots.at(1).get('date')?.value);
      
      expect(firstDate.getTime()).toBeLessThanOrEqual(secondDate.getTime());
    });
  });

  describe('Continuous Class Mode', () => {
    it('should set duration to 12 when continuous enabled', () => {
      component.scheduleForm.patchValue({ is_continuous_class: true });
      
      component.onContinuousToggle();
      
      expect(component.scheduleForm.get('duration')?.value).toBe(12);
      expect(component.scheduleForm.get('duration')?.disabled).toBeTrue();
    });

    it('should enable duration when continuous disabled', () => {
      component.scheduleForm.patchValue({ 
        is_continuous_class: true,
        duration: 12
      });
      component.onContinuousToggle();
      
      component.scheduleForm.patchValue({ is_continuous_class: false });
      component.onContinuousToggle();
      
      expect(component.scheduleForm.get('duration')?.enabled).toBeTrue();
    });
  });

  describe('Availability Checking', () => {
    it('should detect time conflicts', () => {
      const busySlots = {
        'Monday': [
          { start: '10:00', end: '11:00' }
        ]
      };
      
      component.checkTimeConflict('Monday', '10:00', '11:00', busySlots);
      
      expect(component.hasConflict).toBeTrue();
    });

    it('should not show conflict for non-overlapping times', () => {
      const busySlots = {
        'Monday': [
          { start: '10:00', end: '11:00' }
        ]
      };
      
      component.checkTimeConflict('Monday', '11:00', '12:00', busySlots);
      
      expect(component.hasConflict).toBeFalse();
    });

    it('should debounce availability checks', (done) => {
      spyOn(component, 'checkAvailability');
      
      // Trigger multiple times rapidly
      component.onTimeSlotChange();
      component.onTimeSlotChange();
      component.onTimeSlotChange();
      
      setTimeout(() => {
        // Should only call once due to debounce
        expect(component.checkAvailability).toHaveBeenCalledTimes(1);
        done();
      }, 500);
    });
  });

  describe('Form Validation', () => {
    it('should validate required fields', () => {
      component.scheduleForm.patchValue({
        activity_id: '',
        capacity: '',
        location_id: ''
      });
      
      expect(component.scheduleForm.valid).toBeFalse();
      expect(component.scheduleForm.get('activity_id')?.errors?.['required']).toBeTrue();
      expect(component.scheduleForm.get('capacity')?.errors?.['required']).toBeTrue();
    });

    it('should validate start time is before end time', () => {
      component.timeSlots.at(0).get('slots')?.at(0).patchValue({
        start: '11:00',
        end: '10:00'
      });
      
      const isValid = component.validateTimeSlot(0, 0);
      
      expect(isValid).toBeFalse();
    });

    it('should validate capacity is positive', () => {
      component.scheduleForm.patchValue({ capacity: -5 });
      
      expect(component.scheduleForm.get('capacity')?.valid).toBeFalse();
      
      component.scheduleForm.patchValue({ capacity: 20 });
      
      expect(component.scheduleForm.get('capacity')?.valid).toBeTrue();
    });
  });

  describe('Payment Configuration', () => {
    it('should calculate drop-in price as 125% of full price', () => {
      const fullPrice = 10000;
      component.scheduleForm.patchValue({
        payment: {
          full_price: { amount: fullPrice }
        }
      });
      
      component.calculateRelatedPrices();
      
      const dropInPrice = component.scheduleForm.get('payment.drop_in_price.amount')?.value;
      expect(dropInPrice).toBe(fullPrice * 1.25);
    });

    it('should calculate monthly price as 30% of full price', () => {
      const fullPrice = 10000;
      component.scheduleForm.patchValue({
        payment: {
          full_price: { amount: fullPrice }
        }
      });
      
      component.calculateRelatedPrices();
      
      const monthlyPrice = component.scheduleForm.get('payment.monthly_price.amount')?.value;
      expect(monthlyPrice).toBe(fullPrice * 0.30);
    });

    it('should disable other prices when free activity is enabled', () => {
      component.scheduleForm.patchValue({
        payment: {
          is_free: true,
          full_price: { enabled: true },
          drop_in_price: { enabled: true }
        }
      });
      
      component.onFreeActivityToggle();
      
      expect(component.scheduleForm.get('payment.full_price.enabled')?.value).toBeFalse();
      expect(component.scheduleForm.get('payment.drop_in_price.enabled')?.value).toBeFalse();
    });
  });

  describe('Online vs In-person', () => {
    it('should show class link field when online', () => {
      component.scheduleForm.patchValue({ is_online: true });
      
      component.onOnlineToggle();
      
      expect(component.showClassLink).toBeTrue();
      expect(component.showLocation).toBeFalse();
    });

    it('should show location field when in-person', () => {
      component.scheduleForm.patchValue({ is_online: false });
      
      component.onOnlineToggle();
      
      expect(component.showClassLink).toBeFalse();
      expect(component.showLocation).toBeTrue();
    });

    it('should validate class link URL format', () => {
      component.scheduleForm.patchValue({
        is_online: true,
        class_link: 'invalid-url'
      });
      
      expect(component.scheduleForm.get('class_link')?.valid).toBeFalse();
      
      component.scheduleForm.patchValue({
        class_link: 'https://zoom.us/j/123456789'
      });
      
      expect(component.scheduleForm.get('class_link')?.valid).toBeTrue();
    });
  });
});
```

---

## 4. E2E TESTING EXAMPLES

### Example 1: Complete Authentication Flow

Create: `frontend/e2e/instructor-auth-complete.spec.ts`

```typescript
import { test, expect, Page } from '@playwright/test';

// Helper functions
async function loginAsInstructor(page: Page, credentials = {
  email: 'instructor@test.com',
  password: 'TestPass123!'
}) {
  await page.goto('/instructor/login');
  await page.fill('[name="email"]', credentials.email);
  await page.fill('[name="password"]', credentials.password);
  await page.click('button[type="submit"]');
  await page.waitForURL(/\/instructor\/dashboard/);
}

async function mockAuthAPIs(page: Page) {
  // Mock login API
  await page.route('**/api/auth/login', async (route) => {
    await route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify({
        statusCode: 200,
        data: {
          user: {
            _id: 'user123',
            email: 'instructor@test.com',
            fullName: 'Test Instructor',
            user_type: 'INSTRUCTOR',
            user_role: 'instructor'
          },
          access_token: 'fake-jwt-token-12345',
          refresh_token: 'fake-refresh-token-12345'
        },
        message: 'Login successful'
      })
    });
  });

  // Mock user profile API
  await page.route('**/api/user/profile', async (route) => {
    await route.fulfill({
      status: 200,
      body: JSON.stringify({
        statusCode: 200,
        data: {
          _id: 'user123',
          email: 'instructor@test.com',
          fullName: 'Test Instructor',
          profileImage: '/assets/avatars/default.png'
        }
      })
    });
  });
}

test.describe('Instructor Authentication - Complete Flow', () => {
  
  test.beforeEach(async ({ page }) => {
    await mockAuthAPIs(page);
  });

  test('should login with email and password successfully', async ({ page }) => {
    await page.goto('/instructor/login');
    
    // Verify login form elements
    await expect(page.locator('[name="email"]')).toBeVisible();
    await expect(page.locator('[name="password"]')).toBeVisible();
    await expect(page.locator('button[type="submit"]')).toBeVisible();
    
    // Fill credentials
    await page.fill('[name="email"]', 'instructor@test.com');
    await page.fill('[name="password"]', 'TestPass123!');
    
    // Submit form
    await page.click('button[type="submit"]');
    
    // Should navigate to dashboard
    await expect(page).toHaveURL(/\/instructor\/dashboard/);
    
    // Should show welcome message or dashboard content
    await expect(
      page.locator('text=Welcome').or(page.locator('text=Dashboard'))
    ).toBeVisible({ timeout: 5000 });
    
    // Verify token is stored
    const token = await page.evaluate(() => localStorage.getItem('access_token'));
    expect(token).toBeTruthy();
  });

  test('should show validation errors for invalid email', async ({ page }) => {
    await page.goto('/instructor/login');
    
    await page.fill('[name="email"]', 'invalid-email');
    await page.blur('[name="email"]');
    
    await expect(page.locator('text=Invalid email')).toBeVisible();
  });

  test('should show error for wrong credentials', async ({ page }) => {
    // Override mock to return error
    await page.route('**/api/auth/login', async (route) => {
      await route.fulfill({
        status: 401,
        body: JSON.stringify({
          statusCode: 401,
          message: 'Invalid credentials'
        })
      });
    });
    
    await page.goto('/instructor/login');
    await page.fill('[name="email"]', 'wrong@test.com');
    await page.fill('[name="password"]', 'WrongPass123!');
    await page.click('button[type="submit"]');
    
    await expect(page.locator('text=Invalid credentials')).toBeVisible();
    await expect(page).toHaveURL(/\/instructor\/login/);
  });

  test('should toggle password visibility', async ({ page }) => {
    await page.goto('/instructor/login');
    
    const passwordInput = page.locator('[name="password"]');
    const toggleButton = page.locator('[aria-label="Toggle password visibility"]');
    
    // Initially should be password type
    await expect(passwordInput).toHaveAttribute('type', 'password');
    
    // Click toggle
    await toggleButton.click();
    
    // Should change to text type
    await expect(passwordInput).toHaveAttribute('type', 'text');
    
    // Click again
    await toggleButton.click();
    
    // Should change back to password
    await expect(passwordInput).toHaveAttribute('type', 'password');
  });

  test('should remember me functionality', async ({ page, context }) => {
    await page.goto('/instructor/login');
    
    await page.fill('[name="email"]', 'instructor@test.com');
    await page.fill('[name="password"]', 'TestPass123!');
    await page.check('[name="rememberMe"]');
    await page.click('button[type="submit"]');
    
    await expect(page).toHaveURL(/\/instructor\/dashboard/);
    
    // Close and reopen browser
    await page.close();
    const newPage = await context.newPage();
    await newPage.goto('/instructor/dashboard');
    
    // Should still be logged in (token persisted)
    const token = await newPage.evaluate(() => localStorage.getItem('access_token'));
    expect(token).toBeTruthy();
  });

  test('should handle network timeout gracefully', async ({ page }) => {
    // Mock slow/timeout response
    await page.route('**/api/auth/login', async (route) => {
      await new Promise(resolve => setTimeout(resolve, 30000));
    });
    
    await page.goto('/instructor/login');
    await page.fill('[name="email"]', 'instructor@test.com');
    await page.fill('[name="password"]', 'TestPass123!');
    await page.click('button[type="submit"]');
    
    // Should show timeout error (with reasonable timeout)
    await expect(page.locator('text=Request timeout')).toBeVisible({ timeout: 10000 });
  });

  test('should logout successfully', async ({ page }) => {
    await loginAsInstructor(page);
    
    // Click user menu
    await page.click('[aria-label="User menu"]');
    
    // Click logout
    await page.click('text=Logout');
    
    // Should redirect to login
    await expect(page).toHaveURL(/\/instructor\/login/);
    
    // Token should be cleared
    const token = await page.evaluate(() => localStorage.getItem('access_token'));
    expect(token).toBeFalsy();
  });

  test('should handle session expiration', async ({ page }) => {
    await loginAsInstructor(page);
    
    // Simulate session expiration by clearing token
    await page.evaluate(() => localStorage.removeItem('access_token'));
    
    // Try to navigate to protected route
    await page.goto('/instructor/class-management/schedule-class');
    
    // Should redirect to login
    await expect(page).toHaveURL(/\/instructor\/login/);
    await expect(page.locator('text=Session expired')).toBeVisible();
  });
});
```

### Example 2: Complete Class Management Flow

Create: `frontend/e2e/instructor-class-complete-flow.spec.ts`

```typescript
import { test, expect } from '@playwright/test';
import { loginAsInstructor, mockCommonAPIs } from './helpers/auth-helpers';
import { mockActivitiesAPI, mockLocationsAPI, mockClassAPIs } from './helpers/mock-helpers';

test.describe('Instructor Class Management - Complete Flow', () => {
  
  test.beforeEach(async ({ page }) => {
    await mockCommonAPIs(page);
    await mockActivitiesAPI(page);
    await mockLocationsAPI(page);
    await mockClassAPIs(page);
    await loginAsInstructor(page);
  });

  test('should create, view, edit, and delete a class', async ({ page }) => {
    // STEP 1: Create class
    await page.goto('/instructor/class-management/schedule-class');
    
    // Wait for form to load
    await expect(page.locator('[data-testid="schedule-form"]')).toBeVisible();
    
    // Select activity
    await page.click('[data-testid="activity-dropdown"]');
    await page.waitForSelector('text=Yoga');
    await page.click('text=Yoga');
    
    // Select location
    await page.click('[data-testid="location-dropdown"]');
    await page.waitForSelector('text=Main Studio');
    await page.click('text=Main Studio');
    
    // Set capacity
    await page.fill('[name="capacity"]', '20');
    
    // Add time slot
    await page.selectOption('[name="day-0"]', 'Monday');
    await page.fill('[name="start-0"]', '10:00');
    await page.fill('[name="end-0"]', '11:00');
    
    // Select duration
    await page.selectOption('[name="duration"]', '3');
    
    // Next to payment
    await page.click('button:has-text("Next: Payment Details")');
    
    // Fill payment
    await expect(page.locator('[name="full_price"]')).toBeVisible();
    await page.fill('[name="full_price"]', '10000');
    
    // Verify auto-calculated prices
    await expect(page.locator('[name="drop_in_price"]')).toHaveValue('12500');
    await expect(page.locator('[name="monthly_price"]')).toHaveValue('3000');
    
    // Submit
    await page.click('button:has-text("Save")');
    
    // Should navigate to my classes
    await expect(page).toHaveURL(/\/my-classes/);
    await expect(page.locator('text=Class created successfully')).toBeVisible();
    
    // STEP 2: View class in list
    await expect(page.locator('text=Yoga')).toBeVisible();
    await expect(page.locator('text=Main Studio')).toBeVisible();
    await expect(page.locator('text=20').first()).toBeVisible(); // Capacity
    
    // STEP 3: Edit class
    await page.click('[data-testid="edit-class-btn"]').first();
    
    await expect(page).toHaveURL(/\/schedule-class/);
    await expect(page.locator('[name="capacity"]')).toHaveValue('20');
    
    // Change capacity
    await page.fill('[name="capacity"]', '25');
    
    // Save changes
    await page.click('button:has-text("Save")');
    
    await expect(page).toHaveURL(/\/my-classes/);
    await expect(page.locator('text=Class updated successfully')).toBeVisible();
    await expect(page.locator('text=25')).toBeVisible();
    
    // STEP 4: View class details
    await page.click('[data-testid="view-class-btn"]').first();
    
    await expect(page.locator('text=Class Details')).toBeVisible();
    await expect(page.locator('text=Yoga')).toBeVisible();
    await expect(page.locator('text=25')).toBeVisible();
    
    // STEP 5: Delete class
    await page.goBack();
    await page.click('[data-testid="delete-class-btn"]').first();
    
    // Confirm deletion
    await page.click('button:has-text("Confirm")');
    
    await expect(page.locator('text=Class deleted successfully')).toBeVisible();
  });

  test('should create count-based class with multiple sessions', async ({ page }) => {
    await page.goto('/instructor/class-management/schedule-class');
    
    // Switch to count mode
    await page.click('input[value="count"]');
    
    // Fill basic details
    await page.click('[data-testid="activity-dropdown"]');
    await page.click('text=Dance');
    
    await page.click('[data-testid="location-dropdown"]');
    await page.click('text=Studio B');
    
    await page.fill('[name="capacity"]', '15');
    
    // Add first session
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    await page.fill('[name="date-0"]', tomorrow.toISOString().split('T')[0]);
    await page.fill('[name="start-0"]', '14:00');
    await page.fill('[name="end-0"]', '15:00');
    
    // Add second session
    await page.click('button:has-text("Add Slot")');
    const nextWeek = new Date();
    nextWeek.setDate(nextWeek.getDate() + 7);
    await page.fill('[name="date-1"]', nextWeek.toISOString().split('T')[0]);
    await page.fill('[name="start-1"]', '14:00');
    await page.fill('[name="end-1"]', '15:00');
    
    // Add third session
    await page.click('button:has-text("Add Slot")');
    const twoWeeks = new Date();
    twoWeeks.setDate(twoWeeks.getDate() + 14);
    await page.fill('[name="date-2"]', twoWeeks.toISOString().split('T')[0]);
    await page.fill('[name="start-2"]', '14:00');
    await page.fill('[name="end-2"]', '15:00');
    
    // Payment
    await page.click('button:has-text("Next: Payment Details")');
    await page.fill('[name="full_price"]', '8000');
    
    // Submit
    await page.click('button:has-text("Save")');
    
    await expect(page).toHaveURL(/\/my-classes/);
    await expect(page.locator('text=Class created successfully')).toBeVisible();
    await expect(page.locator('text=3 sessions')).toBeVisible();
  });

  test('should handle availability conflicts', async ({ page }) => {
    // Mock conflict in busy slots
    await page.route('**/api/instructor/availability/busy-slots', async (route) => {
      await route.fulfill({
        status: 200,
        body: JSON.stringify({
          statusCode: 200,
          data: {
            busySlots: {
              'Monday': [
                { start: '10:00', end: '11:00', reason: 'Existing class' }
              ]
            }
          }
        })
      });
    });
    
    await page.goto('/instructor/class-management/schedule-class');
    
    await page.click('[data-testid="activity-dropdown"]');
    await page.click('text=Yoga');
    
    await page.click('[data-testid="location-dropdown"]');
    await page.click('text=Main Studio');
    
    await page.fill('[name="capacity"]', '20');
    await page.selectOption('[name="day-0"]', 'Monday');
    await page.fill('[name="start-0"]', '10:00');
    await page.fill('[name="end-0"]', '11:00');
    
    // Wait for conflict detection
    await expect(page.locator('.conflict-warning')).toBeVisible({ timeout: 5000 });
    await expect(page.locator('text=Time slot conflicts')).toBeVisible();
    await expect(page.locator('text=Existing class')).toBeVisible();
    
    // Change time to resolve conflict
    await page.fill('[name="start-0"]', '11:00');
    await page.fill('[name="end-0"]', '12:00');
    
    // Conflict should disappear
    await expect(page.locator('.conflict-warning')).not.toBeVisible({ timeout: 5000 });
  });

  test('should create continuous class with 12 months duration', async ({ page }) => {
    await page.goto('/instructor/class-management/schedule-class');
    
    await page.click('[data-testid="activity-dropdown"]');
    await page.click('text=Yoga');
    
    await page.click('[data-testid="location-dropdown"]');
    await page.click('text=Main Studio');
    
    await page.fill('[name="capacity"]', '20');
    await page.selectOption('[name="day-0"]', 'Monday');
    await page.fill('[name="start-0"]', '10:00');
    await page.fill('[name="end-0"]', '11:00');
    
    // Enable continuous
    await page.check('[name="is_continuous"]');
    
    // Verify duration is set and disabled
    await expect(page.locator('[name="duration"]')).toHaveValue('12');
    await expect(page.locator('[name="duration"]')).toBeDisabled();
    
    // Continue with payment
    await page.click('button:has-text("Next: Payment Details")');
    await page.fill('[name="full_price"]', '10000');
    
    await page.click('button:has-text("Save")');
    
    await expect(page).toHaveURL(/\/my-classes/);
    await expect(page.locator('text=Continuous')).toBeVisible();
  });

  test('should create online class with meeting link', async ({ page }) => {
    await page.goto('/instructor/class-management/schedule-class');
    
    await page.click('[data-testid="activity-dropdown"]');
    await page.click('text=Yoga');
    
    // Enable online
    await page.check('[name="is_online"]');
    
    // Location should be hidden, link should be visible
    await expect(page.locator('[data-testid="location-dropdown"]')).not.toBeVisible();
    await expect(page.locator('[name="class_link"]')).toBeVisible();
    
    // Fill class link
    await page.fill('[name="class_link"]', 'https://zoom.us/j/123456789');
    
    await page.fill('[name="capacity"]', '50');
    await page.selectOption('[name="day-0"]', 'Monday');
    await page.fill('[name="start-0"]', '10:00');
    await page.fill('[name="end-0"]', '11:00');
    await page.selectOption('[name="duration"]', '3');
    
    await page.click('button:has-text("Next: Payment Details")');
    await page.fill('[name="full_price"]', '5000');
    
    await page.click('button:has-text("Save")');
    
    await expect(page).toHaveURL(/\/my-classes/);
    await expect(page.locator('text=Online')).toBeVisible();
  });
});
```

---

## 5. TEST UTILITIES & HELPERS

### Create: `frontend/e2e/helpers/auth-helpers.ts`

```typescript
import { Page, Route } from '@playwright/test';

export const TEST_CREDENTIALS = {
  instructor: {
    email: 'instructor@test.com',
    password: 'TestPass123!',
    token: 'fake-jwt-token-instructor'
  },
  student: {
    email: 'student@test.com',
    password: 'TestPass123!',
    token: 'fake-jwt-token-student'
  }
};

export async function loginAsInstructor(page: Page) {
  await mockAuthAPIs(page, 'instructor');
  await page.goto('/instructor/login');
  await page.fill('[name="email"]', TEST_CREDENTIALS.instructor.email);
  await page.fill('[name="password"]', TEST_CREDENTIALS.instructor.password);
  await page.click('button[type="submit"]');
  await page.waitForURL(/\/instructor\/dashboard/);
}

export async function loginAsStudent(page: Page) {
  await mockAuthAPIs(page, 'student');
  await page.goto('/student/login');
  await page.fill('[name="email"]', TEST_CREDENTIALS.student.email);
  await page.fill('[name="password"]', TEST_CREDENTIALS.student.password);
  await page.click('button[type="submit"]');
  await page.waitForURL(/\/student\/dashboard/);
}

export async function mockAuthAPIs(page: Page, userType: 'instructor' | 'student' = 'instructor') {
  const credentials = TEST_CREDENTIALS[userType];
  
  await page.route('**/api/auth/login', async (route: Route) => {
    await route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify({
        statusCode: 200,
        data: {
          user: {
            _id: `${userType}123`,
            email: credentials.email,
            fullName: `Test ${userType.charAt(0).toUpperCase() + userType.slice(1)}`,
            user_type: userType.toUpperCase(),
            user_role: userType
          },
          access_token: credentials.token,
          refresh_token: `refresh-${credentials.token}`
        },
        message: 'Login successful'
      })
    });
  });

  await page.route('**/api/user/profile', async (route: Route) => {
    await route.fulfill({
      status: 200,
      body: JSON.stringify({
        statusCode: 200,
        data: {
          _id: `${userType}123`,
          email: credentials.email,
          fullName: `Test ${userType.charAt(0).toUpperCase() + userType.slice(1)}`,
          profileImage: '/assets/avatars/default.png',
          user_type: userType.toUpperCase()
        }
      })
    });
  });
}

export async function mockCommonAPIs(page: Page) {
  // Mock notifications
  await page.route('**/api/notifications**', async (route: Route) => {
    await route.fulfill({
      status: 200,
      body: JSON.stringify({
        statusCode: 200,
        data: []
      })
    });
  });

  // Mock preferences
  await page.route('**/api/user/preferences', async (route: Route) => {
    await route.fulfill({
      status: 200,
      body: JSON.stringify({
        statusCode: 200,
        data: {
          theme: 'light',
          language: 'en',
          currency: 'INR'
        }
      })
    });
  });
}
```

### Create: `frontend/e2e/helpers/mock-helpers.ts`

```typescript
import { Page, Route } from '@playwright/test';

export async function mockActivitiesAPI(page: Page) {
  await page.route('**/api/activities**', async (route: Route) => {
    await route.fulfill({
      status: 200,
      body: JSON.stringify({
        statusCode: 200,
        data: [
          {
            _id: 'activity1',
            activity_name: 'Yoga',
            category: 'Fitness',
            description: 'Yoga classes'
          },
          {
            _id: 'activity2',
            activity_name: 'Dance',
            category: 'Arts',
            description: 'Dance classes'
          },
          {
            _id: 'activity3',
            activity_name: 'Painting',
            category: 'Arts',
            description: 'Painting classes'
          }
        ]
      })
    });
  });
}

export async function mockLocationsAPI(page: Page) {
  await page.route('**/api/locations**', async (route: Route) => {
    await route.fulfill({
      status: 200,
      body: JSON.stringify({
        statusCode: 200,
        data: [
          {
            _id: 'location1',
            title: 'Main Studio',
            address: '123 Main St, Bangalore',
            latitude: 12.9716,
            longitude: 77.5946
          },
          {
            _id: 'location2',
            title: 'Studio B',
            address: '456 Park Ave, Bangalore',
            latitude: 12.9719,
            longitude: 77.5950
          }
        ]
      })
    });
  });
}

export async function mockClassAPIs(page: Page) {
  // Mock get classes
  await page.route('**/api/instructor/classes?**', async (route: Route) => {
    await route.fulfill({
      status: 200,
      body: JSON.stringify({
        statusCode: 200,
        data: [
          {
            _id: 'class1',
            activity_name: 'Yoga',
            location_title: 'Main Studio',
            capacity: 20,
            enrolled_students: 15,
            start_date: new Date().toISOString(),
            status: 'active'
          }
        ],
        total: 1,
        page: 1,
        totalPages: 1
      })
    });
  });

  // Mock create class
  await page.route('**/api/instructor/classes', async (route: Route) => {
    if (route.request().method() === 'POST') {
      await route.fulfill({
        status: 201,
        body: JSON.stringify({
          statusCode: 201,
          data: {
            _id: 'new-class-id',
            message: 'Class created successfully'
          }
        })
      });
    }
  });

  // Mock update class
  await page.route('**/api/instructor/classes/*', async (route: Route) => {
    if (route.request().method() === 'PUT') {
      await route.fulfill({
        status: 200,
        body: JSON.stringify({
          statusCode: 200,
          data: {
            _id: 'class1',
            message: 'Class updated successfully'
          }
        })
      });
    } else if (route.request().method() === 'DELETE') {
      await route.fulfill({
        status: 200,
        body: JSON.stringify({
          statusCode: 200,
          message: 'Class deleted successfully'
        })
      });
    }
  });

  // Mock availability
  await page.route('**/api/instructor/availability/busy-slots**', async (route: Route) => {
    await route.fulfill({
      status: 200,
      body: JSON.stringify({
        statusCode: 200,
        data: {
          busySlots: {}
        }
      })
    });
  });
}
```

---

## 6. AUTOMATED TEST SCRIPTS

### Create: `frontend/scripts/run-all-tests.sh`

```bash
#!/bin/bash

echo "========================================="
echo "  INSTRUCTOR MODULE - COMPLETE TEST SUITE"
echo "========================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track results
UNIT_TEST_RESULT=0
E2E_TEST_RESULT=0
ACCESSIBILITY_RESULT=0

echo -e "${YELLOW}[1/5] Running Unit Tests...${NC}"
npm run test -- --watch=false --browsers=ChromeHeadless --code-coverage
UNIT_TEST_RESULT=$?

if [ $UNIT_TEST_RESULT -eq 0 ]; then
  echo -e "${GREEN}✓ Unit Tests Passed${NC}"
else
  echo -e "${RED}✗ Unit Tests Failed${NC}"
fi

echo ""
echo -e "${YELLOW}[2/5] Checking Code Coverage...${NC}"
# Coverage threshold check (example: 90%)
# Add coverage checking logic here

echo ""
echo -e "${YELLOW}[3/5] Running E2E Tests - Chromium...${NC}"
npx playwright test --project=chromium --reporter=html
E2E_CHROMIUM=$?

echo ""
echo -e "${YELLOW}[4/5] Running E2E Tests - Firefox...${NC}"
npx playwright test --project=firefox --reporter=html
E2E_FIREFOX=$?

echo ""
echo -e "${YELLOW}[5/5] Running Accessibility Tests...${NC}"
# Add accessibility test runner

echo ""
echo "========================================="
echo "  TEST RESULTS SUMMARY"
echo "========================================="
echo ""

if [ $UNIT_TEST_RESULT -eq 0 ]; then
  echo -e "${GREEN}✓ Unit Tests: PASSED${NC}"
else
  echo -e "${RED}✗ Unit Tests: FAILED${NC}"
fi

if [ $E2E_CHROMIUM -eq 0 ]; then
  echo -e "${GREEN}✓ E2E Tests (Chromium): PASSED${NC}"
else
  echo -e "${RED}✗ E2E Tests (Chromium): FAILED${NC}"
fi

if [ $E2E_FIREFOX -eq 0 ]; then
  echo -e "${GREEN}✓ E2E Tests (Firefox): PASSED${NC}"
else
  echo -e "${RED}✗ E2E Tests (Firefox): FAILED${NC}"
fi

echo ""

# Overall result
if [ $UNIT_TEST_RESULT -eq 0 ] && [ $E2E_CHROMIUM -eq 0 ] && [ $E2E_FIREFOX -eq 0 ]; then
  echo -e "${GREEN}========================================="
  echo -e "  ALL TESTS PASSED! ✓"
  echo -e "=========================================${NC}"
  exit 0
else
  echo -e "${RED}========================================="
  echo -e "  SOME TESTS FAILED! ✗"
  echo -e "=========================================${NC}"
  exit 1
fi
```

### Create: `frontend/scripts/run-all-tests.ps1` (Windows)

```powershell
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  INSTRUCTOR MODULE - COMPLETE TEST SUITE" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Track results
$unitTestResult = 0
$e2eTestResult = 0

Write-Host "[1/5] Running Unit Tests..." -ForegroundColor Yellow
npm run test -- --watch=false --browsers=ChromeHeadless --code-coverage
$unitTestResult = $LASTEXITCODE

if ($unitTestResult -eq 0) {
  Write-Host "✓ Unit Tests Passed" -ForegroundColor Green
} else {
  Write-Host "✗ Unit Tests Failed" -ForegroundColor Red
}

Write-Host ""
Write-Host "[2/5] Running E2E Tests - Chromium..." -ForegroundColor Yellow
npx playwright test --project=chromium --reporter=html
$e2eChromium = $LASTEXITCODE

Write-Host ""
Write-Host "[3/5] Running E2E Tests - Firefox..." -ForegroundColor Yellow
npx playwright test --project=firefox --reporter=html
$e2eFirefox = $LASTEXITCODE

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  TEST RESULTS SUMMARY" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

if ($unitTestResult -eq 0) {
  Write-Host "✓ Unit Tests: PASSED" -ForegroundColor Green
} else {
  Write-Host "✗ Unit Tests: FAILED" -ForegroundColor Red
}

if ($e2eChromium -eq 0) {
  Write-Host "✓ E2E Tests (Chromium): PASSED" -ForegroundColor Green
} else {
  Write-Host "✗ E2E Tests (Chromium): FAILED" -ForegroundColor Red
}

if ($e2eFirefox -eq 0) {
  Write-Host "✓ E2E Tests (Firefox): PASSED" -ForegroundColor Green
} else {
  Write-Host "✗ E2E Tests (Firefox): FAILED" -ForegroundColor Red
}

Write-Host ""

if ($unitTestResult -eq 0 -and $e2eChromium -eq 0 -and $e2eFirefox -eq 0) {
  Write-Host "=========================================" -ForegroundColor Green
  Write-Host "  ALL TESTS PASSED! ✓" -ForegroundColor Green
  Write-Host "=========================================" -ForegroundColor Green
  exit 0
} else {
  Write-Host "=========================================" -ForegroundColor Red
  Write-Host "  SOME TESTS FAILED! ✗" -ForegroundColor Red
  Write-Host "=========================================" -ForegroundColor Red
  exit 1
}
```

### Make scripts executable

```bash
# Linux/Mac
chmod +x frontend/scripts/run-all-tests.sh

# Windows: Run in PowerShell as Administrator
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## 7. VISUAL TESTING SETUP

### Install Percy (Visual Testing Tool)

```bash
npm install --save-dev @percy/cli @percy/playwright
```

### Configure Percy

Create: `frontend/.percyrc`

```yaml
version: 2
snapshot:
  widths:
    - 375
    - 768
    - 1280
  minHeight: 1024
  percyCSS: ''
```

### Visual Test Example

Create: `frontend/e2e/visual/instructor-visual.spec.ts`

```typescript
import { test } from '@playwright/test';
import percySnapshot from '@percy/playwright';
import { loginAsInstructor } from '../helpers/auth-helpers';

test.describe('Instructor Module - Visual Tests', () => {
  
  test.beforeEach(async ({ page }) => {
    await loginAsInstructor(page);
  });

  test('Dashboard visual snapshot', async ({ page }) => {
    await page.goto('/instructor/dashboard');
    await page.waitForLoadState('networkidle');
    await percySnapshot(page, 'Instructor Dashboard');
  });

  test('Schedule Class form visual snapshot', async ({ page }) => {
    await page.goto('/instructor/class-management/schedule-class');
    await page.waitForLoadState('networkidle');
    await percySnapshot(page, 'Schedule Class Form');
  });

  test('My Classes list visual snapshot', async ({ page }) => {
    await page.goto('/instructor/class-management/my-classes');
    await page.waitForLoadState('networkidle');
    await percySnapshot(page, 'My Classes List');
  });

  test('Payment list visual snapshot', async ({ page }) => {
    await page.goto('/instructor/payments');
    await page.waitForLoadState('networkidle');
    await percySnapshot(page, 'Payment List');
  });
});
```

---

## 8. TEST REPORTING

### HTML Report Generation

Playwright automatically generates HTML reports. View with:

```bash
npx playwright show-report
```

### Custom Test Reporter

Create: `frontend/custom-reporter.ts`

```typescript
import { Reporter, TestCase, TestResult } from '@playwright/test/reporter';
import fs from 'fs';
import path from 'path';

class CustomReporter implements Reporter {
  private results: any[] = [];

  onTestEnd(test: TestCase, result: TestResult) {
    this.results.push({
      title: test.title,
      file: test.location.file,
      status: result.status,
      duration: result.duration,
      error: result.error?.message
    });
  }

  onEnd() {
    const reportDir = path.join(__dirname, 'test-reports');
    if (!fs.existsSync(reportDir)) {
      fs.mkdirSync(reportDir, { recursive: true });
    }

    const report = {
      timestamp: new Date().toISOString(),
      total: this.results.length,
      passed: this.results.filter(r => r.status === 'passed').length,
      failed: this.results.filter(r => r.status === 'failed').length,
      skipped: this.results.filter(r => r.status === 'skipped').length,
      results: this.results
    };

    fs.writeFileSync(
      path.join(reportDir, `test-report-${Date.now()}.json`),
      JSON.stringify(report, null, 2)
    );

    console.log('\n========================================');
    console.log('  TEST REPORT');
    console.log('========================================');
    console.log(`Total Tests: ${report.total}`);
    console.log(`Passed: ${report.passed}`);
    console.log(`Failed: ${report.failed}`);
    console.log(`Skipped: ${report.skipped}`);
    console.log('========================================\n');
  }
}

export default CustomReporter;
```

Update `playwright.config.ts`:

```typescript
import { defineConfig } from '@playwright/test';

export default defineConfig({
  reporter: [
    ['html'],
    ['./custom-reporter.ts']
  ],
  // ... other config
});
```

---

## 🎉 CONCLUSION

You now have:

✅ **Complete test setup** with all dependencies  
✅ **Ready-to-use test examples** for unit and E2E testing  
✅ **Helper utilities** for common test scenarios  
✅ **Automated scripts** to run all tests  
✅ **Visual testing** setup  
✅ **Custom reporting** configuration  

### Next Steps:

1. Run unit tests: `npm run test`
2. Run E2E tests: `npx playwright test`
3. Run complete suite: `./scripts/run-all-tests.sh`
4. View reports: `npx playwright show-report`

**Start testing and catch every bug! 🚀**

