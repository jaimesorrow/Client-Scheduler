# Ticket 22 — New Appointment: Review & Confirm
Route: `/appointments/new/review`
Guard: authed

## Purpose
Final confirmation; creates Appointment with audit event.

## Fields
- Optional internal notes

## UI Layout
- Summary card
- Notes multiline
- CTA Confirm
- Optional Save draft

## States
- submitting
- error banner
- conflict handling

## Actions / Logic
Confirm creates Appointment {status:'scheduled', totals snapshot} and appends audit {action:'created'}. If conflict on write, return to time screen with banner.

## Validation
- all draft fields required

## Acceptance Tests
- Success routes to detail
- Conflict routes back to time

## Design Tokens
- Title: Playfair Display 24/600
- Body: Inter 14–16
- Accent: #C9A24D
- Background: #F6F6F8
- Divider: #E7E7EC

