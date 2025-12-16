# PART B.2: BACKEND API CONTRACT

## B.2.1 New/Modified Endpoints

### Mobile OTP Routes (Existing - Keep)

**POST /auths/sendSignInOtp**
- **Purpose**: Send OTP to mobile for sign-in
- **Current Status**: ✅ Exists, works well
- **Changes**: None required
- **Request**:
```json
{
  "mobile": "+919876543210",
  "countryCode": "+91" // optional
}
```
- **Response**:
```json
{
  "success": true,
  "message": "OTP sent successfully",
  "data": {
    "mobile": "+919876543210",
    "expiresIn": 300 // seconds
  }
}
```

**POST /auths/verifySignInOtp**
- **Purpose**: Verify OTP and login
- **Current Status**: ✅ Exists
- **Changes Needed**: Add `onboardingStatus` to response
- **Request**:
```json
{
  "mobile": "+919876543210",
  "otp": "123456",
  "countryCode": "+91" // optional
}
```
- **Response** (Enhanced):
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "_id": "...",
      "fullName": "John Doe",
      "mobile": "+919876543210",
      "email": "john@example.com", // may be null
      "user_role": "Instructor",
      "user_type": "ClassInTown",
      "is_business_data_added": "No"
    },
    "accessToken": "eyJhbG...",
    "refreshToken": "eyJhbG...",
    "sessionConfig": { ... },
    // NEW: Onboarding status
    "onboardingStatus": {
      "mobile_verified": true,
      "google_verified": false,
      "apple_verified": false,
      "onboarding_completed": false,
      "current_step": "google_verification",
      "nextActions": [
        {
          "action": "link_google",
          "priority": "recommended",
          "prompt": "Connect your Google account to enable calendar integration"
        },
        {
          "action": "link_apple",
          "priority": "optional",
          "prompt": "Connect your Apple account for seamless sign-in"
        }
      ]
    },
    // NEW: Provider status
    "providerStatus": {
      "hasGoogle": false,
      "hasApple": false,
      "hasMobile": true,
      "primaryProvider": "mobile",
      "linkedProviders": ["mobile"]
    }
  }
}
```

---

### Google OAuth Routes

**GET /auths/google** (Existing - Keep)
- No changes needed

**GET /auths/google/callback** (Existing - Enhance)
- **Current Status**: ✅ Exists
- **Changes Needed**: Add conflict detection logic
- **Conflict Scenarios**:
  1. Google email matches existing mobile user → Check if safe to auto-link or require confirmation
  2. Google email matches existing Google user → Login
  3. Google email matches existing Apple user → Require mobile verification to merge
  4. New Google user, no mobile → Store in temp session, redirect to mobile verification

**POST /auths/google/mobile** (Existing - Keep)
- Mobile app Google sign-in
- No major changes needed

**POST /auths/google/complete-signup** (Existing - Enhance)
- **Purpose**: Complete Google signup after mobile verification
- **Current Status**: ✅ Exists
- **Changes Needed**: Add conflict resolution logic
- **Request**:
```json
{
  "session_id": "google_abc123...",
  "mobile": "+919876543210",
  "countryCode": "+91"
}
```
- **Enhanced Logic**:
  1. Validate session (not expired)
  2. **Check if mobile already exists** → If yes, this is a linking operation, not new signup
  3. If mobile exists with different email → Conflict → Return error with merge option
  4. If safe → Create user OR link to existing user
- **Response**:
```json
{
  "success": true,
  "message": "Account created successfully",
  "data": {
    "user": { ... },
    "accessToken": "...",
    "refreshToken": "...",
    "wasLinked": false, // or true if linked to existing account
    "linkedProviders": ["google", "mobile"]
  }
}
```

**GET /auths/link-google-oauth** (Existing - Keep)
- **Purpose**: Initiate Google linking for logged-in user
- **Current Status**: ✅ Exists, works well
- **No changes needed**

**GET /auths/link-google-callback** (Existing - Enhance)
- **Purpose**: Complete Google linking
- **Current Status**: ✅ Exists
- **Changes Needed**: Add security validation
- **Enhanced Logic**:
  1. Validate state (includes userId, CSRF token)
  2. **Check if Google ID already linked to another user** → Error
  3. **Check if email matches user's current email** → Safe to link
  4. **Check if email differs** → Warning, require confirmation
  5. Store tokens, update `linked_providers`, create `provider_link_history` entry
  6. Update `Onboarding_Status.google_verified = true`
- **Redirect**: `/auth/google-linked-success?provider=google`

**POST /auths/disconnect-google** (Existing - Keep)
- **Purpose**: Unlink Google account
- **Current Status**: ✅ Exists
- **Changes Needed**: Ensure it updates `linked_providers` array
- **Logic**:
  1. Remove `google_id`, `google_access_token`, `google_refresh_token`
  2. Remove 'google' from `linked_providers`
  3. Set `Onboarding_Status.google_verified = false`
  4. **Important**: Don't allow unlinking if Google is the only auth method (user would be locked out)

---

### Apple Sign-In Routes

**GET /auths/apple** (Existing - Keep)
- No changes needed

**POST /auths/apple/callback** (Existing - Enhance)
- **Purpose**: Handle Apple OAuth callback
- **Current Status**: ✅ Exists
- **Changes Needed**: Add conflict detection (same as Google)
- **Conflict Scenarios**:
  1. Apple ID matches existing user → Login
  2. Apple email (if not private relay) matches existing user → Check if safe to auto-link
  3. Apple email is private relay → Can't match by email, must match by Apple ID only
  4. New Apple user, no mobile → Store in temp session, redirect to mobile verification

**POST /auths/apple/mobile** (Existing - Keep)
- Mobile app Apple sign-in
- No major changes needed

**POST /auths/apple/complete-signup** (Existing - Enhance)
- **Purpose**: Complete Apple signup after mobile verification
- **Current Status**: ✅ Exists
- **Changes Needed**: Add conflict resolution (same as Google)

**GET /auths/link-apple-oauth** (NEW)
- **Purpose**: Initiate Apple linking for logged-in user
- **Auth**: Requires JWT
- **Request**: Query param `returnUrl` (optional)
- **Logic**:
  1. Validate JWT → Get userId
  2. Generate Apple OAuth URL with state = { userId, returnUrl, csrf, timestamp }
  3. Set linking session in DB (for security)
- **Response**:
```json
{
  "success": true,
  "data": {
    "authUrl": "https://appleid.apple.com/auth/authorize?..."
  }
}
```

**POST /auths/link-apple-callback** (NEW)
- **Purpose**: Complete Apple linking (mirrors Google linking)
- **Request**: `code` (authorization code), `state` (JSON)
- **Logic**:
  1. Exchange code for tokens
  2. Verify ID token
  3. Extract Apple ID, email (if not private relay)
  4. Validate state → Get userId
  5. **Check if Apple ID already linked to another user** → Error
  6. Store tokens, update `System_User`
  7. Update `linked_providers`, `Onboarding_Status.apple_verified = true`
- **Redirect**: `/auth/apple-linked-success?provider=apple`

**POST /auths/disconnect-apple** (NEW)
- **Purpose**: Unlink Apple account
- **Auth**: Requires JWT
- **Logic**:
  1. Remove `apple_id`, `apple_refresh_token`, `apple_email`, etc.
  2. Remove 'apple' from `linked_providers`
  3. Set `Onboarding_Status.apple_verified = false`
  4. **Important**: Don't allow unlinking if Apple is the only auth method
- **Response**:
```json
{
  "success": true,
  "message": "Apple account disconnected"
}
```

---

### Mobile Linking Routes (NEW)

**POST /auths/link/mobile/start**
- **Purpose**: Send OTP to link mobile number to existing Google/Apple user
- **Auth**: Requires JWT
- **Request**:
```json
{
  "mobile": "+919876543210",
  "countryCode": "+91"
}
```
- **Logic**:
  1. Validate JWT → Get userId
  2. Check if user already has mobile → Error if already linked
  3. **Check if mobile already exists in another account** → Conflict (see resolution matrix)
  4. Generate OTP
  5. Save OTP to `User_Temp_Otp` with userId reference
  6. Send SMS
- **Response**:
```json
{
  "success": true,
  "message": "OTP sent to +919876543210",
  "data": {
    "mobile": "+919876543210",
    "expiresIn": 300
  }
}
```

**POST /auths/link/mobile/verify**
- **Purpose**: Verify OTP and link mobile to account
- **Auth**: Requires JWT
- **Request**:
```json
{
  "mobile": "+919876543210",
  "otp": "123456",
  "countryCode": "+91"
}
```
- **Logic**:
  1. Validate JWT → Get userId
  2. Validate OTP from `User_Temp_Otp`
  3. **Check mobile conflict again** (defensive programming)
  4. Update `User` model with mobile
  5. Update `System_User.mobile_verified = true`
  6. Add 'mobile' to `linked_providers`
  7. Update `Onboarding_Status.mobile_verified = true`
  8. Create `provider_link_history` entry
- **Response**:
```json
{
  "success": true,
  "message": "Mobile number linked successfully",
  "data": {
    "mobile": "+919876543210",
    "linkedProviders": ["google", "mobile"]
  }
}
```

**POST /auths/unlink/mobile** (NEW - Optional)
- **Purpose**: Remove mobile from account (rare use case)
- **Auth**: Requires JWT + recent verification
- **Logic**:
  1. Validate JWT
  2. **Important**: Don't allow if mobile is only auth method
  3. Remove mobile from `User` model (set to null or default)
  4. Update `System_User.mobile_verified = false`
  5. Remove 'mobile' from `linked_providers`

---

### Account Status Routes (NEW)

**GET /auths/account-status**
- **Purpose**: Get complete account linking status
- **Auth**: Requires JWT
- **Response**:
```json
{
  "success": true,
  "data": {
    "userId": "...",
    "email": "john@example.com",
    "mobile": "+919876543210",
    "primaryAuthProvider": "google",
    "linkedProviders": ["google", "mobile"],
    "verifications": {
      "mobile": {
        "verified": true,
        "verified_at": "2024-01-15T10:30:00Z",
        "required": true
      },
      "google": {
        "verified": true,
        "verified_at": "2024-01-10T08:00:00Z",
        "required": false,
        "email": "john@gmail.com",
        "scopes": ["email", "profile", "gmail.send"]
      },
      "apple": {
        "verified": false,
        "required": false
      }
    },
    "onboardingStatus": {
      "completed": false,
      "current_step": "business_profile",
      "completed_steps_count": 3,
      "total_steps": 8
    },
    "nextActions": [
      {
        "action": "link_apple",
        "priority": "optional",
        "prompt": "Connect your Apple account",
        "dismissible": true,
        "dismissed_count": 0
      },
      {
        "action": "complete_business_profile",
        "priority": "required",
        "prompt": "Complete your business profile",
        "dismissible": false
      }
    ],
    "warnings": [] // e.g., "Google token expired, please re-link"
  }
}
```

**POST /auths/dismiss-prompt**
- **Purpose**: Dismiss onboarding prompt (e.g., "Link Google" banner)
- **Auth**: Requires JWT
- **Request**:
```json
{
  "promptType": "google_linking",
  "remindInDays": 7 // optional, null = dismiss permanently
}
```
- **Logic**:
  1. Update `Onboarding_Status.dismissed_prompts`
  2. Increment `dismiss_count`
  3. Set `remind_after` if applicable
- **Response**:
```json
{
  "success": true,
  "message": "Prompt dismissed"
}
```

---

### Account Merge Routes (NEW - Admin/Advanced)

**POST /auths/merge-accounts** (Admin only)
- **Purpose**: Merge two accounts manually (conflict resolution)
- **Auth**: Requires admin JWT
- **Request**:
```json
{
  "primaryAccountId": "...",
  "secondaryAccountId": "...",
  "mergeStrategy": "keep_primary_mobile" // or "keep_secondary_mobile", etc.
}
```
- **Logic**:
  1. Validate both accounts exist
  2. Merge `linked_providers` from both
  3. Copy OAuth tokens from secondary to primary
  4. Update `User` fields (phone, email) based on strategy
  5. Mark secondary account as deleted (soft delete)
  6. Add entry to `primary.merged_from_accounts`
  7. Migrate data (classes, enrollments, etc.) - out of scope for this doc
- **Response**:
```json
{
  "success": true,
  "message": "Accounts merged successfully",
  "data": {
    "primaryAccountId": "...",
    "linkedProviders": ["google", "apple", "mobile"]
  }
}
```

---

## B.2.2 Security Controls for Linking

### Requirement: Recent Verification

**Rule**: Before linking a provider, user must have verified their identity within the last 5 minutes.

**Implementation**:
1. When user performs sensitive action (linking), check `System_User.last_verification_at`
2. If `last_verification_at` is null or > 5 minutes ago → Require re-verification
3. Re-verification methods:
   - **For mobile users**: Send OTP, verify OTP, then proceed
   - **For Google/Apple users**: Require password (if set) OR OAuth re-auth
4. On successful verification, update `last_verification_at = Date.now()`

**Example Flow**:
```
User (logged in via mobile OTP 1 hour ago) clicks "Link Google"
→ Backend checks last_verification_at → 1 hour old
→ Backend returns { requiresVerification: true, verificationMethod: 'otp' }
→ Frontend shows OTP input
→ User enters OTP → Backend validates → Updates last_verification_at
→ Proceeds with Google OAuth → Linking completes
```

### Requirement: Linking Nonce

**Purpose**: Prevent replay attacks during linking

**Implementation**:
1. When initiating linking (e.g., `GET /auths/link-google-oauth`):
   - Generate random `linking_nonce` (crypto-strong, 32 bytes hex)
   - Store in `System_User.linking_nonce`
   - Set `linking_nonce_expires = Date.now() + 10 minutes`
   - Include nonce in OAuth state
2. When completing linking (e.g., `GET /auths/link-google-callback`):
   - Validate nonce matches
   - Check not expired
   - Delete nonce after use (one-time use)
3. If nonce invalid/expired → Abort linking, return error

**Example State**:
```json
{
  "userId": "abc123",
  "returnUrl": "/dashboard",
  "csrf": "xyz789",
  "nonce": "a1b2c3d4e5f6...",
  "timestamp": 1704556800000
}
```

### Requirement: Prevent Duplicate Linking

**Rule**: A provider ID (e.g., Google ID) can only be linked to one account

**Implementation**:
1. Before linking, query `System_User.find({ google_id: <googleId> })`
2. If exists and `user_id` differs from current user → Error: "This Google account is already linked to another user"
3. If exists and `user_id` matches current user → Idempotent, already linked
4. If not exists → Proceed

### Requirement: Don't Lock Out User

**Rule**: User must have at least one working auth method

**Implementation**:
1. Before unlinking provider:
   - Count linked providers: `linkedProviders.length`
   - If count === 1 → Error: "Cannot unlink. You must have at least one sign-in method."
   - If count > 1 → Proceed
2. Special case: If user has password set, they can unlink all OAuth providers (can still sign in with email/password)

---




