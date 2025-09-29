# ClassInTown × Razorpay (Technology Partner OAuth) — End‑to‑End Roadmap

**Goal:** Each instructor gets paid **directly to their own Razorpay account**.  
**Approach:** Use Razorpay **Technology Partner + OAuth**. If the instructor doesn’t have an account, you **create one on their behalf**, then guide them through **KYC** via a **hosted onboarding link**, and finally obtain **OAuth consent** so you can create orders on their account.

---

## Contents
1. [At‑a‑Glance Flow (Mermaid)](#at-a-glance-flow-mermaid)
2. [Phase 0 — Business Decisions](#phase-0--business-decisions)
3. [Phase 1 — Become a Technology Partner](#phase-1--become-a-technology-partner)
4. [Phase 2 — Design Onboarding Paths](#phase-2--design-onboarding-paths)
5. [Phase 3 — Data to Collect Upfront](#phase-3--data-to-collect-upfront)
6. [Phase 4 — Instructor Journeys (Step‑by‑Step)](#phase-4--instructor-journeys-step-by-step)
7. [Phase 5 — Payments End‑to‑End (Plain English)](#phase-5--payments-end-to-end-plain-english)
8. [Phase 6 — Reconciliation, Taxes & Refunds](#phase-6--reconciliation-taxes--refunds)
9. [Phase 7 — Ops & Support Playbooks](#phase-7--ops--support-playbooks)
10. [Phase 8 — Testing & Launch Plan](#phase-8--testing--launch-plan)
11. [Phase 9 — Monitoring & Improvements](#phase-9--monitoring--improvements)
12. [Printable Checklists](#printable-checklists)
13. [FAQ & Glossary](#faq--glossary)

---

## At‑a‑Glance Flow (Mermaid)

```mermaid
flowchart TD
    A[Start: Instructor wants to receive payments] --> B{Do they already have a Razorpay account?}
    B -- Yes --> C[Instructor clicks 'Connect Razorpay']
    C --> D[Razorpay OAuth Consent Screen]
    D -->|Allow| E[Redirect back to ClassInTown with Access Granted]
    E --> F[Show Status: Connected]
    F --> G{KYC Verified?}
    G -- Yes --> H[Ready for Live Payments]
    G -- No --> I[Prompt 'Resume Onboarding' on Razorpay Hosted Page]
    I --> J[Upload Needed Docs & Submit]
    J --> K[⏳ WAIT: Razorpay Verification]
    K -->|Approved| H

    B -- No --> L[Create Razorpay Account on Instructor's Behalf]
    L --> M[Generate Hosted Onboarding Link (Prefilled)]
    M --> N[Instructor Opens Link, Reviews, Uploads Docs]
    N --> O[⏳ WAIT: Razorpay Verification]
    O -->|Approved| P[Ask for OAuth Consent]
    P --> D
```
**Legend:**  
- **Diamond** = Decision.  
- **⏳ WAIT** = Razorpay needs time to verify documents.  
- **Hosted Onboarding Link** = Co‑branded Razorpay page that only asks for missing items.

---

## Phase 0 — Business Decisions

- **Revenue Split & Fees**
  - Commission %: `<e.g., 10% of order value>`
  - Refund policy: `<e.g., full refund minus platform fee within 48 hours>`
  - Charge timing: `<monthly invoice to instructor>` or `<introduce Route later for auto‑split>`

- **Invoicing & GST**
  - **MoR (Merchant of Record):** In OAuth model, the **instructor** is typically MoR (issues tax invoice to student).
  - Platform invoices the instructor for commission and services.

- **Disputes & Cancellations**
  - Who approves refunds? `<instructor/platform>`
  - What is the deadline & evidence needed? `<policy link>`

---

## Phase 1 — Become a Technology Partner

1. **Apply/Enable Technology Partner** in Razorpay Partner Program.  
2. **Create an OAuth Application** in Partner Dashboard:  
   - App Name: `ClassInTown Instructor Payments`  
   - Redirect URL(s): `<https://app.classintown.com/payments/razorpay/callback>`  
   - Scopes: `<read/write permissions needed for orders & payments>`  
   - Securely store **Client ID** & **Client Secret**.

**Outputs to keep safe:** Partner Dashboard access, Client ID/Secret, allowed redirect URL(s).

---

## Phase 2 — Design Onboarding Paths

- **Path A (Connect existing account):**  
  - Instructor already has Razorpay; they **Authorize** your app (OAuth).  
  - Minimal friction, immediate connection.

- **Path B (Create account on their behalf):**  
  - You **create** a Razorpay account using instructor basics.  
  - Generate **Hosted Onboarding Link** to capture only missing pieces (PAN/ID, bank proof).  
  - After KYC approval, ask for **OAuth Consent** to grant your app access.

**Tip:** Show clear status chips in your UI: `Not Connected`, `Creating Account`, `KYC Pending`, `In Review`, `Verified`, `Access Revoked`.

---

## Phase 3 — Data to Collect Upfront

Collect these from each instructor (via a short, friendly form):

- **Legal Full Name** (e.g., `Riya Shah`)  
- **Email** (`riya@example.com`)  
- **Mobile** (`+91 98xxxxxxx`)  
- **Business Type**: `Individual / Sole Proprietor / Partnership / LLP / Company`  
- **Business Category**: `Education → Coaching/Tutoring`  
- **Trading/Brand Name**: *(optional)* `Riya’s Chemistry Lab`  
- **Settlement Bank Details**: *(optional now; can collect later)*

**Why:** Enough to create the account & prefill onboarding so only missing KYC items are asked later.

---

## Phase 4 — Instructor Journeys (Step‑by‑Step)

### Path B — No Account Yet (Recommended for non‑tech users)

1) **Explain the process clearly** (copy you can use):  
   - “Click **Create/Connect Razorpay**. We’ll set up your payments account.”  
   - “You may be asked for **PAN**, **ID proof**, and **bank proof**. You can upload them now or later.”  
   - “Once verified, payments from your students go **directly to your bank**.”

2) **Create the Razorpay account on their behalf**  
   - Use their basics from Phase 3.  
   - **Save:** Razorpay `Account ID` for the instructor (e.g., `acc_ABC123`).

3) **Generate the Hosted Onboarding Link**  
   - Send it in‑app and via email/WhatsApp.  
   - It’s prefilled with what you know; it asks only for **missing** docs.

4) **Instructor completes onboarding**  
   - They open the link → review details → upload PAN/ID, bank proof → submit.  
   - Status becomes **Pending Review**.

5) **⏳ WAIT: Verification by Razorpay**  
   - Typical outcomes: **Approved**, **Need clearer copy**, **Alternative doc required**.  
   - If rejected, instructor re‑uploads via the same link.

6) **Ask for OAuth Consent**  
   - Once account exists (and ideally after KYC approved), show **Authorize ClassInTown**.  
   - Instructor taps **Allow** on Razorpay and returns to your app.

7) **Show Connected & Verified**  
   - UI shows: `Connection = Connected`, `KYC = Verified`.  
   - Ready for live payments.

---

### Path A — Already Has an Account

1) **Instructor clicks Connect** → Goes to Razorpay’s **OAuth consent** page.  
2) **Allow** → Redirects back to your app.  
3) Show `Connected`. If KYC was already done, they’re **Ready**; else prompt **Resume Onboarding**.

---

## Phase 5 — Payments End‑to‑End (Plain English)

1) **Student chooses a class and proceeds to pay.**  
2) Your app prepares a **payment order on the instructor’s Razorpay account** (you have OAuth access).  
3) Student completes checkout (Razorpay UI).  
4) **Money settles to instructor’s bank** (per Razorpay timelines).  
5) You **receive webhooks** like `payment.captured` and mark the enrollment as **Paid** in ClassInTown.  
6) **Refunds**—if needed—are initiated on the same account; you display refund status in your app.

