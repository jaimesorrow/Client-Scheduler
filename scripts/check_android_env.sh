#!/usr/bin/env bash
set -euo pipefail

if ! command -v flutter >/dev/null 2>&1; then
  echo "flutter not found on PATH. Install Flutter and retry." >&2
  exit 1
fi

echo "== Flutter version =="
flutter --version

echo ""
echo "== Flutter doctor =="
flutter doctor

echo ""
echo "== Flutter devices =="
flutter devices

echo ""
echo "Tip: On Chromebook, the built-in Android environment should appear as a device in 'flutter devices'."
