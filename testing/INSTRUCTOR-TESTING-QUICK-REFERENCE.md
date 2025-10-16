# 🚀 INSTRUCTOR MODULE - TESTING QUICK REFERENCE
## Daily Testing Checklist & Commands

> **Quick Access**: Keep this document open for instant access to testing commands and checklists.

---

## ⚡ QUICK COMMANDS

### Essential Test Commands

```bash
# Run all unit tests
npm test

# Run unit tests with coverage
npm test -- --code-coverage

# Run specific test file
npm test -- --include='**/component-name.spec.ts'

# Run E2E tests (all browsers)
npx playwright test

# Run E2E tests (specific browser)
npx playwright test --project=chromium

# Run E2E tests in UI mode (debug/develop)
npx playwright test --ui

# Run E2E tests with trace
npx playwright test --trace on

# Show test report
npx playwright show-report

# Run specific E2E test file
npx playwright test e2e/instructor-auth.spec.ts

# Debug single test
npx playwright test --debug e2e/instructor-auth.spec.ts

# Run tests in headed mode (see browser)
npx playwright test --headed

# Generate code (record actions)
npx playwright codegen http://localhost:4200
```

---

## ✅ DAILY TESTING CHECKLIST

### Before Starting Development

- [ ] Pull latest code from repository
- [ ] Run `npm install` if dependencies changed
- [ ] Run existing tests to ensure baseline: `npm test`
- [ ] Check if backend is running (if needed for E2E)

### During Development

- [ ] Write unit tests for new functions/methods
- [ ] Run tests frequently: `npm test -- --include='**/your-component.spec.ts'`
- [ ] Fix any failing tests immediately
- [ ] Maintain test coverage above 90%

### Before Committing

- [ ] Run all unit tests: `npm test`
- [ ] Run linter: `npm run lint`
- [ ] Check code coverage
- [ ] Run quick E2E smoke tests
- [ ] Fix all console errors/warnings
- [ ] Review code changes

### Before Pull Request

- [ ] Run complete test suite
- [ ] Run E2E tests on multiple browsers
- [ ] Check accessibility (no axe violations)
- [ ] Test manually in browser
- [ ] Update test documentation if needed

### Before Deployment

- [ ] All tests passing in CI/CD
- [ ] Code coverage > 90%
- [ ] E2E tests passing on all browsers
- [ ] Performance tests passing
- [ ] Security scan clean
- [ ] Manual testing completed

---

## 🎯 FEATURE-SPECIFIC TEST CHECKLISTS

### Authentication Testing

**Unit Tests:**
- [ ] Email validation
- [ ] Password validation
- [ ] Login success flow
- [ ] Login failure handling
- [ ] OTP send functionality
- [ ] OTP verification
- [ ] Google OAuth flow
- [ ] Remember me functionality
- [ ] Session management

**E2E Tests:**
- [ ] Complete login flow
- [ ] Invalid credentials error
- [ ] Password visibility toggle
- [ ] Remember me persistence
- [ ] Session timeout
- [ ] Logout flow
- [ ] Concurrent login handling

**Edge Cases:**
- [ ] Network timeout
- [ ] Invalid token
- [ ] Expired session
- [ ] Multiple browser tabs
- [ ] Browser back button

---

### Class Management Testing

**Unit Tests:**
- [ ] Form initialization
- [ ] Duration-based mode
- [ ] Count-based mode
- [ ] Add/remove time slots
- [ ] Calendar date generation
- [ ] Availability checking
- [ ] Conflict detection
- [ ] Payment calculation
- [ ] Online vs in-person toggle
- [ ] Continuous class mode
- [ ] Form validation
- [ ] Submit success/failure

**E2E Tests:**
- [ ] Create duration-based class
- [ ] Create count-based class
- [ ] Edit existing class
- [ ] Delete class
- [ ] Handle conflicts
- [ ] Create continuous class
- [ ] Create online class
- [ ] Price auto-calculation
- [ ] Multi-slot creation

**Edge Cases:**
- [ ] Maximum capacity
- [ ] Zero capacity
- [ ] Past dates
- [ ] Invalid time ranges
- [ ] Overlapping slots
- [ ] Very long durations
- [ ] Many time slots (10+)

---

### Student Management Testing

