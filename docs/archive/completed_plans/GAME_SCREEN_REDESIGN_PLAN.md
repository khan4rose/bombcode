# Game Screen Redesign Plan

## 1. Redesign Goal

The main play screen should be redesigned as a premium mobile game UI where the bomb-defusal device is the visual center of the experience.

- The main play screen must feel like a bomb-defusal console, not a dense utility dashboard.
- The top bomb hero device must be the dominant visual element on the screen.
- Difficulty, attempts left, and time left must be displayed inside the bomb hero in real time.
- Urgency must be expressed through four visual stages: `stable`, `caution`, `danger`, and `critical`.
- The Check Table must be hidden from the default main screen and opened through a button or icon.
- History must receive more vertical space and support internal scrolling.
- Keypad and Current Code must remain large, readable, and clearly connected to the main play action.
- The redesign must follow the approved bomb-defusal console mockup direction.
- Existing game logic must not change.
- All text, numbers, timer values, difficulty labels, and button labels must be rendered with Flutter `Text`.

## 2. Target Screen Structure

The redesigned main play screen should be arranged from top to bottom as follows.

### 2.1 Top Utility / Brand Row

Possible contents:

- BoomCode logo or compact title
- Help icon
- Settings or pause icon
- Optional Check Table shortcut

Rules:

- Keep this row compact.
- Do not let utility controls consume the main play space.
- Prefer icon buttons with semantic labels over large text-heavy buttons.

### 2.2 Bomb Hero Status Section

This is the most important area of the redesigned screen.

Contents:

- Bomb hero image
- Difficulty
- Attempts left
- Time left
- Urgency meter
- Warning indicator
- Visual status stage

Status stages:

- `stable`
- `caution`
- `danger`
- `critical`

Display assets:

```text
assets/game/bomb_hero_stable.png
assets/game/bomb_hero_caution.png
assets/game/bomb_hero_danger.png
assets/game/bomb_hero_critical.png
```

Bomb hero state consistency rules:

- All four bomb hero assets must use the same pixel size.
- All four bomb hero assets must use the same transparent canvas bounds.
- The bomb device position, scale, and alignment must match exactly across all four states.
- The device must not visually jump, resize, or shift when the UI switches between `stable`, `caution`, `danger`, and `critical`.
- Only warning lights, accent color, meter state, glow intensity, and surface mood should change between stages.

Text rules:

- Difficulty, attempts left, and time left are Flutter `Text` overlays.
- Dynamic numbers and time values must not be baked into images.
- The hero image provides the device frame, lights, warning surfaces, and stage mood only.

### 2.3 Current Code Section

Contents:

- `current_code_panel.png`
- `code_slot_empty.png`
- `code_slot_filled.png`
- `code_slot_selected.png`
- Support for 2, 3, and 4 digit modes
- Current input digits rendered with Flutter `Text`

Goal:

- The current input value must be one of the fastest elements to recognize on the screen.
- Code slots should appear larger than the current first-pass Game Screen layout.
- The selected slot must be visually obvious without relying on text.

### 2.4 Latest Result Section

Contents:

- `access_trace_panel.png`
- Access count
- Trace count
- Optional Access / Trace icons
- Optional result dots

Goal:

- The player must immediately understand the result of the most recent guess.
- Use `Access` and `Trace`.
- Do not use `Strike`, `Ball`, `S/B`, or baseball terminology.

### 2.5 Scrollable History Section

Contents:

- `history_panel.png`
- `history_row_panel.png`
- Attempt number
- Guessed digits
- Access count
- Trace count
- Optional timestamp

Goal:

- History should be wider and taller than the current always-visible compact version.
- The history list must scroll internally.
- The default viewport should ideally show about 4 to 5 history rows.
- The entire main screen should not become the primary scroll container just to show history.
- If space is tight, keep the fixed play controls stable and scroll only the history content.

### 2.6 Check Table Access

The Check Table grid must not be permanently visible on the default main screen.

Display method:

- Use `check_table_open_button.png` or an icon button.
- On tap, show the Check Table in a modal, bottom sheet, or overlay.

Required assets:

- `check_table_open_button.png`
- `check_table_modal_panel.png`
- `modal_close_button.png`

Existing assets to reuse:

- `check_table_panel.png`
- `digit_marker_unknown.png`
- `digit_marker_possible.png`
- `digit_marker_impossible.png`
- `digit_marker_access_candidate.png`
- `digit_marker_trace_candidate.png`

### 2.7 Keypad Section

