# Ticket 11 — Dashboard Home
Route: `/dashboard`
Guard: authed

## Purpose
Command center: today's appointments, quick stats, quick actions.

## Fields
- none

## UI Layout
- Header: Today + date
- KPI cards (Scheduled/Completed/Cancelled)
- Today list
- Quick actions row

## States
- loading skeleton
- empty state + CTA
- error banner

## Actions / Logic
Query appointments for today's date range (timezone-aware). Tap row to detail; CTA to new appointment.

## Validation
- none

## Acceptance Tests
- Empty state shows when none
- New appointment routes to Ticket 19

## Design Tokens
- Title: Playfair Display 24/600
- Body: Inter 14–16
- Accent: #C9A24D
- Background: #F6F6F8
- Divider: #E7E7EC

