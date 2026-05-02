# BoomCode Mission Setup Screen - Single Screen UI + Asset Generation Spec

## 0. Purpose
Create the `Mission Setup` screen for BoomCode as a single non-scrollable mobile game setup screen.

The current Codex result made the screen too tall and required scrolling. This must be fixed.

Main goals:
- Everything must fit on one phone screen.
- No vertical scroll.
- Keep the same dark sci-fi metal style as the main screen.
- Use separate PNG image assets for background, buttons, sliders, and icons.
- Text must be rendered in code, not baked into most images.

---

## 1. Required Screen Result

The screen must visually match this direction:

- Dark metal industrial background
- Red LED glow accents
- Compact high-density layout
- Game-like UI, not default Android Material UI
- Strong beveled metal frames
- Clear readable white/red/cyan/yellow text
- All controls visible at once

Target screen ratio:
- Portrait mobile layout
- Design around 1080 x 2400 or similar
- Must adapt to common Android phone sizes

Important:
- Do not use a scrollable Column for the full screen.
- Do not allow content to overflow below the bottom.
- Do not split the screen into two pages.
- Reduce padding, spacing, and component heights until everything fits.

---

## 2. Layout Structure

Use this vertical order:

1. Top bar
2. Title area
3. Difficulty selector
4. Difficulty summary card
5. Limit Mode section
6. Options section
7. Start Mission button

Recommended compact height distribution:

| Area | Approx. Height |
|---|---:|
| Top bar + title | 12% |
| Difficulty selector | 10% |
| Difficulty summary | 13% |
| Limit Mode | 27% |
| Options | 25% |
| Start button | 13% |

---

## 3. Top Bar

Components:
- Back button at upper-left
- Title centered: `MISSION SETUP` for English / `미션 설정` for Korean
- Subtitle centered: `SET YOUR CHALLENGE` / `도전 조건 설정`

Rules:
- Back button should use `back_button.png`.
- Title and subtitle are code text, not image text.
- Header height must be compact.

---

## 4. Difficulty Selector

Use a horizontal 3-button bar:

- Beginner / 초급
- Normal / 중급
- Expert / 고급

Each difficulty uses image state:

- `difficulty_beginner_on.png`
- `difficulty_beginner_off.png`
- `difficulty_normal_on.png`
- `difficulty_normal_off.png`
- `difficulty_expert_on.png`
- `difficulty_expert_off.png`

Rules:
- Only one difficulty is ON at a time.
- ON button: red glow / highlighted.
- OFF button: dark metal.
- Text and small icon can be overlaid by Compose.
- Do not bake text into button images.

Difficulty values:

| Difficulty | Korean | Digits | Attempts | Timer | Reward |
|---|---|---:|---:|---|---:|
| Beginner | 초급 | 2 | 20 | Off | 100 |
| Normal | 중급 | 3 | 12 | Off | 200 |
| Expert | 고급 | 4 | 7 | Off | 300 |

---

## 5. Difficulty Summary Card

Show 3 columns in one compact card:

1. Digits
2. Timer
3. Reward

Use icons:

- `digits_icon.png`
- `timer_icon.png`
- `reward_icon.png`

Example English text:

- `2 DIGITS`
- `20 TRIES`
- `NO TIMER`
- `ATTEMPTS ONLY`
- `REWARD 100`

Example Korean text:

- `2자리`
- `20회`
- `타이머 없음`
- `횟수 제한`
- `보상 100`

Rules:
- Use one row with three columns.
- Keep icons small.
- Do not make this section tall.

---

## 6. Limit Mode Section

Section title:
- English: `LIMIT MODE`
- Korean: `제한 모드`

This section must fit without scrolling.

Controls:

### 6.1 Attempts Limit

Use:
- minus button: `minus_button.png`
- slider track: `slider_track.png`
- slider thumb: `slider_thumb.png`
- plus button: `plus_button.png`

Value range:
- Min: 7
- Max: 20
- Default by selected difficulty:
  - Beginner: 20
  - Normal: 12
  - Expert: 7

Displayed value:
- English: `20 TRIES`
- Korean: `20회`

Tick labels:
- 7 / 10 / 15 / 20

### 6.2 Time Limit

Use the same slider assets.

Values:
- OFF
- 01:00
- 03:00
- 05:00

Displayed value:
- English: `00:00 OFF`
- Korean: `00:00 꺼짐`

Rules:
- Attempts slider and time slider must both be visible.
- Use compact row layout.
- Do not use large default Material sliders.
- Custom draw or image-based slider is preferred.

---

## 7. Options Section

Section title:
- English: `OPTIONS`
- Korean: `옵션`

Controls:

### 7.1 Sound Volume

Use:
- `sound_icon.png`
- `slider_track.png`
- `slider_thumb.png`

Default:
- 70%

### 7.2 Music Volume

Use:
- `music_icon.png`
- `slider_track.png`
- `slider_thumb.png`

Default:
- 50%

### 7.3 Vibration Toggle

Use:
- `vibration_icon.png`

Default:
- ON

### 7.4 Auto Check Table Toggle

Use:
- `check_table_icon.png`

Default:
- ON for Beginner
- User selectable for other modes

Rules:
- Options section must be compact.
- Sound and Music sliders should be shorter than the Limit Mode sliders.
- Vibration and Auto Check Table should be one-line rows.
- Do not use large default switches if they break the theme; style them red/dark metal.

---

## 8. Start Mission Button

Use:

