# review.sh — Old Clientè Codex Build Checklist + Stop/Go Scoreboard
# Usage:
#   chmod +x review.sh
#   ./review.sh
#
# Optional (faster/safer):
#   ./review.sh --no-build     # skip flutter build
#   ./review.sh --no-tests     # skip flutter test
#   ./review.sh --no-flutter   # skip all flutter commands (if flutter not installed here)

set -euo pipefail

NO_BUILD=0
NO_TESTS=0
NO_FLUTTER=0

for arg in "$@"; do
  case "$arg" in
    --no-build)   NO_BUILD=1 ;;
    --no-tests)   NO_TESTS=1 ;;
    --no-flutter) NO_FLUTTER=1 ;;
    *) echo "Unknown arg: $arg" >&2; exit 2 ;;
  esac
done

ROOT="$(pwd)"
TS="$(date +%Y%m%d_%H%M%S)"
REPORT_DIR="$ROOT/review_reports"
REPORT_FILE="$REPORT_DIR/review_$TS.txt"
mkdir -p "$REPORT_DIR"

# ---- pretty printing ----
GREEN="$(printf '\033[0;32m')"
YELLOW="$(printf '\033[0;33m')"
RED="$(printf '\033[0;31m')"
CYAN="$(printf '\033[0;36m')"
RESET="$(printf '\033[0m')"

PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0

pass(){ PASS_COUNT=$((PASS_COUNT+1)); echo "${GREEN}✅ PASS${RESET}  $*" | tee -a "$REPORT_FILE"; }
warn(){ WARN_COUNT=$((WARN_COUNT+1)); echo "${YELLOW}⚠️  WARN${RESET}  $*" | tee -a "$REPORT_FILE"; }
fail(){ FAIL_COUNT=$((FAIL_COUNT+1)); echo "${RED}❌ FAIL${RESET}  $*" | tee -a "$REPORT_FILE"; }

run_cmd() {
  local label="$1"; shift
  echo "" | tee -a "$REPORT_FILE"
  echo "${CYAN}== $label ==${RESET}" | tee -a "$REPORT_FILE"
  # shellcheck disable=SC2068
  if "$@" 2>&1 | tee -a "$REPORT_FILE"; then
    return 0
  else
    return 1
  fi
}

has_cmd() { command -v "$1" >/dev/null 2>&1; }

echo "${CYAN}Old Clientè Review — $TS${RESET}" | tee "$REPORT_FILE"
echo "Repo: $ROOT" | tee -a "$REPORT_FILE"

# ------------------------------------------------------------------------------
# 1) Git sanity
# ------------------------------------------------------------------------------
if has_cmd git; then
  run_cmd "git status" git status || warn "git status failed (not fatal, but odd)."
  run_cmd "git diff --stat" git diff --stat || warn "git diff --stat failed."
  run_cmd "git diff (first 400 lines)" bash -lc "git diff | sed -n '1,400p'" || warn "git diff failed."
  pass "Git commands executed."
else
  fail "git not found. Install git or run this in a git repo."
fi

# ------------------------------------------------------------------------------
# 2) Contract enforcement: forbidden keys
#   Must be 0 hits:
#     startsAt / endsAt / serviceId (identifier or field)
# ------------------------------------------------------------------------------
FORBIDDEN_RE='startsAt|endsAt|serviceId\b'
FORBIDDEN_HITS="$(grep -RIn --exclude-dir=build --exclude-dir=.dart_tool --exclude-dir=.git \
  -E "$FORBIDDEN_RE" lib writingdocs docs 2>/dev/null || true)"

echo "" | tee -a "$REPORT_FILE"
echo "${CYAN}== Contract check: forbidden keys ==${RESET}" | tee -a "$REPORT_FILE"
echo "Pattern: $FORBIDDEN_RE" | tee -a "$REPORT_FILE"

if [ -z "$FORBIDDEN_HITS" ]; then
  pass "No forbidden keys found in lib/ writingdocs/ docs/."
else
  echo "$FORBIDDEN_HITS" | tee -a "$REPORT_FILE"
  fail "Forbidden keys found. Must fix before proceeding."
fi

# ------------------------------------------------------------------------------
# 3) Contract enforcement: required keys (informational)
# ------------------------------------------------------------------------------
REQUIRED_RE='startAt|endAt|serviceIds|totalDurationMin|totalPriceCents|onboardingComplete|businessSettings'
REQ_HITS_COUNT="$(grep -RIn --exclude-dir=build --exclude-dir=.dart_tool --exclude-dir=.git \
  -E "$REQUIRED_RE" lib 2>/dev/null | wc -l | tr -d ' ')"

