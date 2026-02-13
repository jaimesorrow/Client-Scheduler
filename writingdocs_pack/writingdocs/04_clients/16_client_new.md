# Ticket 16 — Add Client
Route: `/clients/new`
Guard: authed

## Purpose
Create a new client.

## Fields
- Full name* (required)
- Phone (optional)
- Email (optional)
- Notes (optional)
- VIP toggle (optional)

## UI Layout
- Title: Add client
- Inputs
- CTA: Save client

## States
- saving
- duplicate warning (non-blocking)
- error banner

## Actions / Logic
Create Client; if `return` param exists navigate there, else to detail.

## Validation
- name required
- phone/email format if provided

## Acceptance Tests
- Save creates client and routes correctly
- Name required

## Design Tokens
- Title: Playfair Display 24/600
- Body: Inter 14–16
- Accent: #C9A24D
- Background: #F6F6F8
- Divider: #E7E7EC

