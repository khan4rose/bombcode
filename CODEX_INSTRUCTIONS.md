# CODEX_INSTRUCTIONS

Copy this into a new Codex chat before starting work on BoomCode.

## Project Context

You are working on `D:\jtj\bombcode`, a Flutter project for **BoomCode**, an offline bomb-defusal themed numeric code deduction game.

The game must use `Access / Trace` terminology only.

Do not use or introduce:

- Strike
- Ball
- S/B shorthand
- baseball terminology
- Korean baseball-scoring equivalents

Use:

- Access
- Trace
- A/T only when compact display is intentionally needed

## Work Style

- Before editing any file, read the current version of that file.
- Make the smallest safe change needed for the request.
- Do not rewrite the whole app.
- Do not refactor unrelated code.
- Do not delete user-created assets.
- Do not replace generated assets unless the user explicitly asks for replacement.
- If a file has user edits, work with them and do not revert them.
- At the end, list changed files and commands the user should run.

## Command Rules

- The user usually runs build/test/analyze commands directly.
- Do not run `flutter run`, `flutter build`, `flutter test`, or `flutter analyze` unless the user explicitly allows it for the current task.
- It is okay to read project files when needed.
- It is okay to generate image assets when the user asks for asset generation.
- For documentation tasks, create or update only requested docs.

## UI Style Rules

BoomCode visual style:

- dark sci-fi industrial
- brushed metal panels
- beveled steel frames
- red LED glow accents
- bomb-defusal game mood
- high contrast white/red/cyan/yellow text
- no cute/cartoon styling
- no default-looking plain Material UI when final art exists

Global background rule:

- All screens must use the common provided background:

```text
assets/menu/background.png
```

- Do not create per-screen background images unless the user explicitly asks.
- Screen-specific assets should be UI parts only: buttons, sliders, icons, panels.

Responsive layout rule:

- Every screen must adapt to phone size.
- Use `SafeArea`.
- Prefer `LayoutBuilder`, `FittedBox`, `Flexible`, `Expanded`, and responsive helpers.
- Avoid fixed full-screen pixel layouts except when mapping invisible hit areas over a full-screen image design.
- Avoid vertical overflow.
- Mission Setup must remain a single non-scrollable screen unless the user changes that requirement.

Localization rule:

- Screens must automatically switch Korean/English based on phone language.
- Current helper:

```text
lib/core/constants/app_text.dart
```

- Existing image menus use:
  - Korean if device language is `ko`
  - English otherwise

## Key Existing Rules

Difficulty defaults:

```text
Beginner: 2 digits, 20 attempts
Normal: 3 digits, 12 attempts
Expert: 4 digits, 7 attempts
```

Time limit options in Mission Setup:

```text
OFF / 5 min / 10 min / 15 min / 20 min
```

If time is OFF:

```text
LimitMode.attemptsOnly
```

If time is enabled:

```text
LimitMode.attemptsAndTime
```

## Important Files

```text
lib/features/mode_select/mode_select_screen.dart
```

- Mission Setup screen.
- Large file.
- Edit carefully.
- Do not convert it to scroll unless explicitly requested.

```text
lib/features/game/game_controller.dart
```

- Main gameplay state and rules.
- Do not touch for visual-only tasks.

```text
lib/core/utils/judge_code.dart
```

- Access/Trace logic.
- Do not touch unless fixing judgement tests.

```text
lib/domain/models/game_config.dart
```

- Difficulty defaults and config.

```text
lib/core/widgets/app_background.dart
```

- Common background wrapper.

```text
assets/mission_setup/
```

- Mission setup UI parts.
- PNG files should have transparent backgrounds.
- Text should not be baked into most UI assets.

## Image Asset Rules

For generated UI assets:

- Use transparent PNG.
- No baked text unless explicitly requested.
- No letters.
- No numbers.
- No watermark.
- Button frames should have empty center areas for code text.
- Plus/minus button images should not contain `+` or `-`; symbols are overlaid in code.
- Keep the dark sci-fi metal style consistent.

Current mission setup asset sizes:

```text
back_button.png                    192x192
difficulty_*_on/off.png            360x112
start_mission_button.png           1000x180
slider_track.png                   760x48
slider_thumb.png                   72x96
minus_button.png                   112x112
plus_button.png                    112x112
*_icon.png                         128x128
```

## Testing Guidance

Ask the user to run:

```bash
dart format .
flutter analyze
flutter test
flutter run
```

Only run these yourself if the user explicitly asks you to.

## Final Response Format

Keep final responses concise.

Include:

- changed files
- short summary
- commands for user to run

Do not include long implementation dumps unless requested.
