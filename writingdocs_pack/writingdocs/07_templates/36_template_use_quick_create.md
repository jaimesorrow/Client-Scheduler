# Ticket 36 — Use Template (Quick Create)
Route: `/templates/:id/use`
Guard: authed

## Purpose
Streamlined appointment creation using template services.

## Fields
- Client selection
- Slot selection
- Optional notes (prefilled)

## UI Layout
- 3-step flow: client → time → review
- Compact review
- Confirm

## States
- template loading
- slot loading
- conflict
- saving

## Actions / Logic
Prefill draft from template; confirm creates appointment with templateId and audit created_from_template.

## Validation
- same as appointment create

## Acceptance Tests
- Flow completes with correct services
- Audit includes templateId

## Design Tokens
- Title: Playfair Display 24/600
- Body: Inter 14–16
- Accent: #C9A24D
- Background: #F6F6F8
- Divider: #E7E7EC

