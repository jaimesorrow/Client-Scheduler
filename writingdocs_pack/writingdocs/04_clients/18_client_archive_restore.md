# Ticket 18 — Archive/Restore Client
Route: `/clients/:id/archive`
Guard: authed

## Purpose
Soft archive client; hide from booking.

## Fields
- none

## UI Layout
- Confirm screen: Archive? (or Restore?)
- Primary destructive/primary restore
- Cancel

## States
- saving
- error

## Actions / Logic
Set `Client.archived=true/false`. Archived hidden by default.

## Validation
- none

## Acceptance Tests
- Archived removed from lists and appointment flow

## Design Tokens
- Title: Playfair Display 24/600
- Body: Inter 14–16
- Accent: #C9A24D
- Background: #F6F6F8
- Divider: #E7E7EC

