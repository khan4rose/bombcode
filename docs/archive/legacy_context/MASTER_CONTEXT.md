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
- Game Screen asset-backed UI 1st pass: header/status, code slots, keypad, latest Access/Trace, recent history, check table, pause/result modal
- Game Screen bomb-centric simplified layout: top status/READY/pause/main Check Table bar removed, bomb hero overlay and compact history/keypad applied
- Game Screen final polish in progress: `Bomb HUD -> Current Code -> Keypad -> History`, compact keypad, tactical history table, History-integrated Check Table button
- Game Screen success/failure result overlay polish: generated result ambience overlays and displays result presentation over the existing gameplay screen.
- Game Screen bomb stage animation: fixed hero image with stage-specific looping light/glow overlays, crossfaded state image changes, and no shake/scale movement.
- Game Screen keypad press feedback: number/delete buttons have subtle scale press feedback; submit has a stronger press response while disabled buttons remain static.
- Game sound effect foundation: settings-aware `SystemSound` call points for keypad/delete/submit/success/failure.
- Game haptic feedback foundation: settings-aware `HapticFeedback` call points for keypad/delete/submit/success/failure/critical.
- Mission Setup Attempts Limit supports OFF, and the last selected `GameConfig` is saved with `shared_preferences`.
- Home Start Game launches directly with the last saved `GameConfig`; first-run fallback is Normal + Attempts OFF + Time OFF.
- Game Screen bomb-centric redesign plan and Task 3.2-E required assets
- Bomb hero/device visual rework for `bomb_device_frame.png` and `bomb_hero_*`
- Check Table: auto display and manual digit mark cycling
- Records: `shared_preferences` local records/statistics
- Tutorial placeholder and Settings screen with UI-only option controls
- Tests: `test/judge_code_test.dart`, `test/game_controller_test.dart`

### Not Implemented / Needs Work

- Final Game Screen live responsive QA after latest polish
- Main Menu final visual QA across devices
- Currency amount text and plus-button behavior
- Settings persistence still needed for music/check table/language override; sound volume and vibration enabled are now persisted.
- Custom audio asset playback / audio package integration
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
- 2026-05-07: DDS WebSocket startup failed repeatedly with `Connection closed before full header was received`; try `flutter run --disable-dds --enable-software-rendering`.
- 2026-05-07: Gradle Kotlin incremental storage close stack appeared during `assembleDebug`/`assembleRelease`; cache cleanup and disabling Kotlin incremental build may be needed.
- Do not assume this is only a Flutter layout issue. Check Android window/insets logs if it recurs.

### UI Risks

- Main Menu needs final visual QA: button spacing, touch target, green edge/chroma artifact.
- Mission Setup asset quality needs QA.
- Game Screen latest polish needs `dart format`, `flutter analyze`, `flutter test`, and live 360x800-style overflow/touch-target/icon affordance QA.
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
- MVP is portrait-only. `lib/main.dart` locks Flutter orientation to `DeviceOrientation.portraitUp`, and Android `MainActivity` declares `android:screenOrientation="portrait"`.
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

### Game Screen

- Use common background through `AppBackground`.
- Asset-backed UI 1st pass is applied in `lib/features/game/game_screen.dart` and `lib/features/game/widgets/*`.
- `pubspec.yaml` includes `assets/game/`.
- New helper widgets:
  - `lib/features/game/widgets/game_asset_paths.dart`
  - `lib/features/game/widgets/asset_frame.dart`
- Current applied asset areas:
  - bomb hero: `bomb_hero_stable.png`, `bomb_hero_caution.png`, `bomb_hero_danger.png`, `bomb_hero_critical.png`
  - current code: `current_code_panel.png`, `code_slot_empty.png`, `code_slot_filled.png`, `code_slot_selected.png`
  - `NumberKeypad`: `keypad_button_idle.png`, `keypad_button_pressed.png`, `keypad_button_disabled.png`, `keypad_delete_button.png`, `keypad_submit_button.png`, `keypad_submit_disabled.png`
  - recent history: `history_panel.png`, `history_row_panel.png`
  - Check Table: main screen uses a top-right icon button; bottom sheet reuses `check_table_panel.png`, `digit_marker_*`
  - result modal: `result_modal_success.png`, `result_modal_failure.png`, `modal_primary_button.png`, `modal_secondary_button.png`
  - result overlay ambience: `bomb_defused_overlay.png`, `bomb_exploded_overlay.png`
