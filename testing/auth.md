# 🎯 ClassInTown - Comprehensive Testing Estimation
### Complete Feature Coverage Testing Plan

> **Goal:** Test EVERY feature to the bone. Zero bugs across Frontend, Backend, Database.

---

## 📊 Testing Scope Overview

| Category | Features | Test Cases | Estimated Hours |
|----------|----------|------------|-----------------|
| **1. Authentication & Authorization** 🔥 | 6 | **1,733** | **680h** |
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
| **TOTAL** | **62 Features** | **6,134 Test Cases** | **2,200 Hours** |

**Team Size:** 6 QA Engineers (2 Senior + 3 Mid + 1 Junior)  
**Timeline:** ~28 weeks (7 months) of rigorous testing  
**Cost:** ~$134,000 USD (@ $61/hour avg)

### 🔥 Major Changes in This Version:
- **Authentication Testing:** Expanded from 403 → **1,733 tests** (4.3x increase)
- **Security Focus:** Added 810 penetration testing & attack scenarios
- **Comprehensive Coverage:** Every edge case, security vulnerability, and compliance requirement
- **Zero Bug Goal:** Rock-solid authentication with no security vulnerabilities

---

## 🔐 1. AUTHENTICATION & AUTHORIZATION (Security)

> **PRIMARY METHODS:** Google OAuth (70%) + Mobile OTP (25%)  
> **BACKUP METHOD:** Email/Password (5%)

### 📋 AUTHENTICATION TESTING EXECUTIVE SUMMARY

**Total Authentication Test Cases: 1,733** (increased from 403 - a 4.3x expansion)

#### Test Distribution by Method

```
Google OAuth (PRIMARY - 70% users)
├─ Basic Tests: 120
├─ Frontend Security: 30
├─ Backend Security: 50
├─ Database Security: 20
├─ Network & Infrastructure: 20
└─ Cross-Platform: 25
   TOTAL: 265 tests

Mobile OTP (SECONDARY - 25% users)
├─ Basic Tests: 70
├─ Frontend Security: 35
├─ Backend Security: 50
├─ Database Tests: 20
├─ SMS Integration: 20
└─ Cross-Platform: 20
   TOTAL: 215 tests

Google Calendar & Token Integration
├─ Basic Integration: 77
├─ Calendar Deep Dive: 50
└─ Token Security: 50
   TOTAL: 177 tests

Session Management
├─ Basic Tests: 100
└─ Edge Cases: 70
   TOTAL: 170 tests

Email/Password (BACKUP - 5% users)
├─ Basic Tests: 36
└─ Security Tests: 60
   TOTAL: 96 tests

Security & Penetration Testing
├─ Attack Scenarios: 60
├─ Penetration Tests: 420
└─ Compliance Standards: 330
   TOTAL: 810 tests
```

#### Key Testing Focus Areas

**🔴 CRITICAL SECURITY TESTING:**
- XSS, CSRF, SQL Injection, NoSQL Injection
- Token forgery, tampering, replay attacks
- Session hijacking, fixation, replay
- Brute force, credential stuffing, dictionary attacks
- Man-in-the-middle, phishing, clickjacking
- Privilege escalation (horizontal & vertical)
- OWASP Top 10 (2021) - All vulnerabilities
- CWE Top 25 Most Dangerous Weaknesses

**🔒 COMPLIANCE & STANDARDS:**
- OWASP ASVS Level 2
- GDPR (Data Protection)
- PCI DSS (Payment Security)
- ISO 27001, SOC 2 Type II
- India IT Act 2000
- NIST Cybersecurity Framework

**⚡ EDGE CASES COVERED:**
- Network failures, timeouts, slow connections
- Concurrent sessions, device management
- Token expiry, refresh, rotation
- Cross-browser compatibility (25+ platforms)
- Mobile-specific scenarios
- Rate limiting, DDoS protection
- Database performance & security

#### Testing Timeline: 13 Weeks

| Week | Focus | Tests | Hours |
|------|-------|-------|-------|
| 1 | Google OAuth Complete | 265 | 80h |
| 2 | Mobile OTP Complete | 215 | 60h |
| 3 | Calendar & Token Integration | 177 | 60h |
| 4 | Session Management | 170 | 50h |
| 5 | Email/Password | 96 | 30h |
| 6-7 | Attack Scenarios | 60 | 60h |
| 7-9 | Penetration Testing | 420 | 120h |
| 9-10 | Compliance Testing | 330 | 80h |
| 11 | Integration & E2E | - | 60h |
| 12 | Bug Fixes & Regression | - | 40h |
| 13 | Final Security Audit | - | 40h |

**Total: 680 hours, $38,600 budget**

#### Zero Bug Goal 🎯

By testing every possible edge case, attack vector, and compliance requirement, we aim for:
- ✅ **0 Critical Security Bugs**
- ✅ **0 High Priority Bugs**
- ✅ **100% OWASP Compliance**
- ✅ **100% Test Coverage** on authentication flows
- ✅ **Rock-solid security** that withstands real-world attacks

---

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

**Sub-Total:** **120 test cases (Google OAuth - Basic)**

---

#### 🔒 Security Edge Cases - Frontend (Google OAuth)

|| Test ID | Test Scenario | Test Steps | Expected Result | Priority |
||---------|---------------|------------|-----------------|----------|
|| GOA-SEC-F-001 | XSS injection in OAuth redirect | Inject `<script>` in callback URL | Sanitized, no execution | CRITICAL |
|| GOA-SEC-F-002 | CSRF token validation | Missing CSRF token in OAuth flow | Request rejected | CRITICAL |
|| GOA-SEC-F-003 | State parameter validation | Tampered state parameter | OAuth flow rejected | CRITICAL |
|| GOA-SEC-F-004 | Token stored in localStorage | Check if JWT encrypted | Token encrypted/secured | HIGH |
|| GOA-SEC-F-005 | Token exposed in console | Check browser console logs | No token in logs | HIGH |
|| GOA-SEC-F-006 | Token in URL parameters | Token passed via URL | Token NOT in URL | CRITICAL |
|| GOA-SEC-F-007 | Clickjacking attack | Embed login in iframe | X-Frame-Options blocks | HIGH |
|| GOA-SEC-F-008 | Session fixation | Reuse old session ID | New session created | CRITICAL |
|| GOA-SEC-F-009 | Token in browser history | Check browser history | Token NOT stored | HIGH |
|| GOA-SEC-F-010 | Postmessage validation | Malicious postMessage to OAuth | Origin validated, rejected | HIGH |
|| GOA-SEC-F-011 | OAuth popup blocked | Browser blocks popup | Fallback to redirect | MEDIUM |
|| GOA-SEC-F-012 | Multiple OAuth windows | Open 2+ OAuth windows | Only 1 succeeds | MEDIUM |
|| GOA-SEC-F-013 | OAuth timeout (5 min) | User delays consent | Timeout, show error | HIGH |
|| GOA-SEC-F-014 | Browser back button | Back during OAuth flow | Restart flow | MEDIUM |
|| GOA-SEC-F-015 | Browser refresh during OAuth | F5 during callback | Restart flow gracefully | MEDIUM |
|| GOA-SEC-F-016 | Malformed OAuth response | Google returns error | Display user-friendly error | HIGH |
|| GOA-SEC-F-017 | Google account picker | Multiple Google accounts | User can select | MEDIUM |
|| GOA-SEC-F-018 | Incognito mode login | Login in private browsing | Works correctly | HIGH |
|| GOA-SEC-F-019 | Ad blocker interference | Ad blocker active | OAuth still works | MEDIUM |
|| GOA-SEC-F-020 | Third-party cookies disabled | Browser blocks 3rd party | Show warning/guide | HIGH |
|| GOA-SEC-F-021 | Token expiry check on load | Page load with expired token | Auto-refresh or logout | CRITICAL |
|| GOA-SEC-F-022 | localStorage quota exceeded | Storage full | Graceful error handling | LOW |
|| GOA-SEC-F-023 | DOM manipulation attack | Attacker modifies OAuth button | Original button verified | HIGH |
|| GOA-SEC-F-024 | Network disconnect mid-OAuth | WiFi off during flow | Show offline error | MEDIUM |
|| GOA-SEC-F-025 | Slow network (3G) | OAuth on slow connection | Timeout handling | MEDIUM |
|| GOA-SEC-F-026 | Browser extension interference | Malicious extension present | OAuth validated | MEDIUM |
|| GOA-SEC-F-027 | Screen reader accessibility | Blind user using screen reader | ARIA labels correct | LOW |
|| GOA-SEC-F-028 | Keyboard-only navigation | Tab to OAuth button, Enter | Fully accessible | MEDIUM |
|| GOA-SEC-F-029 | Mobile landscape mode | Rotate device during OAuth | Responsive, no break | LOW |
|| GOA-SEC-F-030 | Very small screen (320px) | Old iPhone SE | Button/UI visible | LOW |

**Sub-Total:** **30 additional Security Edge Cases (Frontend)**

---

#### 🔒 Security Edge Cases - Backend (Google OAuth)

