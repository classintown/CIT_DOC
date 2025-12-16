# PART B: TARGET ARCHITECTURE (DESIGN)

## B.1 Database Design (MongoDB)

### Approach: Enhanced Existing Schema (Recommended)

**Rationale**: Your existing schema already has:
- `System_User.google_id`, `apple_id` fields
- `primary_auth_provider` and `linked_providers` array
- Mobile fields in `User` model

**Strategy**: Extend and standardize existing schema rather than creating new collections.

---

### B.1.1 Updated User Schema

**Collection**: `users`

**No Major Changes Needed** - Current schema is sufficient. Ensure:
- `mobile` remains unique (E.164 format preferred)
- `email` is optional (not all users have email initially)
- Add validation to prevent empty string emails (use `null` instead)

**New Indexes**:
```javascript
// Compound index for phone-based lookups (backward compatible)
db.users.createIndex({ mobile: 1, country_code: 1 });

// Text index for search (optional, if not exists)
db.users.createIndex({ fullName: "text", email: "text" });
```

**Helper Methods to Add**:
```javascript
// User.model.js additions
UserSchema.methods.getVerificationStatus = function() {
  return {
    hasMobile: !!this.mobile,
    hasEmail: !!this.email,
    // Check System_User for provider links (async lookup needed)
  };
};

UserSchema.statics.findByEmailOrPhone = async function(email, phone) {
  const conditions = [];
  if (email) conditions.push({ email: email.toLowerCase() });
  if (phone) {
    // Multiple format search for backward compatibility
    conditions.push(
      { mobile: phone },
      { mobile: Number(phone.replace(/\D/g, '')) },
      { mobile: phone.replace(/^\+/, '') }
    );
  }
  return this.findOne({ $or: conditions });
};
```

---

### B.1.2 Updated System_User Schema

**Collection**: `system_users`

**Current Fields** (Keep):
- `user_id` (ref User)
- `email` (unique, required)
- `password` (optional)
- `google_id`, `google_access_token`, `google_refresh_token`, `google_token_expires`, `google_token_scope`
- `apple_id`, `apple_refresh_token`, `apple_token_expires`, `apple_token_scope`, `apple_email`, `apple_email_verified`, `apple_is_private_relay`
- `primary_auth_provider` (enum)
- `linked_providers` (array)
- `facebook_id` (for completeness)

**New Fields to Add**:
```javascript
{
  // ============================================================================
  // MOBILE AUTHENTICATION FIELDS (NEW)
  // ============================================================================
  mobile_verified: {
    type: Boolean,
    default: false
  },
  mobile_verified_at: {
    type: Date,
    default: null
  },
  
  // ============================================================================
  // EMAIL VERIFICATION FIELDS (NEW)
  // ============================================================================
  email_verified: {
    type: Boolean,
    default: false
  },
  email_verified_at: {
    type: Date,
    default: null
  },
  
  // ============================================================================
  // PROVIDER LINKING METADATA
  // ============================================================================
  provider_link_history: [{
    provider: {
      type: String,
      enum: ['google', 'apple', 'facebook', 'mobile', 'email']
    },
    linked_at: {
      type: Date,
      default: Date.now
    },
    linked_by: {
      type: String,
      enum: ['user', 'system', 'auto_merge'],
      default: 'user'
    },
    ip_address: String,
    user_agent: String,
    verification_method: String // e.g., 'otp', 'oauth', 'auto'
  }],
  
  // ============================================================================
  // ACCOUNT LINKING SECURITY
  // ============================================================================
  last_verification_at: {
    type: Date,
    default: null
    // Track last time user verified identity (OTP, password, etc.)
  },
  linking_nonce: {
    type: String,
    default: null
    // One-time token for linking operations (prevent replay)
  },
  linking_nonce_expires: {
    type: Date,
    default: null
  },
  
  // ============================================================================
  // ACCOUNT MERGE TRACKING
  // ============================================================================
  merged_from_accounts: [{
    merged_user_id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    merged_system_user_id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'System_User'
    },
    merged_at: Date,
    merged_reason: String,
    merged_by: String // 'user', 'admin', 'system'
  }],
  
  // ============================================================================
  // NORMALIZED FIELDS FOR MATCHING
  // ============================================================================
  email_lower: {
    type: String,
    index: true,
    lowercase: true
    // Auto-populated from email field
  },
  phone_e164: {
    type: String,
    index: true
    // Normalized phone format from User.mobile
  },
  
  // ============================================================================
  // ACCOUNT STATUS
  // ============================================================================
  is_active: {
    type: Boolean,
    default: true
  },
  is_blocked: {
    type: Boolean,
    default: false
  },
  blocked_reason: String,
  blocked_at: Date,
  deleted_at: Date
}
```

**New Indexes**:
```javascript
// Prevent duplicate provider IDs
db.system_users.createIndex({ google_id: 1 }, { unique: true, sparse: true });
db.system_users.createIndex({ apple_id: 1 }, { unique: true, sparse: true });
db.system_users.createIndex({ facebook_id: 1 }, { unique: true, sparse: true });

// Fast lookup by normalized fields
db.system_users.createIndex({ email_lower: 1 });
db.system_users.createIndex({ phone_e164: 1 });

// Compound index for provider searches
db.system_users.createIndex({ primary_auth_provider: 1, is_active: 1 });
```

