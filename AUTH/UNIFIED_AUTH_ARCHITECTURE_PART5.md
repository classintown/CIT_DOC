# PART C: FRONTEND UX (ANGULAR) PLAN

## C.1 New Components & Screens

### C.1.1 Account Linking Banner Component (NEW)

**Component**: `<app-account-linking-banner>`  
**Location**: `frontend/src/app/shared/common-components/account-linking-banner/`  
**Purpose**: Show persistent warning banner for missing verifications  
**Placement**: On dashboard, profile page (after successful login)

**Props**:
```typescript
@Input() missingVerifications: {
  mobile: boolean;
  google: boolean;
  apple: boolean;
};
@Input() dismissibleConfig: {
  mobile: boolean; // false = required, can't dismiss
  google: boolean; // true = optional, can dismiss
  apple: boolean;  // true = optional, can dismiss
};
@Output() onLinkProvider: EventEmitter<'mobile' | 'google' | 'apple'>;
@Output() onDismiss: EventEmitter<{
  provider: string;
  remindInDays: number | null;
}>;
```

**Template** (Pseudocode):
```html
<!-- Mobile Verification (Required) -->
<div *ngIf="missingVerifications.mobile" class="banner banner-error">
  <mat-icon>warning</mat-icon>
  <span>Verify your mobile number to secure your account</span>
  <button (click)="onLinkProvider.emit('mobile')">Verify Now</button>
  <button *ngIf="dismissibleConfig.mobile && dismissCount < 3" 
          (click)="onDismiss.emit({ provider: 'mobile', remindInDays: 7 })">
    Remind me later
  </button>
</div>

<!-- Google Linking (Recommended) -->
<div *ngIf="missingVerifications.google" class="banner banner-info">
  <mat-icon>info</mat-icon>
  <span>Connect your Google account for email & calendar integration</span>
  <button (click)="onLinkProvider.emit('google')">Connect Google</button>
  <button (click)="onDismiss.emit({ provider: 'google', remindInDays: null })">
    Dismiss
  </button>
</div>

<!-- Apple Linking (Optional) -->
<div *ngIf="missingVerifications.apple" class="banner banner-info">
  <mat-icon>info</mat-icon>
  <span>Connect your Apple account for seamless sign-in</span>
  <button (click)="onLinkProvider.emit('apple')">Connect Apple</button>
  <button (click)="onDismiss.emit({ provider: 'apple', remindInDays: null })">
    Dismiss
  </button>
</div>
```

**Logic**:
```typescript
export class AccountLinkingBannerComponent implements OnInit {
  @Input() missingVerifications: any;
  @Input() dismissibleConfig: any;
  @Output() onLinkProvider = new EventEmitter<string>();
  @Output() onDismiss = new EventEmitter<any>();

  dismissCount = 0; // Track from backend

  ngOnInit() {
    // Fetch dismiss count from onboardingStatus
    this.dismissCount = this.getProviderDismissCount();
  }

  handleLinkProvider(provider: string) {
    // Emit to parent → Parent calls linking service
    this.onLinkProvider.emit(provider);
  }

  handleDismiss(data: any) {
    // Call backend to dismiss
    this.onDismiss.emit(data);
  }
}
```

---

### C.1.2 Mobile Linking Modal Component (NEW)

**Component**: `<app-mobile-linking-modal>`  
**Location**: `frontend/src/app/shared/common-components/mobile-linking-modal/`  
**Purpose**: Modal for linking mobile number to Google/Apple users  
**Triggered by**: Account linking banner or settings page

**Props**:
```typescript
@Input() isVisible: boolean;
@Output() onClose: EventEmitter<void>;
@Output() onSuccess: EventEmitter<{ mobile: string }>;
```

**Template**:
```html
<mat-dialog *ngIf="isVisible">
  <h2>Verify Mobile Number</h2>
  
  <!-- Step 1: Enter Mobile -->
  <div *ngIf="step === 'enter_mobile'">
    <mat-form-field>
      <mat-label>Country Code</mat-label>
      <mat-select [(ngModel)]="countryCode">
        <mat-option value="+91">+91 (India)</mat-option>
        <mat-option value="+1">+1 (US)</mat-option>
        <!-- More options -->
      </mat-select>
    </mat-form-field>
    
    <mat-form-field>
      <mat-label>Mobile Number</mat-label>
      <input matInput [(ngModel)]="mobile" placeholder="9876543210" />
    </mat-form-field>
    
    <button mat-raised-button color="primary" (click)="sendOtp()">
      Send OTP
    </button>
    <button mat-button (click)="onClose.emit()">Cancel</button>
  </div>
  
  <!-- Step 2: Verify OTP -->
  <div *ngIf="step === 'verify_otp'">
    <p>OTP sent to {{ countryCode }} {{ mobile }}</p>
    
    <mat-form-field>
      <mat-label>Enter OTP</mat-label>
      <input matInput [(ngModel)]="otp" maxlength="6" />
    </mat-form-field>
    
    <button mat-raised-button color="primary" (click)="verifyOtp()">
      Verify
    </button>
    <button mat-button (click)="resendOtp()">Resend OTP</button>
  </div>
  
  <!-- Step 3: Success -->
  <div *ngIf="step === 'success'">
    <mat-icon color="success">check_circle</mat-icon>
    <p>Mobile number verified successfully!</p>
    <button mat-raised-button (click)="onSuccess.emit({ mobile })">
      Done
    </button>
  </div>
</mat-dialog>
```