|| Test ID | Test Scenario | Test Steps | Expected Result | Priority |
||---------|---------------|------------|-----------------|----------|
|| GOA-SEC-B-001 | Token replay attack | Reuse old Google token | Reject with 401 | CRITICAL |
|| GOA-SEC-B-002 | Token from different app | Token from another Google app | Reject, wrong audience | CRITICAL |
|| GOA-SEC-B-003 | Expired Google token | Send expired token | Return 401 Token Expired | CRITICAL |
|| GOA-SEC-B-004 | Malformed JWT token | Send random string as token | Return 400 Bad Request | HIGH |
|| GOA-SEC-B-005 | Missing Authorization header | No header sent | Return 401 Unauthorized | CRITICAL |
|| GOA-SEC-B-006 | SQL injection in email | Email: `' OR '1'='1` | Sanitized, no SQL exec | CRITICAL |
|| GOA-SEC-B-007 | NoSQL injection | Email: `{"$ne": null}` | Sanitized, rejected | CRITICAL |
|| GOA-SEC-B-008 | Email with special chars | Email: `test+tag@example.com` | Accepted correctly | HIGH |
|| GOA-SEC-B-009 | Very long email (500 chars) | Extremely long email | Reject or truncate | MEDIUM |
|| GOA-SEC-B-010 | Unicode in name | Name: `张三`, `محمد` | Stored correctly (UTF-8) | HIGH |
|| GOA-SEC-B-011 | Emoji in name | Name: `John 😀 Doe` | Stored correctly | MEDIUM |
|| GOA-SEC-B-012 | XSS in profile name | Name: `<script>alert(1)</script>` | Sanitized before storage | CRITICAL |
|| GOA-SEC-B-013 | Path traversal in profile pic | URL: `../../etc/passwd` | Validated, rejected | CRITICAL |
|| GOA-SEC-B-014 | Null byte injection | Email: `test@ex\x00ample.com` | Sanitized/rejected | HIGH |
|| GOA-SEC-B-015 | Rate limiting - 100 req/min | Send 101 requests | 101st rejected (429) | HIGH |
|| GOA-SEC-B-016 | Brute force token guessing | Try 1000 random tokens | All rejected, IP blocked | CRITICAL |
|| GOA-SEC-B-017 | Concurrent logins same user | 5 simultaneous OAuth requests | All succeed, separate sessions | HIGH |
|| GOA-SEC-B-018 | Token verification timeout | Google API slow (>10s) | Timeout, return error | HIGH |
|| GOA-SEC-B-019 | Google API rate limit | Exceed Google API quota | Graceful error, queue | HIGH |
|| GOA-SEC-B-020 | Google API returns 500 | Google server error | Retry 3x, then fail gracefully | HIGH |
|| GOA-SEC-B-021 | Invalid Google token format | Token missing parts (2 dots) | Return 400 Invalid Token | HIGH |
|| GOA-SEC-B-022 | Token with wrong signature | Valid format, wrong signature | Reject after Google verify | CRITICAL |
|| GOA-SEC-B-023 | Token audience mismatch | Token for different client_id | Reject, wrong audience | CRITICAL |
|| GOA-SEC-B-024 | Token issuer not Google | Token from facebook.com | Reject, invalid issuer | CRITICAL |
|| GOA-SEC-B-025 | Token issued in future | `iat` (issued at) in future | Reject, clock skew check | HIGH |
|| GOA-SEC-B-026 | Token expired 1 second ago | `exp` just passed | Reject or allow grace period | HIGH |
|| GOA-SEC-B-027 | Clock skew handling | Server time off by 5 min | Accept with tolerance | MEDIUM |
|| GOA-SEC-B-028 | Missing email in token | Google token without email | Reject, email required | HIGH |
|| GOA-SEC-B-029 | Email not verified at Google | `email_verified: false` | Reject or warn user | HIGH |
|| GOA-SEC-B-030 | Revoked token mid-request | User revokes during processing | Detect and reject | HIGH |
|| GOA-SEC-B-031 | Duplicate email race condition | 2 users, same email, simultaneous | One succeeds, one fails | CRITICAL |
|| GOA-SEC-B-032 | Account linking conflict | Link Google to email already linked | Reject, show error | HIGH |
|| GOA-SEC-B-033 | Orphaned session cleanup | User logs out, session in DB | Session deleted | MEDIUM |
|| GOA-SEC-B-034 | Memory leak on many logins | 1000 logins in 1 minute | No memory leak | HIGH |
|| GOA-SEC-B-035 | Database connection pool | 100 concurrent logins | Pool managed correctly | HIGH |
|| GOA-SEC-B-036 | Transaction rollback | Error after user created | Full rollback, no partial data | CRITICAL |
|| GOA-SEC-B-037 | Google refresh token missing | User denies offline access | Store null, handle gracefully | MEDIUM |
|| GOA-SEC-B-038 | Refresh token encryption | Check DB storage | Token encrypted at rest | CRITICAL |
|| GOA-SEC-B-039 | Access token in logs | Check application logs | Tokens redacted/masked | CRITICAL |
|| GOA-SEC-B-040 | Error messages leak info | Wrong token error | Generic error, no details | HIGH |
|| GOA-SEC-B-041 | User enumeration attack | Check if email exists | Same response for exist/not | HIGH |
|| GOA-SEC-B-042 | Timing attack on token check | Measure response time | Constant time comparison | MEDIUM |
|| GOA-SEC-B-043 | HTTP instead of HTTPS | Send token over HTTP | Reject, HTTPS only | CRITICAL |
|| GOA-SEC-B-044 | CORS misconfiguration | Request from evil.com | CORS blocks request | CRITICAL |
|| GOA-SEC-B-045 | Missing security headers | Check response headers | HSTS, CSP, etc. present | HIGH |
|| GOA-SEC-B-046 | JWT algorithm confusion | Change token alg to 'none' | Reject, alg mismatch | CRITICAL |
|| GOA-SEC-B-047 | JWT kid manipulation | Invalid kid in header | Reject, validation fails | HIGH |
|| GOA-SEC-B-048 | Privilege escalation | Student token → Admin access | Reject, role validated | CRITICAL |
|| GOA-SEC-B-049 | Session hijacking | Steal session ID, replay | Detect via IP/User-Agent | HIGH |
|| GOA-SEC-B-050 | Session fixation attack | Force user to use attacker session | New session on login | CRITICAL |

**Sub-Total:** **50 additional Security Edge Cases (Backend)**

---

#### 🔒 Database Security Tests (Google OAuth)

|| Test ID | Test Scenario | Test Steps | Expected Result | Priority |
||---------|---------------|------------|-----------------|----------|
|| GOA-DB-001 | User collection indexes | Check email index exists | Unique index on email | CRITICAL |
|| GOA-DB-002 | Google ID unique constraint | Insert duplicate google_id | Error: Duplicate key | CRITICAL |
|| GOA-DB-003 | Refresh token encrypted | Query users collection | Tokens encrypted | CRITICAL |
|| GOA-DB-004 | Sensitive fields not exposed | Read user document | No password/token in response | HIGH |
|| GOA-DB-005 | Audit log for login | User logs in | Entry in audit_logs | MEDIUM |
|| GOA-DB-006 | Failed login attempts logged | 5 failed logins | 5 entries in logs | HIGH |
|| GOA-DB-007 | Session collection TTL | Session older than 30 days | Auto-deleted by MongoDB TTL | MEDIUM |
|| GOA-DB-008 | Database injection prevention | Malicious query in email | Query fails safely | CRITICAL |
|| GOA-DB-009 | Read/write permissions | Test DB user permissions | Correct access control | HIGH |
|| GOA-DB-010 | Connection encryption | Check DB connection | TLS/SSL enabled | CRITICAL |
|| GOA-DB-011 | Backup includes auth data | Restore from backup | User can login | HIGH |
|| GOA-DB-012 | Data at rest encryption | Check storage | Encryption enabled | HIGH |
|| GOA-DB-013 | Query performance (1M users) | Find user by email | < 50ms with index | HIGH |
|| GOA-DB-014 | Concurrent write conflicts | 2 updates to same user | Optimistic locking | HIGH |
|| GOA-DB-015 | Transaction isolation | Concurrent reads/writes | Proper isolation level | MEDIUM |
|| GOA-DB-016 | Soft delete users | Mark user deleted | active: false, not removed | MEDIUM |
|| GOA-DB-017 | GDPR data deletion | User requests deletion | All user data removed | CRITICAL |
|| GOA-DB-018 | User profile picture storage | Check image URL | Stored in CDN, not DB | MEDIUM |
|| GOA-DB-019 | Token expiry field | Check sessions | expires_at stored correctly | HIGH |
|| GOA-DB-020 | Multi-tenant data isolation | Query users by business_id | Correct filtering | CRITICAL |

**Sub-Total:** **20 Database Security Tests**

---

#### 🌐 Network & Infrastructure Edge Cases

|| Test ID | Test Scenario | Test Steps | Expected Result | Priority |
||---------|---------------|------------|-----------------|----------|
|| GOA-NET-001 | Google OAuth API down | Google returns 503 | Show error, retry logic | HIGH |
|| GOA-NET-002 | DNS resolution failure | DNS for google.com fails | Timeout, show error | MEDIUM |
|| GOA-NET-003 | SSL certificate expired | Google cert expired | Browser warning, handle | LOW |
|| GOA-NET-004 | Man-in-the-middle attack | Intercept OAuth traffic | SSL/TLS prevents | CRITICAL |
|| GOA-NET-005 | Slow Google API (10s+) | Google responds slowly | Timeout at 15s | HIGH |
|| GOA-NET-006 | Network packet loss (50%) | Unstable connection | Retry mechanism works | MEDIUM |
|| GOA-NET-007 | CDN failure (Cloudflare) | CDN down | Fallback to origin | MEDIUM |
|| GOA-NET-008 | Load balancer failure | One server down | Traffic to healthy server | HIGH |
|| GOA-NET-009 | Database connection lost | DB disconnects mid-request | Reconnect, retry | HIGH |
|| GOA-NET-010 | Redis cache down | Cache unavailable | Fallback to DB | MEDIUM |
|| GOA-NET-011 | Email service down | SendGrid/SES unavailable | Queue email, retry later | MEDIUM |
|| GOA-NET-012 | SMS gateway timeout | Twilio timeout | Graceful error | MEDIUM |
|| GOA-NET-013 | API rate limit from proxy | Too many requests from IP | Distribute across IPs | MEDIUM |
|| GOA-NET-014 | IPv6 vs IPv4 | User on IPv6 network | OAuth works | LOW |
|| GOA-NET-015 | VPN/Proxy usage | User behind VPN | OAuth works | MEDIUM |
|| GOA-NET-016 | Corporate firewall | Firewall blocks OAuth | Detect, show guide | MEDIUM |
|| GOA-NET-017 | DDoS attack simulation | 10,000 req/sec | Rate limiting, Cloudflare | HIGH |
|| GOA-NET-018 | Geographic latency (India) | User in Mumbai | < 1s response | HIGH |
|| GOA-NET-019 | Geographic latency (US) | User in New York | < 3s response | MEDIUM |
|| GOA-NET-020 | Mobile network (4G) | User on mobile data | OAuth completes | HIGH |

