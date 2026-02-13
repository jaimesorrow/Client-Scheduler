# Ticket 15 — Client Detail
Route: `/clients/:id`
Guard: authed

## Purpose
Client profile + contact shortcuts + appointment history.

## Fields
- none

## UI Layout
- Header: name + status
- Contact buttons
- Notes card
- History list
- Actions: New appointment/Edit/Archive

## States
- loading
- missing → system error

## Actions / Logic
New appointment preselects client and routes to service selection; history lists recent appointments.

## Validation
- none

## Acceptance Tests
- Contact buttons only show when data exists
- New appointment preselects client

## Design Tokens
- Title: Playfair Display 24/600
- Body: Inter 14–16
- Accent: #C9A24D
- Background: #F6F6F8
- Divider: #E7E7EC

