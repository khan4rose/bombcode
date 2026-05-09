# ASSET_RULES

Read this for asset generation, replacement, cleanup, or visual QA involving PNG files.

---

## Global Rules

- Do not delete user-created or generated assets unless explicitly requested.
- Before deleting an asset, check source and docs references with `rg`.
- Dynamic text, numbers, timer values, attempts, and difficulty labels should be Flutter-rendered whenever possible.
- Button frame assets should not bake localized labels.
- Use transparent PNGs for UI parts unless a full background is explicitly intended.
- Check for chroma/green-edge artifacts after generated asset cleanup.
- Keep visual style consistent: dark sci-fi industrial, brushed metal, beveled steel, red LED accents.

---

## Common Background

```text
assets/menu/background.png
```

- Shared by main screens via `AppBackground`.
- Use `BoxFit.cover`.
- Do not create per-screen full backgrounds unless requested.

---

## Main Menu Assets

Current active menu uses independent parts, not one giant baked UI.

Rules:

- Main button text is Flutter-rendered.
- Start Game uses red primary frame.
- Difficulty/Records/Settings use dark secondary frames.
- Shop/Remove Ads/Help are icon-only utility buttons with semantic labels.
- Touch area and visible icon size may differ.
- Currency panel is currently a blank future display frame.

Reference images may remain as visual references and are not active UI.

---

## Mission Setup Assets

Rules:

- Use common background.
- Difficulty selected/off assets are image frames only; text remains Flutter-rendered.
- Plus/minus frame assets must not bake `+` or `-`; symbols are overlaid in code.
- Attempts/Time slider visual state should be driven from one value list.
- Keep single-screen non-scroll layout.

Archived detailed generation notes:

```text
docs/archive/completed_plans/codex_mission_setup_assets.md
```

---

## Game Assets

Game assets are under:

```text
assets/game/
```

Important active groups:

```text
bomb_hero_stable/caution/danger/critical.png
code_slot_empty/filled/selected.png
keypad_button_idle/pressed/disabled.png
keypad_delete_button.png
keypad_submit_button.png
keypad_submit_disabled.png
history_panel.png
history_row_panel.png
check_table_panel.png
digit_marker_*.png
result/failure_scene_bg.png
result/failure_result_panel.png
result/failure_title_en.png
result/failure_title_ko.png
result/result_button_primary.png
result/result_button_secondary.png
result/result_key_icon.png
result/success_bg.png
result/success_panel.png
result/success_title_en.png
result/success_title_ko.png
modal_primary_button.png
modal_secondary_button.png
```

Rules:

- Bomb hero state assets must share canvas, alignment, silhouette, and display-safe zones.
- Stage differences should be lights, glow, warning surfaces, and mood, not size/position jumps.
- Result background assets may be cinematic portrait scenes, but code must preserve SafeArea and button visibility.
- Result panel assets should be transparent PNG frame/surface art with no dynamic values and no button labels.
- Failure result currently uses the user-provided `failure_scene_bg.png`, `failure_result_panel.png`, localized failure titles, and result button frame assets.
- Failure result also uses `result_key_icon.png` as a transparent cyber/metal key icon beside the correct code.
- Failure result button assets are frame/background images only; `TRY AGAIN`, `HOME`, `다시 시도`, and `홈으로` remain Flutter-rendered.
- Result title assets may contain only the static result title/subtitle for each language:
  `MISSION FAILED` / `DEVICE DETONATED`,
  `MISSION COMPLETE` / `DEVICE DEFUSED`,
  `미션 실패` / `장치가 폭발했습니다`,
  `미션 성공` / `장치 해제 성공`.
- Keep result dynamic text and button labels Flutter-rendered.
- Success may render Answer, Attempts, Time, Try Again, and Home.
- Failure currently renders only the correct code plus Try Again and Home; do not bake the code value or button labels into result images.
- Do not modify original PNGs during layout-only tasks.
- Allowed technical preparation on user-provided result assets is limited to alpha/transparency cleanup, removing unintended checkerboard/background, cropping empty margins, resizing/optimization, and PNG format correction without redesign.

Archived full asset inventory:

```text
docs/archive/completed_plans/GAME_SCREEN_ASSET_LIST.md
docs/archive/completed_plans/GAME_SCREEN_REDESIGN_PLAN.md
```

---

## Release Assets

For Android launch/icon work:

- Confirm app icon and launch screen direction before replacing files.
- Do not touch Flutter game logic.
- Keep release metadata changes scoped to Android/release task.