**Logic**:
```typescript
export class MobileLinkingModalComponent {
  step: 'enter_mobile' | 'verify_otp' | 'success' = 'enter_mobile';
  countryCode = '+91';
  mobile = '';
  otp = '';

  constructor(
    private authService: AuthService,
    private accountLinkingService: AccountLinkingService
  ) {}

  async sendOtp() {
    try {
      await this.accountLinkingService.startMobileLinking(this.mobile, this.countryCode);
      this.step = 'verify_otp';
    } catch (error) {
      // Show error toast
    }
  }

  async verifyOtp() {
    try {
      await this.accountLinkingService.verifyMobileLinking(this.mobile, this.otp, this.countryCode);
      this.step = 'success';
    } catch (error) {
      // Show error toast
    }
  }

  resendOtp() {
    this.sendOtp();
  }
}
```

---

### C.1.3 Account Settings / Profile Enhancement

**Component**: Enhance existing profile components (Instructor, Student, Institute)  
**Add Section**: "Connected Accounts"

**Template Addition**:
```html
<mat-card>
  <mat-card-header>
    <mat-card-title>Connected Accounts</mat-card-title>
  </mat-card-header>
  
  <mat-card-content>
    <!-- Mobile -->
    <div class="provider-row">
      <mat-icon [class.connected]="providerStatus.hasMobile">phone</mat-icon>
      <span>Mobile Number</span>
      <span *ngIf="providerStatus.hasMobile" class="status-badge connected">
        ✓ {{ user.mobile }}
      </span>
      <button *ngIf="!providerStatus.hasMobile" 
              mat-stroked-button 
              (click)="linkMobile()">
        Verify Mobile
      </button>
      <button *ngIf="providerStatus.hasMobile && canUnlink('mobile')" 
              mat-stroked-button 
              (click)="unlinkProvider('mobile')">
        Disconnect
      </button>
    </div>
    
    <!-- Google -->
    <div class="provider-row">
      <mat-icon [class.connected]="providerStatus.hasGoogle">mail</mat-icon>
      <span>Google Account</span>
      <span *ngIf="providerStatus.hasGoogle" class="status-badge connected">
        ✓ Connected
      </span>
      <button *ngIf="!providerStatus.hasGoogle" 
              mat-stroked-button 
              (click)="linkGoogle()">
        Connect Google
      </button>
      <button *ngIf="providerStatus.hasGoogle && canUnlink('google')" 
              mat-stroked-button 
              (click)="unlinkProvider('google')">
        Disconnect
      </button>
    </div>
    
    <!-- Apple -->
    <div class="provider-row">
      <mat-icon [class.connected]="providerStatus.hasApple">apple</mat-icon>
      <span>Apple Account</span>
      <span *ngIf="providerStatus.hasApple" class="status-badge connected">
        ✓ Connected
      </span>
      <button *ngIf="!providerStatus.hasApple" 
              mat-stroked-button 
              (click)="linkApple()">
        Connect Apple
      </button>
      <button *ngIf="providerStatus.hasApple && canUnlink('apple')" 
              mat-stroked-button 
              (click)="unlinkProvider('apple')">
        Disconnect
      </button>
    </div>
  </mat-card-content>
</mat-card>
```

**Logic**:
```typescript
export class ProfileComponent implements OnInit {
  providerStatus: any;
  user: any;

  constructor(
    private accountLinkingService: AccountLinkingService,
    private userService: UserService
  ) {}

  ngOnInit() {
    this.loadAccountStatus();
  }

  async loadAccountStatus() {
    const status = await this.accountLinkingService.getAccountStatus();
    this.providerStatus = status.providerStatus;
    this.user = status.user;
  }

  linkMobile() {
    // Open mobile linking modal
    this.showMobileLinkingModal = true;
  }

  linkGoogle() {
    this.accountLinkingService.initiateGoogleLinking();
  }

  linkApple() {
    this.accountLinkingService.initiateAppleLinking();
  }

  canUnlink(provider: string): boolean {
    // Can't unlink if it's the only auth method
    return this.providerStatus.linkedProviders.length > 1;
  }

  async unlinkProvider(provider: string) {
    const confirmed = confirm(`Are you sure you want to disconnect your ${provider} account?`);
    if (confirmed) {
      await this.accountLinkingService.unlinkProvider(provider);
      this.loadAccountStatus(); // Refresh
    }
  }
}
```

