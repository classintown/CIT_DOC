# CIT Daily Ops — Google Workspace Setup Guide

**Goal:** Keep the 6-person ClassInTown team aligned with a 60-second daily form, one master sheet, and a 15-minute blocker-only sync — no extra admin overhead.

**Cadence (IST):**
| Time | Action |
| --- | --- |
| 4:30 PM Mon–Fri | Automated email with form link |
| 5:00 PM | Form submission deadline |
| 5:15–5:30 PM | 15-min sync: red blockers + cross-team dependencies only |

---

## Team roster (source of truth)

| Name | Email | Role |
| --- | --- | --- |
| Ankit N | ankit@classintown.com | Business Owner |
| Aniruddha Mane | aniruddha@classintown.com | Sales Lead |
| Shashank D | shashank@classintown.com | Product Owner |
| Swapnil M | swapnil@classintown.com | Tech Lead |
| Kunal K | kunal@classintown.com | Mobile Developer |
| Vijay G | vijay.g@classintown.com | QA Lead |

**Feature buckets (form dropdown):** Payments · AI · Mobile App · Web Core · Sales Requests · QA/Infra

---

## Part A — One-click setup (Apps Script)

### Step 1 — Create the Apps Script project

1. Open [script.google.com](https://script.google.com) while signed into a ClassInTown Google account (preferably Ankit or Shashank as workspace owner).
2. Click **New project**.
3. Rename the project to `CIT Daily Ops Automation`.
4. Delete any placeholder code in `Code.gs`.
5. Paste **all** of the script from [Part C](#part-c--complete-google-apps-script) below.
6. Click **Save** (disk icon).

### Step 2 — Set script timezone to IST (required for 4:30 PM)

1. In the Apps Script editor: **Project Settings** (gear icon).
2. Under **Time zone**, select **(GMT+05:30) India Standard Time**.
3. Save.

> Triggers use the script’s timezone. If this stays on US time, reminders will fire at the wrong hour.

### Step 3 — Run the installer once

1. In the function dropdown, select `setupCITCompleteWorkspace`.
2. Click **Run**.
3. On first run, click **Review permissions** → choose your Google account → **Advanced** → **Go to CIT Daily Ops Automation (unsafe)** → **Allow**.
   - Scopes needed: Spreadsheets, Forms, Gmail/Mail, Script triggers, Script properties.
4. Open **Executions** (clock icon) or **View → Logs** and confirm you see:
   - Master Sheet URL
   - Daily Form URL
   - Trigger count = 5 (Mon–Fri)

### Step 4 — Share artifacts with the team

1. Open the **Master Sheet URL** from the log.
2. Click **Share** → add all six team emails with **Editor** (or Viewer for Ankit if preferred; Editors for Shashank/Swapnil/Vijay).
3. Open the **Form URL** → **Send** / copy link → pin in Google Chat (e.g. `#cit-standup`).
4. Optional: bookmark the sheet tab **Daily Updates** for the 5:15 PM sync.

### Step 5 — Verify automation (same day)

1. In Apps Script, select `sendDailyStandupEmail` → **Run**.
2. Confirm all six inboxes receive `[CIT Standup] Please submit your daily update`.
3. Submit one test form response as yourself.
4. Confirm a new row appears on **Daily Updates**.
5. Submit a second test with **Blocker = Yes** → that row’s Blocker cell should turn **red**.

### Step 6 — Meeting habit (no extra tooling)

Use the sheet tab **Meeting Agenda** every day at 5:15 PM. Rules are printed on that tab. Do not turn the sync into status theater.

---

## Part B — Daily 15-minute sync agenda (strict)

**Facilitator:** Shashank (PO) or Swapnil (Tech Lead).  
**Timer:** 15 minutes hard stop.  
**Screen share:** Master Sheet → **Daily Updates** filtered/sorted by Blocker = Yes.

| Minute | Focus | Rule |
| --- | --- | --- |
| 0–1 | Scan red rows only | Ignore green / “No” rows |
| 1–10 | Resolve or assign each blocker | Name owner + next action + ETA (same day / tomorrow) |
| 10–14 | Cross-team dependencies | e.g. Kunal ↔ Swapnil APIs; Vijay ↔ Shashank specs; Aniruddha ↔ Shashank scope |
| 14–15 | Confirm tomorrow’s critical path | One sentence each if needed — no full status dumps |

**Out of scope for this meeting:** demos, long design debates, backlog grooming, revenue deep-dives (those belong in weekly product/business sync).

**Escalation:** If a blocker needs Ankit sign-off (scope/revenue), Shashank notes it on **Product Roadmap** and Slack/emails Ankit outside the standup.

---

## Part C — Complete Google Apps Script

Copy everything below into `Code.gs`.

```javascript
/**
 * CIT Daily Ops — one-click workspace installer
 * Creates: Master Sheet (Roadmap + Daily Updates + Meeting Agenda + Team)
 *          Daily Standup Form (linked)
 *          Mon–Fri 4:30 PM IST email reminders
 *
 * BEFORE FIRST RUN: Project Settings → Time zone = (GMT+05:30) India Standard Time
 */

var CIT_CONFIG = {
  SHEET_NAME: 'CIT Master Workspace Tracker',
  FORM_TITLE: 'CIT Daily Standup Update',
  TEAM: [
    { name: 'Ankit N', email: 'ankit@classintown.com', role: 'Business Owner' },
    { name: 'Aniruddha Mane', email: 'aniruddha@classintown.com', role: 'Sales Lead' },
    { name: 'Shashank D', email: 'shashank@classintown.com', role: 'Product Owner' },
    { name: 'Swapnil M', email: 'swapnil@classintown.com', role: 'Tech Lead' },
    { name: 'Kunal K', email: 'kunal@classintown.com', role: 'Mobile Developer' },
    { name: 'Vijay G', email: 'vijay.g@classintown.com', role: 'QA Lead' }
  ],
  FEATURES: [
    'Payments',
    'AI',
    'Mobile App',
    'Web Core',
    'Sales Requests',
    'QA/Infra'
  ]
};

/**
 * Run once to build the full infrastructure.
 */
function setupCITCompleteWorkspace() {
  var team = CIT_CONFIG.TEAM;
  var features = CIT_CONFIG.FEATURES;
  var emailsCsv = team.map(function (m) { return m.email; }).join(',');

  // --- Spreadsheet ---
  var ss = SpreadsheetApp.create(CIT_CONFIG.SHEET_NAME);
  ss.setSpreadsheetTimeZone('Asia/Kolkata');

  var roadmap = ss.getActiveSheet();
  roadmap.setName('Product Roadmap');
  _buildRoadmapSheet(roadmap);

  var teamSheet = ss.insertSheet('Team Roster');
  _buildTeamSheet(teamSheet, team);

  var agenda = ss.insertSheet('Meeting Agenda');
  _buildMeetingAgendaSheet(agenda);

  // --- Form ---
  var form = FormApp.create(CIT_CONFIG.FORM_TITLE);
  form.setDescription(
    '60-second daily check-in. Submit by 5:00 PM IST. ' +
    'Use Blocker=Yes only when someone else must unblock you before you can proceed.'
  );
  form.setCollectEmail(true);
  form.setLimitOneResponsePerUser(false);
  form.setAllowResponseEdits(true);
  form.setProgressBar(false);
  form.setConfirmationMessage(
    'Thanks — your update is logged. Red blockers will be reviewed in the 5:15 PM sync.'
  );

  form.addListItem()
    .setTitle('Member Name')
    .setChoiceValues(team.map(function (m) { return m.name; }))
    .setRequired(true);

  form.addListItem()
    .setTitle('Primary High-Level Feature')
    .setChoiceValues(features)
    .setRequired(true);

  form.addParagraphTextItem()
    .setTitle('Sub-tasks completed today & time spent')
    .setHelpText('Example: Wired Razorpay webhook handler — 2.5h; Fixed mobile deeplink test — 1h')
    .setRequired(true);

  form.addParagraphTextItem()
    .setTitle('Planned sub-tasks for tomorrow & estimated hours')
    .setHelpText('Example: Finish payment verify API — 3h; Pair with Kunal on mobile contract — 1h')
    .setRequired(true);

  var blockerItem = form.addMultipleChoiceItem()
    .setTitle('Blocker Flag')
    .setRequired(true);
  blockerItem.setChoices([
    blockerItem.createChoice('No'),
    blockerItem.createChoice('Yes')
  ]);

  form.addParagraphTextItem()
    .setTitle('Blocker details & owner required to resolve')
    .setHelpText('Required if Blocker=Yes. Example: Waiting on Swapnil for payment verify endpoint contract')
    .setRequired(false);

  form.addListItem()
    .setTitle('Owner required to resolve (if blocked)')
    .setChoiceValues(
      ['— None —'].concat(team.map(function (m) { return m.name; }))
    )
    .setRequired(false);

  // Link form responses into this spreadsheet
  form.setDestination(FormApp.DestinationType.SPREADSHEET, ss.getId());

  // Rename + format the auto-created responses sheet
  SpreadsheetApp.flush();
  Utilities.sleep(1500);
  var daily = _findFormResponseSheet(ss);
  daily.setName('Daily Updates');
  _formatDailyUpdatesSheet(daily);
  _applyBlockerConditionalFormatting(daily);

  // Move Daily Updates to second position (after Roadmap)
  ss.setActiveSheet(daily);
  ss.moveActiveSheet(2);

  // Persist for email job
  var props = PropertiesService.getScriptProperties();
  props.setProperty('FORM_URL', form.getPublishedUrl());
  props.setProperty('FORM_EDIT_URL', form.getEditUrl());
  props.setProperty('SHEET_URL', ss.getUrl());
  props.setProperty('SHEET_ID', ss.getId());
  props.setProperty('TEAM_EMAILS', emailsCsv);

  _installWeekdayEmailTriggers();

  Logger.log('========== CIT SETUP COMPLETE ==========');
  Logger.log('Master Sheet URL: ' + ss.getUrl());
  Logger.log('Daily Form URL:   ' + form.getPublishedUrl());
  Logger.log('Form Edit URL:    ' + form.getEditUrl());
  Logger.log('Triggers (Mon–Fri ~4:30 PM IST): ' + ScriptApp.getProjectTriggers().length);
  Logger.log('Next: Share Sheet + Form with the team, then Run sendDailyStandupEmail once to test.');
}

/**
 * Mon–Fri reminder — invoked by time-based triggers.
 */
function sendDailyStandupEmail() {
  var props = PropertiesService.getScriptProperties();
  var formUrl = props.getProperty('FORM_URL');
  var emails = props.getProperty('TEAM_EMAILS');
  var sheetUrl = props.getProperty('SHEET_URL') || '';

  if (!formUrl || !emails) {
    Logger.log('Missing FORM_URL or TEAM_EMAILS — run setupCITCompleteWorkspace first.');
    return;
  }

  var subject = '[CIT Standup] Please submit your daily update (by 5:00 PM IST)';
  var body =
    'Hi team,\n\n' +
    'Take ~60 seconds to submit today’s standup before 5:00 PM IST.\n' +
    'Flag Blocker=Yes only if you are blocked on another person.\n\n' +
    'Form: ' + formUrl + '\n' +
    (sheetUrl ? 'Tracker: ' + sheetUrl + '\n' : '') +
    '\nSync at 5:15 PM IST = red blockers + cross-team dependencies only.\n\n' +
    '— ClassInTown Ops';

  MailApp.sendEmail({
    to: emails,
    subject: subject,
    body: body
  });
}

/**
 * Optional: clear and reinstall Mon–Fri triggers (safe to re-run).
 */
function reinstallEmailTriggers() {
  _installWeekdayEmailTriggers();
  Logger.log('Reinstalled ' + ScriptApp.getProjectTriggers().length + ' weekday triggers.');
}

/**
 * Optional: print stored URLs / emails to the log.
 */
function logCITConfig() {
  var props = PropertiesService.getScriptProperties().getProperties();
  Object.keys(props).forEach(function (k) {
    Logger.log(k + ' = ' + props[k]);
  });
}

// ---------------------------------------------------------------------------
// Internals
// ---------------------------------------------------------------------------

function _buildRoadmapSheet(sheet) {
  var headers = [
    'Module / Feature',
    'Owner',
    'Sub-Features / Tasks',
    'Status',
    'Target Date',
    'Depends On',
    'Blocker Details'
  ];
  sheet.getRange(1, 1, 1, headers.length).setValues([headers]);
  sheet.getRange(1, 1, 1, headers.length)
    .setFontWeight('bold')
    .setBackground('#1a73e8')
    .setFontColor('#ffffff');

  var seed = [
    ['Payments', 'Swapnil M', 'Gateway webhooks, verify, deeplinks', 'In Progress', '2026-09-10', '—', ''],
    ['AI', 'Swapnil M', 'Prompt pipeline & API surface', 'Not Started', '2026-09-20', 'Web Core', ''],
    ['Mobile App', 'Kunal K', 'Consume payment + auth APIs', 'Blocked', '2026-09-12', 'Swapnil M', 'Waiting on payment verify API contract'],
    ['Web Core', 'Shashank D', 'Specs + web product scope', 'In Progress', '2026-09-08', 'Ankit N', ''],
    ['Sales Requests', 'Aniruddha Mane', 'Client feature intake & commercial dates', 'Ongoing', '', 'Shashank D', ''],
    ['QA/Infra', 'Vijay G', 'Regression + release sign-off', 'Pending', '2026-09-15', 'Shashank D / Swapnil M', '']
  ];
  sheet.getRange(2, 1, seed.length + 1, headers.length).setValues(seed);
  sheet.setFrozenRows(1);
  sheet.autoResizeColumns(1, headers.length);

  // Status column quick formatting
  var statusRange = sheet.getRange('D2:D100');
  var rules = sheet.getConditionalFormatRules();
  rules.push(
    SpreadsheetApp.newConditionalFormatRule()
      .whenTextEqualTo('Blocked')
      .setBackground('#f4cccc')
      .setRanges([statusRange])
      .build()
  );
  rules.push(
    SpreadsheetApp.newConditionalFormatRule()
      .whenTextEqualTo('Completed')
      .setBackground('#d9ead3')
      .setRanges([statusRange])
      .build()
  );
  sheet.setConditionalFormatRules(rules);
}

function _buildTeamSheet(sheet, team) {
  sheet.getRange(1, 1, 1, 3).setValues([['Name', 'Email', 'Role']]);
  sheet.getRange(1, 1, 1, 3).setFontWeight('bold').setBackground('#34a853').setFontColor('#ffffff');
  var rows = team.map(function (m) { return [m.name, m.email, m.role]; });
  sheet.getRange(2, 1, rows.length + 1, 3).setValues(rows);
  sheet.autoResizeColumns(1, 3);
  sheet.setFrozenRows(1);
}

function _buildMeetingAgendaSheet(sheet) {
  var lines = [
    ['CIT Daily Sync — 15 minutes (5:15–5:30 PM IST)'],
    [''],
    ['RULES'],
    ['1. Open Daily Updates. Discuss ONLY rows where Blocker Flag = Yes (red).'],
    ['2. No full status round-robin. Completed work stays on the form / sheet.'],
    ['3. Every blocker ends with: Owner + Next action + ETA.'],
    ['4. Capture cross-team waits: Mobile↔Backend, QA↔Product Specs, Sales↔Product Scope.'],
    ['5. Hard stop at 15 minutes. Park design/revenue topics to weekly sync.'],
    [''],
    ['FACILITATOR CHECKLIST'],
    ['[ ] Filter / sort Daily Updates by Blocker = Yes'],
    ['[ ] Walk each red row — confirm resolver is in the room or assigned'],
    ['[ ] Update Product Roadmap Blocker Details / Status if needed'],
    ['[ ] Confirm tomorrow critical path in one sentence (optional)'],
    [''],
    ['COMMON DEPENDENCY PATTERNS'],
    ['Kunal (Mobile) waiting on Swapnil (APIs / payments)'],
    ['Vijay (QA) waiting on Shashank (specs) or Swapnil (builds)'],
    ['Aniruddha (Sales) waiting on Shashank (scope) / Ankit (commercial sign-off)'],
    ['Swapnil waiting on Shashank (acceptance criteria) or Ankit (priority)']
  ];
  sheet.getRange(1, 1, lines.length, 1).setValues(lines);
  sheet.getRange('A1').setFontWeight('bold').setFontSize(14);
  sheet.getRange('A3').setFontWeight('bold');
  sheet.getRange('A10').setFontWeight('bold');
  sheet.getRange('A16').setFontWeight('bold');
  sheet.setColumnWidth(1, 720);
}

function _findFormResponseSheet(ss) {
  var sheets = ss.getSheets();
  for (var i = 0; i < sheets.length; i++) {
    var name = sheets[i].getName();
    if (name.indexOf('Form Responses') === 0) {
      return sheets[i];
    }
  }
  // Fallback: create empty Daily Updates if Google is slow to attach
  var fallback = ss.insertSheet('Daily Updates');
  fallback.appendRow([
    'Timestamp',
    'Email Address',
    'Member Name',
    'Primary High-Level Feature',
    'Sub-tasks completed today & time spent',
    'Planned sub-tasks for tomorrow & estimated hours',
    'Blocker Flag',
    'Blocker details & owner required to resolve',
    'Owner required to resolve (if blocked)'
  ]);
  return fallback;
}

function _formatDailyUpdatesSheet(sheet) {
  var lastCol = Math.max(sheet.getLastColumn(), 9);
  var header = sheet.getRange(1, 1, 1, lastCol);
  header.setFontWeight('bold').setBackground('#9334e6').setFontColor('#ffffff');
  sheet.setFrozenRows(1);
  sheet.setFrozenColumns(1);
  try {
    sheet.autoResizeColumns(1, lastCol);
  } catch (e) {
    // ignore resize edge cases on brand-new response sheets
  }
}

function _applyBlockerConditionalFormatting(sheet) {
  // Form columns are typically:
  // A Timestamp | B Email | C Member Name | D Feature | E Done | F Tomorrow | G Blocker Flag | ...
  // Locate "Blocker Flag" header dynamically.
  var headerRow = sheet.getRange(1, 1, 1, sheet.getLastColumn()).getValues()[0];
  var blockerCol = -1;
  for (var c = 0; c < headerRow.length; c++) {
    if (String(headerRow[c]).indexOf('Blocker Flag') !== -1) {
      blockerCol = c + 1;
      break;
    }
  }
  if (blockerCol < 0) {
    blockerCol = 7; // safe default for our form shape
  }

  var colLetter = _columnToLetter(blockerCol);
  var range = sheet.getRange(colLetter + '2:' + colLetter + '2000');

  var rules = sheet.getConditionalFormatRules();
  rules.push(
    SpreadsheetApp.newConditionalFormatRule()
      .whenTextEqualTo('Yes')
      .setBackground('#ff0000')
      .setFontColor('#ffffff')
      .setBold(true)
      .setRanges([range])
      .build()
  );
  rules.push(
    SpreadsheetApp.newConditionalFormatRule()
      .whenTextEqualTo('No')
      .setBackground('#d9ead3')
      .setRanges([range])
      .build()
  );
  sheet.setConditionalFormatRules(rules);

  // Filter view hint: enable filter on header for quick "Yes" filter in meetings
  if (sheet.getFilter()) {
    sheet.getFilter().remove();
  }
  var lastCol = Math.max(sheet.getLastColumn(), blockerCol);
  sheet.getRange(1, 1, 1, lastCol).createFilter();
}

function _installWeekdayEmailTriggers() {
  var existing = ScriptApp.getProjectTriggers();
  for (var i = 0; i < existing.length; i++) {
    if (existing[i].getHandlerFunction() === 'sendDailyStandupEmail') {
      ScriptApp.deleteTrigger(existing[i]);
    }
  }

  var days = [
    ScriptApp.WeekDay.MONDAY,
    ScriptApp.WeekDay.TUESDAY,
    ScriptApp.WeekDay.WEDNESDAY,
    ScriptApp.WeekDay.THURSDAY,
    ScriptApp.WeekDay.FRIDAY
  ];

  days.forEach(function (day) {
    ScriptApp.newTrigger('sendDailyStandupEmail')
      .timeBased()
      .onWeekDay(day)
      .atHour(16)      // 4 PM hour bucket
      .nearMinute(30)  // ~4:30 PM in script timezone
      .inTimezone('Asia/Kolkata')
      .create();
  });
}

function _columnToLetter(column) {
  var temp = '';
  var col = column;
  while (col > 0) {
    var rem = (col - 1) % 26;
    temp = String.fromCharCode(65 + rem) + temp;
    col = Math.floor((col - 1) / 26);
  }
  return temp;
}
```

---

## Part D — Sheet views (what you get)

### 1. Product Roadmap
Parent features → owner → sub-tasks → status → target date → depends on → blocker details.  
Seeded with CIT’s current verticals (Payments, AI, Mobile, Web Core, Sales, QA). Update live during sprints.

### 2. Daily Updates
Live form responses. **Blocker Flag = Yes** cells are bright red; **No** is green. Use the header filter in the 5:15 sync.

### 3. Meeting Agenda
Printed rules so the sync stays on blockers and dependencies.

### 4. Team Roster
Name / email / role reference for the Apps Script and onboarding.

---

## Part E — Operating tips (keep overhead low)

1. **One form only** — do not add Slack status rituals on top of this.
2. **Blocker discipline** — “Yes” means *another human must act*; personal overload is not a blocker.
3. **Roadmap weekly, standup daily** — Shashank updates Roadmap dates once a week; Daily Updates stay mechanical.
4. **Re-run safely** — `setupCITCompleteWorkspace` creates a *new* Sheet + Form each time. Prefer `reinstallEmailTriggers` / `logCITConfig` after the first install.
5. **Quota** — Gmail sending from Apps Script is fine for 6 recipients × 5 days; if you later expand the team, switch to a Google Group address as `to:`.

---

## Part F — Troubleshooting

| Symptom | Fix |
| --- | --- |
| Emails at wrong time | Project Settings → timezone = Asia/Kolkata; run `reinstallEmailTriggers` |
| No red highlighting | Confirm header contains `Blocker Flag`; re-run setup or manually Format → Conditional formatting → Text is exactly `Yes` → red fill |
| Form responses on wrong tab | Responses always land on the destination spreadsheet; rename tab to `Daily Updates` if needed |
| Permission errors on MailApp | Re-run and accept Gmail/Mail scope; account must be allowed to send mail |
| Duplicate reminder emails | Triggers duplicated — run `reinstallEmailTriggers` (deletes old `sendDailyStandupEmail` triggers first) |
| Want to change team list | Edit `CIT_CONFIG.TEAM` / form choices manually, or re-run setup and retire the old Form/Sheet |

---

## Quick checklist (owner: Shashank or Ankit)

- [ ] Apps Script project created; timezone IST
- [ ] `setupCITCompleteWorkspace` ran successfully
- [ ] Sheet + Form shared with all 6 emails
- [ ] Test email via `sendDailyStandupEmail`
- [ ] Test Yes-blocker row shows red on Daily Updates
- [ ] Form link pinned in team chat
- [ ] Team agrees: 5:15 PM = blockers only, 15 minutes
