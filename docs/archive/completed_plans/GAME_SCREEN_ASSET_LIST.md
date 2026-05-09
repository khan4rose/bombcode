# Game Screen Asset List

## Purpose

This document defines the image assets needed before the BoomCode Game Screen redesign.
It is the planning source for:

- Task 3.2 Game Screen Assets generation
- Task 3.3 Game Screen Design implementation

No gameplay logic, Dart UI code, or existing assets are changed by this document.

## Design Basis

| Item | Direction |
| --- | --- |
| App | BoomCode |
| Theme | Bomb-defusal numeric code deduction game |
| Visual style | Dark sci-fi industrial, brushed metal, beveled steel, red LED accent |
| Core terms | Access / Trace |
| Forbidden terms | Strike, Ball, S/B, baseball terminology |
| Base canvas | 360 x 800 dp |
| Primary target | Android portrait first |
| Layout | Prefer non-scroll; avoid overflow on small screens |
| Text | Render with Flutter Text whenever language switching or numbers are needed |
| Asset folder | `assets/game/` |
| File naming | `snake_case.png` |

## Asset Size Rule

Recommended Size is a planning target for creating roughly 2x resolution PNGs for a `360 x 800 dp` reference screen.

Examples:

- An asset that appears close to full `360 dp` screen width should be produced around `720 px` wide.
- An icon or button that appears around `64 dp` should be produced around `128 px`.

Flutter should scale assets to the actual device using `BoxFit.contain`, `FittedBox`, `AspectRatio`, or responsive sizing.

Asset pixel dimensions are not fixed layout values. In Task 3.3, actual placement must account for device size, `SafeArea`, font scale, and touch target requirements.

## Asset Priority Rule

Each asset is classified as:

- Required: core asset to generate first in Task 3.2
- Optional: generate only if the need is confirmed during Task 3.3 or later polish

Task 3.2 should not generate every listed asset at once. Start with Required assets for the core input flow.

Optional assets are for screen polish, warning effects, success/failure presentation, pause/result polish, or layout-specific needs.

## Visual Style Detail

Game Screen assets must visually match the existing common background:

```text
assets/menu/background.png
```

Visual direction:

- Main material: dark gunmetal, brushed metal, beveled steel
- Accent: red LED, subtle orange warning light
- Mood: tense puzzle-device interface, not horror
- Shape language: industrial panels, soft bevels, clean mechanical edges
- Transparency: clean alpha edge, no green/chroma artifact
- Readability: assets must support bright Flutter Text overlays
- Child-safe: the bomb theme should look like a stylized puzzle device, not a realistic explosive

Avoid:

- cartoon style
- toy-like bright colors
- neon cyberpunk overload
- horror/gore mood
- realistic weapon imagery
- baked Korean/English labels
- green-screen edge artifacts

## Text Bake-In Rules

- Do not bake Korean/English UI labels into assets when Flutter Text can render them.
- Do not bake dynamic numbers into assets.
- Render `ACCESS`, `TRACE`, `ATTEMPTS`, `TIME`, `SUCCESS`, `FAILED`, button labels, timer values, attempt counts, and digits with Flutter Text unless a later task explicitly approves otherwise.
- Use PNG assets for frames, panels, lights, icons, slots, surfaces, and state effects.
- Keypad numbers `0` to `9` should be Flutter Text over shared button frame assets.
- `Access / Trace` terminology must be preserved; do not use baseball terms.

## Responsive Layout Memo

- Define asset proportions around a `360 x 800 dp` phone portrait canvas.
- Keep Game Screen non-scroll if practical.
- The current screen uses these functional areas:
  - `LimitStatusBar`
  - `CodeSlots`
  - `NumberKeypad`
  - `CheckTable`
  - `GuessHistoryList`
  - result screen
- Final layout should prioritize:
  - header/status readability
  - code slot clarity
  - keypad touch targets
  - compact history/check table presentation
- If vertical space is tight, history/check table can become a compact panel, collapsible area, or modal candidate in Task 3.3.

## Game Screen Layout Priority

When vertical space is tight, prioritize the screen in this order:

