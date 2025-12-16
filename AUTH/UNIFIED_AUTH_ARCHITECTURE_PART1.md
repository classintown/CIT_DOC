# Unified Authentication System Architecture
## MEAN Stack Multi-Provider Authentication with Account Linking

**Date**: December 2025  
**Project**: ClassInTown  
**Scope**: Backend + MongoDB + Frontend (Angular)  
**Status**: ⚠️ DESIGN PHASE - DO NOT IMPLEMENT YET

---

## Executive Summary

This document provides a complete architecture for implementing a unified authentication system supporting three entry routes (Mobile OTP, Google OAuth, Apple Sign-In) with secure account linking capabilities. The design preserves existing functionality while enabling users to link multiple authentication providers to a single account and receive prompts for completing missing identity bindings.

### Key Objectives
1. Support 3 independent login routes: Mobile OTP, Google Sign-In, Apple Sign-In
2. Enable secure account linking between providers
3. Show contextual warnings to complete missing identity bindings
4. Prevent duplicate accounts and account takeover attacks
5. Handle edge cases: Apple private relay, duplicate emails/phones
6. Maintain backward compatibility with existing users

---

## PART A: CURRENT STATE MAP

### A.1 Existing Backend Auth Structure

#### **User Data Models**

**1. User Model** (`backend/models/user/user.model.js`)
- **Primary Collection**: Stores core user data
- **Key Fields**:
  - `mobile` (Mixed: Number/String, unique, required)
  - `country_code` (String, optional, default '+91')
  - `mobile_local` (String, optional)
  - `fullName`, `email` (if provided)
  - `user_type`, `user_role`
  - `profile_photo`, `dob`, `gender`, `address`
  - `schedules[]`, `enrolled_classes[]`
  - `calendar_settings` (Object)
  - `whatsapp_notifications_enabled`, `email_notifications_enabled`, `push_notifications_enabled`
  - Audit fields: `created_at`, `updated_at`, `deleted_by`, `updated_by`
- **Current State**: Mobile-centric design; email not required

**2. System_User Model** (`backend/models/user/system_user.model.js`)
- **Purpose**: Auth credentials and OAuth tokens
- **Key Fields**:
  - `user_id` (ref to User, required)
  - `email` (String, unique, required)
  - `password` (String, optional - null for OAuth users)
  - `google_id` (String, sparse index)
  - `facebook_id` (String, sparse index)
  - `apple_id` (String, sparse index)
  - `google_access_token`, `google_refresh_token`, `google_token_expires`, `google_token_scope`
  - `apple_refresh_token`, `apple_token_expires`, `apple_token_scope`, `apple_email`, `apple_email_verified`, `apple_is_private_relay`
  - `primary_auth_provider` (enum: 'google', 'apple', 'facebook', 'email', 'mobile')
  - `linked_providers` (Array of strings)
  - `remember_me`
- **Current State**: Supports Google and Apple OAuth fields; has `linked_providers` array but not fully utilized for multi-provider linking logic

**3. User_Temp_Otp Model** (`backend/models/user/user_temp_otp.model.js`)
- **Purpose**: OTP storage for registration and sign-in
- **Key Fields**:
  - `email`, `mobile`, `country_code`, `mobile_local`
  - `otp`, `otpExpiration` (legacy)
  - `emailOtp`, `emailOtpExpiration`
  - `mobileOtp`, `mobileOtpExpiration`
  - Additional: `password`, `instituteName`, `bio`, etc.
- **Current State**: Handles OTP for both email and mobile; expires after 24 hours

**4. User_Session Model** (`backend/models/user/user_session.model.js`)
- **Purpose**: Track active user sessions
- **Key Fields**:
  - `user_id`, `sessionId` (unique, sparse)
  - `ip_address`, `latitude`, `longitude`, `location_data`, `user_agent`
  - `last_activity`, `session_started_at`
  - Session timeout fields: `session_extensions`, `last_extended_at`, `is_warning_active`, `warning_count`
- **Current State**: Supports session timeout and extension logic

