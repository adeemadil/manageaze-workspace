# Screen Specs

## 1) Login
### Goal
Authenticate existing users with same credentials as web platform.

### Inputs
- Email
- Password

### Actions
- Sign In (primary)
- Go to Signup
- Forgot Password (secondary text action)

### States
- Default
- Loading (button spinner, fields disabled)
- Error (invalid credentials, server error)
- Offline (show cached session option if available)
- Success (route to Policy Library)

### Notes
- Keep form compact and mobile-first.
- Show secure/auth trust messaging subtly.

---

## 2) Signup
### Goal
Create account (same auth backend contract as web).

### Inputs
- First name
- Last name
- Work email
- Password
- Confirm password

### Actions
- Create Account (primary)
- Back to Login

### States
- Default
- Validation errors per field
- Loading
- Success confirmation
- Server/API error
- Offline blocked state

---

## 3) Policy Library
### Goal
Browse and search policies quickly, always render cached list first.

### Data
- Policy cards: title, status, updatedAt, owner/department, tags

### Actions
- Search
- Filter (status/category)
- Open policy detail
- Pull to refresh

### States
- Cached-first render
- Loading skeleton
- Empty
- Error fallback
- Offline with stale timestamp

---

## 4) Policy Detail
### Goal
Read full policy content and metadata.

### Sections
- Header (title, status, updatedAt)
- Metadata chips
- Policy body content
- Comments entry CTA

### Actions
- Open comments
- Back to library
- Refresh

### States
- Cached-first
- Loading
- Not found
- Offline stale

---

## 5) Policy Comments
### Goal
View and add comments for a policy.

### Layout
- Phone: bottom sheet
- Tablet/Web: side panel

### Features
- Thread list
- Composer input
- Send action
- Pending/failed message indicators

### Actions
- Post comment (optimistic)
- Retry failed comment
- Close comments panel

### States
- Cached thread
- Syncing
- Empty thread
- Error on send
- Offline queued messages
