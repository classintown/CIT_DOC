# 📋 Complete List of All Agenda Jobs/Queues

**Last Updated**: 2026-02-18  
**Purpose**: Complete reference for testing all Agenda jobs in the system

---

## 🎯 Job Categories

### 1. **NOTIFICATION JOBS** (Priority 1 - CRITICAL)

#### 1.1 Unified Notification System
| Job Name | Priority | Queue | Description | Trigger | Test Method |
|----------|----------|-------|-------------|---------|-------------|
| `send unified notification` | 1 | `agenda_jobs` (regular)<br>`agenda_jobs_otp` (OTP) | Sends notifications via Email, WhatsApp, Push, or In-App | Queued via `queueEmailNotification()`, `queueWhatsAppNotification()`, etc. | Send OTP, create enrollment, send any notification |
| `notify admin of failed notification` | 8 | `agenda_jobs` | Sends email to admin when notification fails 3+ times | Auto-triggered after 3 failed attempts | Force notification failure 3 times |

**OTP Notifications** (Ultra-Fast Queue):
- Uses separate `agenda_jobs_otp` collection
- 1-second polling interval
- <4 seconds delivery target
- Auto-detected when `notificationType === 'otp_verification'`

---

### 2. **PAYMENT JOBS** (Priority 1-2)

| Job Name | Priority | Schedule | Description | Trigger | Test Method |
|----------|----------|----------|-------------|---------|-------------|
| `send payment notifications` | 1 | On-demand | Sends payment confirmation via Email, WhatsApp, Push | Queued after payment creation | Create a payment |
| `paymentStatusPollingJob` | 2 | `*/5 * * * *` (every 5 min) | Polls Razorpay for payment status updates | Scheduled automatically | Wait for scheduled run or trigger manually |
| `paymentPlanExpiryJob` | 2 | Configurable (env) | Marks expired payment plans as expired | Scheduled automatically | Wait for scheduled run or trigger manually |
| `paymentReconciliationJob` | 2 | Configurable (env) | Reconciles payment records with Razorpay | Scheduled automatically | Wait for scheduled run or trigger manually |
| `check payment reminders` | 5 | `1 day at 09:00` (daily 9 AM) | Checks and sends payment due reminders | Scheduled daily | Wait for scheduled run or trigger manually |
| `webhookRetryJob` | 2 | `*/5 * * * *` (every 5 min) | Retries failed Razorpay webhooks | Scheduled automatically | Wait for scheduled run or trigger manually |
| `proofUploadRetryJob` | 2 | `*/5 * * * *` (every 5 min) | Retries failed proof uploads | Scheduled automatically | Wait for scheduled run or trigger manually |

---

### 3. **CLASS/SLOT NOTIFICATION JOBS** (Priority 2-6)

| Job Name | Priority | Schedule | Description | Trigger | Test Method |
|----------|----------|----------|-------------|---------|-------------|
| `send slot reminder` | 5 | Scheduled (24h, 1h, 15min before class) | Sends class reminder notifications | Auto-scheduled when slot is created | Create a class slot |
| `send readiness check` | 5 | Scheduled (2h before class) | Sends readiness check notification | Auto-scheduled when slot is created | Create a class slot |
| `send slot update notification` | 3 | On-demand | Sends notification when slot is updated | Queued when slot is updated | Update a class slot |
| `send slot cancellation` | 2 | On-demand | Sends cancellation notification | Queued when slot is cancelled | Cancel a class slot |
| `auto complete slot` | 6 | Scheduled (at slot end time) | Auto-marks slot as completed | Auto-scheduled when slot is created | Create a slot and wait for end time |

---

### 4. **EVENT NOTIFICATION JOBS** (Priority 5-6)

| Job Name | Priority | Schedule | Description | Trigger | Test Method |
|----------|----------|----------|-------------|---------|-------------|
| `send event notification` | 5 | Scheduled (before event start) | Sends WhatsApp event notification | Auto-scheduled when event is created | Create a calendar event |
| `mark event as completed` | 6 | Scheduled (at event end time) | Marks event as completed | Auto-scheduled when event is created | Create an event and wait for end time |

---

### 5. **ATTENDANCE & STUDENT JOBS** (Priority 5-10)

| Job Name | Priority | Schedule | Description | Trigger | Test Method |
|----------|----------|----------|-------------|---------|-------------|
| `autoMarkAttendanceJob` | 5 | `5 * * * *` (hourly at :05) | Auto-marks attendance for completed slots | Scheduled hourly | Wait for scheduled run or trigger manually |
| `studentArchivingJob` | 10 | `0 2 * * 0` (weekly, Sun 2 AM) | Archives old student records | Scheduled weekly | Wait for scheduled run or trigger manually |

---

### 6. **SYSTEM MAINTENANCE JOBS** (Priority 10 - LOWEST)

