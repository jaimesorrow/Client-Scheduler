# Ticket 33 — Archive/Restore Service
Route: `/services/:id/archive`
Guard: authed

## Purpose
Soft archive service; hide in selectors.

## Fields
- none

## UI Layout
- Confirm UI
- Archive/Restore CTA

## States
- saving
- error

## Actions / Logic
Set archived flag; update lists.

## Validation
- none

## Acceptance Tests
- Archived removed from selectors

## Design Tokens
- Title: Playfair Display 24/600
- Body: Inter 14–16
- Accent: #C9A24D
- Background: #F6F6F8
- Divider: #E7E7EC

