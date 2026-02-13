# Ticket 05 — Forgot Password
Route: `/reset`
Guard: public

## Purpose
Send password reset email.

## Fields
- Email* (format)

## UI Layout
- Title: “Reset password”
- Email input
- CTA: Send reset link
- Link: Back to sign in

## States
- idle
- loading
- success message
- error banner

## Actions / Logic
Call auth reset; always show generic success for security.

## Validation
- email format

## Acceptance Tests
- Valid email submits
- Success message shown
- Back link works

## Design Tokens
- Title: Playfair Display 24/600
- Body: Inter 14–16
- Accent: #C9A24D
- Background: #F6F6F8
- Divider: #E7E7EC