**Sub-Total:** **20 Network & Infrastructure Tests**

---

#### 📱 Cross-Platform & Browser Compatibility

|| Test ID | Browser/Device | OAuth Flow | Token Storage | Callback | Priority |
||---------|----------------|------------|---------------|----------|----------|
|| GOA-PLAT-001 | Chrome (latest) | ✓ | ✓ | ✓ | CRITICAL |
|| GOA-PLAT-002 | Chrome (3 versions old) | ✓ | ✓ | ✓ | HIGH |
|| GOA-PLAT-003 | Firefox (latest) | ✓ | ✓ | ✓ | CRITICAL |
|| GOA-PLAT-004 | Safari (macOS) | ✓ | ✓ | ✓ | CRITICAL |
|| GOA-PLAT-005 | Safari (iOS) | ✓ | ✓ | ✓ | CRITICAL |
|| GOA-PLAT-006 | Edge (Chromium) | ✓ | ✓ | ✓ | HIGH |
|| GOA-PLAT-007 | Brave browser | ✓ | ✓ | ✓ | MEDIUM |
|| GOA-PLAT-008 | Opera browser | ✓ | ✓ | ✓ | LOW |
|| GOA-PLAT-009 | Samsung Internet | ✓ | ✓ | ✓ | MEDIUM |
|| GOA-PLAT-010 | UC Browser (India) | ✓ | ✓ | ✓ | MEDIUM |
|| GOA-PLAT-011 | Chrome on Android 14 | ✓ | ✓ | ✓ | HIGH |
|| GOA-PLAT-012 | Chrome on Android 10 | ✓ | ✓ | ✓ | MEDIUM |
|| GOA-PLAT-013 | Safari on iPhone 15 | ✓ | ✓ | ✓ | HIGH |
|| GOA-PLAT-014 | Safari on iPhone 12 | ✓ | ✓ | ✓ | MEDIUM |
|| GOA-PLAT-015 | iPad Pro (Safari) | ✓ | ✓ | ✓ | MEDIUM |
|| GOA-PLAT-016 | Android tablet | ✓ | ✓ | ✓ | LOW |
|| GOA-PLAT-017 | Windows 11 (Chrome) | ✓ | ✓ | ✓ | HIGH |
|| GOA-PLAT-018 | Windows 10 (Edge) | ✓ | ✓ | ✓ | HIGH |
|| GOA-PLAT-019 | macOS Sonoma (Safari) | ✓ | ✓ | ✓ | HIGH |
|| GOA-PLAT-020 | Linux (Firefox) | ✓ | ✓ | ✓ | MEDIUM |
|| GOA-PLAT-021 | Chrome Incognito | ✓ | ✓ (session) | ✓ | HIGH |
|| GOA-PLAT-022 | Firefox Private | ✓ | ✓ (session) | ✓ | MEDIUM |
|| GOA-PLAT-023 | Safari Private | ✓ | ✓ (session) | ✓ | MEDIUM |
|| GOA-PLAT-024 | WebView (Android app) | ✓ | ✓ | ✓ | HIGH |
|| GOA-PLAT-025 | WKWebView (iOS app) | ✓ | ✓ | ✓ | HIGH |

**Sub-Total:** **25 Cross-Platform Tests**

---

**Google OAuth Extended Total:** **120 (basic) + 30 (FE security) + 50 (BE security) + 20 (DB) + 20 (Network) + 25 (Platform) = 265 test cases**

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

**Sub-Total:** **70 test cases (Mobile OTP - Basic)**

---

#### 🔒 Security Edge Cases - Mobile OTP (Frontend)

|| Test ID | Test Scenario | Test Steps | Expected Result | Priority |
||---------|---------------|------------|-----------------|----------|
|| OTP-SEC-F-001 | OTP visible in plain text | Check input field type | Type: "text" (visible) or "password" | MEDIUM |
|| OTP-SEC-F-002 | OTP in browser autofill | Browser suggests OTP | Auto-fill works (SMS OTP) | HIGH |
|| OTP-SEC-F-003 | Copy-paste OTP disabled | Try to paste OTP | Paste allowed (UX) | LOW |
|| OTP-SEC-F-004 | OTP in browser history | Check history | OTP NOT stored | HIGH |
|| OTP-SEC-F-005 | Mobile number in localStorage | Check storage | Mobile NOT stored plain | MEDIUM |
|| OTP-SEC-F-006 | Resend spam prevention | Click resend 10x rapidly | Limited to 1 per 60s | HIGH |
|| OTP-SEC-F-007 | Timer countdown accuracy | Check 60s timer | Accurate countdown | MEDIUM |
|| OTP-SEC-F-008 | Timer manipulation | Change system clock | Timer continues correctly | LOW |
|| OTP-SEC-F-009 | OTP field validation (6 digits) | Enter 5 digits | Button disabled | HIGH |
|| OTP-SEC-F-010 | OTP field accepts letters | Enter "ABCDEF" | Rejected, numbers only | HIGH |
|| OTP-SEC-F-011 | OTP field accepts special chars | Enter "!@#$%^" | Rejected | HIGH |
|| OTP-SEC-F-012 | XSS in mobile number field | Enter `<script>` | Sanitized | CRITICAL |
|| OTP-SEC-F-013 | SQL injection in mobile | Enter `' OR '1'='1` | Sanitized | CRITICAL |
|| OTP-SEC-F-014 | Country code dropdown | Select wrong country | Mobile validation fails | HIGH |
|| OTP-SEC-F-015 | Mobile with spaces | Enter "98765 43210" | Spaces removed, accepted | MEDIUM |
|| OTP-SEC-F-016 | Mobile with dashes | Enter "9876-543-210" | Dashes removed, accepted | MEDIUM |
|| OTP-SEC-F-017 | Mobile with +91 prefix | Enter "+91 9876543210" | Accepted or prefix removed | HIGH |
|| OTP-SEC-F-018 | Invalid mobile length | Enter "123" (3 digits) | Show error | HIGH |
|| OTP-SEC-F-019 | Mobile starting with 0 | Enter "09876543210" | Reject or auto-correct | HIGH |
|| OTP-SEC-F-020 | Mobile all zeros | Enter "0000000000" | Reject as invalid | MEDIUM |
|| OTP-SEC-F-021 | Mobile all same digit | Enter "1111111111" | Accept (valid format) | MEDIUM |
|| OTP-SEC-F-022 | Very long mobile (20 digits) | Enter 20 digits | Truncate or reject | MEDIUM |
|| OTP-SEC-F-023 | Network error on send OTP | API fails | Show error message | HIGH |
|| OTP-SEC-F-024 | Network error on verify | API fails | Show retry option | HIGH |
|| OTP-SEC-F-025 | Loading state on send | Click Send OTP | Button disabled, spinner shown | MEDIUM |
|| OTP-SEC-F-026 | Loading state on verify | Click Verify | Button disabled, spinner shown | MEDIUM |
|| OTP-SEC-F-027 | Back button during OTP | Press back | Return to mobile input | MEDIUM |
|| OTP-SEC-F-028 | Refresh page during OTP | F5 on OTP screen | Restart flow or maintain state | MEDIUM |
|| OTP-SEC-F-029 | Multiple tabs send OTP | 2 tabs, same mobile | Both get OTP, race condition | MEDIUM |
|| OTP-SEC-F-030 | OTP expires while typing | Wait 5 min, then verify | Show "OTP expired" error | HIGH |
|| OTP-SEC-F-031 | Rate limit error display | After 3 OTP requests | Show "Try again in X minutes" | HIGH |
|| OTP-SEC-F-032 | Mobile number masking | Display mobile on verify screen | Shown as "****3210" | MEDIUM |
|| OTP-SEC-F-033 | Edit mobile after send OTP | Click "Change mobile" | Allow editing | MEDIUM |
|| OTP-SEC-F-034 | Screen reader support | Use screen reader on form | ARIA labels present | LOW |
|| OTP-SEC-F-035 | Keyboard navigation | Tab through fields | All accessible | LOW |

**Sub-Total:** **35 Security Edge Cases (OTP Frontend)**

---

#### 🔒 Security Edge Cases - Mobile OTP (Backend)

