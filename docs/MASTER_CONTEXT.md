# MASTER_CONTEXT.md

> 목적: Codex가 긴 문서 5개를 매번 모두 다시 읽지 않아도 현재 프로젝트 상태, 규칙, 다음 작업을 빠르게 이해하고 실행하도록 만든 압축 컨텍스트 파일이다.  
> 사용법: 새 Codex 작업을 시작할 때 이 파일을 먼저 읽게 하고, 작업 완료 후 반드시 최신 상태로 갱신한다.

---

## 1. Project Identity

| 항목 | 내용 |
| --- | --- |
| App Name | BoomCode |
| Package | `bombcode` |
| Project Path | `D:\jtj\bombcode` |
| Type | Flutter offline mobile game |
| Primary Target | Android first, Flutter cross-platform structure 유지 |
| Concept | Bomb-defusal themed numeric code deduction game |
| Visual Style | Dark sci-fi industrial, brushed metal, beveled steel, red LED accent |
| Core Terms | `Access / Trace` |
| Forbidden Terms | `Strike`, `Ball`, `S/B`, baseball terminology |

### Access / Trace Meaning

- `Access`: 숫자와 위치가 모두 맞음
- `Trace`: 숫자는 맞지만 위치가 다름
- 작은 UI에서만 필요 시 `A/T` 사용 가능

---

## 2. Current Implementation Status

### Implemented

- Flutter app entry/theme structure: `lib/main.dart`, `lib/app.dart`
- Splash screen with Korean/English image selection
- Home/Main Menu with common background, logo/icon PNG parts, Flutter-rendered text on common button frames
- Common background wrapper: `lib/core/widgets/app_background.dart`
- Mission Setup screen: difficulty, digit count, attempts, timer
- Game logic: answer generation, input, judging, timer, success/failure
- Check Table: auto display and manual digit mark cycling
- Records: `shared_preferences` local records/statistics
- Tutorial placeholder and Settings screen with UI-only option controls
- Tests: `test/judge_code_test.dart`, `test/game_controller_test.dart`

### Not Implemented / Needs Work

- Final Game Screen bomb-defusal visual UI and related assets
- Main Menu final visual QA across devices
- Currency amount text and plus-button behavior
- Settings persistence for sound/music/vibration/check table/language override
- Actual audio/haptics behavior
- Shop / Remove Ads / Ads / Payment
- Formal Flutter localization system
- Android release icon, launch assets, metadata, release config
- Full responsive QA across device sizes and font scales

---

## 3. Current Issues / Risks

### Priority Risk

- Android emulator may show repeated `WindowInsets changed`, `FlutterJNI: Sending viewport metrics`, and `Lost connection to device`.
- Previous trial with `SafeArea(bottom:false)` and `MediaQuery.removePadding` did not solve it and was rolled back.
- 2026-05-05: `android:windowSoftInputMode` was changed from `adjustResize` to `adjustNothing`; user later reported the app is currently running normally.
- 2026-05-06: emulator showed `vendor.mesa.virtgpu.kumquat` and `Lost connection to device`; user confirmed `flutter run --enable-software-rendering` runs normally, so emulator GPU/virtgpu instability is likely.
- Do not assume this is only a Flutter layout issue. Check Android window/insets logs if it recurs.

### UI Risks

- Main Menu needs final visual QA: button spacing, touch target, green edge/chroma artifact.
- Mission Setup asset quality needs QA.
- `mode_select_screen.dart` is large and should later be split without behavior change.
- Home menu old/generated assets may remain. Do not delete assets before checking code references.

---

## 4. Architecture Summary

Current `lib/` structure:

```text
lib/
  main.dart
  app.dart
  core/
    constants/
    utils/
    widgets/
  data/
  domain/
    enums/
    models/
  features/
    splash/
    home/
    mode_select/
    game/
    records/
    settings/
    tutorial/
```

### Layer Rules

- `core/`: common constants, utils, reusable widgets only
- `domain/`: enums/models, no Flutter UI dependency
- `data/`: repositories and local storage implementation
- `features/`: screen/feature-specific UI and state
- Avoid large refactors.
- Do not mix UI, logic, asset, and data changes in one task.

### Important Files

| File | Purpose |
| --- | --- |
| `lib/features/home/home_screen.dart` | Home/Main Menu UI |
| `lib/features/mode_select/mode_select_screen.dart` | Mission Setup UI |
| `lib/features/game/game_controller.dart` | Game state/rules |
| `lib/core/utils/judge_code.dart` | Access/Trace judging |
| `lib/domain/models/game_config.dart` | Difficulty/default config |
| `lib/core/widgets/app_background.dart` | Common background wrapper |
| `assets/menu/background.png` | Common background image |

