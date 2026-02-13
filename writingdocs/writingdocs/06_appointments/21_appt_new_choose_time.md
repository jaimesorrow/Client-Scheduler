# Ticket 21 — New Appointment: Choose Date & Time
Route: `/appointments/new/time`
Guard: authed

## Purpose
Choose a slot that fits duration + buffers and avoids conflicts.

## Fields
- Date selection
- Slot selection (required)

## UI Layout
- Calendar day picker
- Time slots list/grid (15-min)
- Helper: needs X min
- CTA Continue

## States
- loading slots
- empty day
- conflict banner
- error banner

## Actions / Logic
Slot engine uses BusinessSettings.hours/breaks/buffers/blackouts and existing appointments to generate valid start times. Select slot sets draft startAt/endAt.

## Validation
- must pick slot

## Acceptance Tests
- Slots respect breaks/buffers
- Conflict returns user to pick a different slot

## Design Tokens
- Title: Playfair Display 24/600
- Body: Inter 14–16
- Accent: #C9A24D
- Background: #F6F6F8
- Divider: #E7E7EC

