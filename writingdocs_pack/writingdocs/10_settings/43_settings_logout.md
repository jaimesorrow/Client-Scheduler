# Ticket 43 — Settings: Log Out
Route: `/settings/logout`
Guard: authenticated

## Purpose
Predictable logout flow (confirm, clear session, clear caches, route to welcome).

## Fields
- none

## UI Layout
- Title: Log out
- Confirm card
- Primary: Log out
- Secondary: Cancel

## States
- idle
- logging out
- error banner
- success

## Actions / Logic
Clear secure storage (token/userId/businessId), clear caches (clients/services/drafts), reset app state; optionally revoke server session; route `/welcome` and clear navigation stack.

## Validation
- none

## Acceptance Tests
- Confirm logs out and routes welcome
- Back cannot return to dashboard
- Cached PII not visible after logout

## Design Tokens
- Title: Playfair Display 24/600
- Body: Inter 14–16
- Accent: #C9A24D
- Background: #F6F6F8
- Divider: #E7E7EC

