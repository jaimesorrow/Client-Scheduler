# Client-Scheduler
Clientè is a luxury client management platform built for high-value service businesses, focused on scheduling, governance, and compliance-first system design. Engineered for clarity, control, and long-term scalability.


## Flutter test setup

Prerequisites: install the Flutter SDK (https://flutter.dev) and ensure `flutter` is on your PATH.

To initialize platform folders (Android/iOS) and get dependencies, run in the project root:

```bash
flutter create .
flutter pub get
```

Run on an Android emulator or connected device:

```bash
flutter devices
flutter run -d <device-id>
```

To build an APK for testing on a phone:

```bash
flutter build apk --debug
```

If you want me to generate Android/iOS native folders here, I can run `flutter create .` for you — but the dev container may not have Flutter installed. If you want, I can instead provide a complete generated project structure.

## Preparing for Google Play (release)

I created a placeholder upload keystore at `android/app/upload-keystore.jks` and a `android/key.properties` file with placeholder passwords. Replace these passwords and the keystore with your secure upload key before publishing.

Steps to produce a Play-ready AAB and upload:

```bash
# (1) Ensure Flutter is installed locally
flutter --version

# (2) Generate platform folders if you haven't already (run locally)
flutter create .
flutter pub get

# (3) Verify the Android package name is set in
#     android/app/src/main/AndroidManifest.xml (package="com.client.scheduler")

# (4) Build an Android App Bundle for Play
flutter build appbundle --release

# (5) Upload the generated .aab from build/app/outputs/bundle/release/ to the Play Console
```

Notes:
- I previously created a placeholder keystore but removed it from the repository to avoid committing secrets. Do not commit `android/key.properties` or any `.jks` files.
- Use the GitHub Actions workflow secrets (`ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_PASSWORD`, `ANDROID_KEY_ALIAS`) to provide signing material to CI.

If you want me to attempt running `flutter create .` and/or generate the full Android Gradle wrapper here, I can try — but the container currently lacks the Flutter SDK.

## CI builds

I added a GitHub Actions workflow to build an Android App Bundle automatically: `.github/workflows/android-build.yml`.

Usage notes for CI:
- To let the workflow sign with your keystore, add a secret `ANDROID_KEYSTORE_BASE64` containing the base64-encoded keystore, and these secrets: `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_PASSWORD`, `ANDROID_KEY_ALIAS`.
- The workflow will produce an `.aab` artifact you can download from the workflow run.

Local helper scripts:
- `scripts/prepare_local.sh` will run `flutter create .` and `flutter pub get` (requires Flutter installed locally).
- `scripts/encode_keystore.sh <path/to/keystore.jks>` base64-encodes a keystore file so you can paste it into the GitHub secret `ANDROID_KEYSTORE_BASE64`.

