# PROJECT_STATUS

## 1. 프로젝트 개요

| 항목 | 내용 |
| --- | --- |
| 앱 이름 | BoomCode |
| Flutter 패키지명 | `bombcode` |
| 프로젝트 경로 | `D:\jtj\bombcode` |
| 우선 타깃 | Android first, Flutter cross-platform 구조 유지 |
| 프로젝트 성격 | Flutter 기반 오프라인 숫자 암호 추리 게임 |
| 게임 분위기 | 폭탄 해체, 해커, 암호 해독, 다크 SF 인더스트리얼 스타일 |
| 핵심 용어 | `Access`, `Trace`, 필요 시 `A/T` |

## 2. 앱 목적

BoomCode는 플레이어가 숨겨진 숫자 암호를 추리하고, 각 시도마다 `Access / Trace` 힌트를 받아 제한 조건 안에서 암호를 해제하는 게임이다.

- `Access`: 숫자와 위치가 모두 맞음
- `Trace`: 숫자는 맞지만 위치가 다름

## 3. 완료/구현 상태 요약

| 영역 | 상태 | 내용 |
| --- | --- | --- |
| Flutter 기본 구조 | 완료 | `lib/main.dart`, `lib/app.dart` 기준 앱 진입점과 테마 구성 |
| Splash | 완료 | 기기 언어에 따라 한국어/영어 splash 표시 후 Home 이동 |
| Home / Main Menu | 구현됨, 최종 미세 조정 반영 | 공통 배경, 로고/아이콘 PNG, 공통 버튼 프레임 이미지와 Flutter 렌더링 텍스트 조합 |
| 공통 배경 | 구현됨 | `AppBackground`와 `assets/menu/background.png` 사용 |
| Mission Setup | 구현됨, layout fine tuning 반영 | 난이도, 선택 요약, LIMIT MODE, START MISSION 구성 |
| 게임 로직 | 완료 | 정답 생성, 입력, 판정, 타이머, 성공/실패 처리 |
| Game Screen UI | bomb console final polish 진행 중 | `Bomb HUD -> Current Code -> Keypad -> History` 흐름, compact keypad, tactical history table, History 내 Check Table button 적용 |
| Check Table | 구현됨, asset-backed UI 1차 적용 | 자동 표시와 수동 digit mark cycling 지원 |
| Records | 구현됨 | `shared_preferences` 기반 최근 기록과 통계 표시 |
| Tutorial / Settings | 구현됨, persistence 필요 | Settings에 Sound / Music / Vibration / Check Table UI-only controls 표시 |
| Tests | 구현됨 | `judge_code_test.dart`, `game_controller_test.dart` |

## 4. 현재 구현된 기능

### 4.1 Flutter 기본 구조

- `lib/main.dart`에서 `BoomCodeApp` 실행
- MVP는 portrait-only이다. `lib/main.dart`에서 `SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])`를 적용하고, Android `MainActivity`에 `android:screenOrientation="portrait"`을 선언했다.
- `lib/app.dart`에서 앱 theme와 root screen 관리
- Flutter cross-platform 구조는 유지하되 Android를 우선 대상으로 개발 중

### 4.2 Splash 화면

- 파일: `lib/features/splash/splash_screen.dart`
- 기기 언어에 따라 splash image 자동 선택
  - 한국어: `assets/splash/main_kor.png`
  - 그 외: `assets/splash/main_eng.png`
- Splash 이후 `HomeScreen`으로 이동

### 4.3 Home / Main Menu 화면

- 파일: `lib/features/home/home_screen.dart`
- 공통 배경 이미지 사용: `assets/menu/background.png`
- `SafeArea` + `LayoutBuilder` 기반 반응형 구조 사용
- 기준 캔버스: `360 x 800 dp`
- 버튼 배경/프레임은 공통 PNG asset 사용
- 버튼 텍스트는 Flutter `Text`로 렌더링
- 버튼은 실제 Flutter touch target으로 구성됨
- 보이는 Exit 버튼은 제거된 상태
- Start Game과 Select Difficulty는 Mission Setup으로 이동
- Records, Settings, Help는 각 화면으로 이동
- Shop, Remove Ads는 현재 coming-soon `SnackBar` 표시
- `assets/menu/main_menu_eng.png`, `assets/menu/main_menu_kor.png`는 active UI가 아니라 visual reference

