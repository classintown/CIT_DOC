# 📱 Mobile App Sign-Up Flow Documentation

**For React Native Developers**

This document explains the complete sign-up flow for first-time users using Google and Apple authentication, including mobile verification.

---

## 📋 Table of Contents

1. [Google Sign-Up Flow](#google-sign-up-flow)
2. [Apple Sign-Up Flow](#apple-sign-up-flow)
3. [Token Information](#token-information)
4. [Error Handling](#error-handling)
5. [Quick Reference](#quick-reference)

---

## 🔵 Google Sign-Up Flow

### Overview
For first-time users signing up with Google, the flow is:
1. User authenticates with Google (gets ID token)
2. Backend creates temporary OAuth session
3. User verifies mobile number with OTP
4. Backend creates account and returns tokens

### Step-by-Step Flow

#### **Step 1: User Authenticates with Google**
**What happens:** User taps "Sign in with Google" in your React Native app.

**What you do:**
- Use Google Sign-In SDK (React Native) to get user's ID token
- You'll receive an `idToken` from Google

**What you get:**
```javascript
{
  idToken: "eyJhbGciOiJSUzI1NiIsImtpZCI6Ij...", // Google ID token
  user: {
    email: "user@example.com",
    name: "John Doe",
    photo: "https://..."
  }
}
```

---

#### **Step 2: Send Google ID Token to Backend**
**Endpoint:** `POST /auths/google/mobile`

**What you send:**
```json
{
  "idToken": "eyJhbGciOiJSUzI1NiIsImtpZCI6Ij...",
  "user_type": "instructor" // Optional: "instructor" or "student", defaults to "instructor"
}
```

**Headers:**
```
Content-Type: application/json
X-Device-Type: handheld  // Important: Tells backend this is a mobile device
```

**What you receive:**

**Case A: New User (First Time)**
```json
{
  "success": false,
  "message": "Mobile verification required",
  "data": {
    "requiresMobileVerification": true,
    "sessionId": "google_session_abc123...",
    "email": "user@example.com"
  }
}
```

**Case B: Existing User (Already Registered)**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": "60d21b4667d0d8992e610c85",
      "fullName": "John Doe",
      "email": "user@example.com",
      "user_type": "instructor",
      "user_role": "instructor"
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "sessionConfig": {
      "warning": false,
      "warningTime": 300,
      "timeout": 3600,
      "maxExtensions": 5
    }
  }
}
```

**Important:** 
- If you get `requiresMobileVerification: true`, proceed to Step 3
- If you get tokens, user is already registered - **STOP HERE**, user is logged in
- **Save the `sessionId`** - you'll need it later

---

#### **Step 3: Send Mobile OTP**
**Endpoint:** `POST /auths/otp/mobile`

**What you send:**
```json
{
  "mobile": "9876543210",  // Phone number without country code
  "countryCode": "+91",     // Country code with + sign
  "fullName": "John Doe"    // Optional: User's name
}
```

**Headers:**
```
Content-Type: application/json
X-Device-Type: handheld
```

**What you receive:**
```json
{
  "success": true,
  "message": "Mobile OTP sent successfully",
  "data": {
    "mobile": "+919876543210",
    "expiresIn": 180,  // OTP expires in 180 seconds (3 minutes)
    "sessionId": "otp_session_xyz789..."  // Optional: May be returned
  }
}
```

**Important:**
- OTP is sent via SMS/WhatsApp
- OTP expires in **3 minutes (180 seconds)**
- Store the `sessionId` if provided (though you already have one from Step 2)

---

#### **Step 4: Verify Mobile OTP**
**Endpoint:** `POST /auths/otp/mobile/verify`

**What you send:**
```json
{
  "mobile": "9876543210",        // Same as Step 3
  "otp": "123456",               // 6-digit OTP user received
  "countryCode": "+91",          // Same as Step 3
  "sessionId": "google_session_abc123..."  // Session ID from Step 2
}
```

**Headers:**
```
Content-Type: application/json
X-Device-Type: handheld
```

**What you receive:**
```json
{
  "success": true,
  "message": "Mobile OTP verified successfully.",
  "data": {
    "mobile": "+919876543210",
    "country_code": "+91",
    "mobile_local": "9876543210",
    "deviceType": "handheld",
    "message": "Mobile OTP verified successfully. You can now proceed with Google sign-up."
  }
}
```

**Important:**
- Mobile is now verified and linked to the Google OAuth session
- Proceed to Step 5 to complete sign-up

---

#### **Step 5: Complete Google Sign-Up**
**Endpoint:** `POST /auths/google/complete-signup`

**What you send:**
```json
{
  "session_id": "google_session_abc123...",  // From Step 2
  "mobile": "9876543210",                     // Verified mobile (without country code)
  "countryCode": "+91",                       // Country code
  "user_type": "instructor"                   // Optional: "instructor" or "student"
}
```

**Headers:**
```
Content-Type: application/json
X-Device-Type: handheld
```

**What you receive:**
```json
{
  "success": true,
  "message": "Account created successfully",
  "data": {
    "user": {
      "id": "60d21b4667d0d8992e610c85",
      "email": "user@example.com",
      "fullName": "John Doe",
      "mobile": "+919876543210",
      "user_type": "instructor",
      "user_role": "instructor",
      "profile_photo": "https://..."
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "sessionConfig": {
      "warning": false,
      "warningTime": 300,
      "timeout": 3600,
      "maxExtensions": 5
    },
    "onboardingInfo": {
      "completed": false,
      "completedSteps": 2,
      "totalSteps": 7,
      "nextStep": "profile_setup"
    }
  }
}
```

**Important:**
- **Save both tokens** (`accessToken` and `refreshToken`) securely
- User account is now created
- User is automatically logged in
- Use `accessToken` for all API calls (add to `Authorization: Bearer <token>` header)

---

## 🍎 Apple Sign-Up Flow

### Overview
For first-time users signing up with Apple, the flow is identical to Google:
1. User authenticates with Apple (gets ID token)
2. Backend creates temporary OAuth session
3. User verifies mobile number with OTP
4. Backend creates account and returns tokens

### Step-by-Step Flow

#### **Step 1: User Authenticates with Apple**
**What happens:** User taps "Sign in with Apple" in your React Native app.

**What you do:**
- Use Apple Sign-In SDK (React Native) to get user's ID token
- You'll receive an `idToken` from Apple
- **Note:** On first sign-in only, you may also receive `user` object with name

**What you get:**
```javascript
{
  idToken: "eyJhbGciOiJSUzI1NiIsImtpZCI6Ij...", // Apple ID token
  authorizationCode: "abc123...",  // Optional: Authorization code
  user: {  // Only on first sign-in
    name: {
      firstName: "John",
      lastName: "Doe"
    },
    email: "user@example.com"  // May be null if user chose to hide email
  }
}
```

---

#### **Step 2: Send Apple ID Token to Backend**
**Endpoint:** `POST /auths/apple/mobile`

**What you send:**
```json
{
  "idToken": "eyJhbGciOiJSUzI1NiIsImtpZCI6Ij...",
  "authorizationCode": "abc123...",  // Optional
  "user": {  // Optional: Only on first sign-in
    "name": {
      "firstName": "John",
      "lastName": "Doe"
    }
  },
  "user_type": "instructor"  // Optional: "instructor" or "student"
}
```

**Headers:**
```
Content-Type: application/json
X-Device-Type: handheld
```

**What you receive:**

**Case A: New User (First Time)**
```json
{
  "success": false,
  "message": "Mobile verification required",
  "data": {
    "requiresMobileVerification": true,
    "sessionId": "apple_session_xyz789...",
    "email": "user@example.com"  // May be private relay email
  }
}
```

**Case B: Existing User (Already Registered)**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": "60d21b4667d0d8992e610c85",
      "fullName": "John Doe",
      "email": "user@example.com",
      "user_type": "instructor"
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**Important:**
- If you get `requiresMobileVerification: true`, proceed to Step 3
- If you get tokens, user is already registered - **STOP HERE**
- **Save the `sessionId`** - you'll need it later
- Apple email may be a "private relay" email (looks like `xxxxx@privaterelay.appleid.com`)

---

#### **Step 3: Send Mobile OTP**
**Same as Google Step 3**

**Endpoint:** `POST /auths/otp/mobile`

**What you send:**
```json
{
  "mobile": "9876543210",
  "countryCode": "+91",
  "fullName": "John Doe"  // Optional
}
```

**What you receive:**
```json
{
  "success": true,
  "message": "Mobile OTP sent successfully",
  "data": {
    "mobile": "+919876543210",
    "expiresIn": 180
  }
}
```

---

#### **Step 4: Verify Mobile OTP**
**Same as Google Step 4**

**Endpoint:** `POST /auths/otp/mobile/verify`

**What you send:**
```json
{
  "mobile": "9876543210",
  "otp": "123456",
  "countryCode": "+91",
  "sessionId": "apple_session_xyz789..."  // From Step 2
}
```

**What you receive:**
```json
{
  "success": true,
  "message": "Mobile OTP verified successfully.",
  "data": {
    "mobile": "+919876543210",
    "country_code": "+91",
    "mobile_local": "9876543210"
  }
}
```

---

#### **Step 5: Complete Apple Sign-Up**
**Endpoint:** `POST /auths/apple/complete-signup`

**What you send:**
```json
{
  "session_id": "apple_session_xyz789...",  // From Step 2
  "mobile": "9876543210",
  "countryCode": "+91",
  "user_type": "instructor"  // Optional
}
```

**Headers:**
```
Content-Type: application/json
X-Device-Type: handheld
```

**What you receive:**
```json
{
  "success": true,
  "message": "Account created successfully",
  "data": {
    "user": {
      "id": "60d21b4667d0d8992e610c85",
      "email": "user@example.com",
      "fullName": "John Doe",
      "mobile": "+919876543210",
      "user_type": "instructor",
      "user_role": "instructor"
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "sessionConfig": {
      "warning": false,
      "warningTime": 300,
      "timeout": 3600,
      "maxExtensions": 5
    }
  }
}
```

**Important:**
- **Save both tokens** securely
- User account is now created
- User is automatically logged in

---

## 🔐 Token Information

### Access Token (JWT)
**What it is:** Token used to authenticate API requests

**Expiration:**
- **Web devices:** 24 hours (1 day)
- **Mobile devices:** 60 days (default) - Can be configured

**How to use:**
```
Authorization: Bearer <accessToken>
```

**What happens when it expires:**
- API returns `401 Unauthorized`
- Use refresh token to get new access token (see below)

---

### Refresh Token
**What it is:** Token used to get new access tokens without re-login

**Expiration:**
- **Web devices:** 7 days
- **Mobile devices:** 60 days (default) - Can be configured

**How to refresh access token:**
**Endpoint:** `POST /auths/refreshToken`

**What you send:**
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**What you receive:**
```json
{
  "success": true,
  "message": "Token refreshed successfully",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",  // New access token
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."  // New refresh token (may be same or rotated)
  }
}
```

**Important:**
- Call this endpoint when access token expires (401 error)
- Save the new tokens
- If refresh token expires, user must sign in again

---

### OTP Token
**What it is:** One-time password sent to mobile

**Expiration:** 3 minutes (180 seconds)

**Important:**
- OTP expires quickly for security
- User must enter OTP within 3 minutes
- If expired, send new OTP (call Step 3 again)

---

### OAuth Session
**What it is:** Temporary storage for OAuth data (Google/Apple) before account creation

**Expiration:** 30 minutes

**Important:**
- Session ID is returned in Step 2
- Must complete sign-up within 30 minutes
- If expired, user must start over (re-authenticate with Google/Apple)

---

## ⚠️ Error Handling

### Common Errors

#### **1. OAuth Session Expired**
**Error:**
```json
{
  "success": false,
  "message": "OAuth session expired. Please sign in with Google/Apple again.",
  "error": "BadRequest"
}
```

**What to do:**
- Start over from Step 1 (re-authenticate with Google/Apple)

---

#### **2. Mobile Already Registered**
**Error:**
```json
{
  "success": false,
  "message": "This mobile number is already registered.",
  "error": "BadRequest"
}
```

**What to do:**
- Show error to user
- User should sign in instead of signing up
- Or use different mobile number

---

#### **3. Invalid OTP**
**Error:**
```json
{
  "success": false,
  "message": "Invalid OTP.",
  "error": "BadRequest"
}
```

**What to do:**
- Show error to user
- Allow user to re-enter OTP
- If multiple failures, may need to send new OTP

---

#### **4. OTP Expired**
**Error:**
```json
{
  "success": false,
  "message": "OTP has expired.",
  "error": "BadRequest"
}
```

**What to do:**
- Show error to user
- Send new OTP (call Step 3 again)

---

#### **5. Invalid ID Token**
**Error:**
```json
{
  "success": false,
  "message": "Invalid Google/Apple ID token",
  "error": "Unauthorized"
}
```

**What to do:**
- Re-authenticate with Google/Apple
- Make sure ID token is fresh (not expired)

---

## 📝 Quick Reference

### Endpoints Summary

| Step | Endpoint | Method | Purpose |
|------|----------|--------|---------|
| Google Step 2 | `/auths/google/mobile` | POST | Send Google ID token |
| Apple Step 2 | `/auths/apple/mobile` | POST | Send Apple ID token |
| Step 3 | `/auths/otp/mobile` | POST | Send OTP to mobile |
| Step 4 | `/auths/otp/mobile/verify` | POST | Verify OTP |
| Google Step 5 | `/auths/google/complete-signup` | POST | Complete Google sign-up |
| Apple Step 5 | `/auths/apple/complete-signup` | POST | Complete Apple sign-up |
| Token Refresh | `/auths/refreshToken` | POST | Refresh access token |

### Required Headers

All requests should include:
```
Content-Type: application/json
X-Device-Type: handheld  // Important for mobile token expiration
```

Authenticated requests (after login):
```
Authorization: Bearer <accessToken>
```

### Token Storage

**Best Practices:**
- Store tokens securely (use secure storage like `react-native-keychain`)
- Never log tokens to console in production
- Clear tokens on logout
- Handle token expiration gracefully (auto-refresh)

### Flow Diagram

```
Google/Apple Sign-Up Flow:

1. User taps "Sign in with Google/Apple"
   ↓
2. Get ID token from Google/Apple SDK
   ↓
3. POST /auths/google/mobile or /auths/apple/mobile
   ↓
   Is new user? → Yes → Continue
   Is existing user? → No → Return tokens (DONE)
   ↓
4. POST /auths/otp/mobile (send OTP)
   ↓
5. User enters OTP
   ↓
6. POST /auths/otp/mobile/verify (verify OTP)
   ↓
7. POST /auths/google/complete-signup or /auths/apple/complete-signup
   ↓
8. Receive tokens (accessToken, refreshToken)
   ↓
9. User logged in ✅
```

---

## 🔄 Token Refresh Flow

When access token expires:

```
1. API call returns 401 Unauthorized
   ↓
2. POST /auths/refreshToken with refreshToken
   ↓
3. Receive new accessToken (and possibly new refreshToken)
   ↓
4. Retry original API call with new accessToken
   ↓
5. If refresh token also expired → User must sign in again
```

---

## 📞 Support

If you encounter issues:
1. Check error messages in response
2. Verify all required fields are sent
3. Ensure `X-Device-Type: handheld` header is included
4. Check token expiration times
5. Contact backend team with:
   - Endpoint called
   - Request body
   - Response received
   - Error message

---

## ✅ Checklist for Implementation

- [ ] Integrate Google Sign-In SDK
- [ ] Integrate Apple Sign-In SDK
- [ ] Implement Step 2 (send ID token)
- [ ] Implement Step 3 (send OTP)
- [ ] Implement Step 4 (verify OTP)
- [ ] Implement Step 5 (complete sign-up)
- [ ] Store tokens securely
- [ ] Implement token refresh flow
- [ ] Handle all error cases
- [ ] Add loading states
- [ ] Test complete flow
- [ ] Test error scenarios
- [ ] Test token expiration

---

**Last Updated:** January 2025  
**Version:** 1.0
