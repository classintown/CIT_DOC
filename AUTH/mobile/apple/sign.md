# 🍎 React Native Apple Sign-In Implementation Guide

**For Frontend Developer**  
**Date:** December 2024

---

## 📋 Overview

This guide explains how to implement Apple Sign-In in React Native with **mobile verification** (same flow as web).

**Key Difference from Web:**
- Web: Browser redirects to Apple → Backend redirects to verification page
- Mobile: Native Apple Sign-In SDK → Your app handles verification flow

---

## 🔄 Complete Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│ 1. USER CLICKS "SIGN IN WITH APPLE"                        │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. REACT NATIVE: Call Apple Sign-In SDK                    │
│    - Use @react-native-apple-authentication               │
│    - Get idToken, authorizationCode, user (name)           │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. SEND TO BACKEND: POST /auths/apple/mobile               │
│    Body: { idToken, authorizationCode, user }             │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
         ┌───────────┴───────────┐
         │                       │
         ▼                       ▼
    ┌─────────┐           ┌──────────────┐
    │ EXISTING│           │  NEW USER    │
    │  USER   │           │              │
    └────┬────┘           └──────┬───────┘
         │                       │
         │                       ▼
         │              ┌─────────────────────┐
         │              │ BACKEND RESPONSE:   │
         │              │ {                  │
         │              │   status: "success"│
         │              │   data: {          │
         │              │     user: {...},  │
         │              │     accessToken,   │
         │              │     refreshToken   │
         │              │   }               │
         │              │ }                 │
         │              └──────┬────────────┘
         │                     │
         │                     ▼
         │              ┌─────────────────────┐
         │              │ OR (NEW USER):      │
         │              │ {                  │
         │              │   status: "pending" │
         │              │   requiresMobile:   │
         │              │     true,           │
         │              │   session_id: "...",│
         │              │   email: "..."      │
         │              │ }                 │
         │              └──────┬────────────┘
         │                     │
         │                     ▼
         │              ┌─────────────────────┐
         │              │ SHOW MOBILE         │
         │              │ VERIFICATION SCREEN │
         │              │ - Enter mobile      │
         │              │ - Send OTP          │
         │              │ - Verify OTP        │
         │              └──────┬────────────┘
         │                     │
         │                     ▼
         │              ┌─────────────────────┐
         │              │ POST /auths/otp/    │
         │              │ mobile/verify       │
         │              │ { mobile, otp }     │
         │              └──────┬────────────┘
         │                     │
         │                     ▼
         │              ┌─────────────────────┐
         │              │ POST /auths/apple/  │
         │              │ complete-signup      │
         │              │ {                   │
         │              │   session_id,       │
         │              │   mobile,           │
         │              │   countryCode        │
         │              │ }                   │
         │              └──────┬────────────┘
         │                     │
         └─────────────────────┴───────┐
                                       │
                                       ▼
                            ┌─────────────────────┐
                            │ SUCCESS:            │
                            │ - Store tokens      │
                            │ - Navigate to app   │
                            └─────────────────────┘
```

---

## 📦 Step-by-Step Implementation

### **STEP 1: Install Dependencies**

```bash
npm install @react-native-apple-authentication
# or
yarn add @react-native-apple-authentication

# For iOS, also run:
cd ios && pod install
```

---

### **STEP 2: Configure Apple Sign-In in Xcode**

1. Open your project in Xcode
2. Go to **Signing & Capabilities**
3. Click **+ Capability**
4. Add **Sign in with Apple**
5. Ensure your **Bundle ID** matches `APPLE_IOS_CLIENT_ID` in backend config

---

### **STEP 3: Create Apple Sign-In Service**

**File:** `src/services/auth/appleAuthService.ts`

```typescript
import appleAuth from '@react-native-apple-authentication/apple-auth';
import { Platform } from 'react-native';
import { API_BASE_URL } from '../config';

interface AppleSignInResult {
  idToken: string;
  authorizationCode: string | null;
  user: {
    name?: {
      firstName?: string;
      lastName?: string;
    };
  } | null;
}