| Job Name | Priority | Schedule | Description | Trigger | Test Method |
|----------|----------|----------|-------------|---------|-------------|
| `autoBackupJob` | 10 | Configurable (env) | Backs up MongoDB database | Scheduled automatically | Wait for scheduled run or trigger manually |
| `archive-module-analytics` | 10 | `0 0 * * *` (daily midnight) | Archives old module analytics data | Scheduled daily | Wait for scheduled run or trigger manually |

---

## 🧪 Testing Guide

### How to Test Each Job

#### **Method 1: Trigger via Application Actions**
Most jobs are triggered automatically by user actions:
- **OTP Notifications**: Request OTP for sign-in
- **Payment Notifications**: Create a payment
- **Slot Reminders**: Create a class slot
- **Event Notifications**: Create a calendar event

#### **Method 2: Manual Job Triggering (via MongoDB/Agenda)**
You can manually trigger jobs using Agenda API:

```javascript
// In Node.js console or test script
const { getAgenda, getOtpAgenda } = require('./backend/shared/utils/agendaHelper');

// For regular jobs
const agenda = await getAgenda();
await agenda.now('job name', { /* job data */ });

// For OTP jobs
const otpAgenda = await getOtpAgenda();
await otpAgenda.now('send unified notification', { /* job data */ });
```

#### **Method 3: Check Scheduled Jobs**
View all scheduled jobs:

```javascript
const agenda = await getAgenda();
const jobs = await agenda.jobs({});
console.log('Scheduled jobs:', jobs.map(j => ({
  name: j.attrs.name,
  nextRunAt: j.attrs.nextRunAt,
  repeatInterval: j.attrs.repeatInterval
})));
```

---

## 📊 Job Priority Levels

| Priority | Level | Jobs |
|----------|-------|------|
| **1** | CRITICAL | OTP notifications, Payment confirmations, Unified notifications |
| **2** | HIGH | Slot cancellations, Payment polling, Webhook retries |
| **3** | HIGH-MEDIUM | Slot updates |
| **5** | MEDIUM | Slot reminders, Payment reminders, Event notifications, Auto-mark attendance |
| **6** | MEDIUM-LOW | Auto-complete slots, Mark events completed |
| **8** | LOW | Admin notifications |
| **10** | LOWEST | Database backups, Archiving jobs |

---

## 🔍 Queue Collections

| Collection | Purpose | Polling Interval |
|------------|---------|------------------|
| `agenda_jobs` | Regular jobs | 30 seconds |
| `agenda_jobs_otp` | OTP notifications only | **1 second** (ultra-fast) |

---

## ✅ Quick Test Checklist

### Critical Jobs (Test First)
- [ ] `send unified notification` - OTP (email + WhatsApp)
- [ ] `send unified notification` - Regular notification
- [ ] `send payment notifications` - Payment confirmation

### Scheduled Jobs (Check Schedule)
- [ ] `autoBackupJob` - Database backup
- [ ] `check payment reminders` - Payment reminders
- [ ] `paymentStatusPollingJob` - Payment status polling
- [ ] `autoMarkAttendanceJob` - Auto-mark attendance

### Slot/Class Jobs
- [ ] `send slot reminder` - Class reminders
- [ ] `send readiness check` - Readiness notifications
- [ ] `send slot update notification` - Slot updates
- [ ] `send slot cancellation` - Cancellation notifications

### Event Jobs
- [ ] `send event notification` - Event notifications
- [ ] `mark event as completed` - Auto-complete events

---

## 🐛 Troubleshooting

### Check if Job is Registered
```javascript
const agenda = await getAgenda();
const jobDefinitions = agenda._definitions;
console.log('Registered jobs:', Object.keys(jobDefinitions));
```

### Check Job Status
```javascript
const jobs = await agenda.jobs({ name: 'job name' });
console.log('Job status:', jobs.map(j => ({
  name: j.attrs.name,
  nextRunAt: j.attrs.nextRunAt,
  lastRunAt: j.attrs.lastRunAt,
  failedAt: j.attrs.failedAt,
  lastFinishedAt: j.attrs.lastFinishedAt
})));
```

### View Failed Jobs
```javascript
const failedJobs = await agenda.jobs({ failedAt: { $exists: true } });
console.log('Failed jobs:', failedJobs);
```

---

## 📝 Notes

1. **OTP Jobs** use a separate ultra-fast queue (`agenda_jobs_otp`) with 1-second polling
2. **Priority 1** jobs are processed first (OTP, payments)
3. **Priority 10** jobs run in background (backups, archiving)
4. Most jobs are **auto-scheduled** when related actions occur
5. Some jobs require **waiting for scheduled time** to test naturally

---

**Total Jobs**: 18 unique job definitions  
**Queues**: 2 (regular + OTP fast queue)  
**Priority Levels**: 7 (1, 2, 3, 5, 6, 8, 10)
