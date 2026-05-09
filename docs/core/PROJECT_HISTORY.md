# PROJECT_HISTORY

This is the compact history index for completed or superseded work.
Raw legacy details are preserved under `docs/archive/`.
Codex should not read this file for every task; read it only when historical context matters.

---

## Archive Map

| Archive Path | Contains |
| --- | --- |
| `docs/archive/legacy_context/MASTER_CONTEXT.md` | Old oversized master context with full session roll-up |
| `docs/archive/legacy_context/NEXT_TASKS.md` | Old task board with completed task details |
| `docs/archive/legacy_context/PROJECT_STATUS.md` | Old broad project status snapshot |
| `docs/archive/completed_plans/GAME_SCREEN_REDESIGN_PLAN.md` | Original Game Screen redesign plan |
| `docs/archive/completed_plans/GAME_SCREEN_ASSET_LIST.md` | Original Game Screen asset inventory and generation plan |
| `docs/archive/completed_plans/codex_mission_setup_assets.md` | Original Mission Setup asset generation notes |
| `docs/archive/legacy_references/BoomCode_Flutter_Codex.md` | Early full project reference/spec |

---

## Completed Work Summary

### App Foundation

- Flutter app entry and theme structure created through `lib/main.dart` and `lib/app.dart`.
- Splash screen selects Korean/English image by device language.
- Common background wrapper exists at `lib/core/widgets/app_background.dart`.
- MVP orientation is portrait-only in Flutter and Android.

### Home / Main Menu

- Main Menu is assembled from separate PNG parts plus Flutter-rendered text.
- Visible exit button was removed.
- Start Game uses red primary frame; Difficulty/Records/Settings use dark secondary frames.
- Shop, Remove Ads, and Help use icon-only utility buttons.
- Currency panel remains a blank future-display frame.

### Mission Setup

- Mission Setup uses common background, `LayoutBuilder`, and non-scroll portrait layout.
- Difficulty on/off assets were rebuilt from user-provided button references.
- Attempts and Timer sliders synchronize badge, ticks, and thumb from one value list.
- Attempts OFF is supported.
- Start Mission saves the selected config.

### Game Logic

- Game supports answer generation, digit input, delete, submit, timer, success/failure, and records.
- `Access`/`Trace` judging is covered by tests.
- Attempts OFF is represented by `GameConfig.maxAttempts == null`.
- `LimitMode.none`, `attemptsOnly`, `timeOnly`, and `attemptsAndTime` are supported.
- Home Start Game loads the last saved `GameConfig`; first run uses Normal + Attempts OFF + Time OFF.

### Game Screen Assets and Layout

- Game asset paths and reusable `AssetFrame` widget were added.
- Task 3.2-A/B/C/D generated core input, status/history, Check Table, and modal/result assets.
- Task 3.2-E generated bomb-centric main play assets.
- Bomb hero/device assets were visually reworked to feel like stylized bomb-defusal hardware.
- Main Game Screen shifted from dashboard layout to `Bomb HUD -> Current Code -> Keypad -> History`.
- Top status panels, READY panel, pause button, inline Check Table bar, and utility count bar were removed from active gameplay.
- Check Table opens from the History area and uses existing digit markers in a bottom sheet.
- History was polished into a compact tactical table with subtle texture and aligned columns.
- Bomb hero stage animation uses fixed image position with light/glow overlays and crossfaded stage changes.
- Keypad press feedback was added for number/delete/submit buttons.

### Result Overlay

- Success/failure ambience overlays were generated:
  - `assets/game/bomb_defused_overlay.png`
  - `assets/game/bomb_exploded_overlay.png`
- Result presentation changed from a separate full screen to an overlay above the current Game Screen.
- Later polish focused on preserving cinematic ambience while maintaining modal safe area and button visibility.
- Task 3.3-E responsive QA/polish improved short portrait fit for active gameplay and result overlays.
- Failure result was redesigned from a generic modal/card into a dedicated cinematic warning scene.
- `assets/game/failure_warning_panel.png` was added as a transparent, text-free industrial warning panel frame.
- Earlier Failure warning-panel work overlaid Flutter-rendered `MISSION FAILED`, `DEVICE DETONATED`, stats, `TRY AGAIN`, and `HOME` over the panel asset.
- Failure hides the gameplay layer itself so keypad/history/current code do not need to be obscured by heavy central fog.
- Failure background composition now prioritizes visible bomb/explosion/smoke ambience, with only localized lower masking for any residual gameplay area.
- Result UI was later refactored into a shared 4-layer cinematic architecture for both Success and Failure:
  background image, panel/frame image, localized title image, and Flutter-rendered dynamic text/buttons.
