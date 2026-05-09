# UI_GUIDELINES

이 문서는 BoomCode의 모든 화면과 이미지 asset에 적용할 UI 규칙이다. UI 작업 전 반드시 읽는다.

## 1. 전체 비주얼 방향

BoomCode의 visual style:

- dark sci-fi industrial
- brushed metal panels
- beveled steel frames
- red LED glow accents
- bomb-defusal game mood
- high contrast white/red/cyan/yellow text
- no cute/cartoon styling
- final art가 있는 경우 default-looking plain Material UI 지양

권장 색감:

- 배경: 검정, 어두운 회색, metallic gray
- 강조: red, cyan, yellow, white
- 중요 action: red 계열

## 2. 기준 화면

| 항목 | 기준 |
| --- | --- |
| 기준 해상도 | `360 x 800 dp` |
| 우선 화면 | Android phone portrait |
| 기본 구성 | 전체 화면, `SafeArea`, non-scroll 우선 |
| 공통 배경 | `assets/menu/background.png` |

`360 x 800 dp`는 기준 캔버스일 뿐 fixed pixel layout으로 사용하지 않는다. 모든 화면은 phone size에 맞게 자동 조절되어야 한다.

## 3. 공통 배경 규칙

모든 주요 화면은 다음 공통 배경을 사용한다.

```text
assets/menu/background.png
```

규칙:

- screen-specific background image를 새로 만들지 않는다.
- 사용자 요청이 있을 때만 per-screen background를 만든다.
- screen-specific asset은 button, slider, icon, panel 같은 UI part 중심으로 만든다.
- full-screen background는 `BoxFit.cover`를 사용한다.
- `AppBackground`를 표준 배경 wrapper로 사용한다.

## 4. 반응형 레이아웃 기준

기본 구조:

```dart
final scaleW = constraints.maxWidth / 360.0;
final scaleH = constraints.maxHeight / 800.0;
final scale = math.min(scaleW, scaleH);
```

적용 대상:

- font size
- button height
- icon size
- margin
- gap
- padding

원칙:

- 모든 full-screen UI는 `SafeArea`를 사용한다.
- 화면 크기는 `LayoutBuilder` 또는 `MediaQuery`로 읽는다.
- production main/menu/setup screen은 기본적으로 non-scroll이어야 한다.
- 사용자 요청 없이 main game/menu/setup screen에 `SingleChildScrollView`를 사용하지 않는다.
- 가로 크기는 fixed width보다 사용 가능한 너비의 비율을 우선한다.

예:

```dart
width * 0.82
FractionallySizedBox(widthFactor: 0.82)
```

권장 widget:

- `SafeArea`
- `LayoutBuilder`
- `MediaQuery`
- `Column`
- `Row`
- `Expanded`
- `Flexible`
- `Spacer`
- `Align`
- `FractionallySizedBox`
- `AspectRatio`
- `FittedBox`

## 5. Overflow 방지 규칙

- vertical overflow 금지
- 작은 화면에서 overflow가 예상되면 spacing, logo, font, button, icon을 비례 축소한다.
- overflow 해결을 위해 즉시 scroll을 추가하지 않는다.
- logo/title/image 영역은 `FittedBox`, `AspectRatio`, `BoxFit.contain`으로 clip/distortion을 방지한다.
- text는 `FittedBox`, `maxLines`, `overflow`, responsive font size를 사용해 overflow를 방지한다.
- 최소 touch target은 가능하면 `48dp` 근처를 유지한다.
- 매우 작은 화면에서는 전체 화면 적합을 우선한다.

## 6. 권장 화면 구조

Menu-like screen 권장 vertical structure:

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

고정 좌표는 불가피한 이미지맵 방식 또는 정밀한 장식 배치에만 제한적으로 사용한다.

## 7. Result Screen UI 규칙

- Result screens should feel like cinematic game scenes, not plain Flutter cards.
- Use layered composition: background scene, dark/flash overlay if needed, panel/frame image, localized title image, Flutter-rendered dynamic text, and image-backed buttons.
- Failure reveal should avoid strong full-screen solid-color flashes. Prefer scene-based effects: brief shake, brightness/contrast flicker, warm light over the background, and a shade reveal for the panel.
- Failure result currently shows only the correct code in the answer area, paired with a cyber/metal key icon; do not show `ANSWER`, `ATTEMPTS`, or `TIME` labels on Failure unless requested.
- Failure code row should stay centered, large, and readable inside the red outlined code box.
- Failure `TRY AGAIN` and `HOME` buttons use image backgrounds, but labels remain Flutter text.
- Preserve SafeArea, button visibility, and no bottom overflow on `360 x 800 dp` and smaller portrait heights.

## 8. Button 규칙

- 버튼은 실제 Flutter tap target이어야 한다.
- 이미지 버튼도 `Semantics` label을 갖도록 한다.
- Main Menu 주요 버튼은 공통 frame PNG와 Flutter `Text` 조합을 사용한다.
- Main Menu button text는 코드에서 렌더링한다.
- Main Menu 하단 utility button은 화면 텍스트 없이 icon-only PNG를 사용한다.
- Mission Setup과 Game Screen의 일반 UI part는 가능한 frame/icon image만 사용한다.
- 일반 UI part의 text, number, `+`, `-`는 code에서 렌더링한다.

## 9. Text / Localization UI 규칙

