# CometChat Integration — End-to-End Guide

> For **Web developers** (Angular) and **Mobile developers** (React Native / Expo).  
> Read this to understand how chat works, which APIs are called, and how both platforms stay in sync.

---

## 1. Big Picture — How Everything Connects

```mermaid
graph TD
    subgraph YOUR_BACKEND ["Our Backend (Node / Express)"]
        B1["POST /api/cometchat/auth-token"]
        B2["POST /api/cometchat/sync-user"]
        B3["POST /api/cometchat/ensure-class-group"]
        B4["POST /api/cometchat/create-group"]
        B5["POST /api/cometchat/groups/:guid/members"]
        B6["GET  /api/cometchat/config"]
        B7["POST /api/cometchat/webhook"]
    end

    subgraph CC ["CometChat Cloud (region: in)"]
        CC1["CometChat REST API v3"]
        CC2["CometChat Realtime WebSocket"]
        CC3["FCM / APNs Push Gateway"]
    end

    subgraph WEB ["Web App (Angular)"]
        W1["APP_INITIALIZER\n(on page load)"]
        W2["CometChatService\n(singleton)"]
        W3["Chat UI Components\n(conversations · chat · unread badge)"]
    end

    subgraph MOBILE ["Mobile App (React Native / Expo)"]
        M1["CometChatProvider\n(app root)"]
        M2["cometchat.service.ts\n(singleton functions)"]
        M3["ConversationsScreen\nChatMessageScreen"]
        M4["NotificationsProvider\n(push handler)"]
    end

    W1 -->|"1. JWT → fetch authToken"| B1
    M1 -->|"1. JWT → fetch authToken"| B1
    B1 -->|"2. createUser if new\ngenerate short-lived token"| CC1
    B1 -->|"3. return { authToken, uid, appId, region }"| W1
    B1 -->|"3. return { authToken, uid, appId, region }"| M1

    W2 <-->|"SDK login + realtime socket"| CC2
    M2 <-->|"SDK login + realtime socket"| CC2

    W3 --> W2
    M3 --> M2

    CC2 -->|"push to offline device"| CC3
    CC3 -->|"FCM / APNs banner"| M4

    B3 & B4 & B5 -->|"REST calls"| CC1
    B7 <-->|"HMAC-verified events"| CC1
```

---

## 2. Auth Flow — Step by Step

> This runs **once per user session** on both platforms.

```mermaid
sequenceDiagram
    participant App as App (Web or Mobile)
    participant OurAPI as Our Backend
    participant CCAPI as CometChat REST API
    participant CCSDK as CometChat SDK (in-app)

    App->>OurAPI: POST /api/cometchat/auth-token\n(JWT in Authorization header)
    OurAPI->>OurAPI: Verify JWT → get userId, name, avatar
    OurAPI->>CCAPI: GET /users/{uid}/auth_tokens
    alt User does NOT exist in CometChat yet
        OurAPI->>CCAPI: POST /users  (create with uid, name, avatar)
        OurAPI->>CCAPI: GET /users/{uid}/auth_tokens  (retry)
    end
    CCAPI-->>OurAPI: { authToken }
    OurAPI-->>App: { authToken, uid, appId, region }

    App->>CCSDK: CometChat.init(appId, region)
    App->>CCSDK: CometChat.login(authToken)
    CCSDK-->>App: User object (logged in ✅)
    App->>CCSDK: addMessageListener() + addUserListener()
    Note over App,CCSDK: Realtime WebSocket is now open
```

---

## 3. Sending a Message

```mermaid
sequenceDiagram
    participant Sender as Sender (Web or Mobile)
    participant CCSDK as CometChat SDK
    participant CC as CometChat Cloud
    participant Receiver as Receiver (any platform)

    Sender->>CCSDK: sendTextMessage(receiverId, type, text)
    CCSDK->>CC: WebSocket / REST — deliver message
    CC-->>Sender: Message object (sentAt timestamp)
    CC-->>Receiver: onTextMessageReceived() fires in MessageListener
    Receiver->>Receiver: Append message to UI\nIncrement unread badge
```

---

## 4. Receiving Messages — Realtime vs Push

This is the most important part to understand.

```mermaid
flowchart TD
    MSG["New message arrives at CometChat Cloud"]

    MSG --> OPEN{"Is receiver's\napp open & connected?"}

    OPEN -->|Yes — WebSocket is alive| RT["onTextMessageReceived()\nfires instantly in-app\n\nWeb: incomingMessage$ Observable\nMobile: messageListeners Set"]
    RT --> UI["UI updates immediately\nUnread badge ticks up"]

    OPEN -->|No — app is backgrounded or killed| PUSH["CometChat sends\nFCM (Android) / APNs (iOS) push"]
    PUSH --> BANNER["OS shows notification banner\nwith sender name + message preview"]
    BANNER --> TAP{"User taps\nthe banner?"}
    TAP -->|Yes| NAV["registerCometChatPushHandler()\nparsed payload → router.push /chat/messages"]
    TAP -->|No| INBOX["Notification sits in tray\nUnread count refreshed on next app open"]
```

