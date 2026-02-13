# Ticket 30 — Service Detail
Route: `/services/:id`
Guard: authed

## Purpose
View service details and archive/restore.

## Fields
- none

## UI Layout
- Title + price + duration
- Description
- Actions: Edit / Archive

## States
- loading
- missing → system error

## Actions / Logic
Archive toggles service archived flag.

## Validation
- none

## Acceptance Tests
- Archive hides from selectors

## Design Tokens
- Title: Playfair Display 24/600
- Body: Inter 14–16
- Accent: #C9A24D
- Background: #F6F6F8
- Divider: #E7E7EC

