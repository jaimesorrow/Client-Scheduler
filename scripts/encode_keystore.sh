#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 path/to/keystore.jks" >&2
  exit 2
fi

KEYSTORE_PATH="$1"
if [ ! -f "$KEYSTORE_PATH" ]; then
  echo "Keystore not found: $KEYSTORE_PATH" >&2
  exit 3
fi

OUTPUT_FILE=keystore.b64
if command -v base64 >/dev/null 2>&1; then
  # GNU and BSD base64 have different flags; use portable approach
  if base64 --help 2>&1 | grep -q -- "-w"; then
    base64 -w0 "$KEYSTORE_PATH" > "$OUTPUT_FILE"
  else
    base64 "$KEYSTORE_PATH" > "$OUTPUT_FILE"
  fi
  echo "Wrote base64 of $KEYSTORE_PATH to $OUTPUT_FILE"
  echo "Add the contents of $OUTPUT_FILE as the GitHub secret ANDROID_KEYSTORE_BASE64"
else
  echo "base64 command not found on PATH" >&2
  exit 4
fi