### When do you get a notification?

| Situation | What happens |
|-----------|-------------|
| App is open (foreground) | Message arrives via WebSocket — **no push banner** (you're already in the app) |
| App is in background | CometChat sends a push via FCM/APNs — **banner appears** |
| App is closed / killed | CometChat sends a push via FCM/APNs — **banner appears** |
| User is on web, mobile is off | Mobile gets push; web gets realtime if tab is open |
| Both platforms open | Both receive the WebSocket message simultaneously |

> **Note:** Push only works for mobile. The web app uses the always-on WebSocket — there is no web push notification currently.

---

## 5. Web vs Mobile — Side by Side

```mermaid
graph LR
    subgraph WEB ["Web (Angular)"]
        direction TB
        WA["app.module.ts\nAPP_INITIALIZER\n→ CometChatService.loginUser()"]
        WB["CometChatService\n(Injectable singleton)\n\n• init()\n• loginUser()\n• logoutUser()\n• syncProfile()\n• sendTextMessage()\n• sendMediaMessage()\n• getMessages()\n• getConversations()\n• getGroups()\n• markAsRead()\n• searchUsers()\n• ensureClassGroup()\n• createGroupViaBackend()\n• addMembersToGroupViaBackend()"]
        WC["Observables exposed:\n\n• currentUser$\n• totalUnread$\n• onMessage$\n• onConversationUpdated$\n• onLoginSuccess$\n• onUserPresence$\n• connectionState$"]
        WD["UI Components:\n\n• <app-cometchat-page>\n• <app-cometchat-conversations>\n• <app-cometchat-chat>"]
        WA --> WB --> WC --> WD
    end

    subgraph MOBILE ["Mobile (React Native)"]
        direction TB
        MA["_layout.tsx root\n→ <CometChatProvider>"]
        MB["CometChatProvider.tsx\nuseEffect watches auth state\n→ loginCometChat() on sign-in\n→ logoutCometChat() on sign-out"]
        MC["cometchat.service.ts\n(exported functions)\n\n• initCometChat()\n• loginCometChat()\n• logoutCometChat()\n• sendTextMessage()\n• sendMediaMessage()\n• getMessages()\n• getConversations()\n• markAsRead()\n• onMessageReceived()\n• onUnreadCountChanged()\n• refreshUnreadCount()"]
        MD["Screens:\n\n• ConversationsScreen\n• ChatMessageScreen\n\nPush:\n• cometchat-push.ts\n  registerCometChatPushHandler()"]
        MA --> MB --> MC --> MD
    end
```

### Key Differences

| | Web (Angular) | Mobile (React Native) |
|---|---|---|
| Login trigger | `APP_INITIALIZER` on page load | `CometChatProvider` watches Zustand auth store |
| Service pattern | `@Injectable` singleton class | Exported async functions + singleton state |
| Realtime delivery | RxJS `Subject` Observables | `Set<listener>` callback pattern |
| Push notifications | Not applicable (WebSocket only) | FCM + APNs via CometChat Dashboard |
| Push tap navigation | Not applicable | `registerCometChatPushHandler()` → `router.push` |
| Profile sync | `ProfileService.updateProfile()` → `syncProfile()` | Done automatically via `sync-user` endpoint |
| Logout | `LogoutService.postLogoutCleanup()` + `ProfileService.handleSignOut()` | `CometChatProvider` useEffect on auth state |
| SDK package | `@cometchat/chat-sdk-javascript` | `@cometchat/chat-sdk-react-native` |

---

## 6. Class Group Provisioning

Every class automatically gets a CometChat group chat so all students and the instructor can message together.

```mermaid
sequenceDiagram
    participant Instructor as Instructor
    participant OurAPI as Our Backend
    participant CC as CometChat REST API

    Instructor->>OurAPI: Create / save a class
    OurAPI->>OurAPI: ensureClassGroupBackground(classId)
    OurAPI->>CC: POST /groups  guid=class_{classId}
    Note over CC: Returns 409 if group already exists — treated as success
    OurAPI->>CC: POST /groups/{guid}/members\n(instructor + all enrolled students)

    Note over OurAPI,CC: Also called when a student enrols via classEnrollmentService

    Instructor->>OurAPI: POST /api/cometchat/ensure-class-group\n{ classId }
    OurAPI-->>Instructor: { guid, name }

    Note over Instructor: Web/Mobile app then opens the group\nchat using that guid
```

---

## 7. Profile Sync

When a user updates their name or photo, CometChat is kept in sync automatically.

```mermaid
sequenceDiagram
    participant User as User (Web)
    participant ProfileSvc as ProfileService
    participant OurAPI as Our Backend
    participant CC as CometChat REST API

    User->>ProfileSvc: updateProfile(formData)
    ProfileSvc->>OurAPI: PATCH /auths/profile
    OurAPI-->>ProfileSvc: Updated user object
    ProfileSvc->>ProfileSvc: tap() — syncProfile() fires (non-blocking)
    ProfileSvc->>OurAPI: POST /api/cometchat/sync-user
    OurAPI->>CC: PUT /users/{uid}  (name + avatar)
    CC-->>OurAPI: Updated
```

---

## 8. Full API Reference

### Our Backend Endpoints (all under `/api/cometchat/`)

| Method | Path | Auth | What it does |
|--------|------|------|-------------|
| `GET` | `/config` | None | Returns `{ appId, region }` — public, never exposes keys |
| `POST` | `/auth-token` | JWT | Creates CometChat user if new, returns short-lived `authToken` |
| `POST` | `/sync-user` | JWT | Pushes updated name + avatar to CometChat |
| `POST` | `/ensure-class-group` | JWT | Creates group for a class, adds instructor + all enrolled students |
| `POST` | `/create-group` | JWT | Creates a custom private group with specified members |
| `POST` | `/groups/:guid/members` | JWT | Adds new members to an existing group |
| `POST` | `/webhook` | HMAC | Receives CometChat events (`after_message`, `after_group_member_joined`, etc.) |

### CometChat SDK Methods Used

| Method | Used on | What it does |
|--------|---------|-------------|
| `CometChat.init(appId, settings)` | Both | One-time SDK initialisation |
| `CometChat.login(authToken)` | Both | Authenticate user with server-issued token |
| `CometChat.logout()` | Both | End session, close socket |
| `CometChat.sendMessage(message)` | Both | Send text or media message |
| `CometChat.MessagesRequest.fetchPrevious()` | Both | Load message history |
| `CometChat.ConversationsRequest.fetchNext()` | Both | Load conversation list |
| `CometChat.markAsRead()` | Both | Mark messages read (shows double-tick) |
| `CometChat.getUnreadMessageCount()` | Both | Fetch total unread across all conversations |
| `CometChat.addMessageListener()` | Both | Subscribe to realtime incoming messages |
| `CometChat.addUserListener()` | Both | Subscribe to online/offline presence |
| `CometChat.getLoggedinUser()` | Both | Check if already logged in (e.g. after page refresh) |
| `CometChat.searchUsers()` | Web | Search by name to start a new DM |
| `CometChat.createGroup()` | Web | Create group directly via SDK (fallback) |

---

## 9. Environment Variables

Set these in `backend/environments/local.env`:

```
COMETCHAT_APP_ID=         # Dashboard → Apps → App ID
COMETCHAT_REGION=in       # Region where your app is hosted (in / us / eu)
COMETCHAT_AUTH_KEY=       # Dashboard → API & Auth Keys → Auth Only key
COMETCHAT_REST_API_KEY=   # Dashboard → API & Auth Keys → Full Access key
COMETCHAT_WEBHOOK_SECRET= # Dashboard → Webhooks → your webhook → Secret
                          # Leave blank for local dev (verification is skipped)
```

> The `AUTH_KEY` is used only server-side to generate auth tokens.  
> The client **never** receives the auth key — it only gets the short-lived `authToken`.

---

## 10. Where Each File Lives

```
backend/
  routes/cometchat.routes.js              ← route definitions
  controllers/cometchat/cometchat.controller.js  ← request handlers
  services/cometchat/cometchat.service.js ← CometChat REST API calls
  scripts/migrate-users-to-cometchat.js   ← one-time bulk user import

frontend/src/app/
  services/core/cometchat/cometchat.service.ts   ← Angular singleton
  components/chat/
    cometchat.module.ts                   ← NgModule
    cometchat-page/                       ← page shell (conversations + chat side by side)
    cometchat-conversations/              ← conversation list + new chat / group UI
    cometchat-chat/                       ← message thread
  services/common/auth/logout.service.ts  ← calls logoutUser() on sign-out
  services/common/profile/profile.service.ts ← calls syncProfile() on profile save

mobile-development-react-native-frontend/
  services/cometchat/
    CometChatProvider.tsx                 ← React context, ties login to auth store
    cometchat.service.ts                  ← all SDK functions
    cometchat-push.ts                     ← push tap → navigate to chat
  services/notifications/
    NotificationsProvider.tsx             ← registers push handler on boot
  features/chat/screens/
    ConversationsScreen.tsx               ← conversation list
    ChatMessageScreen.tsx                 ← message thread
```