- 화면은 기기 언어에 따라 Korean/English 자동 전환한다.
- 현재 helper:

```text
lib/core/constants/app_text.dart
```

- 기존 image logo는 다음 규칙을 사용한다.
  - device language가 `ko`이면 Korean logo asset
  - 그 외에는 English logo asset

텍스트 처리 규칙:

- text는 overflow 되면 안 된다.
- Korean/English text는 가능한 code에서 처리한다.
- Main Menu button은 공통 frame asset 위에 Flutter `Text`를 사용한다.
- 그 외 대부분의 UI asset은 text 없는 frame/icon으로 만들고 Flutter text로 처리한다.

## 10. Home / Main Menu UI 규칙

Home screen은 다음 독립 image part를 조합해서 만든다.

- background
- logo/title
- button images
- coin/currency panel
- bottom icon buttons

금지:

- 사용자 요청 없이 one giant full-screen menu image를 final UI로 사용하지 않는다.
- 사용자 요청 없이 invisible full-screen coordinate hit area를 primary UI로 사용하지 않는다.
- visible exit button을 재도입하지 않는다.

Main Menu button 규칙:

- Main Menu button image는 text 없는 공통 frame PNG를 사용한다.
- Primary / Secondary / Bottom button text style을 분리한다.
- 버튼별로 임의 fontSize를 지정하지 않고 버튼 종류와 언어 기준으로만 보정한다.
- 기존 Korean/English text baked button asset은 보존하되 active UI에서는 사용하지 않는다.

참고 이미지:

```text
assets/menu/main_menu_eng.png
assets/menu/main_menu_kor.png
```

주의:

- 위 파일들은 visual reference이며 active layout 전체 이미지가 아니다.
- active Home screen은 `assets/menu/background.png`와 개별 UI parts로 구성한다.

현재 layout 결정:

- Start Game은 red primary button
- Difficulty, Records, Settings는 dark secondary button
- Shop, Remove Ads, Help는 icon-only asset을 사용하고 화면 텍스트를 표시하지 않는다.
- 하단 utility button은 Semantics label로 접근성 의미를 유지한다.
- 하단 utility button은 터치 영역과 보이는 icon size를 분리한다.
- 하단 utility icon size는 화면 width 기반으로 계산하고 최소/최대 clamp를 둔다.
- 하단 utility icon layout은 `Center` + 명확한 square size를 사용하고, parent height 기반 크기 계산이나 애니메이션 scale loop를 피한다.
- Start Game과 Select Difficulty 사이 세로 gap 없음
- Records / Settings는 아주 작은 responsive gap 유지
- Main buttons는 로고 무게감과 맞도록 약간 두껍게 조정됨
- Currency panel은 blank future currency display frame
- Currency panel은 long/thin보다 short/thick 느낌
- 현재 `assets/menu/menu_currency.png`는 짧고 두껍게 보이게 하기 위해 `BoxFit.fill` 사용 중
- Bottom utility buttons는 축소되어 있고 충분한 mutual spacing과 하단 SafeArea 여백을 유지한다.
- Android viewport/insets 흔들림이 재발하면 Home 화면 layout과 Android window 설정을 함께 확인한다.

테스트 기준 화면:

```text
360x640
360x800
393x873
411x891
Galaxy S23 Ultra-like tall screens
```

## 11. Mission Setup UI 규칙

- Mission Setup은 사용자 요청 전까지 단일 non-scroll 화면 유지
- `LayoutBuilder` 유지
- 공통 배경 `assets/menu/background.png` 사용
- 모든 text는 Flutter widget으로 렌더링
- Mission Setup asset은 대부분 text를 bake하지 않는다.
- Difficulty, timer, sound/music/vibration/check table controls는 화면 내에 overflow 없이 배치
- `assets/mission_setup/` PNG는 transparent background여야 한다.
- plus/minus button image에는 `+`, `-` symbol을 넣지 않는다.
- `+`, `-` symbol은 code에서 overlay한다.

현재 Mission Setup asset size 기준:

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

## 12. Image Asset 생성 규칙

일반 generated UI asset:

- transparent PNG
- no baked text unless explicitly requested
- no letters
- no numbers
- no watermark
- button frame은 code text를 넣을 수 있는 empty center area 유지
- plus/minus button image에는 `+`, `-` symbol을 넣지 않는다.
- dark sci-fi metal style 유지
- 기존 user-created asset은 삭제하거나 교체하지 않는다.
- asset을 추가하면 `pubspec.yaml` 등록 필요 여부를 확인한다.
- icon-only utility asset은 바깥 배경 alpha 0 투명 PNG여야 한다.

예외:

- Main Menu logo는 언어별 text baked image를 사용할 수 있음
- Main Menu buttons는 text baked image를 active UI로 사용하지 않음

현재 등록된 asset folder:

```text
assets/splash/
assets/menu/
assets/mission_setup/
```

## 13. BoxFit 규칙

- Full-screen background: `BoxFit.cover`
- UI part image: 기본적으로 `BoxFit.contain`
- logo/title/image 영역: `BoxFit.contain` 또는 `FittedBox`로 clip/distortion 방지
- 안전하게 늘려도 되는 panel/frame asset만 예외적으로 stretch/fill 가능
- 현재 `assets/menu/menu_currency.png`: short/thick 표시를 위해 `BoxFit.fill`