**5. Onboarding_Status Model** (`backend/models/user/onboarding_status.model.js`)
- **Purpose**: Track user onboarding progress
- **Key Fields**:
  - `user_id` (unique)
  - Verification flags: `mobile_verified`, `google_verified`, `apple_verified`
  - Completion flags: `business_profile_completed`, `banking_profile_completed`, `first_activity_created`, `first_location_added`, `first_class_scheduled`
  - `current_step` (enum)
  - `completed_steps[]` (array of step objects with metadata)
  - `onboarding_completed` (Boolean)
  - Progress: `total_steps` (8), `completed_steps_count`
- **Current State**: Already tracks Google and Apple verification; ready for multi-provider logic

**6. AppleOAuthSessionTemp Model** (`backend/models/auth/appleOAuthSessionTemp.model.js`)
- **Purpose**: Temporary storage for Apple OAuth when mobile not verified
- **Key Fields**:
  - `session_id`, `email`, `apple_id`, `full_name`
  - `email_verified`, `is_private_relay`
  - `apple_tokens` (id_token, refresh_token, access_token)
  - `status` ('pending', 'completed', 'expired')
  - `expires_at` (30 minutes TTL)
- **Current State**: Used in Apple-first flow; similar pattern needed for Google

#### **Auth Routes & Controllers**

**Auth Routes** (`backend/routes/auth.routes.js`)

**Existing OTP Routes:**
- `POST /auths/sendSignInOtp` - Send OTP to mobile for sign-in
- `POST /auths/verifySignInOtp` - Verify OTP and log in user
- `POST /auths/otp/mobile` - Create mobile OTP (registration)
- `POST /auths/otp/mobile/verify` - Verify mobile OTP (registration)
- `POST /auths/otp/email` - Create email OTP
- `POST /auths/otp/email/verify` - Verify email OTP

**Existing Google OAuth Routes:**
- `GET /auths/google` - Initiate Google OAuth (web)
- `GET /auths/google/callback` - Handle Google OAuth callback
- `POST /auths/google/mobile` - Google sign-in for mobile apps (ID token)
- `POST /auths/google/complete-signup` - Complete signup after mobile verification
- `GET /auths/link-google-oauth` - Initiate Google linking (requires JWT)
- `GET /auths/link-google-callback` - Handle Google linking callback
- `GET /auths/google-connection-status` - Check if Google linked
- `POST /auths/disconnect-google` - Disconnect Google account

**Existing Apple Sign-In Routes:**
- `GET /auths/apple` - Initiate Apple OAuth (web)
- `GET|POST /auths/apple/callback` - Handle Apple OAuth callback (form_post)
- `POST /auths/apple/mobile` - Apple sign-in for mobile apps (ID token)
- `POST /auths/apple/complete-signup` - Complete signup after mobile verification

**Standard Routes:**
- `POST /auths/signUp` - Email/password registration
- `POST /auths/signIn` - Email/password sign-in
- `POST /auths/signOut` - Sign out
- `POST /auths/refreshToken` - Refresh access token
- `PATCH /auths/profile` - Update profile
- `PATCH /auths/changePassword` - Change password
- `POST /auths/forgetPassword` - Request password reset
- `PATCH /auths/resetPassword` - Reset password with OTP

**Controllers** (`backend/controllers/auth/auth.controller.js`, `googleLinking.controller.js`)

**Key Functions:**
- `sendSignInOtp()` - Generates and sends OTP to mobile
- `verifySignInOtp()` - Validates OTP, creates session, returns tokens
- `mobileGoogleSignIn()` - Handles Google sign-in from mobile (ID token verification)
- `googleAuthCallback()` - Web Google OAuth callback; checks scopes, creates/links account
- `mobileAppleSignIn()` - Handles Apple sign-in from mobile (ID token verification)
- `appleAuthCallback()` - Web Apple OAuth callback; handles private relay
- `completeGoogleSignup()` - Finishes Google signup after mobile OTP verification
- `completeAppleSignup()` - Finishes Apple signup after mobile OTP verification
- Google Linking Controller:
  - `initiateGoogleLinking()` - Generates OAuth URL with state containing user info
  - `linkGoogleCallback()` - Links Google account to existing user
  - `disconnectGoogleAccount()` - Removes Google link
  - `checkGoogleConnectionStatus()` - Returns connection status