interface BackendResponse {
  status: 'success' | 'pending';
  data?: {
    user: any;
    accessToken: string;
    refreshToken: string;
  };
  requiresMobile?: boolean;
  session_id?: string;
  email?: string;
  message?: string;
}

class AppleAuthService {
  private apiUrl = `${API_BASE_URL}/auths`;

  /**
   * Step 1: Initiate Apple Sign-In
   * Returns idToken, authorizationCode, and user info (name only on first sign-in)
   */
  async signInWithApple(): Promise<AppleSignInResult> {
    try {
      if (Platform.OS !== 'ios') {
        throw new Error('Apple Sign-In is only available on iOS');
      }

      const appleAuthRequestResponse = await appleAuth.performRequest({
        requestedOperation: appleAuth.Operation.LOGIN,
        requestedScopes: [appleAuth.Scope.EMAIL, appleAuth.Scope.FULL_NAME],
      });

      // Check if user cancelled
      if (!appleAuthRequestResponse.identityToken) {
        throw new Error('Apple Sign-In was cancelled');
      }

      const { identityToken, authorizationCode, user } = appleAuthRequestResponse;

      // Extract name (only available on first sign-in)
      const userInfo = user ? {
        name: {
          firstName: user.givenName || undefined,
          lastName: user.familyName || undefined,
        }
      } : null;

      return {
        idToken: identityToken,
        authorizationCode: authorizationCode || null,
        user: userInfo,
      };
    } catch (error: any) {
      if (error.code === appleAuth.Error.CANCELED) {
        throw new Error('Apple Sign-In was cancelled by user');
      }
      throw error;
    }
  }

  /**
   * Step 2: Send Apple credentials to backend
   * Returns either:
   * - Success with tokens (existing user)
   * - Pending with session_id (new user needs mobile verification)
   */
  async sendAppleCredentialsToBackend(
    idToken: string,
    authorizationCode: string | null,
    user: any
  ): Promise<BackendResponse> {
    try {
      const response = await fetch(`${this.apiUrl}/apple/mobile`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          idToken,
          authorizationCode,
          user,
        }),
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.error || data.message || 'Apple Sign-In failed');
      }

      return data;
    } catch (error: any) {
      throw new Error(`Backend request failed: ${error.message}`);
    }
  }

  /**
   * Step 3: Complete signup after mobile verification
   * Called after user verifies mobile number with OTP
   */
  async completeSignup(
    sessionId: string,
    mobile: string,
    countryCode: string = '+91'
  ): Promise<BackendResponse> {
    try {
      const response = await fetch(`${this.apiUrl}/apple/complete-signup`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          session_id: sessionId,
          mobile,
          countryCode,
        }),
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.error || data.message || 'Failed to complete signup');
      }

      return data;
    } catch (error: any) {
      throw new Error(`Complete signup failed: ${error.message}`);
    }
  }
}

export default new AppleAuthService();
```

---

### **STEP 4: Create Mobile Verification Service**

**File:** `src/services/auth/mobileVerificationService.ts`

```typescript
import { API_BASE_URL } from '../config';

interface SendOtpResponse {
  success: boolean;
  message: string;
  data?: {
    mobile: string;
    expiresIn: number;
  };
}

interface VerifyOtpResponse {
  success: boolean;
  message: string;
  data?: {
    mobile: string;
    isVerified: boolean;
  };
}

class MobileVerificationService {
  private apiUrl = `${API_BASE_URL}/auths`;

