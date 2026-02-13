codex# Clientè Technical Specification

**Version:** 0.1.0 (MVP)  
**Last Updated:** February 9, 2026  
**Status:** Development

---

## 1. EXECUTIVE SUMMARY

Clientè is a provider-first, compliance-ready SaaS application functioning as a deterministic system of record for service-based businesses. It centralizes client management, scheduling, payments, and policy enforcement with strict permission boundaries, immutable audit trails, and crash-safe error handling. The MVP supports provider authentication, service management, availability configuration, client management, appointment booking (provider-initiated and client-facing), and transactional payments with deposit/partial/full capture modes.

---

## 2. CORE ENTITIES & DATA MODEL

### 2.1 Entity Relationships

```
Provider (Owner)
  ├── owns Staff (multiple)
  ├── owns Services (multiple)
  ├── owns Client Contacts (multiple)
  ├── owns Appointments (multiple)
  ├── owns Payments (multiple)
  ├── owns BusinessSettings (singular)
  └── owns AuditLog (immutable)

Staff
  ├── belongs_to Provider
  ├── has Permissions (enum-based)
  └── can view/modify Appointments (if permitted)

Service
  ├── belongs_to Provider
  ├── defines duration_minutes
  ├── defines buffer_minutes_before
  ├── defines buffer_minutes_after
  ├── defines pricing (base_price, deposit_percentage)
  ├── defines cancellation_policy (hours_notice_required)
  └── has Availability (recurring or date-locked)

ClientContact
  ├── belongs_to Provider
  ├── has_many Appointments
  ├── has email, phone, name
  └── immutable creation_date

Appointment
  ├── belongs_to Service
  ├── belongs_to ClientContact
  ├── has current_state (enum)
  ├── has scheduled_at (datetime)
  ├── has created_by (Provider | ClientContact)
  ├── has created_at (timestamp)
  ├── has last_modified_at (timestamp)
  ├── has last_modified_by (Staff | Provider | System)
  └── has history (immutable events)

Payment
  ├── belongs_to Appointment
  ├── has amount_cents
  ├── has type (deposit | partial | full)
  ├── has status (pending | captured | failed | refunded)
  ├── has transaction_id (immutable, external reference)
  ├── has created_at (timestamp)
  ├── has captured_at (timestamp, null until captured)
  └── has failure_reason (null if successful)

BusinessSettings
  ├── belongs_to Provider
  ├── defines timezone
  ├── defines currency
  ├── defines notification_preferences
  ├── defines cancellation_policy_global (override default)
  └── defines working_hours (optional, per-day)

AuditLog (immutable, append-only)
  ├── belongs_to Provider
  ├── records action (string)
  ├── records actor_type (enum: owner | staff | client | system)
  ├── records actor_id (nullable for system)
  ├── records entity_type (appointment | payment | service | client)
  ├── records entity_id
  ├── records change_delta (before + after as JSON, nullable if only read)
  ├── records timestamp (server time, immutable)
  └── records request_id (for idempotency deduplication)
```

### 2.2 Permission Levels

```
ROLE: Owner (Provider)
  - Create, read, update, delete all entities (services, clients, staff, appointments)
  - View all payments and financial reports
  - Invite and manage staff
  - Modify BusinessSettings
  - Export client data
  - Cannot: delegate payment refunds to staff (owner-only)

ROLE: Staff
  - Permissions are granted as a bitfield (can be extended):
    - CAN_VIEW_CLIENTS
    - CAN_EDIT_CLIENTS
    - CAN_CREATE_APPOINTMENTS (owner-initiated only, not accept client bookings)
    - CAN_RESCHEDULE_APPOINTMENTS
    - CAN_CANCEL_APPOINTMENTS
    - CAN_VIEW_PAYMENTS (read-only)
    - CAN_VIEW_AVAILABILITY (read-only)
  - Staff cannot: refund payments, delete clients, invite other staff, modify settings
  
ROLE: Client
  - Can view own appointment (after creation/booking)
  - Can reschedule own appointment (if not within cancellation notice window)
  - Can cancel own appointment (if not within cancellation notice window)
  - Can receive notifications
  - Cannot: view other clients' data, access payments except own receipt, modify services
```

