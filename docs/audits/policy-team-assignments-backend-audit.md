# Policy team, roles, and assignments — audit (production backend)

**Date:** 2026-05-12  
**Scope:** Source of truth is **`app-backend-manageaze`** (Express + MongoDB). The **manageaze-prototype** (Lovable / Supabase-oriented) is **not** deployed production; it is referenced only for conceptual drift. **manageaze-mobile-app** is the consumer audit.

---

## 1. Executive summary

| Layer | Role in this audit |
|-------|-------------------|
| **`app-backend-manageaze`** | **Canonical.** Defines `Policy`, `Team`, `User`, statuses, and list/workflow endpoints. |
| **`manageaze-mobile-app`** | Must align filters and CTAs with backend behavior + product rules (Saad Hasnain). |
| **`manageaze-prototype`** | **Non-authoritative.** Different stack (in-memory / Supabase types); useful for UX vocabulary only. |

**Product rule (Saad Hasnain, 2026):** *My Assignments* should show only policies **assigned to the user** that are in **that role’s stage**:

- **Reviewer** + **In review**
- **Creator** + **Draft**
- **Approver** + **Pending approval** (backend: `SUBMITTED`)

The production API **`GET /policies/get-policies-for-quick-actions`** currently returns **all** policies whose `policy.team` array contains the user, **without** status or role-stage filtering — mobile (or backend) must apply the rules above.

---

## 2. Production data model

### 2.1 `Policy` ([`models/policy.js`](../../app-backend-manageaze/models/policy.js))

| Field | Type | Notes |
|-------|------|--------|
| `team` | `[ObjectId → User]` | **Flat list** of user refs. This is what `getPoliciesForQuickActions` queries (`team: userId`). |
| `status` | enum string | `DRAFT`, `IN REVIEW`, `SUBMITTED`, `APPROVED` ([`utils/constants.js`](../../app-backend-manageaze/utils/constants.js)). |
| `createdBy` | ObjectId → User | Policy author; **not** the same field as workflow “creator” on the `Team` document. |
| `company`, `policyType`, versions, etc. | — | Omitted here for brevity. |

**Implication:** Workflow role for a user on a policy is inferred from each **User** document’s **`accessLevel.name`** when `team` is populated (`populate: { path: 'accessLevel' }`). There is **no** separate “role per policy” field on `Policy` itself beyond membership in `team`.

### 2.2 `Team` ([`models/team.js`](../../app-backend-manageaze/models/team.js))

Separate collection, **one document per policy** (`policy` ref, **unique**):

| Field | Notes |
|-------|--------|
| `creator` | Single user ref — **explicit** workflow creator. |
| `reviewers` | Array of user refs. |
| `approvers` | Array of user refs. |

**Implication:** This is the **structured** breakdown Saad’s rules map to naturally. **`Policy.team`** is a **unified** list; keeping it in sync with `Team` (creator + reviewers + approvers) is a **product/backend contract** — not enforced by a single Mongoose validator across both models in this repo.

**Uniqueness:** Schema does **not** forbid the same `ObjectId` in `creator` and `reviewers`; the web UI is expected to enforce “one hat per person” (per product).

### 2.3 `User` ([`models/user.js`](../../app-backend-manageaze/models/user.js))

- `accessLevel` → ref **`AccessLevel`** (e.g. name: `Creator`, `Reviewer`, `Approver`, `Super User`).
- JWT payload ([`userSchema.methods.generateToken`](../../app-backend-manageaze/models/user.js)): `accessLevel` is stored as **`accessLevel.name`** (string), not the ObjectId.

### 2.4 Helper `isUserInTeam` ([`utils/helpers.js`](../../app-backend-manageaze/utils/helpers.js))

**Signature intent:** `team` = **`Team` document shape** with `{ creator, approvers, reviewers }`.

**Critical:** Passing **`policy.team`** (an **array of User documents**) into `isUserInTeam` does **not** match that shape. Destructuring an array does not yield `creator` / `approvers` / `reviewers` fields, so **`memberIds` ends up empty** and the function returns **`false`** (except accidental edge cases).

**Affected call sites (verified by read):**

- [`getDashboardPolicyData`](../../app-backend-manageaze/controllers/policies.js) — filters with `isUserInTeam(p.team, userId)` where `p.team` is populated Users → **likely wrong for non–Super Users**.
- [`getDraftedPolicies`](../../app-backend-manageaze/controllers/policies.js) — same pattern → **likely wrong for non–Super Users**.

**Also:** [`isAccessRestricted`](../../app-backend-manageaze/utils/helpers.js) passes **`policy.team`** (User array) into `isUserInTeam` — same mismatch. Several controller paths have access checks **commented out**, which may have hidden this.

These are **backend bugs / tech debt**, independent of mobile. They do **not** apply to `getPoliciesForQuickActions`, which uses `Policy.find({ team: _id })` only.

---

## 3. API surfaces relevant to assignments and library