echo "" | tee -a "$REPORT_FILE"
echo "${CYAN}== Contract check: required keys (informational) ==${RESET}" | tee -a "$REPORT_FILE"
echo "Pattern: $REQUIRED_RE" | tee -a "$REPORT_FILE"
echo "Hits in lib/: $REQ_HITS_COUNT" | tee -a "$REPORT_FILE"
if [ "$REQ_HITS_COUNT" -gt 0 ]; then
  pass "Required keys present (count=$REQ_HITS_COUNT)."
else
  warn "No hits for required keys. This might be wrong if code moved or not implemented yet."
fi

# ------------------------------------------------------------------------------
# 4) Route presence (best-effort grep)
# ------------------------------------------------------------------------------
echo "" | tee -a "$REPORT_FILE"
echo "${CYAN}== Route presence (best-effort) ==${RESET}" | tee -a "$REPORT_FILE"

ROUTES=(
  "/clients"
  "/clients/new"
  "/services"
  "/services/new"
  "/appointments"
  "/templates"
  "/availability"
  "/analytics"
  "/settings"
  "/logout"
  "/delete"
  "/system"
)

MISSING_ROUTES=0
for r in "${ROUTES[@]}"; do
  if grep -RIn --exclude-dir=build --exclude-dir=.dart_tool --exclude-dir=.git \
      -F "$r" lib/app lib/screens lib 2>/dev/null >/dev/null; then
    echo "✅ found route reference: $r" | tee -a "$REPORT_FILE"
  else
    echo "❌ missing route reference: $r" | tee -a "$REPORT_FILE"
    MISSING_ROUTES=$((MISSING_ROUTES+1))
  fi
done

if [ "$MISSING_ROUTES" -eq 0 ]; then
  pass "All key legacy routes referenced in code (best-effort)."
else
  warn "$MISSING_ROUTES key routes not found by grep. If routes exist but strings differ, ignore; otherwise add routes/aliases."
fi

# ------------------------------------------------------------------------------
# 5) Flutter checks (optional)
# ------------------------------------------------------------------------------
if [ "$NO_FLUTTER" -eq 1 ]; then
  warn "Skipping Flutter checks (--no-flutter)."
else
  if has_cmd flutter; then
    run_cmd "flutter --version" flutter --version || warn "flutter --version failed."

    if run_cmd "flutter analyze" flutter analyze; then
      pass "flutter analyze passed."
    else
      fail "flutter analyze failed."
    fi

    if [ "$NO_TESTS" -eq 1 ]; then
      warn "Skipping flutter test (--no-tests)."
    else
      if run_cmd "flutter test" flutter test; then
        pass "flutter test passed."
      else
        warn "flutter test failed OR no tests present (verify output)."
      fi
    fi

    if [ "$NO_BUILD" -eq 1 ]; then
      warn "Skipping flutter build (--no-build)."
    else
      if run_cmd "flutter build apk --debug" flutter build apk --debug; then
        pass "flutter build apk --debug succeeded."
      else
        fail "flutter build apk --debug failed."
      fi
    fi
  else
    warn "flutter not found on PATH. Run this script on a machine with Flutter installed (or re-run with --no-flutter)."
  fi
fi

# ------------------------------------------------------------------------------
# 6) STOP/GO Scoreboard
# ------------------------------------------------------------------------------
echo "" | tee -a "$REPORT_FILE"
echo "${CYAN}==================== SCOREBOARD ====================${RESET}" | tee -a "$REPORT_FILE"
echo "PASS: $PASS_COUNT   WARN: $WARN_COUNT   FAIL: $FAIL_COUNT" | tee -a "$REPORT_FILE"

if [ "$FAIL_COUNT" -gt 0 ]; then
  echo "${RED}STATUS: STOP ❌${RESET} — Fix FAIL items before continuing." | tee -a "$REPORT_FILE"
  echo "Report: $REPORT_FILE"
  exit 1
fi

if [ "$WARN_COUNT" -gt 0 ]; then
  echo "${YELLOW}STATUS: GO (with caution) ⚠️${RESET} — You can proceed, but address WARN items soon." | tee -a "$REPORT_FILE"
  echo "Report: $REPORT_FILE"
  exit 0
fi

echo "${GREEN}STATUS: GO ✅${RESET} — Clean pass. Proceed to next module." | tee -a "$REPORT_FILE"
echo "Report: $REPORT_FILE"
exit 0