---

## 3. APPOINTMENT STATE MACHINE

### 3.1 Valid State Transitions

```
STATES:
  - pending_confirmation    (booking created, awaiting provider confirmation)
  - confirmed               (provider confirmed, client notified)
  - completed               (appointment occurred, marked by provider)
  - client_canceled         (client initiated cancel before deadline)
  - provider_canceled       (provider initiated cancel)
  - no_show                 (provider marked, client did not appear)
  - rescheduled             (state superseded by new appointment, reference retained)

TRANSITIONS:
  pending_confirmation → confirmed         (owner or staff action)
  pending_confirmation → provider_canceled (owner or staff action, before deadline)
  pending_confirmation → client_canceled   (client action, before cancellation_notice deadline)
  
  confirmed → completed                    (owner or staff action, on/after scheduled_at)
  confirmed → no_show                      (owner or staff action, after scheduled_at)
  confirmed → provider_canceled            (owner or staff action, before cancellation_notice deadline)
  confirmed → client_canceled              (client action, before cancellation_notice deadline)
  
  confirmed → {new appointment}            (reschedule: original marked rescheduled, new created)
  
  pending_confirmation → pending_confirmation (allowed: no state change, for idempotent retries)
  confirmed → confirmed                       (allowed: no state change, for idempotent retries)

INVALID / BLOCKED TRANSITIONS:
  - completed → * (terminal state)
  - no_show → * (terminal state)
  - client_canceled → * (terminal state)
  - provider_canceled → * (terminal state)
  - rescheduled → * (superseded, immutable)
  
  - Any state → pending_confirmation (non-reversible)
  - pending_confirmation → no_show (not allowed, must confirm first)

TIMEOUT RULES:
  - pending_confirmation older than 48 hours → auto-cancel to provider_canceled (optional, can be disabled per provider)
```

### 3.2 State Transition Logic & Refund Implications

| From State | To State | Refund Action | Conditions |
|---|---|---|---|
| pending_confirmation | provider_canceled | Full refund deposit | Before scheduled_at |
| confirmed | provider_canceled | Full refund deposit | Before scheduled_at + cancellation_notice_hours |
| confirmed | client_canceled | Refund per policy | Before scheduled_at + cancellation_notice_hours |
| confirmed | completed | No refund | After scheduled_at |
| confirmed | no_show | Refund per policy (0% to X%) | After scheduled_at, provider discretion |

---

## 4. PAYMENT STATE MACHINE & TIMING

### 4.1 Payment Capture Timing

```
SCENARIO 1: Deposit Required
  1. Appointment created → Payment.status = pending, amount = deposit_amount
  2. Client enters payment details (or staff enters on their behalf via provider UI)
  3. Stripe/Payment gateway initiated
  4. On success:
     - Payment.status = captured
     - Payment.captured_at = server_now()
     - Appointment transitions to confirmed (or stays pending if awaiting approval)
  5. On failure:
     - Payment.status = failed
     - Payment.failure_reason = "card_declined" | "insufficient_funds" | etc.
     - Appointment transitions to provider_canceled (or remains pending)

SCENARIO 2: Full Payment on Booking
  1. Appointment pending → Payment.status = pending, amount = full_service_price
  2. Client/staff enters payment
  3. Stripe initiated
  4. On success:
     - Payment.status = captured
     - Payment.captured_at = server_now()
     - Appointment → confirmed
  5. On failure:
     - Payment.status = failed
     - Appointment → provider_canceled (no booking without payment)

SCENARIO 3: Partial Payment + Balance Due Later
  1. Appointment created → Payment#1.status = pending, amount = partial_amount
  2. Partial payment captured → Payment#1.status = captured
  3. Appointment → confirmed
  4. At completion or day-before, Payment#2 triggered for balance
  5. If Payment#2 fails → Appointment remains completed, balance owed (invoice model, not in MVP)

SCENARIO 4: Cancellation Refund
  1. Appointment.state transitions to *_canceled
  2. Query associated Payment where status = captured
  3. Stripe refund initiated for captured amount
  4. On success:
     - Payment.status = refunded
     - Payment.refunded_at = server_now()
     - AuditLog records refund event
  5. On failure:
     - Payment.status = captured (no change)
     - Manual intervention required (owner notified)
```

