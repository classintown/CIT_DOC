# Payment Verify Deep Link — Mobile Team Guide

This document is **only for the mobile team**. Backend and nginx are already set up on our side. Your job is to make the app open from the **Verify Payment** email button and complete verification inside the app.

For full backend/nginx details, see [mobile-payment-verify-deeplink.md](./mobile-payment-verify-deeplink.md).

---

## What you are building

When an instructor taps **Verify Payment** in email (or a push notification), the app should:

1. Open (not the mobile browser)
2. Show payment details for that submission
3. Let the instructor confirm verify or reject
4. Call our existing verify API with the instructor’s normal login JWT

---

## Link format (from email)

| Environment | Example |
|---|---|
| Dev | `https://dev.classintown.com/mobile/payments/verify?paymentId=<id>&t=<token>` |
| QA | `https://qa.classintown.com/mobile/payments/verify?paymentId=<id>&t=<token>` |
| Prod | `https://www.classintown.com/mobile/payments/verify?paymentId=<id>&t=<token>` |

| Query param | Required | Notes |
|---|---|---|
| `paymentId` | Yes | MongoDB payment id |
| `t` | Yes (in email) | Short-lived link token. **Not** the session JWT. Expires in ~72 hours. |

**Important:** Use `t` only to validate the link and load context. For the actual verify action, always use the instructor’s stored auth JWT.

---

## App identifiers (must match backend)

| Platform | Value |
|---|---|
| Android package | `com.classintown` |
| iOS bundle ID | `com.classintown` |
| iOS App ID (for Universal Links) | `94DR4VQX3Z.com.classintown` |
| Deep link path | `/mobile/payments/verify*` |

---

## Step 1 — Send us your Android cert fingerprints

We need these to finish `assetlinks.json` on the server. **Please send both:**

1. **Release** SHA-256 fingerprint (Play Store / production signing key)
2. **Debug** SHA-256 fingerprint (local dev builds)

**How to get debug fingerprint (example):**
```bash
keytool -list -v -keystore android/app/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

Copy the `SHA256:` line (format like `AA:BB:CC:...`).

---

## Step 2 — Android App Links

Add HTTPS intent filters to `android/app/src/main/AndroidManifest.xml` on `MainActivity` (keep existing `myapp` scheme filter).

```xml
<!-- Dev -->
<intent-filter android:autoVerify="true">
  <action android:name="android.intent.action.VIEW"/>
  <category android:name="android.intent.category.DEFAULT"/>
  <category android:name="android.intent.category.BROWSABLE"/>
  <data
    android:scheme="https"
    android:host="dev.classintown.com"
    android:pathPrefix="/mobile/payments/verify"/>
</intent-filter>

<!-- Prod -->
<intent-filter android:autoVerify="true">
  <action android:name="android.intent.action.VIEW"/>
  <category android:name="android.intent.category.DEFAULT"/>
  <category android:name="android.intent.category.BROWSABLE"/>
  <data
    android:scheme="https"
    android:host="www.classintown.com"
    android:pathPrefix="/mobile/payments/verify"/>
