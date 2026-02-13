# Ticket 06 — Verify Email
Route: `/verify`
Guard: public

## Purpose
Optional gate if email verification is enforced.

## Fields
- none

## UI Layout
- Title: “Verify your email”
- Copy includes target email
- Primary: I’ve verified (refresh)
- Secondary: Resend email

## States
- idle
- loading refresh
- resend throttled banner
- verified success

## Actions / Logic
Resend triggers provider call; refresh checks verified flag; route to onboarding or dashboard accordingly.

## Validation
- none

## Acceptance Tests
- Resend works
- Verified routes forward

## Design Tokens
- Title: Playfair Display 24/600
- Body: Inter 14–16
- Accent: #C9A24D
- Background: #F6F6F8
- Divider: #E7E7EC