### 4.2 Idempotency & Atomicity

```
IDEMPOTENCY KEY: request_id (UUID, client-provided or generated server-side)

Rule: Every payment API call must include request_id in header.

Flow:
  1. Client submits payment with request_id = "pay_abc123"
  2. Server generates idempotency_key = hash(payment_id + request_id)
  3. Check cache: if key exists → return cached response (do not retry external API)
  4. If not in cache:
     - Call Stripe with idempotency_key header
     - Stripe returns success or failure
     - Cache result for 24 hours
     - Return to client
  5. On retry (network timeout, user clicks again):
     - Same request_id → same idempotency_key
     - Cache hit returns previous result
     - Client never charged twice

DOUBLE-BOOKING PREVENTION:
  1. On appointment creation, acquire distributed lock on Service.id + scheduled_at window
  2. Check: no other confirmed/pending appointment in [scheduled_at - buffer_before, scheduled_at + duration + buffer_after]
  3. If conflict exists → reject with ConflictError
  4. If clear → create appointment
  5. Release lock
  6. Lock timeout: 5 seconds (fail-safe)
```

---

## 5. NOTIFICATION MATRIX

### 5.1 Events & Recipients

| Event | Trigger | Recipient | Channel | Content | Timing |
|---|---|---|---|---|---|
| **appointment.created** | Booking made (provider or client) | Provider | In-app + Email | "New booking: [Client Name], [Service], [Date/Time]" | Immediate |
| **appointment.pending** | Awaiting provider confirmation | Client | Email | "Your booking is pending confirmation. You'll receive a confirmation email once approved." | Immediate |
| **appointment.confirmed** | Provider confirms booking | Client | Email + SMS (optional) | "[Service] confirmed for [Date] at [Time]. Reply to reschedule or call [Provider Phone]." | Immediate |
| **appointment.rescheduled** | New date/time selected | Client | Email | "Your [Service] has been rescheduled to [New Date/Time]. Tap here to view details." | Immediate |
| **appointment.canceled** | Canceled (provider or client) | Both | Email | "[Service] on [Date] has been canceled. [Refund status if applicable]." | Immediate |
| **appointment.no_show** | Marked no-show | Client | Email | "We noticed you didn't arrive for your appointment on [Date]. Please reschedule." | +5 min after time |
| **appointment.completed** | Marked done | Client | Email + In-app | "Thanks for your visit! Rate your experience: [Link]. Need anything else?" | Immediate |
| **payment.captured** | Deposit/payment charged | Client | Email | "Payment of [Amount] received. Appointment confirmed for [Date]." | Immediate |
| **payment.failed** | Card declined, etc. | Client | Email + In-app | "Payment failed ([Reason]). Tap here to retry." | Immediate |
| **payment.refunded** | Refund processed | Client | Email | "Refund of [Amount] has been processed. You'll see it in 3-5 business days." | Immediate |
| **reminder.appointment_tomorrow** | Scheduled job 24h before | Client | Email + SMS (optional) | "Reminder: [Service] tomorrow at [Time]. Confirm you can make it." | 9:00 AM prev day |
| **reminder.appointment_1hour** | Scheduled job 1h before | Client | SMS (optional) | "[Service] starts in 1 hour at [Address/Virtual Link]." | 1h before |

### 5.2 Notification Preferences

Provider can disable per notification type:
- In BusinessSettings: `notification_preferences { appointment_created, appointment_confirmed, payment_received, ... }`
- Client can disable per category (in app settings, if implemented):
  - Allow appointment reminders? (yes/no)
  - Allow SMS? (yes/no)
  - Unsubscribe from all? (one-link)

---

## 6. ERROR HANDLING & CRASH-SAFE DEFAULTS

### 6.1 Critical Error Scenarios

