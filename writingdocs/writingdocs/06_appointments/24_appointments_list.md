# Ticket 24 — Appointments List
Route: `/appointments`
Guard: authed

## Purpose
All appointments with filters and search.

## Fields
- Date range filter
- Status filter
- Search query

## UI Layout
- Header
- Filter controls
- List rows
- FAB New appointment

## States
- loading
- empty
- error

## Actions / Logic
Query by date range and optionally status; tap row routes to detail; FAB routes to Ticket 19.

## Validation
- none

## Acceptance Tests
- Filters work
- Row opens detail

## Design Tokens
- Title: Playfair Display 24/600
- Body: Inter 14–16
- Accent: #C9A24D
- Background: #F6F6F8
- Divider: #E7E7EC

