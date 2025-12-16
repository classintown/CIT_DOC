# PART B.3: CONFLICT RESOLUTION MATRIX

## B.3.1 Deterministic Conflict Resolution Rules

### Scenario 1: Mobile OTP User Tries Google Sign-In

**Case 1.1: Email Match + Phone Match**
- **Condition**: User A exists with mobile=+919876543210, email=john@gmail.com (via mobile OTP)
- **Action**: User signs in with Google, Google email=john@gmail.com
- **Decision**: **SAFE AUTO-LINK**
- **Logic**:
  1. Check `System_User` by email → Found
  2. Check if `google_id` already set → No
  3. Check if Google email matches `System_User.email` → Yes
  4. Check `User` by `user_id` → Has mobile=+919876543210
  5. **Conclusion**: Same person (email + phone match) → Auto-link Google
  6. Update `System_User.google_id`, store tokens
  7. Add 'google' to `linked_providers`
  8. Update `Onboarding_Status.google_verified = true`
- **User Experience**: Login successful, see "Google account linked" notification

**Case 1.2: Email Match + Phone Missing**
- **Condition**: User A exists with mobile=+919876543210, email=john@gmail.com
- **Action**: User signs in with Google, Google email=john@gmail.com
- **Check**: Does Google user profile have phone number?
  - If yes and matches → Auto-link (same as 1.1)
  - If no or differs → **REQUIRE CONFIRMATION**
- **Decision**: **SHOW CONFIRMATION DIALOG**
- **Logic**:
  1. Same checks as 1.1, but phones don't match
  2. **Risk**: Potential account takeover if attacker knows email
  3. Send OTP to existing mobile (+919876543210)
  4. Require OTP verification before linking
- **User Experience**:
  - "We found an account with this email. To link your Google account, verify your mobile number."
  - Show OTP input → Verify → Link Google

**Case 1.3: Email Differs + Phone Match (Edge Case)**
- **Condition**: User A exists with mobile=+919876543210, email=old@example.com
- **Action**: User signs in with Google, Google email=new@gmail.com
- **Decision**: **REQUIRE MANUAL MERGE or CREATE NEW ACCOUNT**
- **Logic**:
  1. Check by Google email → No `System_User` found
  2. Check by mobile (+919876543210) → Found in `User` collection
  3. **Conflict**: Same phone, different email
  4. **Options**:
     a) User confirms: "Link to existing account" → Update email to new@gmail.com
     b) User chooses: "Create new account" → Must use different mobile
- **User Experience**:
  - "We found an account with mobile +919876543210 but email old@example.com."
  - "Do you want to link Google to this account? (Email will be updated)"
  - Buttons: [Link to existing account] [Use different number]

**Case 1.4: No Email Match, No Phone Match**
- **Condition**: New Google user, no conflicts
- **Decision**: **CREATE NEW ACCOUNT** (require mobile verification)
- **Logic**:
  1. No `System_User` found by Google email
  2. No `User` found by mobile (if provided)
  3. Store Google session in `GoogleOAuthSessionTemp`
  4. Redirect to mobile verification screen
- **User Experience**:
  - "To complete registration, verify your mobile number"
  - Enter mobile → Receive OTP → Verify → Account created

---

### Scenario 2: Google User Tries Mobile OTP Sign-In

**Case 2.1: Email in System_User Matches, Mobile Not Yet Linked**
- **Condition**: User A exists via Google (email=john@gmail.com, no mobile)
- **Action**: User tries mobile OTP sign-in with +919876543210
- **Decision**: **LINK MOBILE TO EXISTING ACCOUNT**
- **Logic**:
  1. User enters mobile → Send OTP
  2. User verifies OTP
  3. Backend checks: Does mobile exist in `User` collection?
     - If no → Link to existing Google user
     - If yes → Conflict (see Case 2.2)
  4. Update `User` model with mobile
  5. Update `System_User.mobile_verified = true`
  6. Add 'mobile' to `linked_providers`
- **User Experience**:
  - "Mobile number linked successfully"
  - Login with existing Google account tokens

