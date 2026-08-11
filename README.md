# Animal Puzzle Kids

512 offline animal puzzle levels for kids (age 3-12). 8 game modes, 3D clay art,
world map, habitat scenes, ambient music, kid-friendly guides, daily chest,
zero ads, zero internet permission, zero data collection. Paid app ($4.99) for
Amazon Fire tablets.

## Kaise build hota hai (GitHub Actions)

1. GitHub pe naya repo banao: `animal-puzzle-kids` (Private rakho).
2. Is ZIP ka saara content repo mein upload karo (drag & drop ya git push).
   Dhyan rahe: `.github/` folder bhi upload hona chahiye (GitHub web upload
   hidden folders kabhi-kabhi skip karta hai - upload ke baad check kar lo
   ki `.github/workflows/build.yml` repo mein dikhta hai).
3. Repo > Settings > Secrets and variables > Actions > New repository secret.
   4 secrets daalo (values signing-kit ZIP ke `SECRETS.txt` mein hain):
   - `SIGNING_KEYSTORE_BASE64`
   - `SIGNING_STORE_PASSWORD`
   - `SIGNING_KEY_PASSWORD`
   - `SIGNING_KEY_ALIAS`
4. Actions tab > "build" workflow > Run workflow (ya `main` pe push karo).
5. Build green hone ke baad 2 artifacts milenge:
   - `AMAZON-UPLOAD-signed-release` -> SIRF yahi Amazon Appstore pe upload karna hai
   - `APPETIZE-ONLY-debug` -> sirf Appetize.io testing ke liye. Ise Amazon pe KABHI mat upload karna.

## Structure

- `lib/` - app code (8 game modes, world map, screens, core logic)
- `lib/data/guides.dart` - har mode ka kid-friendly "Kaise khele?" guide
- `test/` - unit tests (generators + progress logic + guides)
- `assets/animals/` - 12 clay animal PNGs (transparent)
- `assets/scenes/` - 4 habitat background JPGs
- `assets/sfx/` - 8 sound effects + ambient music loop (offline WAV)
- `ci/` - Android config CI mein apply hota hai (gradle, proguard, icons)
- `.github/workflows/build.yml` - full CI: analyze > test > debug + signed release APK

## Rules jo is project mein follow hote hain

- `android/` CI mein throwaway dir se generate hota hai, repo mein commit nahi hota
- Release signing GitHub Secrets se hoti hai; keystore repo mein kabhi nahi jaata
- minSdk 22, targetSdk 34, compileSdk 36, NDK 28.2.13676358, Java 17
- Sirf 2 plugins: shared_preferences + audioplayers (dono offline-safe)
- Every fix = version bump in pubspec.yaml (Amazon reused versionCode reject karta hai)