1. CodeSlots and current input must be most visible.
2. NumberKeypad must keep large touch targets.
3. Attempts/time status must remain readable.
4. Latest Access/Trace result should be visible without scrolling.
5. GuessHistory and CheckTable may be compact, collapsible, toggle-based, bottom-sheet, or modal if vertical space is tight.

The main game input flow should remain non-scroll if practical. Avoid making the keypad too small just to show every secondary panel at once.

## Check Table Display Rule

CheckTable does not have to be permanently visible on the main game screen.

Allowed forms:

- compact inline panel
- toggle panel
- bottom sheet
- modal overlay

The chosen form must preserve:

- non-scroll main input flow when practical
- large keypad touch targets
- readable CodeSlots
- clear Access/Trace feedback
- easy manual digit marking

## Asset List

### 1. Top Status / Header Area

| Asset Name | Folder | Purpose | Recommended Size | Transparent PNG | Text Baked In? | States Needed | Priority | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `game_header_panel.png` | `assets/game/` | Main top header/status frame | `720x128` | Yes | No | default | Required | Wide metal frame for difficulty, mode, attempts, timer |
| `status_panel_small.png` | `assets/game/` | Reusable compact status card | `220x112` | Yes | No | default, alert | Required | For remaining attempts, time, tried count |
| `status_panel_warning.png` | `assets/game/` | Urgent status card | `220x112` | Yes | No | warning | Optional | Red glow variant for low attempts/time |
| `pause_button.png` | `assets/game/` | Pause icon button frame | `128x128` | Yes | No | idle, pressed | Optional | Flutter icon can be overlaid if preferred |
| `resume_button.png` | `assets/game/` | Resume icon button frame | `128x128` | Yes | No | idle, pressed | Optional | Use only if pause/resume should not share one frame |
| `top_back_button.png` | `assets/game/` | Return/home button frame | `128x128` | Yes | No | idle, pressed | Optional | Use only if Game Screen needs back/home in header |

### 2. Bomb / Code Display Area

| Asset Name | Folder | Purpose | Recommended Size | Transparent PNG | Text Baked In? | States Needed | Priority | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `bomb_device_frame.png` | `assets/game/` | Main bomb/device body behind code slots | `720x260` | Yes | No | default | Required | Full-width sci-fi puzzle-device surface |
| `bomb_device_warning.png` | `assets/game/` | Warning state device glow | `720x260` | Yes | No | warning | Optional | Optional overlay for low time/attempts |
| `code_slot_empty.png` | `assets/game/` | Empty digit slot | `128x128` | Yes | No | empty | Required | Must work for 2, 3, or 4 slots |
| `code_slot_filled.png` | `assets/game/` | Filled digit slot | `128x128` | Yes | No | filled | Required | Digit rendered as Flutter Text |
| `code_slot_selected.png` | `assets/game/` | Active/next slot highlight | `128x128` | Yes | No | selected | Required | Red LED edge or glow |
| `code_slot_locked.png` | `assets/game/` | Disabled/locked slot visual | `128x128` | Yes | No | locked | Optional | Optional for pause/result transitions |
| `code_slot_success_overlay.png` | `assets/game/` | Success glow for slots | `128x128` | Yes | No | success | Optional | Optional green/blue glow, no text |
| `code_slot_failure_overlay.png` | `assets/game/` | Failure glow for slots | `128x128` | Yes | No | failure | Optional | Optional red/error glow, no text |

### 3. Input Keypad Area