**Case 2.2: Mobile Exists in Different Account**
- **Condition**: User A (Google) and User B (Mobile OTP) are separate
- **Action**: User A (Google) tries to sign in with User B's mobile
- **Decision**: **ERROR - CONFLICT**
- **Logic**:
  1. User enters mobile → Send OTP
  2. User verifies OTP
  3. Backend checks: Mobile exists in `User` collection → Found User B
  4. Check if User B has Google linked → No
  5. **Conflict**: Mobile belongs to different account
  6. **Options**:
     a) Merge accounts (requires admin or careful UX)
     b) Error: "This mobile is already registered. Please use a different number or sign in with mobile OTP."
- **User Experience**:
  - "This mobile number is already linked to another account."
  - "Sign in with that account or use a different mobile number."

---

### Scenario 3: Apple User Tries Google Sign-In (Cross-Provider Linking)

**Case 3.1: Same Email (Not Private Relay)**
- **Condition**: User A exists via Apple (email=john@gmail.com, verified)
- **Action**: User signs in with Google (email=john@gmail.com)
- **Decision**: **AUTO-LINK if Email Matches**
- **Logic**:
  1. Check `System_User` by Google email → Found (has `apple_id`)
  2. Check if `google_id` already set → No
  3. Email matches → Safe to link
  4. Store Google tokens, update `google_id`
  5. Add 'google' to `linked_providers`
- **User Experience**:
  - "Google account linked to your existing Apple account"
  - Login successful