```
SCENARIO: Payment Captured, Appointment Creation Fails
  1. Stripe charge succeeds, transaction_id assigned
  2. Database INSERT for appointment fails (network timeout, DB down)
  3. Client sees: "An error occurred. Please check your email or contact support."
  4. System:
     - Payment record created (pending insert retry)
     - Appointment not created
     - AuditLog entry: "payment.captured, appointment.create_failed"
  5. Recovery:
     - Owner notified: "Payment captured but appointment not created. Please contact client."
     - Client email sent within 5 min: "We received your payment but had a technical issue. Our team will contact you."
     - Staff can manually create appointment and link to existing payment.

SCENARIO: Appointment Canceled, Refund Fails
  1. Appointment state → provider_canceled
  2. Refund call to Stripe times out
  3. Payment.status remains captured (not refunded)
  4. Client sees: "Cancellation processed, but refund failed. We're working on it."
  5. System:
     - AuditLog: "appointment.canceled, refund.initiated, refund.failed"
     - Owner dashboard shows: "Pending Refund: [Client], [Amount]"
     - Retry job runs every 1 hour for 7 days
  6. If retry succeeds:
     - Payment.status → refunded
     - Client notified: "Refund processed."

SCENARIO: Network Timeout on Appointment State Update
  1. Client clicks "cancel appointment"
  2. Server receives request, begins state transition
  3. Network drops before response sent to client
  4. Client retries (same request_id via idempotency key)
  5. Server checks: appointment already in client_canceled state
  6. Returns cached response: "Cancellation confirmed."
  7. No duplicate state change.

SCENARIO: Crash During Availability Lock
  1. Service availability slot locked for booking
  2. Server process crashes before lock release
  3. Lock timeout: 5 seconds (automatic release)
  4. Next request acquires lock successfully
  5. Worst case: 5-second delay before slot available to other bookings.
```

### 6.2 Error Codes & User Fallbacks

| Error | HTTP | User Message | System Action |
|---|---|---|---|
| ConflictError (double book) | 409 | "This time slot is no longer available. Try [alternative times]." | Suggest nearby slots |
| PaymentFailedError | 402 | "Payment declined. Try another card or contact your bank." | Log failure, allow retry |
| AppointmentNotFoundError | 404 | "This appointment no longer exists." | Redirect to appointments list |
| PermissionDeniedError | 403 | "You don't have permission to do this." | Return to safe state (home/list) |
| ServerError | 500 | "Something went wrong. Please try again in a few moments." | Log to Sentry, notify ops |
| ValidationError | 400 | Show field-specific message (e.g., "Phone number invalid") | Highlight field, show hint |
| CancellationWindowClosedError | 400 | "Too late to cancel (cancellation deadline was [Date]). Contact [Provider]." | Show provider contact info |
| TimeZoneConflictError | 400 | "Date/time conflict with your timezone. Showing times in [Timezone]." | Auto-adjust display |

### 6.3 Default Recovery Path

```
When any error occurs:
  1. Client is NOT left on a blank screen or error page
  2. Instead:
     - Short, human-readable message is shown
     - "Go back" or "Home" button returns to last stable state
     - If applicable, a "Contact support" link is provided
     - Request ID is captured and shown (for support troubleshooting)
  3. In-app:
     - Broken state is logged to AuditLog
     - Owner dashboard shows: "Unresolved Issue: [Type], [Time], [Client if applicable]"
  4. Email:
     - If payment-related: client receives confirmation of what went wrong within 5 min
     - If appointment-related: provider notified of data inconsistency
```

---

## 7. RBAC & STAFF PERMISSION DETAILS

### 7.1 Permission Bitfield Example

```
Staff Member "Jane" (Permissions: 0b00110101)
  - Bit 0: CAN_VIEW_CLIENTS ✓
  - Bit 1: CAN_EDIT_CLIENTS ✗
  - Bit 2: CAN_CREATE_APPOINTMENTS ✓
  - Bit 3: CAN_RESCHEDULE_APPOINTMENTS ✓
  - Bit 4: CAN_CANCEL_APPOINTMENTS ✗
  - Bit 5: CAN_VIEW_PAYMENTS ✓
  - Bit 6: CAN_REFUND_PAYMENTS ✗
  - Bit 7: Reserved ✗

Jane can:
  ✓ View client records
  ✓ Create appointments (provider-initiated booking)
  ✓ Reschedule appointments
  ✓ View payment logs
  
Jane cannot:
  ✗ Edit client phone/email
  ✗ Cancel appointments
  ✗ Process refunds
```

