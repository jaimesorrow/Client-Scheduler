# Ticket 42 — System Hub (Permission + Error)
Route: `/system (virtual hub)`
Guard: any

## Purpose
Single implementation for permission denied + crash-safe error recovery.

## Fields
- Query params: `mode=permission|error`, `from`, `need`, `code`

## UI Layout
- Two templates:
  - Permission Denied
  - Error / Recovery
- Both include primary escape CTA

## States
- permission mode
- error mode
- retry loading
- error escalation

## Actions / Logic
Permission mode:
- Shows “Access denied” and states owner-only restriction.
- CTA: Back to dashboard.

Error mode:
- Friendly “Something went wrong”.
- CTA: Try again (re-run last safe action) or Go to dashboard.
- Never show stack traces.

## Validation
- none

## Acceptance Tests
- Staff accessing owner-only routes lands here
- Any fatal error lands here with recovery
- Back stack prevents re-entering protected screens after sign-out

## Design Tokens
- Title: Playfair Display 24/600
- Body: Inter 14–16
- Accent: #C9A24D
- Background: #F6F6F8
- Divider: #E7E7EC