|| Test ID | Test Scenario | Test Steps | Expected Result | Priority |
||---------|---------------|------------|-----------------|----------|
|| OTP-SEC-B-001 | OTP brute force (1000 tries) | Try all 6-digit combos | Block after 3 wrong attempts | CRITICAL |
|| OTP-SEC-B-002 | OTP timing attack | Measure verification time | Constant-time comparison | HIGH |
|| OTP-SEC-B-003 | OTP replay attack | Reuse same OTP twice | Second use rejected | CRITICAL |
|| OTP-SEC-B-004 | OTP from different mobile | OTP for mobile A, verify with B | Rejected | CRITICAL |
|| OTP-SEC-B-005 | Expired OTP (5 min + 1 sec) | Verify after expiry | Rejected | HIGH |
|| OTP-SEC-B-006 | OTP not yet sent | Verify without sending | Rejected | HIGH |
|| OTP-SEC-B-007 | OTP generation randomness | Generate 10,000 OTPs | No predictable pattern | CRITICAL |
|| OTP-SEC-B-008 | OTP hash storage | Check DB | OTP stored as hash | CRITICAL |
|| OTP-SEC-B-009 | OTP in application logs | Check logs | OTP redacted/masked | CRITICAL |
|| OTP-SEC-B-010 | OTP in error messages | Wrong OTP | Generic error, no hints | HIGH |
|| OTP-SEC-B-011 | Rate limit: 3 OTP/hour | Send 4th OTP | 4th rejected (429) | HIGH |
|| OTP-SEC-B-012 | Rate limit: 10 verify/hour | 11th verify attempt | Rejected, account locked | HIGH |
|| OTP-SEC-B-013 | IP-based rate limiting | 100 OTP from same IP | Blocked after threshold | HIGH |
|| OTP-SEC-B-014 | Distributed attack | OTPs from 100 IPs | Each IP limited separately | MEDIUM |
|| OTP-SEC-B-015 | Mobile format: India | +91 9876543210 | Accepted | HIGH |
|| OTP-SEC-B-016 | Mobile format: US | +1 2025551234 | Accepted | MEDIUM |
|| OTP-SEC-B-017 | Mobile format: UK | +44 7911123456 | Accepted | MEDIUM |
|| OTP-SEC-B-018 | Mobile format: Invalid country | +999 1234567890 | Rejected | MEDIUM |
|| OTP-SEC-B-019 | Mobile normalization | Various formats → Normalized | Stored consistently | HIGH |
|| OTP-SEC-B-020 | Duplicate mobile check | Mobile already registered | Link or reject | HIGH |
|| OTP-SEC-B-021 | SMS gateway failure | Twilio returns error | Retry 3x, then fail gracefully | HIGH |
|| OTP-SEC-B-022 | SMS delivery delay (2 min) | SMS arrives late | OTP still valid (5 min window) | MEDIUM |
|| OTP-SEC-B-023 | SMS not delivered | Provider fails | Return error to user | HIGH |
|| OTP-SEC-B-024 | SMS delivery confirmation | Check delivery status | Log delivery receipt | MEDIUM |
|| OTP-SEC-B-025 | SMS cost tracking | Send 1000 OTPs | Track cost per SMS | LOW |
|| OTP-SEC-B-026 | International SMS cost | SMS to US number | Higher cost logged | LOW |
|| OTP-SEC-B-027 | Concurrent OTP sends | 2 sends for same mobile | Only latest OTP valid | HIGH |
|| OTP-SEC-B-028 | OTP cleanup job | OTPs older than 1 hour | Deleted automatically | MEDIUM |
|| OTP-SEC-B-029 | Database index on mobile | Query by mobile | < 50ms with index | HIGH |
|| OTP-SEC-B-030 | Transaction on OTP verify | Verify + create user | Atomic transaction | HIGH |
|| OTP-SEC-B-031 | Rollback on failure | User creation fails | OTP not marked as used | HIGH |
|| OTP-SEC-B-032 | SQL injection in mobile | Malicious mobile input | Sanitized, no execution | CRITICAL |
|| OTP-SEC-B-033 | NoSQL injection | MongoDB query injection | Sanitized | CRITICAL |
|| OTP-SEC-B-034 | XSS in mobile storage | Store malicious mobile | Escaped on retrieval | HIGH |
|| OTP-SEC-B-035 | Mobile number enumeration | Check if mobile exists | Same response (privacy) | HIGH |
|| OTP-SEC-B-036 | SSRF via webhook | Malicious SMS webhook | Validated URL | MEDIUM |
|| OTP-SEC-B-037 | Memory leak (many OTPs) | Send 10,000 OTPs | No memory leak | HIGH |
|| OTP-SEC-B-038 | Database connection pool | 100 concurrent OTP sends | Pool managed | MEDIUM |
|| OTP-SEC-B-039 | OTP for blocked number | Blacklisted mobile | Rejected | MEDIUM |
|| OTP-SEC-B-040 | OTP length variation | 4-digit vs 6-digit | 6-digit enforced | MEDIUM |
|| OTP-SEC-B-041 | Alphanumeric OTP | OTP with letters | Numbers only enforced | MEDIUM |
|| OTP-SEC-B-042 | SMS template injection | Modify SMS template | Template validated | HIGH |
|| OTP-SEC-B-043 | Account linking conflict | Link mobile to existing account | Handle gracefully | HIGH |
|| OTP-SEC-B-044 | First-time user creation | OTP verify → Create account | User created with mobile | HIGH |
|| OTP-SEC-B-045 | Returning user login | OTP verify → Login | Existing user logged in | HIGH |
|| OTP-SEC-B-046 | JWT generation after OTP | Verify success | Valid JWT returned | CRITICAL |
|| OTP-SEC-B-047 | JWT contains mobile | Check JWT payload | Mobile included | HIGH |
|| OTP-SEC-B-048 | Session creation | After OTP verify | Session in DB | HIGH |
|| OTP-SEC-B-049 | Multi-tenant isolation | OTP for Business A | Not usable for Business B | CRITICAL |
|| OTP-SEC-B-050 | Audit log | OTP sent/verified | Logged in audit_logs | MEDIUM |

**Sub-Total:** **50 Security Edge Cases (OTP Backend)**

---

#### 🔒 Database Tests - Mobile OTP

|| Test ID | Test Scenario | Test Steps | Expected Result | Priority |
||---------|---------------|------------|-----------------|----------|
|| OTP-DB-001 | OTP storage structure | Check otps collection | Fields: mobile, otp_hash, expires_at | HIGH |
|| OTP-DB-002 | OTP hash algorithm | Check hashing method | bcrypt or Argon2 | CRITICAL |
|| OTP-DB-003 | OTP expiry timestamp | Check expires_at | 5 minutes from creation | HIGH |
|| OTP-DB-004 | OTP TTL index | Check MongoDB TTL | Auto-delete after expiry | MEDIUM |
|| OTP-DB-005 | Mobile number unique index | Insert duplicate mobile (active OTP) | Update, not insert | HIGH |
|| OTP-DB-006 | OTP attempts tracking | Check failed_attempts field | Increments on wrong OTP | HIGH |
|| OTP-DB-007 | Account lock after 3 fails | 3 wrong OTPs | locked: true in DB | HIGH |
|| OTP-DB-008 | Unlock after time period | Wait 30 min | locked: false | MEDIUM |
|| OTP-DB-009 | OTP history tracking | Check otp_history collection | All OTPs logged | LOW |
|| OTP-DB-010 | SMS delivery status | Check delivery_status field | pending/sent/failed/delivered | MEDIUM |
|| OTP-DB-011 | Rate limit tracking | Check rate_limits collection | Per mobile, per IP | HIGH |
|| OTP-DB-012 | Query performance (1M OTPs) | Find OTP by mobile | < 50ms with index | HIGH |
|| OTP-DB-013 | Concurrent OTP updates | 2 verifies same time | Optimistic locking | HIGH |
|| OTP-DB-014 | Transaction isolation | OTP verify + user create | ACID compliance | CRITICAL |
|| OTP-DB-015 | Backup includes OTPs | Restore from backup | OTPs restored correctly | LOW |
|| OTP-DB-016 | Data encryption at rest | Check DB encryption | Enabled | HIGH |
|| OTP-DB-017 | Sensitive data not in logs | Query logs | No OTP values | CRITICAL |
|| OTP-DB-018 | Cascade delete on user | User deleted | Associated OTPs deleted | MEDIUM |
|| OTP-DB-019 | Index on expires_at | Check index | Exists for cleanup queries | MEDIUM |
|| OTP-DB-020 | Storage size (100K OTPs) | Monitor collection size | < 100MB | LOW |

**Sub-Total:** **20 Database Tests (OTP)**

---

#### 📱 SMS Provider Integration Tests

|| Test ID | Test Scenario | Test Steps | Expected Result | Priority |
||---------|---------------|------------|-----------------|----------|
|| OTP-SMS-001 | Twilio integration | Send OTP via Twilio (India) | SMS delivered | HIGH |
|| OTP-SMS-002 | Twilio US numbers | Send to +1 number | SMS delivered | MEDIUM |
|| OTP-SMS-003 | MSG91 integration (India) | Send via MSG91 | SMS delivered | HIGH |
|| OTP-SMS-004 | AWS SNS integration | Send via SNS | SMS delivered | MEDIUM |
|| OTP-SMS-005 | Failover: Twilio → MSG91 | Twilio fails | Auto-switch to MSG91 | HIGH |
|| OTP-SMS-006 | SMS template customization | Modify template | Custom message sent | MEDIUM |
|| OTP-SMS-007 | SMS sender ID | Check sender name | "ClassInTown" or number | MEDIUM |
|| OTP-SMS-008 | SMS length optimization | Check message length | < 160 chars (1 SMS) | LOW |
|| OTP-SMS-009 | Unicode in SMS (Hindi) | Send with Hindi text | Unicode SMS sent | LOW |
|| OTP-SMS-010 | SMS delivery report | Check webhook | Delivery status received | MEDIUM |
|| OTP-SMS-011 | DND registered number | Send to DND number | Promotional blocked, transactional OK | MEDIUM |
|| OTP-SMS-012 | Invalid phone number | Send to invalid number | Error returned | HIGH |
|| OTP-SMS-013 | SMS cost tracking | Track per-SMS cost | Logged correctly | LOW |
|| OTP-SMS-014 | Bulk SMS sending | Send 1000 OTPs | All delivered, < 5 min | MEDIUM |
|| OTP-SMS-015 | SMS queue | Send 100 simultaneous | Queued, sent in order | HIGH |
|| OTP-SMS-016 | SMS retry logic | Initial send fails | Retry 3x with backoff | HIGH |
|| OTP-SMS-017 | SMS webhook security | Validate webhook signature | Only authentic requests | HIGH |
|| OTP-SMS-018 | SMS rate limit by provider | Exceed provider limit | Handled gracefully | MEDIUM |
|| OTP-SMS-019 | International SMS | Send to 10 countries | All delivered | LOW |
|| OTP-SMS-020 | SMS during provider outage | Provider down | Queue, send when up | MEDIUM |

**Sub-Total:** **20 SMS Integration Tests**

---

#### 🌐 Mobile OTP - Cross-Platform Tests

