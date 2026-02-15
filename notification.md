# Complete Notification Inventory

## System-Wide Notification Overview

This document provides a comprehensive list of all notifications in the system, extracted directly from the codebase.

---

## Notification Categories

| # | Notification Type | Source (Trigger) | Destination | Trigger Reason | Related Agenda/Job | Channels | Frequency | Avg Processing Time |
|---|------------------|------------------|-------------|----------------|-------------------|----------|------------|-------------------|
| **AUTHENTICATION NOTIFICATIONS** |
| 1 | OTP Verification (Sign In) | `backend/controllers/auth/auth.controller.js` - `sendSignInOtp()` | User (Student/Instructor) | User requests sign-in OTP | `send unified notification` (Priority 1) | Email, WhatsApp | On-demand (user request) | ~2-5s |
| 2 | OTP Verification (Email) | `backend/controllers/auth/auth.controller.js` - `createEmailOtp()` | User | User requests email OTP | `send unified notification` (Priority 1) | Email | On-demand (user request) | ~2-5s |
| 3 | OTP Verification (Mobile) | `backend/controllers/auth/auth.controller.js` - `createMobileOtp()` | User | User requests mobile OTP | `send unified notification` (Priority 1) | WhatsApp | On-demand (user request) | ~2-5s |
| 4 | Registration Confirmation | `backend/controllers/auth/auth.controller.js` - `verifyOTP()` | New User | User completes registration | Direct call (no queue) | Email, Push | On user registration | ~1-3s |
| 5 | Account Validation | `backend/controllers/auth/auth.controller.js` - `verifyOTP()` | New Instructor/Institute | User completes registration | Direct call (no queue) | Email, Push | On user registration | ~1-3s |
| 6 | Password Reset | `backend/notification.service.js` - `pushNotifyPasswordReset()` | User | User requests password reset | Direct call (no queue) | Push | On-demand (user request) | ~1-2s |
| 7 | Password Change Confirmation | `backend/notification.service.js` - `pushNotifyPasswordChange()` | User | User changes password | Direct call (no queue) | Push | On password change | ~1-2s |
| **ENROLLMENT NOTIFICATIONS** |
| 8 | New Enrollment (to Instructor) | `backend/routes/enrollments.routes.js` - POST `/schedule` | Instructor | Student enrolls in class | `sendNotificationWithRetry()` | WhatsApp, Push | On enrollment creation | ~3-5s |
| 9 | Enrollment Confirmation (to Student) | `backend/routes/enrollments.routes.js` - POST `/schedule` | Student | Student enrolls in class | `sendNotificationWithRetry()` | WhatsApp, Push | On enrollment creation | ~3-5s |
| 10 | Enrollment Approved (to Student) | `backend/routes/enrollments.routes.js` - PATCH `/schedule/:id` | Student | Instructor approves enrollment | `send unified notification` (Priority 1) | Email, WhatsApp, Push | On status change: requested → approved | ~2-5s |
| 11 | Enrollment Rejected (to Student) | `backend/routes/enrollments.routes.js` - PATCH `/schedule/:id` | Student | Instructor rejects enrollment | `send unified notification` (Priority 1) | Email, WhatsApp, Push | On status change to rejected | ~2-5s |
| 12 | Enrollment Waitlisted (to Student) | `backend/routes/enrollments.routes.js` - PATCH `/schedule/:id` | Student | Class is full, enrollment waitlisted | `send unified notification` (Priority 1) | Email, WhatsApp, Push | On status change to waitlisted | ~2-5s |
| 13 | Waitlist to Approved (to Student) | `backend/routes/enrollments.routes.js` - PATCH `/schedule/:id` | Student | Waitlisted enrollment approved | `send unified notification` (Priority 1) | Email, WhatsApp, Push | On status change: waitlisted → approved | ~2-5s |
| 14 | Moved to Waitlist (to Student) | `backend/routes/enrollments.routes.js` - PATCH `/schedule/:id` | Student | Enrollment moved to waitlist | `send unified notification` (Priority 1) | Email, WhatsApp, Push | On status change to waitlisted | ~2-5s |
| 15 | Enrollment Re-Approved (to Student) | `backend/routes/enrollments.routes.js` - PATCH `/schedule/:id` | Student | Enrollment re-approved | `send unified notification` (Priority 1) | Email, WhatsApp, Push | On status change: re-approved | ~2-5s |
| 16 | Enrollment Cancelled (to Student) | `backend/routes/enrollments.routes.js` - PATCH `/schedule/:id` | Student | Enrollment cancelled | `send unified notification` (Priority 1) | Email, WhatsApp, Push | On status change to cancelled | ~2-5s |
| 17 | Enrollment Cancelled (to Instructor) | `backend/routes/enrollments.routes.js` - PATCH `/schedule/:id` | Instructor | Student enrollment cancelled | `send unified notification` (Priority 1) | Email, WhatsApp, Push | On status change to cancelled | ~2-5s |
| 18 | Enrollment Activated (to Student) | `backend/routes/enrollments.routes.js` - PATCH `/schedule/:id` | Student | Enrollment activated | `send unified notification` (Priority 1) | Email, WhatsApp, Push | On status change to active | ~2-5s |
| 19 | Enrollment Activated (to Instructor) | `backend/routes/enrollments.routes.js` - PATCH `/schedule/:id` | Instructor | Student enrollment activated | `send unified notification` (Priority 1) | Email, WhatsApp, Push | On status change to active | ~2-5s |
| 20 | Enrollment Completed (to Student) | `backend/routes/enrollments.routes.js` - PATCH `/schedule/:id` | Student | Enrollment completed | `send unified notification` (Priority 1) | Email, WhatsApp, Push | On status change to completed | ~2-5s |
| 21 | Enrollment Completed (to Instructor) | `backend/routes/enrollments.routes.js` - PATCH `/schedule/:id` | Instructor | Student enrollment completed | `send unified notification` (Priority 1) | Email, WhatsApp, Push | On status change to completed | ~2-5s |
| **PAYMENT NOTIFICATIONS** |
| 22 | Payment Confirmation (to Student) | `backend/shared/jobs/paymentNotifications.js` - `send payment notifications` | Student | Payment created/confirmed | `send payment notifications` (Priority 1) | WhatsApp, Email | On payment creation | ~5-10s (async) |
| 23 | Payment Confirmation (to Instructor) | `backend/shared/jobs/paymentNotifications.js` - `send payment notifications` | Instructor | Payment created/confirmed | `send payment notifications` (Priority 1) | WhatsApp, Email, Push | On payment creation | ~5-10s (async) |
| 24 | Payment Plan Created (to Instructor) | `backend/routes/enrollments.routes.js` | Instructor | Payment plan created | Direct call | Email, WhatsApp, Push | On payment plan creation | ~2-5s |
| 25 | Payment Plan Created (to Student) | `backend/routes/enrollments.routes.js` | Student | Payment plan created | Direct call | Email, WhatsApp, Push | On payment plan creation | ~2-5s |
| 26 | Payment Plan Updated (to Instructor) | `backend/routes/enrollments.routes.js` | Instructor | Payment plan updated | Direct call | Email, WhatsApp, Push | On payment plan update | ~2-5s |
| 27 | Payment Plan Updated (to Student) | `backend/routes/enrollments.routes.js` | Student | Payment plan updated | Direct call | Email, WhatsApp, Push | On payment plan update | ~2-5s |
| 28 | Payment Due Reminder (3 days) | `backend/shared/jobs/paymentReminders.js` - `check payment reminders` | Student | Payment due in 3 days | `check payment reminders` (Priority 5) | Email, WhatsApp, Push | Daily at 9 AM (checks all plans) | ~2-5s per notification |
| 29 | Payment Due Reminder (1 day) | `backend/shared/jobs/paymentReminders.js` - `check payment reminders` | Student | Payment due tomorrow | `check payment reminders` (Priority 5) | Email, WhatsApp, Push | Daily at 9 AM (checks all plans) | ~2-5s per notification |
| 30 | Payment Overdue | `backend/shared/jobs/paymentReminders.js` - `check payment reminders` | Student | Payment is overdue | `check payment reminders` (Priority 5) | Email, WhatsApp, Push | Daily at 9 AM (max once per 24h) | ~2-5s per notification |
| 31 | Payment Submitted (to Student) | `backend/notification.service.js` - `pushNotifyPaymentSubmittedToStudent()` | Student | Payment proof submitted | Direct call | Push | On payment submission | ~1-2s |
| 32 | Payment Submitted (to Instructor) | `backend/notification.service.js` - `pushNotifyPaymentSubmittedToInstructor()` | Instructor | Student submitted payment | Direct call | Push | On payment submission | ~1-2s |
| 33 | Payment Verified (to Student) | `backend/notification.service.js` - `pushNotifyPaymentVerifiedToStudent()` | Student | Payment verified by instructor | Direct call | Push | On payment verification | ~1-2s |
| 34 | Payment Verification Rejected (to Student) | `backend/notification.service.js` - `pushNotifyPaymentVerificationRejectedToStudent()` | Student | Payment proof rejected | Direct call | Push | On rejection | ~1-2s |
| 35 | Payment Failed (to Student) | `backend/notification.service.js` - `pushNotifyPaymentFailedToStudent()` | Student | Payment processing failed | Direct call | Push | On payment failure | ~1-2s |
| 36 | Payment Failed (to Instructor) | `backend/notification.service.js` - `pushNotifyPaymentFailedToInstructor()` | Instructor | Payment processing failed | Direct call | Push | On payment failure | ~1-2s |
| 37 | Payment Refunded (to Student) | `backend/notification.service.js` - `pushNotifyPaymentRefundedToStudent()` | Student | Payment refunded | Direct call | Push | On refund | ~1-2s |
| 38 | Payment Refunded (to Instructor) | `backend/notification.service.js` - `pushNotifyPaymentRefundedToInstructor()` | Instructor | Payment refunded | Direct call | Push | On refund | ~1-2s |
| **CLASS SLOT NOTIFICATIONS** |
| 39 | Slot Reminder (24h before) | `backend/shared/jobs/slotNotifications.js` - `send slot reminder` | Instructor + Students | Class starts in 24 hours | `send slot reminder` (Priority 5) | Push, WhatsApp, In-App | Scheduled 24h before slot | ~2-5s per recipient |
| 40 | Slot Reminder (1h before) | `backend/shared/jobs/slotNotifications.js` - `send slot reminder` | Instructor + Students | Class starts in 1 hour | `send slot reminder` (Priority 5) | Push, WhatsApp, In-App | Scheduled 1h before slot | ~2-5s per recipient |
| 41 | Slot Reminder (15min before) | `backend/shared/jobs/slotNotifications.js` - `send slot reminder` | Instructor + Students | Class starts in 15 minutes | `send slot reminder` (Priority 5) | Push, WhatsApp, In-App | Scheduled 15min before slot | ~2-5s per recipient |
| 42 | Readiness Check (2h before) | `backend/shared/jobs/slotNotifications.js` - `send readiness check` | Instructor only | Class starts in 2 hours | `send readiness check` (Priority 5) | Push, WhatsApp, In-App, Socket | Scheduled 2h before slot | ~2-5s |
| 43 | Slot Update Notification | `backend/shared/jobs/slotNotifications.js` - `send slot update notification` | Instructor + Students | Slot time/location/notes updated | `send slot update notification` (Priority 3) | Push, WhatsApp, In-App | On slot update (immediate) | ~2-5s per recipient |
| 44 | Slot Cancellation | `backend/shared/jobs/slotNotifications.js` - `send slot cancellation` | Students only | Slot cancelled | `send slot cancellation` (Priority 2) | Push, WhatsApp, In-App | On slot cancellation (immediate) | ~2-5s per recipient |
| 45 | Auto-Complete Slot | `backend/shared/jobs/slotNotifications.js` - `auto complete slot` | System | Slot end time reached | `auto complete slot` (Priority 6) | None (status update only) | Scheduled at slot end time | ~1-2s |
| **EVENT NOTIFICATIONS** |
| 46 | Event Reminder | `backend/shared/jobs/eventNotifications.js` - `send event notification` | Event Organizer + Attendees | Event reminder (configurable time) | `send event notification` (Priority 5) | WhatsApp | Scheduled based on `notification_times` | ~2-5s per recipient |
| 47 | Mark Event as Completed | `backend/shared/jobs/eventNotifications.js` - `mark event as completed` | System | Event end time reached | `mark event as completed` (Priority 6) | None (status update only) | Scheduled at event end time | ~1-2s |
| **TASK NOTIFICATIONS** |
| 48 | Task Created (to Sender) | `backend/controllers/task/task.controller.js` | Task Creator | Task created | Direct call | Push | On task creation | ~1-2s |
| 49 | Task Assigned (to Recipients) | `backend/controllers/task/task.controller.js` | Task Recipients | Task assigned to them | Direct call | Push | On task creation | ~1-2s |
| 50 | Task Status Update (to Sender) | `backend/controllers/task/task.controller.js` | Task Creator | Task status changed | Direct call | Push | On status update | ~1-2s |
| 51 | Task Status Update (to Recipients) | `backend/controllers/task/task.controller.js` | Task Recipients | Assigned task status changed | Direct call | Push | On status update | ~1-2s |
| 52 | Task Status Update (by Recipient to Sender) | `backend/controllers/task/task.controller.js` | Task Creator | Recipient updated task status | Direct call | Push | On status update by recipient | ~1-2s |
| 53 | Task Status Update (by Self to Recipient) | `backend/controllers/task/task.controller.js` | Task Recipient | Self-updated task status | Direct call | Push | On self status update | ~1-2s |
| 54 | Task Deleted (to Sender) | `backend/controllers/task/task.controller.js` | Task Creator | Task deleted | Direct call | Push | On task deletion | ~1-2s |
| 55 | Task Deleted (to Recipients) | `backend/controllers/task/task.controller.js` | Task Recipients | Assigned task deleted | Direct call | Push | On task deletion | ~1-2s |
| 56 | Task Archived (to Sender) | `backend/controllers/task/task.controller.js` | Task Creator | Task archived | Direct call | Push | On task archival | ~1-2s |
| 57 | Task Archived (to Recipients) | `backend/controllers/task/task.controller.js` | Task Recipients | Assigned task archived | Direct call | Push | On task archival | ~1-2s |
| 58 | Task Details (to Sender) | `backend/controllers/task/task.controller.js` | Task Creator | Task details viewed | Direct call | Push | On task details view | ~1-2s |
| 59 | Task Details Updated (to Sender) | `backend/controllers/task/task.controller.js` | Task Creator | Task details updated | Direct call | Push | On task details update | ~1-2s |
| 60 | Task Details Updated (to Recipients) | `backend/controllers/task/task.controller.js` | Task Recipients | Assigned task details updated | Direct call | Push | On task details update | ~1-2s |
| **CHAT NOTIFICATIONS** |
| 61 | Group Chat Message | `backend/socket.js` - `sendMessage` event | Group Members (except sender) | New message in group | Direct call (Socket.io) | Push, Socket | Real-time (on message send) | ~100-500ms |
| 62 | Private Chat Message | `backend/socket.js` - `sendPrivateMessage` event | Message Recipient | New private message | Direct call (Socket.io) | Push, Socket | Real-time (on message send) | ~100-500ms |
| **ADMIN NOTIFICATIONS** |
| 63 | Failed Notification Alert | `backend/shared/jobs/unifiedNotifications.js` - `notify admin of failed notification` | Admin (classintownua@gmail.com) | Notification failed 3+ times | `notify admin of failed notification` (Priority 8) | Email | On 3rd failure | ~2-5s |
| **UNIFIED NOTIFICATION SYSTEM** |
| 64 | Send Unified Notification | `backend/shared/jobs/unifiedNotifications.js` - `send unified notification` | Any User | Generic notification handler | `send unified notification` (Priority 1) | Email, WhatsApp, Push, In-App | On queue (varies) | ~2-5s |