Contents:

- Digits `1` to `9`
- Delete
- `0`
- Submit

Required assets:

- `keypad_button_idle.png`
- `keypad_button_pressed.png`
- `keypad_button_disabled.png`
- `keypad_delete_button.png`
- `keypad_submit_button.png`
- `keypad_submit_disabled.png`

Keypad action button consistency rules:

- `keypad_delete_button.png`, `keypad_submit_button.png`, and `keypad_submit_disabled.png` must visually match the existing `keypad_button_*` asset family.
- Match height feel, bevel depth, metal texture, edge treatment, and industrial lighting style.
- Delete and Submit may be wider than number keys, but they must still feel like part of the same keypad system.
- Submit disabled must remain clearly inactive while preserving readable contrast for Flutter-rendered text or icons.

Goal:

- The keypad must be large enough for comfortable mobile play.
- Delete and Submit must read as clear action buttons.
- Submit must have distinct active and disabled states.
- Touch targets should remain at least 48 dp whenever possible.

## 3. Required New Assets

The following assets are required before implementing the bomb-centric redesign in Dart.

### 3.1 Required New Assets

| Asset Name | Purpose | Recommended Size | Transparent PNG | Text Baked In | Required/Optional | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| `assets/game/bomb_hero_stable.png` | Main bomb hero device for normal safe state | `720x360` or `720x400` | Yes | No | Required | Calm device state with subtle green/cyan accent. Holds Flutter text overlays. |
| `assets/game/bomb_hero_caution.png` | Main bomb hero device for mild warning state | `720x360` or `720x400` | Yes | No | Required | Amber/orange warning accents, still readable under overlay text. |
| `assets/game/bomb_hero_danger.png` | Main bomb hero device for high warning state | `720x360` or `720x400` | Yes | No | Required | Stronger red/orange warning lights without realistic weapon detail. |
| `assets/game/bomb_hero_critical.png` | Main bomb hero device for most urgent state | `720x360` or `720x400` | Yes | No | Required | Intense red warning state, safe-for-all-ages, no gore or explosion. |
| `assets/game/current_code_panel.png` | Frame behind the enlarged current code slots | `680x180` | Yes | No | Required | Should visually connect code slots to the bomb hero device. |
| `assets/game/check_table_open_button.png` | Button or frame for opening the Check Table modal | `260x72` or `300x80` | Yes | No | Required | Label/icon rendered by Flutter. Can sit in top row or near history. |
| `assets/game/keypad_delete_button.png` | Dedicated Delete action button frame | `220x112` or `240x112` | Yes | No | Required | Backspace icon or label must be Flutter-rendered. |
| `assets/game/keypad_submit_button.png` | Dedicated active Submit action button frame | `220x112` or `240x112` | Yes | No | Required | Active submit state with strong but readable warning-console styling. |
| `assets/game/keypad_submit_disabled.png` | Dedicated disabled Submit action button frame | `220x112` or `240x112` | Yes | No | Required | Disabled state for incomplete guesses. |
| `assets/game/check_table_modal_panel.png` | Large modal or bottom-sheet frame for Check Table | `680x520` | Yes | No | Required | Must fit marker grid and close control without baking text. |
| `assets/game/modal_close_button.png` | Close button frame for modal overlays | `96x96` or `112x112` | Yes | No | Required | Close icon rendered by Flutter or a no-text icon shape. |

### 3.2 Optional New Assets

These assets are optional. The first implementation can replace them with Flutter widgets, simple vector/icon widgets, or existing approved assets.

- `assets/game/bomb_urgency_meter.png`
- `assets/game/bomb_warning_icon_frame.png`
- `assets/game/access_icon.png`
- `assets/game/trace_icon.png`
- `assets/game/result_dot_empty.png`
- `assets/game/result_dot_active.png`
- `assets/game/history_scroll_thumb.png`
- `assets/game/keypad_panel_frame.png`
- `assets/game/top_help_icon.png`
- `assets/game/top_settings_icon.png`
- `assets/game/top_pause_icon.png`

Optional asset guidance:

- Do not generate optional assets in the first required asset task unless the user explicitly approves them.
- Prefer Flutter-rendered icons, shapes, and scrollbars first when they are sufficient.
- Optional assets are polish candidates after the main bomb-centric layout is approved.

## 4. Bomb Status Stage Rules

These rules are for UI visual stage calculation only.

Protection rules:

