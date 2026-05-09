# BUILD_ISSUES

Read this only when emulator, build, DDS, Gradle, or Android runtime instability appears.

---

## Known Symptoms

- Repeated `WindowInsets changed`.
- Repeated `FlutterJNI: Sending viewport metrics`.
- `Lost connection to device`.
- Emulator log includes `vendor.mesa.virtgpu.kumquat`.
- Dart Dev Service failure:

```text
Connection closed before full header was received
```

- Gradle Kotlin incremental storage close stack during `assembleDebug` or `assembleRelease`.

---

## Current Interpretation

- Prior Home SafeArea/padding experiments did not solve viewport metrics loops and were rolled back.
- `android:windowSoftInputMode` was changed from `adjustResize` to `adjustNothing`.
- Software rendering previously made emulator GPU/virtgpu instability run normally.
- DDS failures may be tooling/service-protocol instability rather than Flutter layout failure.
- Kotlin incremental storage errors may indicate cache corruption or file locking.
- Do not assume a Flutter layout bug unless logs point there.

---

## User-Run Commands

Codex should request these step by step instead of running them:

```bash
flutter analyze
flutter test
flutter clean
flutter pub get
flutter run
flutter run -v
flutter run --enable-software-rendering
flutter run --disable-dds --enable-software-rendering
```

For Kotlin incremental storage recurrence, consider asking the user before changing Gradle properties:

```properties
kotlin.incremental=false
kotlin.incremental.useClasspathSnapshot=false
org.gradle.caching=false
```

---

## Log Triage

When a runtime/build issue recurs, ask for the first relevant failure block:

- `FAILURE`
- `What went wrong`
- first `Caused by`
- `FATAL EXCEPTION`
- `AndroidRuntime`
- `ANR`
- `SIG`
- `WindowInsets`
- `FlutterJNI`
- package/process lines for BoomCode

Only modify Android or build files when the exact log points to them.

