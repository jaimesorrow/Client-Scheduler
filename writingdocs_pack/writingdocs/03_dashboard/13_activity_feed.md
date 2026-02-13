# Ticket 13 — Activity Feed
Route: `/activity`
Guard: authed

## Purpose
Audit-derived activity timeline for trust and accountability.

## Fields
- Optional filters

## UI Layout
- Header + filter chips
- Timeline list newest-first

## States
- loading
- empty
- error

## Actions / Logic
Derive from Appointment.audit events; tap item routes to appointment detail.

## Validation
- none

## Acceptance Tests
- Status changes appear in feed after refresh

## Design Tokens
- Title: Playfair Display 24/600
- Body: Inter 14–16
- Accent: #C9A24D
- Background: #F6F6F8
- Divider: #E7E7EC