  /**
   * Send OTP to mobile number
   */
  async sendOtp(mobile: string, countryCode: string = '+91'): Promise<SendOtpResponse> {
    try {
      // Format mobile: remove spaces, ensure country code
      const formattedMobile = this.formatMobile(mobile, countryCode);

      const response = await fetch(`${this.apiUrl}/otp/mobile`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          mobile: formattedMobile,
          purpose: 'registration',
        }),
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.error || data.message || 'Failed to send OTP');
      }

      return data;
    } catch (error: any) {
      throw new Error(`Send OTP failed: ${error.message}`);
    }
  }

  /**
   * Verify OTP
   */
  async verifyOtp(mobile: string, otp: string, countryCode: string = '+91'): Promise<VerifyOtpResponse> {
    try {
      const formattedMobile = this.formatMobile(mobile, countryCode);

      const response = await fetch(`${this.apiUrl}/otp/mobile/verify`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          mobile: formattedMobile,
          otp,
        }),
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.error || data.message || 'OTP verification failed');
      }

      return data;
    } catch (error: any) {
      throw new Error(`Verify OTP failed: ${error.message}`);
    }
  }

  /**
   * Format mobile number with country code
   */
  private formatMobile(mobile: string, countryCode: string): string {
    // Remove all non-digit characters
    const digits = mobile.replace(/\D/g, '');
    
    // Remove leading zeros
    const cleanMobile = digits.replace(/^0+/, '');
    
    // Ensure country code has +
    const cc = countryCode.startsWith('+') ? countryCode : `+${countryCode}`;
    
    // Return E.164 format
    return `${cc}${cleanMobile}`;
  }
}

export default new MobileVerificationService();
```

---

### **STEP 5: Create Sign-In Screen Component**

**File:** `src/screens/auth/AppleSignInScreen.tsx`

```typescript
import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  ActivityIndicator,
  Alert,
  StyleSheet,
} from 'react-native';
import appleAuthService from '../../services/auth/appleAuthService';
import mobileVerificationService from '../../services/auth/mobileVerificationService';
import { useNavigation } from '@react-navigation/native';

type SignInStep = 'initial' | 'mobile-verification' | 'otp-verification' | 'loading';

