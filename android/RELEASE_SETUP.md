After you run `flutter create .` locally the Android project will be available at `android/`.

Edit `android/app/build.gradle` to add signing config using `android/key.properties`.

In `android/app/build.gradle` inside `android { }` add:

```
def keystorePropertiesFile = rootProject.file("key.properties")
def keystoreProperties = new Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            // Other release optimizations
            minifyEnabled false
            shrinkResources false
        }
    }
}
```

Then build the release AAB:

```
flutter build appbundle --release
```

Replace the placeholder keystore and passwords with your secure upload key before publishing.
