# Ticket 20 — New Appointment: Select Services
Route: `/appointments/new/service`
Guard: authed

## Purpose
Select 1+ services; compute totals.

## Fields
- Multi-select services (>=1)

## UI Layout
- Search input
- Service cards with checkbox
- Sticky summary (Total + Duration)
- CTA Continue

## States
- loading
- empty
- error

## Actions / Logic
Update `draftAppointment.serviceIds[]`; compute totals and persist into draft; continue to time picker.

## Validation
- must select >=1 service

## Acceptance Tests
- Summary updates live
- Continue disabled until valid

## Design Tokens
- Title: Playfair Display 24/600
- Body: Inter 14–16
- Accent: #C9A24D
- Background: #F6F6F8
- Divider: #E7E7EC
