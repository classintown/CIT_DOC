# Class in Town - Instructor & Student Module Functionality Map

## 📋 Table of Contents

1. [Instructor Module - Complete Functionality](#instructor-module)
2. [Student Module - Complete Functionality](#student-module)
3. [Common Conditions & Prerequisites](#conditions-and-prerequisites)
4. [End-to-End User Journey Maps](#user-journey-maps)

---

# INSTRUCTOR MODULE

## 1. AUTHENTICATION & ONBOARDING

### 1.1 Registration Flow
**UI Flow:**
```
Landing Page → Sign Up → Select "Instructor" → 
Email/Mobile Verification → Complete Profile → Dashboard
```

**Functionality:**
- ✅ Email/Mobile registration
- ✅ Google OAuth sign-in
- ✅ Apple Sign-in (iOS/Web)
- ✅ OTP verification
- ✅ Profile completion wizard
- ✅ Business account setup

**Conditions:**
- Valid email format OR valid mobile number with country code
- OTP must be verified within 5 minutes
- User must select "Instructor" as user type
- Profile must include: Name, Email, Mobile, Location
- Business account requires: Business name, Tax ID (optional), Banking details (for payouts)

**UI Components:**
- Registration form with email/mobile toggle
- OTP input modal
- Profile completion stepper (3-4 steps)
- Business account setup form

---

### 1.2 Login Flow
**UI Flow:**
```
Login Page → Email/Mobile + Password → Dashboard
OR
Login Page → Google/Apple Sign-in → Dashboard
```

**Functionality:**
- ✅ Email/Mobile + Password login
- ✅ Social login (Google, Apple)
- ✅ Remember me functionality
- ✅ Forgot password flow
- ✅ Session management
- ✅ Auto-logout on token expiry

**Conditions:**
- Valid credentials
- Account must be verified
- Account must not be suspended
- Token must be valid

**UI Components:**
- Login form
- Social login buttons
- Forgot password link
- Loading states

---

## 2. DASHBOARD

### 2.1 Main Dashboard
**UI Flow:**
```
Dashboard → Overview Cards → Quick Actions → Recent Activity
```

**Functionality:**
- ✅ Statistics cards (Total Classes, Ongoing, Upcoming, Completed)
- ✅ Monthly class count chart
- ✅ Recent schedules list
- ✅ Quick action buttons (Create Class, View Students, etc.)
- ✅ Notification center
- ✅ Calendar widget (upcoming classes)

**API Endpoint:** `GET /api/v1/instructClass/dashboard/stats`

**Data Displayed:**
- Total classes count
- Ongoing class count
- Upcoming class count
- Completed class count
- Monthly breakdown
- Recent schedules with activity, location, capacity, price

**Conditions:**
- User must be authenticated
- User type must be "Instructor"
- Valid scopeId (instructor ID)

**UI Components:**
- Statistics cards (4 cards in grid)
- Line/Bar chart for monthly data
- Schedule cards/list
- Quick action buttons
- Notification bell icon

---

## 3. CLASS MANAGEMENT

### 3.1 Create Class
**UI Flow:**
```
Dashboard → "Create Class" → Activity Selection → 
Location Selection → Schedule Setup → Pricing → Review → Publish
```

**Functionality:**
- ✅ Select existing activity OR create new activity
- ✅ Select location (existing OR add new)
- ✅ Set class type (duration-based OR session-based)
- ✅ Configure schedule (days, time slots, timezone)
- ✅ Set capacity and waitlist
- ✅ Set pricing (full price, discounts)
- ✅ Add class description
- ✅ Upload class media/images
- ✅ Google Calendar integration (auto-create events)
- ✅ Google Meet link generation
- ✅ Preview before publishing

**API Endpoints:**
- `POST /api/v1/instructClass` (create class)
- `GET /api/v1/activities/active` (get activities)
- `GET /api/v1/maps/enhanced` (get locations)

**Conditions:**
- Activity must exist or be created
- Location must exist or be created
- Schedule must have at least one time slot
- Capacity must be > 0
- Price must be >= 0
- Google Calendar must be connected (for auto-sync)
- Start date must be in future
- End date must be after start date

**UI Components:**
- Multi-step form wizard (5-6 steps)
- Activity selector (searchable dropdown)
- Location selector with map
- Schedule builder (calendar + time picker)
- Pricing input fields
- Media upload component
- Preview modal
- Google Calendar connection status

---

### 3.2 View All Classes
**UI Flow:**
```
Dashboard → "My Classes" → Class List → Filter/Sort → Class Details
```

**Functionality:**
- ✅ List all classes (active, archived)
- ✅ Filter by status (ongoing, upcoming, completed)
- ✅ Filter by activity
- ✅ Filter by location
- ✅ Sort by date, name, enrollment
- ✅ Search classes
- ✅ Pagination
- ✅ Quick actions (Edit, Archive, Delete, View Details)

**API Endpoint:** `GET /api/v1/instructClass`

**Conditions:**
- User must be authenticated
- User must be class owner

**UI Components:**
- Class list/grid view
- Filter sidebar
- Search bar
- Sort dropdown
- Pagination controls
- Action buttons per class card

---

### 3.3 Class Details
**UI Flow:**
```
Class List → Click Class → Class Details Page → 
Tabs: Overview | Students | Sessions | Analytics | Materials
```

**Functionality:**
- ✅ View complete class information
- ✅ View enrolled students list
- ✅ View all sessions/schedules
- ✅ View class analytics
- ✅ View/Upload class materials
- ✅ Edit class details
- ✅ Archive/Delete class
- ✅ Export class data

**API Endpoints:**
- `GET /api/v1/api/instructor/classes/{classId}`
- `GET /api/v1/api/instructor/classes/{classId}/analytics`
- `GET /api/v1/api/instructor/classes/{classId}/sessions`
- `GET /api/v1/api/instructor/classes/{classId}/students`
- `GET /api/v1/api/instructor/classes/{classId}/materials`

**Conditions:**
- Class must exist
- User must be class owner
- Valid classId

**UI Components:**
- Class header with image
- Tab navigation (5 tabs)
- Student table/list
- Sessions calendar view
- Analytics charts
- Materials grid/list
- Edit button
- Action menu (Archive, Delete)

---

### 3.4 Edit Class
**UI Flow:**
```
Class Details → "Edit" → Edit Form → Save Changes
```

**Functionality:**
- ✅ Edit all class fields (except enrolled students)
- ✅ Update schedule (add/remove slots)
- ✅ Update pricing
- ✅ Update capacity
- ✅ Update media
- ✅ Sync changes to Google Calendar
- ✅ Notify enrolled students of changes

**API Endpoint:** `PUT /api/v1/api/instructor/classes/{classId}`

**Conditions:**
- Class must exist
- User must be class owner
- Cannot reduce capacity below current enrollment
- Cannot change past sessions
- Must notify students if schedule changes

**UI Components:**
- Edit form (similar to create form)
- Change confirmation modal
- Success/error notifications

---

### 3.5 Archive/Delete Class
**UI Flow:**
```
Class Details → Action Menu → Archive/Delete → Confirm → Success
```

**Functionality:**
- ✅ Archive class (soft delete)
- ✅ Delete class (hard delete - if no enrollments)
- ✅ Cancel future sessions
- ✅ Notify enrolled students
- ✅ Refund handling (if applicable)

**API Endpoint:** `DELETE /api/v1/api/instructor/classes/{classId}`

**Conditions:**
- Class must exist
- User must be class owner
- Cannot delete if active enrollments exist (must archive)
- Must confirm action
- Must notify students

**UI Components:**
- Confirmation modal
- Reason input (for archive)
- Success notification

---

## 4. STUDENT MANAGEMENT

### 4.1 View All Students
**UI Flow:**
```
Dashboard → "Students" → Student List → Filter/Search → Student Details
```

**Functionality:**
- ✅ List all students across all classes
- ✅ Filter by class
- ✅ Filter by enrollment status
- ✅ Search by name, email, mobile
- ✅ Sort by name, enrollment date, attendance
- ✅ Export student list
- ✅ Bulk actions

**API Endpoint:** `GET /api/v1/class/students/{instructorId}`

**Conditions:**
- User must be authenticated
- User must be instructor
- Valid instructorId

**UI Components:**
- Student table/list
- Filter sidebar
- Search bar
- Export button
- Bulk selection checkbox

---

### 4.2 Student Details
**UI Flow:**
```
Student List → Click Student → Student Profile → 
Tabs: Overview | Enrollments | Attendance | Progress | Payments | Notes
```

**Functionality:**
- ✅ View student profile
- ✅ View all enrollments
- ✅ View attendance history
- ✅ View progress tracking
- ✅ View payment history
- ✅ Add/view instructor notes
- ✅ Send message to student
- ✅ Export student data

**API Endpoints:**
- `GET /api/v1/student/instructor/{instructorId}/student/{studentId}`
- `GET /api/v1/student/{studentId}/enrollment-data`
- `GET /api/v1/student/{studentId}/attendance-data`
- `GET /api/v1/student/{studentId}/progress-data`
- `GET /api/v1/student/{studentId}/payment-data`

**Conditions:**
- Student must exist
- Student must be enrolled in at least one of instructor's classes
- Valid studentId and instructorId

**UI Components:**
- Student profile header
- Tab navigation (6 tabs)
- Enrollment cards
- Attendance calendar/table
- Progress charts
- Payment history table
- Notes section
- Message button

---

### 4.3 Student Enrollment Management
**UI Flow:**
```
Class Details → Students Tab → View Enrollments → 
Approve/Reject | Transfer | Remove
```

**Functionality:**
- ✅ View pending enrollments
- ✅ Approve enrollment requests
- ✅ Reject enrollment requests
- ✅ Manually enroll student
- ✅ Remove student from class
- ✅ Transfer student to different class
- ✅ View enrollment history

**API Endpoint:** `GET /api/v1/enrollment/instructor`

**Conditions:**
- Class must exist
- Class must have available capacity
- Student must not be already enrolled
- User must be class owner

**UI Components:**
- Enrollment request list
- Approve/Reject buttons
- Enrollment form (for manual enrollment)
- Transfer modal
- Remove confirmation

---

## 5. ATTENDANCE MANAGEMENT

### 5.1 Mark Attendance
**UI Flow:**
```
Dashboard → "Attendance" → Select Class → Select Session → 
Mark Present/Absent → Save
```

**Functionality:**
- ✅ View all schedules
- ✅ Select class and session
- ✅ View enrolled students for session
- ✅ Mark attendance (Present/Absent/Late)
- ✅ Bulk mark attendance
- ✅ Add notes per student
- ✅ Export attendance report

**API Endpoints:**
- `GET /api/v1/instructClass` (get all schedules)
- `GET /api/v1/class/enrolled/{scheduleId}` (get students for session)

**Conditions:**
- Session must exist
- Session must be in past or current
- Students must be enrolled
- User must be class owner

**UI Components:**
- Class/session selector
- Student list with attendance checkboxes
- Attendance status indicators (Present/Absent/Late)
- Notes input per student
- Save button
- Export button

---

### 5.2 View Attendance Reports
**UI Flow:**
```
Attendance → "Reports" → Select Class → View Attendance Summary
```

**Functionality:**
- ✅ View attendance by class
- ✅ View attendance by student
- ✅ Calculate attendance percentage
- ✅ View attendance trends
- ✅ Export attendance reports

**Conditions:**
- Class must exist
- Must have attendance records

**UI Components:**
- Class selector
- Attendance summary cards
- Attendance percentage chart
- Student attendance table
- Export button

---

## 6. SCHEDULE MANAGEMENT

### 6.1 View Schedules
**UI Flow:**
```
Dashboard → "Schedules" → Calendar View / List View → 
Filter by Class → View Details
```

**Functionality:**
- ✅ Calendar view (month/week/day)
- ✅ List view
- ✅ Filter by class, date range
- ✅ View schedule details
- ✅ Edit schedule
- ✅ Cancel/reschedule sessions

**API Endpoint:** `GET /api/v1/instructClass/instructor/{instructorId}/schedules`

**Conditions:**
- User must be authenticated
- Valid instructorId

**UI Components:**
- Calendar component
- List view toggle
- Filter controls
- Schedule detail modal
- Edit/Cancel buttons

---

### 6.2 Edit Schedule
**UI Flow:**
```
Schedule Details → "Edit" → Update Time/Date → Save → 
Sync to Google Calendar
```

**Functionality:**
- ✅ Update session time
- ✅ Update session date
- ✅ Add/remove sessions
- ✅ Update Google Calendar events
- ✅ Notify enrolled students

**Conditions:**
- Schedule must exist
- Cannot edit past sessions
- Must notify students of changes
- Google Calendar must be connected

**UI Components:**
- Edit form
- Date/time picker
- Confirmation modal
- Success notification

---

## 7. ACTIVITY MANAGEMENT

### 7.1 View Activities
**UI Flow:**
```
Dashboard → "Activities" → Active/Archived Tabs → 
Activity List → Activity Details
```

**Functionality:**
- ✅ View active activities
- ✅ View archived activities
- ✅ Create new activity
- ✅ Edit activity
- ✅ Archive activity
- ✅ View activity analytics

**API Endpoints:**
- `GET /api/v1/activities/active`
- `GET /api/v1/activities/archived`

**Conditions:**
- User must be authenticated
- User must be instructor

**UI Components:**
- Tab navigation (Active/Archived)
- Activity cards/list
- Create button
- Activity detail modal/page

---

### 7.2 Create/Edit Activity
**UI Flow:**
```
Activities → "Create Activity" → Form → Save
```

**Functionality:**
- ✅ Activity name
- ✅ Activity description
- ✅ Activity category
- ✅ Upload activity image
- ✅ Set activity tags
- ✅ Save activity

**Conditions:**
- Activity name is required
- Image is optional but recommended

**UI Components:**
- Activity form
- Image upload
- Category selector
- Save button

---

## 8. LOCATION/VENUE MANAGEMENT

### 8.1 View Locations
**UI Flow:**
```
Dashboard → "Locations" → Location List → Map View / List View
```

**Functionality:**
- ✅ View all locations
- ✅ Map view with markers
- ✅ List view
- ✅ Filter by area
- ✅ Search locations
- ✅ View location analytics

**API Endpoint:** `GET /api/v1/maps/enhanced`

**Conditions:**
- User must be authenticated

**UI Components:**
- Map component (Google Maps)
- Location list
- View toggle (Map/List)
- Filter controls
- Search bar

---

### 8.2 Add/Edit Location
**UI Flow:**
```
Locations → "Add Location" → Form with Map → Save
```

**Functionality:**
- ✅ Location name
- ✅ Address input
- ✅ Map picker (select on map)
- ✅ Set coordinates
- ✅ Add location details
- ✅ Save location

**Conditions:**
- Location name is required
- Address or coordinates required
- Must be valid location

**UI Components:**
- Location form
- Map picker
- Address autocomplete
- Save button

---

## 9. PAYMENT MANAGEMENT

### 9.1 View Payments
**UI Flow:**
```
Dashboard → "Payments" → Payment List → Filter → Payment Details
```

**Functionality:**
- ✅ View all payments
- ✅ Filter by class, student, date range
- ✅ Filter by payment status
- ✅ Search payments
- ✅ View payment details
- ✅ Generate receipts
- ✅ Export payment reports

**API Endpoint:** `GET /api/v1/enrollment/payment-plans`

**Conditions:**
- User must be authenticated
- User must be instructor

**UI Components:**
- Payment table
- Filter sidebar
- Search bar
- Receipt button
- Export button

---

### 9.2 Payment Analytics
**UI Flow:**
```
Payments → "Analytics" → Charts and Reports
```

**Functionality:**
- ✅ Revenue overview
- ✅ Payment trends
- ✅ Class-wise revenue
- ✅ Student-wise payments
- ✅ Pending payments
- ✅ Export analytics

**Conditions:**
- Must have payment data

**UI Components:**
- Revenue cards
- Charts (line, bar, pie)
- Analytics table
- Export button

---

## 10. CALENDAR INTEGRATION

### 10.1 Google Calendar Sync
**UI Flow:**
```
Settings → "Calendar" → Connect Google Calendar → Authorize → Sync
```

**Functionality:**
- ✅ Connect Google Calendar account
- ✅ Auto-create events for classes
- ✅ Auto-update events on schedule changes
- ✅ Auto-delete events on class cancellation
- ✅ Generate Google Meet links
- ✅ View calendar events

**Conditions:**
- Google account must be connected
- Must grant calendar permissions
- Valid Google OAuth token

**UI Components:**
- Connect button
- Connection status indicator
- Sync settings
- Calendar view

---

## 11. COMMUNICATION

### 11.1 Messaging
**UI Flow:**
```
Dashboard → "Messages" → Select Student → Chat Interface
```

**Functionality:**
- ✅ Send messages to students
- ✅ Receive messages from students
- ✅ Real-time chat
- ✅ File attachments
- ✅ Message history
- ✅ Read receipts

**Conditions:**
- Student must be enrolled in instructor's class
- Both parties must be active users

**UI Components:**
- Message list
- Chat interface
- Message input
- File upload
- Typing indicators

---

### 11.2 Announcements
**UI Flow:**
```
Dashboard → "Announcements" → Create → Select Class → Send
```

**Functionality:**
- ✅ Create announcements
- ✅ Send to specific class or all classes
- ✅ Schedule announcements
- ✅ View announcement history
- ✅ Track read receipts

**Conditions:**
- Must have at least one class
- Must have enrolled students

**UI Components:**
- Announcement form
- Class selector
- Schedule picker
- Announcement list

---

## 12. REPORTS & ANALYTICS

### 12.1 Class Analytics
**UI Flow:**
```
Class Details → "Analytics" Tab → View Charts and Metrics
```

**Functionality:**
- ✅ Enrollment trends
- ✅ Attendance rates
- ✅ Revenue per class
- ✅ Student retention
- ✅ Class performance metrics

**API Endpoint:** `GET /api/v1/api/instructor/classes/{classId}/analytics`

**Conditions:**
- Class must exist
- Must have enrollment data

**UI Components:**
- Analytics dashboard
- Charts (multiple types)
- Metrics cards
- Export button

---

## 13. SETTINGS

### 13.1 Profile Settings
**UI Flow:**
```
Dashboard → Settings → Profile → Edit → Save
```

**Functionality:**
- ✅ Edit profile information
- ✅ Update profile picture
- ✅ Change password
- ✅ Update contact information
- ✅ Update business details

**Conditions:**
- Valid user session
- Email must be unique (if changed)
- Mobile must be unique (if changed)

**UI Components:**
- Profile form
- Image upload
- Password change form
- Save button

---

### 13.2 Notification Settings
**UI Flow:**
```
Settings → Notifications → Toggle Preferences → Save
```

**Functionality:**
- ✅ Email notifications toggle
- ✅ SMS notifications toggle
- ✅ Push notifications toggle
- ✅ WhatsApp notifications toggle
- ✅ Notification preferences per event type

**Conditions:**
- Valid user session

**UI Components:**
- Toggle switches
- Notification type list
- Save button

---

# STUDENT MODULE

## 1. AUTHENTICATION & ONBOARDING

### 1.1 Registration Flow
**UI Flow:**
```
Landing Page → Sign Up → Select "Student" → 
Email/Mobile Verification → Complete Profile → Dashboard
```

**Functionality:**
- ✅ Email/Mobile registration
- ✅ Google OAuth sign-in
- ✅ Apple Sign-in (iOS/Web)
- ✅ OTP verification
- ✅ Profile completion
- ✅ Interest selection

**Conditions:**
- Valid email format OR valid mobile number with country code
- OTP must be verified within 5 minutes
- User must select "Student" as user type
- Profile must include: Name, Email, Mobile, Date of Birth (optional)

**UI Components:**
- Registration form
- OTP input modal
- Profile completion form
- Interest selector (optional)

---

### 1.2 Login Flow
**UI Flow:**
```
Login Page → Email/Mobile + Password → Dashboard
OR
Login Page → Google/Apple Sign-in → Dashboard
```

**Functionality:**
- ✅ Email/Mobile + Password login
- ✅ Social login (Google, Apple)
- ✅ Remember me
- ✅ Forgot password
- ✅ Session management

**Conditions:**
- Valid credentials
- Account must be verified
- Account must not be suspended

**UI Components:**
- Login form
- Social login buttons
- Forgot password link

---

## 2. DASHBOARD

### 2.1 Main Dashboard
**UI Flow:**
```
Dashboard → My Classes → Upcoming Sessions → Recent Activity
```

**Functionality:**
- ✅ Enrolled classes overview
- ✅ Upcoming sessions calendar
- ✅ Recent activity feed
- ✅ Quick actions (Browse Classes, My Schedule)
- ✅ Notifications
- ✅ Progress summary

**Conditions:**
- User must be authenticated
- User type must be "Student"

**UI Components:**
- Class cards
- Calendar widget
- Activity feed
- Quick action buttons
- Notification center

---

## 3. CLASS DISCOVERY & ENROLLMENT

### 3.1 Browse Classes
**UI Flow:**
```
Dashboard → "Browse Classes" → Filter/Search → Class Details → Enroll
```

**Functionality:**
- ✅ Browse all available classes
- ✅ Filter by activity, location, price, date
- ✅ Search classes
- ✅ Sort by price, date, rating
- ✅ View class details
- ✅ View instructor profile
- ✅ Check availability
- ✅ Enroll in class

**Conditions:**
- Classes must be active
- Class must have available capacity
- Student must meet any prerequisites (if any)
- Payment must be completed (if paid class)

**UI Components:**
- Class grid/list
- Filter sidebar
- Search bar
- Sort dropdown
- Class detail modal/page
- Enroll button

---

### 3.2 Class Details
**UI Flow:**
```
Class Card → Click → Class Details Page → 
View: Overview | Schedule | Instructor | Reviews
```

**Functionality:**
- ✅ View class information
- ✅ View schedule
- ✅ View instructor profile
- ✅ View reviews/ratings
- ✅ View location on map
- ✅ Check capacity
- ✅ Enroll button
- ✅ Add to wishlist (if feature exists)

**Conditions:**
- Class must be active
- Class must have capacity

**UI Components:**
- Class header with image
- Tab navigation
- Schedule calendar
- Instructor card
- Reviews section
- Map component
- Enroll button

---

### 3.3 Enrollment Process
**UI Flow:**
```
Class Details → "Enroll" → Payment (if required) → 
Confirmation → Enrollment Success
```

**Functionality:**
- ✅ Select enrollment option (if multiple)
- ✅ Apply discount codes
- ✅ Payment processing
- ✅ Enrollment confirmation
- ✅ Receive confirmation email/SMS
- ✅ Add to calendar

**Conditions:**
- Class must have capacity
- Payment must succeed (if paid)
- Student must not be already enrolled
- All required fields must be filled

**UI Components:**
- Enrollment form
- Payment form
- Discount code input
- Confirmation modal
- Success page

---

## 4. MY CLASSES

### 4.1 View Enrolled Classes
**UI Flow:**
```
Dashboard → "My Classes" → Class List → Filter → Class Details
```

**Functionality:**
- ✅ List all enrolled classes
- ✅ Filter by status (active, completed, upcoming)
- ✅ View class progress
- ✅ Access class materials
- ✅ View schedule
- ✅ View attendance

**Conditions:**
- User must be authenticated
- Must have at least one enrollment

**UI Components:**
- Class cards/list
- Filter tabs
- Progress indicators
- Quick access buttons

---

### 4.2 Class Dashboard
**UI Flow:**
```
My Classes → Select Class → Class Dashboard → 
Tabs: Overview | Schedule | Materials | Progress | Attendance
```

**Functionality:**
- ✅ View class overview
- ✅ View upcoming sessions
- ✅ Access class materials
- ✅ View progress tracking
- ✅ View attendance record
- ✅ View assignments (if any)
- ✅ Submit assignments
- ✅ View grades (if any)

**Conditions:**
- Student must be enrolled
- Class must exist

**UI Components:**
- Class header
- Tab navigation
- Session list
- Materials grid
- Progress charts
- Attendance calendar
- Assignment cards

---

## 5. SCHEDULE & CALENDAR

### 5.1 My Schedule
**UI Flow:**
```
Dashboard → "My Schedule" → Calendar View → 
View Sessions → Join Session (if online)
```

**Functionality:**
- ✅ Calendar view (month/week/day)
- ✅ List all enrolled sessions
- ✅ Filter by class
- ✅ View session details
- ✅ Join Google Meet (if online)
- ✅ Add to personal calendar
- ✅ Set reminders

**Conditions:**
- Must have enrolled classes
- Sessions must be scheduled

**UI Components:**
- Calendar component
- Session list
- Session detail modal
- Join button (for online sessions)
- Add to calendar button

---

### 5.2 Session Details
**UI Flow:**
```
Schedule → Click Session → Session Details → 
View Info | Join | Add to Calendar
```

**Functionality:**
- ✅ View session time and date
- ✅ View location (physical or online)
- ✅ View Google Meet link (if online)
- ✅ View location map (if physical)
- ✅ Join session
- ✅ Cancel attendance (if allowed)

**Conditions:**
- Session must exist
- Student must be enrolled
- Session must be upcoming or current

**UI Components:**
- Session detail card
- Time display
- Location map
- Join button
- Calendar link

---

## 6. ATTENDANCE & PROGRESS

### 6.1 View Attendance
**UI Flow:**
```
Class Dashboard → "Attendance" Tab → View Attendance Record
```

**Functionality:**
- ✅ View attendance for each session
- ✅ View attendance percentage
- ✅ View attendance history
- ✅ See attendance trends

**Conditions:**
- Must be enrolled in class
- Must have attendance records

**UI Components:**
- Attendance calendar
- Attendance percentage card
- Attendance table
- Trend chart

---

### 6.2 View Progress
**UI Flow:**
```
Class Dashboard → "Progress" Tab → View Progress Tracking
```

**Functionality:**
- ✅ View overall progress
- ✅ View progress by module/topic
- ✅ View completed sessions
- ✅ View upcoming sessions
- ✅ View milestones achieved

**Conditions:**
- Must be enrolled
- Class must have progress tracking enabled

**UI Components:**
- Progress bar
- Progress chart
- Milestone badges
- Session completion list

---

## 7. PAYMENTS

### 7.1 Payment History
**UI Flow:**
```
Dashboard → "Payments" → Payment List → Payment Details → Receipt
```

**Functionality:**
- ✅ View all payments
- ✅ Filter by class, date, status
- ✅ View payment details
- ✅ Download receipts
- ✅ View payment plans
- ✅ Make payment (if pending)

**API Endpoint:** `GET /api/v1/student/{studentId}/payment-data`

**Conditions:**
- User must be authenticated
- Must have payment records

**UI Components:**
- Payment table
- Filter controls
- Payment detail modal
- Receipt download button
- Pay button (for pending)

---

### 7.2 Make Payment
**UI Flow:**
```
Payment History → "Pay Now" → Payment Form → 
Select Method → Process → Confirmation
```

**Functionality:**
- ✅ Select payment method
- ✅ Enter payment details
- ✅ Apply discount codes
- ✅ Process payment
- ✅ Receive confirmation
- ✅ Download receipt

**Conditions:**
- Payment must be pending
- Valid payment method
- Sufficient funds (if applicable)

**UI Components:**
- Payment form
- Payment method selector
- Discount code input
- Process button
- Confirmation modal

---

## 8. COMMUNICATION

### 8.1 Messaging with Instructor
**UI Flow:**
```
Class Dashboard → "Message Instructor" → Chat Interface
```

**Functionality:**
- ✅ Send messages to instructor
- ✅ Receive messages from instructor
- ✅ Real-time chat
- ✅ File attachments
- ✅ Message history

**Conditions:**
- Must be enrolled in instructor's class
- Both parties must be active

**UI Components:**
- Chat interface
- Message list
- Message input
- File upload

---

### 8.2 View Announcements
**UI Flow:**
```
Dashboard → "Announcements" → View All → Mark as Read
```

**Functionality:**
- ✅ View class announcements
- ✅ Filter by class
- ✅ Mark as read
- ✅ View announcement details

**Conditions:**
- Must be enrolled in at least one class

**UI Components:**
- Announcement list
- Announcement cards
- Filter dropdown
- Read/unread indicators

---

## 9. MATERIALS & RESOURCES

### 9.1 Access Class Materials
**UI Flow:**
```
Class Dashboard → "Materials" Tab → Browse → Download/View
```

**Functionality:**
- ✅ View all class materials
- ✅ Download materials
- ✅ View online (if supported)
- ✅ Filter by type (PDF, Video, etc.)
- ✅ Search materials

**Conditions:**
- Must be enrolled
- Materials must be available

**UI Components:**
- Materials grid/list
- Material cards
- Download button
- Preview button
- Filter controls

---

## 10. PROFILE & SETTINGS

### 10.1 Profile Management
**UI Flow:**
```
Dashboard → Profile → Edit → Save
```

**Functionality:**
- ✅ View profile
- ✅ Edit profile information
- ✅ Update profile picture
- ✅ Change password
- ✅ Update contact information

**Conditions:**
- Valid user session
- Email must be unique (if changed)

**UI Components:**
- Profile form
- Image upload
- Password change form

---

### 10.2 Notification Settings
**UI Flow:**
```
Settings → Notifications → Toggle Preferences → Save
```

**Functionality:**
- ✅ Email notifications
- ✅ SMS notifications
- ✅ Push notifications
- ✅ WhatsApp notifications
- ✅ Notification preferences

**Conditions:**
- Valid user session

**UI Components:**
- Toggle switches
- Notification list
- Save button

---

# CONDITIONS AND PREREQUISITES

## Common Conditions

### Authentication
- ✅ Valid JWT token required for all authenticated endpoints
- ✅ Token must not be expired
- ✅ User account must be active (not suspended/deleted)
- ✅ User must have verified email/mobile

### Authorization
- ✅ User must have correct user_type (Instructor/Student)
- ✅ User must own the resource (for edit/delete operations)
- ✅ User must have required permissions (if permission system exists)

### Data Validation
- ✅ All required fields must be provided
- ✅ Data types must match expected format
- ✅ Data must pass validation rules
- ✅ File uploads must meet size/type restrictions

### Business Rules
- ✅ Classes must have capacity > 0
- ✅ Cannot enroll if class is full
- ✅ Cannot edit past sessions
- ✅ Cannot delete classes with active enrollments
- ✅ Payments must be completed before enrollment (for paid classes)

---

## Instructor-Specific Conditions

### Class Management
- ✅ Must have at least one activity created
- ✅ Must have at least one location created
- ✅ Google Calendar must be connected (for auto-sync)
- ✅ Cannot reduce capacity below current enrollment
- ✅ Must notify students of schedule changes

### Student Management
- ✅ Student must be enrolled in instructor's class
- ✅ Cannot remove student if payment is pending
- ✅ Must have valid instructor ID

### Attendance
- ✅ Session must exist
- ✅ Session must be in past or current
- ✅ Students must be enrolled

---

## Student-Specific Conditions

### Enrollment
- ✅ Class must be active
- ✅ Class must have available capacity
- ✅ Payment must be completed (if required)
- ✅ Student must not be already enrolled
- ✅ Must meet prerequisites (if any)

### Access
- ✅ Must be enrolled to access class materials
- ✅ Must be enrolled to view attendance
- ✅ Must be enrolled to message instructor

---

# END-TO-END USER JOURNEY MAPS

## Instructor Journey: Creating and Managing a Class

```
1. Login → Dashboard
2. Dashboard → "Create Class"
3. Create Class Wizard:
   - Step 1: Select/Create Activity
   - Step 2: Select/Create Location
   - Step 3: Set Schedule (days, times, timezone)
   - Step 4: Set Capacity & Pricing
   - Step 5: Add Description & Media
   - Step 6: Review & Publish
4. Class Created → Auto-sync to Google Calendar
5. Dashboard → "My Classes" → View New Class
6. Class Details → View Enrollments
7. Students Tab → View Enrolled Students
8. Attendance Tab → Mark Attendance for Session
9. Analytics Tab → View Class Performance
10. Payments → View Payment Records
```

## Student Journey: Discovering and Enrolling in a Class

```
1. Login → Dashboard
2. Dashboard → "Browse Classes"
3. Browse → Filter by Activity/Location
4. Class Card → Click → View Details
5. Class Details → Review Schedule, Instructor, Price
6. "Enroll" Button → Enrollment Form
7. Payment (if required) → Process Payment
8. Enrollment Confirmation → Added to "My Classes"
9. My Classes → Select Class → Class Dashboard
10. Class Dashboard → View Schedule
11. Schedule → View Upcoming Sessions
12. Session → Join (if online) or View Location
13. Class Dashboard → View Attendance
14. Class Dashboard → Access Materials
15. Class Dashboard → Message Instructor
```

---

## UI Navigation Flow Diagram

### Instructor Module Navigation
```
Dashboard
├── My Classes
│   ├── Class List
│   ├── Class Details
│   │   ├── Overview
│   │   ├── Students
│   │   ├── Sessions
│   │   ├── Analytics
│   │   └── Materials
│   └── Create Class
├── Students
│   ├── Student List
│   └── Student Details
│       ├── Overview
│       ├── Enrollments
│       ├── Attendance
│       ├── Progress
│       ├── Payments
│       └── Notes
├── Attendance
│   ├── Mark Attendance
│   └── Reports
├── Schedules
│   └── Calendar View
├── Activities
│   ├── Active
│   └── Archived
├── Locations
│   └── Map View
├── Payments
│   ├── Payment List
│   └── Analytics
├── Messages
├── Announcements
└── Settings
    ├── Profile
    └── Notifications
```

### Student Module Navigation
```
Dashboard
├── My Classes
│   ├── Class List
│   └── Class Dashboard
│       ├── Overview
│       ├── Schedule
│       ├── Materials
│       ├── Progress
│       └── Attendance
├── Browse Classes
│   ├── Class Grid
│   └── Class Details
├── My Schedule
│   └── Calendar View
├── Payments
│   ├── Payment History
│   └── Make Payment
├── Messages
├── Announcements
└── Settings
    ├── Profile
    └── Notifications
```

---

# SUMMARY CHECKLIST

## Instructor Module - Must Have Features
- [x] Authentication (Email/Mobile, Google, Apple)
- [x] Dashboard with statistics
- [x] Create/Edit/Delete Classes
- [x] Manage Students (View, Enroll, Remove)
- [x] Mark Attendance
- [x] Schedule Management
- [x] Activity Management
- [x] Location Management
- [x] Payment Management
- [x] Google Calendar Integration
- [x] Messaging
- [x] Reports & Analytics
- [x] Settings

## Student Module - Must Have Features
- [x] Authentication (Email/Mobile, Google, Apple)
- [x] Dashboard
- [x] Browse Classes
- [x] Enroll in Classes
- [x] View My Classes
- [x] View Schedule
- [x] View Attendance
- [x] View Progress
- [x] Make Payments
- [x] Access Materials
- [x] Message Instructor
- [x] View Announcements
- [x] Settings

---

**Document Version:** 1.0  
**Last Updated:** 2025-01-27  
**Status:** Complete Functionality Map