**Current Flow Logic:**

**Mobile OTP Sign-In:**
1. User enters mobile number → `sendSignInOtp()`
2. Backend checks if user exists with that mobile in `User` collection
3. If exists: Generate OTP → Save to `User_Temp_Otp` → Send SMS
4. User enters OTP → `verifySignInOtp()`
5. Backend validates OTP → Looks up `System_User` by mobile or `user_id`
6. If found: Generate JWT tokens → Create `User_Session` → Return tokens + user data
7. Frontend stores tokens, redirects to dashboard

**Google Sign-In (Web):**
1. User clicks "Sign in with Google" → `GET /auths/google`
2. Redirects to Google consent screen
3. Google redirects back to `/auths/google/callback` with authorization code
4. Backend:
   - Exchanges code for tokens
   - Verifies scopes (requires `gmail.send`, `gmail.readonly`, `calendar`)
   - Gets user info (email, name, Google ID)
   - Checks if `System_User` exists by email
   - **If exists**: Updates tokens → Login → Redirect
   - **If not exists AND no mobile**: Stores session in temp storage → Redirects to mobile verification screen
   - **If not exists AND mobile provided**: Creates `User` + `System_User` → Login
5. Frontend handles redirect, stores tokens

**Apple Sign-In (Web):**
1. User clicks "Sign in with Apple" → `GET /auths/apple`
2. Redirects to Apple consent screen
3. Apple redirects back to `/auths/apple/callback` (form_post or GET)
4. Backend:
   - Exchanges code for tokens
   - Verifies ID token
   - Extracts email, Apple ID, name (name only on first sign-in)
   - Handles private relay emails
   - Checks if `System_User` exists by Apple ID or email
   - **If exists**: Updates tokens → Login → Redirect
   - **If not exists AND no mobile**: Creates `AppleOAuthSessionTemp` → Redirects to mobile verification
   - **If not exists AND mobile provided**: Creates `User` + `System_User` → Login
5. Frontend handles redirect, stores tokens

**Google Account Linking (existing):**
1. Logged-in user (e.g., mobile OTP user) goes to profile
2. Clicks "Connect Google"
3. Frontend calls `GET /auths/link-google-oauth` (with JWT)
4. Backend generates OAuth URL with state containing `userId`, `email`, `returnUrl`
5. User completes Google OAuth
6. Google redirects to `/auths/link-google-callback`
7. Backend:
   - Validates state
   - Exchanges code for tokens
   - Stores tokens in `System_User` (updates `google_id`, `google_access_token`, etc.)
   - Updates `linked_providers` array
8. Redirects to frontend success page

**Issues with Current Implementation:**
- ❌ No Apple account linking route (only Google linking exists)
- ❌ No mobile linking for Google/Apple users
- ❌ Duplicate account prevention is incomplete (checks email but not cross-provider)
- ❌ No conflict resolution when phone/email matches different providers
- ❌ Onboarding prompts exist but not enforced/displayed prominently
- ❌ `linked_providers` array not consistently updated across all flows
- ⚠️ Apple private relay emails may cause issues with email-based matching

### A.2 Existing Frontend Auth Structure

#### **Auth Services**

**AuthService** (`frontend/src/app/services/common/auth/auth.service.ts`)
- **Purpose**: Core authentication logic
- **Key Methods**:
  - `login(email, password, rememberMe)` - Email/password login
  - `setToken()`, `getToken()`, `setRefreshToken()`, `getRefreshToken()`
  - `isLoggedIn()` - Checks if user has valid token
  - `logout()` - Clears tokens and redirects
  - `handleLoginRedirect()` - Redirects based on user role
  - `initializeSessionTimeoutAfterLogin()` - Starts session timeout monitoring
- **Storage**: Uses `localStorage` for tokens and user data
- **Current State**: Handles token management; no multi-provider awareness