**Commission handling (OAuth model):**  
- Start with **monthly invoices** to instructors (simplest).  
- Optionally add **Route** later for automatic fee splits.

---

## Phase 6 — Reconciliation, Taxes & Refunds

- **Reconciliation data to store per enrollment:**  
  - Instructor `Account ID`, `Order ID`, `Payment ID`, payer name/email, price, taxes, time.  
- **Invoicing & GST:**  
  - Instructor is MoR; your platform invoices the instructor for commission/service.  
- **Refund policy:**  
  - Define who can trigger refunds, deadlines, and how fees/commissions are treated on refunds.

---

## Phase 7 — Ops & Support Playbooks

**Common Questions & Answers:**  
- *What is bank proof?* → “A cancelled cheque or first page of passbook or a recent bank statement with your name & account number.”  
- *KYC rejected—what now?* → “Click **Resume Onboarding** and re‑upload a clearer document or alternate proof.”  
- *Disconnected by mistake?* → “Click **Reconnect** and press **Allow** on Razorpay.”  
- *When will I get my money?* → “Directly from Razorpay to your bank—check settlements in Razorpay Dashboard.”  
- *How to refund a student?* → “From your Razorpay Dashboard (or ask us); we’ll show the refund status in ClassInTown.”

**Webhooks you must watch:**  
- `payment.captured` (update enrollment to **Paid**)  
- `refund.processed` (reflect refund)  
- `account.app.authorization_revoked` (mark **Disconnected** and prompt **Reconnect**)

