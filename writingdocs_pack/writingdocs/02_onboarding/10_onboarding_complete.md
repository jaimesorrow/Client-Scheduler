# Ticket 10 — Onboarding Complete
Route: `/onboarding/finish`
Guard: owner

## Purpose
Finalize onboarding and unlock dashboard.

## Fields
- none

## UI Layout
- Success icon
- Title: “You’re ready.”
- CTA: Go to dashboard

## States
- idle
- saving

## Actions / Logic
Set `BusinessSettings.onboardingComplete=true`; route `/dashboard`.

## Validation
- none

## Acceptance Tests
- Reopen app routes to dashboard

## Design Tokens
- Title: Playfair Display 24/600
- Body: Inter 14–16
- Accent: #C9A24D
- Background: #F6F6F8
- Divider: #E7E7EC

