# Ticket 38 — Edit Working Hours
Route: `/availability/hours`
Guard: owner-only

## Purpose
Edit weekly schedule + breaks + buffers.

## Fields
- Per day: enabled, start, end, breaks
- buffers

## UI Layout
- 7 day rows
- Break editor
- Save button

## States
- saving
- validation errors
- error banner

## Actions / Logic
Save to BusinessSettings.hours and buffers.

## Validation
- start < end
- breaks valid

## Acceptance Tests
- Invalid shows errors
- Save persists

## Design Tokens
- Title: Playfair Display 24/600
- Body: Inter 14–16
- Accent: #C9A24D
- Background: #F6F6F8
- Divider: #E7E7EC

