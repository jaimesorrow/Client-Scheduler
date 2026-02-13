# Ticket 14 — Clients List
Route: `/clients`
Guard: authed

## Purpose
Client directory with search + filters + add.

## Fields
- Search query
- Filter: All/VIP/Archived

## UI Layout
- Header: Clients
- Search input
- Filter chips
- Client rows + badge
- FAB: + Add

## States
- loading
- empty
- error

## Actions / Logic
Query clients; hide archived unless filter; tap routes to detail; add routes to new.

## Validation
- none

## Acceptance Tests
- Archived hidden by default
- Search respects current filter

## Design Tokens
- Title: Playfair Display 24/600
- Body: Inter 14–16
- Accent: #C9A24D
- Background: #F6F6F8
- Divider: #E7E7EC

