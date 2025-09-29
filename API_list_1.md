# API Documentation

## Table of Contents
- [Class Management Dashboard](#class-management-dashboard)
- [View Class Details](#view-class-details)
- [Student Management](#student-management)
  - [Student List](#student-list)
  - [Student Activity Details](#student-activity-details)
  - [Student Payment Data](#student-payment-data)
  - [Student Attendance Data](#student-attendance-data)
  - [Student Progress Data](#student-progress-data)
  - [Student Enrollment Data](#student-enrollment-data)
  - [View Student Detail](#view-student-detail)
- [Schedule Management](#schedule-management)

---

## Class Management Dashboard

### Get Dashboard Statistics

**Endpoint:** `GET /api/v1/instructClass/dashboard/stats`

**Query Parameters:**
- `user_type`: Instructor
- `scopeId`: 68d6cbdfbbc70a13d02ec3f3

**Request:**
```bash
curl 'https://dev.classintown.com/api/v1/instructClass/dashboard/stats?user_type=Instructor&scopeId=68d6cbdfbbc70a13d02ec3f3' \
  -H 'accept: application/json' \
  -H 'accept-language: en-US,en;q=0.9' \
  -H 'authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNjhkNmNiZGZiYmM3MGExM2QwMmVjM2YzIiwiZW1haWwiOiJzaGFzaGFua0BjbGFzc2ludG93bi5jb20iLCJ1c2VyX3R5cGUiOiJJbnN0cnVjdG9yIiwidXNlcl9yb2xlIjoiSW5zdHJ1Y3RvciIsIm1vYmlsZSI6OTM3MDMwMzY5Mywid2hhdHNhcHBfbm90aWZpY2F0aW9uc19lbmFibGVkIjp0cnVlLCJlbWFpbF9ub3RpZmljYXRpb25zX2VuYWJsZWQiOnRydWUsInB1c2hfbm90aWZpY2F0aW9uc19lbmFibGVkIjp0cnVlLCJqdGkiOiIwMDk4ZTE1Yi05YmQ3LTRiMTItOTRjZi1jMTk0ZmE0N2MyYzEiLCJpc3MiOiJDbGFzc0luVG93biIsImF1ZCI6IkNsYXNzSW5Ub3duLVVzZXJzIiwiaWF0IjoxNzU5MTY5OTg1LCJuYmYiOjE3NTkxNjk5ODUsImV4cCI6MTc1OTI1NjM4NX0.hjqXdjU1DbZ4yi5FGOncOMWL8mGM1YOHNyph21OiFpE' \
  -H 'content-type: application/json'
```

**Response:**
```json
{
    "success": true,
    "status": "success",
    "statusCode": 200,
    "message": "Dashboard statistics retrieved successfully",
    "data": {
        "user_id": "68d6cbdfbbc70a13d02ec3f3",
        "user_type": "Instructor",
        "totalClassesCount": 2,
        "ongoingClassCount": 1,
        "upcomingClassCount": 1,
        "completedClassCount": 0,
        "monthlyClassCounts": [
            {
                "year": 2025,
                "monthName": "September",
                "totalClasses": 2
            }
        ],
        "recentSchedules": [
            {
                "_id": "68daa4374cefccca294a2464",
                "user_id": "68d6cbdfbbc70a13d02ec3f3",
                "activity": {
                    "_id": "68d6cdc9812bb5bd84324a2d",
                    "activity_name": "acitivy",
                    "media": "public/activities/media/images/8ecd1543-a4ff-4dac-a062-a7cae27c36b6.jpg"
                },
                "location": {
                    "_id": "68daa3b04cefccca294a1d5c",
                    "title": "SDS by KUSHAL SHAH, Kala Ghoda, Mumbai"
                },
                "classType": "duration",
                "schedules": [
                    {
                        "_id": "68daa4324cefccca294a244f",
                        "day": "Tuesday",
                        "slots": [
                            {
                                "_id": "68daa4324cefccca294a2450",
                                "event_id": "8ivged0v4334qldrf1bjafq7i8",
                                "google_meet_link": "https://meet.google.com/mzh-nmnx-rjq",
                                "calendar_link": "https://www.google.com/calendar/event?eid=OGl2Z2VkMHY0MzM0cWxkcmYxYmphZnE3aTggc2hhc2hhbmtAY2xhc3NpbnRvd24uY29t",
                                "comment": null,
                                "start": {
                                    "dateTime": "2025-09-29T19:30:00.000Z",
                                    "timeZone": "Asia/Calcutta"
                                },
                                "end": {
                                    "dateTime": "2025-09-29T20:30:00.000Z",
                                    "timeZone": "Asia/Calcutta"
                                },
                                "is_past": false,
                                "is_past_updated_by": null,
                                "is_past_updated_at": null
                            }
                        ]
                    }
                ],
                "capacity": 10,
                "waitlist": 0,
                "full_price": 1200
            }
        ]
    }
}
```

---

## View Class Details

### Get Class by ID

**Endpoint:** `GET /api/v1/api/instructor/classes/{classId}`

**Path Parameters:**
- `classId`: 68daa4074cefccca294a1d85

**Request:**
```bash
curl 'https://dev.classintown.com/api/v1/api/instructor/classes/68daa4074cefccca294a1d85' \
  -H 'accept: application/json' \
  -H 'accept-language: en-US,en;q=0.9' \
  -H 'authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...' \
  -H 'content-type: application/json'
```

### Get Class Analytics

**Endpoint:** `GET /api/v1/api/instructor/classes/{classId}/analytics`

**Request:**
```bash
curl 'https://dev.classintown.com/api/v1/api/instructor/classes/68daa4074cefccca294a1d85/analytics' \
  -H 'accept: application/json' \
  -H 'accept-language: en-US,en;q=0.9' \
  -H 'authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...' \
  -H 'content-type: application/json'
```

### Get Class Sessions

**Endpoint:** `GET /api/v1/api/instructor/classes/{classId}/sessions`

**Request:**
```bash
curl 'https://dev.classintown.com/api/v1/api/instructor/classes/68daa4074cefccca294a1d85/sessions' \
  -H 'accept: application/json' \
  -H 'accept-language: en-US,en;q=0.9' \
  -H 'authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...' \
  -H 'content-type: application/json'
```

### Get Class Students

**Endpoint:** `GET /api/v1/api/instructor/classes/{classId}/students`

**Query Parameters:**
- `limit`: 50

**Request:**
```bash
curl 'https://dev.classintown.com/api/v1/api/instructor/classes/68daa4074cefccca294a1d85/students?limit=50' \
  -H 'accept: application/json' \
  -H 'accept-language: en-US,en;q=0.9' \
  -H 'authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...' \
  -H 'content-type: application/json'
```

### Get Class Materials

**Endpoint:** `GET /api/v1/api/instructor/classes/{classId}/materials`

**Request:**
```bash
curl 'https://dev.classintown.com/api/v1/api/instructor/classes/68daa4074cefccca294a1d85/materials' \
  -H 'accept: application/json' \
  -H 'accept-language: en-US,en;q=0.9' \
  -H 'authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...' \
  -H 'content-type: application/json'
```

---

## Student Management

### Student List

**Endpoint:** `GET /api/v1/class/students/{instructorId}`

**Path Parameters:**
- `instructorId`: 68d17bbe53f6535b32286266

**Request:**
```bash
curl 'https://dev.classintown.com/api/v1/class/students/68d17bbe53f6535b32286266' \
  -H 'accept: application/json' \
  -H 'accept-language: en-US,en;q=0.9' \
  -H 'authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...' \
  -H 'content-type: application/json'
```

### Student Activity Details

**Endpoint:** `GET /api/v1/activities/active`

**Description:** Get activity details related to student

**Request:**
```bash
curl 'https://dev.classintown.com/api/v1/activities/active' \
  -H 'accept: application/json' \
  -H 'accept-language: en-US,en;q=0.9' \
  -H 'authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...' \
  -H 'content-type: application/json'
```

### Student Payment Data

**Endpoint:** `GET /api/v1/student/{studentId}/payment-data`

**Path Parameters:**
- `studentId`: 68d1815b53f6535b32287640

**Request:**
```bash
curl 'https://dev.classintown.com/api/v1/student/68d1815b53f6535b32287640/payment-data' \
  -H 'accept: application/json' \
  -H 'accept-language: en-US,en;q=0.9' \
  -H 'authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...' \
  -H 'content-type: application/json'
```

### Student Attendance Data

**Endpoint:** `GET /api/v1/student/{studentId}/attendance-data`

**Path Parameters:**
- `studentId`: 68d1815b53f6535b32287640

**Request:**
```bash
curl 'https://dev.classintown.com/api/v1/student/68d1815b53f6535b32287640/attendance-data' \
  -H 'accept: application/json' \
  -H 'accept-language: en-US,en;q=0.9' \
  -H 'authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...' \
  -H 'content-type: application/json'
```

### Student Progress Data

**Endpoint:** `GET /api/v1/student/{studentId}/progress-data`

**Path Parameters:**
- `studentId`: 68d1815b53f6535b32287640

**Request:**
```bash
curl 'https://dev.classintown.com/api/v1/student/68d1815b53f6535b32287640/progress-data' \
  -H 'accept: application/json' \
  -H 'accept-language: en-US,en;q=0.9' \
  -H 'authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...' \
  -H 'content-type: application/json'
```

### Student Enrollment Data

**Endpoint:** `GET /api/v1/student/{studentId}/enrollment-data`

**Path Parameters:**
- `studentId`: 68d1815b53f6535b32287640

**Request:**
```bash
curl 'https://dev.classintown.com/api/v1/student/68d1815b53f6535b32287640/enrollment-data' \
  -H 'accept: application/json' \
  -H 'accept-language: en-US,en;q=0.9' \
  -H 'authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...' \
  -H 'content-type: application/json'
```

### View Student Detail

**Endpoint:** `GET /api/v1/student/instructor/{instructorId}/student/{studentId}`

**Path Parameters:**
- `instructorId`: 68d17bbe53f6535b32286266
- `studentId`: 68d6baf72d36a78258eff82b

**Request:**
```bash
curl 'https://dev.classintown.com/api/v1/student/instructor/68d17bbe53f6535b32286266/student/68d6baf72d36a78258eff82b' \
  -H 'accept: application/json' \
  -H 'accept-language: en-US,en;q=0.9' \
  -H 'authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...' \
  -H 'content-type: application/json'
```

---

## Schedule Management

### Get Schedules to Enroll

**Endpoint:** `GET /api/v1/instructClass/instructor/{instructorId}/schedules`

**Path Parameters:**
- `instructorId`: 68d17bbe53f6535b32286266

**Request:**
```bash
curl 'https://dev.classintown.com/api/v1/instructClass/instructor/68d17bbe53f6535b32286266/schedules' \
  -H 'accept: application/json' \
  -H 'accept-language: en-US,en;q=0.9' \
  -H 'authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...' \
  -H 'content-type: application/json'
```

---

## Notes

- All endpoints require authentication via Bearer token
- Base URL: `https://dev.classintown.com`
- All responses are in JSON format
- Standard headers include:
  - `accept: application/json`
  - `content-type: application/json`
  - `authorization: Bearer {token}` 