**Pre-Save Middleware to Add**:
```javascript
SystemUserSchema.pre('save', function(next) {
  // Auto-populate normalized fields
  if (this.email && this.isModified('email')) {
    this.email_lower = this.email.toLowerCase();
  }
  
  // Populate phone_e164 from linked User (requires async lookup in practice)
  // For now, can be set manually during linking operations
  
  // Update linked_providers based on provider fields
  const providers = [];
  if (this.google_id) providers.push('google');
  if (this.apple_id) providers.push('apple');
  if (this.facebook_id) providers.push('facebook');
  if (this.password) providers.push('email');
  if (this.mobile_verified) providers.push('mobile');
  
  this.linked_providers = [...new Set(providers)];
  
  next();
});
```

**Helper Methods**:
```javascript
SystemUserSchema.methods.hasProvider = function(provider) {
  return this.linked_providers.includes(provider);
};

SystemUserSchema.methods.canLinkProvider = function(provider) {
  // Business rules for linking
  if (this.hasProvider(provider)) return false; // Already linked
  return true;
};

SystemUserSchema.methods.addProvider = function(provider, metadata = {}) {
  if (!this.hasProvider(provider)) {
    this.linked_providers.push(provider);
    this.provider_link_history.push({
      provider,
      linked_at: new Date(),
      linked_by: metadata.linked_by || 'user',
      ip_address: metadata.ip_address,
      user_agent: metadata.user_agent,
      verification_method: metadata.verification_method
    });
  }
};

SystemUserSchema.methods.removeProvider = function(provider) {
  this.linked_providers = this.linked_providers.filter(p => p !== provider);
  // Optionally clear provider-specific fields (google_id, etc.)
};

SystemUserSchema.methods.getVerificationStatus = function() {
  return {
    hasGoogle: this.hasProvider('google'),
    hasApple: this.hasProvider('apple'),
    hasMobile: this.hasProvider('mobile') || this.mobile_verified,
    hasEmail: this.hasProvider('email') || this.email_verified,
    primaryProvider: this.primary_auth_provider,
    allLinkedProviders: this.linked_providers
  };
};

SystemUserSchema.methods.needsVerification = function() {
  const needs = {
    mobile: !this.mobile_verified && !this.hasProvider('mobile'),
    google: !this.hasProvider('google'),
    apple: !this.hasProvider('apple')
  };
  
  // Define business rule: mobile verification is required, others are optional
  return {
    ...needs,
    anyRequired: needs.mobile, // Mobile is always required
    anyOptional: needs.google || needs.apple
  };
};
```

---

### B.1.3 OAuth Temporary Session Models

**Existing: AppleOAuthSessionTemp** - Keep as is, works well

**New: GoogleOAuthSessionTemp** (mirror Apple model)

**Collection**: `google_oauth_session_temps`

```javascript
{
  session_id: {
    type: String,
    required: true,
    unique: true,
    index: true
  },
  email: {
    type: String,
    required: true,
    lowercase: true,
    index: true
  },
  google_id: {
    type: String,
    required: true
  },
  full_name: String,
  profile_picture: String,
  email_verified: Boolean,
  google_tokens: {
    access_token: String,
    refresh_token: String,
    id_token: String,
    expires_in: Number,
    scope: String
  },
  return_url: String,
  status: {
    type: String,
    enum: ['pending', 'completed', 'expired'],
    default: 'pending'
  },
  created_at: {
    type: Date,
    default: Date.now
  },
  expires_at: {
    type: Date,
    required: true,
    index: true // TTL index
  },
  completed_at: Date,
  ip_address: String,
  user_agent: String
}

// TTL index - auto-delete after expiration
GoogleOAuthSessionTempSchema.index({ expires_at: 1 }, { expireAfterSeconds: 0 });

// Static methods (same as Apple model)
GoogleOAuthSessionTempSchema.statics.createSession = async function(sessionData) { /* ... */ };
GoogleOAuthSessionTempSchema.statics.findActiveSession = async function(sessionId) { /* ... */ };
GoogleOAuthSessionTempSchema.statics.completeSession = async function(sessionId) { /* ... */ };
```

---

### B.1.4 Account Linking Session Model (New)

**Purpose**: Secure linking operations with time-limited sessions

**Collection**: `account_linking_sessions`

```javascript
{
  session_id: {
    type: String,
    required: true,
    unique: true,
    index: true
  },
  user_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  system_user_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'System_User',
    required: true
  },
  linking_provider: {
    type: String,
    enum: ['google', 'apple', 'mobile'],
    required: true
  },
  linking_action: {
    type: String,
    enum: ['link', 'unlink', 'merge'],
    required: true
  },
  verification_method: {
    type: String,
    enum: ['otp', 'password', 'oauth', 'none'],
    required: true
  },
  verified_at: {
    type: Date,
    required: true
  },
  status: {
    type: String,
    enum: ['pending', 'verified', 'completed', 'expired', 'cancelled'],
    default: 'pending'
  },
  created_at: {
    type: Date,
    default: Date.now
  },
  expires_at: {
    type: Date,
    required: true,
    index: true
  },
  completed_at: Date,
  ip_address: String,
  user_agent: String,
  metadata: mongoose.Schema.Types.Mixed
}

// TTL index
AccountLinkingSessionSchema.index({ expires_at: 1 }, { expireAfterSeconds: 0 });

// Compound indexes
AccountLinkingSessionSchema.index({ user_id: 1, status: 1 });
AccountLinkingSessionSchema.index({ session_id: 1, status: 1 });
```

