# Ticket 01 — Splash / Boot
Route: `/`
Guard: any

## Purpose
Initialize app, hydrate session + business settings, route safely.

## Fields
- none

## UI Layout
- Fullscreen logo lockup centered
- Optional footer version label (Caption)

## States
- loading (default)
- authed → `/dashboard`
- unauthed → `/welcome`
- init error → `/system` error mode

## Actions / Logic
1. Read secure storage: token + userId
2. If missing → `/welcome`
3. Validate token
4. Fetch `UserProfile(userId)` (role, businessId)
5. Fetch `BusinessSettings(businessId)`
6. If onboarding incomplete → `/onboarding/business`
7. Else → `/dashboard`
8. Any exception → system error state with escape to `/welcome`

## Validation
- none

## Acceptance Tests
- No token routes to Welcome
- Invalid token signs out and routes Welcome
- Onboarding incomplete routes to onboarding
- Init failure shows system error UI with recovery

## Design Tokens
- Title: Playfair Display 24/600
- Body: Inter 14–16
- Accent: #C9A24D
- Background: #F6F6F8
- Divider: #E7E7EC

