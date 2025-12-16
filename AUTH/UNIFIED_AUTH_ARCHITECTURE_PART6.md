# PART D: MIGRATION + ROLLOUT PLAN

## D.1 Database Migration Strategy

### Phase 1: Schema Updates (Non-Breaking)

**Timeline**: Day 1-2

**Actions**:
1. **Add New Fields to System_User**:
```javascript
// Migration script: migrations/001_add_linking_fields.js
db.system_users.updateMany(
  {},
  {
    $set: {
      mobile_verified: false,
      mobile_verified_at: null,
      email_verified: false,
      email_verified_at: null,
      provider_link_history: [],
      last_verification_at: null,
      linking_nonce: null,
      linking_nonce_expires: null,
      merged_from_accounts: [],
      email_lower: null,
      phone_e164: null,
      is_active: true,
      is_blocked: false,
      blocked_reason: null,
      blocked_at: null,
      deleted_at: null
    }
  }
);
```

2. **Create New Indexes** (non-blocking):
```javascript
// migrations/002_add_indexes.js
db.system_users.createIndex({ google_id: 1 }, { unique: true, sparse: true, background: true });
db.system_users.createIndex({ apple_id: 1 }, { unique: true, sparse: true, background: true });
db.system_users.createIndex({ email_lower: 1 }, { background: true });
db.system_users.createIndex({ phone_e164: 1 }, { background: true });
db.system_users.createIndex({ primary_auth_provider: 1, is_active: 1 }, { background: true });
```

3. **Create New Collection** (`google_oauth_session_temps`):
```javascript
// migrations/003_create_google_session_temp.js
db.createCollection('google_oauth_session_temps');
db.google_oauth_session_temps.createIndex({ session_id: 1 }, { unique: true });
db.google_oauth_session_temps.createIndex({ email: 1 });
db.google_oauth_session_temps.createIndex({ session_id: 1, status: 1 });
db.google_oauth_session_temps.createIndex({ expires_at: 1 }, { expireAfterSeconds: 0 });
```

4. **Create New Collection** (`account_linking_sessions`):
```javascript
// migrations/004_create_linking_sessions.js
db.createCollection('account_linking_sessions');
db.account_linking_sessions.createIndex({ session_id: 1 }, { unique: true });
db.account_linking_sessions.createIndex({ user_id: 1, status: 1 });
db.account_linking_sessions.createIndex({ expires_at: 1 }, { expireAfterSeconds: 0 });
```

---

### Phase 2: Data Backfill

**Timeline**: Day 3-4

**Purpose**: Populate new fields with existing data

**Script**: `migrations/005_backfill_existing_users.js`

```javascript
const User = require('../models/user/user.model');
const System_User = require('../models/user/system_user.model');

async function backfillUsers() {
  console.log('Starting backfill of existing users...');
  
  const systemUsers = await System_User.find({}).exec();
  let processed = 0;
  let errors = 0;

  for (const su of systemUsers) {
    try {
      // 1. Populate linked_providers based on existing fields
      const providers = [];
      if (su.google_id) providers.push('google');
      if (su.apple_id) providers.push('apple');
      if (su.facebook_id) providers.push('facebook');
      if (su.password) providers.push('email');
      
      // 2. Normalize email
      su.email_lower = su.email ? su.email.toLowerCase() : null;
      
      // 3. Set verification flags for existing OAuth users
      if (su.google_id) {
        su.email_verified = true;
        su.email_verified_at = su.created_at || new Date();
        if (!providers.includes('google')) providers.push('google');
      }
      
      if (su.apple_id) {
        if (!providers.includes('apple')) providers.push('apple');
      }
      
      // 4. Lookup User for mobile
      const user = await User.findById(su.user_id).exec();
      if (user && user.mobile) {
        su.phone_e164 = user.getMobileE164(); // Use helper method
        su.mobile_verified = true;
        su.mobile_verified_at = user.created_at || new Date();
        if (!providers.includes('mobile')) providers.push('mobile');
      }
      
      // 5. Set primary auth provider (infer from oldest linked)
      if (providers.length > 0 && !su.primary_auth_provider) {
        // Default to first linked provider (or 'mobile' if has mobile)
        su.primary_auth_provider = providers.includes('mobile') ? 'mobile' : providers[0];
      }
      
      // 6. Update linked_providers
      su.linked_providers = [...new Set(providers)];
      
      // 7. Save
      await su.save();
      
      processed++;
      if (processed % 100 === 0) {
        console.log(`Processed ${processed} users...`);
      }
    } catch (error) {
      console.error(`Error processing user ${su._id}:`, error);
      errors++;
    }
  }
  
  console.log(`Backfill complete. Processed: ${processed}, Errors: ${errors}`);
}

module.exports = backfillUsers;
```

