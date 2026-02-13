# Ticket 26 — Cancel Appointment
Route: `/appointments/:id/cancel`
Guard: authed

## Purpose
Cancel with reason (required) and audit.

## Fields
- Reason* (required)
- Optional note

## UI Layout
- Reason picker
- Note input
- Destructive CTA Cancel
- Secondary Keep

## States
- saving
- error

## Actions / Logic
Set status='cancelled'; save reason/note; append audit {action:'cancelled'}.

## Validation
- reason required

## Acceptance Tests
- Cancel reflected across lists
- Audit appended

## Design Tokens
- Title: Playfair Display 24/600
- Body: Inter 14–16
- Accent: #C9A24D
- Background: #F6F6F8
- Divider: #E7E7EC