---

## 5. Protected File Rules

### Visual-only task에서 수정 금지

```text
lib/features/game/game_controller.dart
lib/core/utils/judge_code.dart
lib/domain/models/game_config.dart
```

### Mission Setup visual task에서 수정 금지

```text
lib/features/game/game_controller.dart
lib/core/utils/judge_code.dart
assets/menu/
android/
```

### Game Screen visual task에서 수정 금지

```text
lib/core/utils/judge_code.dart
lib/domain/models/game_config.dart
```

`game_controller.dart`는 UI 버그가 controller 문제로 증명된 경우에만 수정한다.

### General Asset Rule

- User-created/generated assets must not be deleted or replaced unless explicitly requested.
- Before deleting an old asset, confirm it is not referenced in source code or documentation.

---

## 6. UI Rules Summary

### Global

- Base canvas: `360 x 800 dp`
- Android phone portrait first
- Use `SafeArea`
- Use `LayoutBuilder` or `MediaQuery`
- Main/Menu/Setup/Game screens should remain non-scroll unless user explicitly requests otherwise
- Avoid fixed pixel layout
- Prevent vertical overflow by scaling spacing, logo, font, button, icon

### Common Background

- Use `assets/menu/background.png`
- Use `AppBackground`
- Full-screen background: `BoxFit.cover`
- Do not create per-screen full background unless requested

### Text / Localization

- Korean/English text should be rendered in Flutter widgets when possible
- Current language helper: `lib/core/constants/app_text.dart`
- Main Menu button text must be Flutter-rendered text, not baked into active button images
- Logo may remain language-specific baked image

### Main Menu

- Active UI is assembled from independent parts, not one giant full-screen menu image
- Do not reintroduce visible exit button
- Start Game: red primary button
- Difficulty / Records / Settings: dark secondary buttons
- Shop / Remove Ads / Help: icon-only utility buttons with Semantics label
- Touch area and visible icon size are separated
- Currency panel is currently blank future display frame

### Mission Setup

- Keep single-screen non-scroll structure
- Keep `LayoutBuilder`
- Use common background
- Text must be Flutter-rendered
- Plus/minus image assets must not include `+` or `-`; symbols are overlaid in code
- `assets/mission_setup/` PNGs should be transparent
- Difficulty button text remains Flutter-rendered; selected/off frames are image assets only.
- Difficulty selected/off assets were rebuilt from user-provided `D:\download\New_button.png` and `D:\download\New_off.png`.
- Attempts/Time slider badge, ticks, and thumb position should stay synchronized from one source list.
- Start Mission button has no key icon; text is centered.
- Digits / Timer / Reward summary card has enlarged icons, text, padding, and height.

---

## 7. Game Rules Summary

### Difficulty Defaults

| Difficulty | Digits | Attempts |
| --- | ---: | ---: |
| Beginner | 2 | 20 |
| Normal | 3 | 12 |
| Expert | 4 | 7 |

### Timer Options

```text
OFF / 5 min / 10 min / 20 min
```

### LimitMode

```text
If time is OFF:
  LimitMode.attemptsOnly

If time is enabled:
  LimitMode.attemptsAndTime
```

### Confirmation Needed

- Check whether `GameConfig.defaults()` and Mission Setup timer selector defaults fully match the intended document rules.

---

## 8. Current Task Board Snapshot

### Priority 1

- `Task 1.0` Android viewport metrics 반복 / 자동 종료 원인 확인 — TODO
- `Task 1.1` Analyze/Test 이슈 수정 — TODO

### Priority 2

- `Task 2.0` Main Menu Visual QA 및 Asset Cleanup — DONE, but visual reference comparison and artifact cleanup checks remain
- `Task 2.1` Mission Setup Asset Visual QA — TODO
- `Task 2.2` Mission Setup Layout Fine Tuning — DONE
- `Task 2.3` Mission Setup Widget 분리 — TODO

### Priority 3

- `Task 3.1` Game Screen Asset List 정의 — TODO
- `Task 3.2` Game Screen Assets 생성 — TODO
- `Task 3.3` Game Screen Design 적용 — TODO

### Later

- `Task 4.1` Localization improvement
- `Task 5.1` Settings persistence
- `Task 6.1` Records improvement
- `Task 7.1` Android release readiness

### 2026-05-05 Snapshot Correction

