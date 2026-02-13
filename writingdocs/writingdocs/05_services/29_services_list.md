# Ticket 29 — Services List
Route: `/services`
Guard: authed

## Purpose
Service catalog with pricing and duration.

## Fields
- Search query
- Filter: Active/Archived

## UI Layout
- Header
- Search input
- Filter chips
- Service rows
- FAB Add

## States
- loading
- empty
- error

## Actions / Logic
Query services; hide archived by default.

## Validation
- none

## Acceptance Tests
- Sorting deterministic
- Empty shows CTA

## Design Tokens
- Title: Playfair Display 24/600
- Body: Inter 14–16
- Accent: #C9A24D
- Background: #F6F6F8
- Divider: #E7E7EC