### 7.2 Multi-Staff Conflict Resolution

```
Rule: If two staff members try to reschedule the same appointment simultaneously,
      first write wins. Second request receives:
      - HTTP 409 Conflict
      - Message: "This appointment was just modified. Refresh to see the latest state."
      - Client refreshes, sees new time
      - Second staff member sees updated state, can try again if needed

Rule: Only one staff member can modify an appointment at a time.
      (Achieved via appointment.last_modified_at + request_id dedup)
```

---

## 8. MVP SCOPE, OUT-OF-SCOPE & NON-GOALS

### 8.1 MVP In Scope (Priority 1)

```
✅ AUTHENTICATION
  - Email/password login (Firebase Auth)
  - Owner account creation
  - Staff account invitations
  - Client account creation (optional signup, or provider can create contact)
  - Session management + logout
  - Delete account + data export (GDPR/CCPA)

✅ PROVIDER MANAGEMENT
  - Provider profile (name, timezone, currency, logo/branding)
  - Staff management (invite, revoke, permission assignment)
  - Business settings (hours, policies, notification preferences)

✅ SERVICE MANAGEMENT
  - Create service (name, duration, buffer, pricing, deposit %)
  - Edit service (all fields)
  - Delete service (soft delete, hide from new bookings)
  - Service list view
  - Bulk duplicate service

✅ AVAILABILITY MANAGEMENT
  - Set weekly recurring availability (9 AM - 5 PM, Mon-Fri, timezone-aware)
  - Block time off (date-specific, override recurring)
  - View availability calendar (month view)
  - Bulk edit availability

✅ CLIENT MANAGEMENT
  - Create client contact (name, email, phone)
  - Edit client contact
  - List clients (with search, filter by tag/status)
  - View client appointment history
  - Soft-delete client (archive, not hard delete)

✅ APPOINTMENT MANAGEMENT
  - Provider creates appointment (select client, service, date/time)
  - Client self-books appointment (select service, pick available slot)
  - Confirm/approve pending appointment (provider action)
  - Reschedule appointment (provider or client, if not in cancellation window)
  - Cancel appointment (provider or client, with refund logic)
  - Mark completed (provider action)
  - Mark no-show (provider action)
  - View appointment list (calendar + list views)
  - Appointment detail view (status, payment, notes, history)

✅ PAYMENTS
  - Stripe integration (deposit only, minimum viable)
  - Capture deposit on appointment creation
  - Refund on cancellation (full or partial per policy)
  - Payment receipt/history (client + provider view)
  - Fee calculation and display (platform fee, payment processor fee)

✅ NOTIFICATIONS
  - Transactional email (appointment created, confirmed, canceled, payment received)
  - In-app notifications (badge count on home screen)
  - Email reminders (optional 24h before, 1h before)

✅ AUDIT LOG
  - All state changes logged (appointment state, payment status, client edits, staff actions)
  - Timestamps and actor field immutable
  - Accessible to owner (export as CSV)

✅ COMPLIANCE
  - Privacy policy (static page, in-app or linked)
  - Terms of service (static page, in-app or linked)
  - Delete account flow (remove personal data, retain audit trail)
  - No deceptive UX (fees transparent, no dark patterns)
  - App Store + Play Store ready
```

### 8.2 Out of Scope (Do Not Build in MVP)

