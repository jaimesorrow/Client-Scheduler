# Ticket 37 — Availability Overview
Route: `/availability`
Guard: owner-only

## Purpose
Owner command center for working hours, buffers, and time off.

## Fields
- none

## UI Layout
- Summary cards
- Buttons: Edit hours, Time off

## States
- loading
- error

## Actions / Logic
Read BusinessSettings hours/buffers/blackouts; link to editors.

## Validation
- none

## Acceptance Tests
- Staff blocked with permission denied
- Changes impact slot engine

## Design Tokens
- Title: Playfair Display 24/600
- Body: Inter 14–16
- Accent: #C9A24D
- Background: #F6F6F8
- Divider: #E7E7EC