**SessionService** (`frontend/src/app/services/session/session.service.ts`)
- **Purpose**: Session health monitoring
- **Key Methods**:
  - `syncSession(forceGoogleRefresh)` - Sync session with backend
  - `renewSession()` - Refresh tokens using refresh token
  - `checkSessionHealth()` - Check if session is healthy
  - `getActiveSessions()` - Get all active sessions
- **Current State**: Handles session renewal and monitoring

**UserService** (inferred from AuthService usage)
- **Purpose**: Manage user profile data
- **Key Methods**:
  - `updateUser(userData)` - Updates stored user profile
  - Likely stores user in localStorage or BehaviorSubject

#### **Login Components**

**Common Pattern** (Student, Instructor, Institute, Admin, Parent):
- All use `<app-login-form>` shared component
- Support inputs:
  - Email/password sign-in
  - Mobile OTP sign-in
  - Google Sign-In button
  - Apple Sign-In button
  - Facebook Sign-In button (less relevant)
  - "Forgot Password" link
  - "Register" link
- Component structure (e.g., `student-log-in.component.ts`):
  - `loginForm: FormGroup` - Email/password form
  - `otpForm: FormGroup` - OTP verification form
  - `isOtpSent: boolean` - Toggle between forms
  - Methods:
    - `onEmailSignIn()` - Email/password sign-in
    - `onMobileSignIn()` - Request OTP
    - `onOtpVerify()` - Verify OTP and log in
    - `signInWithGoogle()` - Initiate Google OAuth
    - `signInWithApple()` - Initiate Apple OAuth
    - `onFacebookSignIn()` - Facebook OAuth (less used)
- **Current State**: All flows work independently; no account linking UI

**Dashboard/Profile Components** (inferred):
- Likely show user info from `UserService`
- Currently may show "Connect Google" button (based on existing linking controller)
- **Missing**: Unified banner/alert for missing verifications
- **Missing**: Apple linking UI
- **Missing**: Mobile linking UI for Google/Apple users

#### **Storage & Guards**

**LocalStorage Keys:**
- `accessToken` / `authToken` - JWT access token
- `refreshToken` - JWT refresh token
- `user` - User profile object (likely stringified JSON)
- `sessionConfig` - Session timeout configuration

**Route Guards** (inferred):
- Likely have `AuthGuard` that checks `isLoggedIn()`
- May have role-based guards for instructor/admin/student routes
- **Current State**: Guards don't check for required verifications (e.g., phone verified)

### A.3 Current Behavior Summary

**What Works:**
✅ Mobile OTP sign-in for existing users  
✅ Google OAuth sign-in (web and mobile)  
✅ Apple Sign-In (web and mobile)  
✅ Google account linking for existing mobile users  
✅ Session management and token refresh  
✅ Onboarding status tracking (DB level)  
✅ OTP generation and SMS sending  
✅ Device detection and device-specific token expiration  
✅ Apple private relay email handling  
✅ Temporary session storage for incomplete OAuth flows  

**What's Missing:**
❌ Apple account linking route (no `/auths/link-apple-oauth`)  
❌ Mobile verification linking for Google/Apple users  
❌ Unified account linking UI with prominent banners  
❌ Conflict resolution when email/phone matches multiple providers  
❌ Auto-linking logic when safe (same email + same phone)  
❌ Security controls to prevent account takeover during linking  
❌ Frontend state machine for onboarding prompts  
❌ Consistent update of `linked_providers` array in all flows  
❌ Verification gates for sensitive actions (payments, class creation)  

---

## PART A.4: GAPS & RISKS

### Critical Gaps

**1. Incomplete Account Linking**
- **Gap**: Only Google linking exists; Apple and Mobile linking missing
- **Risk**: Users can't complete their identity profiles fully
- **Impact**: HIGH - Core feature incomplete

**2. Duplicate Account Creation**
- **Gap**: A user with phone +919876543210 signs in via OTP → Creates Account A. Later signs in via Google with same email → May create Account B if email differs or vice versa
- **Risk**: Multiple accounts for same person
- **Impact**: HIGH - Data fragmentation, poor UX