```
❌ MARKETPLACE / DISCOVERY
  - No public provider directory
  - No reviews or ratings
  - No provider search or filtering
  - No marketplace listing

❌ MESSAGING / CHAT
  - No in-app messaging between client and provider
  - No SMS (email only for transactional)
  - Avoid moderation liability

❌ SUBSCRIPTION / RECURRING SERVICES
  - No recurring bookings or subscriptions
  - Each appointment is one-off

❌ INVOICING / ACCOUNTING EXPORT
  - No detailed invoice generation
  - No QuickBooks/Xero sync
  - No tax report generation

❌ ADVANCED PAYMENT MODES
  - No "pay later" / installment plans
  - No multiple payment methods per booking (one payment per appointment)
  - No gift cards or credits

❌ MULTI-LOCATION / MULTI-PROVIDER
  - One provider per account (MVP)
  - No multi-location chain support
  - No provider groups or networks

❌ MOBILE APPS (Phase 2)
  - Web first (PWA if time allows)
  - Native iOS/Android in Phase 2

❌ VIDEO / VIRTUAL APPOINTMENTS
  - No video call integration
  - No Zoom/Google Meet linking
  - Provider handles virtual logistics separately

❌ CALL/SMS REMINDERS
  - Email reminders only
  - SMS reminders deprioritized (nice-to-have, Phase 2)
```

### 8.3 Non-Goals (Explicitly Not Designed For)

```
🚫 VIRALITY / GROWTH HACKING
  - No referral program
  - No viral loops
  - No gamification
  - Platform designed for professional, controlled growth

🚫 PRICE OPTIMIZATION / DYNAMIC PRICING
  - Provider sets service price; no A/B testing or surge pricing
  - Price is deterministic, not algorithmic

🚫 UPSELL / CROSS-SELL
  - UI does not suggest or push additional services
  - No algorithmic recommendation

🚫 ALGORITHMIC MATCHING
  - No matching clients to providers
  - Providers define their rules; clients follow them

🚫 SOCIAL / PERFORMANCE METRICS
  - No provider ratings or reviews
  - No "trending" or "popular" mechanics
  - Neutral system of record, not evaluative
```

---

## 9. TECH CONSTRAINTS & ARCHITECTURE DECISIONS

### 9.1 Offline & Latency Tolerance

```
OFFLINE SUPPORT (Phase 2, not MVP):
  - MVP assumes reliable internet connection
  - No offline-first sync
  - If network fails mid-action, user sees error and must retry

LATENCY TOLERANCE:
  - Critical paths (payment, appointment state change) must complete in < 3 seconds
  - Reporting / export can take up to 10 seconds
  - UI shows loading state and allows cancellation on long operations
```

### 9.2 Race Conditions & Concurrency

```
APPOINTMENT DOUBLE-BOOKING:
  - Handled via distributed lock (Redis or DB-level)
  - Lock scope: Service ID + [scheduled_at - buffer_minutes, scheduled_at + duration + buffer_minutes]
  - Lock timeout: 5 seconds
  - On timeout (lock not released), fail safe: reject booking with "Slot unavailable"

CONCURRENT STAFF EDITS:
  - Last-write-wins with notification to other staff
  - Conflict detected via last_modified_at timestamp
  - Second editor shown: "This has been modified. Refresh to see changes."

CONCURRENT PAYMENT PROCESSING:
  - Idempotency key prevents duplicate charges
  - If same request_id within 24h, return cached result
  - If different request_id, allow (user error, charge twice, support can refund)
```

### 9.3 Data Consistency & Transactions

```
APPOINTMENT STATE CHANGE + PAYMENT REFUND:
  - Wrapped in database transaction
  - All-or-nothing: either appointment cancels AND refund initiates, or both fail
  - If payment gateway is unreachable, appointment state remains unchanged (no state without action)

APPOINTMENT CREATION + AVAILABILITY LOCK:
  - Locked: Service.id + time slot
  - Atomic: lock acquired → check availability → create appointment → release lock
  - On failure at any step, transaction rolls back, lock released
```

### 9.4 Idempotency Design

```
REQUEST ID HEADER: X-Idempotency-Key: <UUID>

Idempotent operations:
  - POST /appointments (booking)
  - POST /payments (charge)
  - PATCH /appointments/{id}/state (state transitions)

Non-idempotent:
  - POST /clients (create new client always)
  - DELETE /staff/{id} (revoke always)

Cache strategy:
  - Key: hash(operation + request_id)
  - TTL: 24 hours
  - Storage: Redis or in-process cache (depends on deployment)
```

### 9.5 Deployment & Environment