---

## Phase 8 — Testing & Launch Plan

**Sandbox/Pilot:**  
- Connect a **test** instructor (Path A & Path B).  
- Run a **test payment** and verify your webhook updates the enrollment.  
- Simulate **revoked access** and confirm your UI shows **Disconnected** with **Reconnect** button.

**Pilot Launch:**  
- Onboard 3–5 real instructors, gather friction points, refine copy & reminders.

**Full Launch:**  
- Publish internal SOP, FAQs, and add automated reminders for “KYC Pending”.

---

## Phase 9 — Monitoring & Improvements

Track weekly:  
- % instructors who **started** onboarding, % who **completed** KYC, average **time to verification**.  
- Payment **success rate**, **refund rate**, webhook **delivery errors**.  
- Top **drop‑off** reasons (e.g., bank proof unclear).

Improve by:  
- Prefilling more fields, adding **examples** next to each document upload, and sending helpful **nudges** (email/WhatsApp).

---

## Printable Checklists

### Platform Readiness
- [ ] Technology Partner access enabled  
- [ ] OAuth App created; Client ID/Secret stored securely  
- [ ] Redirect URL tested end‑to‑end  
- [ ] Hosted Onboarding Link flow verified  
- [ ] Webhooks subscribed & tested (`payment.captured`, `authorization_revoked`)

### Per‑Instructor
- [ ] Basics collected (name, email, phone, entity type, category)  
- [ ] If no account → Create account; send onboarding link  
- [ ] If account exists → Connect via OAuth  
- [ ] KYC status: `Verified`  
- [ ] Connection status: `Connected`  
- [ ] Test payment & webhook received

---

## FAQ & Glossary

**FAQ**  
- **Do I need to open the account myself?** No. ClassInTown can create it for you and you just upload missing docs on a single page.  
- **Who holds my money?** Razorpay; it settles directly to your bank account.  
- **Can I disconnect later?** Yes, anytime from Razorpay; you can reconnect from ClassInTown.

**Glossary**  
- **Technology Partner:** A Razorpay partner type that lets a platform act on behalf of its clients with consent.  
- **OAuth:** A safe permission system that lets ClassInTown operate on the instructor’s Razorpay account.  
- **KYC (Onboarding):** Document & verification process required before payouts.  
- **Webhook:** A message Razorpay sends your system when an event occurs (e.g., payment captured).