| Asset Name | Folder | Purpose | Recommended Size | Transparent PNG | Text Baked In? | States Needed | Priority | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `keypad_button_idle.png` | `assets/game/` | Shared number key frame | `144x112` | Yes | No | idle | Required | Digits rendered with Flutter Text |
| `keypad_button_pressed.png` | `assets/game/` | Pressed number key frame | `144x112` | Yes | No | pressed | Required | Slight red LED/glow response |
| `keypad_button_disabled.png` | `assets/game/` | Used digit disabled frame | `144x112` | Yes | No | disabled | Required | Must keep digit readable but subdued |
| `keypad_action_button_idle.png` | `assets/game/` | Delete/submit shared action frame | `300x112` | Yes | No | idle | Required | Text/icon rendered by Flutter |
| `keypad_action_button_pressed.png` | `assets/game/` | Action pressed frame | `300x112` | Yes | No | pressed | Optional | For delete and submit |
| `keypad_submit_active.png` | `assets/game/` | Submit active frame | `300x112` | Yes | No | active | Required | Stronger red accent for valid guess |
| `keypad_submit_disabled.png` | `assets/game/` | Submit disabled frame | `300x112` | Yes | No | disabled | Required | For incomplete guess |
| `delete_icon.png` | `assets/game/` | Delete/backspace icon | `96x96` | Yes | No | idle | Optional | Flutter icon can be used instead |
| `submit_icon.png` | `assets/game/` | Submit/check icon | `96x96` | Yes | No | idle | Optional | Flutter icon can be used instead |

### 4. Result Feedback / History Area

| Asset Name | Folder | Purpose | Recommended Size | Transparent PNG | Text Baked In? | States Needed | Priority | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `access_trace_panel.png` | `assets/game/` | Frame for latest Access/Trace result | `640x112` | Yes | No | default | Required | Flutter Text renders Access/Trace counts |
| `access_count_badge.png` | `assets/game/` | Access count badge/frame | `160x96` | Yes | No | default | Optional | Use Access term, no baked label |
| `trace_count_badge.png` | `assets/game/` | Trace count badge/frame | `160x96` | Yes | No | default | Optional | Use Trace term, no baked label |
| `history_panel.png` | `assets/game/` | Container for guess history area | `680x260` | Yes | No | default | Required | Can hold compact rows |
| `history_row_panel.png` | `assets/game/` | Single guess history row | `640x84` | Yes | No | default | Required | Attempt number, guess, Access/Trace rendered in Flutter |
| `history_row_latest.png` | `assets/game/` | Highlight latest guess row | `640x84` | Yes | No | latest | Optional | Optional LED accent |
| `history_empty_panel.png` | `assets/game/` | Empty history placeholder frame | `640x96` | Yes | No | empty | Optional | Text rendered in Flutter |

### 5. Check Table / Memo Area

| Asset Name | Folder | Purpose | Recommended Size | Transparent PNG | Text Baked In? | States Needed | Priority | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `check_table_panel.png` | `assets/game/` | Container for digit memo table | `680x220` | Yes | No | default | Required | Can be compact, toggle-based, bottom-sheet, or modal |
| `check_table_toggle_button.png` | `assets/game/` | Button/icon frame to open check table | `180x96` | Yes | No | idle, active | Optional | Text rendered separately if needed |
| `digit_marker_unknown.png` | `assets/game/` | Unknown marker cell | `120x72` | Yes | No | unknown | Required | Digit and mark label rendered by Flutter |
| `digit_marker_possible.png` | `assets/game/` | Possible marker cell | `120x72` | Yes | No | possible | Required | Match current `DigitMark.possible` |
| `digit_marker_impossible.png` | `assets/game/` | Impossible marker cell | `120x72` | Yes | No | impossible | Required | Match current `DigitMark.impossible` |
| `digit_marker_access_candidate.png` | `assets/game/` | Access candidate marker cell | `120x72` | Yes | No | access candidate | Required | Use Access term |
| `digit_marker_trace_candidate.png` | `assets/game/` | Trace candidate marker cell | `120x72` | Yes | No | trace candidate | Required | Use Trace term |

### 6. Modal / Overlay Candidates