현재 Home 화면 레이아웃 상태:

- 로고는 크게 표시되고 화면 상단 쪽에 위치
- main button group은 넓고 얇은 느낌으로 조정됨
- Start Game과 Select Difficulty 사이의 세로 간격은 없음
- Records와 Settings는 아주 작은 responsive gap 유지
- 하단 utility button은 텍스트 없이 아이콘만 표시하는 보조 메뉴로 정리됨
- Currency panel은 아직 실제 금액 표시가 없는 blank frame
- Currency panel은 `BoxFit.fill`로 짧고 두껍게 표시됨

### 4.4 공통 배경

- 모든 주요 화면은 `assets/menu/background.png`를 공통 배경으로 사용해야 함
- 공통 widget: `lib/core/widgets/app_background.dart`
- 화면별 full background image는 사용자 요청 없이 추가하지 않음

### 4.5 Mission Setup 화면

- 파일: `lib/features/mode_select/mode_select_screen.dart`
- 단일 화면, non-scroll 구조
- `LayoutBuilder` 사용
- `assets/mission_setup/`의 PNG UI 부품 사용
- OPTIONS 섹션은 Mission Setup에서 제거되었고 Settings 화면으로 이동됨
- 일부 asset이 없을 경우 fallback widget 사용
- DIFFICULTY / LIMIT MODE section title은 공통 style을 사용한다.
- Difficulty button은 사용자가 제공한 on/off frame asset을 기반으로 하며, 텍스트는 Flutter `Text`로 렌더링한다.
- Difficulty button selected/off asset은 외부 배경이 투명 PNG이고, 프레임 내부 dark panel은 불투명 질감으로 유지한다.
- Attempts / Time slider는 단일 값 리스트 기준으로 현재값 badge, tick label, thumb 위치를 동기화한다.
- Start Mission 버튼은 key icon 없이 Flutter text만 중앙 정렬한다.
- Digits / Timer / Reward summary card는 아이콘과 텍스트를 키우고 card 배경 영역도 넓힌 최신 배치를 사용한다.

난이도 기본값:

| 난이도 | 코드 길이 | 기본 시도 |
| --- | ---: | ---: |
| Beginner | 2 | 20 |
| Normal | 3 | 12 |
| Expert | 4 | 7 |

시간 제한 옵션:

- `OFF`
- `5 min`
- `10 min`
- `20 min`

LimitMode:

- 시간이 `OFF`이면 `LimitMode.attemptsOnly`
- 시간이 켜져 있으면 `LimitMode.attemptsAndTime`

현재 옵션 상태:

- Sound / Music / Vibration / Check Table 컨트롤은 Settings 화면의 UI-only controls
- 설정값 영구 저장과 실제 sound/music/vibration 동작은 미구현

### 4.6 게임 로직

- 중복 없는 정답 숫자 생성
- 첫 자리 0 허용
- 중복 입력 차단
- `judgeCode()`가 `access`와 `trace` 반환
- `lib/features/game/game_controller.dart`에서 다음 기능 지원:
  - start
  - pause / resume
  - digit input
  - delete
  - submit
  - restart same config
  - one-second tick
  - attempt exhaustion
  - time expiration
  - success / failure status

### 4.7 Check Table

- 단순 케이스 자동 표시 지원
- Auto mode가 꺼져 있을 때 수동 digit mark cycling 지원
- Game Screen main 화면에서는 Check Table grid를 기본 표시하지 않는다.
- History panel 오른쪽 위 utility button으로 기존 `CheckTable`을 bottom sheet에 표시한다.
- Check Table entry button은 `assets/game/check_table_bulb_icon.png`를 원형 dark/metal frame 안에 표시하며, Flutter `CustomPainter` bulb는 asset load fallback으로 남아 있다.

### 4.8 Game Screen UI

- 파일: `lib/features/game/game_screen.dart`
- 위젯:
  - `lib/features/game/widgets/asset_frame.dart`
  - `lib/features/game/widgets/game_asset_paths.dart`
  - `lib/features/game/widgets/limit_status_bar.dart`
  - `lib/features/game/widgets/code_slots.dart`
  - `lib/features/game/widgets/number_keypad.dart`
  - `lib/features/game/widgets/guess_history_list.dart`
  - `lib/features/game/widgets/check_table.dart`
