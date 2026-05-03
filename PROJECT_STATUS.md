# PROJECT_STATUS

## Current App

- App name: **BoomCode**
- Flutter package name: `bombcode`
- Primary target: Android first, Flutter cross-platform project structure retained.

## Purpose

BoomCode is an offline number-code deduction game with a bomb-defusal theme. The player guesses a hidden numeric code and receives `Access / Trace` hints until the code is unlocked or the selected limits are exhausted.

## Implemented Features

- Flutter app entry and theme:
  - `lib/main.dart`
  - `lib/app.dart`
- Splash flow:
  - Uses device locale to choose `assets/splash/main_kor.png` or `assets/splash/main_eng.png`.
  - Then navigates to `HomeScreen`.
- Home/main menu:
  - File: `lib/features/home/home_screen.dart`
  - Uses the common background `assets/menu/background.png`.
  - Uses `SafeArea` + `LayoutBuilder` and responsive scale values from a `360 x 800 dp` reference canvas.
  - Uses language-specific complete PNG menu assets with baked text:
    - `assets/menu/menu_logo_eng.png`
    - `assets/menu/menu_logo_kor.png`
    - `assets/menu/menu_currency.png`
    - `assets/menu/menu_start_eng.png`
    - `assets/menu/menu_start_kor.png`
    - `assets/menu/menu_difficulty_eng.png`
    - `assets/menu/menu_difficulty_kor.png`
    - `assets/menu/menu_records_eng.png`
    - `assets/menu/menu_records_kor.png`
    - `assets/menu/menu_settings_eng.png`
    - `assets/menu/menu_settings_kor.png`
    - `assets/menu/menu_shop_eng.png`
    - `assets/menu/menu_shop_kor.png`
    - `assets/menu/menu_remove_ads_eng.png`
    - `assets/menu/menu_remove_ads_kor.png`
    - `assets/menu/menu_help_eng.png`
    - `assets/menu/menu_help_kor.png`
  - Buttons are real Flutter tap targets displaying complete button images.
  - Main menu button assets were regenerated in a darker sci-fi metal style:
    - Start Game / Game Start is the red primary action button.
    - Difficulty, Records, and Settings are dark secondary buttons.
    - Bottom utility buttons are icon+label PNG assets.
  - Main menu current layout notes:
    - Logo is enlarged and positioned high on the screen.
    - Main button group is intentionally wide and visually thinner than the source PNG aspect ratio.
    - Start Game and Select Difficulty currently have no vertical gap between them.
    - Other main buttons keep a very small responsive vertical gap.
    - Bottom utility buttons are scaled down to 80% of the latest utility-button sizing and their horizontal gap is reduced to 30% of the computed spacing.
    - Currency panel is intentionally a blank frame for future Flutter-rendered currency text. It is displayed shorter and thicker than the source asset using `BoxFit.fill`.
  - The visible exit button has been removed from the main menu.
  - Start Game and Select Difficulty both route to Mission Setup.
  - Records, Settings, and Help route to their screens.
  - Shop and Remove Ads currently show a coming-soon `SnackBar`.
- Global/common background:
  - All non-image screens should use `assets/menu/background.png`.
  - Shared widget: `lib/core/widgets/app_background.dart`.
- Mission setup screen:
  - File: `lib/features/mode_select/mode_select_screen.dart`
  - Single-screen, non-scroll layout using `LayoutBuilder`.
  - Difficulty selection:
    - Beginner: 2 digits, 20 attempts
    - Normal: 3 digits, 12 attempts
    - Expert: 4 digits, 7 attempts
  - Time limit values:
    - OFF, 5, 10, 15, 20 minutes
  - Sound/music/vibration/auto check table controls are UI-only for now.
  - Uses PNG UI parts from `assets/mission_setup/` with fallback widgets if assets are missing.