</intent-filter>
```

Add QA/stage hosts the same way if you test on those environments.

**Verify on device (after our deploy + your fingerprints):**
```bash
adb shell pm get-app-links com.classintown
```
Dev/prod hosts should show `verified`.

---

## Step 3 — iOS Universal Links

Add `associatedDomains` in `app.json` under `expo.ios`:

```json
"ios": {
  "bundleIdentifier": "com.classintown",
  "associatedDomains": [
    "applinks:dev.classintown.com",
    "applinks:qa.classintown.com",
    "applinks:www.classintown.com"
  ]
}
```

Rebuild the native iOS project after this change (`npx expo prebuild` or EAS build).

**Check AASA is live (backend team deploys this):**
```bash
curl -I https://dev.classintown.com/.well-known/apple-app-site-association
```
Expect `200` and `application/json`.

---

## Step 4 — Create the verify screen

Push notifications already target this route:

```
/(instructor)/verifyPayment
```

**Create:** `app/(instructor)/verifyPayment.tsx`

**Screen should accept:**
- `paymentId` (required)
- `t` (from email link; optional if opened from push with JWT already available)

**Suggested UI:**
- Student name, class name, amount, payment method
- Primary button: **Verify payment**
- Secondary: **Reject** (optional for v1)
- Loading and error states (expired link, not authorized, already verified)

---

## Step 5 — Handle incoming links

Use `expo-linking` (already in the project) for:

- Cold start: `Linking.getInitialURL()`
- Foreground: `Linking.addEventListener('url', ...)`

**Parse URL example:**
```
https://dev.classintown.com/mobile/payments/verify?paymentId=507f...&t=eyJ...
```
→ `paymentId` = `507f...`, `t` = `eyJ...`

**Navigate to:**
```
/(instructor)/verifyPayment?paymentId=<id>&t=<token>
```

Also handle push opens: existing code in `services/notifications/notifications.ts` reads `data.screen`. For `payment_submitted_instructor`, payload includes `paymentId` and `verifyLink` — route to the same screen.

---

## Step 6 — API calls

Base URL: `EXPO_PUBLIC_API_BASE_URL` + `/api/v1` (same as rest of app).

### A) Load context (call when screen opens)

```
GET /api/v1/mobile/payments/verify/context?paymentId=<id>&t=<token>
Authorization: Bearer <instructor JWT>
```

**Success (200):**
```json
{
  "success": true,
  "data": {
    "paymentId": "...",
    "authorized": true,
    "studentName": "Arjun Mehta",
    "className": "Yoga Basics",
    "amount": 1500,
    "currency": "INR",
    "status": "awaiting_verification"
  }
}
```

**Errors:**
- `403` — not authorized (wrong instructor or bad token)
- `404` — payment not found
- `410` — link expired (ask instructor to use Payments in app or request new email)

`Authorization` header is optional if `t` is valid, but **recommended** when user is logged in.

### B) Verify payment (on button tap)

```
PATCH /api/v1/enrollment/payments/{paymentId}/verify
Authorization: Bearer <instructor JWT>
Content-Type: application/json

{
  "status": "verified",
  "notes": "Verified from class details"
}
```

To reject:
```json
{
  "status": "rejected",
  "notes": "Amount does not match"
}
```

**Success:** `{ "success": true, "data": { ...payment } }`  
**403:** instructor does not own this payment.

---

## Step 7 — Recommended app flow

```
Email / Push tap
    ↓
Parse paymentId + t
    ↓
User logged in as instructor? ──no──→ Sign in → return to screen
    ↓ yes
GET .../verify/context
    ↓
Show payment summary
    ↓
User taps Verify
    ↓
PATCH .../payments/{id}/verify
    ↓
Show success → navigate back to payments/home
```

---

## Step 8 — Testing checklist

Ask backend team for **one real dev test email** after their deploy.

| # | Test | Pass criteria |
|---|---|---|
| 1 | Tap email on Android (dev build) | App opens, not Chrome |
| 2 | Tap email on iOS (dev build) | App opens, not Safari |
| 3 | Context API | Payment details load |
| 4 | Verify button | Payment status updates to verified |
| 5 | Wrong instructor logged in | 403 / friendly error |
| 6 | Expired `t` (after 72h or tampered) | Clear error message |
| 7 | Push “Payment Submitted — Verify Now” | Opens same verify screen |
| 8 | App not installed | Link opens browser → web Payments page (backend handles this) |

---

## What we need from you (summary)

| # | Action |
|---|---|
| 1 | Send **Android release + debug SHA-256** fingerprints |
| 2 | Add Android App Link intent-filters |
| 3 | Add iOS `associatedDomains` |
| 4 | Implement `/(instructor)/verifyPayment` screen |
| 5 | Wire `expo-linking` + push handler to that screen |
| 6 | Integrate context GET + verify PATCH APIs |
| 7 | Test on real devices with dev test email |
| 8 | Confirm prod build works with `www.classintown.com` links |

---

## What backend will provide you

- Dev test email with a real `paymentId` + `t` link
- This doc + [mobile-payment-verify-deeplink.md](./mobile-payment-verify-deeplink.md)
- Live association files after deploy:
  - `https://dev.classintown.com/.well-known/assetlinks.json`
  - `https://dev.classintown.com/.well-known/apple-app-site-association`

---

## Questions?

Contact the web/backend team if:
- Association files return 404 or HTML (not JSON)
- Context API returns 403 for a valid instructor + fresh email link
- Email link opens browser even with app installed (usually cert fingerprint or intent-filter issue)
