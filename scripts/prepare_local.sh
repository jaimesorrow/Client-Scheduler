#!/usr/bin/env bash
set -euo pipefail

echo "This script helps prepare the project locally for Flutter builds."

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FLUTTER_CMD="$REPO_ROOT/scripts/flutterw"

echo "Running flutter create . to generate platform folders (if missing)"
"$FLUTTER_CMD" create .

echo "Fetching pub dependencies"
"$FLUTTER_CMD" pub get

echo "If you have a keystore, place it at android/app/upload-keystore.jks and update android/key.properties"
echo "To build an APK for testing: scripts/flutterw build apk --debug"
echo "To build an app bundle for Play: scripts/flutterw build appbundle --release"