|| Test ID | Device/Browser | Send OTP | Verify OTP | SMS Autofill | Priority |
||---------|----------------|----------|------------|--------------|----------|
|| OTP-PLAT-001 | Android 14 (Chrome) | ✓ | ✓ | ✓ (SMS OTP API) | HIGH |
|| OTP-PLAT-002 | Android 13 (Chrome) | ✓ | ✓ | ✓ | HIGH |
|| OTP-PLAT-003 | Android 10 (Chrome) | ✓ | ✓ | Manual | MEDIUM |
|| OTP-PLAT-004 | iPhone 15 (Safari) | ✓ | ✓ | ✓ (AutoFill) | HIGH |
|| OTP-PLAT-005 | iPhone 12 (Safari) | ✓ | ✓ | ✓ | HIGH |
|| OTP-PLAT-006 | Samsung Galaxy (Samsung Internet) | ✓ | ✓ | ✓ | MEDIUM |
|| OTP-PLAT-007 | OnePlus (OxygenOS) | ✓ | ✓ | ✓ | MEDIUM |
|| OTP-PLAT-008 | Xiaomi (MIUI) | ✓ | ✓ | ✓ | MEDIUM |
|| OTP-PLAT-009 | Desktop Chrome | ✓ | ✓ | Manual entry | MEDIUM |
|| OTP-PLAT-010 | Desktop Firefox | ✓ | ✓ | Manual entry | MEDIUM |
|| OTP-PLAT-011 | iPad (Safari) | ✓ | ✓ | ✓ | LOW |
|| OTP-PLAT-012 | Android tablet | ✓ | ✓ | Manual | LOW |
|| OTP-PLAT-013 | Mobile with no SMS app | ✓ | Manual verify | N/A | LOW |
|| OTP-PLAT-014 | Dual SIM phone | ✓ | ✓ | Correct SIM | MEDIUM |
|| OTP-PLAT-015 | 2G network | ✓ (slow) | ✓ | SMS delay OK | LOW |
|| OTP-PLAT-016 | 3G network | ✓ | ✓ | ✓ | MEDIUM |
|| OTP-PLAT-017 | 4G/LTE network | ✓ | ✓ | ✓ | HIGH |
|| OTP-PLAT-018 | 5G network | ✓ | ✓ | ✓ | MEDIUM |
|| OTP-PLAT-019 | WiFi only (no cellular) | ✓ | Manual verify | N/A | MEDIUM |
|| OTP-PLAT-020 | Roaming (international) | ✓ | ✓ | SMS delay | LOW |

**Sub-Total:** **20 Cross-Platform Tests (OTP)**

---

**Mobile OTP Extended Total:** **70 (basic) + 35 (FE) + 50 (BE) + 20 (DB) + 20 (SMS) + 20 (Platform) = 215 test cases**

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

**Sub-Total:** **77 test cases (Google Integration - Basic)**

---

#### 🔒 Google Calendar Deep Integration Tests

|| Test ID | Test Scenario | Test Steps | Expected Result | Priority |
||---------|---------------|------------|-----------------|----------|
|| GCAL-001 | First-time calendar scope request | User logs in | Prompt for Calendar access | CRITICAL |
|| GCAL-002 | User grants calendar access | Click "Allow" | Scope stored in DB | CRITICAL |
|| GCAL-003 | User denies calendar access | Click "Deny" | Continue without sync | HIGH |
|| GCAL-004 | Re-request scope later | User clicks "Enable Calendar Sync" | OAuth prompt again | HIGH |
|| GCAL-005 | Multiple calendar selection | User has 3 calendars | Select which to sync | MEDIUM |
|| GCAL-006 | Primary calendar default | No selection | Use primary calendar | HIGH |
|| GCAL-007 | Create event in Google | New class created | Event in Google Calendar | CRITICAL |
|| GCAL-008 | Update event in Google | Edit class time | Google event updated | CRITICAL |
|| GCAL-009 | Delete event in Google | Delete class | Google event deleted | CRITICAL |
|| GCAL-010 | Sync from Google to ClassInTown | Create event in Google | Appears in ClassInTown | HIGH |
|| GCAL-011 | Conflict detection | Same time slot | Show conflict warning | HIGH |
|| GCAL-012 | Conflict resolution | Resolve conflict | User chooses which to keep | MEDIUM |
|| GCAL-013 | Event attendees sync | Add student to class | Student in Google event | HIGH |
|| GCAL-014 | Event location sync | Class venue | Venue in Google event | HIGH |
|| GCAL-015 | Event description sync | Class details | Description in Google | MEDIUM |
|| GCAL-016 | Event reminders | Set reminder in ClassInTown | Google Calendar reminder set | HIGH |
|| GCAL-017 | Recurring event sync | Weekly class | Recurring event in Google | HIGH |
|| GCAL-018 | Edit single recurring event | Edit one instance | Only that instance updated | MEDIUM |
|| GCAL-019 | Edit all recurring events | Edit series | All instances updated | HIGH |
|| GCAL-020 | Delete single recurring event | Delete one | Only that instance deleted | MEDIUM |
|| GCAL-021 | Delete all recurring events | Delete series | All instances deleted | HIGH |
|| GCAL-022 | Timezone handling | Class in IST | Google event in IST | HIGH |
|| GCAL-023 | Daylight saving time | DST change | Times adjusted correctly | MEDIUM |
|| GCAL-024 | All-day event | Full day class | All-day in Google | LOW |
|| GCAL-025 | Multi-day event | 3-day workshop | Spans correctly | LOW |
|| GCAL-026 | Event color coding | Class type → Color | Correct color in Google | LOW |
|| GCAL-027 | Event privacy | Private class | Private in Google | MEDIUM |
|| GCAL-028 | Sync delay | Create class | Synced within 1 minute | HIGH |
|| GCAL-029 | Batch sync | 10 classes at once | All synced correctly | HIGH |
|| GCAL-030 | Sync retry on failure | Network error | Retry 3x with backoff | HIGH |
|| GCAL-031 | Sync queue | 100 events to sync | Queued, processed in order | MEDIUM |
|| GCAL-032 | Google API rate limit | Exceed quota | Queue, sync later | HIGH |
|| GCAL-033 | Google API error (500) | Server error | Retry, graceful failure | HIGH |
|| GCAL-034 | Token expired during sync | Mid-sync token expires | Refresh token, continue | CRITICAL |
|| GCAL-035 | Token revoked during sync | User revokes access | Stop sync, notify user | HIGH |
|| GCAL-036 | Incremental sync | Only sync changes | Not full re-sync | MEDIUM |
|| GCAL-037 | Sync pagination | 1000+ events | Paginate through all | MEDIUM |
|| GCAL-038 | Sync conflict: same event edited | Both sides edited | Last-write-wins or merge | HIGH |
|| GCAL-039 | Sync state tracking | Check sync_status | In DB: pending/syncing/synced/failed | MEDIUM |
|| GCAL-040 | Manual sync trigger | User clicks "Sync Now" | Immediate sync | MEDIUM |
|| GCAL-041 | Auto-sync interval | Every 15 minutes | Background sync | MEDIUM |
|| GCAL-042 | Webhook from Google | Google sends notification | Real-time sync | LOW |
|| GCAL-043 | Sync only future events | Past events | Not synced (performance) | MEDIUM |
|| GCAL-044 | Sync range: 6 months ahead | Events beyond | Not synced yet | LOW |
|| GCAL-045 | Re-sync all | Force full sync | All events re-synced | LOW |
|| GCAL-046 | Sync errors in UI | Failed sync | Show error to user | HIGH |
|| GCAL-047 | Sync history log | Check sync_logs | All syncs logged | LOW |
|| GCAL-048 | Multiple instructors | 2 instructors, same class | Both calendars updated | HIGH |
|| GCAL-049 | Student calendar sync | Student joins class | Event in student's calendar | MEDIUM |
|| GCAL-050 | Disable calendar sync | User disables | Stop syncing, keep data | MEDIUM |

**Sub-Total:** **50 Google Calendar Integration Tests**

---

#### 🔐 Token Security & Lifecycle Tests

|| Test ID | Test Scenario | Test Steps | Expected Result | Priority |
||---------|---------------|------------|-----------------|----------|
|| TOKEN-001 | JWT structure validation | Decode JWT | Header, payload, signature present | CRITICAL |
|| TOKEN-002 | JWT algorithm | Check alg field | RS256 or HS256 (not 'none') | CRITICAL |
|| TOKEN-003 | JWT signature validation | Verify signature | Valid signature required | CRITICAL |
|| TOKEN-004 | JWT expiry claim | Check exp field | Timestamp in future | CRITICAL |
|| TOKEN-005 | JWT issued at claim | Check iat field | Timestamp in past | HIGH |
|| TOKEN-006 | JWT not before claim | Check nbf field | Timestamp validation | MEDIUM |
|| TOKEN-007 | JWT issuer claim | Check iss field | ClassInTown or Google | CRITICAL |
|| TOKEN-008 | JWT audience claim | Check aud field | Correct audience | CRITICAL |
|| TOKEN-009 | JWT subject claim | Check sub field | User ID present | HIGH |
|| TOKEN-010 | JWT custom claims | Check role, permissions | Correct user data | HIGH |
|| TOKEN-011 | Token in Authorization header | Format: "Bearer {token}" | Parsed correctly | CRITICAL |
|| TOKEN-012 | Missing Bearer prefix | Just token, no Bearer | Rejected (400) | HIGH |
|| TOKEN-013 | Malformed Bearer header | "Bearer" with no token | Rejected (400) | HIGH |
|| TOKEN-014 | Multiple Authorization headers | 2 headers sent | Use first or reject | MEDIUM |
|| TOKEN-015 | Token in query parameter | ?token=xyz | Rejected (insecure) | HIGH |
|| TOKEN-016 | Token in POST body | {token: "xyz"} | Rejected (use header) | HIGH |
|| TOKEN-017 | Token in cookie | Cookie: token=xyz | Accepted if configured | MEDIUM |
|| TOKEN-018 | HttpOnly cookie | Check cookie flags | HttpOnly, Secure, SameSite | HIGH |
|| TOKEN-019 | Token refresh endpoint | POST /api/auth/refresh | New token returned | CRITICAL |
|| TOKEN-020 | Refresh with expired token | Refresh token expired | Rejected, re-login required | CRITICAL |
|| TOKEN-021 | Refresh with invalid token | Bad refresh token | Rejected (401) | CRITICAL |
|| TOKEN-022 | Refresh token rotation | Use refresh token | New refresh token issued | HIGH |
|| TOKEN-023 | Refresh token reuse detection | Use old refresh token | Rejected, invalidate session | CRITICAL |
|| TOKEN-024 | Token blacklist on logout | User logs out | Token added to blacklist | HIGH |
|| TOKEN-025 | Blacklisted token check | Use blacklisted token | Rejected (401) | HIGH |
|| TOKEN-026 | Token family/chain tracking | Multiple refreshes | Chain maintained | MEDIUM |
|| TOKEN-027 | Logout from all devices | User clicks "Logout All" | All tokens invalidated | HIGH |
|| TOKEN-028 | Token sliding window | Activity within window | Token validity extended | MEDIUM |
|| TOKEN-029 | Idle timeout (30 min) | No activity for 30 min | Token expires | MEDIUM |
|| TOKEN-030 | Absolute timeout (7 days) | 7 days after login | Force re-login | HIGH |
|| TOKEN-031 | Remember me (30 days) | "Remember me" checked | Longer token validity | LOW |
|| TOKEN-032 | Token storage: localStorage | Store in localStorage | Retrieved correctly | HIGH |
|| TOKEN-033 | Token storage: sessionStorage | Use sessionStorage | Cleared on tab close | MEDIUM |
|| TOKEN-034 | Token storage: cookie | Use cookie | Sent automatically | MEDIUM |
|| TOKEN-035 | Token storage: IndexedDB | Large tokens | Use IndexedDB | LOW |
|| TOKEN-036 | Token size limit | Very large token (>4KB) | Handle or reject | LOW |
|| TOKEN-037 | Token encryption in transit | HTTPS only | TLS 1.2+ required | CRITICAL |
|| TOKEN-038 | Token encryption at rest | DB storage | Encrypted in database | CRITICAL |
|| TOKEN-039 | Token in error responses | Error occurs | Token NOT in response | HIGH |
|| TOKEN-040 | Token in logs | Check all logs | Token redacted | CRITICAL |
|| TOKEN-041 | Token in monitoring tools | Sentry, DataDog | Token masked | HIGH |
|| TOKEN-042 | Token scope validation | Token has limited scope | Scope enforced | HIGH |
|| TOKEN-043 | Token role validation | Student token → Admin API | Rejected (403) | CRITICAL |
|| TOKEN-044 | Token permission validation | Missing permission | Rejected (403) | HIGH |
|| TOKEN-045 | Token tenant validation | Business A token → Business B | Rejected | CRITICAL |
|| TOKEN-046 | Token device fingerprinting | Track device info | Device ID in token | MEDIUM |
|| TOKEN-047 | Token IP binding | Bind to IP | IP change detected | LOW |
|| TOKEN-048 | Token User-Agent binding | Bind to User-Agent | UA change detected | LOW |
|| TOKEN-049 | Token geolocation check | Unusual location | Warning or block | LOW |
|| TOKEN-050 | Token compromise detection | Suspicious activity | Auto-revoke token | HIGH |

