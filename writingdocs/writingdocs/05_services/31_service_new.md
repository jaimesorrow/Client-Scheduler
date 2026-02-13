# Ticket 31 — Add Service
Route: `/services/new`
Guard: authed

## Purpose
Create new service offering.

## Fields
- Name*
- Price*
- Duration*
- Description (optional)

## UI Layout
- Inputs + CTA Save

## States
- saving
- error

## Actions / Logic
Create Service. Return param honored.

## Validation
- name required
- price >= 0
- duration >= 15

## Acceptance Tests
- Save persists
- Return param works

## Design Tokens
- Title: Playfair Display 24/600
- Body: Inter 14–16
- Accent: #C9A24D
- Background: #F6F6F8
- Divider: #E7E7EC