- 공통 배경은 `AppBackground`와 `assets/menu/background.png` 유지
- `pubspec.yaml`에 `assets/game/` 등록 추가
- `docs/GAME_SCREEN_REDESIGN_PLAN.md`에 bomb hero 중심 redesign 목표, required asset, stage rule, Check Table modal 구조, phase plan을 정리했다.
- 현재 적용된 bomb console 영역:
  - bomb hero: `bomb_hero_stable/caution/danger/critical.png`
  - hero 내부 Flutter Text overlay: `LEFT / TIME` label과 남은 횟수/시간 LED 숫자
  - current code: 얇은 Flutter frame 안에 `code_slot_empty/filled/selected.png` 슬롯 표시
  - number keypad: `keypad_button_idle/pressed/disabled.png`
  - keypad action: `keypad_delete_button.png`, `keypad_submit_button.png`, `keypad_submit_disabled.png`
  - recent history: `history_panel.png` 기반 compact tactical table
  - Check Table: History panel 오른쪽 위 utility button, bottom sheet 안에서 기존 `check_table_panel.png`, `digit_marker_*` 사용
  - result modal: `result_modal_success.png`, `result_modal_failure.png`, `modal_primary_button.png`, `modal_secondary_button.png`
- Task 3.2-E에서 bomb-centric redesign에 필요한 required asset 11개와 QA preview를 생성했다.
- Task 3.2-E 이후 `bomb_device_frame.png`와 bomb hero 4종을 실제 bomb-defusal device 느낌이 강하도록 visual rework했다.
- 사용자가 교체한 bomb hero 4종은 checkerboard background를 투명화하고, emulator/GPU 부담을 낮추기 위해 `720x405 RGBA`로 최소 보정했다.
- 신규 bomb hero 4종:
  - `bomb_hero_stable.png`
  - `bomb_hero_caution.png`
  - `bomb_hero_danger.png`
  - `bomb_hero_critical.png`
- 신규 action/modal 관련 asset:
  - `current_code_panel.png`
  - `check_table_open_button.png`
  - `keypad_delete_button.png`
  - `keypad_submit_button.png`
  - `keypad_submit_disabled.png`
  - `check_table_modal_panel.png`
  - `modal_close_button.png`
  - `main_play_required_assets_preview.png`
- 게임 로직 파일인 `game_controller.dart`, `judge_code.dart`, `game_config.dart`는 수정하지 않았다.
- `bomb_device_frame.png`, 상단 status panel, READY panel, pause button, 별도 ACCESS/TRACE 요약 영역은 main gameplay 화면에서 더 이상 사용하지 않는다.
- 현재 화면 흐름은 `Bomb HUD -> Current Code -> Keypad -> History`이다.
- Bomb HUD는 난이도 텍스트 없이 `LEFT / TIME`만 표시하며, stage별 색상(stable/caution/danger/critical)에 label과 숫자 색상이 동기화된다.
- Attempts는 2자리 느낌(`06 /7`, `07 /20`)으로 표시하고, timer OFF는 `--:--`로 표시한다.
- History는 최신 기록이 위에 오며, `# / CODE / RESULT` table header와 row를 같은 column structure와 padding으로 맞춘다.
- History result는 `A` green(`#33D17A`), `T` blue(`#4DA3FF`)로 분리 표시한다.
- History empty state는 큰 안내 문구 대신 compact `STANDBY` 표시를 사용한다.
- History panel 내부는 `history_panel.png`의 outer frame을 유지하되, baked-in inner frame 위에 code-side dark tactical surface를 덮어 single panel처럼 보이게 한다.
- History surface에는 아주 낮은 alpha의 Flutter `CustomPainter` brushed line/speck texture가 적용되어 flat black box 느낌을 줄인다.
- Keypad는 Current Code 중심축에 맞춘 compact width를 사용하고 button touch target은 48dp 수준을 유지한다.
- Bomb hero 흰색 matte 문제는 `bomb_hero_*` asset의 near-white matte를 dark matte로 보정하고, Flutter side에서 약한 dark backing을 추가해 완화했다.
- `bomb_hero_critical.png`는 canvas size `720x405`를 유지하면서 internal content를 소폭 줄여 stable/caution/danger와 optical size를 더 맞췄다.
- 현재 상태는 latest Game Screen polish 적용 후 `dart format`, `flutter analyze`, `flutter test`, 실제 360x800 overflow/touch-target QA가 필요하다.