```
MINIMUM VIABLE STACK (MVP):
  - Backend: Node.js/Express + TypeScript OR Dart/Shelf (Flutter backend)
  - Database: PostgreSQL (relational, strong ACID)
  - Cache: Redis (idempotency, locks)
  - Payment: Stripe (Production-ready, PCI-compliant)
  - Auth: Firebase Auth OR custom JWT
  - Hosting: Firebase, AWS, or GCP (must be HTTPS, SOC2 eligible for future)
  - Monitoring: Sentry or similar (error tracking)
  - Email: SendGrid or similar (transactional email)

ENVIRONMENT VARIABLES (must be externalized):
  - STRIPE_SECRET_KEY
  - FIREBASE_CONFIG (or JWT_SECRET)
  - DATABASE_URL
  - REDIS_URL
  - EMAIL_API_KEY
  - APP_ENV (development | staging | production)

DEPLOYMENT:
  - CI/CD: GitHub Actions (build + test on PR, deploy on main)
  - Database migrations: Automated, versioned
  - Secrets: Not in repo, injected at deployment
```

---

## 10. APPOINTMENT BOOKING FLOW (Client-Facing)

### 10.1 Step-by-Step (Happy Path)

```
1. Client visits booking link (provider-branded URL)
   → Unauthenticated or logged-in as client

2. Select Service
   → List of active services (excluding deleted)
   → Show: service name, duration, price, and deposit %
   → Tap to select

3. Select Date
   → Calendar view showing available dates (next 90 days)
   → Dates with no available slots are grayed out
   → Tap date to proceed

4. Select Time
   → List available time slots for selected date
   → Slots account for: availability window + duration + buffers
   → Show: time, duration, final price (including fees)
   → Tap to select

5. Enter Booking Details (if not logged in)
   → Email (validate format)
   → Phone (validate format)
   → Name (require non-empty)
   → Optional: notes/special requests

6. Payment (if deposit required)
   → Show: service price + platform fee = total
   → Stripe card input (not custom form)
   → "Secure payment" badge
   → On success: receipt shown, confirmation email sent
   → On failure: clear error message, retry option

7. Confirmation
   → "Your appointment is confirmed!" or "Pending provider approval"
   → Show: appointment details, confirmation number
   → Button: "Add to calendar" (ics download)
   → Button: "View appointment" (link to appointment detail page)

TIMEOUT:
  - If client abandons at any step, no booking is created
  - No pre-authorization charges
  - Cart-like experience (no commitment until payment)
```

### 10.2 Rescheduling (Client-Initiated)

```
Precondition: Appointment is confirmed, current_state = confirmed

1. Client views appointment detail
2. Taps "Reschedule"
3. Check cancellation window:
   - If time_until_appointment < cancellation_notice_hours:
     → "Too late to reschedule. Contact [Provider]."
     → Show provider phone/email
   - Else: proceed
4. Show: available slots (starting from min(now, scheduled_at - 24h))
5. Select new time (same flow as step 4 above)
6. Confirm reschedule
7. Old appointment marked as rescheduled, new appointment created
8. Notification sent to provider and client
```

### 10.3 Cancellation (Client-Initiated)

```
Precondition: Appointment is confirmed, current_state = confirmed

1. Client views appointment detail
2. Taps "Cancel"
3. Check cancellation window:
   - If time_until_appointment < cancellation_notice_hours:
     → "Too late to cancel. Contact [Provider]."
     → Show provider phone/email
   - Else: proceed
4. Show: refund amount (based on cancellation policy)
   → "Your [Amount] deposit will be refunded within 3-5 business days."
5. Confirm cancellation (require confirmation, not one-click)
6. On confirm:
   - Appointment.state → client_canceled
   - Refund initiated to original payment method
   - Email sent to client and provider
7. On success: "Cancellation confirmed. Refund processed."
```

---

## 11. PROVIDER MANAGEMENT FLOW (Owner/Staff)

### 11.1 Appointment Creation (Provider-Initiated)

