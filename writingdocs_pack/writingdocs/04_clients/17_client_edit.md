# Ticket 17 — Edit Client
Route: `/clients/:id/edit`
Guard: authed

## Purpose
Edit client fields and status.

## Fields
- Same as add + status selector (Normal/VIP/Blocked)

## UI Layout
- Inputs + Save/Cancel
- Optional warning for Blocked

## States
- loading
- saving
- error

## Actions / Logic
Update client. Blocked clients are excluded from booking pickers by default.

## Validation
- same as add

## Acceptance Tests
- Changes persist on detail
- Blocked not selectable in Ticket 19 by default

## Design Tokens
- Title: Playfair Display 24/600
- Body: Inter 14–16
- Accent: #C9A24D
- Background: #F6F6F8
- Divider: #E7E7EC