### 4.9 Records

- `lib/data/local_record_repository.dart`
- `shared_preferences` 기반 local storage 사용
- 최근 게임 기록 저장
- best attempts, fastest time, recent plays 표시

### 4.10 Tutorial / Settings Placeholder

- 현재 placeholder 성격의 화면
- `AppText`를 통해 기기 언어 기반 한국어/영어 문구 표시

### 4.11 Tests

현재 테스트 파일:

```text
test/judge_code_test.dart
test/game_controller_test.dart
```

## 5. 아직 구현되지 않은 기능

- Game Screen 최종 live responsive QA와 일부 미세 polish
- 최근 responsive 배치 변경 이후 Main Menu 최종 visual QA
- Currency panel 안의 Flutter-rendered currency amount
- Currency panel 주변 plus-button 동작
- 설정값 영구 저장:
  - sound volume
  - music volume
  - vibration
  - language override
- 실제 sound / music / vibration 동작
- Shop / Remove Ads / Payment / Ads 시스템
- Flutter ARB 또는 localization delegates 기반의 정식 localization 시스템
- Production-grade Android app icon 및 launch assets
- 다양한 기기 크기와 font scale에 대한 완전 QA
- 최종 release build configuration

## 6. 최근 변경 사항

- Home 화면이 하나의 full menu image 방식이 아니라 공통 배경과 독립 PNG UI part 조합 방식으로 구성되어 있다.
- Home menu button asset이 언어별 완성형 이미지로 재생성되었다.
- Start Game은 red primary action, 나머지 주요 버튼은 dark secondary style이다.
- Primary / Secondary 버튼 텍스트 스타일이 분리되었다.
- Bottom utility button은 화면 텍스트 없이 icon-only asset과 Semantics label을 사용한다.
- Start Game과 Difficulty 사이의 수직 간격은 현재 없다.
- 하단 utility button은 icon-only 구조로 정리되었고 버튼 간 간격과 하단 여백이 조정되었다.
- Currency panel은 향후 Flutter text를 넣기 위한 blank frame이며 `BoxFit.fill`로 짧고 두껍게 표시한다.
- `AppBackground`가 공통 배경 widget으로 사용된다.
- Mission Setup은 2026-05-05에 OPTIONS 제거, back icon 위치, difficulty button 내부 배치, LIMIT MODE 높이, Attempts/Time slider width를 responsive 기준으로 미세 조정했다.
- Mission Setup 후속 조정으로 `slider_track.png`의 과도한 투명 여백을 제거하고 Attempts/Time slider track이 더 길고 선명하게 보이도록 수정했다.
- Mission Setup의 DIFFICULTY / LIMIT MODE title style을 통일했고, Time summary card를 실제 time value(`OFF`, `05:00`, `10:00`, `20:00`)로 표시하도록 수정했다.
- Mission Setup slider는 Attempts `[7, 10, 13, 15, 20]`, Time `[0, 5, 10, 20]` 리스트 기준으로 badge/tick/thumb 위치를 동기화한다.
- Mission Setup difficulty on/off button asset 6개는 사용자가 제공한 `D:\download\New_button.png`, `D:\download\New_off.png`를 기반으로 `360x112` transparent PNG로 재생성했다.
- Mission Setup difficulty 영역, LIMIT MODE 영역, Start Mission 버튼 위치/간격/두께를 사용자 피드백에 따라 responsive 범위 안에서 미세 조정했다.
- Mission Setup Digits / Timer / Reward summary card는 영역 높이, panel padding, icon size, text size를 키워 더 잘 보이도록 조정했다.
- Start Mission 버튼 앞 key icon은 제거했고, Flutter text를 버튼 중앙에 정렬했다.
- Android Manifest에는 emulator 안정성을 위해 Impeller 비활성화 metadata가 있다.
- Android emulator viewport/insets 반복 대응으로 `android:windowSoftInputMode`를 `adjustResize`에서 `adjustNothing`으로 변경했고, 이후 사용자가 현재 정상 작동을 확인했다.
- Android emulator에서 `vendor.mesa.virtgpu.kumquat` / `Lost connection to device`가 재발했으나 `flutter run --enable-software-rendering`으로 정상 작동을 확인했다. emulator GPU/virtgpu 이슈 가능성이 높다.
- `docs/GAME_SCREEN_ASSET_LIST.md`를 생성/보완해 Game Screen asset 제작 기준을 정리했다.
- Game Screen asset list에는 asset size rule, Required/Optional 기준, visual style detail, layout priority, check table display rule, Task 3.2 단계별 asset generation order가 포함되어 있다.
- Task 3.2-A/B/C/D Game Screen asset generation을 완료했다.
- Task 3.2-A core input asset은 사용자가 제공한 reference style 기준으로 재작업했고, `bomb_device_frame.png`, `code_slot_*`, `keypad_button_*` 7개가 승인되었다.
- Task 3.2-B status/history asset 5개를 생성하고 visual polish를 통해 compact 최종 크기로 조정했다.
- Task 3.2-C check table/memo asset 6개를 생성했다.
- Task 3.2-D modal/result asset 5개를 생성하고 visual polish를 통해 success/failure/pause 상태 차이와 primary/secondary button 위계를 강화했다.
- Task 3.3-A Game Screen asset-backed layout 1차 적용을 진행했다.
- `pubspec.yaml`에 `assets/game/` 등록을 추가했다.
- `lib/features/game/widgets/game_asset_paths.dart`, `lib/features/game/widgets/asset_frame.dart`를 추가했다.
- Game Screen main gameplay view에 header, code slots, keypad, latest Access/Trace, recent history, check table, pause/result modal asset을 연결했다.
- `game_controller.dart`, `judge_code.dart`, `game_config.dart`는 변경하지 않았다.
- `docs/GAME_SCREEN_REDESIGN_PLAN.md`를 생성하고 사용자가 승인한 bomb-centric main play redesign 방향을 정리했다.
- redesign plan에는 bomb hero 중심 화면 구조, stable/caution/danger/critical stage rule, Check Table button/modal 구조, required asset 11개, optional asset 목록, implementation phase plan, coding protection rule을 포함했다.
- Task 3.2-E Main Play Redesign Required Assets generation을 완료했다.
- Task 3.2-E 생성 asset: `bomb_hero_stable.png`, `bomb_hero_caution.png`, `bomb_hero_danger.png`, `bomb_hero_critical.png`, `current_code_panel.png`, `check_table_open_button.png`, `keypad_delete_button.png`, `keypad_submit_button.png`, `keypad_submit_disabled.png`, `check_table_modal_panel.png`, `modal_close_button.png`, `main_play_required_assets_preview.png`.
- 이후 사용자의 visual rework 지시에 따라 `bomb_device_frame.png`와 bomb hero 4종을 단순 panel/frame 느낌에서 stylized but believable bomb-defusal device 느낌으로 재작업했다.
- visual rework에서는 side housing, cables, connectors, bolts, warning lights, recessed display areas, stage별 glow/meter 차이를 강화했다.
- bomb hero 4종은 사용자가 교체한 이미지를 기반으로 `720x405 RGBA`, 동일 transparent canvas와 동일 device alignment를 유지한다.
- `bomb_device_frame.png`는 `720x260 RGBA`이며 bomb hero의 하위 입력 장치 모듈처럼 보이도록 재작업했다.
- `main_play_required_assets_preview.png`는 visual rework 결과를 비교 확인할 수 있도록 갱신했다.
- 사용자가 `dart format` 실행 시 `pubspec.yaml`을 format 대상에 포함해 YAML parse error가 출력되었으나 Dart 파일 format은 진행되었다. 이후 format 명령에서는 `pubspec.yaml`을 제외해야 한다.
- `flutter run` 중 Dart Dev Service 연결 실패(`Connection closed before full header was received`)가 보고되었다. 앱 로딩 자체보다는 emulator/debug service 연결 문제 가능성이 높으며 `flutter run --enable-software-rendering` 재확인이 권장된다.
- Task 3.3-C Main Play Screen Bomb-Centric Layout을 적용했다. 상단 status panel, READY panel, pause button, main Check Table bar를 제거하고 bomb hero overlay, compact current code, compact scrollable history, 우상단 Check Table icon button, 전용 delete/submit keypad asset을 연결했다.
- `flutter analyze`에서 `GameConfig.maxAttempts` nullable 사용 오류가 보고되어 `game_screen.dart`의 UI stage 계산에서 null/0 check를 추가했다.
- 이후 Game Screen final polish를 여러 차례 적용했다.
- Bomb HUD 내부 난이도 표시를 제거하고 `LEFT / TIME` 2분할 LED HUD로 변경했다.
- Bomb HUD label과 숫자는 stage color와 동기화했고, 중앙 divider는 제거했다.
- Current Code는 큰 panel background 대신 얇은 Flutter frame과 slot 중심 구조로 경량화했다.
- Main layout은 `Bomb HUD -> Current Code -> Keypad -> History` 흐름으로 변경했다.
- Keypad는 Current Code와 중심축을 맞추는 compact width로 조정했고, row gap/padding을 줄여 overflow를 방지했다.
- History는 card list가 아니라 tactical deduction table처럼 보이도록 row frame/separator를 약화하거나 제거하고 typography를 강화했다.
- History header와 row는 동일 column structure 및 padding을 사용하도록 정리했다.
- History inner frame 중복감은 `history_panel.png` 위의 dark surface overlay로 약화했고, header/body가 하나의 tactical panel surface처럼 보이도록 subtle texture를 추가했다.
- Check Table button은 History panel 오른쪽 위로 이동했고, bottom sheet open 동작은 유지했다.
- Check Table entry icon은 사용자 교체 bulb 이미지를 프로그램용 transparent PNG로 정리한 뒤 circular frame 안에 표시한다.
- `bomb_hero_critical.png`는 다른 bomb hero state보다 크게 보이는 문제를 줄이기 위해 canvas는 유지하고 internal content만 소폭 축소했다.
- 앱 전체는 MVP 기준 portrait-only로 고정되어 landscape overflow 전환 자체를 막는다.
- `assets/game/bomb_hero_stable/caution/danger/critical.png`의 near-white matte를 dark matte 계열로 보정했고 `.bak_matte` 백업이 생성되었다.
- Latest note: 사용자가 360x800 스타일 실행 화면에서 overflow, History header alignment, Check Table icon 위치, critical bomb size를 확인하며 여러 차례 미세 조정을 진행했다. 가장 최근 변경은 History single-surface polish, header/body alignment, circular bulb icon frame, portrait-only lock, critical bomb optical size 축소이며 format/analyze/live QA가 필요하다.
- `flutter run`/`assembleRelease`에서 DDS WebSocket 연결 실패와 Kotlin incremental storage close stack이 반복 보고되었다. `--disable-dds`, `--enable-software-rendering`, Gradle/Kotlin cache cleanup, `kotlin.incremental=false` 설정이 권장되며 실제 원인 확인에는 첫 `FAILURE` / `What went wrong` / `Caused by` 로그가 필요하다.

