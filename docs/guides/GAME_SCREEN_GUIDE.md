# GAME_SCREEN_GUIDE

Read this only for Game Screen, result overlay, Check Table modal, keypad, history, or game visual polish work.

---

## Active Structure

Main gameplay flow:

```text
Bomb HUD
Current Code
Keypad
History
```

Active file cluster:

```text
lib/features/game/game_screen.dart
lib/features/game/widgets/asset_frame.dart
lib/features/game/widgets/check_table.dart
lib/features/game/widgets/code_slots.dart
lib/features/game/widgets/game_asset_paths.dart
lib/features/game/widgets/guess_history_list.dart
lib/features/game/widgets/number_keypad.dart
```

Protected for visual-only Game Screen work:

```text
lib/features/game/game_controller.dart
lib/core/utils/judge_code.dart
lib/domain/models/game_config.dart
```

---

## Current Visual Rules

- Use `AppBackground`; do not create a new full-screen background.
- Preserve portrait non-scroll gameplay layout.
- Use responsive sizing, not fixed pixel layout.
- Keep keypad touch targets around 48dp.
- Text and dynamic numbers must be Flutter-rendered.
- Preserve `Access` and `Trace`; never use baseball terms.
- Do not show the Check Table grid on the default main screen.
- Keep History internally scrollable.

---

## Bomb HUD

Assets:

```text
assets/game/bomb_hero_stable.png
assets/game/bomb_hero_caution.png
assets/game/bomb_hero_danger.png
assets/game/bomb_hero_critical.png
```

Rules:

- Four bomb hero states share the same canvas and alignment.
- Stage changes should not shake, shift, or scale the image.
- Use fixed-position hero images with light/glow overlays.
- HUD shows `LEFT` and `TIME`; no difficulty text in the active HUD.
- Attempts OFF should display as unlimited/OFF behavior according to current UI code.

---

## Current Code and Keypad

Current Code assets:

```text
assets/game/code_slot_empty.png
assets/game/code_slot_filled.png
assets/game/code_slot_selected.png
```

Keypad assets:

```text
assets/game/keypad_button_idle.png
assets/game/keypad_button_pressed.png
assets/game/keypad_button_disabled.png
assets/game/keypad_delete_button.png
assets/game/keypad_submit_button.png
assets/game/keypad_submit_disabled.png
```

Rules:

- Selected slot must be visible without relying only on text.
- Delete/Submit labels are Flutter-rendered.
- Disabled buttons should not animate or respond as active controls.
- Button press feedback must not change layout size.

---

## History

Assets:

```text
assets/game/history_panel.png
assets/game/history_row_panel.png
assets/game/check_table_bulb_icon.png
```

Rules:

- Latest guess appears first.
- Header and rows share the same `# / CODE / RESULT` columns.
- Result display uses green `A` and blue `T`.
- Empty state uses compact `STANDBY`.
- Check Table entry sits in the History panel area.

---

## Check Table

Assets:

```text
assets/game/check_table_panel.png
assets/game/check_table_modal_panel.png
assets/game/modal_close_button.png
assets/game/digit_marker_unknown.png
assets/game/digit_marker_possible.png
assets/game/digit_marker_impossible.png
assets/game/digit_marker_access_candidate.png
assets/game/digit_marker_trace_candidate.png
```

Current state:

- Main screen grid is hidden.
- Existing bottom sheet reuses `CheckTable`.
- Manual digit mark cycling and auto mark behavior must be preserved.
- Applying modal panel and close button is still a small future polish task.

---

## Result Overlay

Assets:

```text
assets/game/result/failure_scene_bg.png
assets/game/result/failure_result_panel.png
assets/game/result/failure_title_en.png
assets/game/result/failure_title_ko.png
assets/game/result/result_button_primary.png
assets/game/result/result_button_secondary.png
assets/game/result/result_key_icon.png
assets/game/result/success_bg.png
assets/game/result/success_panel.png
assets/game/result/success_title_en.png
assets/game/result/success_title_ko.png
assets/game/modal_primary_button.png
assets/game/modal_secondary_button.png
```

