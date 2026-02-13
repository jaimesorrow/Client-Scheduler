# Clientè Master Build Checklist

Date: 2026-02-11
Scope: All documents shared in this workspace, combined into one verification checklist.

## 1) Brand + Design Tokens
- [ ] Accent color is `#C9A24D` only for primary CTAs and highlights
- [ ] Playfair Display used for headings
- [ ] Inter used for body/UI
- [ ] No hard-coded colors outside tokens
- [ ] Typography uses tokenized styles only
- [ ] Spacing uses 4/8/12/16/20/24/32 scale
- [ ] Radius uses 12 (cards), 16 (sheets), 999 (pills)

## 2) Route Map Coverage
- [ ] All spec routes implemented (Tickets 1–45)
- [ ] Owner-only guards enforce `/availability/*`, `/analytics/*`, `/settings/*`
- [ ] Crash-safe routing to `/dashboard` or `/system` for failures

## 3) Global UX Requirements
- [ ] Every screen has Loading, Empty, Error states
- [ ] Primary CTAs disabled when invalid/loading
- [ ] All destructive actions require confirmation
- [ ] Offline-ish behavior: graceful errors + retry, no crashes

## 4) Core Logic Requirements
- [ ] Appointment audit log created for create/cancel/complete/reschedule/no_show/notes_updated
- [ ] Role permissions block staff from owner-only pages
- [ ] Delete account flow is store-compliant and functional

## 5) Legal + Compliance
- [ ] Terms + Privacy accessible from auth and settings
- [ ] Delete account screen includes disclosure language and re-auth
- [ ] Logout clears local session and cached PII
- [ ] App disclosures aligned with store requirements

## 6) Analytics + Support
- [ ] Analytics screens only for owners
- [ ] Support Contact screen implements form + mailto

## 7) Acceptance Checklists
- [ ] Ticket-specific acceptance checklist passes
- [ ] Founder-level pre-launch drill passes

---

This checklist must be fully satisfied before launch.