**Unit Tests:**
- [ ] Student list loading
- [ ] Pagination
- [ ] Search functionality
- [ ] Filter by class
- [ ] Sort by name/date
- [ ] Add new student
- [ ] Edit student details
- [ ] Delete student
- [ ] Bulk import
- [ ] Progress tracking

**E2E Tests:**
- [ ] View student list
- [ ] Create new student
- [ ] Edit student information
- [ ] Delete student with confirmation
- [ ] Search students
- [ ] Filter and sort
- [ ] Mark attendance
- [ ] Update progress
- [ ] Export student list

**Edge Cases:**
- [ ] Duplicate email
- [ ] Invalid mobile number
- [ ] Large student list (1000+)
- [ ] Empty search results
- [ ] Import errors

---

### Payment Management Testing

**Unit Tests:**
- [ ] Payment list loading
- [ ] Filter by status
- [ ] Filter by date range
- [ ] Search payments
- [ ] Verify payment
- [ ] Bulk verification
- [ ] Receipt generation
- [ ] Payment analytics
- [ ] Export functionality

**E2E Tests:**
- [ ] View payment list
- [ ] Verify single payment
- [ ] Bulk verify payments
- [ ] Generate receipt
- [ ] Download receipt
- [ ] Email receipt
- [ ] Filter payments
- [ ] Export to CSV/Excel
- [ ] View payment details

**Edge Cases:**
- [ ] Zero payments
- [ ] Large payment list
- [ ] Invalid payment proof
- [ ] Network error during verification
- [ ] Missing payment details

---

## 🐛 COMMON ISSUES & SOLUTIONS

### Issue: Tests fail randomly (flaky tests)

**Solutions:**
- Add proper wait conditions: `await page.waitForLoadState('networkidle')`
- Use explicit waits: `await expect(element).toBeVisible({ timeout: 5000 })`
- Avoid using `setTimeout` - use `waitForTimeout` sparingly
- Mock external dependencies consistently
- Reset state between tests

### Issue: E2E tests timeout

**Solutions:**
- Increase timeout in `playwright.config.ts`: `timeout: 60000`
- Check if backend is running
- Verify API endpoints are accessible
- Use `--headed` mode to see what's happening
- Add `await page.pause()` to debug

### Issue: Coverage not reaching 90%

**Solutions:**
- Identify uncovered lines: `npm test -- --code-coverage`
- Open `coverage/index.html` in browser
- Write tests for missing branches
- Test error handling paths
- Test edge cases

### Issue: Unit test can't find module

**Solutions:**
- Check imports in spec file
- Verify TestBed.configureTestingModule providers
- Add missing service mocks
- Check if module is properly imported

### Issue: Cannot access element in E2E test

**Solutions:**
- Use better selectors: `data-testid`, `aria-label`
- Wait for element: `await page.waitForSelector('[data-testid="element"]')`
- Check if element is visible: `await expect(element).toBeVisible()`
- Verify element is not in shadow DOM
- Use `page.locator()` instead of `page.$`

---

## 📊 TEST COVERAGE GUIDE

### Coverage Goals

| Type | Target | Minimum |
|------|--------|---------|
| Line Coverage | 95% | 90% |
| Branch Coverage | 90% | 85% |
| Function Coverage | 95% | 90% |
| Statement Coverage | 95% | 90% |

### How to Check Coverage

```bash
# Generate coverage report
npm test -- --code-coverage

# Open HTML report
# Navigate to: frontend/coverage/index.html
```

### Improve Coverage

1. **Find uncovered code:**
   - Open `coverage/index.html`
   - Click on file name
   - Red lines = not covered
   - Yellow lines = partially covered

2. **Write targeted tests:**
   ```typescript
   it('should handle error case', () => {
     // Test the red line
   });
   ```

3. **Test branches:**
   ```typescript
   it('should take if branch', () => {
     // Test if condition = true
   });
   
   it('should take else branch', () => {
     // Test if condition = false
   });
   ```

---

## 🎨 TEST DATA TEMPLATES

### Valid Test User

```typescript
const validInstructor = {
  email: 'instructor@test.com',
  password: 'TestPass123!',
  fullName: 'Test Instructor',
  mobile: '+919876543210'
};
```

### Valid Class Data