**Sub-Total:** **50 Token Security Tests**

---

**Google Integration Extended Total:** **77 (basic) + 50 (Calendar) + 50 (Token) = 177 test cases**

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

**Sub-Total:** **36 test cases (Email/Password - Basic)**

---

#### 🔒 Email/Password - Comprehensive Security Tests

|| Test ID | Test Scenario | Test Steps | Expected Result | Priority |
||---------|---------------|------------|-----------------|----------|
|| EP-SEC-001 | Email format validation | Various email formats | RFC 5322 compliant | HIGH |
|| EP-SEC-002 | Email with + symbol | test+tag@example.com | Accepted | MEDIUM |
|| EP-SEC-003 | Email with dots | test.name@example.com | Accepted | MEDIUM |
|| EP-SEC-004 | Email case sensitivity | Test@Example.COM | Normalized to lowercase | HIGH |
|| EP-SEC-005 | Email whitespace trimming | " test@example.com " | Trimmed automatically | HIGH |
|| EP-SEC-006 | Password minimum length | Less than 8 chars | Rejected | CRITICAL |
|| EP-SEC-007 | Password maximum length | More than 128 chars | Truncated or rejected | MEDIUM |
|| EP-SEC-008 | Password complexity | Require uppercase, lowercase, number, symbol | Enforced | HIGH |
|| EP-SEC-009 | Password common passwords | "password123" | Rejected (dictionary check) | HIGH |
|| EP-SEC-010 | Password same as email | Password equals email | Rejected | MEDIUM |
|| EP-SEC-011 | Password hashing algorithm | Check DB | bcrypt or Argon2 | CRITICAL |
|| EP-SEC-012 | Password salt | Check hash | Unique salt per password | CRITICAL |
|| EP-SEC-013 | Password hash cost factor | bcrypt rounds | 10-12 rounds | HIGH |
|| EP-SEC-014 | Brute force protection | 5 wrong attempts | Account locked 30 min | CRITICAL |
|| EP-SEC-015 | Credential stuffing | 100 login attempts | IP blocked | HIGH |
|| EP-SEC-016 | Rate limiting per IP | 10 logins/minute | 11th rejected | HIGH |
|| EP-SEC-017 | Rate limiting per email | 5 attempts/hour | 6th rejected | HIGH |
|| EP-SEC-018 | CAPTCHA after failures | 3 wrong attempts | CAPTCHA required | HIGH |
|| EP-SEC-019 | Timing attack prevention | Wrong email vs wrong password | Same response time | HIGH |
|| EP-SEC-020 | User enumeration | Check if email exists | Same response | HIGH |
|| EP-SEC-021 | Password reset token | Generate reset token | Cryptographically random | CRITICAL |
|| EP-SEC-022 | Reset token expiry | Token expires | 1 hour expiry | HIGH |
|| EP-SEC-023 | Reset token single use | Use token twice | Second use rejected | CRITICAL |
|| EP-SEC-024 | Reset link format | Check link | HTTPS, no token in URL (use POST) | HIGH |
|| EP-SEC-025 | Reset token in database | Check storage | Hashed, not plain text | CRITICAL |
|| EP-SEC-026 | Reset email delivery | Send reset email | Delivered within 1 min | HIGH |
|| EP-SEC-027 | Reset email template | Check content | Professional, no phishing indicators | MEDIUM |
|| EP-SEC-028 | Multiple reset requests | Request 5 times | Only latest valid | HIGH |
|| EP-SEC-029 | Reset with wrong token | Invalid token | Rejected | HIGH |
|| EP-SEC-030 | Password reset rate limiting | 10 requests/hour | 11th rejected | MEDIUM |
|| EP-SEC-031 | Password history | New password same as old | Rejected (last 5 passwords) | MEDIUM |
|| EP-SEC-032 | Password strength meter | Show strength | Weak/Medium/Strong | LOW |
|| EP-SEC-033 | Show/hide password toggle | Click eye icon | Password visibility toggles | LOW |
|| EP-SEC-034 | Password paste disabled | Try paste | Allowed (UX best practice) | LOW |
|| EP-SEC-035 | Account lockout notification | Account locked | Email sent | MEDIUM |
|| EP-SEC-036 | Account unlock | Wait 30 min | Auto-unlocked | MEDIUM |
|| EP-SEC-037 | Admin unlock account | Admin action | Immediately unlocked | MEDIUM |
|| EP-SEC-038 | Failed login logging | Wrong password | Logged with IP, timestamp | HIGH |
|| EP-SEC-039 | Successful login logging | Login success | Logged in audit_logs | MEDIUM |
|| EP-SEC-040 | SQL injection in email | ' OR '1'='1 | Sanitized, no SQL exec | CRITICAL |
|| EP-SEC-041 | SQL injection in password | Malicious input | Sanitized | CRITICAL |
|| EP-SEC-042 | XSS in email field | <script> tag | Sanitized | CRITICAL |
|| EP-SEC-043 | LDAP injection | Email with LDAP chars | Sanitized | MEDIUM |
|| EP-SEC-044 | Email verification required | Unverified email login | Rejected or prompt to verify | MEDIUM |
|| EP-SEC-045 | Email verification link | Click verify link | Email marked verified | MEDIUM |
|| EP-SEC-046 | Email verification expiry | 24-hour expiry | Expired link rejected | MEDIUM |
|| EP-SEC-047 | Resend verification email | User requests | New email sent | MEDIUM |
|| EP-SEC-048 | Change email | User updates email | Re-verification required | HIGH |
|| EP-SEC-049 | Change password | User updates password | Old password required | HIGH |
|| EP-SEC-050 | Current password validation | Wrong current password | Change rejected | HIGH |
|| EP-SEC-051 | Password confirmation | Passwords don't match | Error shown | HIGH |
|| EP-SEC-052 | Session invalidation on password change | Password changed | All sessions terminated | HIGH |
|| EP-SEC-053 | Login with old password | After password change | Rejected | HIGH |
|| EP-SEC-054 | 2FA enrollment (optional) | User enables 2FA | TOTP setup | LOW |
|| EP-SEC-055 | 2FA login | 2FA enabled | OTP required after password | LOW |
|| EP-SEC-056 | 2FA backup codes | Generate codes | 10 backup codes created | LOW |
|| EP-SEC-057 | Login with backup code | Use backup code | Login successful, code invalidated | LOW |
|| EP-SEC-058 | 2FA recovery | Lost device | Recovery via email | LOW |
|| EP-SEC-059 | Remember device (30 days) | "Trust this device" | 2FA skipped for 30 days | LOW |
|| EP-SEC-060 | Account deletion | User deletes account | Data removed, email released | MEDIUM |

**Sub-Total:** **60 Email/Password Security Tests**

---

**Email/Password Extended Total:** **36 (basic) + 60 (security) = 96 test cases**

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

**Sub-Total:** **100 test cases (Session Management - Basic)**

---

#### 🔒 Session Management - Comprehensive Edge Cases

