# Ticket 09 — Working Hours Setup
Route: `/onboarding/hours`
Guard: owner

## Purpose
Define weekly hours, breaks, and buffers (drives slot generation).

## Fields
- For each weekday: enabled, start, end, breaks[]
- Global: bufferBeforeMin, bufferAfterMin

## UI Layout
- Title: “Working hours”
- 7 day rows with toggles + time pickers
- Add break per day
- Buffers section
- CTA: Finish

## States
- idle
- error inline + banner
- saving

## Actions / Logic
Save `BusinessSettings.hours` + buffers; route `/onboarding/finish`.

## Validation
- start < end on enabled days
- breaks within bounds and non-overlapping

## Acceptance Tests
- Invalid ranges show errors
- Saved hours affect available slots in Ticket 21

## Design Tokens
- Title: Playfair Display 24/600
- Body: Inter 14–16
- Accent: #C9A24D
- Background: #F6F6F8
- Divider: #E7E7EC

