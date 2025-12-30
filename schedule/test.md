# Count-based Class Scheduling — Edge Case Test Matrix (Markdown)

_Last updated: 2025-12-30_

This document is a **manual test checklist** for **count-based class scheduling**. It is designed so a tester can execute tests independently with consistent steps, copy/paste API examples, and clear verification points.

## How to use

1. Pick a test case (TC) below.
2. Follow **Preconditions / Setup**, then **Steps**.
3. Collect evidence (UI screenshot, request/response, DB query output, calendar screenshot).
4. Mark pass/fail and record deviations.

## Assumptions & placeholders (edit once for your project)

- API base URL: set `BASE_URL` (e.g., `https://staging.example.com`)
- Auth token: set `TOKEN`
- Instructor under test: `inst_001`
- Default timezone used in examples: `Asia/Kolkata`
- Example DB tables/columns: `classes`, `class_slots` (adjust queries to your schema)
- Calendar: Google Calendar (or equivalent) with per-slot `eventId`

### Environment variables for copy/paste commands

```bash
export BASE_URL='https://YOUR_ENV_BASE_URL'
export TOKEN='YOUR_BEARER_TOKEN'
```
### Product policy switches (record what your system is expected to do)

- [ ] POLICY_ALLOW_EDIT_PAST_SLOTS = true
- [ ] POLICY_ALLOW_EDIT_PAST_SLOTS = false
- [ ] POLICY_ALLOW_DELETE_PAST_SLOTS = true
- [ ] POLICY_ALLOW_DELETE_PAST_SLOTS = false
- [ ] POLICY_ALLOW_OVERRIDE_CONFLICTS_WITH_OTHER_CLASSES = true
- [ ] POLICY_ALLOW_OVERRIDE_CONFLICTS_WITH_OTHER_CLASSES = false
- [ ] POLICY_BLOCK_DELETE_ENROLLED_SLOT = true
- [ ] POLICY_BLOCK_DELETE_ENROLLED_SLOT = false
- [ ] POLICY_CONCURRENCY = last-write-wins
- [ ] POLICY_CONCURRENCY = optimistic-locking

### Evidence to capture for every TC

- UI screenshot(s) showing slot list + any validation errors
- Network request/response (HAR or screenshot)
- DB query output relevant to the test
- Calendar screenshot (if calendar sync is in scope for that test)
- Any logs / error IDs for failures

### Common endpoints used in examples (adjust paths/params)

```text
POST   /api/classes
PUT    /api/classes/{classId}
GET    /api/classes/{classId}
GET    /api/availability/busy-slots?instructorId=...&startDate=YYYY-MM-DD&endDate=YYYY-MM-DD&timeZone=...
GET    /api/availability/check?instructorId=...&date=YYYY-MM-DD&startTime=HH:MM&endTime=HH:MM&timeZone=...
```
## Table of contents