## 7. 현재 이슈 / 주의사항

| 이슈 | 상태 | 메모 |
| --- | --- | --- |
| Main Menu 최종 visual QA | 확인 필요 | 여러 기기 크기에서 버튼 크기, 간격, touch target, green edge artifact 확인 필요 |
| Android viewport metrics / DDS 연결 실패 | 진행 중 | `WindowInsets changed`, `FlutterJNI: Sending viewport metrics`, `Lost connection to device`, DDS WebSocket close가 반복 보고됨. `--disable-dds`, `--enable-software-rendering`, emulator cold boot/새 image 확인 필요 |
| Gradle Kotlin incremental storage 에러 | 진행 중 | `org.jetbrains.kotlin.incremental.storage.*` close stack이 debug/release build 중 반복됨. Gradle/Kotlin cache cleanup과 `kotlin.incremental=false` 적용 필요 |
| Currency panel | 미구현 | amount text와 plus-button 동작이 아직 없음 |
| `mode_select_screen.dart` 파일 크기 | 개선 예정 | 별도 작업으로 widget 분리 필요 |
| Mission Setup asset 품질 | 관찰 중 | difficulty on/off button과 slider track은 갱신됨. 실제 화면에서 투명 가장자리, 내부 panel 보존, 텍스트 가독성 최종 QA 필요 |
| Game Screen bomb console layout | polish 진행 중, 최신 변경 검증 필요 | `Bomb HUD -> Current Code -> Keypad -> History` 흐름, compact keypad, tactical history table, History 내 Check Table button 적용. 최신 미세 조정 후 format/analyze/live QA 필요 |
| Settings persistence | 미구현 | sound/music/vibration/language override 저장 없음 |
| 실제 audio/haptics | 미구현 | sound/music/vibration 컨트롤이 실제 기능과 연결되지 않음 |
| Shop/Ads | 미구현 | 결제, 광고, 광고 제거 시스템 없음 |
| 정식 localization | 미구현 | 현재는 단순 `AppText` helper 기반 |
| Release readiness | 미구현 | Android icon, launch assets, release config 필요 |