**Case 3.2: Apple Private Relay Email**
- **Condition**: User A exists via Apple (email=abc123@privaterelay.appleid.com)
- **Action**: User signs in with Google (email=john@gmail.com)
- **Decision**: **CANNOT AUTO-LINK** (emails don't match)
- **Logic**:
  1. Check by Google email → No `System_User` found
  2. Check by Apple email → Found, but it's private relay
  3. **Cannot determine if same person**
  4. Require mobile verification to link
- **User Experience**:
  - "To link your Google account, verify your mobile number"
  - Send OTP to existing mobile → Verify → Link Google

---

### Scenario 4: Logged-In User Explicitly Links Provider

**Case 4.1: Link Google (User Logged In via Mobile)**
- **Condition**: User A logged in via mobile OTP
- **Action**: User clicks "Connect Google" in settings
- **Decision**: **LINK GOOGLE** (after verification)
- **Logic**:
  1. Validate JWT → Get userId
  2. Check `System_User.last_verification_at` → If > 5 mins, require OTP
  3. User completes Google OAuth
  4. Check if Google ID already linked to another user → Error if yes
  5. Store tokens, link Google
- **User Experience**:
  - Click "Connect Google" → OAuth popup → "Google connected"

**Case 4.2: Link Apple (User Logged In via Google)**
- **Condition**: User A logged in via Google
- **Action**: User clicks "Connect Apple" in settings
- **Decision**: **LINK APPLE** (after verification)
- **Logic**: Same as 4.1, but for Apple

**Case 4.3: Link Mobile (User Logged In via Google/Apple)**
- **Condition**: User A logged in via Google (no mobile)
- **Action**: User clicks "Verify Mobile" in settings
- **Decision**: **LINK MOBILE** (after OTP verification)
- **Logic**:
  1. Validate JWT → Get userId
  2. User enters mobile → Send OTP
  3. User verifies OTP
  4. Check if mobile exists in another account → Error if yes
  5. Update `User` model, link mobile

---

## B.3.2 Conflict Resolution Matrix (Summary Table)

| **Scenario** | **Match On** | **Action** | **Verification Required** | **Auto-Link** |
|--------------|--------------|------------|---------------------------|---------------|
| Mobile → Google | Email + Phone | Link Google | No | ✅ Yes |
| Mobile → Google | Email only | Link Google | ⚠️ Yes (OTP to existing mobile) | ⚠️ With confirmation |
| Mobile → Google | Phone only | Update email, link | ⚠️ Yes (OTP + confirm email change) | ⚠️ With confirmation |
| Mobile → Google | Neither | Create new account | ⚠️ Yes (mobile OTP for new user) | ❌ No |
| Google → Mobile | Email exists, no mobile | Link mobile | ⚠️ Yes (OTP to new mobile) | ✅ Yes |
| Google → Mobile | Mobile exists elsewhere | Error | N/A | ❌ No |
| Apple → Google | Same email (not relay) | Link Google | No | ✅ Yes |
| Apple → Google | Private relay email | Link Google | ⚠️ Yes (mobile OTP) | ⚠️ With verification |
| Google → Apple | Same email | Link Apple | No | ✅ Yes |
| Google → Apple | Different email | Link Apple | ⚠️ Yes (recent auth) | ⚠️ With confirmation |
| Logged-in user | N/A | Manual link | ⚠️ Yes (recent auth < 5 mins) | ✅ Yes (if no conflicts) |
| Admin merge | N/A | Force merge | ⚠️ Yes (admin auth) | ✅ Yes (manual) |

**Legend**:
- ✅ Yes: Action is safe and automatic
- ⚠️ With confirmation/verification: Action requires user confirmation or OTP
- ❌ No: Action is blocked or creates new account

---

## B.3.3 Auth State Machine

### State 1: Unauthenticated

**Entry**: User visits app, no valid JWT

**Actions Available**:
- Sign in with Mobile OTP → State 2
- Sign in with Google → State 3
- Sign in with Apple → State 4
- Sign up (email/password) → Out of scope (legacy)

---

### State 2: Mobile OTP Flow

**Sub-State 2A: OTP Sent**
- User entered mobile → OTP sent
- **Next**: Enter OTP → Verify

**Sub-State 2B: OTP Verified**
- Check if user exists:
  - **If exists**: Issue JWT → State 5 (Authenticated, Mobile Only)
  - **If not exists**: Create user → Issue JWT → State 5

---

### State 3: Google OAuth Flow

**Sub-State 3A: OAuth Initiated**
- Redirect to Google → User consents

**Sub-State 3B: OAuth Callback**
- Receive authorization code → Exchange for tokens
- Verify ID token → Get user info
- **Check conflicts**:
  - Email exists in System_User:
    - Has Google ID → Login (existing user) → State 6 (Authenticated, Google)
    - No Google ID → Check phone match:
      - Phone matches → Auto-link → State 7 (Authenticated, Multi-Provider)
      - Phone missing/differs → Require mobile OTP → Sub-State 3C
  - Email not exists:
    - Create temp session → Require mobile verification → Sub-State 3C

**Sub-State 3C: Mobile Verification Required**
- Show mobile input → Send OTP → Verify OTP
- Check conflicts again
- **Complete signup**:
  - Create user OR link to existing → Issue JWT → State 7

---

### State 4: Apple Sign-In Flow

**Sub-State 4A: OAuth Initiated**
- Redirect to Apple → User consents

**Sub-State 4B: OAuth Callback**
- Same logic as State 3B, but for Apple

**Sub-State 4C: Mobile Verification Required**
- Same as State 3C

---

### State 5: Authenticated (Mobile Only)

**User has**: Mobile verified, no Google, no Apple

**Actions Available**:
- Link Google → Initiate Google OAuth → State 3B (linking mode)
- Link Apple → Initiate Apple OAuth → State 4B (linking mode)
- Continue using app (show prompts to link other providers)
- Logout → State 1

**Warnings Shown**:
- Banner: "Connect your Google account for email & calendar integration" (dismissible)
- Banner: "Connect your Apple account for seamless sign-in" (dismissible)

---

### State 6: Authenticated (Google Only)

**User has**: Google verified, no mobile

**Actions Available**:
- Link Mobile → Send OTP → Verify → State 7
- Link Apple → Initiate Apple OAuth → State 7
- Continue using app (show warning to verify mobile)
- Logout → State 1

**Warnings Shown**:
- Banner: "Verify your mobile number to secure your account" (required, not dismissible until done or dismissed 3x)

---

### State 7: Authenticated (Multi-Provider)

**User has**: 2 or more providers linked (e.g., Mobile + Google, or all three)

**Actions Available**:
- Unlink provider (if > 1 provider linked)
- Continue using app (no warnings unless a provider token expires)
- Logout → State 1

**Warnings Shown**:
- None (or warnings about expired tokens)

---

### State 8: Provider Linking in Progress

**Entry**: User clicked "Link Google" or "Link Apple" while logged in

**Sub-State 8A: Verification Check**
- Check `last_verification_at`
- If > 5 mins → Require OTP → Sub-State 8B
- If < 5 mins → Proceed to OAuth → Sub-State 8C

**Sub-State 8B: Re-Verification**
- Send OTP → User verifies → Update `last_verification_at` → Sub-State 8C

**Sub-State 8C: OAuth Flow**
- Redirect to provider OAuth → User consents → Callback
- Link provider → Update tokens → State 7 (Multi-Provider)

---

## B.3.4 Frontend State Management

### User Profile State (BehaviorSubject or Store)

```typescript
interface UserAuthState {
  isAuthenticated: boolean;
  user: {
    id: string;
    fullName: string;
    email: string | null;
    mobile: string | null;
    userRole: string;
    userType: string;
  } | null;
  tokens: {
    accessToken: string;
    refreshToken: string;
  } | null;
  providerStatus: {
    hasGoogle: boolean;
    hasApple: boolean;
    hasMobile: boolean;
    primaryProvider: 'mobile' | 'google' | 'apple' | 'email';
    linkedProviders: string[];
  };
  onboardingStatus: {
    mobileVerified: boolean;
    googleVerified: boolean;
    appleVerified: boolean;
    onboardingCompleted: boolean;
    currentStep: string;
    nextActions: Array<{
      action: string;
      priority: 'required' | 'recommended' | 'optional';
      prompt: string;
      dismissible: boolean;
    }>;
  };
}
```

### State Transitions

**Initial Load**:
1. Check `localStorage` for `accessToken`
2. If exists → Call `GET /auths/account-status`
3. Update `UserAuthState` with response
4. Redirect to dashboard if authenticated

**After Login**:
1. Receive tokens from backend
2. Store in `localStorage`
3. Update `UserAuthState`
4. Call `GET /auths/account-status` (optional, already included in login response)
5. Navigate to dashboard

**After Linking Provider**:
1. OAuth callback succeeds → Store new tokens (if applicable)
2. Call `GET /auths/account-status` to refresh state
3. Update `providerStatus` and `onboardingStatus`
4. Show success notification

**After Dismissing Prompt**:
1. Call `POST /auths/dismiss-prompt`
2. Update `onboardingStatus.nextActions` (remove dismissed action or update reminder time)
3. Hide banner in UI

---

## B.3.5 Linking Flow Sequence Diagrams (Text-Based)

### Link Google to Mobile User

```
User (Mobile Auth) → Frontend
  |
  | 1. Click "Connect Google"
  |
Frontend → Backend: GET /auths/link-google-oauth (JWT)
  |
  | 2. Check last_verification_at
  |      - If > 5 mins: Return { requiresVerification: true }
  |      - If < 5 mins: Generate OAuth URL
  |
Backend → Frontend: { authUrl: "https://accounts.google.com/..." }
  |
  | 3. Redirect to Google
  |
User → Google: Consent screen
  |
  | 4. User approves
  |
Google → Backend: Redirect to /auths/link-google-callback?code=...&state=...
  |
  | 5. Exchange code for tokens
  | 6. Verify state (userId, nonce, csrf)
  | 7. Check if Google ID already linked → Error if yes
  | 8. Store tokens in System_User
  | 9. Update linked_providers
  | 10. Update Onboarding_Status.google_verified = true
  |
Backend → Frontend: Redirect to /auth/google-linked-success
  |
  | 11. Show success notification
  |
Frontend → Backend: GET /auths/account-status (refresh state)
  |
  | 12. Update UserAuthState
  |
Frontend → User: "Google account connected" ✅
```

### Link Mobile to Google User

```
User (Google Auth) → Frontend
  |
  | 1. Click "Verify Mobile"
  |
Frontend → Backend: POST /auths/link/mobile/start (JWT, mobile)
  |
  | 2. Generate OTP
  | 3. Check if mobile exists → Error if linked elsewhere
  | 4. Save OTP to User_Temp_Otp
  | 5. Send SMS
  |
Backend → Frontend: { success: true, expiresIn: 300 }
  |
  | 6. Show OTP input
  |
User → Frontend: Enter OTP
  |
Frontend → Backend: POST /auths/link/mobile/verify (JWT, mobile, otp)
  |
  | 7. Validate OTP
  | 8. Update User.mobile
  | 9. Update System_User.mobile_verified = true
  | 10. Add 'mobile' to linked_providers
  |
Backend → Frontend: { success: true, linkedProviders: ["google", "mobile"] }
  |
  | 11. Update UserAuthState
  | 12. Show success notification
  |
Frontend → User: "Mobile number verified" ✅
```

---




