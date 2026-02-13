# Ticket 45 — Contact Support
Route: `/support/contact`
Guard: authenticated

## Purpose
Send support message (email link).

## Design baseline for all screens
### Header block
- Line 1: Screen title — `t.h1` (Playfair 28/600)
- Line 2 (optional): Subtitle — `t.bodyMuted` (Inter 14/400)

### Primary actions
- Primary button: `PrimaryButton` — background `c.gold`, label `t.button`
- Secondary button (if needed): `SecondaryButton` — border `c.gold`, label `t.button`
- Destructive actions: red `c.danger` only on confirmation screens

### States (required)
- Loading: skeleton + disabled CTAs
- Empty: `EmptyState` with single CTA
- Error: inline message + “Try again”

## Typography per line (on this screen)
- Title: “Contact support” `t.h1`

## Components
- Form: subject, message
- Shows support email

## Buttons / actions (every button)
- Primary: “Send”
- Secondary: “Cancel”

## States
- Loading
- Error

## Business logic
- Uses mailto or in-app messaging later

## Analytics events
- support_send

## Acceptance checklist
- [ ] All labels match spec
- [ ] CTAs disabled when invalid/loading
- [ ] Empty state shown when no data
- [ ] Error state recoverable
- [ ] Accessibility: contrast + tap targets + focus order
- [ ] Route guarded correctly (if required)
