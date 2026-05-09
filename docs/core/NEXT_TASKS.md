# NEXT_TASKS

Only active, blocked, or future work belongs here.
Completed task details belong in `docs/core/PROJECT_HISTORY.md` or `docs/archive/`.

---

## Task Rules

- Choose exactly one task per session unless the user specifies otherwise.
- Read `docs/core/MASTER_CONTEXT.md` and this file first.
- Read only task-relevant guides from `docs/guides/`.
- Modify only task-relevant files.
- For visual-only work, protect `game_controller.dart`, `judge_code.dart`, and `game_config.dart`.
- Codex must not run `dart format`, `flutter analyze`, `flutter test`, or `flutter run`; ask the user to run them step by step.

---

## Priority 1. Stability

### Task 1.0 Android/DDS/Gradle Build Stabilization

Status: WATCH / BLOCKED WHEN REPRODUCED

Goal:

- Diagnose emulator exit, DDS WebSocket failure, viewport metric loops, or Gradle Kotlin incremental storage errors only when they recur.

Read:

- `docs/guides/BUILD_ISSUES.md`

Do not modify:

- Game judgment logic
- Difficulty/config rules
- Ads/shop/payment
- Records schema unless required by exact error

---

## Priority 2. Main Menu / Mission Setup

### Task 2.0 Main Menu Remaining Visual QA

Status: TODO

Goal:

- Compare live Main Menu against reference images and check spacing, touch targets, currency panel, utility icons, and green/chroma artifacts.

Read:

- `docs/guides/UI_GUIDELINES.md`
- `docs/guides/ASSET_RULES.md`

### Task 2.3 Mission Setup Widget Split

Status: TODO

Goal:

- Split `mode_select_screen.dart` private widgets without behavior or layout changes.

Do not modify:

- `lib/features/game/`
- `lib/domain/`
- `assets/`

---

## Priority 3. Game Screen

### Task 3.3-E Game Screen Responsive QA and Visual Polish

Status: IMPLEMENTED / VERIFY NEEDED

Goal:

- Finish live QA and final polish for the current bomb-centric Game Screen and layered cinematic result overlay.

Current focus:

- Verify Success and Failure overlays on `360x800` and smaller portrait heights.
- Check `TRY AGAIN` and `HOME` visibility, text readability, and `BOTTOM OVERFLOWED` absence.
- Verify all 4 localized result combinations:
  Failure English, Failure Korean, Success English, Success Korean.
- For Failure, confirm the gameplay layer is hidden while the bomb/explosion/smoke background remains visible.
- For Failure, confirm the reveal animation is skippable by tapping and does not accidentally trigger result buttons while skipping.
- For Success, confirm it now uses the same layered cinematic structure rather than an old modal-style result.

Implemented notes:

- Active gameplay layout was made more responsive for short portrait heights.
- Result overlay was refactored into a shared layered system:
  background image, panel/frame image, localized title image, Flutter dynamic text/buttons.
- Result asset helpers were added in `game_asset_paths.dart` for success/failure and Korean/English title selection.
- Result assets were added/replaced under `assets/game/result/`.
- Failure result was replaced with the user-provided final failure assets:
  `failure_scene_bg.png`, `failure_result_panel.png`, `failure_title_en.png`, `failure_title_ko.png`,
  `result_button_primary.png`, and `result_button_secondary.png`.
- Failure no longer renders `_GameplayView` behind the result scene; this separates gameplay hiding from failure background visibility.
- Failure reveal now uses Flutter animation only:
  the detonation background appears immediately, the screen shakes briefly, explosion light flickers over the background for about 1.5 seconds, then panel/title/code/buttons appear nearly together with a slower shade reveal.
- Strong full-screen red flash was removed from the Failure reveal; visual impact now comes from shake, background brightness/contrast flicker, and a warm explosion-light overlay.
- Failure result assets are precached in `GameScreen` so the detonation background does not show a blank first frame.
- Failure reveal tap-to-skip jumps to the final state and keeps `TRY AGAIN` / `HOME` disabled until the reveal is complete.
- Failure panel and result button assets had only technical transparency/crop cleanup; no new artwork was generated.
- Failure layout was further polished so the answer area shows only the correct code, with a small cyber/metal key icon before it; `ANSWER`, `ATTEMPTS`, and `TIME` are not shown on the Failure result.
- A new transparent key icon asset was added at `assets/game/result/result_key_icon.png` and wired through `GameAssetPaths.resultKeyIcon`.
- Failure background/panel composition was adjusted upward/taller for better visual balance, with larger buttons and a larger key/code presentation.
- Success was upgraded to the same layered result architecture with `assets/game/result/success_bg.png`, `success_panel.png`, and localized title assets.
- Success visuals were not intentionally changed in the failure-only replacement pass.
- Dynamic values and button labels remain Flutter-rendered.

Read:

- `docs/guides/GAME_SCREEN_GUIDE.md`
- `docs/guides/UI_GUIDELINES.md`
- `docs/guides/ASSET_RULES.md` only if assets are involved

Allowed:

- `lib/features/game/game_screen.dart`
- `lib/features/game/widgets/*`
- `assets/game/result/*` for explicit result screen asset replacement or polish only

Protected:

- `lib/features/game/game_controller.dart`
- `lib/core/utils/judge_code.dart`
- `lib/domain/models/game_config.dart`
- Other `assets/game/*.png` unless the user explicitly requests asset edits

User verification sequence:

```bash
dart format lib/features/game/game_screen.dart lib/features/game/widgets/game_asset_paths.dart
flutter analyze
flutter test
flutter run --disable-dds --enable-software-rendering
```

### Task 3.3-D Check Table Modal Asset Application

Status: TODO / PARTIAL FOUNDATION EXISTS

Goal:

- Apply `check_table_modal_panel.png` and `modal_close_button.png` to the existing Check Table bottom sheet without changing digit mark behavior.

Read:

- `docs/guides/GAME_SCREEN_GUIDE.md`

---

## Priority 4. Localization

### Task 4.1 AppText Structure Improvement

Status: TODO

Goal:

- Improve the current ad hoc `AppText` approach or plan ARB localization while preserving Korean/English fallback behavior.

Protected:

- Game logic
- Assets
- Android manifest

---

## Priority 5. Settings Persistence

### Task 5.1 Remaining Settings Persistence

Status: PARTIAL

Goal:

- Persist music, auto check table, and language override settings.
- Keep existing sound volume, vibration, and last `GameConfig` persistence behavior.

Protected:

- Records schema unless absolutely required
- Gameplay judging logic

---

## Priority 6. Records

### Task 6.1 Records Screen Improvement

Status: TODO

Goal:

- Polish Records visual style and improve stats display.

Protected:

- Game controller
- Mission Setup

---

## Priority 7. Release

### Task 7.1 Android Release Readiness

Status: TODO

Goal:

- Prepare Android launch screen, icon, app label, metadata, and release config.

Read:

- `docs/guides/BUILD_ISSUES.md` if build problems occur
- `docs/guides/ASSET_RULES.md` if creating or replacing launch/icon assets

Protected:

- Flutter game logic
- Mission Setup UI
