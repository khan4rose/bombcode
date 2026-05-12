# MASTER_CONTEXT

BoomCode 작업을 시작할 때 항상 읽는 초경량 현재 상태 문서이다.
상세 기록은 `docs/core/PROJECT_HISTORY.md`와 `docs/archive/`에 보관한다.
특정 영역 작업 시에는 필요한 `docs/guides/*` 문서만 추가로 읽는다.

---

## Project Identity

| 항목 | 내용 |
| --- | --- |
| App | BoomCode |
| Package | `bombcode` |
| Path | `D:\jtj\bombcode` |
| Type | Flutter offline mobile game |
| Target | Android portrait-first |
| Concept | Bomb-defusal numeric code deduction |
| Style | Dark sci-fi industrial, metal panels, red LED accents |
| Core Terms | `Access`, `Trace`, compact UI may use `A/T` |
| Forbidden Terms | `Strike`, `Ball`, `S/B`, baseball terminology |

`Access`: digit and position are both correct.
`Trace`: digit is correct but position is different.

---

## Current App State

- App shell, splash, home, mission setup, game, records, tutorial, and settings screens exist.
- Common background uses `AppBackground` and `assets/menu/background.png`.
- MVP is portrait-only via Flutter orientation lock and Android `screenOrientation`.
- Game logic supports answer generation, digit input/editing, judging, timer, success/failure, records, attempts OFF, and time OFF.
- Time-limit countdown starts on the first valid keypad/input edit, not immediately when the Game Screen opens.
- Home Start Game loads the last saved `GameConfig`; first-run default is Normal + Attempts OFF + Time OFF.
- Sound and haptic foundations exist; custom audio assets are not integrated yet.
- Game Screen active flow is `Bomb HUD -> Current Code -> Keypad -> History`.
- Current Code is a single industrial display panel containing four slot positions; filled slots can be tapped to select and edit a specific digit.
- Result screen uses layered cinematic compositions for Success and Failure:
  background scene image, panel/frame image, localized title image, then Flutter-rendered dynamic text/buttons.
- Result assets live under `assets/game/result/`:
  Failure uses `failure_scene_bg.png`, `failure_result_panel.png`, `failure_title_en.png`, `failure_title_ko.png`, `result_button_primary.png`, and `result_button_secondary.png`;
  Success uses `success_bg.png`, `success_panel.png`, `success_title_en.png`, and `success_title_ko.png`.
- Failure Korean title art uses `assets/game/result/failure_title_ko.png`; it is a transparent PNG normalized to the standard result title canvas and scaled to fill the Failure panel title slot without clipping.
- Failure hides the gameplay layer itself and shows a bomb detonation aftermath scene behind the result panel.
- Failure has a Flutter-only reveal animation: `failure_scene_bg.png` appears immediately, the scene shakes briefly, explosion light flickers for about 1.4 seconds, and the panel/title/code/buttons begin appearing at the same time as the flicker.
- Failure result assets are precached from `GameScreen` to avoid a blank first frame before the detonation background appears.
- Failure result now presents only the correct code in the answer area, paired with `assets/game/result/result_key_icon.png`; Attempts and Time are intentionally hidden on Failure.
- Success uses the same result architecture with a stabilized/defused device scene, not the older modal-style result.
- User runs `dart format`, `flutter analyze`, `flutter test`, and `flutter run`; Codex should request them step by step, not run them.

---

## Architecture

```text
lib/
  core/       constants, utils, shared widgets, feedback helpers
  data/       repositories and local storage
  domain/     enums and models, no Flutter UI dependency
  features/   screen and feature-specific UI/state
```

Important files:

| File | Purpose |
| --- | --- |
| `lib/features/home/home_screen.dart` | Home/Main Menu UI |
| `lib/features/mode_select/mode_select_screen.dart` | Mission Setup UI |
| `lib/features/game/game_screen.dart` | Main gameplay and result overlay UI |
| `lib/features/game/game_controller.dart` | Game state/rules |
| `lib/core/utils/judge_code.dart` | Access/Trace judging |
| `lib/domain/models/game_config.dart` | Difficulty/config model |
| `lib/core/widgets/app_background.dart` | Common background wrapper |

Rules:

