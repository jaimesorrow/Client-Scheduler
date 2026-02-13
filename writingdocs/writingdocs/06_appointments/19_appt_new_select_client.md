# Ticket 19 — New Appointment: Select Client
Route: `/appointments/new/client`
Guard: authed

## Purpose
Start creation by selecting a client.

## Fields
- Client selection (required)
- Optional search query

## UI Layout
- Top bar: Back + “New appointment”
- Search input
- Client list rows
- Sticky CTA: + Add new client

## States
- loading
- empty
- error

## Actions / Logic
Select client → set `draftAppointment.clientId` + snapshot → route `/appointments/new/service`. Add client routes `/clients/new?return=...`.

## Validation
- client required

## Acceptance Tests
- Selecting client continues
- Archived/Blocked behavior respected

## Design Tokens
- Title: Playfair Display 24/600
- Body: Inter 14–16
- Accent: #C9A24D
- Background: #F6F6F8
- Divider: #E7E7EC