- Do not change `game_controller.dart`.
- Do not change `judge_code.dart`.
- Do not change `game_config.dart`.
- Do not change game rules, judging, difficulty defaults, attempts logic, or timer logic.

Example calculation:

```text
attemptsRatio = remainingAttempts / maxAttempts
timeRatio = remainingSeconds / maxSeconds
effectiveRatio = the more dangerous available ratio
```

Selection rules:

- If both attempts and time are enabled, use the more dangerous ratio. In practice, this is the lower ratio.
- If time is OFF, use `attemptsRatio`.
- If a future mode has no attempts limit, use `timeRatio`.
- If neither ratio is available, fall back to `stable`.

Stage thresholds:

| Stage | Ratio Rule |
| --- | --- |
| `stable` | `ratio >= 0.65` |
| `caution` | `0.35 <= ratio < 0.65` |
| `danger` | `0.15 <= ratio < 0.35` |
| `critical` | `ratio < 0.15` |

Visual direction:

| Stage | Direction |
| --- | --- |
| `stable` | Calm light, green/cyan subtle accent, low warning. |
| `caution` | Amber/orange accent, mild warning. |
| `danger` | Red/orange accent, stronger warning light. |
| `critical` | Intense red, urgent warning meter, safe-for-all-ages, no gore, no real explosion. |

## 5. Layout Priority

When screen space is limited, preserve the layout in this priority order:

1. Bomb Hero Status Section
2. Current Code Section
3. Keypad Section
4. Latest Access / Trace Result
5. Scrollable History
6. Check Table button
7. Decorative elements

Important rules:

- Do not show the Check Table grid on the default main screen.
- Use internal scrolling inside the History area.
- Do not shrink CodeSlots or Keypad just to show the Check Table grid.
- Decorative lights, trim, meters, and extra labels should be removed before core play controls are reduced.

## 6. Implementation Phase Plan

### Phase 1: Required Asset Generation

Task name:

```text
Task 3.2-E Main Play Redesign Required Assets generation
```

Generation targets:

- `bomb_hero_stable.png`
- `bomb_hero_caution.png`
- `bomb_hero_danger.png`
- `bomb_hero_critical.png`
- `current_code_panel.png`
- `check_table_open_button.png`
- `keypad_delete_button.png`
- `keypad_submit_button.png`
- `keypad_submit_disabled.png`
- `check_table_modal_panel.png`
- `modal_close_button.png`
- `main_play_required_assets_preview.png`

QA preview:

- Create `assets/game/main_play_required_assets_preview.png`.
- The preview should show all required new assets together for approval.
- The preview must make it easy to compare the four bomb hero states and confirm that their canvas size, device scale, and alignment are consistent.
- The preview must include the three keypad action button states near the existing keypad visual language direction.

### Phase 2: Main Play Layout Implementation

Task name:

```text
Task 3.3-C Main Play Screen Bomb-Centric Layout implementation
```

Work contents:

- Apply bomb hero section.
- Apply status text overlays.
- Apply current code section.
- Apply latest result section.
- Apply scrollable history.
- Apply Check Table button.
- Reposition keypad.
- Protect existing game logic.

### Phase 3: Check Table Modal Implementation

Task name:

```text
Task 3.3-D Check Table Modal / Bottom Sheet implementation
```

Work contents:

- Show modal or bottom sheet when the Check Table button is tapped.
- Display digit marker grid.
- Preserve existing `DigitMark` state mapping.
- Preserve manual marking flow.
- Reuse approved Check Table marker assets.

### Phase 4: Responsive QA / Polish

Task name:

```text
Task 3.3-E Game Screen Responsive QA and Visual Polish
```

Work contents:

- Check overflow around a `360x800` reference viewport.
- Check smaller screens.
- Check font scale behavior.
- Check keypad touch targets.
- Check history internal scrolling.
- Check bomb stage visuals.
- Verify the Check Table modal does not hide critical controls unexpectedly.

## 7. Coding Protection Rules

Do not modify:

- `game_controller.dart`
- `judge_code.dart`
- `game_config.dart`
- Game rules
- Access / Trace judging
- Difficulty logic
- Attempts / timer logic
- Existing asset image files
- `android/`
- `pubspec.yaml`, unless new assets are later registered in a specific implementation task

Allowed in later implementation tasks:

- UI widgets
- UI helpers
- Visual stage calculation helper
- Asset path constants
- Responsive layout code
- Check Table modal UI

Implementation note:

- Any visual stage helper must be treated as presentation logic only.
- It must read existing state and choose a visual asset.
- It must not mutate game state or redefine the rules for attempts, timer, success, or failure.

