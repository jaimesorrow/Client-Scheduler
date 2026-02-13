# Ticket 25 — Reschedule Appointment
Route: `/appointments/:id/reschedule`
Guard: authed

## Purpose
Select a new slot using same slot engine and record audit.

## Fields
- Slot selection (required)
- Optional reason note

## UI Layout
- Current time card
- Calendar + slots
- Reason note
- CTA Confirm

## States
- loading
- conflict
- saving
- error

## Actions / Logic
Update startAt/endAt; append audit {action:'rescheduled', meta:{from,to,reason}}.

## Validation
- must pick slot

## Acceptance Tests
- Audit contains from/to
- Conflicts handled

## Design Tokens
- Title: Playfair Display 24/600
- Body: Inter 14–16
- Accent: #C9A24D
- Background: #F6F6F8
- Divider: #E7E7EC

