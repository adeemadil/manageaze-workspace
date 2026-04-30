# ManagEaze — Development Handover PRD

**Version**: 1.0

**Date**: April 9, 2026

**Author**: Saad Hasnain (Product Manager)

**Platform Owner / Access**: Saad Vakil

**Recipient Team**: Zap Studio — Wajahat & Adeem

---

## Overview

ManagEaze is a governance, policy, and compliance management platform built for organizations that need structured policy authoring, committee-driven governance, and regulatory compliance tracking. The production platform runs on **AWS + MongoDB + Next.js (React)**. A working prototype exists in React/TypeScript and serves as the source of truth for UI, data models, and feature logic.

This document hands off three development milestones to Zap Studio. The prototype is the canonical reference — **do not redesign, do not reinvent**. Your job is to replicate and extend what exists on the production stack, connect it to a robust database schema, and build out the features described below.

All questions about platform access go to **Saad Vakil**. Product decisions go to **Saad Hasnain**.

---

## How to Work

### Use Claude Code

We strongly encourage the entire team to use [Claude Code](https://claude.ai/code) throughout this engagement. It is a CLI AI coding assistant that can scaffold features, write migrations, generate components, and significantly compress weeks of work into days. Feed it the prototype codebase and the context in this document — it will handle boilerplate, data models, and component scaffolding at a speed no manual coding workflow can match.

### Project Tracking

Set up a shared **Project Board** (Notion) before writing a line of code. The board should have:

- One column per milestone
- Cards for every task in this PRD
- Blocked/In Progress/Done states
- Weekly async status updates linked to the board

Saad H. will check this board; it is the primary reporting mechanism.

### Self-Deployment Requirement — Read This First

Some clients will run ManagEaze on their own infrastructure. **Do not build anything that cannot be self-hosted.** Specifically:

- Avoid hard dependencies on vendor-specific cloud services (AWS Lambda functions tied to SQS, Azure-specific auth, etc.)
- Any AI/LLM calls must be abstracted behind a provider interface so a self-hosted model (e.g., Ollama, vLLM, LM Studio) can be swapped in without code changes
- Container-first: every service should have a `Dockerfile` and a `docker-compose.yml` that brings the whole stack up locallConfiguration (API keys, model endpoints, S3/storage URLs) must be fully environment-variable driven

---

## Platform Stack (Production Ready)


| Layer             | Production                                                            | Source                                                                                                                                     |
| ----------------- | --------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| Frontend          | Next.js (React)                                                       | Confirmed — `/_next/` bundles + `__NEXT_DATA__`                                                                                            |
| Styling           | Tailwind CSS + Emotion                                                | Confirmed — class names + `data-emotion` in HTML                                                                                           |
| Font              | Roboto Flex (use DM Sans instead)                                     | Confirmed — font variable in HTML                                                                                                          |
| State management  | Redux + Redux Persist                                                 | Confirmed — `persist:root` in localStorage                                                                                                 |
| Frontend host     | `app.manageaze.com`                                                   | Confirmed                                                                                                                                  |
| Backend framework | **Node.js + Express**                                                 | Confirmed — `x-powered-by: Express` response header                                                                                        |
| Web server        | nginx/1.24.0 on Ubuntu                                                | Confirmed — `server: nginx/1.24.0 (Ubuntu)` response header                                                                                |
| Backend host      | `server.manageaze.com`                                                | Confirmed                                                                                                                                  |
| API base path     | `/manageaze/api/`                                                     | Confirmed — `/manageaze/api/user/login`, `/manageaze/api/policies`                                                                         |
| Real-time         | **Socket.IO** (WebSockets)                                            | Confirmed — `socket.io` polling on `server.manageaze.com`                                                                                  |
| Auth              | **Token-based via Redux Persist** — no cookies                        | Confirmed — empty `document.cookie`; `persist:root` in localStorage; CORS allows `Authorization`, `x-auth-token`, `x-access-token` headers |
| Database          | **MongoDB**                                                           | Confirmed — all IDs are Mongo ObjectIds                                                                                                    |
| Hosting           | AWS                                                                   |                                                                                                                                            |
| Storage           | **AWS S3** — bucket `manageaze-frontend-s3bucket`, region `us-east-2` | Confirmed via `logoURL` in company object                                                                                                  |


> The prototype is also available for reference. It is instead built in React/TypeScript/Supabase. The production frontend is also React (Next.js) so component patterns, hooks, and TypeScript types transfer almost directly.

> For production ready platform, the backend is a **separate Node.js/Express service** on `server.manageaze.com` — not Next.js API routes. All new endpoints must follow the `/manageaze/api/` path convention.

### Auth — How It Works

The app uses **JWT (HS256)** token-based auth. After login, the response body contains a `user` object and a `token` string. These are stored in Redux state, persisted to `localStorage` under the key `persist:root` → `user`. On every API request the token is sent as an `Authorization: Bearer <token>` header. No session cookies are used.

**JWT payload**: `{ _id, email, company, role, accessLevel, permissions, iat, exp }` — tokens expire after **24 hours**.

**Mobile app**: React Native cannot use `localStorage`/Redux Persist. Store the token in **Secure Storage** (`expo-secure-store` or `react-native-keychain`) and attach it to every request as `Authorization: Bearer <token>`. Login flow: `POST /manageaze/api/user/login` → extract `token` from response → store securely.

### Access Level Model

Access levels are a MongoDB collection, not a simple enum. Each user has an `accessLevel` object:

```jsx
{
  _id: ObjectId,
  name: String,        // e.g. "Super User"
  level: Number,       // 0 = highest (Super User), higher = lower privilege
  actions: [String]    // e.g. ["Policy Workflow Creator", "Role Editor", "Committee Editor", ...]
}
```

The governance permission table in this document maps to this `actions` array. When building governance feature gates, check `user.accessLevel.actions` — do not rely solely on `user.role`.

### Company White-Labelling

Each company has a `companyColorTheme: { primary, secondary, text }` stored in the company record. The mobile app must apply this theme on login so the UI matches the client’s brand.

### Storage

Files (logos, policy covers, attachments) are stored in S3 bucket `manageaze-frontend-s3bucket` in `us-east-2`. The bucket returns public URLs directly. For self-hosted deployments, this must be swappable — use an `STORAGE_ENDPOINT` env var so it can point to MinIO or another S3-compatible store.

### ⚠️ Security Issue — Fix Before Mobile Launch

(Check with Saad Vakil)

The `/user/login` API response currently returns the user’s **bcrypt password hash** inside the user object. This hash is then stored in Redux/localStorage on the client. **The password hash must never leave the server.** Saad Vakil should remove the `password` field from all user-facing API responses before mobile ships. This is a pre-launch blocker.

### CORS — Mobile Requires Backend Change

The backend CORS is currently locked to `https://app.manageaze.com`. Before any mobile API calls will work, Saad Vakil must add the mobile app’s origin (or use a wildcard for native apps, which send no `Origin` header). React Native’s `fetch` does not send an `Origin` header, so the CORS check is bypassed — but this must be verified in staging before ship.

### Socket.IO — Important for Mobile

Socket.IO is used for real-time updates. The mobile app must handle this:

- Use `socket.io-client` (works in React Native)
- Connect to `wss://server.manageaze.com/socket.io/`
- Pass the auth token as a handshake parameter: `io(url, { auth: { token } })`
- Confirm active event names with Saad V. (likely: policy status changes, notifications, meeting updates)

---

## Prototype Reference

The prototype codebase is available for your review. Key files and areas:


| What                     | Where in prototype                                                    |
| ------------------------ | --------------------------------------------------------------------- |
| Governance data types    | `src/types/governance.ts`                                             |
| Governance state & logic | `src/hooks/useGovernance.ts`                                          |
| Governance routes        | `src/App.tsx` (all `/governance/`* routes)                            |
| TOR form fields          | `src/components/governance/TorForm.tsx`                               |
| TOR review / approval UI | `src/pages/governance/TorReview.tsx`                                  |
| Committee hierarchy      | `src/components/governance/CommitteeTree.tsx`                         |
| Meeting minutes          | `src/pages/governance/MeetingMinutes.tsx`                             |
| Voting interface         | `src/pages/governance/VotingDecisions.tsx`                            |
| Policy editor (markdown) | `src/components/policy/PolicyEditor.tsx`                              |
| Policy approval workflow | `src/components/policy/WorkflowSidebar.tsx`, `ApprovalConditions.tsx` |
| Activity logging         | `src/lib/activity-logger.ts`                                          |


The prototype governance features use **in-memory state only** (no database persistence). Building the MongoDB schema and wiring it up is the core of Milestone 2.

---

# Milestone 1 — Native Mobile App

**Goal**: A native mobile application (iOS + Android) that gives policy viewers and participants access to ManagEaze without a browser, and enables reviewers/approvers to take action on in-progress policies.

## Scope

### Included

- Policy Library: browse and read all published/approved policies
- Viewer role: read-only access to the approved policy library
- Reviewer role: view in-progress policies, leave comments, flag concerns
- Approver role: view pending policies, leave comments (policy creation remains web-only)
- Push notifications for new assignments, comment mentions, approval requests
- Authentication using the same credentials as the web platform

### Excluded

- Policy creation (web only for now)
- Governance management (web only for now)
- Admin/settings screens

## Technical Direction

- **Framework**: **React Native** (strongly preferred over Flutter). The production and prototype frontends are both React — the team is already in that ecosystem, hooks and component logic carry over, and `socket.io-client` has first-class React Native support
- **API Layer**: Extend the existing Express backend on `server.manageaze.com`. Add new endpoints under `/manageaze/api/` — do not create a separate mobile API service
- **Auth**: JWT HS256, 24-hour expiry. Shared with web — same `/manageaze/api/user/login` endpoint. On mobile, store the token from the response in **Secure Storage** (`expo-secure-store`), not AsyncStorage
- **Offline**: Basic read caching for the policy library so the app works with poor connectivity
- **Notifications**: Firebase Cloud Messaging (FCM) for both platforms

## API Endpoints Needed (minimum)

Base URL: `https://server.manageaze.com/manageaze/api/`

Several of these already exist (e.g. `/user/login`, `/policies`). Extend them or add mobile-specific variants as needed — do not break existing web clients.

```
GET  /policies                   — published policy list (EXISTS — extend for mobile filtering)
GET  /policies/:id               — policy detail + content
GET  /policies/:id/comments      — comments on a policy
POST /policies/:id/comments      — post a comment
GET  /user/assignments           — policies assigned to me for review/approval
POST /user/login                 — authenticate (EXISTS)
POST /user/refresh               — token refresh
POST /notifications/register     — register FCM device token (NEW)
```

## Deliverables

- iOS and Android builds (TestFlight + APK for UAT)
- API spec (OpenAPI/Swagger)
- App deployed to App Store and Google Play (or internal distribution for initial release — confirm with Saad H.)

---

---

# Milestone 2 — Governance Architecture + AI Meeting Intelligence

**Goal**: Migrate the prototype governance module to production (MongoDB + Next.js), implement an approval workflow for the Governance Framework and TORs, and build an AI-powered meeting intelligence layer that transcribes meetings, extracts action items, and logs voting outcomes.

This is the most technically intensive milestone.

## Part A — Governance Data Schema (MongoDB)

The prototype has well-defined TypeScript types in `src/types/governance.ts`. Use them to design the MongoDB collections. Below is the recommended schema.

**Field naming convention**: the existing backend uses camelCase field names (confirmed from the live user/company objects: `firstName`, `accessLevel`, `companyColorTheme`, `paymentPlanType`). Use camelCase throughout — not snake_case. The schemas below use snake_case for readability; convert to camelCase in the actual implementation (e.g. `organization_id` → `companyId`, `created_at` → `createdAt`).

**Company reference**: in the existing schema the company/org reference field is called `company` (visible in JWT payload: `{ company: "..." }`). Use `companyId` consistently in new collections to match this convention.

### Collection: `governance_frameworks`

```jsx
{
  _id: ObjectId,
  organization_id: ObjectId,
  name: String,
  description: String,
  status: String,              // "draft" | "active" | "archived"
  approval_status: String,     // "draft" | "submitted" | "approved" | "rejected"
  version: Number,
  created_by: ObjectId,        // ref: users
  approved_by: ObjectId,       // ref: users
  approved_at: Date,
  committees: [ObjectId],      // refs: committees
  created_at: Date,
  updated_at: Date
}
```

### Collection: `committees`

```jsx
{
  _id: ObjectId,
  organization_id: ObjectId,
  framework_id: ObjectId,
  name: String,
  description: String,
  type: String,                // "standing" | "ad-hoc"
  level: String,               // "L1" | "L2" | "L3" | "L4" | "L5"
  parent_committee_id: ObjectId | null,
  owner_id: ObjectId,          // ref: users
  chairperson_id: ObjectId,    // ref: users
  min_members: Number,
  meeting_frequency: String,   // "weekly" | "bi-weekly" | "monthly" | "quarterly" | "annual"
  members: [
    {
      user_id: ObjectId,
      role: String,            // "administrator" | "chairperson" | "member" | "approver" | "reviewer" | "observer"
      joined_at: Date
    }
  ],
  tor_id: ObjectId | null,     // ref: terms_of_reference
  created_at: Date,
  updated_at: Date
}
```

### Collection: `terms_of_reference`

```jsx
{
  _id: ObjectId,
  organization_id: ObjectId,
  committee_id: ObjectId,
  version: String,             // e.g. "1.0", "1.1"
  status: String,              // "draft" | "submitted" | "under_review" | "approved" | "rejected"
  content: {
    purpose: String,           // markdown
    roles_and_responsibilities: String, // markdown
    agenda: String,            // markdown
    reporting_workflow: String,
    approval_workflow: String,
    meeting_frequency: String
  },
  approval_log: [
    {
      approver_id: ObjectId,
      action: String,          // "approved" | "rejected" | "commented"
      comment: String,
      timestamp: Date
    }
  ],
  version_history: [
    {
      version: String,
      updated_by: ObjectId,
      update_comment: String,
      snapshot: Object,        // full content snapshot
      timestamp: Date
    }
  ],
  required_approvers: [ObjectId],
  submitted_at: Date,
  approved_at: Date,
  created_at: Date,
  updated_at: Date
}
```

### Collection: `meetings`

```jsx
{
  _id: ObjectId,
  organization_id: ObjectId,
  committee_id: ObjectId,
  title: String,
  scheduled_at: Date,
  held_at: Date,
  status: String,              // "scheduled" | "in_progress" | "completed" | "cancelled"
  attendees: [
    {
      user_id: ObjectId,
      attended: Boolean,
      role: String             // "chair" | "member" | "guest"
    }
  ],
  agenda_items: [
    {
      item: String,
      notes: String,
      referenced_tor_id: ObjectId | null
    }
  ],
  decisions: [String],
  action_items: [
    {
      description: String,
      assigned_to: ObjectId,
      due_date: Date,
      status: String,          // "open" | "in_progress" | "completed"
      source: String           // "manual" | "ai_extracted"
    }
  ],
  voting_ids: [ObjectId],      // refs: voting_decisions
  transcript: {
    raw: String,               // full transcript text
    source: String,            // "upload" | "live" | "url"
    processed_at: Date
  },
  ai_summary: {
    summary: String,
    action_items_extracted: [String],
    key_decisions: [String],
    generated_at: Date,
    model: String              // track which model was used
  },
  minutes_published: Boolean,
  minutes_published_at: Date,
  created_by: ObjectId,
  created_at: Date,
  updated_at: Date
}
```

### Collection: `voting_decisions`

```jsx
{
  _id: ObjectId,
  organization_id: ObjectId,
  committee_id: ObjectId,
  meeting_id: ObjectId | null,
  title: String,
  description: String,
  status: String,              // "open" | "passed" | "rejected" | "withdrawn"
  deadline: Date,
  votes: [
    {
      user_id: ObjectId,
      vote: String,            // "yes" | "no" | "abstain"
      comment: String,
      voted_at: Date
    }
  ],
  quorum_required: Number,     // minimum votes needed
  result_summary: {
    yes: Number,
    no: Number,
    abstain: Number,
    total: Number,
    outcome: String
  },
  created_by: ObjectId,
  created_at: Date,
  updated_at: Date
}
```

---

## Part B — Governance Framework in Next.js

Port the prototype governance UI to the production Next.js app. Since both the prototype and production frontend are React, components and hooks transfer with minimal rework. Match the prototype exactly — layout, workflow states, component hierarchy. Do not redesign.

### Features to port


| Feature              | Prototype Reference                      | Notes                                          |
| -------------------- | ---------------------------------------- | ---------------------------------------------- |
| Governance Dashboard | `GovernanceDashboard.tsx`                | Framework overview, committee tree, TOR status |
| Framework Wizard     | `FrameworkWizard.tsx`                    | Guided framework setup                         |
| Committee Management | `CommitteeTree.tsx`, `CommitteeForm.tsx` | Hierarchical L1-L5 structure                   |
| Org Chart            | `OrgChart.tsx`                           | Visual organizational hierarchy                |
| TOR Editor           | `TorEditor.tsx`, `TorForm.tsx`           | Markdown editor (see Part D for editor spec)   |
| TOR Preview          | `TorPreview.tsx`                         | Print-ready document view                      |
| TOR Review           | `TorReview.tsx`                          | 4-tab approval interface                       |


### Approval Workflow for Governance Framework

This does not exist in the prototype and must be built. Model it after the policy approval workflow.

**States**: `draft → submitted → under_review → approved | rejected`

**Rules**:

- Only the framework creator or an L1 committee member can submit for approval
- Approval requires sign-off from all designated approvers (configurable per framework)
- Any approver can reject; rejection requires a comment and returns to `draft`
- Approved frameworks are locked — edits require creating a new version
- Full approval log (who approved/rejected, when, comment) persisted to `governance_frameworks` collection

**UI Components needed**:

- Framework submission button (visible to creator/L1 admin only)
- Approval panel (list of required approvers + their status)
- Rejection modal with required comment field
- Version history tab (match TOR version history pattern)

---

## Part C — TOR Approval Workflow (Production-Wired)

The prototype has the TOR approval UI built (`TorReview.tsx`, `TorApprovalPanel.tsx`). Wire it to the database:

- Save all approval log entries to `terms_of_reference.approval_log`
- Save version snapshots on each submission to `terms_of_reference.version_history`
- Enforce quorum: TOR status only moves to `approved` when all `required_approvers` have approved
- Notifications: notify required approvers when a TOR is submitted; notify creator when fully approved or rejected

---

## Part D — Markdown Editor (TOR + Governance)

Build a reusable Markdown editor component for the production Next.js app, modelled on the policy editor (`src/components/policy/PolicyEditor.tsx`).

### Requirements

- **Editor**: Use [Tiptap](https://tiptap.dev/) (recommended) or upgrade the existing ReactQuill implementation. Since production is also Next.js/React, the prototype’s editor code is directly portable
- **Toolbar**: Bold, italic, headings (H1–H3), ordered/unordered lists, blockquote, horizontal rule, undo/redo
- **Markdown export**: Content must serialize to Markdown for storage (not HTML)
- **Markdown import**: Load Markdown from the database and render it in the editor
- **RTL support**: Some users write right-to-left; detect and switch text direction per-paragraph (see PolicyEditor for reference)
- **Auto-save**: Debounced save every 30 seconds while editing
- **Read-only mode**: Render Markdown as formatted HTML (for preview/published views)
- **Word count**: Display live word count in the toolbar

This component will be used in:

- TOR Purpose, Roles & Responsibilities, Agenda sections
- Meeting minutes capture
- Any future long-form content fields

## Part F — Permission Model

The governance module needs a clear permission layer. Map committee roles to actions:


| Action                        | Organization Admin | L1 Committee Member | Chairperson       | Committee Member | Viewer |
| ----------------------------- | ------------------ | ------------------- | ----------------- | ---------------- | ------ |
| Create framework              | ✓                  | ✓                   | —                 | —                | —      |
| Submit framework for approval | ✓                  | ✓                   | —                 | —                | —      |
| Approve framework             | ✓                  | ✓ (if designated)   | —                 | —                | —      |
| Create committee              | ✓                  | ✓                   | —                 | —                | —      |
| Edit TOR                      | ✓                  | ✓                   | ✓                 | —                | —      |
| Approve TOR                   | ✓                  | ✓ (if designated)   | ✓ (if designated) | —                | —      |
| Create meeting                | ✓                  | ✓                   | ✓                 | —                | —      |
| Publish minutes               | ✓                  | ✓                   | ✓                 | —                | —      |
| Cast vote                     | ✓                  | ✓                   | ✓                 | ✓                | —      |
| View published content        | ✓                  | ✓                   | ✓                 | ✓                | ✓      |


**Important**: the production platform has two separate permission concepts that must not be conflated:

1. `**user.accessLevel`** — platform-wide permissions. A MongoDB document with `level: Number` (0 = Super User, higher = lower privilege) and `actions: [String]` (e.g. `"Committee Editor"`, `"Policy Workflow Creator"`). This gates whether a user can access governance features at all.
2. `**committees.members[].role`** — committee-specific role (chairperson, member, approver, etc.). This gates what a user can do *within* a specific committee.

Governance middleware must check both: `accessLevel.actions` first (can this user touch governance at all?), then `committee.members[].role` (can they perform this specific action in this committee?).

---

---

---

# Milestone 3 — Task Automation & Compliance Dashboard

**Status**: Tentative. If Milestone 2 surfaces additional governance requirements, those take priority and this milestone is adjusted. Confirm scope with Saad H. before starting.

**Goal**: Close the loop between governance decisions and operational execution. Automate recurring governance tasks. Give leadership a real-time compliance and governance health dashboard.

## Part A — AI Meeting Intelligence

This is the most novel feature in the milestone. The goal is: after a meeting, a committee secretary uploads a recording or transcript, and the platform produces a structured meeting summary with extracted action items and decision log — automatically.

### Flow

```
Meeting held
    → Recording/transcript uploaded (or live meeting URL provided)
    → Transcription (if audio/video)
    → AI processing: extract summary, action items, key decisions
    → Human review: secretary reviews and edits AI output
    → Publish: meeting minutes published to the committee
```

### Transcription

Support three input modes:

1. **File upload**: MP3/MP4/WAV → transcribe via Whisper API (self-hostable: `openai/whisper` via `whisper.cpp` or `faster-whisper`)
2. **Text paste / document upload**: Secretary pastes raw transcript text or uploads .txt/.docx
3. **Integration (future)**: Zoom/Teams meeting URL — out of scope for now, design the integration point but don’t implement

Whisper must be abstracted: `TranscriptionProvider` interface with a `WhisperProvider` implementation. Future providers (Zoom, AssemblyAI) implement the same interface.

### AI Processing

After transcription, call an LLM to extract:

- **Executive summary** (3–5 sentences)
- **Action items**: each item includes description, suggested assignee (matched to committee members), suggested due date
- **Key decisions made**
- **Voting outcomes** (if votes were discussed)

The LLM call must go through a `LLMProvider` interface:

```jsx
// Provider interface
interface LLMProvider {
  complete(prompt: string, options: LLMOptions): Promise<string>
}

// Implementations
class AnthropicProvider implements LLMProvider { ... }    // Claude API
class OpenAIProvider implements LLMProvider { ... }       // OpenAI API
class OllamaProvider implements LLMProvider { ... }       // Self-hosted
class VLLMProvider implements LLMProvider { ... }         // Self-hosted vLLM
```

Config drives which provider is active:

```
LLM_PROVIDER=anthropic          # or openai | ollama | vllm
LLM_API_KEY=...
LLM_BASE_URL=http://localhost:11434  # for self-hosted
LLM_MODEL=claude-sonnet-4-6
```

Use structured output / JSON mode when calling the LLM so the response parses reliably without fragile string parsing.

### Meeting Dashboard

After the secretary reviews and publishes:

- A **Meeting Report** page per meeting showing:
  - Date, committee, attendees
  - AI-generated summary (with “AI generated” label)
  - Action items table (assignee, due date, status — trackable after the fact)
  - Decisions log
  - Voting outcomes
  - Link to full minutes (Markdown rendered)
- A **Committee Meeting History** view: all past meetings for a committee, searchable
- Action items feed: cross-committee view of all open action items assigned to the logged-in user

### Manual Fallback

If no recording is available, the secretary can fill in the meeting fields manually. AI processing is an enhancement, not a blocker. Every AI-populated field must be editable by the secretary before publishing.

---

## Part A — Electronic Voting

Extend the Milestone 2 voting system with formal electronic voting workflows:

- Vote by committee member (one vote per member, recorded with timestamp)
- Voting open/close dates enforced server-side
- Quorum check: voting closes as passed/rejected only if quorum is met
- Abstain option always available
- Voter cannot change vote after submission (audit trail requirement)
- Email/push notification when a vote is opened that requires your participation
- Results published to the Meeting Dashboard automatically when vote closes

## Part B — Notification

Pairs with the mobile app to notify the users based on the setup. The prototype has a proof-of-concept at `src/pages/governance/TaskAutomation.tsx`. Build the real thing:


| Automation                  | Trigger                                       | Action                                        |
| --------------------------- | --------------------------------------------- | --------------------------------------------- |
| TOR renewal reminder        | TOR `approved_at` + renewal interval          | Notify chairperson 30/15/7 days before expiry |
| Overdue approval escalation | Approval pending > N days (configurable)      | Notify next level up + log escalation         |
| Action item follow-up       | Action item `due_date` approaching            | Notify assigned user 3 days before            |
| Meeting minutes overdue     | Meeting `held_at` + 48h, no published minutes | Notify secretary                              |
| Committee quorum alert      | Meeting quorum not met at scheduled time      | Notify chairperson                            |


Automations run as scheduled jobs (cron). Must be self-hostable — use a simple job queue (BullMQ with Redis, or a cron table in MongoDB). No AWS SQS, no Temporal unless you’re already running it.

## Part C — Compliance Dashboard

A real-time executive dashboard visible to users whose `accessLevel.level` is 0 or 1 (Super User / senior access), and to users with `"Access To Policy Approval Information"` in their `accessLevel.actions`:

### Panels

**Governance Health**

- Frameworks: X active, Y pending approval
- Committees: total count, committees missing TOR, committees with overdue TOR renewal
- Meetings: meetings held this quarter vs. required (per TOR frequency)

**Policy Compliance**

- Policies: approved count, in-review count, overdue for renewal
- Quiz completion rate by department (if quiz module is active)

**Action Items**

- Open action items by committee
- Overdue action items (past due date)
- Completion rate this month

**Voting Record**

- Votes held this quarter
- Pass/fail/withdrawn breakdown
- Participation rate (% of eligible voters who voted)

All dashboard data must be real-time or near-real-time (MongoDB aggregation pipelines, refreshed on page load or with a short polling interval). No hardcoded numbers.

---

## Appendix A — Environment Configuration Template

```
# Application
NODE_ENV=production
PORT=3000
APP_URL=https://app.manageaze.com

# Database
MONGODB_URI=mongodb+srv://...
MONGODB_DB=manageaze

# Auth
JWT_SECRET=...
JWT_EXPIRY=1d    # confirmed 24h expiry from production tokens

# Storage (S3 compatible — works with AWS S3, MinIO, Cloudflare R2)
STORAGE_PROVIDER=s3          # or minio | r2
STORAGE_BUCKET=manageaze-frontend-s3bucket   # confirmed bucket name
STORAGE_REGION=us-east-2                     # confirmed region
STORAGE_ACCESS_KEY=...
STORAGE_SECRET_KEY=...
STORAGE_ENDPOINT=            # leave blank for AWS S3, set for MinIO/R2 self-hosted

# LLM (AI meeting intelligence, summaries)
LLM_PROVIDER=anthropic       # or openai | ollama | vllm
LLM_API_KEY=...
LLM_BASE_URL=                # for self-hosted providers
LLM_MODEL=claude-sonnet-4-6

# Transcription (meeting audio)
TRANSCRIPTION_PROVIDER=whisper   # or assemblyai
WHISPER_MODEL=base               # for self-hosted whisper
WHISPER_ENDPOINT=                # for remote whisper service
ASSEMBLYAI_API_KEY=              # if using AssemblyAI

# Push Notifications
FCM_SERVER_KEY=...

# Email
SMTP_HOST=...
SMTP_PORT=587
SMTP_USER=...
SMTP_PASS=...
SMTP_FROM=noreply@manageaze.com

# Job Queue
REDIS_URL=redis://localhost:6379
```

---

## Appendix B — Milestone Summary


| Milestone                                  | Core Deliverable                                                     | Key Risk                                                                  |
| ------------------------------------------ | -------------------------------------------------------------------- | ------------------------------------------------------------------------- |
| 1 — Mobile App                             | Native iOS/Android policy viewer                                     | API design must be extensible for governance features in later milestones |
| 2 — Governance Architecture                | MongoDB schema + Next.js governance module + AI meeting intelligence | LLM provider abstraction is critical for self-deployment clients          |
| 3 — Task Automation & Compliance Dashboard | Automated jobs + executive dashboard                                 | Scope may shift based on M2 findings — confirm before kickoff             |


---

## Appendix C — Questions Before You Start

Resolve these with Saad Vakil and Saad Hasnain before the first sprint:

1. MongoDB Atlas tier — confirm with Saad V. (affects aggregation pipeline complexity and Atlas Search availability)
2. Socket.IO event names currently emitted — confirm with Saad V. (mobile needs these to subscribe to the right channels)
3. Is Redis already running on `server.manageaze.com`? — confirm with Saad V. (determines job queue approach for M3 automations)

---

*End of document. Questions to Saad Hasnain at +923324878866.*