---

## C.2 New Services

### C.2.1 AccountLinkingService (NEW)

**Location**: `frontend/src/app/services/common/auth/account-linking.service.ts`

**Purpose**: Handle all account linking operations

**Methods**:
```typescript
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { firstValueFrom } from 'rxjs';
import { environment } from 'src/environments/environment';

@Injectable({
  providedIn: 'root'
})
export class AccountLinkingService {
  private apiUrl = environment.apiUrl;

  constructor(private http: HttpClient) {}

  // ===== Get Account Status =====
  async getAccountStatus(): Promise<any> {
    return firstValueFrom(
      this.http.get(`${this.apiUrl}/auths/account-status`)
    );
  }

  // ===== Google Linking =====
  async initiateGoogleLinking(): Promise<void> {
    const response: any = await firstValueFrom(
      this.http.get(`${this.apiUrl}/auths/link-google-oauth`)
    );
    // Redirect to Google OAuth
    window.location.href = response.data.authUrl;
  }

  async disconnectGoogle(): Promise<any> {
    return firstValueFrom(
      this.http.post(`${this.apiUrl}/auths/disconnect-google`, {})
    );
  }

  // ===== Apple Linking =====
  async initiateAppleLinking(): Promise<void> {
    const response: any = await firstValueFrom(
      this.http.get(`${this.apiUrl}/auths/link-apple-oauth`)
    );
    // Redirect to Apple OAuth
    window.location.href = response.data.authUrl;
  }

  async disconnectApple(): Promise<any> {
    return firstValueFrom(
      this.http.post(`${this.apiUrl}/auths/disconnect-apple`, {})
    );
  }

  // ===== Mobile Linking =====
  async startMobileLinking(mobile: string, countryCode: string): Promise<any> {
    return firstValueFrom(
      this.http.post(`${this.apiUrl}/auths/link/mobile/start`, {
        mobile,
        countryCode
      })
    );
  }

  async verifyMobileLinking(mobile: string, otp: string, countryCode: string): Promise<any> {
    return firstValueFrom(
      this.http.post(`${this.apiUrl}/auths/link/mobile/verify`, {
        mobile,
        otp,
        countryCode
      })
    );
  }

  // ===== Generic Unlink =====
  async unlinkProvider(provider: 'google' | 'apple' | 'mobile'): Promise<any> {
    const endpoints = {
      google: '/auths/disconnect-google',
      apple: '/auths/disconnect-apple',
      mobile: '/auths/unlink/mobile'
    };
    
    return firstValueFrom(
      this.http.post(`${this.apiUrl}${endpoints[provider]}`, {})
    );
  }

  // ===== Dismiss Prompts =====
  async dismissPrompt(promptType: string, remindInDays: number | null): Promise<any> {
    return firstValueFrom(
      this.http.post(`${this.apiUrl}/auths/dismiss-prompt`, {
        promptType,
        remindInDays
      })
    );
  }
}
```

---

### C.2.2 Enhance AuthService

**Changes to** `frontend/src/app/services/common/auth/auth.service.ts`:

**Add Method**:
```typescript
// NEW: Store onboarding status
setOnboardingStatus(status: any): void {
  localStorage.setItem('onboardingStatus', JSON.stringify(status));
}

// NEW: Get onboarding status
getOnboardingStatus(): any {
  const stored = localStorage.getItem('onboardingStatus');
  return stored ? JSON.parse(stored) : null;
}

// NEW: Store provider status
setProviderStatus(status: any): void {
  localStorage.setItem('providerStatus', JSON.stringify(status));
}

// NEW: Get provider status
getProviderStatus(): any {
  const stored = localStorage.getItem('providerStatus');
  return stored ? JSON.parse(stored) : null;
}

// NEW: Check if user needs verification
needsVerification(): { mobile: boolean; google: boolean; apple: boolean } {
  const onboarding = this.getOnboardingStatus();
  if (!onboarding) return { mobile: false, google: false, apple: false };
  
  return {
    mobile: !onboarding.mobile_verified,
    google: !onboarding.google_verified,
    apple: !onboarding.apple_verified
  };
}
```