- Prefer existing patterns over new abstractions.
- Keep one task per session.
- Minimize changed files.
- Do not mix UI, logic, asset, and data changes in one task.
- Do not delete generated/user assets unless explicitly requested and references are checked.

---

## Protected Files

For visual-only tasks, do not modify:

```text
lib/features/game/game_controller.dart
lib/core/utils/judge_code.dart
lib/domain/models/game_config.dart
```

For Mission Setup visual tasks, also avoid:

```text
assets/menu/
android/
```

For Game Screen visual tasks:

- `judge_code.dart` and `game_config.dart` are always protected.
- `game_controller.dart` may be changed only if a UI bug is proven to require controller behavior.

---

## Gameplay Rules

Difficulty defaults:

| Difficulty | Digits | Attempts |
| --- | ---: | ---: |
| Beginner | 2 | 20 |
| Normal | 3 | 12 |
| Expert | 4 | 7 |

Attempts options:

```text
OFF / 7 / 10 / 13 / 15 / 20
```

Timer options:

```text
OFF / 5 min / 10 min / 20 min
```

Limit modes:

| Attempts | Time | LimitMode |
| --- | --- | --- |
| OFF | OFF | `none` |
| ON | OFF | `attemptsOnly` |
| OFF | ON | `timeOnly` |
| ON | ON | `attemptsAndTime` |

---

## Active UI Direction

Global:

- Base reference canvas: `360 x 800 dp`.
- Use `SafeArea`, `LayoutBuilder`, or `MediaQuery`.
- Main/Menu/Setup/Game should remain non-scroll unless explicitly requested.
- Text should be Flutter-rendered where possible.
- Prevent overflow by responsive spacing, sizing, and `FittedBox`; do not hide overflow as the primary fix.

Game Screen:

- Use common background through `AppBackground`.
- Active visual flow: `Bomb HUD -> Current Code -> Keypad -> History`.
- Bomb hero uses `bomb_hero_stable/caution/danger/critical.png`.
- Code slots use `code_slot_empty/filled/selected.png`.
- Current Code slots are grouped inside a shared display panel; tapping a slot selects it, keypad input replaces the selected digit, and Delete clears the selected digit before falling back to last-digit delete.
- Keypad uses `keypad_button_*`, `keypad_delete_button.png`, `keypad_submit_button.png`, and disabled submit asset.
- History is a compact tactical table; latest row first; `A` is green and `T` is blue.
- Check Table opens from History area; default main screen does not show the grid.
- Result overlay should be cinematic but must preserve SafeArea and button visibility.
- Result title/subtitle are image assets selected by success/failure and device language.
- Success keeps Answer, Attempts, Time, Try Again, and Home Flutter-rendered and interactive.
- Failure keeps the correct code and button labels Flutter-rendered; the correct code is displayed as a large centered row with the cyber/metal key icon asset and no `ANSWER`, `ATTEMPTS`, or `TIME` labels.
- Failure `TRY AGAIN` / `HOME` use only `result_button_primary.png` / `result_button_secondary.png` as button frames; do not add temporary generated button backing, decoration, or gloss overlays in Flutter.
- Failure result should hide the gameplay layer itself instead of relying on heavy fog over the whole scene; keep the bomb/explosion/smoke background visible behind the result composition.
- Failure reveal animation should stay Flutter-only, skippable, and must not allow result buttons to fire during skip.
- Do not use a strong full-screen red flash for Failure; explosion emphasis should come from shake, background light/contrast flicker, and shade reveal over the existing scene.
- Success and Failure should continue using layered result-scene composition, not plain modal/card implementations.

---

## Current Risks

- Live device QA is still important for Game Screen/result overlay small-screen fit, especially Korean/English result title scale and button visibility.
- Android emulator may have GPU/virtgpu, DDS, or Gradle Kotlin incremental instability.
- Main Menu and Mission Setup still need final device-level visual QA.
- Settings persistence remains partial.
- Release icon/launch/metadata are not ready.

For build/runtime issues, read `docs/guides/BUILD_ISSUES.md`.
For Game Screen work, read `docs/guides/GAME_SCREEN_GUIDE.md`.
For asset work, read `docs/guides/ASSET_RULES.md`.