- New result asset structure was wired and registered:
  - `assets/game/result/failure_bg.png`
  - `assets/game/result/failure_panel.png`
  - `assets/game/result/failure_title_en.png`
  - `assets/game/result/failure_title_ko.png`
  - `assets/game/result/success_bg.png`
  - `assets/game/result/success_panel.png`
  - `assets/game/result/success_title_en.png`
  - `assets/game/result/success_title_ko.png`
- Temporary result visuals were replaced with stronger cinematic assets:
  Failure uses a detonation aftermath background and red industrial panel/title treatment; Success uses a stabilized device background and cyan industrial panel/title treatment.
- Success no longer uses the older modal-style result direction; Success and Failure now share the same composition system.
- Localized result title/subtitle art is selected by current app language through `GameAssetPaths.resultTitle`.
- Success keeps Answer, Attempts, Time, Try Again, and Home Flutter-rendered so dynamic values and interactive buttons stay maintainable.
- Failure Result was later replaced with the user-provided final failure assets only:
  - `assets/game/result/failure_scene_bg.png`
  - `assets/game/result/failure_result_panel.png`
  - `assets/game/result/failure_title_en.png`
  - `assets/game/result/failure_title_ko.png`
  - `assets/game/result/result_button_primary.png`
  - `assets/game/result/result_button_secondary.png`
- Failure reveal animation went through several timing passes and now uses a Flutter-only sequence:
  `failure_scene_bg.png` appears immediately, the screen shakes briefly, explosion light/contrast flickers over the background, then the final panel/title/code/buttons appear nearly together through a shade reveal.
- Strong full-screen red flash was removed because it read like a rendering error; Failure impact is now handled by shake, brightness/contrast flicker, and warm explosion-light overlay.
- Failure result assets are precached in `GameScreen` to avoid a blank image decode frame before the background appears.
- Failure reveal is skippable by tapping; taps during reveal jump to the final result state without triggering `TRY AGAIN` or `HOME`.
- Failure result buttons use the new result button frame assets, with Korean/English labels still rendered in Flutter.
- Technical asset preparation was limited to transparency/crop cleanup on `failure_result_panel.png`, `result_button_primary.png`, and `result_button_secondary.png`.
- Failure result layout was polished through several passes:
  the background bomb/explosion image was lifted, the panel was made visually longer, title/code/button spacing was rebalanced, and bottom overflow was addressed for short portrait heights.
- Failure answer display was simplified to the correct code only, then clarified with a key icon plus large code row; `ANSWER`, `ATTEMPTS`, and `TIME` no longer appear on the Failure result.
- `assets/game/result/result_key_icon.png` was added as a transparent cyber/metal key icon and wired through `GameAssetPaths.resultKeyIcon`.
- Failure `TRY AGAIN` and `HOME` continue to use `result_button_primary.png` and `result_button_secondary.png`, with labels rendered in Flutter.
- Success result visuals were not intentionally changed during the failure-only replacement pass.

### Feedback and Settings

- `GameSoundEffects` foundation uses settings-aware `SystemSound`.
- `GameHaptics` foundation uses settings-aware `HapticFeedback`.
- Sound volume and vibration enabled values are persisted.
- Music, auto Check Table, and language override persistence remain future work.

### Records / Tutorial / Settings

- Records screen uses `shared_preferences` for local records/statistics.
- Tutorial and Settings placeholder screens exist.
- Settings contains UI controls for Sound, Music, Vibration, and Check Table.

### Build / Runtime Notes

- Android viewport metric loops were investigated; Home SafeArea/padding trials were rolled back.
- `android:windowSoftInputMode` was changed to `adjustNothing`.
- Emulator GPU/virtgpu instability was mitigated by software rendering.
- DDS startup failures may require `flutter run --disable-dds --enable-software-rendering`.
- Gradle Kotlin incremental storage errors may require cache cleanup or disabling Kotlin incremental build.
