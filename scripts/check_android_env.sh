#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FLUTTER_CMD="$REPO_ROOT/scripts/flutterw"

echo "== Flutter version =="
"$FLUTTER_CMD" --version

echo ""
echo "== Flutter doctor =="
"$FLUTTER_CMD" doctor

echo ""
echo "== Flutter devices =="
"$FLUTTER_CMD" devices

echo ""
echo "Tip: On Chromebook, the built-in Android environment should appear as a device in 'flutter devices'."