---

## Notification Channels Summary

| Channel | Count | Primary Use Cases |
|---------|-------|------------------|
| **Push** | 45+ | Real-time alerts, task updates, chat messages, enrollment status |
| **WhatsApp** | 25+ | OTP verification, payment confirmations, class reminders, enrollment notifications |
| **Email** | 20+ | OTP verification, payment confirmations, enrollment status, payment reminders |
| **In-App** | 10+ | Class reminders, slot updates, enrollment notifications |
| **Socket.io** | 2 | Real-time chat messages, readiness check modals |

---

## Agenda Job Priorities

| Priority | Level | Used For |
|----------|-------|----------|
| 1 | CRITICAL | OTP, Payment confirmations, Unified notifications |
| 2 | HIGH | Slot cancellations |
| 3 | HIGH-MEDIUM | Slot updates |
| 5 | MEDIUM | Slot reminders, Payment reminders, Event notifications, Readiness checks |
| 6 | MEDIUM-LOW | Auto-complete slots, Mark events completed |
| 8 | LOW | Admin notifications |

---

## Frequency Patterns

| Pattern | Count | Examples |
|---------|-------|----------|
| **On-Demand** | 35+ | OTP, Enrollment status changes, Payment confirmations, Task updates |
| **Scheduled (Time-based)** | 8 | Slot reminders (24h, 1h, 15min), Readiness check (2h), Payment reminders (daily) |
| **Real-time** | 2 | Chat messages, Socket events |
| **Daily Batch** | 1 | Payment reminder check (runs at 9 AM daily) |

---

## Processing Time Notes

- **Fast (< 2s)**: Push notifications, Direct socket events
- **Medium (2-5s)**: Email, WhatsApp via unified service, Scheduled notifications
- **Slow (5-10s)**: Payment notifications (async via Agenda), Multi-channel notifications
- **Batch Processing**: Payment reminders check processes all active plans (varies by volume)

---

## Key Observations

1. **Most notifications use the unified notification service** (Priority 1) for consistent delivery and retry logic
2. **Payment notifications are async** - queued immediately after payment creation for fast API response
3. **Slot notifications are scheduled** at specific times before class start
4. **Chat notifications are real-time** via Socket.io with push fallback
5. **Task notifications are push-only** and sent immediately
6. **Enrollment status changes trigger multi-channel notifications** (Email, WhatsApp, Push)
7. **Payment reminders run daily** at 9 AM to check all active payment plans

---

## Retry Logic

- **Max Attempts**: 5 (3 failures + 2 reserve)
- **Retry Delay**: 10 minutes
- **Admin Notification**: After 3 failures
- **Channels**: All channels support retry via unified notification service

---

*Last Updated: Generated from codebase analysis*
*Total Notifications: 64+ distinct notification types*
