# Clientè MVP Build Pack — Official Freeze (v1.0)

**Freeze Date:** 2026-02-05  
**Timezone:** America/Anchorage  
**Scope:** Provider app MVP (Owner + Staff). Client portal deferred to Phase 2.

## What’s included
- **Exact screen/ticket specs (1–44)** with routes, UI components, states, validations, permissions, and acceptance tests.
- **Design system tokens + component library**
- **Developer acceptance checklist** (per ticket)
- **Task board** (Firebase/Kotlin/Flutter) with dependencies + priorities
- **App Store / Google Play reviewer notes** mapped to tickets

## Roles
- **Owner:** full access
- **Staff:** limited access (blocked from Availability / Analytics / Settings owner-only areas)
- **Client:** not in MVP provider app

## Owner-only route guards
- `/availability/*`
- `/analytics/*`
- `/settings/*`

## Data Entities
- `Client`
- `Service`
- `Appointment`
- `Template`
- `BusinessSettings`

## Appointment audit logging
All appointment lifecycle changes append to `Appointment.audit[]`:
- created, rescheduled, cancelled, completed, no_show, notes_updated

## Tickets implemented (declared current state)
- ✅ Appointment creation flow: Tickets **19–22**
- ✅ Fixed: Add Client import typo (code-level)
- 📋 Full specs: Tickets **1–44** (this bundle)

---

## Directory map
See `writingdocs/`.
