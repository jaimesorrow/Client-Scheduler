# App Store / Google Play Reviewer Notes (Mapped to Tickets)

## Product
Clientè — Provider Scheduling App (Owner + Staff)

## Core user journey (for review)
1) Sign up / sign in (Tickets 2–4)
2) Complete onboarding (Tickets 7–10)
3) Add services + clients (Tickets 31 + 16)
4) Create an appointment (Tickets 19–22)
5) Manage appointment lifecycle (Tickets 23–28)

## Access & authentication disclosure
- The app requires authentication to access core functionality.
- Reviewers should create an account via **Sign Up** (Ticket 4) or use a test account if provided by the developer at submission time.

> Do **not** hardcode credentials in the app. Provide test credentials only in store console “Review notes”.

## Owner-only areas (role guard)
- Availability: Tickets 37–39
- Analytics: Tickets 40–41
- Settings compliance actions: Tickets 43–44
If a non-owner account navigates to these routes, the app shows a clear **Access Denied** state via **System Hub** (Ticket 42).

## Data handling disclosures (minimum)
### Delete account (Ticket 44)
Delete screen includes:
- “Permanent and cannot be undone.”
- “Deletes your Clientè account and business data.”
- “Some records may be retained if required by law.” (future-proof language)

### Logout (Ticket 43)
Logout clears local session + cached sensitive data and returns to welcome.

## Privacy / Legal
- Links to Privacy Policy and Terms must be accessible from Settings (recommended within Settings Home list).
- If a dedicated legal viewer screen is added later, it should be reachable from `/settings`.

## Sensitive content / restricted services
Clientè is a general scheduling tool. It does not advertise or facilitate prohibited services within the app UI. (Developer must ensure store listing and in-app content remain compliant.)

## Crash-safe behavior
Any unexpected error routes to System Hub “Error” mode (Ticket 42) with recovery CTAs and no sensitive stack traces.

## Ticket mapping quick reference
- Auth: 1–6
- Onboarding: 7–10
- Dashboard: 11–13
- Clients: 14–18
- Appointments: 19–28
- Services: 29–33
- Templates: 34–36
- Availability: 37–39 (owner-only)
- Analytics: 40–41 (owner-only)
- System/Settings compliance: 42–44