```typescript
const validClass = {
  activity_id: 'activity123',
  location_id: 'location456',
  capacity: 20,
  classType: 'duration',
  duration: 3,
  time_slots: [
    {
      day: 'Monday',
      slots: [{ start: '10:00', end: '11:00' }]
    }
  ],
  payment: {
    full_price: { enabled: true, amount: 10000 },
    drop_in_price: { enabled: true, amount: 12500 },
    monthly_price: { enabled: true, amount: 3000 }
  }
};
```

### Valid Student Data

```typescript
const validStudent = {
  fullName: 'Test Student',
  email: 'student@test.com',
  mobile: '+919876543211',
  dateOfBirth: '2000-01-01',
  parentName: 'Parent Name',
  parentMobile: '+919876543212'
};
```

### Invalid Test Data (for negative tests)

```typescript
const invalidData = {
  email: {
    empty: '',
    invalid: 'not-an-email',
    missingAt: 'testexample.com',
    missingDomain: 'test@'
  },
  mobile: {
    tooShort: '123',
    tooLong: '123456789012345',
    invalidFormat: 'abcd',
    missingPlus: '919876543210'
  },
  capacity: {
    zero: 0,
    negative: -5,
    decimal: 20.5,
    string: 'twenty'
  }
};
```

---

## 🔍 DEBUGGING TIPS

### Debug Unit Tests

```typescript
// Add console.log
it('should do something', () => {
  console.log('Form value:', component.form.value);
  expect(component.form.valid).toBeTrue();
});

// Use fit to run only this test
fit('should debug this', () => {
  // test code
});

// Use fdescribe to run only this suite
fdescribe('ComponentName', () => {
  // tests
});
```

### Debug E2E Tests

```bash
# Run in debug mode
npx playwright test --debug

# Run with trace
npx playwright test --trace on

# View trace
npx playwright show-trace trace.zip
```

```typescript
// Add pause to inspect
test('should do something', async ({ page }) => {
  await page.goto('/some-page');
  await page.pause(); // Browser will pause here
  await page.click('button');
});

// Take screenshot
test('should do something', async ({ page }) => {
  await page.screenshot({ path: 'screenshot.png' });
});

// Print to console
test('should do something', async ({ page }) => {
  const text = await page.locator('h1').textContent();
  console.log('Heading:', text);
});
```

---

## 📈 PERFORMANCE TESTING

### Quick Performance Check

```bash
# Install lighthouse
npm install -g lighthouse

# Run lighthouse
lighthouse http://localhost:4200/instructor/dashboard --view

# Check specific metrics
lighthouse http://localhost:4200/instructor/dashboard \
  --only-categories=performance \
  --output=json \
  --output-path=./performance-report.json
```

### Performance Targets

| Metric | Target | Acceptable |
|--------|--------|------------|
| First Contentful Paint | < 1.5s | < 2s |
| Largest Contentful Paint | < 2.5s | < 3s |
| Time to Interactive | < 3s | < 4s |
| Total Blocking Time | < 200ms | < 300ms |
| Cumulative Layout Shift | < 0.1 | < 0.25 |
| Speed Index | < 2.5s | < 3s |

---

## ♿ ACCESSIBILITY TESTING

### Quick A11y Check

```bash
# Install axe
npm install -D @axe-core/playwright

# Run in E2E test
test('should be accessible', async ({ page }) => {
  await page.goto('/instructor/dashboard');
  const results = await injectAxe(page);
  expect(results.violations).toHaveLength(0);
});
```

### Manual A11y Checklist

- [ ] All images have alt text
- [ ] All buttons have labels
- [ ] Form inputs have labels
- [ ] Color contrast ratio > 4.5:1
- [ ] Can navigate with keyboard only
- [ ] Focus indicators visible
- [ ] ARIA labels where needed
- [ ] Heading hierarchy correct (h1 -> h2 -> h3)
- [ ] No auto-playing media
- [ ] Error messages associated with fields

---

## 🚨 CI/CD INTEGRATION

### GitHub Actions Example

Create: `.github/workflows/test.yml`

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - name: Install dependencies
        run: cd frontend && npm ci
      
      - name: Run unit tests
        run: cd frontend && npm test -- --watch=false --browsers=ChromeHeadless --code-coverage
      
      - name: Run E2E tests
        run: cd frontend && npx playwright test
      
      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: playwright-report
          path: frontend/playwright-report/