- `start_mission_button_eng.png`
- `start_mission_button_kor.png`

Important:
- These button images should NOT contain text.
- Button text must be overlaid in code:
  - English: `START MISSION`
  - Korean: `미션 시작`

Rules:
- Full width button near bottom.
- Must be visible without scrolling.
- Red metallic premium style.

---

## 9. Required PNG Asset List

Generate or prepare these files:

```text
mission_setup_bg_eng.png
mission_setup_bg_kor.png
back_button.png
difficulty_beginner_on.png
difficulty_beginner_off.png
difficulty_normal_on.png
difficulty_normal_off.png
difficulty_expert_on.png
difficulty_expert_off.png
start_mission_button_eng.png
start_mission_button_kor.png
slider_track.png
slider_thumb.png
minus_button.png
plus_button.png
sound_icon.png
music_icon.png
vibration_icon.png
digits_icon.png
timer_icon.png
reward_icon.png
check_table_icon.png
```

---

## 10. Asset Generation Rules

All assets must follow the same visual style:

```text
dark sci-fi industrial UI, metallic frame, brushed steel texture, red LED glow accents,
high contrast, mobile game UI, cyberpunk, sharp beveled edges, realistic lighting,
transparent background for isolated UI elements, no text, no letters, no numbers
```

Critical rules:
- Do not combine all assets into one sprite sheet unless separately requested.
- Output each asset as an individual PNG.
- For button/frame assets, do not include text.
- For plus/minus buttons, do not include the + or - symbol if the symbol will be rendered in code.
- For icons, no words or labels.
- Background images can be full screen and do not need transparency.

---

## 11. Asset-Specific Prompts

### 11.1 mission_setup_bg_eng.png / mission_setup_bg_kor.png

```text
dark sci-fi metallic panel background for mobile game setup screen, empty center area,
industrial frame edges, subtle red LED glow, brushed steel texture, clean readable center,
no text, no icons, no buttons, portrait mobile background, high detail
```

### 11.2 back_button.png

```text
square metallic sci-fi back button frame, dark steel, red LED glow, beveled edges,
empty center or simple red arrow shape, transparent background, no text
```

### 11.3 difficulty_*_on.png

```text
horizontal sci-fi metallic difficulty button frame, active selected state, red glowing edge,
dark brushed metal body, beveled corners, small icon slot area, empty center,
transparent background, no text, no letters, no numbers
```

### 11.4 difficulty_*_off.png

```text
horizontal sci-fi metallic difficulty button frame, inactive state, dark gray steel,
minimal red glow, beveled corners, small icon slot area, empty center,
transparent background, no text, no letters, no numbers
```

### 11.5 start_mission_button_eng.png / start_mission_button_kor.png

```text
large horizontal red metallic sci-fi button frame, strong red LED glow, premium game UI,
beveled steel corners, empty center for text overlay, transparent background,
no text, no letters, no numbers
```

### 11.6 slider_track.png

```text
horizontal sci-fi slider track, dark metallic base, red glowing progress line,
clean thin game UI bar, transparent background, no text, no numbers
```

### 11.7 slider_thumb.png

```text
small vertical sci-fi metallic slider thumb handle, glowing red core, beveled steel,
centered, transparent background, no text
```

### 11.8 minus_button.png / plus_button.png

```text
small square sci-fi metallic button frame, dark steel, subtle red LED glow,
empty center for symbol overlay, transparent background, no text, no symbols
```

### 11.9 sound_icon.png

```text
small sci-fi metallic speaker icon with red glow, clean silhouette, transparent background,
no text
```

### 11.10 music_icon.png

```text
small sci-fi metallic music note icon with red glow, clean silhouette, transparent background,
no text
```

### 11.11 vibration_icon.png

```text
small sci-fi metallic vibration phone icon with red glow and vibration lines,
transparent background, no text
```

### 11.12 digits_icon.png

```text
small sci-fi metallic number block icon, abstract digits or stacked blocks, red glow,
transparent background, no text, no readable numbers
```

### 11.13 timer_icon.png

```text
small sci-fi metallic stopwatch icon with red glow, transparent background, no text
```

### 11.14 reward_icon.png

```text
small sci-fi metallic reward coin or star badge icon with red/gold glow,
transparent background, no text, no numbers
```

### 11.15 check_table_icon.png

```text
small sci-fi metallic checklist grid icon with red glow, transparent background,
no text, no letters, no numbers
```

---

## 12. Implementation Instructions for Codex

1. Create or update the Mission Setup screen.
2. Keep everything on one screen.
3. Remove the full-screen scroll container.
4. Use compact layout spacing.
5. Use image assets listed above.
6. Overlay text with Compose/Text widgets.
7. Use state to switch difficulty button images.
8. Use custom slider visuals with slider track/thumb assets.
9. Ensure English/Korean text can be changed through strings.xml or localization.
10. Test on emulator in portrait orientation.

---

## 13. Acceptance Criteria

The work is complete only if:

- Mission Setup screen fits in one screen without scrolling.
- Start Mission button is visible at the bottom immediately.
- Difficulty selector uses horizontal bar buttons.
- Attempts and Time controls are both visible.
- Sound and Music controls are visible.
- Vibration and Auto Check Table options are visible.
- Design visually matches BoomCode main screen.
- No image asset contains unwanted text.
- All requested PNG filenames exist.
- English and Korean versions can be shown.

---

## 14. Notes

Do not redesign the whole game.
Only modify the Mission Setup screen and its required assets.