**Modify Existing Method** (`login`, `verifySignInOtp`, etc.):
```typescript
// In login response handler
map(response => {
  // ... existing code ...

  // NEW: Store onboarding and provider status
  if (response?.data?.onboardingStatus) {
    this.setOnboardingStatus(response.data.onboardingStatus);
  }
  if (response?.data?.providerStatus) {
    this.setProviderStatus(response.data.providerStatus);
  }

  return response;
})
```

---

## C.3 Route Guards Enhancement

### C.3.1 VerificationRequiredGuard (NEW)

**Location**: `frontend/src/app/guards/verification-required.guard.ts`

**Purpose**: Block access to sensitive routes if mobile not verified

**Usage**:
```typescript
import { Injectable } from '@angular/core';
import { CanActivate, Router } from '@angular/router';
import { AuthService } from '../services/common/auth/auth.service';

@Injectable({
  providedIn: 'root'
})
export class VerificationRequiredGuard implements CanActivate {
  constructor(
    private authService: AuthService,
    private router: Router
  ) {}

  canActivate(): boolean {
    const needs = this.authService.needsVerification();
    
    if (needs.mobile) {
      // Mobile verification is required for this route
      alert('Please verify your mobile number to access this feature');
      this.router.navigate(['/profile']); // Redirect to profile to complete verification
      return false;
    }
    
    return true; // Mobile verified, allow access
  }
}
```

**Apply to Routes**:
```typescript
// In app-routing.module.ts or feature routing
{
  path: 'instructor/create-class',
  component: CreateClassComponent,
  canActivate: [AuthGuard, VerificationRequiredGuard] // NEW: Add verification guard
}
```

---

## C.4 Dashboard Integration

### Enhance Dashboard Components

**For All Role Dashboards** (Instructor, Student, Institute):

**Add to Template** (after header, before main content):
```html
<app-account-linking-banner
  *ngIf="showLinkingBanner"
  [missingVerifications]="missingVerifications"
  [dismissibleConfig]="dismissibleConfig"
  (onLinkProvider)="handleLinkProvider($event)"
  (onDismiss)="handleDismissPrompt($event)"
></app-account-linking-banner>
```

**Add to Component Logic**:
```typescript
export class InstructorDashboardComponent implements OnInit {
  showLinkingBanner = false;
  missingVerifications = { mobile: false, google: false, apple: false };
  dismissibleConfig = { mobile: false, google: true, apple: true };

  constructor(
    private authService: AuthService,
    private accountLinkingService: AccountLinkingService
  ) {}

  ngOnInit() {
    this.checkAccountStatus();
  }

  async checkAccountStatus() {
    const needs = this.authService.needsVerification();
    this.missingVerifications = needs;
    
    // Show banner if any verification missing
    this.showLinkingBanner = needs.mobile || needs.google || needs.apple;
  }

  handleLinkProvider(provider: string) {
    if (provider === 'mobile') {
      // Open mobile linking modal
      this.showMobileLinkingModal = true;
    } else if (provider === 'google') {
      this.accountLinkingService.initiateGoogleLinking();
    } else if (provider === 'apple') {
      this.accountLinkingService.initiateAppleLinking();
    }
  }

  async handleDismissPrompt(data: { provider: string; remindInDays: number | null }) {
    await this.accountLinkingService.dismissPrompt(
      `${data.provider}_linking`,
      data.remindInDays
    );
    this.checkAccountStatus(); // Refresh
  }
}
```

---

## C.5 Success/Error Callback Pages

### C.5.1 Google Linked Success Page (Enhance Existing)

**Component**: `frontend/src/app/components/auth/google-linked-success/`

**Enhancements**:
- Show success message
- Refresh `UserAuthState`
- Redirect to dashboard after 3 seconds
- Show confetti animation (optional)

### C.5.2 Apple Linked Success Page (NEW)

**Component**: `frontend/src/app/components/auth/apple-linked-success/` (mirror Google)

### C.5.3 Error Pages

**Component**: `frontend/src/app/components/auth/linking-error/`

**Purpose**: Show error when linking fails

**Template**:
```html
<div class="error-container">
  <mat-icon color="warn">error</mat-icon>
  <h2>Account Linking Failed</h2>
  <p>{{ errorMessage }}</p>
  
  <div *ngIf="errorCode === 'already_linked'">
    <p>This account is already linked to another user.</p>
    <button mat-raised-button [routerLink]="['/dashboard']">
      Go to Dashboard
    </button>
  </div>
  
  <div *ngIf="errorCode === 'mobile_conflict'">
    <p>This mobile number is already registered with another account.</p>
    <button mat-raised-button [routerLink]="['/profile']">
      Use Different Number
    </button>
  </div>
  
  <button mat-stroked-button (click)="retry()">Try Again</button>
</div>
```

---