Rules:

- Result overlay uses a shared 4-layer cinematic composition for Success and Failure:
  background image, panel/frame image, localized title image, Flutter dynamic UI.
- Failure hides the gameplay layer behind the result scene; Success may overlay from the finished gameplay state but must use the same composition system.
- Failure has a dedicated Flutter-only reveal sequence:
  `failure_scene_bg.png` appears immediately, the scene shakes briefly, explosion light flickers over the background, then panel/title/code/buttons appear nearly together through a shade reveal.
- Failure should not use a strong full-screen red flash; any impact lighting should read as light over the existing explosion scene, not as a solid red error screen.
- Failure reveal must be skippable by tapping; while skipping/revealing, taps should not trigger `TRY AGAIN` or `HOME`.
- Background image should read as a cinematic result scene, not a tiny decoration.
- Preserve SafeArea and full visibility of `TRY AGAIN` and `HOME`.
- Use the upper area to reveal the bomb/explosion/defused-device scene; roughly the upper 35-40% should feel like cinematic background, not panel.
- Keep the panel visually dominant enough to hold information, but do not let it become a giant card blocking the scene.
- Title/subtitle should be localized image art, not plain Flutter text, when assets are available.
- Dynamic result text and button labels must remain Flutter-rendered.
- Success may show Answer, Attempts, Time, Try Again, and Home.
- Failure currently shows only the correct code with a key icon, plus Try Again and Home; do not show `ANSWER`, `ATTEMPTS`, or `TIME` on Failure unless the user explicitly asks to restore them.
- Avoid `SingleChildScrollView` for result modal fixes.
- Do not hide overflow with clipping as the primary solution.
- Prefer `LayoutBuilder`, responsive height, compact padding, and localized scrim/shadow for readability.

Failure-specific rules:

- Failure uses `assets/game/result/failure_scene_bg.png`, `failure_result_panel.png`, and localized title assets.
- Failure uses `assets/game/result/result_key_icon.png` beside the correct code in the answer area.
- Failure uses `assets/game/result/result_button_primary.png` for `TRY AGAIN` / `다시 시도`.
- Failure uses `assets/game/result/result_button_secondary.png` for `HOME` / `홈으로`.
- Failure title image contains only `MISSION FAILED` / `DEVICE DETONATED` or Korean equivalent.
- Failure correct-code value and button labels are Flutter-rendered over the panel/button assets; do not bake the code value, `TRY AGAIN`, or `HOME` into the assets.
- Failure answer area should read as `[key icon] 1234`: centered, game-like, and visually dominant inside the red outlined code box.
- Failure should feel like a dedicated cinematic warning scene, not a generic app modal/card.
- Hide the gameplay layer itself during Failure. Do not rely on heavy full-screen fog or central black gradients to hide keypad/history/current code.
- Keep the bomb/explosion/smoke background visible, especially between the bomb scene and the warning panel.
- Precache Failure result assets before the overlay appears when possible, so the detonation background does not momentarily show a blank frame.
- If additional masking is needed, keep it localized to the lower gameplay residue area and preserve center-scene detail.
- Do not modify Success while doing a failure-only result asset/reveal task.

Success-specific rules:

- Success uses `assets/game/result/success_bg.png`, `success_panel.png`, and localized title assets.
- Success title image contains only `MISSION COMPLETE` / `DEVICE DEFUSED` or Korean equivalent.
- Success should feel rewarding and controlled, but still dark sci-fi industrial.
- Do not let Success regress to the older plain modal/card direction.

QA checklist:

- Success overlay is large and clear.
- Failure overlay is large and clear.
- Korean and English localized title images select correctly for both Success and Failure.
- Success stats remain readable and aligned over the panel.
- Failure code row remains readable, centered, and clearly understood as the correct code.
- Buttons are fully visible.
- Result panel assets remain free of dynamic values and button labels.
- Failure background scene remains visible while gameplay UI is hidden.
- Success background scene remains visible and not over-obscured by the panel.
- No `BOTTOM OVERFLOWED` on `360x800` or smaller portrait heights.