- [1. Create flow](#1-create-flow)
- [2. Edit flow](#2-edit-flow)
- [3. Update scenarios (mid-state)](#3-update-scenarios-mid-state)
- [4. Delete / remove slot cases](#4-delete--remove-slot-cases)
- [5. Availability & busy-slots edge cases](#5-availability--busy-slots-edge-cases)
- [6. Timezone & date-boundary cases](#6-timezone--date-boundary-cases)
- [7. Self-conflict & exclusion logic](#7-self-conflict--exclusion-logic)
- [8. Sync consistency checks](#8-sync-consistency-checks)
- [9. Failure & recovery cases](#9-failure--recovery-cases)


## 1. Create flow

### TC 1.1.1 — Create class with classCount = 1

**Goal:** Validate successful create path and 1:1 consistency (UI ↔ payload ↔ DB ↔ Calendar ↔ busy-slots).

**Preconditions / Setup**

- Default timezone set to `Asia/Kolkata` (or set in payload).
- Instructor `inst_001` has calendar sync enabled.

**Steps**

1. Open Create Class form → choose `classType = count`.
1. Set `classCount = 1`.
1. Add slots: 2026-01-05 09:00–10:00.
1. Click **Save**.

**Copy/paste examples**

```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "TC-1.1.1",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 1,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      }
    ]
  }
}
JSON
```
```bash
curl -sS "$BASE_URL/api/availability/busy-slots?instructorId=inst_001&startDate=2026-01-05&endDate=2026-01-05&timeZone=Asia/Kolkata" -H "Authorization: Bearer $TOKEN" | jq
```

**Expected results**

- UI: Form is valid; slots render exactly as entered.
- API: `POST /api/classes` returns **201** and includes `classId` plus created `slotId` values.
- DB: Exactly **1** non-deleted slot rows exist for the new class.
- Calendar: Exactly **1** calendar events exist and match each slot (no duplicates).
- Availability: `busy-slots` for the relevant date(s) includes the created slot(s).

**DB checks (examples)**

```sql
SELECT COUNT(*) FROM class_slots WHERE class_id = '<classId>' AND is_deleted = false;
```
```sql
SELECT slot_id, start_utc, end_utc, event_id FROM class_slots WHERE class_id = '<classId>' ORDER BY start_utc;
```

**Calendar checks**

- Verify event title contains `TC-{cid}` (or whatever naming convention you use).
- Verify each event's start/end matches slot start/end in the instructor's timezone.

**Notes**

- Capture network request/response and calendar screenshot.

---

### TC 1.1.2 — Create class with classCount = 2, add 2 slots same day

**Goal:** Validate successful create path and 1:1 consistency (UI ↔ payload ↔ DB ↔ Calendar ↔ busy-slots).

**Preconditions / Setup**

- Default timezone set to `Asia/Kolkata` (or set in payload).
- Instructor `inst_001` has calendar sync enabled.

**Steps**

1. Open Create Class form → choose `classType = count`.
1. Set `classCount = 2`.
1. Add slots: 2026-01-05 09:00–10:00, 2026-01-05 14:00–15:00.
1. Click **Save**.

**Copy/paste examples**

```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "TC-1.1.2",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    },
    {
      "start": "2026-01-05T14:00:00+05:30",
      "end": "2026-01-05T15:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "startLocal": "2026-01-05T14:00:00+05:30",
        "endLocal": "2026-01-05T15:00:00+05:30",
        "startUtc": "2026-01-05T08:30:00Z",
        "endUtc": "2026-01-05T09:30:00Z"
      }
    ]
  }
}
JSON
```
```bash
curl -sS "$BASE_URL/api/availability/busy-slots?instructorId=inst_001&startDate=2026-01-05&endDate=2026-01-05&timeZone=Asia/Kolkata" -H "Authorization: Bearer $TOKEN" | jq
```

**Expected results**

- UI: Form is valid; slots render exactly as entered.
- API: `POST /api/classes` returns **201** and includes `classId` plus created `slotId` values.
- DB: Exactly **2** non-deleted slot rows exist for the new class.
- Calendar: Exactly **2** calendar events exist and match each slot (no duplicates).
- Availability: `busy-slots` for the relevant date(s) includes the created slot(s).

**DB checks (examples)**

```sql
SELECT COUNT(*) FROM class_slots WHERE class_id = '<classId>' AND is_deleted = false;
```
```sql
SELECT slot_id, start_utc, end_utc, event_id FROM class_slots WHERE class_id = '<classId>' ORDER BY start_utc;
```

**Calendar checks**

- Verify event title contains `TC-{cid}` (or whatever naming convention you use).
- Verify each event's start/end matches slot start/end in the instructor's timezone.

**Notes**

- Capture network request/response and calendar screenshot.

---

### TC 1.1.3 — Create class with classCount = 2, add 2 slots different days

**Goal:** Validate successful create path and 1:1 consistency (UI ↔ payload ↔ DB ↔ Calendar ↔ busy-slots).

**Preconditions / Setup**

- Default timezone set to `Asia/Kolkata` (or set in payload).
- Instructor `inst_001` has calendar sync enabled.

**Steps**

1. Open Create Class form → choose `classType = count`.
1. Set `classCount = 2`.
1. Add slots: 2026-01-05 09:00–10:00, 2026-01-06 09:00–10:00.
1. Click **Save**.

**Copy/paste examples**

```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "TC-1.1.3",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    },
    {
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "startLocal": "2026-01-06T09:00:00+05:30",
        "endLocal": "2026-01-06T10:00:00+05:30",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      }
    ]
  }
}
JSON
```
```bash
curl -sS "$BASE_URL/api/availability/busy-slots?instructorId=inst_001&startDate=2026-01-05&endDate=2026-01-06&timeZone=Asia/Kolkata" -H "Authorization: Bearer $TOKEN" | jq
```

**Expected results**

- UI: Form is valid; slots render exactly as entered.
- API: `POST /api/classes` returns **201** and includes `classId` plus created `slotId` values.
- DB: Exactly **2** non-deleted slot rows exist for the new class.
- Calendar: Exactly **2** calendar events exist and match each slot (no duplicates).
- Availability: `busy-slots` for the relevant date(s) includes the created slot(s).

**DB checks (examples)**

```sql
SELECT COUNT(*) FROM class_slots WHERE class_id = '<classId>' AND is_deleted = false;
```
```sql
SELECT slot_id, start_utc, end_utc, event_id FROM class_slots WHERE class_id = '<classId>' ORDER BY start_utc;
```

**Calendar checks**

- Verify event title contains `TC-{cid}` (or whatever naming convention you use).
- Verify each event's start/end matches slot start/end in the instructor's timezone.

**Notes**

- Capture network request/response and calendar screenshot.

---

### TC 1.1.4 — Create class with classCount = 3, add slots spanning 3 weeks

**Goal:** Validate successful create path and 1:1 consistency (UI ↔ payload ↔ DB ↔ Calendar ↔ busy-slots).

**Preconditions / Setup**

- Default timezone set to `Asia/Kolkata` (or set in payload).
- Instructor `inst_001` has calendar sync enabled.

**Steps**

1. Open Create Class form → choose `classType = count`.
1. Set `classCount = 3`.
1. Add slots: 2026-01-05 09:00–10:00, 2026-01-12 09:00–10:00, 2026-01-19 09:00–10:00.
1. Click **Save**.

**Copy/paste examples**

```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "TC-1.1.4",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 3,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    },
    {
      "start": "2026-01-12T09:00:00+05:30",
      "end": "2026-01-12T10:00:00+05:30"
    },
    {
      "start": "2026-01-19T09:00:00+05:30",
      "end": "2026-01-19T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "startLocal": "2026-01-12T09:00:00+05:30",
        "endLocal": "2026-01-12T10:00:00+05:30",
        "startUtc": "2026-01-12T03:30:00Z",
        "endUtc": "2026-01-12T04:30:00Z"
      },
      {
        "startLocal": "2026-01-19T09:00:00+05:30",
        "endLocal": "2026-01-19T10:00:00+05:30",
        "startUtc": "2026-01-19T03:30:00Z",
        "endUtc": "2026-01-19T04:30:00Z"
      }
    ]
  }
}
JSON
```
```bash
curl -sS "$BASE_URL/api/availability/busy-slots?instructorId=inst_001&startDate=2026-01-05&endDate=2026-01-19&timeZone=Asia/Kolkata" -H "Authorization: Bearer $TOKEN" | jq
```

**Expected results**

- UI: Form is valid; slots render exactly as entered.
- API: `POST /api/classes` returns **201** and includes `classId` plus created `slotId` values.
- DB: Exactly **3** non-deleted slot rows exist for the new class.
- Calendar: Exactly **3** calendar events exist and match each slot (no duplicates).
- Availability: `busy-slots` for the relevant date(s) includes the created slot(s).

**DB checks (examples)**

```sql
SELECT COUNT(*) FROM class_slots WHERE class_id = '<classId>' AND is_deleted = false;
```
```sql
SELECT slot_id, start_utc, end_utc, event_id FROM class_slots WHERE class_id = '<classId>' ORDER BY start_utc;
```

**Calendar checks**

- Verify event title contains `TC-{cid}` (or whatever naming convention you use).
- Verify each event's start/end matches slot start/end in the instructor's timezone.

**Notes**

- Capture network request/response and calendar screenshot.

---

### TC 1.2.1 — Add MORE slots than classCount

**Goal:** Validate mismatch/invalid create requests are blocked and do not create partial state.

**Preconditions / Setup**

- Default timezone set to `Asia/Kolkata`.

**Steps**

1. Open Create Class form → choose `classType = count`.
1. Set `classCount = 2`.
1. Add slots: 2026-01-05 09:00–10:00, 2026-01-06 09:00–10:00, 2026-01-07 09:00–10:00.
1. Attempt to click **Save**.

**Copy/paste examples**

```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "TC-1.2.1",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    },
    {
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30"
    },
    {
      "start": "2026-01-07T09:00:00+05:30",
      "end": "2026-01-07T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "startLocal": "2026-01-06T09:00:00+05:30",
        "endLocal": "2026-01-06T10:00:00+05:30",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      },
      {
        "startLocal": "2026-01-07T09:00:00+05:30",
        "endLocal": "2026-01-07T10:00:00+05:30",
        "startUtc": "2026-01-07T03:30:00Z",
        "endUtc": "2026-01-07T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Expected results**

- UI: Shows validation error and prevents submission.
- API: If request is sent, server returns **400** (or 422) with message like: `Number of slots (3) exceeds classCount (2)`.
- DB: No class/slot rows created (or transaction rolled back).
- Calendar: No events created.

**DB checks (examples)**

```sql
SELECT COUNT(*) FROM classes WHERE title = 'TC-{cid}';
```

**Notes**

- If UI blocks submission, confirm **no network request** is made.

---

### TC 1.2.2 — Add FEWER slots than classCount

**Goal:** Validate mismatch/invalid create requests are blocked and do not create partial state.

**Preconditions / Setup**

- Default timezone set to `Asia/Kolkata`.

**Steps**

1. Open Create Class form → choose `classType = count`.
1. Set `classCount = 3`.
1. Add slots: 2026-01-05 09:00–10:00, 2026-01-06 09:00–10:00.
1. Attempt to click **Save**.

**Copy/paste examples**

```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "TC-1.2.2",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 3,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    },
    {
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "startLocal": "2026-01-06T09:00:00+05:30",
        "endLocal": "2026-01-06T10:00:00+05:30",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Expected results**

- UI: Shows validation error and prevents submission.
- API: If request is sent, server returns **400** (or 422) with message like: `Number of slots (2) is less than classCount (3)`.
- DB: No class/slot rows created (or transaction rolled back).
- Calendar: No events created.

**DB checks (examples)**

```sql
SELECT COUNT(*) FROM classes WHERE title = 'TC-{cid}';
```

**Notes**

- If UI blocks submission, confirm **no network request** is made.

---

### TC 1.2.3 — Add EXACTLY classCount slots

**Goal:** Validate successful create path and 1:1 consistency (UI ↔ payload ↔ DB ↔ Calendar ↔ busy-slots).

**Preconditions / Setup**

- Default timezone set to `Asia/Kolkata` (or set in payload).
- Instructor `inst_001` has calendar sync enabled.

**Steps**

1. Open Create Class form → choose `classType = count`.
1. Set `classCount = 3`.
1. Add slots: 2026-01-05 09:00–10:00, 2026-01-06 09:00–10:00, 2026-01-07 09:00–10:00.
1. Click **Save**.

**Copy/paste examples**

```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "TC-1.2.3",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 3,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    },
    {
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30"
    },
    {
      "start": "2026-01-07T09:00:00+05:30",
      "end": "2026-01-07T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "startLocal": "2026-01-06T09:00:00+05:30",
        "endLocal": "2026-01-06T10:00:00+05:30",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      },
      {
        "startLocal": "2026-01-07T09:00:00+05:30",
        "endLocal": "2026-01-07T10:00:00+05:30",
        "startUtc": "2026-01-07T03:30:00Z",
        "endUtc": "2026-01-07T04:30:00Z"
      }
    ]
  }
}
JSON
```
```bash
curl -sS "$BASE_URL/api/availability/busy-slots?instructorId=inst_001&startDate=2026-01-05&endDate=2026-01-07&timeZone=Asia/Kolkata" -H "Authorization: Bearer $TOKEN" | jq
```

**Expected results**

- UI: Form is valid; slots render exactly as entered.
- API: `POST /api/classes` returns **201** and includes `classId` plus created `slotId` values.
- DB: Exactly **3** non-deleted slot rows exist for the new class.
- Calendar: Exactly **3** calendar events exist and match each slot (no duplicates).
- Availability: `busy-slots` for the relevant date(s) includes the created slot(s).

**DB checks (examples)**

```sql
SELECT COUNT(*) FROM class_slots WHERE class_id = '<classId>' AND is_deleted = false;
```
```sql
SELECT slot_id, start_utc, end_utc, event_id FROM class_slots WHERE class_id = '<classId>' ORDER BY start_utc;
```

**Calendar checks**

- Verify event title contains `TC-{cid}` (or whatever naming convention you use).
- Verify each event's start/end matches slot start/end in the instructor's timezone.

**Notes**

- Capture network request/response and calendar screenshot.

---

### TC 1.3.1 — Add duplicate dates (same day, different times)

**Goal:** Validate successful create path and 1:1 consistency (UI ↔ payload ↔ DB ↔ Calendar ↔ busy-slots).

**Preconditions / Setup**

- Default timezone set to `Asia/Kolkata` (or set in payload).
- Instructor `inst_001` has calendar sync enabled.

**Steps**

1. Open Create Class form → choose `classType = count`.
1. Set `classCount = 2`.
1. Add slots: 2026-01-05 09:00–10:00, 2026-01-05 14:00–15:00.
1. Click **Save**.

**Copy/paste examples**

```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "TC-1.3.1",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    },
    {
      "start": "2026-01-05T14:00:00+05:30",
      "end": "2026-01-05T15:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "startLocal": "2026-01-05T14:00:00+05:30",
        "endLocal": "2026-01-05T15:00:00+05:30",
        "startUtc": "2026-01-05T08:30:00Z",
        "endUtc": "2026-01-05T09:30:00Z"
      }
    ]
  }
}
JSON
```
```bash
curl -sS "$BASE_URL/api/availability/busy-slots?instructorId=inst_001&startDate=2026-01-05&endDate=2026-01-05&timeZone=Asia/Kolkata" -H "Authorization: Bearer $TOKEN" | jq
```

**Expected results**

- UI: Form is valid; slots render exactly as entered.
- API: `POST /api/classes` returns **201** and includes `classId` plus created `slotId` values.
- DB: Exactly **2** non-deleted slot rows exist for the new class.
- Calendar: Exactly **2** calendar events exist and match each slot (no duplicates).
- Availability: `busy-slots` for the relevant date(s) includes the created slot(s).

**DB checks (examples)**

```sql
SELECT COUNT(*) FROM class_slots WHERE class_id = '<classId>' AND is_deleted = false;
```
```sql
SELECT slot_id, start_utc, end_utc, event_id FROM class_slots WHERE class_id = '<classId>' ORDER BY start_utc;
```

**Calendar checks**

- Verify event title contains `TC-{cid}` (or whatever naming convention you use).
- Verify each event's start/end matches slot start/end in the instructor's timezone.

**Notes**

- Capture network request/response and calendar screenshot.

---

### TC 1.3.2 — Add duplicate time ranges on different dates

**Goal:** Validate successful create path and 1:1 consistency (UI ↔ payload ↔ DB ↔ Calendar ↔ busy-slots).

**Preconditions / Setup**

- Default timezone set to `Asia/Kolkata` (or set in payload).
- Instructor `inst_001` has calendar sync enabled.

**Steps**

1. Open Create Class form → choose `classType = count`.
1. Set `classCount = 2`.
1. Add slots: 2026-01-05 09:00–10:00, 2026-01-06 09:00–10:00.
1. Click **Save**.

**Copy/paste examples**

```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "TC-1.3.2",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    },
    {
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "startLocal": "2026-01-06T09:00:00+05:30",
        "endLocal": "2026-01-06T10:00:00+05:30",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      }
    ]
  }
}
JSON
```
```bash
curl -sS "$BASE_URL/api/availability/busy-slots?instructorId=inst_001&startDate=2026-01-05&endDate=2026-01-06&timeZone=Asia/Kolkata" -H "Authorization: Bearer $TOKEN" | jq
```

**Expected results**

- UI: Form is valid; slots render exactly as entered.
- API: `POST /api/classes` returns **201** and includes `classId` plus created `slotId` values.
- DB: Exactly **2** non-deleted slot rows exist for the new class.
- Calendar: Exactly **2** calendar events exist and match each slot (no duplicates).
- Availability: `busy-slots` for the relevant date(s) includes the created slot(s).

**DB checks (examples)**

```sql
SELECT COUNT(*) FROM class_slots WHERE class_id = '<classId>' AND is_deleted = false;
```
```sql
SELECT slot_id, start_utc, end_utc, event_id FROM class_slots WHERE class_id = '<classId>' ORDER BY start_utc;
```

**Calendar checks**

- Verify event title contains `TC-{cid}` (or whatever naming convention you use).
- Verify each event's start/end matches slot start/end in the instructor's timezone.

**Notes**

- Capture network request/response and calendar screenshot.

---

### TC 1.3.3 — Add overlapping slots within same class (same day)

**Goal:** Validate mismatch/invalid create requests are blocked and do not create partial state.

**Preconditions / Setup**

- Default timezone set to `Asia/Kolkata`.

**Steps**

1. Open Create Class form → choose `classType = count`.
1. Set `classCount = 2`.
1. Add slots: 2026-01-05 09:00–10:00, 2026-01-05 09:30–10:30.
1. Attempt to click **Save**.

**Copy/paste examples**

```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "TC-1.3.3",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    },
    {
      "start": "2026-01-05T09:30:00+05:30",
      "end": "2026-01-05T10:30:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "startLocal": "2026-01-05T09:30:00+05:30",
        "endLocal": "2026-01-05T10:30:00+05:30",
        "startUtc": "2026-01-05T04:00:00Z",
        "endUtc": "2026-01-05T05:00:00Z"
      }
    ]
  }
}
JSON
```

**Expected results**

- UI: Shows validation error and prevents submission.
- API: If request is sent, server returns **400** (or 422) with message like: `Slots cannot overlap within the same class`.
- DB: No class/slot rows created (or transaction rolled back).
- Calendar: No events created.

**DB checks (examples)**

```sql
SELECT COUNT(*) FROM classes WHERE title = 'TC-{cid}';
```

**Notes**

- If UI blocks submission, confirm **no network request** is made.

---

### TC 1.3.4 — Add overlapping slots within same class (different days)

**Goal:** Validate successful create path and 1:1 consistency (UI ↔ payload ↔ DB ↔ Calendar ↔ busy-slots).

**Preconditions / Setup**

- Default timezone set to `Asia/Kolkata` (or set in payload).
- Instructor `inst_001` has calendar sync enabled.

**Steps**

1. Open Create Class form → choose `classType = count`.
1. Set `classCount = 2`.
1. Add slots: 2026-01-05 09:00–10:00, 2026-01-06 09:00–10:00.
1. Click **Save**.

**Copy/paste examples**

```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "TC-1.3.4",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    },
    {
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "startLocal": "2026-01-06T09:00:00+05:30",
        "endLocal": "2026-01-06T10:00:00+05:30",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      }
    ]
  }
}
JSON
```
```bash
curl -sS "$BASE_URL/api/availability/busy-slots?instructorId=inst_001&startDate=2026-01-05&endDate=2026-01-06&timeZone=Asia/Kolkata" -H "Authorization: Bearer $TOKEN" | jq
```

**Expected results**

- UI: Form is valid; slots render exactly as entered.
- API: `POST /api/classes` returns **201** and includes `classId` plus created `slotId` values.
- DB: Exactly **2** non-deleted slot rows exist for the new class.
- Calendar: Exactly **2** calendar events exist and match each slot (no duplicates).
- Availability: `busy-slots` for the relevant date(s) includes the created slot(s).

**DB checks (examples)**

```sql
SELECT COUNT(*) FROM class_slots WHERE class_id = '<classId>' AND is_deleted = false;
```
```sql
SELECT slot_id, start_utc, end_utc, event_id FROM class_slots WHERE class_id = '<classId>' ORDER BY start_utc;
```

**Calendar checks**

- Verify event title contains `TC-{cid}` (or whatever naming convention you use).
- Verify each event's start/end matches slot start/end in the instructor's timezone.

**Notes**

- Capture network request/response and calendar screenshot.

---

### TC 1.4.1 — Add slots via calendar picker only

**Goal:** Validate successful create path and 1:1 consistency (UI ↔ payload ↔ DB ↔ Calendar ↔ busy-slots).

**Preconditions / Setup**

- Default timezone set to `Asia/Kolkata` (or set in payload).
- Instructor `inst_001` has calendar sync enabled.

**Steps**

1. Open Create Class form → choose `classType = count`.
1. Set `classCount = 2`.
1. Use the calendar picker to select **2026-01-05** and **2026-01-06**; set times 09:00–10:00 for each.
1. Save.

**Copy/paste examples**

```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "TC-1.4.1",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    },
    {
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "startLocal": "2026-01-06T09:00:00+05:30",
        "endLocal": "2026-01-06T10:00:00+05:30",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      }
    ]
  }
}
JSON
```
```bash
curl -sS "$BASE_URL/api/availability/busy-slots?instructorId=inst_001&startDate=2026-01-05&endDate=2026-01-06&timeZone=Asia/Kolkata" -H "Authorization: Bearer $TOKEN" | jq
```

**Expected results**

- UI: Form is valid; slots render exactly as entered.
- API: `POST /api/classes` returns **201** and includes `classId` plus created `slotId` values.
- DB: Exactly **2** non-deleted slot rows exist for the new class.
- Calendar: Exactly **2** calendar events exist and match each slot (no duplicates).
- Availability: `busy-slots` for the relevant date(s) includes the created slot(s).

**DB checks (examples)**

```sql
SELECT COUNT(*) FROM class_slots WHERE class_id = '<classId>' AND is_deleted = false;
```
```sql
SELECT slot_id, start_utc, end_utc, event_id FROM class_slots WHERE class_id = '<classId>' ORDER BY start_utc;
```

**Calendar checks**

- Verify event title contains `TC-{cid}` (or whatever naming convention you use).
- Verify each event's start/end matches slot start/end in the instructor's timezone.

**Notes**

- Capture network request/response and calendar screenshot.

---

### TC 1.4.2 — Add slots via form inputs only (manual date entry)

**Goal:** Validate successful create path and 1:1 consistency (UI ↔ payload ↔ DB ↔ Calendar ↔ busy-slots).

**Preconditions / Setup**

- Default timezone set to `Asia/Kolkata` (or set in payload).
- Instructor `inst_001` has calendar sync enabled.

**Steps**

1. Open Create Class form → choose `classType = count`.
1. Set `classCount = 2`.
1. Manually type dates `2026-01-05` and `2026-01-06` in the date fields; set times 09:00–10:00.
1. Save.

**Copy/paste examples**

```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "TC-1.4.2",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    },
    {
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "startLocal": "2026-01-06T09:00:00+05:30",
        "endLocal": "2026-01-06T10:00:00+05:30",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      }
    ]
  }
}
JSON
```
```bash
curl -sS "$BASE_URL/api/availability/busy-slots?instructorId=inst_001&startDate=2026-01-05&endDate=2026-01-06&timeZone=Asia/Kolkata" -H "Authorization: Bearer $TOKEN" | jq
```

**Expected results**

- UI: Form is valid; slots render exactly as entered.
- API: `POST /api/classes` returns **201** and includes `classId` plus created `slotId` values.
- DB: Exactly **2** non-deleted slot rows exist for the new class.
- Calendar: Exactly **2** calendar events exist and match each slot (no duplicates).
- Availability: `busy-slots` for the relevant date(s) includes the created slot(s).

**DB checks (examples)**

```sql
SELECT COUNT(*) FROM class_slots WHERE class_id = '<classId>' AND is_deleted = false;
```
```sql
SELECT slot_id, start_utc, end_utc, event_id FROM class_slots WHERE class_id = '<classId>' ORDER BY start_utc;
```

**Calendar checks**

- Verify event title contains `TC-{cid}` (or whatever naming convention you use).
- Verify each event's start/end matches slot start/end in the instructor's timezone.

**Notes**

- Capture network request/response and calendar screenshot.

---

### TC 1.4.3 — Mix calendar picker and form inputs

**Goal:** Validate successful create path and 1:1 consistency (UI ↔ payload ↔ DB ↔ Calendar ↔ busy-slots).

**Preconditions / Setup**

- Default timezone set to `Asia/Kolkata` (or set in payload).
- Instructor `inst_001` has calendar sync enabled.

**Steps**

1. Open Create Class form → choose `classType = count`.
1. Set `classCount = 2`.
1. Add slot #1 via calendar picker: 2026-01-05 09:00–10:00.
1. Add slot #2 via manual form entry: 2026-01-06 09:00–10:00.
1. Save.

**Copy/paste examples**

```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "TC-1.4.3",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    },
    {
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "startLocal": "2026-01-06T09:00:00+05:30",
        "endLocal": "2026-01-06T10:00:00+05:30",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      }
    ]
  }
}
JSON
```
```bash
curl -sS "$BASE_URL/api/availability/busy-slots?instructorId=inst_001&startDate=2026-01-05&endDate=2026-01-06&timeZone=Asia/Kolkata" -H "Authorization: Bearer $TOKEN" | jq
```

**Expected results**

- UI: Form is valid; slots render exactly as entered.
- API: `POST /api/classes` returns **201** and includes `classId` plus created `slotId` values.
- DB: Exactly **2** non-deleted slot rows exist for the new class.
- Calendar: Exactly **2** calendar events exist and match each slot (no duplicates).
- Availability: `busy-slots` for the relevant date(s) includes the created slot(s).

**DB checks (examples)**

```sql
SELECT COUNT(*) FROM class_slots WHERE class_id = '<classId>' AND is_deleted = false;
```
```sql
SELECT slot_id, start_utc, end_utc, event_id FROM class_slots WHERE class_id = '<classId>' ORDER BY start_utc;
```

**Calendar checks**

- Verify event title contains `TC-{cid}` (or whatever naming convention you use).
- Verify each event's start/end matches slot start/end in the instructor's timezone.

**Notes**

- Capture network request/response and calendar screenshot.

---

### TC 1.5.1 — Submit with empty slot (missing date)

**Goal:** Ensure the UI and/or API blocks saving when any slot is missing a required date.

**Preconditions / Setup**

- Open Create Class form (count-based).

**Steps**

1. Set `classCount = 2`.
1. Fill slot #1 completely (e.g., 2026-01-05 09:00–10:00).
1. Add slot #2 but leave **date** empty.
1. Attempt to Save.

**Copy/paste examples**

```json
{ "classCount": 2, "schedules": [ {"start":"2026-01-05T09:00:00+05:30","end":"2026-01-05T10:00:00+05:30"}, {"start":null,"end":null} ] }
```

**Expected results**

- UI: Inline validation error on empty date field; Save disabled or blocked.
- API: If forced, server returns 400/422 with field error like `schedules[1].date is required`.
- No DB or Calendar changes.

**Notes**

- Verify **backend is not called** in normal UI flow (no network request).

---

### TC 1.5.2 — Submit with empty slot (missing time)

**Goal:** Ensure the UI and/or API blocks saving when any slot is missing required time(s).

**Preconditions / Setup**

- Open Create Class form (count-based).

**Steps**

1. Set `classCount = 2`.
1. Fill slot #1 completely (e.g., 2026-01-05 09:00–10:00).
1. For slot #2, set date but omit start time.
1. Attempt to Save.

**Copy/paste examples**

```json
{ "classCount": 2, "schedules": [ {"start":"2026-01-05T09:00:00+05:30","end":"2026-01-05T10:00:00+05:30"}, {"start":"2026-01-06T??:??:00+05:30","end":"2026-01-06T10:00:00+05:30"} ] }
```

**Expected results**

- UI: Inline validation error on missing time field.
- API: If forced, server returns 400/422 with message like `startTime is required`.
- No DB or Calendar changes.

---

### TC 1.5.3 — Submit with invalid date format

**Goal:** Ensure invalid date input is rejected (or normalized) consistently across UI/API.

**Preconditions / Setup**

- Open Create Class form (count-based).

**Steps**

1. Set `classCount = 1`.
1. Enter date as `01/05/2026` (MM/DD/YYYY) instead of `2026-01-05`.
1. Set times 09:00–10:00.
1. Attempt to Save.

**Copy/paste examples**

```json
{ "classCount": 1, "schedules": [ {"date":"01/05/2026","startTime":"09:00","endTime":"10:00"} ] }
```

**Expected results**

- UI: Shows validation error OR normalizes to `2026-01-05` before sending.
- API: If sent as `01/05/2026`, server rejects with 400/422 OR accepts if server normalizes.
- Calendar: Only created if accepted; must land on the normalized date/time.

---

### TC 1.5.4 — Submit with end time before start time

**Goal:** Ensure time-range validation prevents invalid ranges.

**Preconditions / Setup**

- Open Create Class form (count-based).

**Steps**

1. Set `classCount = 1`.
1. Add slot on 2026-01-05 with start 10:00 and end 09:00.
1. Attempt to Save.

**Copy/paste examples**

```json
{ "classCount": 1, "schedules": [ {"start":"2026-01-05T10:00:00+05:30","end":"2026-01-05T09:00:00+05:30"} ] }
```

**Expected results**

- UI: Error `End time must be after start time`.
- API: If forced, server returns 400/422 with same validation.
- No DB or Calendar changes.

---

### TC 1.5.5 — Submit with past date

**Goal:** Ensure past-date scheduling is blocked and does not create slots/events.

**Preconditions / Setup**

- Set system/business clock so `2025-01-01` is in the past (it is for most environments).

**Steps**

1. Set `classCount = 1`.
1. Add slot with date 2025-01-01 09:00–10:00.
1. Attempt to Save.

**Copy/paste examples**

```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "TC-1.5.5",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 1,
  "capacity": 10,
  "schedules": [
    {
      "start": "2025-01-01T09:00:00+05:30",
      "end": "2025-01-01T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2025-01-01T09:00:00+05:30",
        "endLocal": "2025-01-01T10:00:00+05:30",
        "startUtc": "2025-01-01T03:30:00Z",
        "endUtc": "2025-01-01T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Expected results**

- UI: Error/warning `Cannot schedule in the past`.
- API: If submitted, server rejects with 400/422 `Cannot create slots in the past`.
- No DB or Calendar changes.

---

### TC 1.6.1 — Verify payload matches UI exactly

**Goal:** Ensure the network payload is a 1:1 representation of the UI state (no hidden mutation).

**Preconditions / Setup**

- Browser devtools open (Network tab).

**Steps**

1. Create a class with `classCount = 2` and 2 slots (e.g., 2026-01-05 09:00–10:00 and 2026-01-06 09:00–10:00).
1. Before clicking Save, screenshot the UI slot list.
1. Click Save and inspect the request body.

**Expected results**

- Request body contains exactly 2 schedules and each start/end matches the UI values.
- No extra schedules, no missing schedules, no timezone shift in displayed local values.

---

### TC 1.6.2 — Verify backend stores exactly classCount slots

**Goal:** Ensure backend persistence creates exactly N slots and nothing else.

**Preconditions / Setup**

- DB read access for verification.

**Steps**

1. Create a class with `classCount = 3` and 3 slots; save.
1. Query DB for class slots by returned classId.

**Expected results**

- DB count of non-deleted slots equals 3 and matches the schedules sent.

**DB checks (examples)**

```sql
SELECT COUNT(*) FROM class_slots WHERE class_id = '<classId>' AND is_deleted = false;
```

---

### TC 1.6.3 — Verify calendar events match DB slots

**Goal:** Ensure calendar sync is 1:1 with DB slots and times/dates are consistent.

**Preconditions / Setup**

- Calendar sync enabled; you can view the instructor calendar.

**Steps**

1. Create a class with `classCount = N` and N slots; save.
1. Compare DB slot list vs calendar events list (count + times).

**Expected results**

- Calendar event count equals DB slot count equals classCount.
- Each slot has a corresponding calendar event at the same time range; no duplicates; no missing events.

---


## 2. Edit flow

### TC 2.1.1 — Open edit mode, don't change anything, save

**Goal:** Saving with no changes should be a no-op (or explicit no-op response) and must not create duplicate slots/events.

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-2.1.1",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    },
    {
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "startLocal": "2026-01-06T09:00:00+05:30",
        "endLocal": "2026-01-06T10:00:00+05:30",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Open the class in edit mode.
1. Do not change any fields.
1. Click Save.
1. Re-open and confirm nothing changed.

**Copy/paste examples**

```bash
curl -sS -X PUT "$BASE_URL/api/classes/<classId>" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "classId": "<classId>",
  "title": "TC-2.1.1",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "schedules": [
    {
      "slotId": "slot_1",
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30",
      "eventId": "evt_1"
    },
    {
      "slotId": "slot_2",
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30",
      "eventId": "evt_2"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "slotId": "slot_1",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "slotId": "slot_2",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Expected results**

- API: either no-op 200/204, or explicit `No changes` response—**but must not duplicate**.
- DB: slot rows unchanged.
- Calendar: no new events; no duplicates.

**DB checks (examples)**

```sql
SELECT slot_id, start_utc, end_utc, event_id FROM class_slots WHERE class_id = '<classId>' AND is_deleted = false ORDER BY start_utc;
```

---

### TC 2.1.2 — Open edit mode, change non-schedule fields (capacity), save

**Goal:** Editing non-schedule fields must not mutate schedules or calendar events.

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-2.1.2",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    },
    {
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "startLocal": "2026-01-06T09:00:00+05:30",
        "endLocal": "2026-01-06T10:00:00+05:30",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Open class in edit mode.
1. Change capacity from 10 → 15 (do not touch slots).
1. Save.

**Copy/paste examples**

```bash
curl -sS -X PUT "$BASE_URL/api/classes/<classId>" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "classId": "<classId>",
  "title": "TC-2.1.2",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "schedules": [
    {
      "slotId": "slot_1",
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30",
      "eventId": "evt_1"
    },
    {
      "slotId": "slot_2",
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30",
      "eventId": "evt_2"
    }
  ],
  "capacity": 15,
  "_debug": {
    "utcPreview": [
      {
        "slotId": "slot_1",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "slotId": "slot_2",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Expected results**

- API: 200 OK.
- DB: capacity updated; schedules unchanged.
- Calendar: events unchanged.

**DB checks (examples)**

```sql
SELECT capacity FROM classes WHERE class_id = '<classId>';
```
```sql
SELECT slot_id, start_utc, end_utc FROM class_slots WHERE class_id = '<classId>' AND is_deleted = false ORDER BY start_utc;
```

---

### TC 2.2.1 — Edit time of one slot (same date)

**Goal:** Updating a slot time updates DB and calendar for that slot only.

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-2.2.1",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    },
    {
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "startLocal": "2026-01-06T09:00:00+05:30",
        "endLocal": "2026-01-06T10:00:00+05:30",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Open edit mode.
1. Change slot #1 time 09:00–10:00 → 11:00–12:00.
1. Save.

**Copy/paste examples**

```bash
curl -sS -X PUT "$BASE_URL/api/classes/<classId>" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "classId": "<classId>",
  "title": "TC-2.2.1",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "schedules": [
    {
      "slotId": "slot_1",
      "start": "2026-01-05T11:00:00+05:30",
      "end": "2026-01-05T12:00:00+05:30",
      "eventId": "evt_1"
    },
    {
      "slotId": "slot_2",
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30",
      "eventId": "evt_2"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "slotId": "slot_1",
        "startUtc": "2026-01-05T05:30:00Z",
        "endUtc": "2026-01-05T06:30:00Z"
      },
      {
        "slotId": "slot_2",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Expected results**

- DB: only slot #1's time changes.
- Calendar: slot #1 event updated (not duplicated).

**DB checks (examples)**

```sql
SELECT slot_id, start_utc, end_utc, event_id FROM class_slots WHERE class_id = '<classId>' AND is_deleted = false ORDER BY slot_id;
```

**Calendar checks**

- Confirm only one event exists for slot #1, now at 11:00–12:00.

---

### TC 2.2.2 — Edit date of one slot (same time)

**Goal:** Moving a slot to a new date updates DB and moves the calendar event.

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-2.2.2",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    },
    {
      "start": "2026-01-07T09:00:00+05:30",
      "end": "2026-01-07T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "startLocal": "2026-01-07T09:00:00+05:30",
        "endLocal": "2026-01-07T10:00:00+05:30",
        "startUtc": "2026-01-07T03:30:00Z",
        "endUtc": "2026-01-07T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Open edit mode.
1. Change slot #1 date 2026-01-05 → 2026-01-06 (keep 09:00–10:00).
1. Save.

**Copy/paste examples**

```bash
curl -sS -X PUT "$BASE_URL/api/classes/<classId>" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "classId": "<classId>",
  "title": "TC-2.2.2",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "schedules": [
    {
      "slotId": "slot_1",
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30",
      "eventId": "evt_1"
    },
    {
      "slotId": "slot_2",
      "start": "2026-01-07T09:00:00+05:30",
      "end": "2026-01-07T10:00:00+05:30",
      "eventId": "evt_2"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "slotId": "slot_1",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      },
      {
        "slotId": "slot_2",
        "startUtc": "2026-01-07T03:30:00Z",
        "endUtc": "2026-01-07T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Expected results**

- DB: slot #1 start/end updated to new date.
- Calendar: slot #1 event moved to 2026-01-06 (same eventId), old date no longer has it.

**DB checks (examples)**

```sql
SELECT slot_id, start_utc, end_utc FROM class_slots WHERE class_id = '<classId>' AND is_deleted = false ORDER BY slot_id;
```

**Calendar checks**

- Confirm old date (2026-01-05) has no event for slot #1.

---

### TC 2.2.3 — Edit both date and time of one slot

**Goal:** Full slot move should update DB + calendar and remove old date/time.

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-2.2.3",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    },
    {
      "start": "2026-01-07T09:00:00+05:30",
      "end": "2026-01-07T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "startLocal": "2026-01-07T09:00:00+05:30",
        "endLocal": "2026-01-07T10:00:00+05:30",
        "startUtc": "2026-01-07T03:30:00Z",
        "endUtc": "2026-01-07T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Open edit mode.
1. Change slot #1 from 2026-01-05 09:00–10:00 → 2026-01-06 14:00–15:00.
1. Save.

**Copy/paste examples**

```bash
curl -sS -X PUT "$BASE_URL/api/classes/<classId>" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "classId": "<classId>",
  "title": "TC-2.2.3",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "schedules": [
    {
      "slotId": "slot_1",
      "start": "2026-01-06T14:00:00+05:30",
      "end": "2026-01-06T15:00:00+05:30",
      "eventId": "evt_1"
    },
    {
      "slotId": "slot_2",
      "start": "2026-01-07T09:00:00+05:30",
      "end": "2026-01-07T10:00:00+05:30",
      "eventId": "evt_2"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "slotId": "slot_1",
        "startUtc": "2026-01-06T08:30:00Z",
        "endUtc": "2026-01-06T09:30:00Z"
      },
      {
        "slotId": "slot_2",
        "startUtc": "2026-01-07T03:30:00Z",
        "endUtc": "2026-01-07T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Expected results**

- DB: slot #1 new date/time stored; slot #2 unchanged.
- Calendar: slot #1 event updated to new date/time (not duplicated).

**DB checks (examples)**

```sql
SELECT slot_id, start_utc, end_utc, event_id FROM class_slots WHERE class_id = '<classId>' AND is_deleted = false ORDER BY slot_id;
```

---

### TC 2.3.1 — Remove one slot (classCount > 1)

**Goal:** Removing a slot without adjusting classCount must be blocked/rejected.

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-2.3.1",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 3,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    },
    {
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30"
    },
    {
      "start": "2026-01-07T09:00:00+05:30",
      "end": "2026-01-07T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "startLocal": "2026-01-06T09:00:00+05:30",
        "endLocal": "2026-01-06T10:00:00+05:30",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      },
      {
        "startLocal": "2026-01-07T09:00:00+05:30",
        "endLocal": "2026-01-07T10:00:00+05:30",
        "startUtc": "2026-01-07T03:30:00Z",
        "endUtc": "2026-01-07T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Open edit mode.
1. Remove slot #2 (middle slot).
1. Attempt to Save.

**Copy/paste examples**

```bash
curl -sS -X PUT "$BASE_URL/api/classes/<classId>" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "classId": "<classId>",
  "title": "TC-2.3.1",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 3,
  "schedules": [
    {
      "slotId": "slot_1",
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30",
      "eventId": "evt_1"
    },
    {
      "slotId": "slot_2",
      "start": "2026-01-07T09:00:00+05:30",
      "end": "2026-01-07T10:00:00+05:30",
      "eventId": "evt_2"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "slotId": "slot_1",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "slotId": "slot_2",
        "startUtc": "2026-01-07T03:30:00Z",
        "endUtc": "2026-01-07T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Expected results**

- UI: validation error `Must have 3 slots` (or similar).
- API: if submitted, 400/422 `Cannot have fewer slots than classCount`.
- DB & Calendar unchanged.

**Notes**

- Confirm no calendar events are deleted on a rejected save.

---

### TC 2.3.2 — Add one slot (already at classCount)

**Goal:** Adding slots beyond classCount must be blocked/rejected.

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-2.3.2",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    },
    {
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "startLocal": "2026-01-06T09:00:00+05:30",
        "endLocal": "2026-01-06T10:00:00+05:30",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Open edit mode.
1. Add a 3rd slot (e.g., 2026-01-07 09:00–10:00).
1. Attempt to Save.

**Copy/paste examples**

```bash
curl -sS -X PUT "$BASE_URL/api/classes/<classId>" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "classId": "<classId>",
  "title": "TC-2.3.2",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "schedules": [
    {
      "slotId": "slot_1",
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30",
      "eventId": "evt_1"
    },
    {
      "slotId": "slot_2",
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30",
      "eventId": "evt_2"
    },
    {
      "slotId": "slot_3",
      "start": "2026-01-07T09:00:00+05:30",
      "end": "2026-01-07T10:00:00+05:30",
      "eventId": "evt_3"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "slotId": "slot_1",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "slotId": "slot_2",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      },
      {
        "slotId": "slot_3",
        "startUtc": "2026-01-07T03:30:00Z",
        "endUtc": "2026-01-07T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Expected results**

- UI: validation error `Cannot have more slots than classCount`.
- API: if submitted, 400/422 with same message.
- DB & Calendar unchanged.

---

### TC 2.3.3 — Remove slot and immediately re-add same date/time

**Goal:** Replacing a slot should delete the old slot row/event and create a new one without leaving ghosts.

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-2.3.3",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    },
    {
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "startLocal": "2026-01-06T09:00:00+05:30",
        "endLocal": "2026-01-06T10:00:00+05:30",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Open edit mode.
1. Delete slot #1.
1. Add a new slot with the same date/time as the deleted one.
1. Save.

**Copy/paste examples**

```bash
curl -sS -X PUT "$BASE_URL/api/classes/<classId>" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "classId": "<classId>",
  "title": "TC-2.3.3",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "schedules": [
    {
      "slotId": "slot_2",
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30",
      "eventId": "evt_2"
    },
    {
      "slotId": null,
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    }
  ]
}
JSON
```

**Expected results**

- DB: old slot deleted (or soft-deleted) and new slot created (new slotId).
- Calendar: either (A) old event deleted & new event created, or (B) event updated to represent replacement—**but no duplicates**.
- busy-slots shows the slot time as busy after save.

**DB checks (examples)**

```sql
SELECT slot_id, is_deleted, event_id, start_utc, end_utc FROM class_slots WHERE class_id = '<classId>' ORDER BY start_utc;
```

---

### TC 2.4.1 — Reduce classCount (3 → 2) while UI still has 3 slots

**Goal:** Reducing classCount must require removing extra slots first.

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-2.4.1",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 3,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    },
    {
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30"
    },
    {
      "start": "2026-01-07T09:00:00+05:30",
      "end": "2026-01-07T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "startLocal": "2026-01-06T09:00:00+05:30",
        "endLocal": "2026-01-06T10:00:00+05:30",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      },
      {
        "startLocal": "2026-01-07T09:00:00+05:30",
        "endLocal": "2026-01-07T10:00:00+05:30",
        "startUtc": "2026-01-07T03:30:00Z",
        "endUtc": "2026-01-07T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Open edit mode.
1. Change classCount 3 → 2 but leave 3 slots.
1. Attempt to Save.

**Copy/paste examples**

```bash
curl -sS -X PUT "$BASE_URL/api/classes/<classId>" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "classId": "<classId>",
  "title": "TC-2.4.1",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "schedules": [
    {
      "slotId": "slot_1",
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30",
      "eventId": "evt_1"
    },
    {
      "slotId": "slot_2",
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30",
      "eventId": "evt_2"
    },
    {
      "slotId": "slot_3",
      "start": "2026-01-07T09:00:00+05:30",
      "end": "2026-01-07T10:00:00+05:30",
      "eventId": "evt_3"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "slotId": "slot_1",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "slotId": "slot_2",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      },
      {
        "slotId": "slot_3",
        "startUtc": "2026-01-07T03:30:00Z",
        "endUtc": "2026-01-07T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Expected results**

- UI: error `Must remove 1 slot`.
- API: 400/422 `Cannot reduce classCount while slots exceed new count`.
- DB & Calendar unchanged.

---

### TC 2.4.2 — Reduce classCount after removing slots

**Goal:** After removing slots, reducing classCount should succeed and remove 1 event.

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-2.4.2",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 3,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    },
    {
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30"
    },
    {
      "start": "2026-01-07T09:00:00+05:30",
      "end": "2026-01-07T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "startLocal": "2026-01-06T09:00:00+05:30",
        "endLocal": "2026-01-06T10:00:00+05:30",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      },
      {
        "startLocal": "2026-01-07T09:00:00+05:30",
        "endLocal": "2026-01-07T10:00:00+05:30",
        "startUtc": "2026-01-07T03:30:00Z",
        "endUtc": "2026-01-07T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Open edit mode.
1. Remove one slot (now 2 slots).
1. Change classCount 3 → 2.
1. Save.

**Copy/paste examples**

```bash
curl -sS -X PUT "$BASE_URL/api/classes/<classId>" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "classId": "<classId>",
  "title": "TC-2.4.2",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "schedules": [
    {
      "slotId": "slot_1",
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30",
      "eventId": "evt_1"
    },
    {
      "slotId": "slot_2",
      "start": "2026-01-07T09:00:00+05:30",
      "end": "2026-01-07T10:00:00+05:30",
      "eventId": "evt_2"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "slotId": "slot_1",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "slotId": "slot_2",
        "startUtc": "2026-01-07T03:30:00Z",
        "endUtc": "2026-01-07T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Expected results**

- API: 200 OK.
- DB: classCount=2 and exactly 2 active slots remain.
- Calendar: corresponding removed slot event deleted.

**DB checks (examples)**

```sql
SELECT class_count FROM classes WHERE class_id = '<classId>';
```
```sql
SELECT COUNT(*) FROM class_slots WHERE class_id = '<classId>' AND is_deleted = false;
```

---

### TC 2.4.3 — Increase classCount (2 → 3) while UI still has 2 slots

**Goal:** Increasing classCount must require adding slots first.

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-2.4.3",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    },
    {
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "startLocal": "2026-01-06T09:00:00+05:30",
        "endLocal": "2026-01-06T10:00:00+05:30",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Open edit mode.
1. Change classCount 2 → 3 but keep only 2 slots.
1. Attempt to Save.

**Copy/paste examples**

```bash
curl -sS -X PUT "$BASE_URL/api/classes/<classId>" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "classId": "<classId>",
  "title": "TC-2.4.3",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 3,
  "schedules": [
    {
      "slotId": "slot_1",
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30",
      "eventId": "evt_1"
    },
    {
      "slotId": "slot_2",
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30",
      "eventId": "evt_2"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "slotId": "slot_1",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "slotId": "slot_2",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Expected results**

- UI: error `Must add 1 slot`.
- API: 400/422 `Cannot increase classCount without adding slots`.
- DB & Calendar unchanged.

---

### TC 2.4.4 — Increase classCount after adding slots

**Goal:** After adding a slot, increasing classCount should succeed and create 1 new event.

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-2.4.4",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    },
    {
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "startLocal": "2026-01-06T09:00:00+05:30",
        "endLocal": "2026-01-06T10:00:00+05:30",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Open edit mode.
1. Add 1 slot (now 3 total).
1. Change classCount 2 → 3.
1. Save.

**Copy/paste examples**

```bash
curl -sS -X PUT "$BASE_URL/api/classes/<classId>" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "classId": "<classId>",
  "title": "TC-2.4.4",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 3,
  "schedules": [
    {
      "slotId": "slot_1",
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30",
      "eventId": "evt_1"
    },
    {
      "slotId": "slot_2",
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30",
      "eventId": "evt_2"
    },
    {
      "slotId": "slot_3",
      "start": "2026-01-07T09:00:00+05:30",
      "end": "2026-01-07T10:00:00+05:30",
      "eventId": "evt_3"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "slotId": "slot_1",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "slotId": "slot_2",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      },
      {
        "slotId": "slot_3",
        "startUtc": "2026-01-07T03:30:00Z",
        "endUtc": "2026-01-07T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Expected results**

- API: 200 OK.
- DB: classCount=3 and exactly 3 active slots exist.
- Calendar: 1 new event created for the new slot.

**DB checks (examples)**

```sql
SELECT class_count FROM classes WHERE class_id = '<classId>';
```
```sql
SELECT COUNT(*) FROM class_slots WHERE class_id = '<classId>' AND is_deleted = false;
```

---

### TC 2.5.1 — Edit past slot (already happened)

**Goal:** Verify policy for editing past slots is enforced consistently.

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-2.5.1",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 1,
  "capacity": 10,
  "schedules": [
    {
      "start": "2025-12-01T09:00:00+05:30",
      "end": "2025-12-01T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2025-12-01T09:00:00+05:30",
        "endLocal": "2025-12-01T10:00:00+05:30",
        "startUtc": "2025-12-01T03:30:00Z",
        "endUtc": "2025-12-01T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Open edit mode for the class containing past slot 2025-12-01 09:00–10:00.
1. Attempt to change it to 2026-01-05 09:00–10:00.
1. Save.

**Copy/paste examples**

```bash
curl -sS -X PUT "$BASE_URL/api/classes/<classId>" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "classId": "<classId>",
  "title": "TC-2.5.1",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 1,
  "schedules": [
    {
      "slotId": "slot_1",
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30",
      "eventId": "evt_1"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "slotId": "slot_1",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Expected results**

- If `POLICY_ALLOW_EDIT_PAST_SLOTS=false`: UI disables edit or API rejects with `Cannot edit past slots`.
- If `POLICY_ALLOW_EDIT_PAST_SLOTS=true`: DB updates and calendar event updates/moves accordingly.

**Notes**

- Record which policy your product uses and ensure it matches documentation.

---

### TC 2.5.2 — Edit future slot (not yet happened)

**Goal:** Future slots should be editable and reflected in busy-slots.

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-2.5.2",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 1,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Open edit mode.
1. Change slot date 2026-01-05 → 2026-01-06.
1. Save.

**Copy/paste examples**

```bash
curl -sS -X PUT "$BASE_URL/api/classes/<classId>" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "classId": "<classId>",
  "title": "TC-2.5.2",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 1,
  "schedules": [
    {
      "slotId": "slot_1",
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30",
      "eventId": "evt_1"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "slotId": "slot_1",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      }
    ]
  }
}
JSON
```
```bash
curl -sS "$BASE_URL/api/availability/busy-slots?instructorId=inst_001&startDate=2026-01-05&endDate=2026-01-06&timeZone=Asia/Kolkata" -H "Authorization: Bearer $TOKEN" | jq
```

**Expected results**

- API: 200 OK.
- DB: updated to 2026-01-06; old date no longer shows slot.
- busy-slots includes new slot and excludes old one (after save).

---

### TC 2.5.3 — Remove past slot

**Goal:** Verify policy for deleting past slots is enforced consistently.

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-2.5.3",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 1,
  "capacity": 10,
  "schedules": [
    {
      "start": "2025-12-01T09:00:00+05:30",
      "end": "2025-12-01T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2025-12-01T09:00:00+05:30",
        "endLocal": "2025-12-01T10:00:00+05:30",
        "startUtc": "2025-12-01T03:30:00Z",
        "endUtc": "2025-12-01T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Open edit mode.
1. Attempt to remove the past slot.
1. Save.

**Expected results**

- If `POLICY_ALLOW_DELETE_PAST_SLOTS=false`: UI disables removal or API rejects `Cannot remove past slots`.
- If `POLICY_ALLOW_DELETE_PAST_SLOTS=true`: slot removed/soft-deleted and calendar event removed.

---

### TC 2.6.1 — Edit slot that has calendar event

**Goal:** Ensure updates use `eventId` and do not duplicate events.

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-2.6.1",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 1,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      }
    ]
  }
}
JSON
```
- Confirm the created slot has an `eventId` in DB.

**Steps**

1. Open edit mode.
1. Change time 09:00–10:00 → 11:00–12:00.
1. Save.
1. Check calendar for duplicates.

**Copy/paste examples**

```bash
curl -sS -X PUT "$BASE_URL/api/classes/<classId>" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "classId": "<classId>",
  "title": "TC-2.6.1",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 1,
  "schedules": [
    {
      "slotId": "slot_1",
      "start": "2026-01-05T11:00:00+05:30",
      "end": "2026-01-05T12:00:00+05:30",
      "eventId": "evt_1"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "slotId": "slot_1",
        "startUtc": "2026-01-05T05:30:00Z",
        "endUtc": "2026-01-05T06:30:00Z"
      }
    ]
  }
}
JSON
```

**Expected results**

- Calendar shows exactly one event (updated), not two.

**DB checks (examples)**

```sql
SELECT slot_id, event_id FROM class_slots WHERE class_id = '<classId>' AND is_deleted = false;
```

---

### TC 2.6.2 — Edit slot where calendar sync failed previously (no event_id)

**Goal:** Editing a slot without eventId should attempt calendar creation (and set eventId if successful).

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-2.6.2",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 1,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      }
    ]
  }
}
JSON
```
- Force calendar sync failure on create (see `Calendar failure simulation` section) so slot has no `eventId`.

**Steps**

1. Open edit mode.
1. Change time 09:00–10:00 → 11:00–12:00.
1. Save.

**Copy/paste examples**

```bash
curl -sS -X PUT "$BASE_URL/api/classes/<classId>" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "classId": "<classId>",
  "title": "TC-2.6.2",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 1,
  "schedules": [
    {
      "slotId": "slot_1",
      "start": "2026-01-05T11:00:00+05:30",
      "end": "2026-01-05T12:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "slotId": "slot_1",
        "startUtc": "2026-01-05T05:30:00Z",
        "endUtc": "2026-01-05T06:30:00Z"
      }
    ]
  }
}
JSON
```

**Expected results**

- DB: slot updated regardless of calendar outcome.
- Calendar: backend attempts to create an event; either succeeds (eventId set) or logs error and keeps eventId null.

**DB checks (examples)**

```sql
SELECT slot_id, event_id FROM class_slots WHERE class_id = '<classId>' AND is_deleted = false;
```

---

### TC 2.7.1 — Edit slot to time that conflicts with another class (not own)

**Goal:** Availability/conflict detection should surface conflicts with other classes; accept/reject based on policy.

**Preconditions / Setup**

- Create an **other class** for the same instructor with a slot at 2026-01-05 09:00–10:00 (this is the conflict).
- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-2.7.1",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-06T11:00:00+05:30",
      "end": "2026-01-06T12:00:00+05:30"
    },
    {
      "start": "2026-01-07T11:00:00+05:30",
      "end": "2026-01-07T12:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-06T11:00:00+05:30",
        "endLocal": "2026-01-06T12:00:00+05:30",
        "startUtc": "2026-01-06T05:30:00Z",
        "endUtc": "2026-01-06T06:30:00Z"
      },
      {
        "startLocal": "2026-01-07T11:00:00+05:30",
        "endLocal": "2026-01-07T12:00:00+05:30",
        "startUtc": "2026-01-07T05:30:00Z",
        "endUtc": "2026-01-07T06:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Open edit mode for the TC class and change slot #1 to 2026-01-05 09:00–10:00.
1. Observe conflict UI warning.
1. Attempt to Save.

**Expected results**

- UI: shows conflict warning referencing the other class.
- If `POLICY_ALLOW_OVERRIDE_CONFLICTS=true`: save succeeds and busy-slots shows both classes as busy.
- If `POLICY_ALLOW_OVERRIDE_CONFLICTS=false`: API rejects with conflict error (409/422) and nothing changes.

---

### TC 2.7.2 — Edit slot to time that matches own other slot (same class)

**Goal:** System must prevent same-class overlap/duplicate time ranges (same date).

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-2.7.2",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    },
    {
      "start": "2026-01-05T11:00:00+05:30",
      "end": "2026-01-05T12:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "startLocal": "2026-01-05T11:00:00+05:30",
        "endLocal": "2026-01-05T12:00:00+05:30",
        "startUtc": "2026-01-05T05:30:00Z",
        "endUtc": "2026-01-05T06:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Open edit mode.
1. Change slot #1 to match slot #2 exactly (11:00–12:00 same date).
1. Attempt to Save.

**Copy/paste examples**

```bash
curl -sS -X PUT "$BASE_URL/api/classes/<classId>" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "classId": "<classId>",
  "title": "TC-2.7.2",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "schedules": [
    {
      "slotId": "slot_1",
      "start": "2026-01-05T11:00:00+05:30",
      "end": "2026-01-05T12:00:00+05:30",
      "eventId": "evt_1"
    },
    {
      "slotId": "slot_2",
      "start": "2026-01-05T11:00:00+05:30",
      "end": "2026-01-05T12:00:00+05:30",
      "eventId": "evt_2"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "slotId": "slot_1",
        "startUtc": "2026-01-05T05:30:00Z",
        "endUtc": "2026-01-05T06:30:00Z"
      },
      {
        "slotId": "slot_2",
        "startUtc": "2026-01-05T05:30:00Z",
        "endUtc": "2026-01-05T06:30:00Z"
      }
    ]
  }
}
JSON
```

**Expected results**

- UI: error `Slots cannot overlap within same class`.
- API: 400/422 with same message if submitted.
- DB & Calendar unchanged.

---

### TC 2.7.3 — Edit slot to time that matches own slot from SAME class (overlap rule check)

**Goal:** Even if busy-slots self-exclusion exists, **within-class overlap** must still be validated.

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-2.7.3",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    },
    {
      "start": "2026-01-05T11:00:00+05:30",
      "end": "2026-01-05T12:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "startLocal": "2026-01-05T11:00:00+05:30",
        "endLocal": "2026-01-05T12:00:00+05:30",
        "startUtc": "2026-01-05T05:30:00Z",
        "endUtc": "2026-01-05T06:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Open edit mode.
1. Attempt to set slot #1 to the exact date/time range of slot #2.
1. Save.

**Expected results**

- Must be rejected due to within-class overlap (same date/time).
- If your UI uses busy-slots self-exclusion, confirm you still validate overlap locally or server-side.

---

### TC 2.7.4 — Edit slot: busy-slots should EXCLUDE this class's slots

**Goal:** Availability queries in edit mode should not flag the class's existing slots as conflicts (self-exclusion).

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-2.7.4",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    },
    {
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "startLocal": "2026-01-06T09:00:00+05:30",
        "endLocal": "2026-01-06T10:00:00+05:30",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Open edit mode for the created class.
1. Trigger availability/busy-slots query for 2026-01-05.
1. Verify the response (or client-side filtering) excludes this class's slots from conflict list.

**Copy/paste examples**

```bash
curl -sS "$BASE_URL/api/availability/busy-slots?instructorId=inst_001&startDate=2026-01-05&endDate=2026-01-05&timeZone=Asia/Kolkata&excludeClassId=<classId>" -H "Authorization: Bearer $TOKEN" | jq
```

**Expected results**

- If backend supports `excludeClassId`, response does not include slots for that classId.
- If backend does not support exclusion, frontend must filter by current UI slot set (not stale).

---

### TC 2.7.5 — Edit slot: busy-slots should INCLUDE removed slots from same class (not saved)

**Goal:** If a slot is removed in the UI but not saved, it still exists in DB and must show as busy/conflict.

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-2.7.5",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 1,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Open edit mode.
1. Remove the slot in the UI **without saving**.
1. Run busy-slots for 2026-01-05.
1. Check availability for 09:00–10:00.

**Copy/paste examples**

```bash
curl -sS "$BASE_URL/api/availability/busy-slots?instructorId=inst_001&startDate=2026-01-05&endDate=2026-01-05&timeZone=Asia/Kolkata" -H "Authorization: Bearer $TOKEN" | jq
```
```bash
curl -sS "$BASE_URL/api/availability/check?instructorId=inst_001&date=2026-01-05&startTime=09:00&endTime=10:00&timeZone=Asia/Kolkata" -H "Authorization: Bearer $TOKEN" | jq
```

**Expected results**

- busy-slots still includes the slot (because DB is source of truth until save).
- Availability check returns `available=false` (conflict).
- Frontend self-exclusion should NOT filter this removed slot (because it's not in current UI state).

---

### TC 2.8.1 — UI shows fewer slots than DB (after classCount reduction)

**Goal:** Saving should reconcile DB to match the payload/UI (remove stale slots and delete calendar events).

**Preconditions / Setup**

- Start with a classCount=3 class and 3 slots.
- Simulate a previous partial edit where UI removed 1 slot but DB still has 3 (or directly insert a stale slot row for the class).

**Steps**

1. Open edit mode where UI shows only 2 slots.
1. Save.
1. Verify DB has only 2 slots and 1 event was removed.

**Expected results**

- DB reconciled to exactly 2 slots.
- Calendar reconciled: removed slot event deleted.
- busy-slots returns only 2 slots for the class.

---

### TC 2.8.2 — DB has slots not shown in UI (stale slots)

**Goal:** On save, backend should delete/soft-delete slots that are missing from the submitted schedules.

**Preconditions / Setup**

- Have a class where DB has 3 slots but UI renders only 2 (stale).

**Steps**

1. Open edit mode; confirm UI shows 2 slots.
1. Save (no changes).
1. Verify DB now matches UI (2 slots) and any extra calendar event is deleted.

**Expected results**

- DB slot count equals UI slot count after save.
- No ghost slots remain in busy-slots.

---

### TC 2.8.3 — Edit while another user modified same class (concurrency)

**Goal:** Verify concurrency strategy (last-write-wins vs optimistic locking) is consistent and safe.

**Preconditions / Setup**

- Two user sessions (User A and User B) can edit the same class concurrently.

**Steps**

1. User A opens edit form for a class.
1. User B opens edit form for the same class.
1. User A makes a change and saves.
1. User B (stale) makes a different change and saves.

**Expected results**

- If `POLICY_CONCURRENCY=last-write-wins`: User B's save overwrites A (document this).
- If `POLICY_CONCURRENCY=optimistic-locking`: User B's save fails with 409/412 and prompts reload.
- In both cases: DB+calendar must not end up partially updated.

---


## 3. Update scenarios (mid-state)

### TC 3.1.1 — Change classCount from 2 to 3, add 1 slot

**Goal:** Increasing classCount with the matching number of slots should succeed and create one new slot/event.

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-3.1.1",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    },
    {
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "startLocal": "2026-01-06T09:00:00+05:30",
        "endLocal": "2026-01-06T10:00:00+05:30",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Open edit mode.
1. Change classCount 2 → 3.
1. Add one slot to reach 3 total.
1. Save.

**Copy/paste examples**

```bash
curl -sS -X PUT "$BASE_URL/api/classes/<classId>" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "classId": "<classId>",
  "title": "TC-3.1.1",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 3,
  "schedules": [
    {
      "slotId": "slot_1",
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30",
      "eventId": "evt_1"
    },
    {
      "slotId": "slot_2",
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30",
      "eventId": "evt_2"
    },
    {
      "slotId": "slot_3",
      "start": "2026-01-07T09:00:00+05:30",
      "end": "2026-01-07T10:00:00+05:30",
      "eventId": "evt_3"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "slotId": "slot_1",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "slotId": "slot_2",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      },
      {
        "slotId": "slot_3",
        "startUtc": "2026-01-07T03:30:00Z",
        "endUtc": "2026-01-07T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Expected results**

- DB: classCount=3 and 3 active slots.
- Calendar: exactly 3 events; 1 new event created.
- busy-slots includes all 3 slots.

**DB checks (examples)**

```sql
SELECT class_count FROM classes WHERE class_id='<classId>';
```
```sql
SELECT COUNT(*) FROM class_slots WHERE class_id='<classId>' AND is_deleted=false;
```

---

### TC 3.1.2 — Change classCount from 3 to 2, remove 1 slot

**Goal:** Decreasing classCount with matching slot removal should delete one slot/event.

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-3.1.2",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 3,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    },
    {
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30"
    },
    {
      "start": "2026-01-07T09:00:00+05:30",
      "end": "2026-01-07T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "startLocal": "2026-01-06T09:00:00+05:30",
        "endLocal": "2026-01-06T10:00:00+05:30",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      },
      {
        "startLocal": "2026-01-07T09:00:00+05:30",
        "endLocal": "2026-01-07T10:00:00+05:30",
        "startUtc": "2026-01-07T03:30:00Z",
        "endUtc": "2026-01-07T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Open edit mode.
1. Remove 1 slot to make 2 total.
1. Change classCount 3 → 2.
1. Save.

**Copy/paste examples**

```bash
curl -sS -X PUT "$BASE_URL/api/classes/<classId>" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "classId": "<classId>",
  "title": "TC-3.1.2",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "schedules": [
    {
      "slotId": "slot_1",
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30",
      "eventId": "evt_1"
    },
    {
      "slotId": "slot_2",
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30",
      "eventId": "evt_2"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "slotId": "slot_1",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "slotId": "slot_2",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Expected results**

- DB: classCount=2 and exactly 2 active slots.
- Calendar: one event deleted.
- busy-slots reflects 2 slots.

**DB checks (examples)**

```sql
SELECT class_count FROM classes WHERE class_id='<classId>';
```
```sql
SELECT COUNT(*) FROM class_slots WHERE class_id='<classId>' AND is_deleted=false;
```

---

### TC 3.2.1 — Change classType from count to continuous (duration)

**Goal:** Switching schedule model should convert data correctly and maintain availability correctness.

**Preconditions / Setup**

- Have an existing count-based class with N explicit slots and (optionally) calendar events.

**Steps**

1. Open edit mode.
1. Change classType from `count` → `duration` (continuous/recurring).
1. Configure the recurring pattern (e.g., weekly Mon 09:00–10:00 for 3 weeks).
1. Save.

**Expected results**

- DB: classType updated and schedules stored as recurring pattern (or equivalent).
- busy-slots: reflects recurring pattern accurately.
- Calendar: events are converted to recurring series OR regenerated as per your design (document expected).

**Notes**

- Because implementations vary, document your conversion rules: what happens to existing slot IDs and event IDs?

---

### TC 3.2.2 — Change classType from continuous (duration) to count

**Goal:** Switching from recurring to explicit slots should generate exactly classCount slots and sync events.

**Preconditions / Setup**

- Have an existing duration-based class with a recurring pattern.

**Steps**

1. Open edit mode.
1. Change classType from `duration` → `count`.
1. Set `classCount = N` and confirm UI shows N specific slots.
1. Save.

**Expected results**

- DB: classType=count and exactly N explicit slot rows exist.
- Calendar: recurring series converted to N single events (or per design).
- busy-slots shows N explicit dates.

---

### TC 3.2.3 — Change classType back and forth (count → duration → count)

**Goal:** Repeated conversions must not leak ghost slots/events and final state must match UI/payload.

**Preconditions / Setup**

- Start with a count-based class with 2–3 slots.

**Steps**

1. Convert count → duration; Save.
1. Convert duration → count; set classCount and explicit slots; Save.
1. Verify DB/calendar have only the final expected representation.

**Expected results**

- No ghost slots (deleted slots filtered from busy-slots).
- No duplicated calendar events; final state matches last save.

---

### TC 3.3.1 — Update only schedule, don't touch other fields

**Goal:** Schedule-only edits must not affect non-schedule fields.

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-3.3.1",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    },
    {
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "startLocal": "2026-01-06T09:00:00+05:30",
        "endLocal": "2026-01-06T10:00:00+05:30",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Open edit mode.
1. Change slot #1 time 09:00–10:00 → 11:00–12:00.
1. Leave other fields unchanged.
1. Save.

**Copy/paste examples**

```bash
curl -sS -X PUT "$BASE_URL/api/classes/<classId>" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "classId": "<classId>",
  "title": "TC-3.3.1",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "schedules": [
    {
      "slotId": "slot_1",
      "start": "2026-01-05T11:00:00+05:30",
      "end": "2026-01-05T12:00:00+05:30",
      "eventId": "evt_1"
    },
    {
      "slotId": "slot_2",
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30",
      "eventId": "evt_2"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "slotId": "slot_1",
        "startUtc": "2026-01-05T05:30:00Z",
        "endUtc": "2026-01-05T06:30:00Z"
      },
      {
        "slotId": "slot_2",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Expected results**

- DB: schedules updated; other fields unchanged.
- Calendar: only affected event updated.

---

### TC 3.3.2 — Update only non-schedule fields, don't touch slots

**Goal:** Non-schedule edits must not affect schedules.

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-3.3.2",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    },
    {
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "startLocal": "2026-01-06T09:00:00+05:30",
        "endLocal": "2026-01-06T10:00:00+05:30",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Open edit mode.
1. Change capacity 10 → 15.
1. Do not touch slots.
1. Save.

**Copy/paste examples**

```bash
curl -sS -X PUT "$BASE_URL/api/classes/<classId>" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "classId": "<classId>",
  "title": "TC-3.3.2",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "schedules": [
    {
      "slotId": "slot_1",
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30",
      "eventId": "evt_1"
    },
    {
      "slotId": "slot_2",
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30",
      "eventId": "evt_2"
    }
  ],
  "capacity": 15,
  "_debug": {
    "utcPreview": [
      {
        "slotId": "slot_1",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "slotId": "slot_2",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Expected results**

- DB: capacity updated; schedules unchanged.
- Calendar unchanged.

---

### TC 3.4.1 — Update class with enrolled students

**Goal:** Editing a class with enrollments should preserve enrollments and update schedules/events safely.

**Preconditions / Setup**

- Have a class with at least 2 enrolled students (stu_001, stu_002).
- Ensure enrollment records reference the class/slots appropriately.

**Steps**

1. Edit the class and change slot #1 time.
1. Save.
1. Verify students remain enrolled and (if applicable) notifications/calendar updates occur.

**Expected results**

- DB: slot updated; enrollment count unchanged.
- If you sync student calendars: their events update accordingly (or an update notification is queued).

---

### TC 3.4.2 — Remove slot that students are enrolled in

**Goal:** Removing an enrolled slot must follow product rules (block vs cascade handling).

**Preconditions / Setup**

- Have a class with a slot that has enrolled students.

**Steps**

1. Attempt to remove the enrolled slot in edit mode.
1. Save.

**Expected results**

- If `POLICY_BLOCK_DELETE_ENROLLED_SLOT=true`: UI/API blocks with message like `Cannot remove slot with enrolled students`.
- If allowed: system must reassign/cancel enrollments and notify students; calendar events removed accordingly.

**Notes**

- Document and verify your rule; ensure no orphaned enrollments remain.

---

### TC 3.5.1 — Update class after notifications sent

**Goal:** After initial notifications, schedule changes should trigger update notifications (or logs) per design.

**Preconditions / Setup**

- A class where notifications have already been sent (e.g., invite emails).

**Steps**

1. Edit slot time and save.
1. Check notification log/queue.

**Expected results**

- DB updated.
- If notifications are expected: an update notification is queued/sent and logged.
- Calendar updated accordingly.

---

### TC 3.5.2 — Update class before notifications sent

**Goal:** Before notifications send, updated schedule should be what notifications reference.

**Preconditions / Setup**

- A class where notifications are scheduled but not sent yet.

**Steps**

1. Edit slot time and save.
1. Trigger notification sending (if possible).

**Expected results**

- Notifications (when sent) reference the updated slot times.

---

### TC 3.6.1 — Update class, calendar sync fails

**Goal:** DB should update even if calendar fails; errors logged; busy-slots based on DB.

**Preconditions / Setup**

- Enable a fault injection to make calendar API fail for update calls.

**Steps**

1. Edit a slot time and save (while calendar API is failing).
1. Verify UI messaging and DB state.
1. Check busy-slots and calendar.

**Expected results**

- DB: updated schedule stored.
- Calendar: event not updated.
- busy-slots: shows updated schedule (DB source of truth).
- System logs error; provides retry mechanism if available.

---

### TC 3.6.2 — Update class after previous calendar sync failure

**Goal:** Retry on missing event IDs should attempt to create events again.

**Preconditions / Setup**

- A class with at least one slot missing eventId due to prior sync failure.

**Steps**

1. Edit that slot (or save without changes if retry on save is supported).
1. Save.

**Expected results**

- Backend attempts to create missing calendar events; on success, eventId is filled in DB.
- No duplicate events for slots that already had eventId.

---

### TC 3.7.1 — Save without touching schedules

**Goal:** Resaving unchanged schedules must be idempotent.

**Preconditions / Setup**

- Have an existing class with slots.

**Steps**

1. Open edit mode.
1. Do not change schedules.
1. Save.

**Expected results**

- No duplicate DB slots or calendar events.
- No schedule mutation (time drift).

---

### TC 3.7.2 — Save after making changes, then save again without changes

**Goal:** Second save should be a no-op and not duplicate or re-notify unexpectedly.

**Preconditions / Setup**

- Have an existing class with slots.

**Steps**

1. Edit one slot time and save (first save).
1. Re-open edit form and save again with no changes (second save).

**Expected results**

- First save updates DB/calendar once.
- Second save does not create duplicates; calendar unchanged; notifications not resent unless designed.

---


## 4. Delete / remove slot cases

### TC 4.1.1 — Remove one slot when classCount > 1

**Goal:** Cannot save if removing a slot would make slotCount < classCount.

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-4.1.1",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 3,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    },
    {
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30"
    },
    {
      "start": "2026-01-07T09:00:00+05:30",
      "end": "2026-01-07T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "startLocal": "2026-01-06T09:00:00+05:30",
        "endLocal": "2026-01-06T10:00:00+05:30",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      },
      {
        "startLocal": "2026-01-07T09:00:00+05:30",
        "endLocal": "2026-01-07T10:00:00+05:30",
        "startUtc": "2026-01-07T03:30:00Z",
        "endUtc": "2026-01-07T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Open edit mode.
1. Remove slot #2 (middle).
1. Attempt to Save.

**Copy/paste examples**

```bash
curl -sS -X PUT "$BASE_URL/api/classes/<classId>" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "classId": "<classId>",
  "title": "TC-4.1.1",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 3,
  "schedules": [
    {
      "slotId": "slot_1",
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30",
      "eventId": "evt_1"
    },
    {
      "slotId": "slot_2",
      "start": "2026-01-07T09:00:00+05:30",
      "end": "2026-01-07T10:00:00+05:30",
      "eventId": "evt_2"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "slotId": "slot_1",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "slotId": "slot_2",
        "startUtc": "2026-01-07T03:30:00Z",
        "endUtc": "2026-01-07T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Expected results**

- UI blocks or API rejects `Cannot have fewer slots than classCount`.
- DB and Calendar unchanged.

---

### TC 4.1.2 — Remove last slot (classCount = 1)

**Goal:** Cannot remove the only slot (must keep at least 1).

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-4.1.2",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 1,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Open edit mode.
1. Attempt to remove the only slot.
1. Attempt to Save.

**Expected results**

- UI blocks or API rejects `Cannot remove last slot`.
- DB and Calendar unchanged.

---

### TC 4.1.3 — Remove slot from middle of sequence

**Goal:** Removing a middle slot is allowed only if classCount is reduced accordingly.

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-4.1.3",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 3,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    },
    {
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30"
    },
    {
      "start": "2026-01-07T09:00:00+05:30",
      "end": "2026-01-07T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "startLocal": "2026-01-06T09:00:00+05:30",
        "endLocal": "2026-01-06T10:00:00+05:30",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      },
      {
        "startLocal": "2026-01-07T09:00:00+05:30",
        "endLocal": "2026-01-07T10:00:00+05:30",
        "startUtc": "2026-01-07T03:30:00Z",
        "endUtc": "2026-01-07T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Open edit mode.
1. Remove the middle slot (2026-01-06).
1. If classCount remains 3, attempt Save (expect rejection).
1. Then set classCount=2 and Save (expect success).

**Copy/paste examples**

```bash
curl -sS -X PUT "$BASE_URL/api/classes/<classId>" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "classId": "<classId>",
  "title": "TC-4.1.3-reject",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 3,
  "schedules": [
    {
      "slotId": "slot_1",
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30",
      "eventId": "evt_1"
    },
    {
      "slotId": "slot_2",
      "start": "2026-01-07T09:00:00+05:30",
      "end": "2026-01-07T10:00:00+05:30",
      "eventId": "evt_2"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "slotId": "slot_1",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "slotId": "slot_2",
        "startUtc": "2026-01-07T03:30:00Z",
        "endUtc": "2026-01-07T04:30:00Z"
      }
    ]
  }
}
JSON
```
```bash
curl -sS -X PUT "$BASE_URL/api/classes/<classId>" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "classId": "<classId>",
  "title": "TC-4.1.3-accept",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "schedules": [
    {
      "slotId": "slot_1",
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30",
      "eventId": "evt_1"
    },
    {
      "slotId": "slot_2",
      "start": "2026-01-07T09:00:00+05:30",
      "end": "2026-01-07T10:00:00+05:30",
      "eventId": "evt_2"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "slotId": "slot_1",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "slotId": "slot_2",
        "startUtc": "2026-01-07T03:30:00Z",
        "endUtc": "2026-01-07T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Expected results**

- With classCount=3: rejected.
- With classCount=2: accepted; middle slot removed; calendar event deleted.

---

### TC 4.2.1 — Remove slot that exists in calendar

**Goal:** Deleting a slot with eventId should delete the corresponding calendar event.

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-4.2.1",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    },
    {
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "startLocal": "2026-01-06T09:00:00+05:30",
        "endLocal": "2026-01-06T10:00:00+05:30",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      }
    ]
  }
}
JSON
```
- Ensure slot #1 has a valid eventId.

**Steps**

1. Open edit mode.
1. Remove slot #1 (2026-01-05).
1. Set classCount=1 (if required by UI).
1. Save.

**Copy/paste examples**

```bash
curl -sS -X PUT "$BASE_URL/api/classes/<classId>" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "classId": "<classId>",
  "title": "TC-4.2.1",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 1,
  "schedules": [
    {
      "slotId": "slot_1",
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30",
      "eventId": "evt_1"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "slotId": "slot_1",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Expected results**

- DB: slot deleted/soft-deleted.
- Calendar: the event for removed slot is deleted via eventId.
- busy-slots for 2026-01-05 no longer includes that slot.

---

### TC 4.2.2 — Remove slot that has no calendar event (sync failed)

**Goal:** Deleting a slot without eventId should remove DB slot without calendar operations.

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-4.2.2",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 1,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      }
    ]
  }
}
JSON
```
- Force calendar creation failure on create so the slot has `eventId = null`.

**Steps**

1. Open edit mode.
1. Remove the slot.
1. Attempt to Save (may require classCount change / cannot remove last slot based on your rules).

**Expected results**

- DB: slot removed/soft-deleted.
- Calendar: no changes (no event existed).

---

### TC 4.3.1 — Remove slot that is already marked past (is_past=true)

**Goal:** Past slot removal should follow policy and behave consistently.

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-4.3.1",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 1,
  "capacity": 10,
  "schedules": [
    {
      "start": "2025-12-01T09:00:00+05:30",
      "end": "2025-12-01T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2025-12-01T09:00:00+05:30",
        "endLocal": "2025-12-01T10:00:00+05:30",
        "startUtc": "2025-12-01T03:30:00Z",
        "endUtc": "2025-12-01T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Open edit mode.
1. Attempt to remove the past slot.
1. Save.

**Expected results**

- If `POLICY_ALLOW_DELETE_PAST_SLOTS=false`: reject/disable.
- If allowed: remove slot and delete calendar event.

---

### TC 4.3.2 — Remove slot that is upcoming but in past relative to now (yesterday)

**Goal:** Ensure the system uses actual current time when deciding 'past' vs 'future'.

**Preconditions / Setup**

- Set the system clock (or use test-time override) so 'today' = 2026-01-05 local.
- Create a class with a slot on 2026-01-04 09:00–10:00.

**Steps**

1. Open edit mode on 2026-01-05.
1. Attempt to remove the 2026-01-04 slot.
1. Save.

**Expected results**

- Slot should be treated as past (because it's yesterday).
- Behavior follows your past-slot deletion policy.

---

### TC 4.4.1 — Remove slot and re-add same date/time

**Goal:** Replacing a slot should not leave ghost DB rows or duplicated calendar events.

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-4.4.1",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 1,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Open edit mode.
1. Remove the slot.
1. Add a new slot with the same date/time.
1. Save.

**Expected results**

- DB: old slot removed, new slot created (new slotId).
- Calendar: old event deleted and new event created OR updated safely; no duplicates.

**Notes**

- If your UI forbids removing last slot, increase classCount temporarily or use a classCount>1 base fixture.

---

### TC 4.4.2 — Remove slot and re-add different date/time

**Goal:** Removing then adding a different slot should delete old event and create new event.

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-4.4.2",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    },
    {
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "startLocal": "2026-01-06T09:00:00+05:30",
        "endLocal": "2026-01-06T10:00:00+05:30",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Open edit mode.
1. Remove slot #1 (2026-01-05 09:00–10:00).
1. Add new slot 2026-01-06 11:00–12:00 (or 2026-01-07).
1. Save.

**Expected results**

- DB and Calendar reflect the new set exactly (no ghost for removed slot).

---

### TC 4.5.1 — Removed slot should NOT appear in busy-slots

**Goal:** After a saved removal, busy-slots must not include the deleted slot.

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-4.5.1",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    },
    {
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "startLocal": "2026-01-06T09:00:00+05:30",
        "endLocal": "2026-01-06T10:00:00+05:30",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Open edit mode.
1. Remove the 2026-01-05 slot and save (adjust classCount if needed).
1. Query busy-slots for 2026-01-05.

**Copy/paste examples**

```bash
curl -sS -X PUT "$BASE_URL/api/classes/<classId>" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "classId": "<classId>",
  "title": "TC-4.5.1",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 1,
  "schedules": [
    {
      "slotId": "slot_1",
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30",
      "eventId": "evt_1"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "slotId": "slot_1",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      }
    ]
  }
}
JSON
```
```bash
curl -sS "$BASE_URL/api/availability/busy-slots?instructorId=inst_001&startDate=2026-01-05&endDate=2026-01-05&timeZone=Asia/Kolkata" -H "Authorization: Bearer $TOKEN" | jq
```

**Expected results**

- busy-slots response does NOT contain the removed slot.

---

### TC 4.5.2 — Removed slot should NOT appear in calendar

**Goal:** Calendar must not show deleted slot events after save.

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-4.5.2",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    },
    {
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "startLocal": "2026-01-06T09:00:00+05:30",
        "endLocal": "2026-01-06T10:00:00+05:30",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Remove the 2026-01-05 slot and save.
1. Open Google Calendar and confirm the event is gone.

**Expected results**

- Calendar shows no event for removed slot; event count reduced accordingly.

---

### TC 4.5.3 — Removed slot should NOT block availability checks

**Goal:** Availability check should return available=true once slot is deleted and cache invalidated.

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-4.5.3",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    },
    {
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "startLocal": "2026-01-06T09:00:00+05:30",
        "endLocal": "2026-01-06T10:00:00+05:30",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Remove the 2026-01-05 09:00–10:00 slot and save.
1. Call availability check for 2026-01-05 09:00–10:00.

**Copy/paste examples**

```bash
curl -sS "$BASE_URL/api/availability/check?instructorId=inst_001&date=2026-01-05&startTime=09:00&endTime=10:00&timeZone=Asia/Kolkata" -H "Authorization: Bearer $TOKEN" | jq
```

**Expected results**

- Availability returns `available=true` (assuming no other conflicts).

---


## 5. Availability & busy-slots edge cases

### TC 5.1.1 — busy-slots returns slots not visible in UI

**Goal:** Confirm busy-slots uses DB as source of truth (so it can reveal stale/unsaved slots).

**Preconditions / Setup**

- Have a class where DB has 3 slots but the edit UI currently shows only 2 (e.g., remove one in UI without saving OR simulate stale UI).

**Steps**

1. Open edit UI and confirm only 2 slots display.
1. Call busy-slots for the affected date range.
1. Confirm 3 slots are returned (from DB).

**Copy/paste examples**

```bash
curl -sS "$BASE_URL/api/availability/busy-slots?instructorId=inst_001&startDate=2026-01-05&endDate=2026-01-07&timeZone=Asia/Kolkata" -H "Authorization: Bearer $TOKEN" | jq
```

**Expected results**

- busy-slots returns the DB state (3 slots), even if UI currently shows fewer (unsaved).
- Document this as expected behavior: DB is source of truth until save.

---

### TC 5.1.2 — busy-slots returns slots from DB but removed from UI (not saved)

**Goal:** Removing a slot in UI without saving should not affect busy-slots.

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-5.1.2",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    },
    {
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "startLocal": "2026-01-06T09:00:00+05:30",
        "endLocal": "2026-01-06T10:00:00+05:30",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Open edit mode and remove one slot **without saving**.
1. Query busy-slots for that date.

**Copy/paste examples**

```bash
curl -sS "$BASE_URL/api/availability/busy-slots?instructorId=inst_001&startDate=2026-01-05&endDate=2026-01-05&timeZone=Asia/Kolkata" -H "Authorization: Bearer $TOKEN" | jq
```

**Expected results**

- busy-slots still includes the removed-in-UI slot because it still exists in DB.
- Frontend must not exclude removed slots when displaying conflicts.

---

### TC 5.1.3 — busy-slots returns slots from same class (should be excluded in edit mode)

**Goal:** In edit mode, availability checks should not treat the class’s own slots as conflicts.

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-5.1.3",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 1,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Open edit mode for the class.
1. Trigger availability check for the same time range as the class’s own slot.
1. Verify own slot is excluded from conflict evaluation (via backend `excludeClassId` or frontend filtering).

**Copy/paste examples**

```bash
curl -sS "$BASE_URL/api/availability/busy-slots?instructorId=inst_001&startDate=2026-01-05&endDate=2026-01-05&timeZone=Asia/Kolkata&excludeClassId=<classId>" -H "Authorization: Bearer $TOKEN" | jq
```

**Expected results**

- No conflict is shown for the class’s own slot during edit mode (self-exclusion works).

---

### TC 5.1.4 — busy-slots returns slots from different class

**Goal:** Confirm busy-slots includes real conflicts from other classes.

**Preconditions / Setup**

- Create two classes for inst_001 on the same date/time (or ensure at least one other class exists in range).

**Steps**

1. Query busy-slots for the date range.
1. Confirm slots from other classes appear in response and are identifiable by classId/title.

**Copy/paste examples**

```bash
curl -sS "$BASE_URL/api/availability/busy-slots?instructorId=inst_001&startDate=2026-01-05&endDate=2026-01-05&timeZone=Asia/Kolkata" -H "Authorization: Bearer $TOKEN" | jq
```

**Expected results**

- busy-slots includes slots from other classes (real conflicts).

---

### TC 5.2.1 — busy-slots returns multiple slots on same day from same class

**Goal:** Confirm response can include multiple slots for same date and does not collapse/overwrite them.

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-5.2.1",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    },
    {
      "start": "2026-01-05T14:00:00+05:30",
      "end": "2026-01-05T15:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "startLocal": "2026-01-05T14:00:00+05:30",
        "endLocal": "2026-01-05T15:00:00+05:30",
        "startUtc": "2026-01-05T08:30:00Z",
        "endUtc": "2026-01-05T09:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Query busy-slots for 2026-01-05.
1. Verify two slots returned for that date.

**Copy/paste examples**

```bash
curl -sS "$BASE_URL/api/availability/busy-slots?instructorId=inst_001&startDate=2026-01-05&endDate=2026-01-05&timeZone=Asia/Kolkata" -H "Authorization: Bearer $TOKEN" | jq
```

**Expected results**

- Response includes both slots (09:00–10:00 and 14:00–15:00).
- If response is grouped by date, date group contains 2 entries.

---

### TC 5.2.2 — busy-slots returns multiple slots on same day from different classes

**Goal:** Confirm multiple classes' slots on the same day appear distinctly.

**Preconditions / Setup**

- Create Class A with slot 2026-01-05 09:00–10:00 and Class B with slot 2026-01-05 14:00–15:00 for same instructor.

**Steps**

1. Query busy-slots for 2026-01-05.
1. Verify two slots returned with different class identifiers.

**Copy/paste examples**

```bash
curl -sS "$BASE_URL/api/availability/busy-slots?instructorId=inst_001&startDate=2026-01-05&endDate=2026-01-05&timeZone=Asia/Kolkata" -H "Authorization: Bearer $TOKEN" | jq
```

**Expected results**

- Response contains entries for both classes; no data loss.

---

### TC 5.3.1 — Checking availability while editing (self-exclusion should work)

**Goal:** Editing flow should not show conflict for own existing slot.

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-5.3.1",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 1,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Open edit mode.
1. Run availability check for 2026-01-05 09:00–10:00.
1. Confirm it reports available (no self-conflict).

**Copy/paste examples**

```bash
curl -sS "$BASE_URL/api/availability/check?instructorId=inst_001&date=2026-01-05&startTime=09:00&endTime=10:00&timeZone=Asia/Kolkata" -H "Authorization: Bearer $TOKEN" | jq
```

**Expected results**

- Availability check does NOT flag own slot as conflict in edit context (via exclusion/filter).

---

### TC 5.3.2 — Checking availability while creating (no self-exclusion)

**Goal:** Create flow should show all conflicts since the class doesn’t exist yet.

**Preconditions / Setup**

- Have at least one existing class slot on 2026-01-05 09:00–10:00.

**Steps**

1. Open Create Class form.
1. Run availability check for 2026-01-05 09:00–10:00.
1. Confirm conflict is shown.

**Copy/paste examples**

```bash
curl -sS "$BASE_URL/api/availability/check?instructorId=inst_001&date=2026-01-05&startTime=09:00&endTime=10:00&timeZone=Asia/Kolkata" -H "Authorization: Bearer $TOKEN" | jq
```

**Expected results**

- Availability shows conflicts from existing classes (no self-exclusion in create mode).

---

### TC 5.4.1 — Checking availability with timezone boundary crossing

**Goal:** When querying by local date, slots stored in UTC must map to correct local day.

**Preconditions / Setup**

- Store/create a slot at 2026-01-05 02:00–03:00 IST (which is 2026-01-04 20:30–21:30 UTC).

**Steps**

1. Query busy-slots for local date 2026-01-05 with timeZone=Asia/Kolkata.
1. Verify the slot appears under 2026-01-05 (local), not 2026-01-04 (UTC).

**Copy/paste examples**

```bash
curl -sS "$BASE_URL/api/availability/busy-slots?instructorId=inst_001&startDate=2026-01-05&endDate=2026-01-05&timeZone=Asia/Kolkata" -H "Authorization: Bearer $TOKEN" | jq
```

**Expected results**

- busy-slots includes the slot mapped to local date 2026-01-05.

---

### TC 5.4.2 — Querying busy-slots by local date vs UTC date

**Goal:** Ensure date range conversion happens correctly for the requested timezone.

**Preconditions / Setup**

- Have a slot stored as `2026-01-04T20:30:00Z` (UTC) which corresponds to 2026-01-05 02:00 IST.

**Steps**

1. Query busy-slots for startDate=2026-01-05 in IST.
1. Confirm the UTC-stored slot is returned and displayed as 2026-01-05 local.

**Copy/paste examples**

```bash
curl -sS "$BASE_URL/api/availability/busy-slots?instructorId=inst_001&startDate=2026-01-05&endDate=2026-01-05&timeZone=Asia/Kolkata" -H "Authorization: Bearer $TOKEN" | jq
```

**Expected results**

- Slot is included when querying by local day 2026-01-05 IST.

---

### TC 5.5.1 — startDate/endDate filters correctness (single date)

**Goal:** busy-slots must return ONLY slots in the requested date (after TZ conversion).

**Preconditions / Setup**

- Have slots on 2026-01-05 and 2026-01-06.

**Steps**

1. Query busy-slots for startDate=2026-01-05&endDate=2026-01-05.
1. Verify no slots from 2026-01-06 appear.

**Copy/paste examples**

```bash
curl -sS "$BASE_URL/api/availability/busy-slots?instructorId=inst_001&startDate=2026-01-05&endDate=2026-01-05&timeZone=Asia/Kolkata" -H "Authorization: Bearer $TOKEN" | jq
```

**Expected results**

- Response includes only 2026-01-05 slots.

---

### TC 5.5.2 — startDate/endDate filters correctness (date range)

**Goal:** busy-slots must return all slots in the inclusive date range and none outside.

**Preconditions / Setup**

- Have slots on 2026-01-05, 2026-01-06, 2026-01-07, and also on 2026-01-08 (outside range).

**Steps**

1. Query busy-slots for 2026-01-05 → 2026-01-07.
1. Verify only 05/06/07 returned.

**Copy/paste examples**

```bash
curl -sS "$BASE_URL/api/availability/busy-slots?instructorId=inst_001&startDate=2026-01-05&endDate=2026-01-07&timeZone=Asia/Kolkata" -H "Authorization: Bearer $TOKEN" | jq
```

**Expected results**

- Response includes 05/06/07 and excludes 08.

---

### TC 5.6.1 — Cached vs live data inconsistencies

**Goal:** If busy-slots is cached, validate cache invalidation and freshness behavior.

**Preconditions / Setup**

- Caching enabled for busy-slots (if applicable).

**Steps**

1. Remove a slot and save.
1. Immediately call busy-slots and observe whether it shows stale data.
1. Repeat after cache TTL expires or after invalidation.

**Expected results**

- If cached: you may see stale slot briefly; but must converge to correct DB state.
- If live: should reflect deletion immediately.
- In all cases: document cache TTL and invalidation strategy.

---

### TC 5.6.2 — busy-slots after slot deletion (cache invalidation)

**Goal:** After deletion, busy-slots must not keep returning the removed slot.

**Preconditions / Setup**

- A class with a slot on 2026-01-05 09:00–10:00.

**Steps**

1. Delete the slot and save.
1. Call busy-slots for 2026-01-05 until cache should be invalidated.
1. Verify removed slot no longer appears.

**Copy/paste examples**

```bash
curl -sS "$BASE_URL/api/availability/busy-slots?instructorId=inst_001&startDate=2026-01-05&endDate=2026-01-05&timeZone=Asia/Kolkata" -H "Authorization: Bearer $TOKEN" | jq
```

**Expected results**

- Removed slot does not appear after invalidation; no phantom conflicts.

---

### TC 5.7.1 — Soft-deleted slot appears in busy-slots

**Goal:** busy-slots must filter out soft-deleted slots.

**Preconditions / Setup**

- Create a slot then mark it `is_deleted=true` in DB (soft-delete).

**Steps**

1. Query busy-slots for that date.
1. Verify soft-deleted slot is not returned.

**Expected results**

- No soft-deleted slots in response.

**DB checks (examples)**

```sql
SELECT * FROM class_slots WHERE is_deleted=true AND start_utc::date = '2026-01-05';
```

---

### TC 5.7.2 — Stale slot from removed/deleted class appears in busy-slots

**Goal:** busy-slots must exclude slots from deleted classes.

**Preconditions / Setup**

- Mark a class `is_deleted=true` but leave its slot rows in DB.

**Steps**

1. Query busy-slots for the date range.
1. Verify slots from deleted class are excluded.

**Expected results**

- No slots from deleted classes returned.

**DB checks (examples)**

```sql
SELECT c.is_deleted, s.* FROM classes c JOIN class_slots s ON s.class_id=c.class_id WHERE c.is_deleted=true;
```

---

### TC 5.7.3 — Inactive class slots appear in busy-slots

**Goal:** busy-slots must exclude inactive classes.

**Preconditions / Setup**

- Have a class with `status='Inactive'` and slots present in DB.

**Steps**

1. Query busy-slots for the date range.
1. Verify inactive class slots are excluded.

**Expected results**

- No slots from inactive classes returned.

**DB checks (examples)**

```sql
SELECT c.status, s.* FROM classes c JOIN class_slots s ON s.class_id=c.class_id WHERE c.status <> 'Active';
```

---


## 6. Timezone & date-boundary cases

### TC 6.1.1 — Slot stored as UTC, displayed as next-day local

**Goal:** Verify UTC storage and local display are consistent across UI/DB/calendar.

**Preconditions / Setup**

- User/instructor timezone set to Asia/Kolkata.
- System stores datetimes in UTC in DB (common approach).

**Steps**

1. Create a slot at 2026-01-05 02:00–03:00 IST.
1. Inspect DB to confirm stored UTC datetime.
1. Check UI and calendar display.

**Copy/paste examples**

```text
Local start/end: 2026-01-05T02:00:00+05:30 → 2026-01-05T03:00:00+05:30
UTC start/end: 2026-01-04T20:30:00Z → 2026-01-04T21:30:00Z
```

**Expected results**

- DB stores UTC times (e.g., 2026-01-04 20:30Z for 02:00 IST).
- UI displays local date/time 2026-01-05 02:00–03:00.
- Calendar displays correct local time for viewer.

---

### TC 6.1.2 — Querying busy-slots by local date finds UTC-stored slot

**Goal:** busy-slots date filtering must convert local date ranges to UTC ranges correctly.

**Preconditions / Setup**

- A slot stored in DB as 2026-01-04T20:30:00Z (UTC) representing 2026-01-05 02:00 IST.

**Steps**

1. Query busy-slots for startDate=2026-01-05 with timeZone=Asia/Kolkata.
1. Verify the slot is included and returned on local date 2026-01-05.

**Copy/paste examples**

```bash
curl -sS "$BASE_URL/api/availability/busy-slots?instructorId=inst_001&startDate=2026-01-05&endDate=2026-01-05&timeZone=Asia/Kolkata" -H "Authorization: Bearer $TOKEN" | jq
```

**Expected results**

- Response includes the slot under 2026-01-05 (local).

---

### TC 6.2.1 — Same UTC time maps to different local dates

**Goal:** Same slot should display different local dates/times for users in different timezones.

**Preconditions / Setup**

- Slot stored at 2026-01-04T20:30:00Z.

**Steps**

1. View the slot in UI as an IST user and as an EST/New York user.
1. Compare displayed local date/time.

**Copy/paste examples**

```text
UTC: 2026-01-04T20:30:00Z
As IST: 2026-01-05T02:00:00+05:30
As America/New_York: 2026-01-04T15:30:00-05:00
```

**Expected results**

- IST user sees 2026-01-05 02:00 (next day).
- EST user sees 2026-01-04 afternoon (previous day).
- Both are correct and consistent with UTC storage.

---

### TC 6.3.1 — Edit slot near midnight (date boundary)

**Goal:** Editing across midnight must store correct date/time and show on correct local day.

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-6.3.1",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 1,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T23:00:00+05:30",
      "end": "2026-01-06T00:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T23:00:00+05:30",
        "endLocal": "2026-01-06T00:00:00+05:30",
        "startUtc": "2026-01-05T17:30:00Z",
        "endUtc": "2026-01-05T18:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Open edit mode.
1. Change slot from 2026-01-05 23:00–00:00 → 2026-01-06 01:00–02:00.
1. Save.

**Copy/paste examples**

```bash
curl -sS -X PUT "$BASE_URL/api/classes/<classId>" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "classId": "<classId>",
  "title": "TC-6.3.1",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 1,
  "schedules": [
    {
      "slotId": "slot_1",
      "start": "2026-01-06T01:00:00+05:30",
      "end": "2026-01-06T02:00:00+05:30",
      "eventId": "evt_1"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "slotId": "slot_1",
        "startUtc": "2026-01-05T19:30:00Z",
        "endUtc": "2026-01-05T20:30:00Z"
      }
    ]
  }
}
JSON
```

**Expected results**

- DB updated correctly; busy-slots shows slot on 2026-01-06.
- Calendar event updated to new date/time.

---

### TC 6.3.2 — Create slot that spans midnight

**Goal:** Slots spanning midnight must store end time on the next day and display correctly.

**Preconditions / Setup**

- Timezone = Asia/Kolkata.

**Steps**

1. Create a count-based class with a single slot 2026-01-05 23:00–00:00 (spans midnight).
1. Save.
1. Verify storage and busy-slots grouping (often grouped by start date).

**Copy/paste examples**

```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "TC-6.3.2",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 1,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T23:00:00+05:30",
      "end": "2026-01-06T00:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T23:00:00+05:30",
        "endLocal": "2026-01-06T00:00:00+05:30",
        "startUtc": "2026-01-05T17:30:00Z",
        "endUtc": "2026-01-05T18:30:00Z"
      }
    ]
  }
}
JSON
```
```text
Local start/end: 2026-01-05T23:00:00+05:30 → 2026-01-06T00:00:00+05:30
UTC start/end: 2026-01-05T17:30:00Z → 2026-01-05T18:30:00Z
```

**Expected results**

- DB stores end datetime on 2026-01-06 (UTC conversion accordingly).
- busy-slots shows it on the correct day (define whether you group by start date).
- Calendar event spans midnight correctly.

---

### TC 6.4.1 — Consistency between stored dateTime and displayed date

**Goal:** The UI date should reflect local date derived from stored UTC time.

**Preconditions / Setup**

- DB stores UTC; UI displays in user timezone.

**Steps**

1. Create a slot (e.g., 2026-01-05 09:00–10:00 IST).
1. Check DB UTC and UI local display.

**Expected results**

- Converting DB UTC → local yields the same date/time shown in UI.
- No off-by-one-day errors around midnight.

---

### TC 6.4.2 — Edit slot, verify date consistency maintained

**Goal:** After editing date, stored UTC must update accordingly and UI shows the new local date.

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-6.4.2",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 1,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Edit slot date 2026-01-05 → 2026-01-06; keep same local time.
1. Save.
1. Verify DB UTC values changed accordingly and UI shows 2026-01-06.

**Expected results**

- DB UTC updated; UI and calendar display new date/time correctly.

---


## 7. Self-conflict & exclusion logic

### TC 7.1.1 — Self-exclusion works when editing (slots in current UI)

**Goal:** Availability check must not flag current class slots as conflicts while editing.

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-7.1.1",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 1,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Open edit mode for the class.
1. Trigger busy-slots request for 2026-01-05.
1. Verify availability UI does not show a conflict for the class’s own slot.

**Copy/paste examples**

```bash
curl -sS "$BASE_URL/api/availability/busy-slots?instructorId=inst_001&startDate=2026-01-05&endDate=2026-01-05&timeZone=Asia/Kolkata" -H "Authorization: Bearer $TOKEN" | jq
```

**Expected results**

- If backend supports exclusion: request includes excludeClassId and response omits own slots.
- If frontend filters: busy-slots may include own slots but UI filters them out correctly.

---

### TC 7.1.2 — Self-exclusion works when editing (slots match current UI state)

**Goal:** Frontend filtering should match against current UI schedules (not a stale copy).

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-7.1.2",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    },
    {
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "startLocal": "2026-01-06T09:00:00+05:30",
        "endLocal": "2026-01-06T10:00:00+05:30",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Open edit mode.
1. Ensure UI shows exactly 2 slots.
1. Trigger busy-slots and verify the UI excludes conflicts that match those 2 current slots.

**Expected results**

- No self-conflict warnings for the class’s own current slots.

---

### TC 7.2.1 — Removed slot should NOT be excluded (should show as conflict)

**Goal:** If slot is removed in UI (not saved), it must not be excluded by self-exclusion filter.

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-7.2.1",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 1,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Open edit mode.
1. Remove the slot from UI WITHOUT saving.
1. Run availability check for 2026-01-05 09:00–10:00.

**Expected results**

- Availability shows conflict (because DB still has the slot).
- Frontend self-exclusion uses **current UI state**, so it should not filter the removed slot.

---

### TC 7.2.2 — Removed slot after save should NOT appear in busy-slots

**Goal:** After saving the removal, busy-slots must no longer return the deleted slot.

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-7.2.2",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    },
    {
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "startLocal": "2026-01-06T09:00:00+05:30",
        "endLocal": "2026-01-06T10:00:00+05:30",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Open edit mode.
1. Remove the 2026-01-05 slot and save (adjust classCount if needed).
1. Query busy-slots for 2026-01-05.

**Copy/paste examples**

```bash
curl -sS "$BASE_URL/api/availability/busy-slots?instructorId=inst_001&startDate=2026-01-05&endDate=2026-01-05&timeZone=Asia/Kolkata" -H "Authorization: Bearer $TOKEN" | jq
```

**Expected results**

- busy-slots does not include the removed slot; availability becomes free for that time (unless other conflicts).

---

### TC 7.3.1 — Exclusion by classId (if implemented)

**Goal:** If backend supports excludeClassId, confirm it works and is correctly wired from UI.

**Preconditions / Setup**

- Backend exposes `excludeClassId` parameter (optional feature).

**Steps**

1. Call busy-slots with excludeClassId set to the class being edited.
1. Confirm response contains no entries for that classId.

**Copy/paste examples**

```bash
curl -sS "$BASE_URL/api/availability/busy-slots?instructorId=inst_001&startDate=2026-01-05&endDate=2026-01-06&timeZone=Asia/Kolkata&excludeClassId=cls_123" -H "Authorization: Bearer $TOKEN" | jq
```

**Expected results**

- Response excludes classId=cls_123 slots.

---

### TC 7.3.2 — Exclusion by slotId (if implemented)

**Goal:** If backend supports excludeSlotIds, confirm it works.

**Preconditions / Setup**

- Backend exposes `excludeSlotIds` query param (optional).

**Steps**

1. Call busy-slots with excludeSlotIds=slot_1,slot_2.
1. Confirm response contains no entries with those slotIds.

**Copy/paste examples**

```bash
curl -sS "$BASE_URL/api/availability/busy-slots?instructorId=inst_001&startDate=2026-01-05&endDate=2026-01-05&excludeSlotIds=slot_1,slot_2" -H "Authorization: Bearer $TOKEN" | jq
```

**Expected results**

- Response excludes the specified slot IDs.

---

### TC 7.3.3 — Exclusion by event_id (if implemented)

**Goal:** If backend supports excludeEventIds, confirm it works.

**Preconditions / Setup**

- Backend exposes `excludeEventIds` query param (optional).

**Steps**

1. Call busy-slots with excludeEventIds=evt_1.
1. Confirm response contains no entries with that eventId.

**Copy/paste examples**

```bash
curl -sS "$BASE_URL/api/availability/busy-slots?instructorId=inst_001&startDate=2026-01-05&endDate=2026-01-05&excludeEventIds=evt_1" -H "Authorization: Bearer $TOKEN" | jq
```

**Expected results**

- Response excludes specified event IDs.

---

### TC 7.3.4 — Exclusion by time overlap (current implementation)

**Goal:** If frontend excludes by matching time ranges, confirm matching is correct and stable.

**Preconditions / Setup**

- UI implements self-exclusion by comparing busy-slots entries to current UI slot ranges.

**Steps**

1. Edit a class and trigger busy-slots.
1. Verify UI filters out busy-slots entries that match current UI slots (same start/end).
1. Verify it does NOT filter unrelated entries that partially overlap unless intended.

**Expected results**

- Self slots excluded; other slots remain as conflicts.

---

### TC 7.4.1 — Exclusion using old UI state (stale originalSchedules)

**Goal:** Detect bug where removed slots are still excluded because filter uses originalSchedules.

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-7.4.1",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 1,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Open edit mode.
1. Remove the slot in UI (do not save).
1. Trigger busy-slots/availability check for the removed time.
1. If UI shows available (no conflict), it indicates stale exclusion bug.

**Expected results**

- Correct behavior: should show conflict (slot still in DB).
- Bug behavior: false available due to stale exclusion list.

---

### TC 7.4.2 — Exclusion using current UI state (correct)

**Goal:** Confirm exclusion uses current UI schedules so removed slots are not excluded.

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-7.4.2",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 1,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Open edit mode.
1. Remove slot in UI without saving.
1. Trigger availability check for the removed time.
1. Confirm conflict is shown.

**Expected results**

- Conflict is shown (because removed slot is not in current UI state to be excluded).

---


## 8. Sync consistency checks

### TC 8.1.1 — UI state matches payload exactly

**Goal:** Network payload must match UI slot list 1:1.

**Preconditions / Setup**

- Browser devtools open; network request body visible.

**Steps**

1. Create or edit a class and set N slots with specific dates/times.
1. Before saving, screenshot or copy the UI slot list.
1. Save and inspect request payload.
1. Compare UI slots vs payload schedules exactly.

**Expected results**

- Same count (N), same dates/times, same ordering (if order matters), no hidden slots.
- No time drift due to timezone conversion in *displayed* local values.

---

### TC 8.1.2 — Payload matches UI after slot removal

**Goal:** After removing a slot, payload must exclude it (no zombie schedules).

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-8.1.2",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    },
    {
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "startLocal": "2026-01-06T09:00:00+05:30",
        "endLocal": "2026-01-06T10:00:00+05:30",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Open edit mode.
1. Remove one slot in UI.
1. Inspect outgoing PUT payload before sending (or in devtools after).

**Expected results**

- Payload contains N-1 schedules and does not include removed slotId/time range.

---

### TC 8.2.1 — Payload accepted, DB matches payload

**Goal:** After successful save, DB record must match the payload exactly.

**Preconditions / Setup**

- DB read access.

**Steps**

1. Send a valid create/edit payload.
1. Query DB for class slots and compare to payload.

**Expected results**

- DB has exactly the same slots as payload (count + times + deletion flags).

---

### TC 8.2.2 — Payload rejected, DB unchanged

**Goal:** Rejected saves must not partially update DB.

**Preconditions / Setup**

- DB read access.

**Steps**

1. Attempt to save an invalid payload (e.g., slotCount != classCount).
1. Verify API returns 400/422.
1. Query DB and verify previous state unchanged.

**Expected results**

- No partial DB writes; if transaction used, it is fully rolled back.

---

### TC 8.3.1 — DB slots match calendar events (1:1)

**Goal:** Calendar sync must create exactly one event per slot and keep them aligned.

**Preconditions / Setup**

- Calendar sync enabled; ability to view calendar.

**Steps**

1. Create class with N slots and save.
1. Query DB slots and list event IDs.
1. Verify calendar contains exactly N events matching the DB slots.

**Expected results**

- Calendar event count equals DB slot count equals classCount.
- Each DB slot has exactly one corresponding calendar event; no duplicates.

---

### TC 8.3.2 — DB slot updated, calendar event updated

**Goal:** Updating a slot must update its calendar event via eventId (not duplicate).

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-8.3.2",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 1,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Edit slot time and save.
1. Verify DB slot updated.
1. Verify calendar event updated (same eventId) and not duplicated.

**Expected results**

- Calendar shows 1 updated event; not 2 events.

---

### TC 8.3.3 — DB slot deleted, calendar event deleted

**Goal:** Deleting a slot must delete the calendar event tied to it.

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-8.3.3",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 2,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    },
    {
      "start": "2026-01-06T09:00:00+05:30",
      "end": "2026-01-06T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      },
      {
        "startLocal": "2026-01-06T09:00:00+05:30",
        "endLocal": "2026-01-06T10:00:00+05:30",
        "startUtc": "2026-01-06T03:30:00Z",
        "endUtc": "2026-01-06T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Remove one slot and save (ensure classCount updated if required).
1. Verify DB slot deleted/soft-deleted.
1. Verify calendar event deleted.

**Expected results**

- Calendar no longer contains the deleted event; event count reduced.

---

### TC 8.4.1 — busy-slots matches DB (source of truth)

**Goal:** busy-slots should be derived from DB active slots (filtered) and match DB output.

**Preconditions / Setup**

- DB read access.

**Steps**

1. Query busy-slots for a date range.
1. Query DB for active slots in same range.
1. Compare results.

**Expected results**

- busy-slots output equals DB active slots (excluding deleted/inactive classes).

---

### TC 8.4.2 — busy-slots matches calendar (if calendar is source)

**Goal:** If your system uses calendar as source, busy-slots must match calendar; otherwise calendar must match DB.

**Preconditions / Setup**

- Know whether busy-slots source is DB or calendar.

**Steps**

1. Compare busy-slots output vs calendar events for same instructor and date range.

**Expected results**

- If source=calendar: they match exactly.
- If source=DB: calendar should be consistent with DB, and busy-slots matches DB.

---

### TC 8.5.1 — No ghost slots in UI

**Goal:** UI should not show slots that don’t exist in DB (or are deleted).

**Preconditions / Setup**

- Have a class with deleted/soft-deleted slots or historical edits.

**Steps**

1. Open edit form.
1. Verify UI shows only active slots.

**Expected results**

- No ghost slots rendered (deleted slots hidden).

---

### TC 8.5.2 — No ghost slots in DB

**Goal:** After slot removal, DB should not keep active copies (no duplicates).

**Preconditions / Setup**

- DB read access.

**Steps**

1. Remove a slot and save.
1. Query DB for the class slots.

**Expected results**

- Deleted slot is not returned as active; total active count equals expected.

---

### TC 8.5.3 — No ghost slots in calendar

**Goal:** After slot removal, calendar should not keep the removed event.

**Preconditions / Setup**

- Calendar access.

**Steps**

1. Remove a slot and save.
1. Search calendar for that time/date.

**Expected results**

- No event remains for removed slot.

---

### TC 8.5.4 — No ghost slots in busy-slots

**Goal:** busy-slots must not include deleted slots.

**Preconditions / Setup**

- Have a deleted/soft-deleted slot.

**Steps**

1. Query busy-slots for the slot’s date.
1. Verify deleted slot not included.

**Expected results**

- No deleted slots returned.

---

### TC 8.6.1 — No missing slots in UI (all DB slots shown)

**Goal:** Edit UI must display all active DB slots.

**Preconditions / Setup**

- DB has N active slots for the class.

**Steps**

1. Open edit form.
1. Compare UI slot list count and times to DB.

**Expected results**

- All DB slots are visible in UI.

---

### TC 8.6.2 — No missing slots in DB (all UI slots saved)

**Goal:** After save, DB must contain all slots present in payload/UI.

**Preconditions / Setup**

- DB read access.

**Steps**

1. Create/edit a class with N slots; save.
1. Query DB and verify all N slots exist.

**Expected results**

- DB contains all N slots; none dropped.

---

### TC 8.6.3 — No missing slots in calendar (all DB slots synced)

**Goal:** Calendar should reflect all DB slots when sync is healthy.

**Preconditions / Setup**

- Calendar sync enabled and healthy (no injected failures).

**Steps**

1. Create class with N slots and save.
1. Verify calendar has N events.

**Expected results**

- No missing events.

---

### TC 8.6.4 — No missing slots in busy-slots (all active slots included)

**Goal:** busy-slots should include all active, non-deleted slots.

**Preconditions / Setup**

- Have active slots in DB across date range.

**Steps**

1. Query busy-slots for date range.
1. Verify all active DB slots appear.

**Expected results**

- No active slots missing.

---

### TC 8.7.1 — No phantom conflicts from deleted slots

**Goal:** After deleting a slot, availability should not remain blocked by it.

**Preconditions / Setup**

- Have a slot that will be deleted.

**Steps**

1. Delete slot and save.
1. Check availability for that exact time range.

**Expected results**

- Availability shows available=true (assuming no other conflicts).

---

### TC 8.7.2 — No phantom conflicts from own slots (edit mode)

**Goal:** Editing should not show conflict against the class itself.

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-8.7.2",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 1,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Open edit mode and run availability for 09:00–10:00.
1. Verify no conflict shown (self-exclusion).

**Expected results**

- No self-conflict in edit mode.

---

### TC 8.7.3 — No phantom conflicts from stale UI state

**Goal:** Removing a slot in UI (not saved) must still show conflict because DB still has it.

**Preconditions / Setup**

- Create a base class used for this test; capture returned `classId` and the slot IDs/event IDs from the response or DB.
- ```bash
curl -sS -X POST "$BASE_URL/api/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d @- <<'JSON'
{
  "title": "SETUP-8.7.3",
  "classType": "count",
  "timeZone": "Asia/Kolkata",
  "instructorId": "inst_001",
  "classCount": 1,
  "capacity": 10,
  "schedules": [
    {
      "start": "2026-01-05T09:00:00+05:30",
      "end": "2026-01-05T10:00:00+05:30"
    }
  ],
  "_debug": {
    "utcPreview": [
      {
        "startLocal": "2026-01-05T09:00:00+05:30",
        "endLocal": "2026-01-05T10:00:00+05:30",
        "startUtc": "2026-01-05T03:30:00Z",
        "endUtc": "2026-01-05T04:30:00Z"
      }
    ]
  }
}
JSON
```

**Steps**

1. Open edit mode.
1. Remove slot without saving.
1. Run availability for removed time.

**Expected results**

- Conflict shown (correct).
- If UI shows available, it indicates stale exclusion bug (filters based on originalSchedules).

---


## 9. Failure & recovery cases

### TC 9.1.1 — Save fails after DB update but before calendar sync

**Goal:** Verify system behavior when DB commit succeeds but calendar update fails.

**Preconditions / Setup**

- Enable fault injection: make calendar API fail AFTER DB commit (or simulate by blocking outbound calendar calls).

**Steps**

1. Edit a class (change a slot time) and save.
1. Observe UI success/error message.
1. Verify DB updated; calendar unchanged; logs written.
1. Verify retry mechanism (if any).

**Expected results**

- DB reflects new schedule.
- Calendar event not updated.
- System logs calendar failure and provides retry path or a visible 'sync pending' state.
- busy-slots reflects DB state (updated).

---

### TC 9.1.2 — Save fails after calendar sync but before DB update

**Goal:** Verify rollback/compensation when calendar updates but DB fails.

**Preconditions / Setup**

- Enable fault injection: make DB update fail AFTER calendar update (harder; may require test harness).

**Steps**

1. Edit a slot time and save with DB failure injection.
1. Verify API returns error.
1. Check DB and calendar for consistency.

**Expected results**

- Preferred: DB rollback means DB unchanged; calendar should also be rolled back/compensated if implemented.
- If not implemented: document inconsistency risk and ensure there's a reconciliation job or manual fix path.

---

### TC 9.1.3 — Save fails mid-transaction (partial DB update)

**Goal:** DB should be all-or-nothing; no partial slot updates.

**Preconditions / Setup**

- Enable fault injection causing DB transaction to fail after some writes.

**Steps**

1. Attempt a multi-slot update and force transaction failure.
1. Verify DB ends in either old state or fully updated state (not partial).

**Expected results**

- No partial DB state; transaction rolled back.

---

### TC 9.2.1 — Calendar creation fails for one slot

**Goal:** Partial calendar sync failure should be tracked per slot and recoverable.

**Preconditions / Setup**

- Enable fault injection: calendar create fails for slot #1 but succeeds for slot #2.

**Steps**

1. Create class with 2 slots and save.
1. Verify DB has 2 slots.
1. Verify calendar has only 1 event.
1. Verify failed slot has eventId=null and error is logged.

**Expected results**

- DB has both slots.
- Calendar has only the successful event.
- Retry can create missing event without duplicating existing one.

---

### TC 9.2.2 — Calendar creation fails for all slots

**Goal:** When calendar is down, DB should still store slots and system should surface sync failure.

**Preconditions / Setup**

- Disable/revoke calendar integration or simulate calendar API outage.

**Steps**

1. Create class with N slots and save.
1. Verify DB has N slots and all eventIds are null.
1. Verify UI shows `Calendar sync failed` (or logs).

**Expected results**

- DB stores slots.
- Calendar has no new events.
- System indicates sync failure and offers retry.

---

### TC 9.2.3 — Calendar creation fails, retry succeeds

**Goal:** Retry should create missing events and attach eventIds in DB without duplicates.

**Preconditions / Setup**

- Start from 9.2.2: DB has slots but calendar creation failed; then restore calendar connectivity.

**Steps**

1. Trigger retry mechanism (button/job).
1. Verify calendar events created.
1. Verify DB slots updated with eventIds.

**Expected results**

- All missing events created on retry.
- No duplicates for slots that already had events.

---

### TC 9.3.1 — Retry after partial failure

**Goal:** Retry should target only failed operations.

**Preconditions / Setup**

- Have a state where some slot calendar syncs failed and some succeeded.

**Steps**

1. Trigger retry.
1. Observe which operations re-run.
1. Verify no duplication.

**Expected results**

- Only failed slots are retried; successful ones are not duplicated.

---

### TC 9.3.2 — Retry after complete failure

**Goal:** Retry should reattempt all operations and still avoid duplicates.

**Preconditions / Setup**

- Have a state where all operations failed due to outage; then restore service.

**Steps**

1. Trigger retry.
1. Verify all missing events are created.

**Expected results**

- All operations retried; no duplicates after multiple retries.

---

### TC 9.4.1 — Rollback on DB failure

**Goal:** If DB fails, system should rollback and leave DB/calendar unchanged.

**Preconditions / Setup**

- Inject DB failure on save (before commit).

**Steps**

1. Attempt save.
1. Verify error response.
1. Verify DB unchanged and calendar unchanged.

**Expected results**

- DB unchanged; calendar unchanged; UI shows previous state or reloads.

---

### TC 9.4.2 — Rollback on calendar failure (if implemented)

**Goal:** If calendar fails and you implement rollback, verify DB rollback occurs too.

**Preconditions / Setup**

- Inject calendar failure.

**Steps**

1. Attempt save.
1. Verify error response.
1. Verify DB rolled back (unchanged) and calendar unchanged.

**Expected results**

- Either full rollback (if implemented) OR DB updated with sync-pending state (if not). Document expected behavior.

---

### TC 9.5.1 — Edit class after previous save failure

**Goal:** Previous failures should not block future edits; state shown should be correct (DB state).

**Preconditions / Setup**

- Cause a save failure (DB or calendar) on a class.

**Steps**

1. Re-open edit form.
1. Verify loaded state matches DB.
1. Make a new edit and save (without fault injection).

**Expected results**

- New save succeeds and brings system to consistent state.

---

### TC 9.5.2 — Edit class with partial calendar sync failure (missing event_id)

**Goal:** Subsequent edits should attempt to heal missing calendar events.

**Preconditions / Setup**

- A class with some slots missing eventId from prior calendar failure.

**Steps**

1. Open edit form; identify slots missing eventId.
1. Make an edit and save (with calendar restored).

**Expected results**

- Backend attempts calendar creation for missing eventIds; success fills eventIds; failures logged.

---

### TC 9.6.1 — busy-slots after DB save failure

**Goal:** If save fails, busy-slots must reflect old DB state (no changes).

**Preconditions / Setup**

- Inject DB failure so save is rejected and no DB write occurs.

**Steps**

1. Attempt to edit slot and save (expect failure).
1. Query busy-slots for the affected range.

**Expected results**

- busy-slots shows previous state (unchanged).

---

### TC 9.6.2 — busy-slots after calendar sync failure

**Goal:** If DB updated but calendar failed, busy-slots must reflect DB updated state.

**Preconditions / Setup**

- Inject calendar failure while allowing DB commit.

**Steps**

1. Edit slot and save (calendar fails).
1. Query busy-slots.

**Expected results**

- busy-slots shows updated slot times (DB source of truth) even if calendar is inconsistent.

---


## Final checklist summary

_If all below pass, count-based scheduling is logically sound._

### Create flow

- [ ] Can create class with classCount = 1, 2, 3, many
- [ ] Cannot create with slots > classCount
- [ ] Cannot create with slots < classCount
- [ ] Can create with slots on same day (different times)
- [ ] Can create with slots on different days
- [ ] Cannot create with overlapping slots within same class
- [ ] Payload matches UI exactly
- [ ] DB stores exactly classCount slots
- [ ] Calendar shows exactly classCount events
- [ ] Calendar events match DB slots (dates/times)

### Edit flow

- [ ] Can edit without changing slots
- [ ] Can edit slot time (same date)
- [ ] Can edit slot date (same time)
- [ ] Can edit slot date and time
- [ ] Cannot remove slot if it would make slots < classCount
- [ ] Cannot add slot if it would make slots > classCount
- [ ] Can reduce classCount after removing slots
- [ ] Can increase classCount after adding slots
- [ ] Past slots handled consistently (editable or not)
- [ ] Calendar events updated (not duplicated) when slot edited
- [ ] Self-conflict exclusion works (own slots not flagged)
- [ ] Removed slots (not saved) show as conflicts (correct)
- [ ] Removed slots (saved) don't show in busy-slots

### Update scenarios

- [ ] Can change classCount after creation
- [ ] Can change classType (count ↔ continuous)
- [ ] Partial updates work (schedule only, non-schedule only)
- [ ] Updates work with enrolled students
- [ ] Updates work after notifications sent
- [ ] Calendar sync failure handled gracefully
- [ ] Re-saving without changes works

### Delete / remove

- [ ] Cannot remove slot if slots would be < classCount
- [ ] Cannot remove last slot
- [ ] Can remove slot from middle of sequence (if classCount adjusted)
- [ ] Removed slot deleted from calendar
- [ ] Removed slot deleted from DB
- [ ] Removed slot doesn't appear in busy-slots
- [ ] Removed slot doesn't block availability

### Availability & busy-slots

- [ ] busy-slots uses DB as source of truth (not UI)
- [ ] busy-slots excludes own slots in edit mode (self-exclusion)
- [ ] busy-slots includes removed slots (not saved yet) - shows conflict correctly
- [ ] busy-slots excludes removed slots (saved) - correctly deleted
- [ ] busy-slots includes slots from other classes (real conflicts)
- [ ] busy-slots handles timezone correctly (UTC ↔ local)
- [ ] busy-slots filters by date range correctly
- [ ] busy-slots excludes soft-deleted slots
- [ ] busy-slots excludes inactive classes
- [ ] busy-slots excludes deleted classes

### Timezone

- [ ] Slots stored as UTC, displayed as local date
- [ ] Querying by local date finds UTC-stored slots
- [ ] Same UTC time shows different local dates in different timezones
- [ ] Slots near midnight handled correctly
- [ ] Date consistency maintained (stored vs displayed)

### Self-conflict exclusion

- [ ] Self-exclusion uses current UI state (not stale originalSchedules)
- [ ] Self-exclusion works for slots in current UI
- [ ] Self-exclusion does NOT work for removed slots (they should show as conflicts)
- [ ] Exclusion by time overlap works correctly
- [ ] No phantom conflicts from own slots

### Sync consistency

- [ ] UI state = API payload (1:1)
- [ ] API payload = DB record (1:1)
- [ ] DB record = Calendar events (1:1)
- [ ] busy-slots = DB (for active classes)
- [ ] No ghost slots in UI, DB, calendar, or busy-slots
- [ ] No missing slots in UI, DB, calendar, or busy-slots
- [ ] No phantom conflicts

### Failure & recovery

- [ ] Partial save failures handled (DB vs calendar)
- [ ] Calendar creation failures handled
- [ ] Retry mechanism works
- [ ] Rollback works on failure
- [ ] Editing after failure works
- [ ] busy-slots shows correct state after failure
