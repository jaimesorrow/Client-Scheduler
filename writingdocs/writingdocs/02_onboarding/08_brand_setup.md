# Ticket 08 — Brand Setup
Route: `/onboarding/brand`
Guard: owner

## Purpose
Optional logo upload and brand preview (accent locked in MVP).

## Fields
- Logo image (optional: png/jpg)
- Accent (locked #C9A24D)

## UI Layout
- Title: “Brand”
- Logo uploader + preview
- Typography preview
- CTA: Continue
- Secondary: Skip

## States
- idle
- uploading
- invalid file banner
- saving

## Actions / Logic
Upload logo to storage → save `logoUrl`; continue to `/onboarding/hours`. Skip saves defaults.

## Validation
- none

## Acceptance Tests
- Upload persists
- Skip still continues

## Design Tokens
- Title: Playfair Display 24/600
- Body: Inter 14–16
- Accent: #C9A24D
- Background: #F6F6F8
- Divider: #E7E7EC