- Removed from active main gameplay layout:
  - `LimitStatusBar` top header/status panels
  - `bomb_device_frame.png`
  - READY panel / `access_trace_panel.png`
  - pause button / pause overlay
  - main inline Check Table bar and tried/current count utility bar
- Text and digits remain Flutter-rendered.
- Access / Trace terms are preserved.
- Latest Game Screen visual flow is `Bomb HUD -> Current Code -> Keypad -> History`.
- Bomb HUD no longer shows difficulty text. It shows `LEFT / TIME` labels and large LED-style remaining attempts/time.
- Bomb HUD label/number color is synchronized with bomb stage color. The central divider was removed.
- Bomb HUD shows `OFF` for unlimited attempts. Attempts OFF is represented by `GameConfig.maxAttempts == null`.
- Bomb hero stage animation uses fixed-position hero images with looping light/glow overlays only. Stage image changes are crossfaded; shake, jitter, and scale movement are avoided.
- Current Code uses a light Flutter frame and visible slot assets instead of a heavy background panel.
- Keypad is compact, centered on the Current Code axis, keeps 48dp touch target height, and uses subtle scale press feedback.
- History is a compact tactical deduction table with shared header/row columns, latest row first, `A` green and `T` blue.
- History panel polish now covers the baked-in inner frame with a single flat tactical surface, adds very subtle CustomPainter grain/brushed texture, and aligns `# / CODE / RESULT` header columns with row content.
- Empty History uses compact `STANDBY` instead of a large `No attempts yet.` panel.
- Check Table entry moved into the History panel top-right area and opens the existing bottom sheet.
- Check Table entry uses `assets/game/check_table_bulb_icon.png` inside an icon-only circular frame aligned near the History header; a Flutter `CustomPainter` bulb remains as an asset-load fallback.
- Bomb hero 4 states had near-white matte pixels darkened; `.bak_matte` backups may exist beside the PNGs.
- `bomb_hero_critical.png` canvas remains `720x405`, but its internal content was slightly reduced to better match the optical size of stable/caution/danger.
- Access/Trace judging remains unchanged. `game_controller.dart` and `game_config.dart` were later updated only to support Attempts OFF / no-limit config rules.
- `dart format` should not be run on `pubspec.yaml`; use `flutter pub get` after YAML changes.
- `docs/GAME_SCREEN_REDESIGN_PLAN.md` defines the next bomb-centric main play layout.
- Task 3.2-E generated required bomb-centric assets: `bomb_hero_stable.png`, `bomb_hero_caution.png`, `bomb_hero_danger.png`, `bomb_hero_critical.png`, `current_code_panel.png`, `check_table_open_button.png`, `keypad_delete_button.png`, `keypad_submit_button.png`, `keypad_submit_disabled.png`, `check_table_modal_panel.png`, `modal_close_button.png`, and `main_play_required_assets_preview.png`.
- Latest visual rework updated only `bomb_device_frame.png`, `bomb_hero_stable.png`, `bomb_hero_caution.png`, `bomb_hero_danger.png`, `bomb_hero_critical.png`, and `main_play_required_assets_preview.png`.
- Bomb hero 4 states are `720x405 RGBA` with the same canvas, alignment, body silhouette, and display-safe areas after user-image transparency and size normalization.
- `bomb_device_frame.png` is `720x260 RGBA` and now reads more like a small bomb input module.

---

## 7. Game Rules Summary

### Difficulty Defaults

| Difficulty | Digits | Attempts |
| --- | ---: | ---: |
| Beginner | 2 | 20 |
| Normal | 3 | 12 |
| Expert | 4 | 7 |

### First-Run / Saved Config

