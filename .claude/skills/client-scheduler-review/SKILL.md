---
name: client-scheduler-review
description: Reviews diffs in this repo (Client-Scheduler / "Clientè", a Flutter + Firebase multi-tenant appointment-booking app) against its actual business-scoping, route-authorization, booking-conflict, and invitation-token invariants, on top of ordinary correctness review. Use this instead of a generic code review for any change touching lib/data/repos, lib/data/models/appointment.dart or invitation.dart, lib/app/app_router.dart, lib/screens/booking_landing_screen.dart, or any screen currently marked as a TODO stub being filled in.
---

# Client-Scheduler code review

This is a Flutter app (Dart, Provider for state, go_router for navigation) backed directly by
Firebase (`firebase_auth` + `cloud_firestore` — no separate backend server lives in this repo).
It's a multi-tenant scheduling tool: every business's clients, services, and appointments live under
`businesses/{businessId}/...` subcollections, and a client-facing, unauthenticated booking flow is
reached through single-use invitation links. The checks below are grounded in what's actually
implemented today (`lib/data/**`, `lib/app/app_router.dart`, `lib/screens/booking_landing_screen.dart`)
rather than generic advice. Review diffs against this list in addition to normal correctness,
readability, and null-safety review.

## 1. Business-scoping (multi-tenant isolation)

- `ClientRepository`, `ServiceRepository`, `AppointmentRepository`, and `TemplateRepository` all key
  their Firestore collection off an explicit `businessId` argument
  (`businesses/{businessId}/clients`, `.../appointments`, etc.). Flag any new query, cache, or helper
  that reads/writes one of these collections without threading `businessId` through, or that derives
  it from anything other than the caller-supplied value (e.g. trusting a client-provided document
  field instead of the path segment).
- `InvitationRepository` is the one exception: invites live in a **root-level** `invites` collection
  (not nested under a business) specifically so an unauthenticated client can look one up by token
  without knowing the business ID (see the doc comment at the top of
  `lib/data/repos/invitation_repository.dart`). Don't flag this as an inconsistency — but do flag any
  *other* new root-level collection that should have been business-scoped instead.
- There is no `firestore.rules` file in this repo, so business-to-business data isolation is enforced
  entirely server-side, outside what's reviewable here. Don't assume a new repository method is safe
  just because it compiles — call out anywhere a new query could plausibly read across businesses
  (e.g. a collection-group query, or a lookup keyed only by a client-supplied ID) since there's no
  local rules file to cross-check it against.

## 2. Route authorization (`lib/app/app_router.dart`)

- All auth/onboarding/role gating lives in **one place**: the `redirect` callback on the single
  `GoRouter` in `AppRouter`. There is no per-screen guard — a screen's own `build()` never checks
  `FirebaseAuth.instance.currentUser` or `UserProfile.role`. This means:
  - A new owner-only route must be added to the `ownerOnly` prefix check (currently
    `/availability`, `/analytics`, `/settings`) or it will be reachable by any signed-in staff
    account regardless of role. Flag a new settings/analytics/availability-style screen whose path
    doesn't fall under one of those three prefixes.
  - The only route excluded from the "must be signed in" check is `path.startsWith('/book/')` (the
    public invitation-booking flow). Flag any new unauthenticated-by-design route that isn't added
    to that `loggingIn || path == '/splash' || path.startsWith('/book/')` condition, and equally flag
    any change that widens that condition to cover routes that should require auth.
- `_fastRoute` (no page transition, used for the clients/appointments/services list-heavy routes) vs
  `_defaultRoute` is a deliberate perf choice (see the perf commit history) — don't "fix" a route back
  to `_defaultRoute` without a stated reason.

## 3. Booking flow correctness (`lib/screens/booking_landing_screen.dart` + `AppointmentRepository`)

- `BookingLandingScreen._book()` and `AppointmentRepository.create()` currently perform **no overlap
  check** against a business's existing appointments, and **no cross-check** against working hours or
  blackout dates — those live in `AvailabilityHoursScreen`/`AvailabilityBlackoutsScreen`, which are
  still `TODO: Implement screen content per spec.` stubs. If a diff adds real availability data or
  fills in either availability screen, flag it if the booking-creation path (this screen, or any
  owner-side "new appointment" screen once implemented) still doesn't consult it before writing an
  appointment — that's the double-booking gap this app is currently exposed to.
