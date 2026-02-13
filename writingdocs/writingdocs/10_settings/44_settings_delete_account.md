# Ticket 44 — Settings: Delete Account
Route: `/settings/delete-account`
Guard: owner (recommended)

## Purpose
Store-compliant account deletion with clear disclosure, confirm gate, re-auth, server-side deletion, and sign-out.

## Fields
- Typed confirm phrase* (exact: DELETE)
- Re-auth* (password or provider reauth)
- Optional final acknowledgement checkbox (optional)

## UI Layout
- Title: Delete account
- Warning card
- Disclosure bullets
- Confirm input: type DELETE
- Re-auth block
- Destructive CTA: Delete permanently
- Secondary: Cancel

## States
- idle
- invalid gate
- reauth loading
- delete loading (blocking)
- success (routes welcome)
- error banner

## Actions / Logic
Require confirm phrase + reauth. Call server-authoritative function `deleteAccountAndBusiness(userId,businessId)` to recursively delete business data (clients/services/appointments/templates/settings) then sign out and clear caches.

## Validation
- confirm phrase must match
- reauth required
- must be owner to delete business workspace

## Acceptance Tests
- Cannot delete without typing DELETE
- Wrong password prevents deletion
- Successful deletion signs out and prevents re-login
- Data no longer accessible after deletion

## Design Tokens
- Title: Playfair Display 24/600
- Body: Inter 14–16
- Accent: #C9A24D
- Background: #F6F6F8
- Divider: #E7E7EC

