# Developer Acceptance Checklists (Per Ticket)

Use this as QA gating. A ticket is “Done” only if **all** checks pass.

> Conventions:
- “Routes correctly” means navigation target matches spec and back stack is safe.
- “Guards” must route to System Hub permission mode for restricted areas.

## 1–6 Auth
- **01 Splash/Boot:** routes correctly for authed/unauthed/onboarding; init failure recovers via System Hub error mode.
- **02 Welcome:** both CTAs route correctly.
- **03 Sign In:** validation disables CTA; wrong creds show generic error; success persists session and lands dashboard.
- **04 Sign Up:** consent required; creates UserProfile + BusinessSettings; routes onboarding.
- **05 Reset:** generic success; no enumeration; returns to login.
- **06 Verify:** resend works; verified routes forward.

## 7–10 Onboarding
- **07 Business:** business name required; timezone persists and affects date math.
- **08 Brand:** logo upload validates type/size; skip still progresses.
- **09 Hours:** invalid ranges blocked; buffers saved; impacts slots.
- **10 Complete:** onboardingComplete flips true; dashboard becomes default landing.

## 11–18 Dashboard + Clients
- **11 Dashboard:** today range correct in timezone; empty state shows CTA; tapping appointment opens detail.
- **12 Search:** debounce; tab preserves query; routes correct.
- **13 Activity:** derives from audit; tap routes to appointment.
- **14 Clients List:** archived hidden by default; filters work.
- **15 Client Detail:** contact buttons only when available; new appointment preselects client.
- **16 Add Client:** validations; return param honored.
- **17 Edit Client:** changes persist; blocked client excluded from booking flow by default.
- **18 Archive/Restore:** archived removed from lists and booking pickers.

## 19–28 Appointments
- **19 Select Client:** selection persists draft; add client return works.
- **20 Select Services:** >=1 required; totals update live.
- **21 Choose Time:** slot engine respects hours/breaks/buffers/blackouts/overlaps; conflict handled.
- **22 Review/Confirm:** creates appointment + audit created; conflict returns to time screen.
- **23 Detail:** actions reflect status; every mutation appends audit.
- **24 List:** filters + search work; open detail works.
- **25 Reschedule:** audit includes from/to; conflicts handled.
- **26 Cancel:** reason required; status + audit updated.
- **27 No-show:** status + audit updated.
- **28 Complete:** status + audit updated.

## 29–36 Services + Templates
- **29 Services List:** sorting deterministic; add works.
- **30 Service Detail:** shows fields; archive/restore visible.
- **31 Add Service:** duration/price validation; return param honored.
- **32 Edit Service:** edits persist; does not retroactively change existing appointment totals.
- **33 Archive:** hidden from service selector by default.
- **34 Templates:** empty state; create/edit/use navigation.
- **35 Template Edit:** name + >=1 service required.
- **36 Use Template:** services prefilled; creates appointment with templateId + audit.

## 37–41 Availability + Analytics (Owner-only)
- **37/38/39:** staff blocked; changes affect slots.
- **40/41:** staff blocked; metrics correct for range; empty states handled.

## 42–44 System + Settings subroutes
- **42 System Hub:** permission mode clear; error mode recovers; no sensitive traces; escape hatch works.
- **43 Logout:** clears secure storage and caches; clears nav stack; routes welcome.
- **44 Delete account:** typed confirm + reauth required; server deletion invoked; sign-out occurs; cannot re-login.