- Home Start Game loads the last saved `GameConfig`.
- If no saved config exists, first-run default is Normal + Attempts OFF + Time OFF.
- Mission Setup saves the selected config when Start Mission is pressed.

### Attempts Options

```text
OFF / 7 / 10 / 13 / 15 / 20
```

### Timer Options

```text
OFF / 5 min / 10 min / 20 min
```

### LimitMode

```text
If attempts is OFF and time is OFF:
  LimitMode.none

If attempts is ON and time is OFF:
  LimitMode.attemptsOnly

If attempts is OFF and time is ON:
  LimitMode.timeOnly

If attempts is ON and time is ON:
  LimitMode.attemptsAndTime
```

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

- `Task 3.1` Game Screen Asset List 정의 — DONE
- `Task 3.2-A` Core Input Assets — DONE
- `Task 3.2-B` Status / History Panel Assets — DONE
- `Task 3.2-C` Check Table / Memo Assets — DONE
- `Task 3.2-D` Modal / Result Assets — DONE
- `Task 3.2-E` Main Play Redesign Required Assets — DONE
- `Task 3.2-E Visual Rework` Bomb Hero / Device Assets — DONE
- `Task 3.3-A` Game Screen Asset-backed Layout Implementation — DONE / SUPERSEDED
- `Task 3.3-C` Main Play Screen Bomb-Centric Layout Implementation — DONE / VERIFY BLOCKED BY BUILD
- `Task 3.3-D` Check Table Modal / Bottom Sheet Implementation — PARTIAL
- `Task 3.3-E` Game Screen Responsive QA and Visual Polish — IN PROGRESS / LATEST POLISH VERIFY NEEDED

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
- Task 3.1 Game Screen Asset List: DONE after creating `docs/GAME_SCREEN_ASSET_LIST.md`.
- Task 3.1 update: `docs/GAME_SCREEN_ASSET_LIST.md` now includes asset size rule, Required/Optional priority, visual style detail, layout priority, check table display rule, and phased Task 3.2 generation order.
- Task 3.2-A/B/C/D Game Screen asset generation: DONE. Generated and polished core input, status/history, check table/memo, and modal/result assets under `assets/game/`.
- Task 3.2-E Game Screen bomb-centric redesign planning/assets: DONE. Created `docs/GAME_SCREEN_REDESIGN_PLAN.md`, generated required new assets, and created `assets/game/main_play_required_assets_preview.png`.
- Task 3.2-E visual rework: DONE. Reworked `bomb_device_frame.png` and `bomb_hero_stable/caution/danger/critical.png` to look more like stylized but believable bomb-defusal devices with side housings, cables, connectors, bolts, warning lights, and recessed display-safe areas.
- Task 3.2-E validation: bomb hero 4 states were generated as `720x400 RGBA`; later user-provided hero replacements were normalized to `720x405 RGBA`, transparent corners alpha 0.
- Task 3.3-A update: Game Screen asset-backed layout 1st pass applied. Awaiting `flutter analyze`, `flutter test`, and live UI QA.
- Task 3.3-C update: simplified bomb-centric Game Screen applied. Top status panels, READY panel, pause button, main Check Table bar, and utility count bar were removed. Bomb hero overlay, current code panel, compact scrollable history, top-right Check Table icon, and dedicated delete/submit keypad assets were connected.
- Task 3.3-E update: Game Screen final polish is in progress. The active flow is now `Bomb HUD -> Current Code -> Keypad -> History`. Difficulty text was removed from Bomb HUD, `LEFT/TIME` LED HUD uses stage color sync, Current Code uses a light frame, keypad is compact and centered, History is a tactical table, and Check Table entry is integrated into the History panel.
- Task 3.3-E latest note: 360x800 overflow was reported and addressed by reducing bomb hero, code, keypad, and history spacing. Later polish cleaned up the History inner frame by overlaying a single dark tactical surface, added subtle surface texture, aligned History header/body columns, replaced the Check Table entry with a bulb PNG in a circular icon frame, and slightly reduced the critical bomb hero optical size. Latest format/analyze/live QA is still needed.
- Task 3.3-E animation/feedback update: Bomb hero state animation now loops with fixed-position light/glow overlays only, state image changes crossfade naturally, and keypad/delete/submit buttons have scale press feedback without changing layout or touch target size.
- Task 3.3-E result presentation update: generated `bomb_defused_overlay.png` and `bomb_exploded_overlay.png`, then changed success/failure presentation to layer a dark translucent overlay, result ambience image, and existing result modal over the current gameplay screen with fade/scale motion. Live brightness/readability/overflow QA is still needed.
- Game feedback foundation update: Added `lib/core/utils/game_sound_effects.dart` and `lib/core/feedback/game_haptics.dart`. Sound uses settings-aware `SystemSound`; haptics use settings-aware `HapticFeedback`. No audio/haptic package dependencies were added.
- Mission Setup / Home config update: Attempts OFF is available, no-limit mode is represented by `LimitMode.none`, last `GameConfig` is persisted via `LocalGameConfigRepository`, and Home Start Game launches directly with the last saved config or Normal + Attempts OFF + Time OFF on first run.
- Orientation update: MVP now locks the whole app to portrait via Flutter `SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])` and Android `android:screenOrientation="portrait"` to avoid unsupported landscape overflow.
- Current runtime note: Dart Dev Service connection failure and Gradle Kotlin incremental storage errors are blocking live QA. Try `flutter run --disable-dds --enable-software-rendering`, cache cleanup, and `kotlin.incremental=false` if the Kotlin storage stack recurs.

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
Task 3.3-E Game Screen Responsive QA and Visual Polish
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
flutter run --disable-dds --enable-software-rendering
```

Additional manual steps:

- Android Emulator cold boot
- Create new emulator image
- If `Ctrl + C` stops `flutter run` and connection gets unstable, restart emulator

---

## 12. Work Session Update Area

> Codex must update this area after each task.

### Last Updated

- Date: 2026-05-07
- Updated By: Codex

### Current Active Task

- Task ID: Session Roll-up / Docs Update
- Task Name: Gameplay Feedback, Config, and Result Overlay Summary
- Status: UPDATED / VERIFY NEEDED
- Target Files: `docs/MASTER_CONTEXT.md`, `docs/NEXT_TASKS.md`

### Latest Result

- Changed Files: `lib/features/game/game_screen.dart`, `lib/features/game/widgets/game_asset_paths.dart`, `lib/features/game/widgets/number_keypad.dart`, `lib/core/utils/game_sound_effects.dart`, `lib/core/feedback/game_haptics.dart`, `lib/features/settings/settings_screen.dart`, `lib/domain/enums/limit_mode.dart`, `lib/domain/models/game_config.dart`, `lib/data/local_game_config_repository.dart`, `lib/features/home/home_screen.dart`, `lib/features/mode_select/mode_select_screen.dart`, `lib/features/game/game_controller.dart`, `test/game_controller_test.dart`, `test/local_game_config_repository_test.dart`, `assets/game/bomb_defused_overlay.png`, `assets/game/bomb_exploded_overlay.png`, `docs/MASTER_CONTEXT.md`, and `docs/NEXT_TASKS.md`.
- Summary: Rolled up the latest work: fixed-position bomb stage light/glow animation with crossfaded hero state images, keypad/delete/submit press feedback, sound effect foundation, haptic feedback foundation, Attempts OFF/no-limit config support, last-config persistence and Home direct Start Game, plus success/failure result ambience overlays over the existing Game Screen. Access/Trace judging, assets outside `assets/game/`, Android, and dependencies were not changed.
- Remaining Issues: Latest `dart format .`, `flutter analyze`, `flutter test`, and live run verification are still needed. QA should cover no-limit gameplay, saved config reload, sound/haptic setting behavior, result overlay brightness/readability, small-screen fit, and emulator DDS/Gradle stability.
- User Commands To Run: `dart format .`, `flutter analyze`, `flutter test`, `flutter run --disable-dds --enable-software-rendering`; if Kotlin incremental storage recurs, clean Gradle caches and set `kotlin.incremental=false`.

---