추가 주의사항:

- Home menu는 더 이상 문구가 박힌 버튼 PNG를 active UI로 사용하지 않는다.
- Main Menu 주요 버튼은 공통 button frame PNG 위에 Flutter `Text`를 렌더링한다.
- 하단 utility button은 화면 텍스트를 렌더링하지 않고 icon-only PNG를 사용한다.
- 하단 utility icon은 `196x196` 투명 PNG로 정리되었고, 터치 영역과 보이는 icon size가 분리되어 있다.
- 하단 utility icon size는 화면 width 기반 `(width * 0.17).clamp(62.0, 76.0)` 규칙을 사용한다.
- Android emulator에서 viewport metrics 반복과 device connection lost가 재발하면 logcat에서 `FATAL EXCEPTION`, `AndroidRuntime`, `SIG`, `WindowInsets`, `FlutterJNI`, `com.example.bombcode` 기준으로 확인한다.
- emulator GPU/virtgpu 로그와 함께 끊기면 `flutter run --enable-software-rendering`으로 우선 재확인한다.
- 기존 언어별 완성형 button PNG는 보존하되 현재 화면에서는 사용하지 않는다.
- Home menu asset은 반복 생성/수정되었으므로 chroma-key/green edge artifact 확인 필요.
- `assets/menu/main_menu_eng.png`, `assets/menu/main_menu_kor.png`는 active UI가 아니라 visual reference로 유지한다.
- 오래된 실험용 menu asset이 남아 있을 수 있다. 코드 참조 여부 확인 전 삭제 금지.
- 프로젝트는 화면 단위로 점진 개발 중이므로 대규모 rewrite 금지.