| Asset Name | Folder | Purpose | Recommended Size | Transparent PNG | Text Baked In? | States Needed | Priority | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `pause_modal_panel.png` | `assets/game/` | Pause overlay panel | `680x520` | Yes | No | default | Required | Resume/home labels rendered in Flutter |
| `result_modal_success.png` | `assets/game/` | Success result panel | `680x560` | Yes | No | success | Required | For CODE UNLOCKED state, text in Flutter |
| `result_modal_failure.png` | `assets/game/` | Failure result panel | `680x560` | Yes | No | failure | Required | For ACCESS DENIED / timeout / attempts used |
| `result_fact_row.png` | `assets/game/` | Row frame for result facts | `600x72` | Yes | No | default | Optional | Answer, attempts, time, difficulty, limit |
| `modal_primary_button.png` | `assets/game/` | Result/restart primary button frame | `520x112` | Yes | No | idle, pressed | Required | Text rendered in Flutter |
| `modal_secondary_button.png` | `assets/game/` | Home/secondary button frame | `520x112` | Yes | No | idle, pressed | Required | Text rendered in Flutter |
| `success_light_overlay.png` | `assets/game/` | Success glow/light effect | `720x800` | Yes | No | success | Optional | Optional full-screen transparent overlay |
| `failure_light_overlay.png` | `assets/game/` | Failure red warning overlay | `720x800` | Yes | No | failure | Optional | Optional full-screen transparent overlay |

## Recommended Minimum Asset Set For Task 3.2

Task 3.2 can start with this smaller set before producing every optional variant:

```text
assets/game/game_header_panel.png
assets/game/status_panel_small.png
assets/game/bomb_device_frame.png
assets/game/code_slot_empty.png
assets/game/code_slot_filled.png
assets/game/code_slot_selected.png
assets/game/keypad_button_idle.png
assets/game/keypad_button_pressed.png
assets/game/keypad_button_disabled.png
assets/game/keypad_action_button_idle.png
assets/game/keypad_submit_active.png
assets/game/keypad_submit_disabled.png
assets/game/access_trace_panel.png
assets/game/history_panel.png
assets/game/history_row_panel.png
assets/game/check_table_panel.png
assets/game/digit_marker_unknown.png
assets/game/digit_marker_possible.png
assets/game/digit_marker_impossible.png
assets/game/digit_marker_access_candidate.png
assets/game/digit_marker_trace_candidate.png
assets/game/pause_modal_panel.png
assets/game/result_modal_success.png
assets/game/result_modal_failure.png
assets/game/modal_primary_button.png
assets/game/modal_secondary_button.png
```

## Task 3.2 Asset Generation Order

Task 3.2 should be split into smaller asset-generation phases.

### Phase 1: Core Input Area

Create only the core input assets first:

```text
assets/game/bomb_device_frame.png
assets/game/code_slot_empty.png
assets/game/code_slot_filled.png
assets/game/code_slot_selected.png
assets/game/keypad_button_idle.png
assets/game/keypad_button_pressed.png
assets/game/keypad_button_disabled.png
```

Purpose:

- Confirm the visual quality of the main password input area.
- Confirm the keypad style, transparency, bevel, and red LED accent.
- Avoid generating too many assets before the core style is approved.

### Phase 2: Status and History Panels

```text
assets/game/game_header_panel.png
assets/game/status_panel_small.png
assets/game/access_trace_panel.png
assets/game/history_panel.png
assets/game/history_row_panel.png
```

### Phase 3: Check Table / Memo Assets

```text
assets/game/check_table_panel.png
assets/game/digit_marker_unknown.png
assets/game/digit_marker_possible.png
assets/game/digit_marker_impossible.png
assets/game/digit_marker_access_candidate.png
assets/game/digit_marker_trace_candidate.png
```

### Phase 4: Modal / Result Assets

```text
assets/game/pause_modal_panel.png
assets/game/result_modal_success.png
assets/game/result_modal_failure.png
assets/game/modal_primary_button.png
assets/game/modal_secondary_button.png
```

Optional warning/success/failure overlays should be generated only after the main Game Screen layout is approved.

### Phase 5: Main Play Bomb-Centric Redesign Assets

Status: DONE

Created after `docs/GAME_SCREEN_REDESIGN_PLAN.md` was approved.

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

Purpose:

- Move the next Game Screen direction from a dense panel layout toward a bomb hero-centered main play screen.
- Give the top play area a stronger stylized bomb-defusal device identity.
- Support stable / caution / danger / critical visual status stages without changing game logic.
- Prepare dedicated Delete / Submit action button assets.
- Prepare Check Table button/modal assets so the Check Table grid can be removed from the default main screen.