```
Owner or Staff (with CAN_CREATE_APPOINTMENTS permission):

1. Navigate to "New Appointment"
2. Select Service
3. Select Client
   → Search existing clients, or create new client inline
4. Select Date & Time
   → Calendar shows availability per service
   → Prevents double-booking (locked slot)
5. Add notes (optional)
6. Review: appointment details + pricing
7. Create
   → Appointment created in pending_confirmation state
   → No payment until owner confirms (or can auto-confirm)
8. If deposit required:
   → Owner chooses: invoice client now, or later
   → If now: send Stripe payment link via email
   → If later: manual follow-up
```

### 11.2 Appointment Confirmation Flow

```
Owner receives: "New Booking: [Client], [Service], [Date/Time], Pending Confirmation"

1. Owner reviews appointment detail
2. Taps "Confirm" or "Decline"
3. If Confirm:
   → Appointment.state → confirmed
   → Client notified: "Appointment confirmed for [Date/Time]"
   → Payment captured (if not already)
4. If Decline:
   → Appointment.state → provider_canceled
   → Full refund issued (if payment was captured)
   → Client notified: "Unfortunately, we're not able to accommodate this time."
```

---

## 12. AUDIT LOG & COMPLIANCE

### 12.1 What Gets Logged (Immutable)

```
Every action that changes state or accesses sensitive data:

- Appointment created (by: owner | staff | client_booked)
- Appointment state transitioned (from_state, to_state, actor, reason)
- Appointment rescheduled (old_time, new_time, actor)
- Client created (actor, email)
- Client data edited (field, old_value, new_value, actor)
- Service created/edited/deleted (actor)
- Payment initiated (amount, method, actor)
- Payment captured (transaction_id, timestamp)
- Payment failed (reason)
- Payment refunded (amount, reason, actor)
- Staff invited (email, permissions, actor)
- Staff permissions changed (old_perms, new_perms, actor)
- Staff revoked (actor)
- Settings changed (field, old_value, new_value, actor)
- Report exported (actor, type, date_range)

Not logged (read-only):
- Appointment viewed
- Client viewed
- Service viewed
- Payment history viewed
```

### 12.2 Owner Access to Audit Log

```
Dashboard view: Audit Log
  - Filterable by: date range, action type, actor, entity type
  - Sortable by: timestamp (desc)
  - Exportable as CSV (for legal/compliance)
  - Immutable (no deletion, truncation, or editing)

Use cases:
  - Dispute resolution ("client says they never booked, but log shows...")
  - Staff accountability (who refunded, who canceled)
  - Compliance/audits (export for legal review)
```

---

## 13. MVP SUCCESS CRITERIA

- [ ] Owner can create account and verify email
- [ ] Owner can create services and set availability
- [ ] Owner can invite staff with granular permissions
- [ ] Client can self-book appointment via public link
- [ ] Payment (deposit) captured on booking
- [ ] Appointment state machine enforces valid transitions
- [ ] Cancellation refunds processed and logged
- [ ] All state changes logged immutably
- [ ] Notifications sent transactionally (email)
- [ ] App Store / Play Store compliance verified (terms, privacy, delete account)
- [ ] Zero unhandled exceptions in error scenarios
- [ ] Idempotency prevents duplicate charges
- [ ] Performance: < 3s for critical paths (booking, payment)
- [ ] iOS AAB and Android APK build and install successfully
- [ ] Reviewer account (reviewer@cliente.app) can login and book

---

## 14. GLOSSARY

| Term | Definition |
|---|---|
| **Provider** | The business operating the service (owner or staff accountable to owner) |
| **Owner** | The account owner with full RBAC permissions |
| **Staff** | Team member with delegated permissions |
| **Client** | End customer booking/receiving service |
| **Service** | Defined offering (e.g., "haircut," "consulting hour") |
| **Appointment** | Booking of a service for a specific date/time |
| **Availability** | Time windows when provider offers services |
| **Deposit** | Upfront payment (percentage of service price) |
| **Idempotency Key** | UUID to prevent duplicate API requests |
| **Audit Log** | Immutable record of all state-changing actions |
| **State Machine** | Defined transitions between appointment states |
| **RBAC** | Role-Based Access Control (owner, staff, client) |
| **Refund** | Return of captured payment to client |
| **No-show** | Client did not appear for confirmed appointment |
| **System of Record** | Single source of truth (Clientè as the system) |

---

**End of Specification**