## 8. Text and Localization Rules

- All numbers, timer values, difficulty labels, and status messages must be rendered with Flutter `Text`.
- Do not bake Korean or English text into image assets.
- Button labels must be rendered with Flutter `Text`.
- Account for Korean and English text length with `FittedBox`, responsive text sizing, or equivalent layout protection.
- Preserve the terms `Access` and `Trace`.
- Do not use `Strike`, `Ball`, `S/B`, or baseball terminology.
- Dynamic status text should remain localizable in future localization work.

## 9. User Command Policy

Codex does not directly run PowerShell or terminal commands for implementation verification.

When commands are needed, Codex should ask the user to run them and paste the result.

Example commands for the user to run in PowerShell:

```powershell
dart format .
flutter analyze
flutter test
flutter run
```

After the user provides command output, Codex should decide the next correction step based on that exact output.

## 10. Deliverable

The deliverable for this planning task is one document:

```text
docs/GAME_SCREEN_REDESIGN_PLAN.md
```

This task does not generate image assets, modify Dart code, change Android files, change `pubspec.yaml`, or alter game logic.

## 11. Current Completion Snapshot

Status as of 2026-05-06:

- This redesign plan was reviewed and approved by the user.
- The requested document supplements were added:
  - QA preview file requirement: `assets/game/main_play_required_assets_preview.png`
  - bomb hero 4-state same-size / same-canvas / same-alignment rule
  - keypad action button consistency rule for the existing `keypad_button_*` family
- Task 3.2-E Main Play Redesign Required Assets generation is complete.
- The bomb hero / device visual rework requested after Task 3.2-E is also complete.

Generated Task 3.2-E assets:

```text
assets/game/bomb_hero_stable.png
assets/game/bomb_hero_caution.png
assets/game/bomb_hero_danger.png
assets/game/bomb_hero_critical.png
assets/game/current_code_panel.png
assets/game/check_table_open_button.png
assets/game/keypad_delete_button.png
assets/game/keypad_submit_button.png
assets/game/keypad_submit_disabled.png
assets/game/check_table_modal_panel.png
assets/game/modal_close_button.png
assets/game/main_play_required_assets_preview.png
```

Visual rework targets completed:

```text
assets/game/bomb_device_frame.png
assets/game/bomb_hero_stable.png
assets/game/bomb_hero_caution.png
assets/game/bomb_hero_danger.png
assets/game/bomb_hero_critical.png
assets/game/main_play_required_assets_preview.png
```

Visual rework result:

- The bomb hero assets were reworked from flat panel-like frames into stylized but believable bomb-defusal devices.
- The reworked device style includes side housings, cables, connectors, bolts, warning lights, recessed display-safe areas, and stronger stage lighting.
- `bomb_device_frame.png` was reworked to feel like a smaller input module from the same bomb-device family.
- The four bomb hero states still share the same canvas, body silhouette, device alignment, and display-safe area positions.
- No Korean text, English text, numbers, difficulty labels, timer values, or attempts values are baked into these assets.

Validation snapshot:

| Asset | Size / Mode | Notes |
| --- | --- | --- |
| `bomb_hero_stable.png` | `720x405 RGBA` | User-provided replacement normalized to transparent canvas |
| `bomb_hero_caution.png` | `720x405 RGBA` | User-provided replacement normalized to transparent canvas |
| `bomb_hero_danger.png` | `720x405 RGBA` | User-provided replacement normalized to transparent canvas |
| `bomb_hero_critical.png` | `720x405 RGBA` | User-provided replacement normalized to transparent canvas |
| `bomb_device_frame.png` | `720x260 RGBA` | Reworked as device-like input module |
| `main_play_required_assets_preview.png` | `1600x2100 RGB` | Preview sheet for visual comparison |

Validation notes:

- Transparent PNG corner alpha was checked for target RGBA assets.
- Bright chroma-green artifact count was checked and found to be `0`.
- The current Dart UI uses the Task 3.2-E bomb hero assets in the simplified Task 3.3-C main gameplay layout.
- The active Game Screen no longer uses `bomb_device_frame.png`, top status panels, READY panel, pause button, or the inline Check Table bar.
- Live responsive QA is blocked by DDS service protocol failures and Gradle Kotlin incremental storage build errors.

Next implementation task:

```text
Task 1.0 Android/DDS/Gradle Kotlin build stabilization, then Task 3.3-E responsive QA
```
