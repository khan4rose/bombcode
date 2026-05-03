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
- At the end of every task, always include a short list of what the user should do next.

## Command Rules

- The user usually runs build/test/analyze commands directly.
- Do not run app/build/check/format commands unless the user explicitly allows it for the current task.
- This includes `flutter run`, `flutter build`, `flutter test`, `flutter analyze`, and `dart format`.
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

Main menu image rule:

- `assets/menu/main_menu_eng.png` and `assets/menu/main_menu_kor.png` are visual references.
- The active Home screen uses `assets/menu/background.png` plus language-specific complete PNG UI parts.
- Main menu button images must be complete generated images with their text already integrated into the artwork.
- Do not make main menu buttons by generating empty frames and then drawing or overlaying Flutter text on top.
- Do not post-compose text onto empty button frames unless the user explicitly requests that workflow.
- Keep Korean and English main menu button assets as separate files.
- The visible exit button has been removed and should not be reintroduced unless the user explicitly asks.

Responsive layout rule:

- Every screen must adapt to phone size.
- Design from a single base canvas of `360 x 800 dp`, but treat it only as the reference size, not as fixed pixels.
- All production screens must be non-scrollable by default. Do not use `SingleChildScrollView` for main game/menu/setup screens unless the user explicitly changes this requirement.
- Use `SafeArea` on every full-screen UI.
- Use `LayoutBuilder` or `MediaQuery` to read the actual available screen size.
- Calculate responsive scale values for every screen:

```dart
final scaleW = constraints.maxWidth / 360.0;
final scaleH = constraints.maxHeight / 800.0;
final scale = math.min(scaleW, scaleH);
```

- Apply `scale` to font sizes, button heights, icon sizes, margins, gaps, and padding.
- For horizontal sizes, prefer percentages of available width, for example `width * 0.82` or `FractionallySizedBox(widthFactor: 0.82)`.
- Prefer flexible layout relationships over fixed coordinates: `Column`, `Row`, `Expanded`, `Flexible`, `Spacer`, `Align`, `FractionallySizedBox`, `AspectRatio`, and `FittedBox`.
- Avoid fixed full-screen pixel layouts except when mapping invisible hit areas over a full-screen image design.
- Avoid vertical overflow. If a small device would overflow, shrink spacing, logo, fonts, buttons, and icons proportionally; do not add scrolling.
- Large logo/title/image areas must use `FittedBox`, `AspectRatio`, or `BoxFit.contain` so they never clip or distort.
- Full-screen backgrounds must use `BoxFit.cover`.
- UI-part images such as button frames should normally use `BoxFit.contain` unless the asset is designed to stretch safely.
- Maintain minimum practical touch targets around `48dp` when possible, but for very small screens prioritize fitting the entire screen without overflow.
- Text must never overflow. Use `FittedBox`, `maxLines`, and responsive font sizes where needed.
- Mission Setup must remain a single non-scrollable screen unless the user changes that requirement.

Recommended vertical structure for menu-like screens:

```text
SafeArea
└─ LayoutBuilder
   └─ Stack / AppBackground
      └─ Column
         ├─ Top status area      flex: 1
         ├─ Logo/title area      flex: 3
         ├─ Main buttons area    flex: 4
         └─ Bottom icons area    flex: 2
```

For the Home/Main Menu screen specifically:

- Build the screen by composing independent image parts: background, logo/title, button images, coin panel, and bottom icon buttons.
- Do not use one giant full-screen menu image as the final UI unless the user explicitly asks for image-map style.
- Main menu must fit without vertical scrolling on Galaxy S23 Ultra and smaller common Android phones.
- Test layout at least conceptually against these sizes: `360x640`, `360x800`, `393x873`, `411x891`, and Galaxy S23 Ultra-like tall screens.

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

```text
lib/features/home/home_screen.dart
```

- Home/main menu screen.
- Use language-specific complete image buttons under `assets/menu/`.
- Do not overlay Flutter text on main menu buttons.
- Do not use invisible full-screen coordinate hit areas as the primary UI unless the user explicitly requests a full-screen image-map approach.
- Do not add an exit button unless explicitly requested.

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

Exception:

- Main menu buttons are explicitly required to have baked text inside the generated image.
- Main menu text must be generated as part of the whole button image, not added later as a separate overlay.

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

## Version Control Guidance

When the user asks to update `PROJECT_STATUS.md`, `NEXT_TASKS.md`, and optionally `CODEX_INSTRUCTIONS.md`, include a short Git version-control checklist after the update.

Use this sequence:

```bash
git status --short
git add .
git status --short
git diff --cached --stat
git commit -m "Update project status and task notes"
git log --oneline -5
git push
```

If this is the first push for the current branch, tell the user to check the branch name and push with upstream tracking:

```bash
git branch --show-current
git push -u origin <branch-name>
```

Only recommend `git add .` when `.gitignore` already excludes local scratch/review files such as:

```text
tmp/
Old_Save/
assets/capture/
```

## Final Response Format

Keep final responses concise.

Include:

- changed files
- short summary
- commands for user to run

Do not include long implementation dumps unless requested.
