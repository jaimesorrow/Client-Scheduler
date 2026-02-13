# Ticket 28 — Complete Appointment
Route: `/appointments/:id/complete`
Guard: authed

## Purpose
Mark completed and audit.

## Fields
- Optional completion note

## UI Layout
- Confirm UI
- CTA Mark completed
- Secondary Back

## States
- saving
- error

## Actions / Logic
Set status='completed'; append audit {action:'completed'}

## Validation
- none

## Acceptance Tests
- Completed appears in analytics counts
- Audit appended

## Design Tokens
- Title: Playfair Display 24/600
- Body: Inter 14–16
- Accent: #C9A24D
- Background: #F6F6F8
- Divider: #E7E7EC

