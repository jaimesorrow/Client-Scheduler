---
name: data-model
description: Reference for Client-Scheduler's Firestore data model — every model class, its exact fields/types, its collection path, and the repository methods that read/write it. Use for questions like "what's the structure of Appointment", "how do I query a business's clients", "what fields does Invitation have", "entity diagram", "where is X stored in Firestore".
---

# Client-Scheduler data model

All models live in `lib/data/models/*.dart` (plus `lib/data/business_settings.dart` and
`lib/data/user_profile.dart`); all persistence goes through `lib/data/repos/*.dart` (plus
`lib/data/business_settings_repository.dart` / `lib/data/user_repository.dart`) using
`cloud_firestore` directly — no ORM.

## Primary entities

- `Appointment` — `id, clientId (String), serviceIds (List<String>), startAt/endAt (DateTime,
  stored as Timestamp), status (String, default 'scheduled'), notes (String?),
  totalDurationMin (int?), totalPriceCents (int?)`.
- `Client` — `id, fullName (String), phone/email/notes (String?), tags (List<String>),
  isArchived (bool, default false)`.
- `Service` — `id, name (String), durationMinutes (int), priceCents (int?), description (String?),
  isActive (bool, default true)`.
- `Template` — `id, name (String), serviceIds (List<String>), defaultNotes (String?),
  defaultDurationMinutes/defaultPriceCents (int?)`.
- `Invitation` — `id, businessId, clientName, clientEmail (String), clientPhone/message (String?),
  serviceIds (List<String>), status (InvitationStatus enum: pending/accepted/revoked/expired),
  expiresAt/createdAt (DateTime), acceptedAt (DateTime?)`.
- `BusinessSettings` — `businessId, onboardingComplete (bool)`.
- `UserProfile` — `uid, role (String, default 'staff'), businessId (String), onboardingComplete (bool)`.

## Relationships (Firestore paths)

- `businesses/{businessId}/clients/{id}`, `.../services/{id}`, `.../appointments/{id}`,
  `.../templates/{id}` — all four are scoped under the owning business.
- `invites/{token}` — root-level, deliberately **not** business-scoped (see doc comment in
  `invitation_repository.dart`) so an unauthenticated client can look one up by token alone;
  `businessId` is a field on the document instead of the path.
- `users/{uid}` and `businessSettings/{businessId}` — both root-level, one doc per user/business.
- No field is a live Firestore reference type; every cross-entity link (`clientId`, `serviceIds`,
  `businessId`) is a plain string ID resolved via a repository `.get()` call.

## Validation rules

- Every `fromMap` does its own per-field null-coalescing at the call site (e.g.
  `(data['status'] ?? 'scheduled') as String`) — there is no shared parsing helper, so a new field
  needs both a `toMap()` write and a defaulted `fromMap()` read.
- `Appointment.fromMap` is the one exception that throws: missing `startAt`/`endAt` raises a
  `StateError` rather than defaulting.
- `Invitation.status` is the only enum-backed field; `parseStatus` falls back to `pending` for any
  unrecognized string. `Appointment.status` is a free string with no enum.

## Query patterns

- `list(businessId)` on each business-scoped repo; `Client`/`Service` also expose
  `listArchived(businessId)` (Client: `isArchived == true`; Service: `isActive == false`).
- `Client.list`/`Service.list` default to excluding archived/inactive via a `where` clause plus an
  `orderBy` (`fullName`, `name`); `Appointment.list` orders by `startAt` ascending.
- `get(businessId, id)` returns `null` on a missing doc (never throws) across all repos.
- `InvitationRepository.get(token)` looks up by document ID directly (the token IS the doc ID);
  `InvitationRepository.list(businessId)` filters `where('businessId', isEqualTo: businessId)`.

## Mutations

- `create` — `ClientRepository`/`ServiceRepository`/`AppointmentRepository` use `.add()` (auto-ID);
  `InvitationRepository.create` pre-allocates a doc ref to return its token before writing.
- `update` — full-document `.update(model.toMap())`, no partial-field variants.
- Soft-delete only: `Client.archive`/`Service.archive` flip a boolean field; nothing is ever
  hard-deleted. `Invitation.revoke`/`.accept` write a status string plus a server timestamp.