- Game logic:
  - Answer generation without duplicate digits.
  - Leading zero allowed.
  - Duplicate input blocked.
  - `judgeCode()` returns `access` and `trace`.
  - Game controller supports:
    - start
    - pause/resume
    - digit input
    - delete
    - submit
    - restart same config
    - one-second tick
    - attempt exhaustion
    - time expiration
    - success/failure status
- Check table:
  - Auto marking for simple cases.
  - Manual digit mark cycling when auto mode is disabled.
- Records:
  - Local storage via `shared_preferences`.
  - Stores recent game records.
  - Displays best attempts, fastest time, and recent plays.
- Tutorial/settings placeholder screens:
  - Device-language aware English/Korean text through `AppText`.
- Tests:
  - `test/judge_code_test.dart`
  - `test/game_controller_test.dart`

## Not Yet Implemented

- Full final game UI art for all screens.
- Final game screen image assets and exact bomb-defusal UI layout.
- Final main menu layout QA after the latest responsive placement changes.
- Flutter-rendered currency amount and plus-button behavior inside/around the current blank currency panel.
- Persistent settings for:
  - sound volume
  - music volume
  - vibration
  - language override
- Actual sound, music, vibration behavior.
- Shop/remove ads/payment/ad systems.
- Full localization system using ARB or Flutter localization delegates.
- Production-grade Android app icon and launch assets.
- Complete QA across many device sizes and font-scale settings.
- Final visual QA for the regenerated main menu assets and exact menu spacing on target devices.
- Final release build configuration.

## Terminology Rules

Do not use number-baseball terms in UI, code names, comments, or new docs.

Allowed terms:

- `Access`
- `Trace`
- `A`
- `T`

Forbidden terms:

- `Strike`
- `Ball`
- `S`
- `B`
- Korean equivalents related to baseball scoring
- `baseball` as a game concept

Meaning:

- `Access`: correct digit in the correct position.
- `Trace`: correct digit in a different position.

## Current Folder Structure

```text
lib/
  main.dart
  app.dart
  core/
    constants/
      app_colors.dart
      app_strings.dart
      app_text.dart
    utils/
      code_generator.dart
      judge_code.dart
      responsive.dart
      timer_formatter.dart
    widgets/
      app_background.dart
  data/
    record_repository.dart
    local_record_repository.dart
  domain/
    enums/
      difficulty.dart
      limit_mode.dart
      game_status.dart
      game_over_reason.dart
      digit_mark.dart
    models/
      game_config.dart
      game_record.dart
      guess_record.dart
      judge_result.dart
  features/
    splash/
      splash_screen.dart
    home/
      home_screen.dart
    mode_select/
      mode_select_screen.dart
    game/
      game_controller.dart
      game_screen.dart
      widgets/
        check_table.dart
        code_slots.dart
        guess_history_list.dart
        limit_status_bar.dart
        number_keypad.dart
    records/
      records_screen.dart
    settings/
      settings_screen.dart
    tutorial/
      tutorial_screen.dart
assets/
  splash/
  menu/
  mission_setup/
test/
  judge_code_test.dart
  game_controller_test.dart
```

## Key Files

- `lib/main.dart`
  - Starts `BoomCodeApp`.
- `lib/app.dart`
  - App theme and root screen.
- `lib/core/constants/app_text.dart`
  - Current device-locale based English/Korean text helper.
  - Uses `PlatformDispatcher.instance.locale`.
- `lib/core/widgets/app_background.dart`
  - Shared background image wrapper using `assets/menu/background.png`.
- `lib/core/utils/responsive.dart`
  - Small helper for responsive scaling.
- `lib/core/utils/judge_code.dart`
  - Access/Trace judgement logic.
- `lib/core/utils/code_generator.dart`
  - Generates non-duplicate digit answers.
- `lib/domain/models/game_config.dart`
  - Difficulty defaults and game setup configuration.
- `lib/features/mode_select/mode_select_screen.dart`
  - Mission Setup screen.
  - Important and currently large file.
  - Uses mission setup assets and fallback UI.
- `lib/features/game/game_controller.dart`
  - Main game state and rules.
