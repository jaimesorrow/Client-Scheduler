# Ticket 03 — Sign In
Route: `/login`
Guard: public

## Purpose
Authenticate user into provider app.

## Fields
- Email (required)
- Password (required)

## UI Layout
- Title: “Sign in”
- Email input
- Password input with show/hide
- Link: Forgot password
- CTA: Sign in (disabled until valid)

## States
- idle
- loading
- error banner (invalid creds / network / rate limit)
- optional: requires verification → `/verify`

## Actions / Logic
Normalize email (trim/lowercase) → call auth signIn → store session → fetch UserProfile → route `/dashboard`.

## Validation
- email format
- password non-empty

## Acceptance Tests
- Invalid email keeps CTA disabled
- Wrong credentials show generic banner
- Success lands on Dashboard

## Design Tokens
- Title: Playfair Display 24/600
- Body: Inter 14–16
- Accent: #C9A24D
- Background: #F6F6F8
- Divider: #E7E7EC