const AppleSignInScreen: React.FC = () => {
  const navigation = useNavigation();
  const [step, setStep] = useState<SignInStep>('initial');
  const [loading, setLoading] = useState(false);
  
  // Mobile verification state
  const [mobile, setMobile] = useState('');
  const [countryCode, setCountryCode] = useState('+91');
  const [otp, setOtp] = useState('');
  const [sessionId, setSessionId] = useState<string | null>(null);
  const [email, setEmail] = useState<string | null>(null);

  /**
   * STEP 1: Handle Apple Sign-In button press
   */
  const handleAppleSignIn = async () => {
    try {
      setLoading(true);

      // Step 1: Get Apple credentials
      const appleCredentials = await appleAuthService.signInWithApple();
      console.log('✅ Apple Sign-In successful');

      // Step 2: Send to backend
      const backendResponse = await appleAuthService.sendAppleCredentialsToBackend(
        appleCredentials.idToken,
        appleCredentials.authorizationCode,
        appleCredentials.user
      );

      console.log('📥 Backend response:', backendResponse);

      // Check if user exists or needs mobile verification
      if (backendResponse.status === 'success' && backendResponse.data) {
        // ✅ EXISTING USER - Sign in complete
        await handleSignInSuccess(backendResponse.data);
      } else if (backendResponse.requiresMobile && backendResponse.session_id) {
        // ⚠️ NEW USER - Mobile verification required
        setSessionId(backendResponse.session_id);
        setEmail(backendResponse.email || null);
        setStep('mobile-verification');
        Alert.alert(
          'Mobile Verification Required',
          'Please verify your mobile number to complete sign-up.'
        );
      } else {
        throw new Error('Unexpected response from backend');
      }
    } catch (error: any) {
      console.error('❌ Apple Sign-In error:', error);
      Alert.alert('Error', error.message || 'Apple Sign-In failed');
    } finally {
      setLoading(false);
    }
  };

  /**
   * STEP 2: Send OTP to mobile
   */
  const handleSendOtp = async () => {
    try {
      if (!mobile.trim()) {
        Alert.alert('Error', 'Please enter your mobile number');
        return;
      }

      setLoading(true);
      await mobileVerificationService.sendOtp(mobile, countryCode);
      
      Alert.alert('Success', 'OTP sent to your mobile number');
      setStep('otp-verification');
    } catch (error: any) {
      Alert.alert('Error', error.message || 'Failed to send OTP');
    } finally {
      setLoading(false);
    }
  };

  /**
   * STEP 3: Verify OTP and complete signup
   */
  const handleVerifyOtp = async () => {
    try {
      if (!otp.trim()) {
        Alert.alert('Error', 'Please enter the OTP');
        return;
      }

      if (!sessionId) {
        Alert.alert('Error', 'Session expired. Please sign in again.');
        setStep('initial');
        return;
      }

      setLoading(true);

      // Step 1: Verify OTP
      await mobileVerificationService.verifyOtp(mobile, otp, countryCode);
      console.log('✅ OTP verified');

      // Step 2: Complete Apple signup
      const completeResponse = await appleAuthService.completeSignup(
        sessionId,
        mobile,
        countryCode
      );

      console.log('✅ Signup completed:', completeResponse);

      if (completeResponse.status === 'success' && completeResponse.data) {
        await handleSignInSuccess(completeResponse.data);
      } else {
        throw new Error('Failed to complete signup');
      }
    } catch (error: any) {
      Alert.alert('Error', error.message || 'OTP verification failed');
    } finally {
      setLoading(false);
    }
  };

  /**
   * Handle successful sign-in
   * Store tokens and navigate to main app
   */
  const handleSignInSuccess = async (data: {
    user: any;
    accessToken: string;
    refreshToken: string;
  }) => {
    try {
      // Store tokens (use your preferred storage method)
      // Example: AsyncStorage, SecureStore, or Redux
      await AsyncStorage.setItem('accessToken', data.accessToken);
      await AsyncStorage.setItem('refreshToken', data.refreshToken);
      await AsyncStorage.setItem('user', JSON.stringify(data.user));

      // Navigate to main app
      navigation.reset({
        index: 0,
        routes: [{ name: 'Home' }],
      });
    } catch (error) {
      console.error('Failed to store tokens:', error);
      Alert.alert('Error', 'Failed to save login information');
    }
  };

  // Render based on current step
  if (step === 'initial') {
    return (
      <View style={styles.container}>
        <Text style={styles.title}>Sign In with Apple</Text>
        
        <TouchableOpacity
          style={styles.appleButton}
          onPress={handleAppleSignIn}
          disabled={loading}
        >
          {loading ? (
            <ActivityIndicator color="#fff" />
          ) : (
            <Text style={styles.appleButtonText}>🍎 Sign In with Apple</Text>
          )}
        </TouchableOpacity>
      </View>
    );
  }

  if (step === 'mobile-verification') {
    return (
      <View style={styles.container}>
        <Text style={styles.title}>Verify Mobile Number</Text>
        {email && <Text style={styles.subtitle}>Email: {email}</Text>}
        
        <View style={styles.inputContainer}>
          <TextInput
            style={styles.countryCodeInput}
            value={countryCode}
            onChangeText={setCountryCode}
            placeholder="+91"
            keyboardType="phone-pad"
          />
          <TextInput
            style={styles.mobileInput}
            value={mobile}
            onChangeText={setMobile}
            placeholder="Enter mobile number"
            keyboardType="phone-pad"
          />
        </View>

        <TouchableOpacity
          style={styles.button}
          onPress={handleSendOtp}
          disabled={loading}
        >
          {loading ? (
            <ActivityIndicator color="#fff" />
          ) : (
            <Text style={styles.buttonText}>Send OTP</Text>
          )}
        </TouchableOpacity>
      </View>
    );
  }

  if (step === 'otp-verification') {
    return (
      <View style={styles.container}>
        <Text style={styles.title}>Enter OTP</Text>
        <Text style={styles.subtitle}>Sent to {countryCode} {mobile}</Text>
        
        <TextInput
          style={styles.otpInput}
          value={otp}
          onChangeText={setOtp}
          placeholder="Enter 6-digit OTP"
          keyboardType="number-pad"
          maxLength={6}
        />

        <TouchableOpacity
          style={styles.button}
          onPress={handleVerifyOtp}
          disabled={loading}
        >
          {loading ? (
            <ActivityIndicator color="#fff" />
          ) : (
            <Text style={styles.buttonText}>Verify OTP</Text>
          )}
        </TouchableOpacity>

        <TouchableOpacity
          style={styles.resendButton}
          onPress={handleSendOtp}
          disabled={loading}
        >
          <Text style={styles.resendText}>Resend OTP</Text>
        </TouchableOpacity>
      </View>
    );
  }

  return null;
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 20,
    justifyContent: 'center',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 20,
    textAlign: 'center',
  },
  subtitle: {
    fontSize: 14,
    color: '#666',
    marginBottom: 20,
    textAlign: 'center',
  },
  appleButton: {
    backgroundColor: '#000',
    padding: 15,
    borderRadius: 8,
    alignItems: 'center',
  },
  appleButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
  inputContainer: {
    flexDirection: 'row',
    marginBottom: 20,
  },
  countryCodeInput: {
    flex: 1,
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    padding: 12,
    marginRight: 10,
  },
  mobileInput: {
    flex: 3,
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    padding: 12,
  },
  otpInput: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    padding: 12,
    marginBottom: 20,
    fontSize: 18,
    textAlign: 'center',
  },
  button: {
    backgroundColor: '#007AFF',
    padding: 15,
    borderRadius: 8,
    alignItems: 'center',
    marginBottom: 10,
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
  resendButton: {
    padding: 10,
    alignItems: 'center',
  },
  resendText: {
    color: '#007AFF',
    fontSize: 14,
  },
});

