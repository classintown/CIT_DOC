# 🍎 Apple Mobile Sign-In Flow - React Native Integration Guide

## Overview
This document explains how Apple Sign-In works for mobile apps (React Native). The flow supports both **existing users** (direct sign-in) and **new users** (sign-up with mobile verification).

---

## 🔄 Complete Flow Diagram

### For Existing Users:
```
1. User clicks "Sign in with Apple" in React Native app
2. React Native gets idToken from Apple Sign-In SDK
3. React Native calls: POST /auths/apple/mobile
4. Backend finds existing user → Returns tokens + user data
5. React Native stores tokens and navigates to dashboard
```

### For New Users:
```
1. User clicks "Sign in with Apple" in React Native app
2. React Native gets idToken (and optionally authorizationCode) from Apple SDK
3. React Native calls: POST /auths/apple/mobile
4. Backend detects new user → Creates OAuth session → Returns session_id
5. React Native shows mobile verification screen
6. User enters mobile number → React Native calls: POST /auths/otp/mobile
7. User enters OTP → React Native calls: POST /auths/otp/mobile/verify
8. React Native calls: POST /auths/apple/complete-signup
9. Backend creates account → Returns tokens + user data
10. React Native stores tokens and navigates to dashboard
```

---

## 📡 API Endpoints

### 1. Mobile Apple Sign-In
**Endpoint:** `POST /auths/apple/mobile`

**Request Body:**
```json
{
  "idToken": "string (required) - Apple ID token from SDK",
  "authorizationCode": "string (optional) - Apple authorization code for full token access",
  "user": {
    "name": {
      "firstName": "string (optional) - Only on first sign-in",
      "lastName": "string (optional) - Only on first sign-in"
    }
  },
  "user_type": "string (optional) - 'instructor' or 'student', defaults to 'instructor'"
}
```

**Important Notes:**
- `idToken` is **required** - Always provided by Apple SDK
- `authorizationCode` is **optional** - If provided, backend will exchange it for full tokens
- `user.name` is **only available on first sign-in** - Apple doesn't send name after first time
- If `authorizationCode` is provided, backend stores full Apple tokens (better for future use)

**Response - Existing User (Success):**
```json
{
  "status": "success",
  "user": {
    "id": "user_id",
    "fullName": "User Name",
    "email": "user@example.com",
    "user_role": "SuperAdmin",
    "user_type": "instructor",
    "is_business_data_added": true/false,
    "profile_photo": "url or empty string"
  },
  "accessToken": "jwt_access_token",
  "refreshToken": "jwt_refresh_token"
}
```

**Response - New User (Mobile Verification Required):**
```json
{
  "status": "success",
  "statusCode": 200,
  "action": "mobile_verification_required",
  "message": "Mobile verification required to complete sign-up",
  "session_id": "oauth_session_id",
  "email": "user@example.com",
  "provider": "apple",
  "user_type": "instructor",
  "details": {
    "nextStep": "Please verify your mobile number to complete sign-up",
    "endpoint": "/auths/apple/complete-signup",
    "hasTokens": true/false,
    "note": "Apple tokens included in session" or "Only idToken included. Authorization code can be provided for full token access."
  }
}
```

**Response - Error:**
```json
{
  "status": "error",
  "statusCode": 400/401/500,
  "errorType": "BadRequest/Unauthorized/InternalServerError",
  "message": "Error message",
  "isOperational": true/false
}
```

---

### 2. Send OTP to Mobile
**Endpoint:** `POST /auths/otp/mobile`

**Request Body:**
```json
{
  "mobile": "string (required) - Mobile number",
  "countryCode": "string (optional) - Defaults to '+91'"
}
```

**Response:**
```json
{
  "status": "success",
  "message": "OTP sent successfully"
}
```

---

### 3. Verify OTP
**Endpoint:** `POST /auths/otp/mobile/verify`

**Request Body:**
```json
{
  "mobile": "string (required) - Mobile number",
  "otp": "string (required) - OTP code",
  "countryCode": "string (optional) - Defaults to '+91'"
}
```

**Response:**
```json
{
  "status": "success",
  "message": "OTP verified successfully"
}
```

**Note:** This creates a `VerifiedMobileTemp` record that will be used in the complete signup step.

---

### 4. Complete Apple Sign-Up
**Endpoint:** `POST /auths/apple/complete-signup`

**Request Body:**
```json
{
  "session_id": "string (required) - From mobile sign-in response",
  "mobile": "string (required) - Verified mobile number",
  "countryCode": "string (optional) - Defaults to '+91'",
  "user_type": "string (optional) - 'instructor' or 'student', overrides session value"
}
```

**Response - Success:**
```json
{
  "status": "success",
  "user": {
    "id": "user_id",
    "fullName": "User Name",
    "email": "user@example.com",
    "mobile": "mobile_number",
    "user_type": "instructor",
    "user_role": "SuperAdmin",
    "is_business_data_added": false,
    "profile_photo": "url or empty string"
  },
  "accessToken": "jwt_access_token",
  "refreshToken": "jwt_refresh_token",
  "sessionConfig": {
    // Session configuration object
  },
  "routingInfo": {
    "userType": "instructor",
    "requiresOnboarding": true/false,
    "onboardingStatus": {
      "completed": false,
      "completedSteps": 0,
      "totalSteps": 7,
      "nextStep": "step_name"
    }
  }
}
```