- Task 1.0 Android viewport metrics repeat / auto-exit check: WATCH after `android:windowSoftInputMode="adjustNothing"`; user reported current run is normal.
- Task 1.0 update: if emulator GPU/virtgpu logs recur, try `flutter run --enable-software-rendering`; this was confirmed normal on 2026-05-06.
- Task 2.1 Mission Setup Asset Visual QA: DONE / WATCH after slider track padding fix and difficulty on/off asset rebuild.
- Task 2.2 Mission Setup Layout Fine Tuning: DONE after spacing, slider sync, summary time display, summary card enlargement, and Start Mission text alignment updates.

---

## 9. Recommended Next Task Selection Rule

Codex should select only ONE task per session.

### If emulator/app exits or connection is unstable

Choose:

```text
Task 1.0 Android viewport metrics 반복 / 자동 종료 원인 확인
```

### If user provides analyze/test errors

Choose:

```text
Task 1.1 Analyze/Test 이슈 수정
```

### If app runs but Main Menu still needs visual check

Choose:

```text
Task 2.0 remaining QA only
```

### If moving forward with UI polish

Choose:

```text
Task 2.2 Mission Setup Layout Fine Tuning
```

### If preparing final gameplay UI

Choose:

```text
Task 3.1 Game Screen Asset List 정의
```

---

## 10. Codex Execution Rules

Codex must:

1. Read this `MASTER_CONTEXT.md`.
2. Read `docs/NEXT_TASKS.md`.
3. Pick exactly ONE task unless the user specifies another task.
4. Read target files before modifying.
5. Make the smallest safe change.
6. Modify only task-relevant files.
7. Avoid broad refactor.
8. Do not run build/test/analyze unless user explicitly allows.
9. After work, update:
   - `docs/PROJECT_STATUS.md` if status changed
   - `docs/NEXT_TASKS.md` task state
   - `docs/MASTER_CONTEXT.md` current status/task snapshot
10. Report:
   - changed files
   - summary
   - commands user should run
   - next recommended task

---

## 11. Commands User Usually Runs

```bash
flutter pub get
dart format .
flutter analyze
flutter test
flutter run
```

If emulator/debug connection is unstable:

```bash
flutter clean
flutter pub get
flutter run
```

Additional manual steps:

- Android Emulator cold boot
- Create new emulator image
- If `Ctrl + C` stops `flutter run` and connection gets unstable, restart emulator

---

## 12. Work Session Update Area

> Codex must update this area after each task.

### Last Updated

- Date: 2026-05-05
- Updated By: Codex

### Current Active Task

- Task ID: Task 2.1 / 2.2 follow-up
- Task Name: Mission Setup Asset + Layout Visual Tuning
- Status: DONE
- Target Files: `lib/features/mode_select/mode_select_screen.dart`, `assets/mission_setup/difficulty_*_on.png`, `assets/mission_setup/difficulty_*_off.png`, `assets/mission_setup/slider_track.png`, `android/app/src/main/AndroidManifest.xml`, `docs/NEXT_TASKS.md`, `docs/PROJECT_STATUS.md`, `docs/MASTER_CONTEXT.md`

### Latest Result

- Changed Files: `lib/features/mode_select/mode_select_screen.dart`, `assets/mission_setup/slider_track.png`, `assets/mission_setup/difficulty_beginner_on.png`, `assets/mission_setup/difficulty_normal_on.png`, `assets/mission_setup/difficulty_expert_on.png`, `assets/mission_setup/difficulty_beginner_off.png`, `assets/mission_setup/difficulty_normal_off.png`, `assets/mission_setup/difficulty_expert_off.png`, `android/app/src/main/AndroidManifest.xml`, `docs/NEXT_TASKS.md`, `docs/PROJECT_STATUS.md`, `docs/MASTER_CONTEXT.md`
- Summary: Mission Setup slider track transparent padding was removed. Difficulty selected/off frames were rebuilt from user-provided button art with transparent outer background and preserved inner dark panel. Section title style, summary time display, summary card icon/text/card size, slider value/tick/thumb synchronization, Difficulty/LIMIT MODE spacing, and Start Mission text alignment were tuned while preserving non-scroll LayoutBuilder structure and gameplay behavior.
- Remaining Issues: Final visual QA on real/emulated devices is still needed. Android viewport metrics issue is currently normal after `adjustNothing`; emulator GPU/virtgpu disconnect was normal with `--enable-software-rendering` and should be watched if it recurs. Task 2.3 widget split remains pending.
- User Commands To Run: `dart format .`, `flutter analyze`, `flutter test`, `flutter run`

---