- Date/time is built from `showDatePicker`/`showTimePicker` results with a plain `DateTime(...)`
  constructor (device-local wall-clock time), then stored via `Timestamp.fromDate`. There is no
  timezone field anywhere (`BusinessSettings` has only `businessId`/`onboardingComplete`) and no
  `.toUtc()`/explicit-offset handling in the codebase. Flag any new code that assumes a client and a
  business can be in different timezones and still line up correctly — the infrastructure to support
  that doesn't exist yet, so either the assumption is wrong or it needs a companion timezone field.
- `BookingLandingScreen._book()` sets the created `Appointment.clientId` to `inv.clientEmail` (a raw
  email string), not a real `Client` document ID from `ClientRepository`. Flag any new code that
  assumes `appointment.clientId` always round-trips through `ClientRepository.get(businessId, id)` —
  today it doesn't for invitation-originated bookings.
- `Invitation` gating (`isExpired`, `isValid`, and the `status` checks for `revoked`/`accepted`) all
  happens client-side in `BookingLandingScreen.build()` before showing the booking form. If a diff
  touches invitation status transitions or `InvitationRepository.accept`/`revoke`, verify those three
  states (revoked, expired, already-accepted) are still all checked before a new appointment can be
  created — don't let a refactor collapse them into a single "is pending" check that silently drops
  one case.

## 4. Data model consistency

- `Appointment.status` is a free `String` (default `'scheduled'`; the booking flow uses
  `'pending_client'`) with no enum and no exhaustive switch anywhere in the codebase — unlike
  `Invitation.status`, which is a proper `InvitationStatus` enum with an explicit `parseStatus`
  fallback-to-`pending` mapping. Flag a new status string introduced without checking existing
  read-sites (`appt_detail_screen.dart`, `appts_list_screen.dart`, etc.) for whether they need to
  handle it, since a typo'd status string fails silently rather than at compile time.
- `fromMap`/`toMap` pairs in `lib/data/models/*.dart` do their own null-coalescing per field (e.g.
  `(data['status'] ?? 'scheduled') as String`). Flag a new model field added to `toMap()` without a
  matching default/cast in `fromMap()`, or vice versa — there's no shared serialization helper to
  catch the mismatch for you.

## 5. Stub screens being filled in

44 of the 73 files under `lib/screens/` are still literal placeholders (`ScreenScaffold` wrapping
`Text('TODO: Implement screen content per spec.')`) — check which stub a diff is turning into a real
screen and hold it to the same standard as the already-implemented ones:

- It should use `ScreenScaffold` and the tokens in `lib/theme/tokens.dart` (`AppColors`, `AppSpacing`,
  `AppRadii`, `AppTextStyles`) rather than introducing raw colors/spacing literals — every currently
  implemented screen follows this convention.
- It should route data through the relevant repository (`ClientRepository`, `ServiceRepository`,
  `AppointmentRepository`, etc.) rather than holding a local mock list, and should pass `businessId`
  through per section 1.
- If it's one of the owner-only surfaces (availability, analytics, settings), confirm its route is
  covered by the `ownerOnly` check in `app_router.dart` (section 2) — a newly-implemented screen is
  the moment this is easiest to get wrong.

## 6. Test coverage

There is no meaningful automated test suite yet — `test/widget_test.dart` is still the unmodified
default Flutter counter-app test. Don't assume any of the invariants above are protected by CI; if a
diff adds real logic to a previously-stub screen or to a repository (especially anything touching
conflict detection, invitation validation, or `businessId` scoping), say explicitly that it has no
test coverage rather than assuming the existing suite would catch a regression, and suggest a
`flutter_test`/mocked-Firestore unit test for the new logic where practical.

## Running checks

```
scripts/flutterw analyze
scripts/flutterw test
```

If the local Flutter SDK (`.flutter/flutter`, invoked via `scripts/flutterw`) isn't available in this
environment, say so explicitly instead of claiming the build or analyzer was run.

## Output

Report findings the same way `/code-review` does: most-severe first, each with file:line, a
one-sentence defect summary, and a concrete failure scenario. A business-scoping leak (section 1) or
a route-authorization gap (section 2) is at least as severe as an equivalent plain correctness bug in
this codebase — those are the two places a bug here means one business's data or actions leaking to
another.