**Purpose**: This model enforces that linking operations:
1. Are time-limited (5-10 minutes)
2. Require recent verification
3. Can be audited
4. Prevent replay attacks

---

### B.1.5 Updated Onboarding_Status Schema

**Current schema is good**, but ensure:

**Field Updates**:
```javascript
// Already has:
// - mobile_verified, google_verified, apple_verified
// - current_step (includes 'mobile_verification', 'google_verification', 'apple_verification')

// Add new field for completion requirements:
verification_requirements: {
  mobile_required: {
    type: Boolean,
    default: true // Mobile always required
  },
  google_recommended: {
    type: Boolean,
    default: true // Recommended but not required
  },
  apple_recommended: {
    type: Boolean,
    default: true
  },
  // Used to determine which prompts to show
},

// Track dismissal of prompts
dismissed_prompts: [{
  prompt_type: {
    type: String,
    enum: ['mobile_verification', 'google_linking', 'apple_linking']
  },
  dismissed_at: Date,
  dismiss_count: {
    type: Number,
    default: 1
  },
  remind_after: Date // If user clicks "Remind me later"
}]
```

**Helper Methods**:
```javascript
OnboardingStatusSchema.methods.shouldShowPrompt = function(promptType) {
  const dismissed = this.dismissed_prompts.find(p => p.prompt_type === promptType);
  
  if (!dismissed) return true; // Never dismissed
  
  if (dismissed.dismiss_count >= 3) return false; // Dismissed too many times
  
  if (dismissed.remind_after && dismissed.remind_after > new Date()) {
    return false; // Reminder not yet due
  }
  
  return true;
};

OnboardingStatusSchema.methods.dismissPrompt = function(promptType, remindInDays = null) {
  let dismissed = this.dismissed_prompts.find(p => p.prompt_type === promptType);
  
  if (dismissed) {
    dismissed.dismiss_count += 1;
    dismissed.dismissed_at = new Date();
    if (remindInDays) {
      dismissed.remind_after = new Date(Date.now() + remindInDays * 24 * 60 * 60 * 1000);
    }
  } else {
    this.dismissed_prompts.push({
      prompt_type: promptType,
      dismissed_at: new Date(),
      dismiss_count: 1,
      remind_after: remindInDays ? new Date(Date.now() + remindInDays * 24 * 60 * 60 * 1000) : null
    });
  }
};
```

---

### B.1.6 Migration Strategy for Existing Data

**Step 1: Add New Fields**
- Run migration script to add new fields to `System_User` with default values
- Update indexes (non-blocking operations)

**Step 2: Backfill Data**
```javascript
// Migration script pseudocode
async function migrateExistingUsers() {
  const systemUsers = await System_User.find({});
  
  for (const su of systemUsers) {
    // Populate linked_providers based on existing fields
    const providers = [];
    if (su.google_id) providers.push('google');
    if (su.apple_id) providers.push('apple');
    if (su.password) providers.push('email');
    
    su.linked_providers = providers;
    su.email_lower = su.email.toLowerCase();
    
    // Set verification flags
    if (su.google_id) {
      su.email_verified = true; // Google emails are verified
      su.email_verified_at = su.created_at;
    }
    
    // Lookup User model for mobile
    const user = await User.findById(su.user_id);
    if (user && user.mobile) {
      su.phone_e164 = user.getMobileE164(); // Use helper method
      su.mobile_verified = true;
      su.mobile_verified_at = user.created_at;
    }
    
    await su.save();
  }
}
```

**Step 3: Verify**
- Run validation queries to ensure no data loss
- Check that all users have `linked_providers` populated correctly

---

### B.1.7 Uniqueness Constraints Strategy

**Challenge**: Prevent duplicates while allowing partial users (Google user without phone, mobile user without email)

**Solution**:
1. **Mobile**: Unique in `User` model (already enforced)
2. **Email**: Unique in `System_User` model (already enforced)
3. **Google ID**: Unique sparse index in `System_User` (already exists)
4. **Apple ID**: Unique sparse index in `System_User` (already exists)
5. **Phone + Provider Combo**: Enforced via application logic (conflict resolution rules)

**Sparse Indexes** allow multiple `null` values, so users without Google ID can coexist.

**Application-Level Uniqueness Checks**:
- Before creating user via mobile OTP: Check if mobile exists in `User`
- Before creating user via Google: Check if `google_id` OR `email` exists in `System_User`
- Before creating user via Apple: Check if `apple_id` OR `email` (if not private relay) exists in `System_User`
- During linking: Check if provider ID already linked to another user

---




