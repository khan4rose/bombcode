# NEXT_TASKS

This file splits future work into safe chat-sized tasks. Each task should be handled in a separate Codex chat when possible.

## Priority 1: Stabilize Current Build

### Task 1.1 - Run and Fix Analyze/Test Issues

Goal:
- Fix only issues reported by `flutter analyze` and `flutter test`.

Do:
- Read the exact error/warning output from the user.
- Patch only files mentioned by the analyzer/test failure.
- Keep fixes minimal.

Do not touch:
- `assets/`
- `android/`
- unrelated feature screens

Expected checks:

```bash
dart format .
flutter analyze
flutter test
```

## Priority 2: Mission Setup Screen Polish

### Task 2.1 - Visual QA for Mission Setup Assets

Goal:
- Review and replace any mission setup PNG that does not match the dark sci-fi metal style.

Do:
- Work only inside `assets/mission_setup/`.
- Keep every asset transparent PNG.
- Do not bake text, letters, numbers, `+`, or `-` into images unless explicitly requested.

Do not touch:
- `lib/features/game/`
- `lib/domain/`
- `lib/data/`
- `android/`

### Task 2.2 - Mission Setup Layout Fine Tuning

Goal:
- Make Mission Setup match the reference design more closely while staying one-screen and non-scroll.

Do:
- Edit `lib/features/mode_select/mode_select_screen.dart`.
- Keep `LayoutBuilder`.
- Keep the common background `assets/menu/background.png`.
- Keep all text rendered by Flutter widgets.

Do not touch:
- `lib/features/game/game_controller.dart`
- `lib/core/utils/judge_code.dart`
- `assets/menu/`
- `android/`

### Task 2.3 - Split Mission Setup Widgets

Goal:
- Reduce `mode_select_screen.dart` size without changing behavior.

Do:
- Move private widgets into files under:

```text
lib/features/mode_select/widgets/
```

Do not change:
- UI behavior
- layout proportions
- assets
- game config rules

Do not touch:
- `lib/features/game/`
- `lib/domain/`
- `assets/`

## Priority 3: Gameplay Screen Redesign

### Task 3.1 - Define Game Screen Asset List

Goal:
- List required gameplay UI assets with sizes before generating images.

Do:
- Create/update a planning doc only.
- Include assets for code slots, keypad buttons, status panels, history rows, check table, pause button.

Do not touch:
- Dart source files
- existing assets

### Task 3.2 - Generate Game Screen Assets

Goal:
- Generate gameplay UI assets in the same sci-fi metal style.

Do:
- Save under:

```text
assets/game/
```

Do not touch:
- Game logic
- Mission setup assets

### Task 3.3 - Apply Game Screen Design

Goal:
- Update `GameScreen` to use final assets and responsive layout.

Do:
- Edit only:
  - `lib/features/game/game_screen.dart`
  - `lib/features/game/widgets/*`
  - possibly `lib/core/widgets/app_background.dart`

Do not touch:
- `lib/features/game/game_controller.dart` unless a UI bug proves a controller change is necessary.
- `lib/core/utils/judge_code.dart`
- `lib/domain/models/game_config.dart`

## Priority 4: Localization

### Task 4.1 - Convert AppText to Structured Localization

Goal:
- Replace ad hoc `AppText` with a cleaner project-local string structure or Flutter ARB localization.

Do:
- Keep current Korean/English behavior.
- Preserve `PlatformDispatcher` fallback until localization is fully wired.

Do not touch:
- game logic
- assets
- Android manifest

## Priority 5: Settings Persistence

### Task 5.1 - Persist Settings

Goal:
- Save sound/music/vibration/auto check table defaults locally.

Do:
- Add a settings repository.
- Use `shared_preferences`.
- Load settings into Mission Setup.

Do not touch:
- records storage schema unless absolutely required.
- gameplay judgement logic.

## Priority 6: Records Improvements

### Task 6.1 - Improve Records Screen

Goal:
- Match final visual style and improve stats display.

Do:
- Edit records screen only.
- Keep `GameRecord` schema stable unless a migration plan is added.

Do not touch:
- game controller
- mission setup

## Priority 7: Android Release Readiness

### Task 7.1 - Launch and Icon Polish

Goal:
- Finalize Android launch screen, app icon, labels, package metadata.

Do:
- Work under `android/` and assets as needed.

Do not touch:
- Flutter game logic
- mission setup UI

## General Task Rules

- One chat should focus on one task group.
- Always read current files before editing.
- Do not rewrite unrelated files.
- Preserve user-created assets.
- Do not delete generated assets unless the user explicitly requests it.
- At the end of each task, report:
  - changed files
  - what changed
  - commands the user should run