- `lib/features/game/game_screen.dart`
  - Game play and result UI.
- `lib/data/local_record_repository.dart`
  - `shared_preferences` implementation for records.
- `android/app/src/main/AndroidManifest.xml`
  - Contains Flutter Android metadata.
  - Impeller disabled for emulator stability.

## Assets Currently Present

```text
assets/menu/background.png
assets/menu/main_menu_eng.png
assets/menu/main_menu_kor.png
assets/menu/menu_logo_eng.png
assets/menu/menu_logo_kor.png
assets/menu/menu_currency.png
assets/menu/menu_start_eng.png
assets/menu/menu_start_kor.png
assets/menu/menu_difficulty_eng.png
assets/menu/menu_difficulty_kor.png
assets/menu/menu_records_eng.png
assets/menu/menu_records_kor.png
assets/menu/menu_settings_eng.png
assets/menu/menu_settings_kor.png
assets/menu/menu_shop_eng.png
assets/menu/menu_shop_kor.png
assets/menu/menu_remove_ads_eng.png
assets/menu/menu_remove_ads_kor.png
assets/menu/menu_help_eng.png
assets/menu/menu_help_kor.png
assets/splash/main_eng.png
assets/splash/main_kor.png
assets/mission_setup/back_button.png
assets/mission_setup/difficulty_*_on/off.png
assets/mission_setup/start_mission_button.png
assets/mission_setup/slider_track.png
assets/mission_setup/slider_thumb.png
assets/mission_setup/minus_button.png
assets/mission_setup/plus_button.png
assets/mission_setup/sound_icon.png
assets/mission_setup/music_icon.png
assets/mission_setup/vibration_icon.png
assets/mission_setup/digits_icon.png
assets/mission_setup/timer_icon.png
assets/mission_setup/reward_icon.png
assets/mission_setup/check_table_icon.png
```

## Run / Check

Use these commands manually:

```bash
flutter pub get
dart format .
flutter analyze
flutter test
flutter run
```

If emulator debug connection fails with Bluetooth/system logs, try:

```bash
flutter clean
flutter pub get
flutter run
```

Also try Android Emulator cold boot or a new emulator image.

## Current Issues / Notes

- `mode_select_screen.dart` is large and should eventually be split into smaller widgets only when doing a focused refactor.
- Mission setup asset generation was done incrementally. Some generated assets may need visual review and replacement for final art quality.
- Home menu now uses separate, language-specific complete image buttons instead of Flutter-rendered button labels.
- Home menu image assets were regenerated iteratively and need device visual QA for sizing, spacing, and any remaining chroma-key edge artifacts.
- Latest main menu asset/layout pass:
  - `assets/menu/menu_start_eng.png`
  - `assets/menu/menu_start_kor.png`
  - `assets/menu/menu_difficulty_eng.png`
  - `assets/menu/menu_difficulty_kor.png`
  - `assets/menu/menu_records_eng.png`
  - `assets/menu/menu_records_kor.png`
  - `assets/menu/menu_settings_eng.png`
  - `assets/menu/menu_settings_kor.png`
  - `assets/menu/menu_shop_eng.png`
  - `assets/menu/menu_shop_kor.png`
  - `assets/menu/menu_remove_ads_eng.png`
  - `assets/menu/menu_remove_ads_kor.png`
  - `assets/menu/menu_help_eng.png`
  - `assets/menu/menu_help_kor.png`
  - `lib/features/home/home_screen.dart`
- `assets/menu/main_menu_eng.png` and `assets/menu/main_menu_kor.png` are retained as visual references, not the active home screen layout.
- Some old experimental menu assets may remain if the OS kept them locked during cleanup; remove them only after confirming no code references them.
- App currently uses a simple `AppText` helper instead of Flutter's full localization system.
- Sound/music/vibration controls do not persist and do not affect real audio/haptics yet.
- `AppBackground` is the standard background path. Do not add per-screen full background images unless explicitly requested.
- Avoid large rewrites. This project is evolving screen-by-screen.
