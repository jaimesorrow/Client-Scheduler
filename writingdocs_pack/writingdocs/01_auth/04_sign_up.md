# Ticket 04 — Sign Up
Route: `/signup`
Guard: public

## Purpose
Create owner account and initialize BusinessSettings.

## Fields
- Full name* (min 2 chars)
- Email* (format)
- Password* (min 8)
- Confirm password* (match)
- Consent checkbox* (Terms + Privacy)

## UI Layout
- Title: “Create account”
- Inputs + helpers
- Consent checkbox with links
- Primary CTA: Create account

## States
- idle
- loading
- error banner (email used/weak password/consent missing)

## Actions / Logic
Create auth user → create `UserProfile{role:'owner', businessId}` → create `BusinessSettings{onboardingComplete:false, accent:'#C9A24D'}` → route `/onboarding/business`.

## Validation
- all required fields valid
- consent required

## Acceptance Tests
- Consent unchecked blocks submit
- Successful sign up always routes to onboarding

## Design Tokens
- Title: Playfair Display 24/600
- Body: Inter 14–16
- Accent: #C9A24D
- Background: #F6F6F8
- Divider: #E7E7EC