|| Test ID | Test Scenario | Test Steps | Expected Result | Priority |
||---------|---------------|------------|-----------------|----------|
|| SESS-001 | Session creation on login | User logs in | Session in DB with metadata | CRITICAL |
|| SESS-002 | Session ID generation | Create session | Cryptographically random ID | CRITICAL |
|| SESS-003 | Session ID length | Check session ID | 128+ bits entropy | HIGH |
|| SESS-004 | Session ID collision | Create 1M sessions | No collisions | HIGH |
|| SESS-005 | Session storage location | Check DB | sessions collection exists | HIGH |
|| SESS-006 | Session data structure | Query session | user_id, token, created_at, expires_at, device_info | HIGH |
|| SESS-007 | Session expiry time | Check expires_at | 24 hours from creation | HIGH |
|| SESS-008 | Session auto-renewal | Activity detected | Expiry extended | MEDIUM |
|| SESS-009 | Session absolute timeout | 7 days after creation | Force logout | HIGH |
|| SESS-010 | Session idle timeout | 30 min no activity | Logout | MEDIUM |
|| SESS-011 | Session validation on each request | API call | Session checked | CRITICAL |
|| SESS-012 | Invalid session ID | Use random session ID | Rejected (401) | HIGH |
|| SESS-013 | Expired session | Use expired session | Rejected, redirect to login | HIGH |
|| SESS-014 | Session hijacking attempt | Different IP/User-Agent | Warn or block | HIGH |
|| SESS-015 | Session fixation prevention | Pre-login session ID | New ID after login | CRITICAL |
|| SESS-016 | Session replay attack | Reuse logged-out session | Rejected | CRITICAL |
|| SESS-017 | Concurrent sessions same user | Login from 3 devices | All sessions active | HIGH |
|| SESS-018 | Max sessions per user | 6th concurrent login | Oldest session terminated | MEDIUM |
|| SESS-019 | Session device tracking | Check device_info | OS, browser, IP logged | MEDIUM |
|| SESS-020 | Session location tracking | Check geolocation | Country/city logged | LOW |
|| SESS-021 | New device notification | Login from new device | Email notification sent | MEDIUM |
|| SESS-022 | Suspicious activity detection | Login from new country | Additional verification | MEDIUM |
|| SESS-023 | Session list in UI | User views active sessions | All sessions shown | MEDIUM |
|| SESS-024 | Logout from specific device | User clicks "Logout Device X" | Only that session terminated | HIGH |
|| SESS-025 | Logout from all devices | Click "Logout All" | All sessions terminated | HIGH |
|| SESS-026 | Logout from current device | Click "Logout" | Current session terminated | CRITICAL |
|| SESS-027 | Session after password change | User changes password | All sessions invalidated | HIGH |
|| SESS-028 | Session after account deletion | Account deleted | All sessions terminated | HIGH |
|| SESS-029 | Session cleanup job | Cron job runs | Expired sessions deleted | MEDIUM |
|| SESS-030 | Session cleanup frequency | Check cron | Runs every 1 hour | LOW |
|| SESS-031 | Session in Redis cache | Check cache | Session cached for fast lookup | MEDIUM |
|| SESS-032 | Cache invalidation on logout | User logs out | Cache cleared | HIGH |
|| SESS-033 | Cache miss fallback | Redis down | Fallback to DB | HIGH |
|| SESS-034 | Session sync: Redis ↔ DB | Session created | Synced to both | MEDIUM |
|| SESS-035 | Session token in cookie | Check HTTP cookie | HttpOnly, Secure, SameSite | HIGH |
|| SESS-036 | Session token in localStorage | Alternative storage | Retrieved correctly | MEDIUM |
|| SESS-037 | Session token rotation | After 1 hour | New token issued | MEDIUM |
|| SESS-038 | Old token grace period | Use old token (within 5 min) | Still valid | LOW |
|| SESS-039 | Session CSRF protection | CSRF token in session | Validated on state-changing requests | CRITICAL |
|| SESS-040 | Session across subdomains | login.classintown.com → app.classintown.com | Session shared | MEDIUM |
|| SESS-041 | Session on mobile app | Native app login | Session works | HIGH |
|| SESS-042 | Session on WebView | Embedded browser | Session works | MEDIUM |
|| SESS-043 | Session persistence | Browser close/reopen | Session restored | HIGH |
|| SESS-044 | Session in incognito mode | Private browsing | Session cleared on close | MEDIUM |
|| SESS-045 | Session warning (5 min left) | 5 min before expiry | Show warning popup | MEDIUM |
|| SESS-046 | Session extension on warning | User clicks "Stay logged in" | Session extended | MEDIUM |
|| SESS-047 | Session auto-logout | No response to warning | Logged out | MEDIUM |
|| SESS-048 | Session heartbeat | Every 5 minutes | Ping to keep alive | LOW |
|| SESS-049 | Session in multiple tabs | 3 tabs open | Sync session state | MEDIUM |
|| SESS-050 | Logout in one tab | Close tab A | Other tabs detect logout | HIGH |
|| SESS-051 | Token refresh in one tab | Tab A refreshes | Other tabs get new token | MEDIUM |
|| SESS-052 | Session race condition | 2 requests simultaneous | Both succeed | MEDIUM |
|| SESS-053 | Session database index | Query by user_id | < 50ms with index | HIGH |
|| SESS-054 | Session database index | Query by token | < 50ms with index | HIGH |
|| SESS-055 | Session query performance (1M sessions) | Find session | < 100ms | HIGH |
|| SESS-056 | Session transaction safety | Concurrent updates | No data corruption | HIGH |
|| SESS-057 | Session backup | Backup sessions | Restored correctly | LOW |
|| SESS-058 | Session encryption at rest | Check DB | Encrypted | HIGH |
|| SESS-059 | Session token in logs | Check logs | Token redacted | CRITICAL |
|| SESS-060 | Session data in error messages | Error occurs | No session data leaked | HIGH |
|| SESS-061 | Session audit trail | All session events | Logged in audit_logs | MEDIUM |
|| SESS-062 | Session IP whitelist | Restrict to certain IPs | Enforced | LOW |
|| SESS-063 | Session IP blacklist | Block malicious IPs | Blocked | MEDIUM |
|| SESS-064 | Session rate limiting | 100 requests/minute | Enforced per session | HIGH |
|| SESS-065 | Session remember me | "Remember me" checked | 30-day expiry | MEDIUM |
|| SESS-066 | Session remember me (unchecked) | Not checked | 24-hour expiry | MEDIUM |
|| SESS-067 | Session 2FA requirement | Admin account | 2FA enforced | MEDIUM |
|| SESS-068 | Session step-up authentication | Sensitive action | Re-authenticate | LOW |
|| SESS-069 | Session device fingerprinting | Track device | Consistent fingerprint | LOW |
|| SESS-070 | Session anomaly detection | Unusual pattern | Flag for review | LOW |

**Sub-Total:** **70 Comprehensive Session Management Tests**

---

**Session Management Extended Total:** **100 (basic) + 70 (edge cases) = 170 test cases**

---

### 1.6 🔴 Security Attack Scenarios & Penetration Testing

> **Critical:** Simulate real-world attacks to ensure authentication is bulletproof

#### Authentication Attack Scenarios

|| Test ID | Attack Type | Test Scenario | Expected Result | Priority |
||---------|-------------|---------------|-----------------|----------|
|| ATK-001 | Brute Force | Try 10,000 password combinations | Blocked after 5 attempts | CRITICAL |
|| ATK-002 | Dictionary Attack | Use common password list (10K) | All rejected, rate limited | CRITICAL |
|| ATK-003 | Credential Stuffing | Replay leaked credentials | Detect and block | CRITICAL |
|| ATK-004 | Password Spraying | Same password, many accounts | Detect pattern, block | HIGH |
|| ATK-005 | Rainbow Table Attack | Pre-computed hash attack | Salted hashes prevent | CRITICAL |
|| ATK-006 | Session Hijacking | Steal session cookie | Detect IP/UA change | CRITICAL |
|| ATK-007 | Session Fixation | Force user to use attacker's session | New session on login | CRITICAL |
|| ATK-008 | Session Replay | Replay captured session | Detect and reject | CRITICAL |
|| ATK-009 | Token Theft | Steal JWT from storage | Token encrypted/httpOnly | CRITICAL |
|| ATK-010 | Token Forgery | Create fake JWT | Signature validation fails | CRITICAL |
|| ATK-011 | Token Tampering | Modify JWT payload | Signature mismatch | CRITICAL |
|| ATK-012 | Algorithm Confusion | Change JWT alg to "none" | Rejected | CRITICAL |
|| ATK-013 | CSRF Attack | Force state-changing request | CSRF token validation | CRITICAL |
|| ATK-014 | XSS Attack | Inject script to steal token | Sanitization prevents | CRITICAL |
|| ATK-015 | Clickjacking | Embed login in invisible iframe | X-Frame-Options blocks | HIGH |
|| ATK-016 | Phishing | Fake login page | User education + 2FA helps | MEDIUM |
|| ATK-017 | Man-in-the-Middle | Intercept traffic | HTTPS + HSTS enforced | CRITICAL |
|| ATK-018 | DNS Spoofing | Redirect to fake site | DNSSEC, certificate pinning | MEDIUM |
|| ATK-019 | SQL Injection | Inject SQL in login form | Prepared statements prevent | CRITICAL |
|| ATK-020 | NoSQL Injection | MongoDB query injection | Input sanitization prevents | CRITICAL |
|| ATK-021 | LDAP Injection | Inject LDAP query | Input validation prevents | MEDIUM |
|| ATK-022 | XML Injection | XML entity attack | XML parser secured | LOW |
|| ATK-023 | XXE Attack | External entity injection | DTD processing disabled | MEDIUM |
|| ATK-024 | SSRF Attack | Server-side request forgery | URL validation | MEDIUM |
|| ATK-025 | Open Redirect | Redirect to malicious site | Whitelist validation | MEDIUM |
|| ATK-026 | Path Traversal | Access unauthorized files | Path normalization | HIGH |
|| ATK-027 | File Upload Attack | Upload malicious file | File type validation | HIGH |
|| ATK-028 | Command Injection | Execute system commands | Input sanitization | CRITICAL |
|| ATK-029 | Code Injection | Inject executable code | No eval(), sanitized | CRITICAL |
|| ATK-030 | Timing Attack | Measure response time | Constant-time comparison | HIGH |
|| ATK-031 | Side-Channel Attack | Extract info via timing | Prevent info leakage | MEDIUM |
|| ATK-032 | Replay Attack | Replay old authentication | Nonce/timestamp validation | HIGH |
|| ATK-033 | Downgrade Attack | Force weak encryption | TLS 1.2+ enforced | HIGH |
|| ATK-034 | Cookie Poisoning | Tamper with cookies | Signed cookies validated | HIGH |
|| ATK-035 | HTTP Response Splitting | Inject headers | Header validation | MEDIUM |
|| ATK-036 | Header Injection | CRLF injection | Input sanitization | MEDIUM |
|| ATK-037 | Host Header Injection | Manipulate Host header | Validated against whitelist | MEDIUM |
|| ATK-038 | Cache Poisoning | Poison CDN cache | Cache keys validated | LOW |
|| ATK-039 | DoS - Application Layer | Flood login requests | Rate limiting active | HIGH |
|| ATK-040 | DoS - Slowloris | Slow connection attack | Connection timeout | MEDIUM |
|| ATK-041 | DDoS Simulation | 10,000 concurrent requests | Cloudflare/WAF blocks | HIGH |
|| ATK-042 | Regex DoS (ReDoS) | Evil regex input | Regex timeout/optimization | MEDIUM |
|| ATK-043 | Billion Laughs Attack | XML bomb | XML parser limits | LOW |
|| ATK-044 | ZIP Bomb | Compressed malicious file | File size limits | LOW |
|| ATK-045 | Privilege Escalation | Student → Admin | Role validation blocks | CRITICAL |
|| ATK-046 | Horizontal Privilege Escalation | Access another user's data | Tenant isolation | CRITICAL |
|| ATK-047 | Vertical Privilege Escalation | User → Root | Permission checks | CRITICAL |
|| ATK-048 | IDOR (Insecure Direct Object Ref) | Access by changing ID | Authorization check | CRITICAL |
|| ATK-049 | Mass Assignment | Set admin=true in request | Whitelist fields only | HIGH |
|| ATK-050 | Parameter Pollution | Duplicate parameters | Last value or reject | MEDIUM |
|| ATK-051 | HTTP Verb Tampering | POST → GET | Method validated | MEDIUM |
|| ATK-052 | CORS Misconfiguration | Access from evil.com | CORS policy enforced | HIGH |
|| ATK-053 | Subdomain Takeover | Hijack unused subdomain | DNS records monitored | LOW |
|| ATK-054 | API Key Exposure | API key in client code | No sensitive keys in frontend | CRITICAL |
|| ATK-055 | Secret Leakage | Secrets in git/logs | Secrets never committed | CRITICAL |
|| ATK-056 | Metadata Exposure | .git, .env files accessible | Web server configured | HIGH |
|| ATK-057 | Information Disclosure | Error messages leak info | Generic error messages | HIGH |
|| ATK-058 | Username Enumeration | Check if user exists | Same response always | HIGH |
|| ATK-059 | Account Takeover | Combine multiple vulns | All mitigations active | CRITICAL |
|| ATK-060 | Social Engineering | Trick user into revealing creds | User awareness training | LOW |