**3. Account Takeover Vulnerability**
- **Gap**: If a user signs in via mobile OTP, then clicks "Link Google," there's no re-verification before linking
- **Risk**: Attacker with access to logged-in session can link their own Google account
- **Impact**: CRITICAL - Security issue
- **Mitigation Needed**: Require recent OTP verification or additional confirmation before linking

**4. Email/Phone Conflict Resolution**
- **Gap**: No clear rules for:
  - User A has mobile +919876543210 and email user@example.com via OTP
  - User B tries to sign in via Google with user@example.com but different/no mobile
  - Should they merge? Create separate accounts?
- **Risk**: Inconsistent behavior, potential account takeover
- **Impact**: HIGH - Data integrity and security

**5. Apple Private Relay Edge Cases**
- **Gap**: Apple private relay emails (e.g., `abc123@privaterelay.appleid.com`) can't be matched to real emails
- **Risk**: Can't auto-merge accounts even if same person
- **Impact**: MEDIUM - UX inconvenience, duplicate accounts

**6. Frontend Onboarding Prompts Not Enforced**
- **Gap**: Onboarding status tracked in DB, but frontend doesn't show persistent banners
- **Risk**: Users forget to complete verifications
- **Impact**: MEDIUM - Low completion rates

**7. No Verification Gates**
- **Gap**: No enforcement of "phone verified" for sensitive actions (e.g., creating classes, making payments)
- **Risk**: Unverified users can perform sensitive actions
- **Impact**: MEDIUM - Potential abuse or data quality issues

### Backward Compatibility Risks

**1. Existing Users Without Email**
- **Issue**: Some users registered via mobile OTP may have no email in `User` model
- **Risk**: Linking Google/Apple (which require email) may fail
- **Mitigation**: Allow adding email during linking flow

**2. Existing Users Without Google/Apple IDs**
- **Issue**: Old users have `System_User` with `google_id` or `apple_id` = null
- **Risk**: Sparse index allows nulls; should be fine
- **Mitigation**: Ensure linking updates these fields correctly

**3. Mobile Number Format Changes**
- **Issue**: Old users may have mobile as Number (e.g., 9876543210), new users have E.164 string ("+919876543210")
- **Risk**: Search queries may fail
- **Mitigation**: Already handled with multiple search variants in existing code; ensure consistency

**4. Token Expiration**
- **Issue**: Google tokens expire; refresh tokens may become invalid
- **Risk**: Linked Google accounts may stop working
- **Mitigation**: Implement token refresh logic (already exists in `googleTokenRefreshService.js`)

### Security Risks

**1. State Parameter Hijacking**
- **Risk**: OAuth state parameter contains user info; if predictable or leaked, attacker could hijack linking flow
- **Mitigation**: Use crypto-strong random state, include CSRF token, validate strictly

**2. Linking Without Re-Authentication**
- **Risk**: User logs in via mobile OTP, leaves session open → Attacker links their own Google
- **Mitigation**: Require recent authentication (OTP sent < 5 minutes ago) OR separate confirmation step

**3. Email Enumeration**
- **Risk**: Attacker can check if email exists by attempting sign-in
- **Mitigation**: Already mitigated with generic error messages; maintain this

**4. SMS OTP Interception**
- **Risk**: OTPs sent via SMS can be intercepted
- **Mitigation**: Use short expiration (5-10 minutes), rate limiting (already in place)

### Data Integrity Risks

**1. Orphaned Onboarding Records**
- **Risk**: If user creation fails but onboarding status created, orphan record exists
- **Mitigation**: Use transactions or cleanup job

**2. Stale OAuth Tokens**
- **Risk**: Refresh tokens expire (Google: indefinite if used, Apple: 6 months), user can't send emails or access calendar
- **Mitigation**: Periodic token validation, re-prompt user to re-link if expired

**3. `linked_providers` Array Inconsistency**
- **Risk**: Code updates `google_id` but forgets to update `linked_providers` array
- **Mitigation**: Centralize linking logic in reusable functions with validation

---