```

---

## 📝 TEST NAMING CONVENTIONS

### Unit Tests

```typescript
// Pattern: should [action] [expected result]
it('should validate email format', () => {});
it('should call API with correct parameters', () => {});
it('should show error message on failure', () => {});

// Group related tests
describe('Login Functionality', () => {
  describe('Email Validation', () => {
    it('should accept valid email', () => {});
    it('should reject invalid email', () => {});
  });
  
  describe('Password Validation', () => {
    it('should require minimum length', () => {});
    it('should accept strong password', () => {});
  });
});
```

### E2E Tests

```typescript
// Pattern: should [user action] [expected outcome]
test('should login with valid credentials', async ({ page }) => {});
test('should show error for invalid credentials', async ({ page }) => {});
test('should create class and navigate to list', async ({ page }) => {});
```

---

## 🎯 PRIORITY TESTING MATRIX

### P0 - Critical (Must Pass)
- [ ] User login/logout
- [ ] Create class (duration & count)
- [ ] Edit class
- [ ] View class list
- [ ] Mark attendance
- [ ] Payment verification
- [ ] Receipt generation

### P1 - High Priority
- [ ] Student CRUD operations
- [ ] Availability conflict detection
- [ ] Payment filtering & search
- [ ] Calendar sync
- [ ] Bulk operations
- [ ] Export functionality

### P2 - Medium Priority
- [ ] Advanced filters
- [ ] Custom reports
- [ ] Settings & preferences
- [ ] Notifications
- [ ] Help & support

### P3 - Low Priority
- [ ] UI animations
- [ ] Tooltips
- [ ] Optional features
- [ ] Nice-to-have functionality

---

## 💡 TESTING BEST PRACTICES

### DO ✅

- Write tests before/during development
- Keep tests simple and focused
- Use descriptive test names
- Mock external dependencies
- Test one thing per test
- Clean up test data
- Use test helpers/utilities
- Maintain high coverage
- Run tests frequently
- Fix failing tests immediately

### DON'T ❌

- Skip writing tests
- Test implementation details
- Use brittle selectors
- Have interdependent tests
- Ignore flaky tests
- Commit failing tests
- Test third-party code
- Over-mock everything
- Write long, complex tests
- Leave commented-out tests

---

## 🆘 GETTING HELP

### Documentation
- [Playwright Docs](https://playwright.dev/)
- [Angular Testing](https://angular.io/guide/testing)
- [Jasmine Docs](https://jasmine.github.io/)

### Common Resources
- Stack Overflow: Tag with `playwright`, `angular`, `jasmine`
- Playwright Discord: [Join](https://discord.gg/playwright)
- GitHub Issues: Check existing issues first

### Internal Resources
- Review existing test files
- Ask team members
- Check test documentation
- Review CI/CD logs

---

## 🎉 SUCCESS METRICS

Track your testing success:

- **Coverage**: Maintain > 90%
- **Test Count**: ~2000+ total tests
- **Pass Rate**: > 98%
- **Execution Time**: < 60 min (full suite)
- **Flaky Tests**: < 2%
- **Bugs Found in Testing**: Track trend
- **Production Bugs**: < 5 per release

---

## 📋 WEEKLY TESTING CHECKLIST

### Monday
- [ ] Run full test suite
- [ ] Review last week's bugs
- [ ] Update test documentation

### Wednesday
- [ ] Check test coverage
- [ ] Fix any flaky tests
- [ ] Review CI/CD pipeline

### Friday
- [ ] Run performance tests
- [ ] Run security scan
- [ ] Generate test report
- [ ] Plan next week's testing

---

## 🚀 QUICK START FOR NEW DEVELOPERS

1. **Setup:**
   ```bash
   cd frontend
   npm install
   npx playwright install
   ```

2. **Run Your First Test:**
   ```bash
   npm test -- --include='**/app.component.spec.ts'
   ```

3. **Run Your First E2E Test:**
   ```bash
   npx playwright test e2e/example.spec.ts
   ```

4. **Explore Tests:**
   - Open existing test files
   - Understand patterns
   - Copy and modify for your feature

5. **Get Feedback:**
   - Run tests locally
   - Fix issues
   - Commit with passing tests

---

## 📞 SUPPORT

For questions:
1. Check this document
2. Review comprehensive testing strategy
3. Check implementation guide
4. Ask team members
5. Review test examples

**Happy Testing! Keep the bugs away! 🐛❌**