## 8. 실행 / 점검 명령어

사용자가 직접 실행하는 기본 명령어:

```bash
flutter pub get
dart format .
flutter analyze
flutter test
flutter run
```

Game Screen 3.3-A 수정 파일만 format할 때는 YAML을 제외한다:

```bash
dart format lib/features/game/game_screen.dart lib/features/game/widgets/asset_frame.dart lib/features/game/widgets/game_asset_paths.dart lib/features/game/widgets/code_slots.dart lib/features/game/widgets/number_keypad.dart lib/features/game/widgets/limit_status_bar.dart lib/features/game/widgets/guess_history_list.dart lib/features/game/widgets/check_table.dart
```

Emulator debug connection 문제가 발생하면 다음을 시도:

```bash
flutter clean
flutter pub get
flutter run
flutter run --enable-software-rendering
flutter run --disable-dds --enable-software-rendering
```

Gradle Kotlin incremental storage 에러가 반복되면 `android/gradle.properties`에 다음 안정화 옵션을 추가한다:

```properties
kotlin.incremental=false
kotlin.incremental.useClasspathSnapshot=false
org.gradle.caching=false
```

추가 조치:

- Android Emulator cold boot
- 새 emulator image 생성
- VS Code 터미널에서 `Ctrl + C` 종료 후 연결이 불안정하면 emulator 재시작

## 9. 다음 작업 요약

우선순위 기준 다음 후보:

1. Mission Setup 최종 visual QA
2. Main Menu 최종 visual QA 및 불필요 asset 정리
3. `mode_select_screen.dart` widget 분리
4. Task 1.0 Android/DDS/Gradle Kotlin build 안정화
5. Task 3.3-E Game Screen latest polish 검증 및 마감 QA
