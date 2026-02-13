# Ticket 40 — Analytics Overview
Route: `/analytics`
Guard: owner-only

## Purpose
High-level KPIs for selected date range.

## Fields
- date range selection

## UI Layout
- KPI cards
- Range chips
- Tap to detail

## States
- loading
- empty
- error

## Actions / Logic
MVP: query appointments in range and compute counts client-side.

## Validation
- none

## Acceptance Tests
- Counts update when range changes
- Staff blocked

## Design Tokens
- Title: Playfair Display 24/600
- Body: Inter 14–16
- Accent: #C9A24D
- Background: #F6F6F8
- Divider: #E7E7EC