**Response - Error:**
```json
{
  "status": "error",
  "statusCode": 400/404/500,
  "errorType": "BadRequest/NotFound/InternalServerError",
  "message": "Error message",
  "isOperational": true/false
}
```

---

## 🎯 React Native Implementation Steps

### Step 1: Handle Sign-In Response
After calling `/auths/apple/mobile`:

- **If `action === "mobile_verification_required"`:**
  - Extract `session_id` from response
  - Store `session_id`, `email`, `user_type` for later use
  - Check `details.hasTokens` to know if full tokens are available
  - Navigate to mobile verification screen

- **If `accessToken` exists:**
  - Store `accessToken` and `refreshToken`
  - Store `user` object
  - Navigate to dashboard using `routingInfo` if available

- **If `status === "error"`:**
  - Display error message to user
  - Allow user to retry

---

### Step 2: Mobile Verification Flow

1. **Show mobile number input screen**
   - User enters mobile number
   - User selects country code (optional, defaults to +91)

2. **Send OTP:**
   - Call `POST /auths/otp/mobile`
   - Send `mobile` and `countryCode` in request body
   - Show success message

3. **Show OTP verification screen:**
   - User enters OTP code received via SMS

4. **Verify OTP:**
   - Call `POST /auths/otp/mobile/verify`
   - Send `mobile`, `otp`, and `countryCode` in request body
   - On success, proceed to complete signup

---

### Step 3: Complete Sign-Up

After OTP verification succeeds:

1. **Call complete signup endpoint:**
   - Endpoint: `POST /auths/apple/complete-signup`
   - Request body:
     - `session_id`: From Step 1
     - `mobile`: Verified mobile number
     - `countryCode`: User's country code
     - `user_type`: Optional, can override session value

2. **Handle response:**
   - Store `accessToken` and `refreshToken`
   - Store `user` object
   - Use `routingInfo` to determine where to navigate
   - Navigate to appropriate dashboard

---

## ⚠️ Important Notes

1. **Session Expiration:**
   - OAuth sessions expire in **30 minutes**
   - User must complete mobile verification within this time
   - If expired, user needs to start over (call `/auths/apple/mobile` again)

2. **Apple-Specific Considerations:**
   - **Name Field:** Apple only sends user name on **first sign-in**. After that, name is not included in idToken. Always send `user.name` object if available from Apple SDK.
   - **Email Privacy:** Apple users can choose "Hide My Email" which provides a relay email. Backend handles this automatically.
   - **Authorization Code:** If you can get `authorizationCode` from Apple SDK, include it in the request. This allows backend to store full Apple tokens for better future integration.

3. **User Type:**
   - Can be specified in initial sign-in request (`/auths/apple/mobile`)
   - Can be overridden in complete signup request
   - Defaults to `'instructor'` if not specified

4. **Mobile Number Format:**
   - Backend handles various formats (E.164, local, with/without country code)
   - Recommended: Send in E.164 format (e.g., `+919876543210`)
   - Country code defaults to `+91` if not provided

5. **Error Handling:**
   - Always check `status` field in response
   - Handle `isOperational` errors differently (user-friendly messages)
   - Log non-operational errors for debugging

6. **Token Storage:**
   - If `authorizationCode` was provided, backend stores full Apple tokens
   - If not provided, only idToken is stored (still sufficient for sign-up)
   - Full tokens enable better integration with Apple services later

---

## 🔐 Security Notes

- `idToken` must be valid and not expired
- `session_id` is temporary and expires in 30 minutes
- Mobile verification OTP expires (check backend for exact duration)
- All tokens should be stored securely (use secure storage in React Native)
- Apple relay emails are handled automatically by backend

---

## 📝 Example Flow Summary

**New User Journey:**
1. User taps "Sign in with Apple" → Gets idToken (and optionally authorizationCode)
2. App calls `/auths/apple/mobile` with idToken, authorizationCode (if available), and user.name (if first sign-in) → Receives `session_id`
3. App shows mobile input → User enters mobile
4. App calls `/auths/otp/mobile` → OTP sent
5. App shows OTP input → User enters OTP
6. App calls `/auths/otp/mobile/verify` → OTP verified
7. App calls `/auths/apple/complete-signup` → Account created
8. App receives tokens → User logged in

**Existing User Journey:**
1. User taps "Sign in with Apple" → Gets idToken
2. App calls `/auths/apple/mobile` → Receives tokens directly
3. App stores tokens → User logged in

---

## 🍎 Apple-Specific Best Practices

1. **Always Request Name on First Sign-In:**
   - Configure Apple Sign-In to request name scope
   - Send `user.name` object in the request if available
   - Backend will use this for the user's fullName

2. **Request Authorization Code When Possible:**
   - If your Apple Sign-In configuration allows, request authorization code
   - Include `authorizationCode` in the request for better token storage
   - This enables full Apple service integration later

3. **Handle Email Privacy:**
   - Backend automatically handles Apple relay emails
   - No special handling needed in React Native
   - User's real email is used if available, relay email otherwise

4. **Error Messages:**
   - Apple-specific errors (token expired, invalid token) are handled by backend
   - Backend returns user-friendly error messages
   - React Native should display these messages to users
