# Ticket 27 — Mark No-Show
Route: `/appointments/:id/no-show`
Guard: authed

## Purpose
Mark missed appointment and audit.

## Fields
- Optional note

## UI Layout
- Confirm UI
- Destructive CTA Mark no-show
- Secondary Back

## States
- saving
- error

## Actions / Logic
Set status='no_show'; append audit {action:'no_show'}

## Validation
- none

## Acceptance Tests
- No-show appears in analytics counts
- Audit appended

## Design Tokens
- Title: Playfair Display 24/600
- Body: Inter 14–16
- Accent: #C9A24D
- Background: #F6F6F8
- Divider: #E7E7EC