export default AppleSignInScreen;
```

---

## 🔄 Backend API Endpoints

### **1. Apple Mobile Sign-In**
```
POST /api/v1/auths/apple/mobile
Body: {
  "idToken": "string",
  "authorizationCode": "string | null",
  "user": {
    "name": {
      "firstName": "string",
      "lastName": "string"
    }
  } | null
}

Response (Existing User):
{
  "status": "success",
  "data": {
    "user": {...},
    "accessToken": "string",
    "refreshToken": "string"
  }
}

Response (New User):
{
  "status": "pending",
  "requiresMobile": true,
  "session_id": "string",
  "email": "string"
}
```

### **2. Send Mobile OTP**
```
POST /api/v1/auths/otp/mobile
Body: {
  "mobile": "+919876543210",
  "purpose": "registration"
}
```

### **3. Verify Mobile OTP**
```
POST /api/v1/auths/otp/mobile/verify
Body: {
  "mobile": "+919876543210",
  "otp": "123456"
}
```

### **4. Complete Apple Signup**
```
POST /api/v1/auths/apple/complete-signup
Body: {
  "session_id": "string",
  "mobile": "9876543210",
  "countryCode": "+91"
}

Response:
{
  "status": "success",
  "data": {
    "user": {...},
    "accessToken": "string",
    "refreshToken": "string"
  }
}
```

---

## ✅ Testing Checklist

- [ ] Apple Sign-In button works
- [ ] Existing user signs in directly (no mobile verification)
- [ ] New user sees mobile verification screen
- [ ] OTP is sent successfully
- [ ] OTP verification works
- [ ] Signup completes and user is logged in
- [ ] Tokens are stored securely
- [ ] User navigates to main app after sign-in

---

## 🐛 Common Issues

### **Issue 1: "Apple Sign-In is only available on iOS"**
- **Solution:** This is expected. Apple Sign-In only works on iOS devices.

### **Issue 2: "Session expired"**
- **Solution:** OAuth sessions expire after 30 minutes. User needs to sign in again.

### **Issue 3: "Mobile not verified"**
- **Solution:** Ensure OTP is verified before calling `complete-signup`.

### **Issue 4: "OTP verification failed"**
- **Solution:** Check mobile number format (E.164: +919876543210).

---

## 📝 Notes

1. **Name Only on First Sign-In:** Apple only provides user name on the first sign-in. Store it if needed.

2. **Private Relay Email:** Apple may provide a relay email. Backend handles this automatically.

3. **Session Expiry:** OAuth sessions expire after 30 minutes. Handle this gracefully.

4. **Token Storage:** Use secure storage (e.g., `react-native-keychain` or `@react-native-async-storage/async-storage`).

5. **Error Handling:** Always show user-friendly error messages.

---

## 🔗 Related Files

- Backend: `backend/controllers/auth/auth.controller.js` → `mobileAppleSignIn`
- Backend: `backend/controllers/auth/auth.controller.js` → `completeAppleSignup`
- Backend Routes: `backend/routes/auth.routes.js`

---

**Need Help?** Contact backend team for API issues or check backend logs for detailed error messages.

