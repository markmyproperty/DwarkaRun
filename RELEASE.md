# Releasing Odyssey of the Ages

How to ship a store build to Google Play and the Apple App Store.
Store text, privacy answers and content-rating answers are in [docs/store-listing.md](docs/store-listing.md); the privacy policy page is [docs/privacy.html](docs/privacy.html).

## Release settings in this repository

| Setting | Value |
| --- | --- |
| Android application id / iOS bundle id | `com.mmyp.odysseyoftheages` (permanent once uploaded) |
| Version | `pubspec.yaml` → `version: 1.0.0+1` (name + build number; bump the number for every upload) |
| Android signing | `android/key.properties` + upload keystore, both git-ignored; debug keys are used when they are missing |
| Android target | Flutter defaults (target SDK 36, min SDK 24), App Bundle (`.aab`) for Play |
| iOS | iPhone only, portrait only, iOS 15+, `ITSAppUsesNonExemptEncryption = NO`, app icon without alpha |
| CI | `codemagic.yaml`: `android-release` (signed AAB → Play internal track as draft) and `ios-release` (signed IPA → TestFlight) |

## Android: signed App Bundle

1. Put the upload keystore at `android/app/upload-keystore.jks` and create `android/key.properties`:

   ```properties
   storePassword=…
   keyPassword=…
   keyAlias=upload
   storeFile=upload-keystore.jks
   ```

   Keep both files and the passwords backed up outside the repository. With Play App Signing (the default), Google holds the real app-signing key; this is only the upload key, and Play support can reset it if it is lost.

2. Build:

   ```sh
   flutter build appbundle --release
   # → build/app/outputs/bundle/release/app-release.aab
   ```

3. In Play Console: create the app (name, default language English (India) or English (US), Game, Free), fill every item under **Policy › App content** using `docs/store-listing.md`, upload the listing graphics, then upload the `.aab` to **Testing › Internal testing**, then promote to Closed testing / Production.

   Personal developer accounts created after 13 Nov 2023 must run a **closed test with at least 12 testers for 14 days** before Production access is granted. Organisation accounts skip this.

## iOS: TestFlight and App Store

The iOS build needs macOS with Xcode. Either:

- **Codemagic** (no Mac): connect this repository at codemagic.io, add an App Store Connect API key under *Team integrations* named `MMYP App Store Connect`, enable automatic iOS code signing, set `APP_STORE_APPLE_ID` in `codemagic.yaml`, and run `ios-release`. The build lands in TestFlight.
- **A Mac**: `flutter build ipa --release`, then open `build/ios/archive/Runner.xcarchive` in Xcode › Organizer › Distribute App › App Store Connect, with the team set under Runner › Signing & Capabilities.

Before the first build, register the bundle id in the Apple Developer portal (Identifiers) and create the app in App Store Connect (My Apps › + › New App, bundle id above, SKU `odyssey-of-the-ages`).

Then in App Store Connect: fill App Information, Pricing (Free), App Privacy ("Data Not Collected"), Age Rating (all None → 4+), the 1.0 version page (screenshots, description, keywords, support URL, review contact), pick the TestFlight build, and **Submit for Review**.

## Every later release

1. Bump `version:` in `pubspec.yaml` (for example `1.0.1+2`). Build numbers must always go up.
2. Run `flutter analyze` and `flutter test`.
3. Build and upload as above (or start both Codemagic workflows).
4. Update "What's new" in both stores.