Technical notes:

- `bomb_hero_*` assets use the same pixel size, transparent canvas, device alignment, body silhouette, and text-safe display area placement.
- `keypad_delete_button.png`, `keypad_submit_button.png`, and `keypad_submit_disabled.png` are designed to match the existing `keypad_button_*` family.
- All dynamic text, digits, difficulty labels, attempts, and timer values remain Flutter-rendered.

### Phase 5-B: Bomb Hero / Device Visual Rework

Status: DONE

Reworked targets:

```text
assets/game/bomb_device_frame.png
assets/game/bomb_hero_stable.png
assets/game/bomb_hero_caution.png
assets/game/bomb_hero_danger.png
assets/game/bomb_hero_critical.png
assets/game/main_play_required_assets_preview.png
```

Rework notes:

- The user approved the structure/alignment but requested a stronger "actual bomb-defusal device" feel.
- The rework reduced flat panel/frame styling and added a more device-like body with side housings, cables, connectors, bolts, warning lights, and recessed displays.
- The result remains stylized and safe-for-all-ages: no gore, no explosion, no horror mood, and no excessive military realism.
- `bomb_device_frame.png` now reads as a smaller bomb input module in the same visual family as the hero device.
- Validation confirmed RGBA PNG for target transparent assets, transparent corners, no baked text/numbers, and no bright chroma-green artifact.

## Task 3.3 Implementation Notes

- Keep gameplay rules in `GameController`, `judgeCode`, and `GameConfig` unchanged unless a UI bug proves otherwise.
- Prefer replacing current Material containers/buttons with asset-backed frames while preserving existing controller calls.
- Keep current functional widgets as natural implementation boundaries:
  - `LimitStatusBar`
  - `CodeSlots`
  - `NumberKeypad`
  - `CheckTable`
  - `GuessHistoryList`
- Use `AppBackground` and common background unless a later task explicitly introduces a game-specific background.
- Avoid baking text into image assets so Korean/English rendering remains possible.

### Task 3.3-A Implementation Snapshot

Status: IN PROGRESS / VERIFY

Applied:

```text
lib/features/game/game_screen.dart
lib/features/game/widgets/asset_frame.dart
lib/features/game/widgets/game_asset_paths.dart
lib/features/game/widgets/limit_status_bar.dart
lib/features/game/widgets/code_slots.dart
lib/features/game/widgets/number_keypad.dart
lib/features/game/widgets/guess_history_list.dart
lib/features/game/widgets/check_table.dart
pubspec.yaml
```

Implementation notes:

- `assets/game/` was added to `pubspec.yaml`.
- Main gameplay view first used approved Game Screen assets for header/status, code slots, keypad, latest Access/Trace, recent history, and check table.
- Task 3.3-C then simplified the main layout around the bomb hero, removing top status panels, READY panel, pause button, and inline Check Table bar.
- Active code slots now use `current_code_panel.png`; `bomb_device_frame.png` is preserved as an asset but is no longer used by active Game Screen code.
- Check Table opens from a top-right icon and reuses the existing CheckTable panel in a bottom sheet.
- `GameController`, `judgeCode`, and `GameConfig` were read but not modified.
- Delete/submit now use `keypad_delete_button.png`, `keypad_submit_button.png`, and `keypad_submit_disabled.png`.
- User-provided bomb hero replacements were normalized to `720x405 RGBA` transparent PNGs.
- QA still needed for 360x800 overflow, keypad touch target, hero overlay position, history compactness, and result modal fit.
- `dart format` should be run only on Dart files, not `pubspec.yaml`.

## Next Work

Next Task:

`Task 1.0 Android/DDS/Gradle Kotlin build stabilization`

Scope:

```text
Resolve DDS service protocol and Gradle Kotlin incremental storage failures so the simplified bomb-centric Game Screen can be live-tested.
```

After verification:

- Task 3.3-E Game Screen Responsive QA and Visual Polish
- Result modal polish if needed
