# App Store Review – Rejection Summary  
**Submission ID:** `60d5588d-0a8a-4647-b9fb-c97f2225076d`  
**Review Date:** December 08, 2025  
**Version Reviewed:** 1.0  

---

# ❌ Reason for Rejection – Summary

Your app was rejected due to four guideline violations:

1. Guideline **4.8 – Login Services**  
2. Guideline **2.3.6 – Age Rating Metadata**  
3. Guideline **4.0 – Design (External Browser for Login)**  
4. Guideline **2.1 – Performance (Google Login Crash/Error)**  

Detailed findings below.

---

# 1️⃣ Guideline 4.8 – Design – Login Services

The app uses a third-party login service (Google), but does **not** provide an equivalent login option that meets all these Apple requirements:

- The login option must limit data collection to *only* the user's **name and email address**.  
- The login option must allow users to **hide their email address**.  
- The login option must **not** collect app interaction data for advertising without consent.

**Apple notes:**  
> Sign in with Apple already meets all required criteria.

### **Next Steps**
- Add **Sign in with Apple** as a login option in your app.  
- If you already have an equivalent login that meets all requirements, reply in App Store Connect and explain how it complies.

---

# 2️⃣ Guideline 2.3.6 – Performance – Accurate Metadata

Your age-rating metadata indicates **“In-App Controls”**, but reviewers could not find:

- Parental Controls  
- Age Assurance features  

### **Next Steps**
If these features exist:  
- Reply to Apple and explain where/how to find them.

If they do NOT exist:  
- Update Age Rating → set **None** for:
  - *Parental Controls*  
  - *Age Assurance*

(Location: App Store Connect → App Information → Age Rating)

---

# 3️⃣ Guideline 4.0 – Design – Poor Login Flow (External Browser)

Reviewers found that your app **opens a default external browser** for login/registration.  
This is considered a **poor user experience**.

### **Next Steps**
- Implement **in-app login** handling.  
- OR use **Safari View Controller** instead of redirecting to an external browser.

**Important:**  
Apps that support account creation must also support **account deletion** (Guideline 5.1.1(v)).

---

# 4️⃣ Guideline 2.1 – Performance – App Completeness

Reviewers encountered a **bug**:

> When tapping **“Continue with Google”**, an error message appeared.

**Test Device:**  
- iPhone 13 mini  
- iOS 26.1

### **Next Steps**
- Reproduce and fix the crash/error.  
- Test on real devices, not only simulators.  

If you cannot reproduce the bug, try:  
- Delete all old builds → reinstall fresh.  
- Install the new version as an update over the previous one.  

---

# 📌 Recommended Fix Order (Fastest Way to Get Approval)

1. Add **Sign in with Apple**  
2. Move login to **in-app** (or Safari View Controller)  
3. Fix Google login crash (likely OAuth redirect / scheme mismatch)  
4. Update **Age Rating** metadata  
5. Re-test on iPhone (physical device)  
6. Resubmit with a **clear explanation** in App Review notes

---

If you want, I can also prepare:

✅ A **perfect reply message** to Apple  
✅ A **technical fix guide** for integrating Sign in With Apple (Angular + Capacitor)  
✅ A **checklist** to ensure next submission is 100% approved  
