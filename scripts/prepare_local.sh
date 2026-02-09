#!/usr/bin/env bash
set -euo pipefail

echo "This script helps prepare the project locally for Flutter builds."

if ! command -v flutter >/dev/null 2>&1; then
  echo "Error: flutter is not installed or not on PATH. Install Flutter first: https://flutter.dev"
  exit 2
fi

echo "Running flutter create . to generate platform folders (if missing)"
flutter create .

echo "Fetching pub dependencies"
flutter pub get

echo "If you have a keystore, place it at android/app/upload-keystore.jks and update android/key.properties"
echo "To build an APK for testing: flutter build apk --debug"
echo "To build an app bundle for Play: flutter build appbundle --release"
