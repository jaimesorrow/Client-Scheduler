# Ticket 35 — Create/Edit Template
Route: `/templates/new OR /templates/:id/edit`
Guard: authed

## Purpose
Define preset services and default notes for fast scheduling.

## Fields
- Template name* (required)
- ServiceIds* (>=1)
- Default notes (optional)

## UI Layout
- Name input
- Services multi-select
- Notes
- CTA Save

## States
- loading (edit)
- saving
- error

## Actions / Logic
Save Template {name, serviceIds, defaultNotes}.

## Validation
- name required
- >=1 service required

## Acceptance Tests
- Save persists and shows in list
- Invalid blocks submission

## Design Tokens
- Title: Playfair Display 24/600
- Body: Inter 14–16
- Accent: #C9A24D
- Background: #F6F6F8
- Divider: #E7E7EC