**Run**: `node migrations/005_backfill_existing_users.js`

---

### Phase 3: Update Onboarding Status

**Timeline**: Day 5

**Script**: `migrations/006_backfill_onboarding_status.js`

```javascript
const OnboardingStatus = require('../models/user/onboarding_status.model');
const System_User = require('../models/user/system_user.model');

async function backfillOnboardingStatus() {
  console.log('Backfilling onboarding status...');
  
  const systemUsers = await System_User.find({}).exec();
  
  for (const su of systemUsers) {
    // Check if onboarding status exists
    let onboarding = await OnboardingStatus.findOne({ user_id: su.user_id });
    
    if (!onboarding) {
      // Create new onboarding status
      onboarding = await OnboardingStatus.create({
        user_id: su.user_id,
        mobile_verified: su.mobile_verified || false,
        google_verified: su.hasProvider('google'),
        apple_verified: su.hasProvider('apple'),
        debug_info: {
          created_via: 'migration',
          initial_data: {
            primary_auth_provider: su.primary_auth_provider
          }
        }
      });
    } else {
      // Update existing onboarding status
      onboarding.mobile_verified = su.mobile_verified || onboarding.mobile_verified;
      onboarding.google_verified = su.hasProvider('google');
      onboarding.apple_verified = su.hasProvider('apple');
      await onboarding.save();
    }
  }
  
  console.log('Onboarding status backfill complete');
}

module.exports = backfillOnboardingStatus;
```

---

### Phase 4: Validation & Rollback Plan

**Timeline**: Day 6

**Validation Queries**:
```javascript
// 1. Check all users have linked_providers populated
db.system_users.count({ linked_providers: { $exists: false } }); // Should be 0

// 2. Check all users with google_id have 'google' in linked_providers
db.system_users.count({ google_id: { $ne: null }, linked_providers: { $ne: 'google' } }); // Should be 0

// 3. Check email_lower is populated
db.system_users.count({ email: { $ne: null }, email_lower: null }); // Should be 0

// 4. Check mobile_verified matches phone existence
const usersWithMobile = db.users.count({ mobile: { $ne: null } });
const systemUsersWithMobileVerified = db.system_users.count({ mobile_verified: true });
// These should be approximately equal (accounting for inactive users)
```

