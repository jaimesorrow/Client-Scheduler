# Ticket 12 — Global Search
Route: `/search`
Guard: authed

## Purpose
Search across clients, services, appointments.

## Fields
- Query string

## UI Layout
- Search input
- Tabs: Clients/Appointments/Services
- Results list

## States
- typing debounce
- empty results
- error banner

## Actions / Logic
MVP: filter cached lists and/or prefix search; route to entity detail on selection.

## Validation
- none

## Acceptance Tests
- Switching tabs preserves query
- Result routes correctly

## Design Tokens
- Title: Playfair Display 24/600
- Body: Inter 14–16
- Accent: #C9A24D
- Background: #F6F6F8
- Divider: #E7E7EC