**Sub-Total:** **60 Attack Scenario Tests**

---

#### Penetration Testing Checklists

|| Test ID | Category | Test Area | Tests | Priority |
||---------|----------|-----------|-------|----------|
|| PEN-001 | OWASP Top 10 (2021) | All 10 vulnerabilities | 50 | CRITICAL |
|| PEN-002 | Authentication | All auth flows | 40 | CRITICAL |
|| PEN-003 | Authorization | Role & permission checks | 30 | CRITICAL |
|| PEN-004 | Session Management | All session operations | 25 | HIGH |
|| PEN-005 | Input Validation | All input fields | 40 | HIGH |
|| PEN-006 | Output Encoding | All dynamic content | 30 | HIGH |
|| PEN-007 | Cryptography | Encryption, hashing, tokens | 25 | HIGH |
|| PEN-008 | Error Handling | All error scenarios | 20 | MEDIUM |
|| PEN-009 | Logging & Monitoring | Audit trails, alerts | 20 | MEDIUM |
|| PEN-010 | API Security | All API endpoints | 35 | HIGH |
|| PEN-011 | Database Security | Queries, access control | 25 | HIGH |
|| PEN-012 | File Operations | Upload, download, storage | 20 | MEDIUM |
|| PEN-013 | Third-party Integration | Google, payment gateways | 25 | HIGH |
|| PEN-014 | Mobile Security | WebView, mobile-specific | 15 | MEDIUM |
|| PEN-015 | Cloud Security | AWS/GCP configurations | 20 | MEDIUM |

**Sub-Total:** **420 Penetration Testing Tests**

---

#### Compliance & Security Standards

|| Test ID | Standard | Requirements | Tests | Priority |
||---------|----------|--------------|-------|----------|
|| COMP-001 | OWASP ASVS Level 2 | Authentication Verification | 50 | HIGH |
|| COMP-002 | GDPR | Data protection & privacy | 30 | HIGH |
|| COMP-003 | ISO 27001 | Information security | 40 | MEDIUM |
|| COMP-004 | SOC 2 Type II | Security controls | 35 | MEDIUM |
|| COMP-005 | PCI DSS (payments) | Payment security | 25 | HIGH |
|| COMP-006 | NIST Cybersecurity Framework | Core functions | 30 | MEDIUM |
|| COMP-007 | CWE Top 25 | Most dangerous weaknesses | 40 | HIGH |
|| COMP-008 | SANS Top 25 | Software errors | 35 | HIGH |
|| COMP-009 | India IT Act 2000 | Local compliance | 20 | MEDIUM |
|| COMP-010 | CERT Secure Coding | Secure development | 25 | MEDIUM |

**Sub-Total:** **330 Compliance Tests**

---

**Security Attack & Penetration Testing Total:** **60 (attacks) + 420 (pen test) + 330 (compliance) = 810 test cases**

---

## 🔐 AUTHENTICATION TESTING SUMMARY

### Comprehensive Test Breakdown

| Auth Method | Basic Tests | Edge Cases | Security | Total | Priority | % of Users |
|-------------|-------------|------------|----------|-------|----------|------------|
| 🔥 **Google OAuth** | 120 | 30 FE + 50 BE + 20 DB + 20 Net + 25 Platform | - | **265** | CRITICAL | 70% |
| 🔥 **Mobile OTP** | 70 | 35 FE + 50 BE + 20 DB + 20 SMS + 20 Platform | - | **215** | HIGH | 25% |
| 🔥 **Google Integration** | 77 | 50 Calendar + 50 Token | - | **177** | CRITICAL | - |
| **Session Management** | 100 | 70 edge cases | - | **170** | HIGH | 100% |
| **Email/Password** | 36 | - | 60 security | **96** | MEDIUM | 5% |
| **🔴 Security & Attacks** | - | 60 attacks + 420 pen test + 330 compliance | - | **810** | CRITICAL | - |
| **TOTAL** | **403** | **450** | **880** | **1,733** | - | - |

### Updated Test Categories

#### 1. Google OAuth Testing: 265 tests
- ✅ Basic frontend (13 tests)
- ✅ Basic backend (20 tests)
- ✅ Frontend security edge cases (30 tests)
- ✅ Backend security edge cases (50 tests)
- ✅ Database security (20 tests)
- ✅ Network & infrastructure (20 tests)
- ✅ Cross-platform compatibility (25 tests)
- ✅ Integration tests (10 tests)
- ✅ E2E user journeys (80+ tests)

#### 2. Mobile OTP Testing: 215 tests
- ✅ Basic frontend (12 tests)
- ✅ Basic backend (17 tests)
- ✅ Frontend security (35 tests)
- ✅ Backend security (50 tests)
- ✅ Database tests (20 tests)
- ✅ SMS provider integration (20 tests)
- ✅ Cross-platform (20 tests)
- ✅ Integration tests (58 tests)
- ✅ E2E user journeys (31+ tests)

#### 3. Google Calendar & Token: 177 tests
- ✅ Basic calendar sync (9 tests)
- ✅ Token management (6 tests)
- ✅ Calendar deep integration (50 tests)
- ✅ Token security & lifecycle (50 tests)
- ✅ Integration flows (62+ tests)

#### 4. Session Management: 170 tests
- ✅ Frontend unit tests (33 tests)
- ✅ Backend unit tests (41 tests)
- ✅ Integration tests (26 tests)
- ✅ Comprehensive edge cases (70 tests)

#### 5. Email/Password: 96 tests
- ✅ Basic tests (36 tests)
- ✅ Security tests (60 tests)

#### 6. Security & Penetration Testing: 810 tests
- ✅ Attack scenarios (60 tests)
- ✅ Penetration testing (420 tests)
- ✅ Compliance standards (330 tests)

---

### Updated Timeline for Auth Testing

| Phase | Focus Area | Tests | Hours | Team |
|-------|------------|-------|-------|------|
| **Week 1** | Google OAuth (Basic + Security) | 265 | 80h | 2 QA |
| **Week 2** | Mobile OTP (Complete) | 215 | 60h | 2 QA |
| **Week 3** | Google Calendar & Token Integration | 177 | 60h | 2 QA |
| **Week 4** | Session Management | 170 | 50h | 1 QA |
| **Week 5** | Email/Password | 96 | 30h | 1 QA |
| **Week 6-7** | Security Attack Scenarios | 60 | 60h | 1 Senior QA |
| **Week 7-9** | Penetration Testing | 420 | 120h | 1 Senior QA + 1 QA |
| **Week 9-10** | Compliance Testing | 330 | 80h | 1 Senior QA |
| **Week 11** | Integration & E2E Flows | - | 60h | 2 QA |
| **Week 12** | Bug Fixes & Regression | - | 40h | All |
| **Week 13** | Final Security Audit | - | 40h | Senior QA |
| **TOTAL** | **13 weeks** | **1,733** | **680h** | **3-4 engineers** |

### Resource Requirements

| Role | Expertise | Hours | Rate | Cost |
|------|-----------|-------|------|------|
| Senior QA Security Engineer | OWASP, penetration testing | 240h | $70/h | $16,800 |
| QA Engineer (Auth Specialist) | OAuth, JWT, sessions | 200h | $55/h | $11,000 |
| QA Engineer (Frontend) | Angular, E2E testing | 160h | $50/h | $8,000 |
| Junior QA Engineer | Test execution, documentation | 80h | $35/h | $2,800 |
| **TOTAL** | | **680h** | | **$38,600** |

---

**Total Auth Testing:** **1,733 test cases** (increased from 403)  
**Total Testing Time:** **680 hours** (increased from 140h)  
**Timeline:** **13 weeks** (increased from 4 weeks)  
**Budget:** **$38,600** (increased from initial estimate)

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

