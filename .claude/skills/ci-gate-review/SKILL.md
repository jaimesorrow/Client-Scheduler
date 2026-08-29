---
name: ci-gate-review
description: Reviews changes to Client-Scheduler's CI configuration and its claims about CI (.github/workflows/android-build.yml, docs/SPECIFICATION.md's CI/CD section, analysis_options.yaml, test/, review.sh) against what the pipeline actually runs. Use this instead of assuming a passing GitHub Actions badge means analyze/tests ran, for any change to .github/workflows/**, any change that adds or modifies tests, and any change to docs claiming CI enforces something.
---

# Client-Scheduler CI-gate review

This repo has exactly one GitHub Actions workflow, `.github/workflows/android-build.yml`, and it
does less than the project's own docs claim. Review any CI-adjacent diff against what's actually
wired up, not against the aspirational description in `docs/SPECIFICATION.md`.

## 1. The workflow never runs on pull requests

`android-build.yml`'s trigger is:

```yaml
on:
  workflow_dispatch:
  push:
    branches: [ main ]
```

There is no `pull_request:` trigger. This means a PR branch gets **zero** CI feedback before
merge — the workflow only fires after a push lands directly on `main` (or someone clicks
"Run workflow" manually). Flag:
- Any diff that adds a required-status-check assumption (branch protection rules, PR templates,
  contributor docs) implying "CI will catch this" for a PR — it won't, today.
- Any change to the `on:` block that still omits `pull_request` while claiming to "add CI
  coverage for PRs."

## 2. The workflow only builds — it never lints or tests

The single job's steps are `flutter --version` → `flutter create . --no-overwrite` →
(optional keystore restore) → `flutter pub get` → `flutter build appbundle --release` → upload
artifact. There is no `flutter analyze` step and no `flutter test` step anywhere in this file, even
though:
- `analysis_options.yaml` pulls in `package:flutter_lints/flutter.yaml`, implying lint rules are
  meant to be enforced somewhere.
- `test/widget_test.dart` exists (even though today it's still the unmodified default counter-app
  test — see the `client-scheduler-review` skill's section 6).
- `docs/SPECIFICATION.md` states under "TECH CONSTRAINTS & ARCHITECTURE DECISIONS":
  `CI/CD: GitHub Actions (build + test on PR, deploy on main)` — the actual workflow satisfies
  neither half of that (no PR trigger, no test step).

`flutter build appbundle --release` type-checks the code but does not fail on lint warnings from
`analysis_options.yaml`, and does not run anything under `test/`. A PR that introduces an analyzer
warning, or that breaks `test/widget_test.dart` (or any real test added later), gets a green build
artifact regardless. Flag:
- Any PR description or commit message asserting "CI will catch this" for a lint or test
  regression — today it structurally cannot, since neither step exists in the workflow.
- A new/edited test file added anywhere under `test/` without a corresponding `flutter test` step
  added to `android-build.yml` (or a new workflow) — the test would only ever run locally
  (`scripts/flutterw test`, or manually), never in CI.
- Any edit to `docs/SPECIFICATION.md`'s CI/CD line that changes the claim without a matching change
  to the actual workflow — keep the two in sync, in whichever direction the diff intends.

## 3. `review.sh` is a local script, not a CI gate

`review.sh` runs `flutter analyze`, `flutter test`, and `flutter build apk --debug`, and produces a
pass/warn/fail scoreboard with a non-zero exit code on FAIL — but nothing in `.github/workflows/`
invokes it. Its `review_reports/*.txt` output is currently committed to the repo (e.g.
`review_reports/review_20260212_083211.txt`, `review_reports/review_20260212_083219.txt`) even
though these are timestamped run artifacts, not source. Flag:
- Any claim (in a PR, commit message, or docs) that `review.sh` "gates" merges or deploys — it is
  invoked manually today and produces no CI check.
- New `review_reports/*.txt` files added in a diff — these are local run output and generally
  shouldn't be committed; consider whether a `.gitignore` entry is warranted if a diff adds more of
  them, or a script change that requires this.

## 4. If a diff adds `pull_request` triggering, `flutter analyze`, or `flutter test` to the workflow

That's the fix for sections 1-2 — don't flag it as a problem. Instead verify:
- `flutter analyze` and `flutter test` steps run with the shell's default failure propagation (no
  `continue-on-error: true`, no `|| true` swallowing a non-zero exit) — a step that's present but
  can't fail the job is equivalent to not having it.
- The job still fails (non-zero exit / workflow shows red) when analyze or test fails, not just when
  the build step fails.

## Running checks

There is no way to "run CI" locally beyond what `review.sh` and `scripts/flutterw` already do (see
the `client-scheduler-review` skill's "Running checks" section). State plainly in review output that
a green GitHub Actions run on this repo, as of this writing, confirms only that the app bundle built
— not that lints pass, not that tests pass, and not that the PR's own branch was ever built at all
(only post-merge pushes to `main` are).
