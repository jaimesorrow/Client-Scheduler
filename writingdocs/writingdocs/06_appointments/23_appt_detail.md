# Ticket 23 — Appointment Detail
Route: `/appointments/:id`
Guard: authed

## Purpose
Lifecycle management with status actions and audit timeline.

## Fields
- Optional notes edit
- Status actions

## UI Layout
- Status pill + summary card
- Action buttons
- Notes section
- Audit timeline

## States
- loading
- missing → system error

## Actions / Logic
Status changes update appointment and append audit event. Notes edits append notes_updated audit event.

## Validation
- none

## Acceptance Tests
- Every status change appends audit
- Buttons reflect status

## Design Tokens
- Title: Playfair Display 24/600
- Body: Inter 14–16
- Accent: #C9A24D
- Background: #F6F6F8
- Divider: #E7E7EC