| Route | Handler | Membership / filter | Status filter |
|-------|---------|---------------------|---------------|
| `GET /policies/get-policies-for-quick-actions` | `getPoliciesForQuickActions` | `team` contains current user `_id` | **None** — returns all statuses |
| `GET /policies` | `getUserPolicies` | Filter: `isSuperUser \|\| p.team.map(t => t._id === userId)` | Excludes `DRAFT` and `APPROVED` |
| `GET /policies/drafted` | `getDraftedPolicies` | `isSuperUser \|\| isUserInTeam(p.team, userId)` | `DRAFT` only — **`isUserInTeam` misuse** (see §2.4) |
| `GET /policies/library/:designationId` | `getPolicyLibrary` | By company + designation | `APPROVED` only |
| `GET /policies/:id` | `policyById` | Company check; draft vs non-draft populate paths | — |
| `PATCH /policies/policy-reviewed/:policyId` | `policyReviewed` | User is **Reviewer** on populated `team`, policy **IN REVIEW** | Server-enforced |
| `PATCH /policies/approve/:id` | `approvePolicy` | User is **Approver** on team, policy **SUBMITTED** | Server-enforced |

### 3.1 `getUserPolicies` filter bug

[`controllers/policies.js`](../../app-backend-manageaze/controllers/policies.js) ~228–230:

```js
const filteredPolicies = policies.filter(
  (p) => isSuperUser(p.company, req.user) || p.team.map(t => t._id === userId)
);
```

`p.team.map(...)` returns an **array of booleans**, which is always **truthy** (non-empty array). The intent was almost certainly **`p.team.some(t => t._id.equals(userId))`**. As written, **non–super users may incorrectly receive all company non-draft/non-approved policies** (or behavior depends on subtle coercion). **Recommend fix + test.**

---

## 4. Status vocabulary (API → mobile)

| Backend `POLICY_STATUS` | Typical mobile label ([`normalizeStatus`](../../manageaze-mobile-app/src/features/policies/policy-cache.ts)) |
|-------------------------|----------------------------------------------------------------------------------------------------------|
| `DRAFT` | Draft |
| `IN REVIEW` | In review |
| `SUBMITTED` | Pending approval |
| `APPROVED` | Approved |

Saad’s **Approver** stage maps to **`SUBMITTED`** / mobile **Pending approval**.

---

## 5. How mobile derives “role on this policy”

[`deriveViewerTeamRole`](../../manageaze-mobile-app/src/features/policies/policy-cache.ts) walks **`policy.team`**, finds the member whose `_id` matches the viewer, reads **`member.accessLevel.name`**.

**Assumptions:**

- Each user appears **at most once** in `policy.team`.
- Their **`AccessLevel.name`** matches workflow expectations (`Creator` / `Reviewer` / `Approver` / `Super User`).

**Gap vs `Team` document:** If **`Team.creator`** is the source of truth for “creator” but that user’s global access level or `policy.team` membership is wrong or missing, **Creator + Draft** filtering on mobile can be wrong. **Recommendation:** Confirm with Saad V. / web whether **`Team`** should be exposed on quick-actions responses or merged server-side for assignments.

---

## 6. Prototype (`manageaze-prototype`) — reference only

[`src/types/policy.ts`](../../manageaze-prototype/src/types/policy.ts) uses:

- `assignedReviewers: string[]`, `assignedApprovers: string[]`, `UserRole`, statuses like `Under Review`.

This is **not** wired to Mongo `Policy` / `Team` in production. Use it only for **naming** and UI sketches, not for schema or permission truth.

---

## 7. Alignment checklist (post–Saad rules)

| Item | Backend today | Mobile / next step |
|------|---------------|-------------------|
| Quick actions payload | All statuses for team members | Filter: Reviewer ∧ In review; Creator ∧ Draft; Approver ∧ Pending approval |
| Library “Needs attention” | Merged from `GET /policies` + library in app | Apply **same** role+stage rules to action queue section |
| Super User | JWT + `isSuperUser` in several handlers | Product: same strict assignment rows vs oversight — confirm with PM |
| Creator identity | `Team.creator` vs `createdBy` vs `policy.team` | Confirm single source of truth with backend owner |

---

## 8. Recommendations

1. **Backend (optional but ideal):** Narrow `getPoliciesForQuickActions` with server-side filters using **`Team`** + `status` + user id, or add a dedicated **`GET /user/assignments`** that implements Saad’s matrix — reduces client bugs and payload size.
2. **Backend (fix):** Correct `getUserPolicies` filter (use `.some` / `equals`). Fix **`isUserInTeam` vs `policy.team`** misuse in `getDashboardPolicyData` and `getDraftedPolicies` (use a dedicated helper for “user id in populated `policy.team` array”).
3. **Mobile:** Implement shared **`includeInAssignmentQueue(policy, viewer)`** + bump cache key; keep **`policyReviewed` / `approvePolicy`** gates aligned with §3 table.
4. **Docs:** Keep this file updated when `Team` ↔ `policy.team` sync or assignment API changes.

---

## 9. File index (production)

| Area | Path |
|------|------|
| Policy model | `app-backend-manageaze/models/policy.js` |
| Team model | `app-backend-manageaze/models/team.js` |
| User / JWT | `app-backend-manageaze/models/user.js` |
| Policies controller | `app-backend-manageaze/controllers/policies.js` |
| Team edit | `app-backend-manageaze/controllers/team.js` |
| Helpers | `app-backend-manageaze/utils/helpers.js` |
| Access level names | `app-backend-manageaze/utils/access-level-actions.js` |
| Policy routes | `app-backend-manageaze/routes/policies.js` |
| Mobile normalization | `manageaze-mobile-app/src/features/policies/policy-cache.ts` |
| Mobile types | `manageaze-mobile-app/src/features/policies/policy-types.ts` |
