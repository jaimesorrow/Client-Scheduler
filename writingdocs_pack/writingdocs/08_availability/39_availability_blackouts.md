# Ticket 39 — Time Off / Blackouts
Route: `/availability/blackouts`
Guard: owner-only

## Purpose
Add blackout ranges to block booking.

## Fields
- start datetime
- end datetime

## UI Layout
- Range picker
- List of blocks
- Add/remove

## States
- saving
- error

## Actions / Logic
Save ranges to BusinessSettings.blackouts; slot engine excludes them.

## Validation
- end after start

## Acceptance Tests
- Blackouts remove slots on Ticket 21

## Design Tokens
- Title: Playfair Display 24/600
- Body: Inter 14–16
- Accent: #C9A24D
- Background: #F6F6F8
- Divider: #E7E7EC

