---
name: flutter-widgets
description: Reference for Client-Scheduler's Flutter app structure — file layout, widget naming/organization, state management, navigation, and testing conventions. Use for questions like "where does this screen go", "should this be Stateful or Stateless", "how does state get to this widget", "how is navigation wired", "what's the testing setup".
---

# Client-Scheduler Flutter conventions

## File structure

- `lib/app/app_router.dart` — the single `GoRouter` instance and all route definitions.
- `lib/data/models/*.dart` — plain data classes (`fromMap`/`toMap`, no Firestore imports beyond
  `Timestamp`). `lib/data/repos/*.dart` — one `*Repository` class per model, holding the
  `FirebaseFirestore` reference.
- `lib/data/*_provider.dart` — `ChangeNotifier` providers (`UserProfileProvider`,
  `BusinessSettingsProvider`) that wrap a repository for app-wide auth/business state.
- `lib/screens/*.dart` — one file per route, named `<feature>_<action>_screen.dart`
  (e.g. `appt_new_time_screen.dart`, `client_archive_screen.dart`), each exposing exactly one
  `*Screen` widget. `lib/widgets/` — shared cross-screen widgets (currently just
  `screen_scaffold.dart`). `lib/theme/tokens.dart` — `AppColors`/`AppSpacing`/`AppRadii`/
  `AppTextStyles`; every screen uses these instead of raw literals.

## Widget naming & organization

- Screens with no local mutable UI state (list/detail views still backed by inline TODO data, e.g.
  `ApptsListScreen`) are `StatelessWidget`. Screens with pickers, forms, or async submit flows
  (`BookingLandingScreen`, `ClientEditScreen`, `ServiceNewScreen`) are `StatefulWidget`, with the
  private `_<Name>State` holding controllers/repo instances/loading flags.
- 44 of 73 screens are still literal stubs: `ScreenScaffold` wrapping
  `Text('TODO: Implement screen content per spec.')` — match that shape until real content lands.

## State management

- No Riverpod/Bloc: app-wide state is two `ChangeNotifier`s (`UserProfileProvider`,
  `BusinessSettingsProvider`) registered with `package:provider` and read via
  `context.read<T>()`/`context.watch<T>()`. Screen-local state is plain `setState` inside a
  `StatefulWidget` — see `BookingLandingScreen`'s `_isSubmitting`/`_submitted`/`_error` fields.
- Data fetched per-screen (not cached in a provider) is loaded directly from a `*Repository`
  instance created in `initState`/as a field, then awaited via `FutureBuilder` (see
  `BookingLandingScreen._load`).

## Navigation

- `lib/app/app_router.dart`: all routes are declared via two helpers, `_defaultRoute` (normal page
  transition) and `_fastRoute` (`NoTransitionPage`, used for list-heavy sections: clients,
  appointments, services, invitations) — preserve that choice rather than "fixing" it back to
  `_defaultRoute`. All auth/onboarding/role redirect logic is centralized in the single `redirect`
  callback, not per-screen guards.

## Testing patterns

- `test/widget_test.dart` is still the unmodified default Flutter counter-app smoke test — there is
  no real widget or repository test coverage yet. A new test should use `flutter_test` and, since
  repos call `FirebaseFirestore.instance` directly with no interface/DI seam, either inject a fake
  `FirebaseFirestore` via each repo's optional constructor param or use `fake_cloud_firestore`.