**Rollback Plan**:
If migration fails, rollback steps:
1. Drop new indexes (won't affect existing queries)
2. Remove new fields from `System_User` (optional, can leave as null)
3. Delete new collections (`google_oauth_session_temps`, `account_linking_sessions`)
4. Restore from backup if data corruption detected

---

## D.2 Backend Changes Sequence

### Phase 1: Model Updates (Non-Breaking)

**Timeline**: Week 1

1. **Update System_User Model** (`backend/models/user/system_user.model.js`)
   - Add new fields
   - Add pre-save middleware for `email_lower` and `linked_providers`
   - Add helper methods: `hasProvider()`, `addProvider()`, `removeProvider()`, `getVerificationStatus()`, `needsVerification()`

2. **Create New Models**:
   - `backend/models/auth/googleOAuthSessionTemp.model.js` (mirror Apple model)
   - `backend/models/auth/accountLinkingSession.model.js`

3. **Update Onboarding_Status Model** (`backend/models/user/onboarding_status.model.js`)
   - Add `dismissed_prompts` field
   - Add helper methods: `shouldShowPrompt()`, `dismissPrompt()`

4. **Update User Model** (minor):
   - Ensure `mobile` field supports E.164 format (already does)
   - Add helper method `getVerificationStatus()` (delegates to System_User)

---

### Phase 2: Backend Services (Helpers)

**Timeline**: Week 2

1. **Create Account Linking Service** (`backend/services/auth/accountLinkingService.js`)
   - Centralize linking logic
   - Methods:
     - `createLinkingSession(userId, provider, metadata)`
     - `validateLinkingSession(sessionId)`
     - `linkProvider(userId, provider, providerId, tokens, metadata)`
     - `unlinkProvider(userId, provider)`
     - `checkProviderConflict(provider, providerId)`

2. **Create Conflict Resolution Service** (`backend/services/auth/conflictResolutionService.js`)
   - Implement conflict detection logic
   - Methods:
     - `detectConflict(provider, email, phone, providerId)`
     - `resolveConflict(conflictType, strategy, metadata)`
     - `canAutoLink(systemUser, providerData)`

3. **Enhance Token Service** (`backend/services/auth/tokenService.js`)
   - Add onboarding status to JWT claims
   - Add provider status to JWT claims
   - Method: `generateEnhancedToken(userId, systemUser, onboardingStatus)`

---

### Phase 3: Backend Routes & Controllers

**Timeline**: Week 3-4

**Priority 1 (Critical)**:
1. **Update existing auth controllers** to return `onboardingStatus` and `providerStatus`:
   - `verifySignInOtp()` → Add status to response
   - `googleAuthCallback()` → Add conflict detection, add status to response
   - `appleAuthCallback()` → Add conflict detection, add status to response
   - `mobileGoogleSignIn()` → Add status to response
   - `mobileAppleSignIn()` → Add status to response

2. **Update existing linking controllers**:
   - `linkGoogleCallback()` → Add security validation (nonce, recent verification)

**Priority 2 (New Features)**:
3. **Create Apple linking routes**:
   - `GET /auths/link-apple-oauth` → New controller `initiateAppleLinking()`
   - `POST /auths/link-apple-callback` → New controller `linkAppleCallback()`
   - `POST /auths/disconnect-apple` → New controller `disconnectAppleAccount()`

4. **Create Mobile linking routes**:
   - `POST /auths/link/mobile/start` → New controller `startMobileLinking()`
   - `POST /auths/link/mobile/verify` → New controller `verifyMobileLinking()`
   - `POST /auths/unlink/mobile` → New controller `unlinkMobile()` (optional)

5. **Create Account status routes**:
   - `GET /auths/account-status` → New controller `getAccountStatus()`
   - `POST /auths/dismiss-prompt` → New controller `dismissPrompt()`

**Priority 3 (Admin Tools)**:
6. **Create Merge routes** (admin only):
   - `POST /auths/merge-accounts` → New controller `mergeAccounts()`

---

## D.3 Frontend Changes Sequence

### Phase 1: Services & State Management

**Timeline**: Week 1

1. **Create AccountLinkingService** (`frontend/src/app/services/common/auth/account-linking.service.ts`)

2. **Enhance AuthService** (`frontend/src/app/services/common/auth/auth.service.ts`)
   - Add methods: `setOnboardingStatus()`, `getOnboardingStatus()`, `setProviderStatus()`, `getProviderStatus()`, `needsVerification()`
   - Update login/OTP verification handlers to store new status fields

3. **Create UserAuthState Interface** (`frontend/src/app/models/common/user-auth-state.model.ts`)

---

### Phase 2: Shared Components

**Timeline**: Week 2

1. **Create AccountLinkingBannerComponent** (`frontend/src/app/shared/common-components/account-linking-banner/`)

2. **Create MobileLinkingModalComponent** (`frontend/src/app/shared/common-components/mobile-linking-modal/`)

3. **Create Success/Error Pages**:
   - `frontend/src/app/components/auth/apple-linked-success/` (mirror Google)
   - `frontend/src/app/components/auth/linking-error/`

4. **Create VerificationRequiredGuard** (`frontend/src/app/guards/verification-required.guard.ts`)

---

### Phase 3: Feature Integration

**Timeline**: Week 3-4

1. **Update Dashboard Components** (Instructor, Student, Institute, Admin, Parent):
   - Add `<app-account-linking-banner>` to templates
   - Add logic to check account status and show banner

2. **Update Profile/Settings Components**:
   - Add "Connected Accounts" section to profile pages
   - Add link/unlink buttons for each provider

3. **Update Login Components**:
   - Ensure login response handlers store `onboardingStatus` and `providerStatus`

4. **Apply VerificationRequiredGuard**:
   - Add guard to sensitive routes (class creation, payments, etc.)

---

## D.4 Testing Strategy

### Unit Tests

**Backend**:
1. **Model Tests** (`backend/tests/unit/models/`):
   - Test `System_User` helper methods: `hasProvider()`, `addProvider()`, `needsVerification()`
   - Test `Onboarding_Status` methods: `shouldShowPrompt()`, `dismissPrompt()`
   - Test pre-save middleware for `linked_providers` auto-population

2. **Service Tests** (`backend/tests/unit/services/`):
   - Test `accountLinkingService`: linking, unlinking, conflict detection
   - Test `conflictResolutionService`: all conflict scenarios from matrix
   - Test token generation with new fields

3. **Controller Tests** (`backend/tests/unit/controllers/`):
   - Test each new endpoint with various scenarios
   - Test error handling for conflicts
   - Test security validations (nonce, recent verification)

**Frontend**:
1. **Service Tests** (`frontend/src/app/services/common/auth/account-linking.service.spec.ts`):
   - Test API calls return correct data
   - Test error handling

2. **Component Tests**:
   - Test `AccountLinkingBannerComponent` shows correct banners
   - Test `MobileLinkingModalComponent` OTP flow
   - Test profile component link/unlink buttons

---

### Integration Tests

**Backend**:
1. **Full Auth Flows** (`backend/tests/integration/`):
   - Mobile OTP → Login → Link Google → Verify
   - Google OAuth → Login → Link Mobile → Verify
   - Apple OAuth → Login → Link Google → Verify
   - Conflict scenarios: Same email, same phone, etc.

2. **Linking Flows**:
   - Logged-in user links Google → Success
   - Logged-in user links Apple → Success
   - Logged-in user links Mobile → Success
   - Try to link already-linked provider → Error

**Frontend**:
1. **E2E Tests** (Cypress/Playwright):
   - User logs in via mobile OTP → See "Link Google" banner → Click → OAuth completes → Banner disappears
   - User logs in via Google → See "Verify Mobile" banner → Click → Enter mobile → Verify OTP → Banner disappears
   - User goes to profile → Links/unlinks providers → Changes reflected

---

### Manual Testing Checklist

**Day 1**:
- [ ] New user: Mobile OTP sign-in → Account created → See "Link Google" banner
- [ ] Click "Link Google" → OAuth flow → Google linked → Banner disappears
- [ ] Check profile → Google shown as connected

**Day 2**:
- [ ] New user: Google sign-in (no mobile) → See "Verify Mobile" banner
- [ ] Click "Verify Mobile" → Enter mobile → Receive OTP → Verify → Mobile linked
- [ ] Check profile → Mobile shown as connected

**Day 3**:
- [ ] New user: Apple sign-in (private relay email) → See "Verify Mobile" banner
- [ ] Link mobile → Success
- [ ] Go to profile → Link Google → Success
- [ ] Check all 3 providers connected

**Day 4**:
- [ ] Existing mobile user logs in → Check if banner shown correctly
- [ ] Existing Google user logs in → Check if mobile prompt shown
- [ ] Dismiss banner → Check dismissal tracked

**Day 5**:
- [ ] Conflict test: Mobile user with email A → Try to link Google with email B → See warning
- [ ] Conflict test: Mobile +919876543210 exists → New Google user tries to link same mobile → Error

**Day 6**:
- [ ] Unlink provider → Check can't unlink if only one method
- [ ] Unlink provider with multiple linked → Success → Check provider removed
- [ ] Try sensitive action without mobile verified → Blocked by guard

---

## D.5 Rollout Strategy with Feature Flag

### Feature Flag Implementation

**Backend** (`backend/configs/featureFlags.js`):
```javascript
module.exports = {
  UNIFIED_AUTH_ENABLED: process.env.UNIFIED_AUTH_ENABLED === 'true',
  ACCOUNT_LINKING_ENABLED: process.env.ACCOUNT_LINKING_ENABLED === 'true',
  REQUIRE_MOBILE_VERIFICATION: process.env.REQUIRE_MOBILE_VERIFICATION === 'true'
};
```

**Usage in Controllers**:
```javascript
const featureFlags = require('../../configs/featureFlags');

exports.getAccountStatus = async (req, res) => {
  if (!featureFlags.UNIFIED_AUTH_ENABLED) {
    return res.status(404).json({ error: 'Feature not available' });
  }
  // ... rest of controller logic
};
```

**Frontend** (`frontend/src/environments/environment.ts`):
```typescript
export const environment = {
  production: false,
  apiUrl: 'http://localhost:2000',
  features: {
    unifiedAuth: true,
    accountLinking: true,
    mobileVerificationRequired: true
  }
};
```

**Usage in Components**:
```typescript
import { environment } from 'src/environments/environment';

export class DashboardComponent {
  showLinkingBanner = environment.features.accountLinking;
}
```

---

### Rollout Phases

**Phase 0: Pre-Production**
- Enable flags in DEV environment
- Run all tests
- Manual QA testing
- Performance testing

**Phase 1: Beta Users (10%)**
- Enable flags for specific users (via DB flag)
- Monitor errors and performance
- Collect feedback
- Duration: 1 week

**Phase 2: Staged Rollout (25% → 50% → 75%)**
- Gradually increase user percentage
- Monitor:
  - Error rates
  - Linking success rates
  - User complaints
  - Performance metrics
- Duration: 2 weeks per stage

**Phase 3: Full Rollout (100%)**
- Enable for all users
- Monitor for 1 week
- Address any issues immediately

**Phase 4: Cleanup**
- Remove feature flags after 2 weeks of stable operation
- Archive old code paths

---




