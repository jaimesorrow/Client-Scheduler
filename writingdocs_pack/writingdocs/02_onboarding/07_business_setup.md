# Ticket 07 — Business Setup
Route: `/onboarding/business`
Guard: owner

## Purpose
Collect business identity and timezone (required for scheduling).

## Fields
- Business name* (required)
- Timezone* (default America/Anchorage)
- Currency (USD read-only MVP)
- City/State (optional)

## UI Layout
- Title: “Your business”
- Inputs + timezone dropdown
- Step indicator: 1 of 3
- CTA: Continue

## States
- loading existing
- saving
- error banner

## Actions / Logic
Save BusinessSettings fields then route `/onboarding/brand`.

## Validation
- business name required

## Acceptance Tests
- Cannot continue without business name
- Timezone persists and is used for all date math

## Design Tokens
- Title: Playfair Display 24/600
- Body: Inter 14–16
- Accent: #C9A24D
- Background: #F6F6F8
- Divider: #E7E7EC

