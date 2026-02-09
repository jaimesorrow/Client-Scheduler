# Play Store Deployment Guide

This guide covers how to prepare and upload your Flutter app to Google Play.

## Prerequisites

1. **Google Play Developer Account** (~$25 one-time registration fee)
2. **Signing keystore** (Android upload key or Play key)
3. **App signing certificate** (if using Google Play's app signing)
4. **GitHub secrets** configured (see below)

## Step 1: Create or Prepare Your Signing Keystore

If you don't have an upload keystore yet:

### Option A: Create a new keystore locally

```bash
keytool -genkeypair -v \
  -keystore android/app/Cliente-Scheduler-Keystore.jks \
  -storepass YOUR_PASSWORD \
  -alias YOUR_ALIAS \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -dname "CN=Your Name, OU=Your Org, O=Your Company, L=City, ST=State, C=US"
```

### Option B: Use an existing keystore

Keep your existing keystore file secure and accessible.

## Step 2: Configure GitHub Secrets

1. Go to your GitHub repository settings: **Settings > Secrets and variables > Actions**
2. Click **New repository secret** and add these four secrets:

   - **ANDROID_KEYSTORE_BASE64**: Base64-encoded keystore file
   - **ANDROID_KEYSTORE_PASSWORD**: The keystore password (e.g., `testidcliente`)
   - **ANDROID_KEY_PASSWORD**: The key password (e.g., `testingpassword123`)
   - **ANDROID_KEY_ALIAS**: The key alias (e.g., `ClienteKey`)

### How to create ANDROID_KEYSTORE_BASE64

Run this on your local machine:

```bash
bash scripts/encode_keystore.sh android/app/Cliente-Scheduler-Keystore.jks
cat keystore.b64
```

Copy the entire output and paste it into the `ANDROID_KEYSTORE_BASE64` secret on GitHub.

## Step 3: Trigger the CI Build

Option A: **Automatic** — push to main branch (workflow runs on push)

Option B: **Manual** — go to GitHub Actions tab, select "Build Android AAB" workflow, click "Run workflow"

The workflow will:
1. Check out the code
2. Install Flutter SDK
3. Generate platform folders (`flutter create .`)
4. Load the keystore from secrets
5. Build the Android App Bundle (`.aab`)

## Step 4: Download the AAB

1. Go to GitHub Actions tab
2. Click on the completed "Build Android AAB" workflow run
3. Under "Artifacts", download the `appbundle.zip`
4. Extract it to find the `.aab` file (usually in `build/app/outputs/bundle/release/`)

## Step 5: Upload to Google Play Console

1. Sign in to [Google Play Console](https://play.google.com/console)
2. Select your app
3. Go to **Internal testing** or **Staging** (for initial testing)
4. Click **Create new release**
5. Upload the `.aab` file
6. Fill in release notes (required)
7. Review the app details:
   - App name: "Clientè Scheduler"
   - Package name: `com.client.scheduler` (from `AndroidManifest.xml`)
   - Permissions, features, device compatibility
8. Click **Publish** to internal testing (or staging/production when ready)

## Step 6: Review and Go Live

1. **Internal Testing**: Share the link with internal testers. No review required.
2. **Staging**: Optional, for testing on Play Store test infrastructure.
3. **Production**: Requires Google Play review (~24-48 hours). Review policies include:
   - Privacy policy
   - Content rating
   - Compliance with Play Store policies

## Troubleshooting

### Build fails with "Unable to locate Android SDK"
- This happens in CI sometimes with slow downloads. Retry the workflow (the SDK will be cached).

### Signing error in CI
- Verify secrets are set correctly. The workflow logs will show which step failed.
- `ANDROID_KEYSTORE_BASE64` must be the exact base64 output; extra whitespace breaks it.

### Play Console upload fails
- Verify the `.aab` file is valid: `zipinfo build/app/outputs/bundle/release/*.aab | head -20`
- Check Google Play's error message for specifics (usually about permissions, features, or content rating).

### App doesn't install on test device
- Ensure the target device's Android version matches `minSdkVersion` in `android/app/build.gradle`.
- Google Play may have compatibility filters; check device details in Play Console.

## Local Testing (Alternative to CI)

If you prefer to build locally:

```bash
# Install Flutter (if not already done)
# From https://flutter.dev/docs/get-started/install

# In project root:
flutter create .
flutter pub get

# Build APK for immediate testing (debug version):
flutter build apk --debug
adb install -r build/app/outputs/apk/debug/app-debug.apk

# Build AAB for Play Store (release version, requires keystore):
# Create android/key.properties with your credentials first
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

## Security Best Practices

- **Never commit** `android/key.properties` or the `.jks` keystore file to the repository.
- **Store the keystore** securely offline (encrypted USB, password manager, etc.).
- **Rotate upload keys** periodically (if using a separate upload key, not the app signing key).
- **Use GitHub secrets** for all sensitive data; never log passwords or keys.
- **Review CI logs** carefully; GitHub Actions will not log secret values.

## Support

For Flutter/Dart issues: https://flutter.dev/docs
For Google Play: https://support.google.com/googleplay/android-developer
