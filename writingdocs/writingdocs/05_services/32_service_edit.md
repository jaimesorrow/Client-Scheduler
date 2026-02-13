# Ticket 32 — Edit Service
Route: `/services/:id/edit`
Guard: authed

## Purpose
Edit service fields; do not retroactively affect past appointments.

## Fields
- Same as add

## UI Layout
- Inputs + Save

## States
- saving
- error

## Actions / Logic
Update Service. Existing appointments keep snapshot totals.

## Validation
- same as add

## Acceptance Tests
- Edits persist; past appointments unchanged

## Design Tokens
- Title: Playfair Display 24/600
- Body: Inter 14–16
- Accent: #C9A24D
- Background: #F6F6F8
- Divider: #E7E7EC

