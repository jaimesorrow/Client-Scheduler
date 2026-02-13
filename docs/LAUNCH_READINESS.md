# Cliente Pre-Launch Verification Drill (Founder Runbook)

Date: 2026-02-11
Scope: Founder-level 60-minute drill, tailored to Cliente MVP.
Outcome: Pass/Fail per section, with hard evidence (screenshots or notes).

---

## 0) How To Run This
- Run it personally.
- Log everything: time, build number, device used, and pass/fail.
- If any step is unclear, it is a fail.

---

## 1) Access Control & Account Deletion
Goal: Prove you control roles, data boundaries, and deletion behavior.

Checklist:
- Log in as Owner and attempt to access staff-only routes.
- Log in as Staff and attempt to access owner-only routes.
- Try typing restricted URLs directly.
- Attempt to edit another user’s data by direct navigation or ID guess.
- Confirm the guard blocks access without leaking backend structure.
- Delete your own account and confirm access stops immediately.
- Confirm backend data retention matches policy after deletion.
- Export your data before deletion and confirm export succeeds and is complete.

Pass/Fail criteria:
- Any unauthorized route access is a fail.
- Any data access without proper role is a fail.
- Any unclear deletion behavior is a fail.

---

## 2) Payment Conflict Simulation
Goal: Prove money and dispute language is accurate and user-safe.

Checklist:
- Book an appointment, cancel it, request a refund.
- Simulate a dispute flow (chargeback language path).
- Ensure UI shows provider-controlled refund language.
- Confirm platform fees are clearly non-refundable.
- Verify UI never displays or stores raw card numbers.
- Confirm language does not imply Cliente guarantees services.

Pass/Fail criteria:
- Any ambiguity about who controls refunds is a fail.
- Any UI implying Cliente provides services is a fail.
- Any raw card handling is a fail.

---

## 3) Legal Visibility & Consistency
Goal: Prove legal documents are accessible and consistent in-product.

Checklist:
- Terms of Service visible in-app.
- Privacy Policy visible in-app.
- Acceptable Use Policy visible in-app.
- Refund Disclosure visible in-app.
- Law Enforcement Policy visible in-app.
- Account Deletion Policy visible in-app.
- Validate in-app copy does not contradict these documents.

Pass/Fail criteria:
- Missing doc or conflicting language is a fail.

---

## 4) Abuse & Misuse Testing
Goal: Prove the app handles prohibited content and abuse paths.

Checklist:
- Attempt to enter prohibited service descriptions (illegal, sexual services, medical diagnosis).
- Attempt to bypass fees or manipulate appointment status.
- Attempt to upload suspicious data payloads.
- Confirm either moderation logic or explicit AUP violation path exists.

Pass/Fail criteria:
- No clear mitigation or escalation path is a fail.

---

## 5) Operational Resilience
Goal: Prove graceful failure and no secrets exposure.

Checklist:
- Force-close app mid-booking.
- Kill network mid-payment.
- Trigger an intentional error state.
- Confirm no stack traces or internal IDs are exposed.
- Verify production keys are not present in client builds.
- Verify test keys are removed.

Pass/Fail criteria:
- Any exposure of internals or secrets is a fail.

---

## 6) Data Discipline
Goal: Prove data storage and retention are intentional and lawful.

Checklist:
- Review what data is stored per entity (Client, Service, Appointment, Template, BusinessSettings).
- Confirm no unnecessary personal data is stored.
- Confirm retention logic matches the policy.
- Confirm logs exist for: payments, status changes, account deletions.
- If subpoenaed, confirm you can enumerate exactly what exists.

Pass/Fail criteria:
- Data stored without policy basis is a fail.
- Missing critical audit logs is a fail.

---

## 7) Brand Alignment
Goal: Prove the app feels premium and finished.

Checklist:
- Open app fresh and evaluate the first 30 seconds.
- Flag any placeholder screen, text, or inconsistent UI.
- Confirm typography and gold accent usage matches brand system.

Pass/Fail criteria:
- Any placeholder or inconsistent UI is a fail.

---

## 8) Scalability Reality Check
Goal: Prove you can survive 500 users tomorrow.

Checklist:
- Identify the weakest operational link (support, payment disputes, compliance, data export, deletion).
- Validate that you can handle this at 500 users without improvisation.

Pass/Fail criteria:
- If the answer is “no” for any core function, it is a fail.

---

# Cliente-Specific Tailoring Notes
Based on current project direction (Flutter + role-based access + audit logging):

- Roles in scope: Owner, Staff. Client portal is Phase 2.
- Scheduling flows are a core MVP pillar. Appointment status changes must be logged.
- Settings, legal, and delete account are required for store compliance.
- Payments are Phase 2 unless already implemented. If payments are not implemented, Sections 2 and 5 must be adapted to “manual/no payment” flows.
- Crash-safe routing was specified. Verify all guarded routes redirect safely to `/dashboard`.

If any of the above is not yet implemented, mark the section as Fail and list the missing component.

---

# Brutal Launch Readiness Scorecard (Pass/Fail Only)
Instructions: Mark each line Pass or Fail. No partial credit.

1. Access control blocks all restricted routes.
2. Direct URL access cannot bypass guards.
3. Cross-user data cannot be edited.
4. Account deletion immediately removes access.
5. Data retention behavior matches policy.
6. Data export is available and complete.
7. Refund language is correct and provider-controlled.
8. Platform fees are clearly non-refundable.
9. No raw card numbers are displayed or stored.
10. Legal docs are accessible in-app.
11. In-product copy matches legal docs.
12. AUP violations are handled or blocked.
13. Abuse attempts are detected or flagged.
14. App fails gracefully with no internal leaks.
15. No production secrets in client build.
16. Audit logs exist for sensitive events.
17. Data stored is minimal and policy-aligned.
18. Brand experience is premium and consistent.
19. No placeholder screens remain.
20. You could handle 500 users tomorrow.

Overall result: PASS only if every line is Pass.
