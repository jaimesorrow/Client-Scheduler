# Ticket 41 — Analytics Detail
Route: `/analytics/detail?metric=...`
Guard: owner-only

## Purpose
Drill-down list for a selected metric.

## Fields
- metric param
- optional filters

## UI Layout
- Header metric
- Filters
- List of appointments
- Export disabled (coming soon)

## States
- loading
- empty
- error

## Actions / Logic
Query appointments by status + range; filter by service optionally.

## Validation
- metric required

## Acceptance Tests
- Correct list shown for metric
- Empty state handled

## Design Tokens
- Title: Playfair Display 24/600
- Body: Inter 14–16
- Accent: #C9A24D
- Background: #F6F6F8
- Divider: #E7E7EC

