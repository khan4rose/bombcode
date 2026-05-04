# ARCHITECTURE

이 문서는 BoomCode Flutter 프로젝트의 현재 구조, 계층별 책임, 데이터 흐름, 향후 확장 방향을 정리한다. 구조 변경, 파일 생성, 리팩터 작업 전에 먼저 확인한다.

## 1. 루트 구조

```text
bombcode/
  android/
  assets/
  ios/
  lib/
  linux/
  macos/
  test/
  web/
  windows/
  pubspec.yaml
```

Flutter 크로스플랫폼 기본 구조를 유지하지만, 현재 우선 타깃은 Android다.

## 2. 현재 lib 구조

```text
lib/
  main.dart
  app.dart
  core/
    constants/
      app_colors.dart
      app_strings.dart
      app_text.dart
    utils/
      code_generator.dart
      judge_code.dart
      responsive.dart
      timer_formatter.dart
    widgets/
      app_background.dart
  data/
    record_repository.dart
    local_record_repository.dart
  domain/
    enums/
      difficulty.dart
      limit_mode.dart
      game_status.dart
      game_over_reason.dart
      digit_mark.dart
    models/
      game_config.dart
      game_record.dart
      guess_record.dart
      judge_result.dart
  features/
    splash/
      splash_screen.dart
    home/
      home_screen.dart
    mode_select/
      mode_select_screen.dart
    game/
      game_controller.dart
      game_screen.dart
      widgets/
        check_table.dart
        code_slots.dart
        guess_history_list.dart
        limit_status_bar.dart
        number_keypad.dart
    records/
      records_screen.dart
    settings/
      settings_screen.dart
    tutorial/
      tutorial_screen.dart
```

## 3. Entry / App Layer

| 파일 | 역할 |
| --- | --- |
| `lib/main.dart` | Flutter 앱 시작, `BoomCodeApp` 실행 |
| `lib/app.dart` | 앱 theme, root screen, 전체 앱 기본 구조 관리 |

현재 앱 진입과 화면 라우팅은 단순한 Flutter 기본 구조를 사용한다. 전역 라우터 패키지는 사용하지 않는다.

## 4. Core Layer

공통 상수, 유틸리티, 재사용 widget을 둔다. 특정 feature에만 종속되는 UI나 상태는 `core`로 올리지 않는다.

### `lib/core/constants/`

| 파일 | 역할 |
| --- | --- |
| `app_colors.dart` | 앱 색상 상수 |
| `app_strings.dart` | 공통 문자열 또는 기존 문자열 상수 |
| `app_text.dart` | 기기 locale 기반 한국어/영어 text helper |

주의:

- 현재 localization은 정식 ARB 구조가 아니라 `AppText` helper 기반이다.
- 향후 `AppText` 구조 개선 또는 Flutter localization 전환 예정이다.

### `lib/core/utils/`

| 파일 | 역할 |
| --- | --- |
| `code_generator.dart` | 중복 없는 정답 숫자 생성 |
| `judge_code.dart` | `Access / Trace` 판정 로직 |
| `responsive.dart` | 반응형 scale helper |
| `timer_formatter.dart` | 시간 표시 formatting |

보호 규칙:

- `judge_code.dart`는 판정 로직 수정 task가 아니면 건드리지 않는다.
- UI-only 작업에서 `judge_code.dart`, `code_generator.dart`를 수정하지 않는다.

### `lib/core/widgets/`

| 파일 | 역할 |
| --- | --- |
| `app_background.dart` | 공통 배경 wrapper |

공통 배경 경로:

```text
assets/menu/background.png
```

## 5. Domain Layer

게임 규칙에 필요한 enum과 model을 둔다. Flutter UI 의존성을 넣지 않는다.

### `lib/domain/enums/`

- `difficulty.dart`
- `limit_mode.dart`
- `game_status.dart`
- `game_over_reason.dart`
- `digit_mark.dart`

### `lib/domain/models/`

| 파일 | 역할 |
| --- | --- |
| `game_config.dart` | 난이도 기본값과 game setup config |
| `game_record.dart` | 게임 기록 model |
| `guess_record.dart` | 각 guess 기록 model |
| `judge_result.dart` | `Access / Trace` 판정 결과 model |

보호 규칙:

- `game_config.dart`는 난이도/제한 규칙 변경 task가 아니면 수정하지 않는다.
- `GameRecord` schema는 migration plan 없이 변경하지 않는다.

## 6. Data Layer

기록 저장소 관련 코드를 둔다.

| 파일 | 역할 |
| --- | --- |
| `record_repository.dart` | 기록 repository abstraction |
| `local_record_repository.dart` | `shared_preferences` 기반 local record 저장 구현 |

현재 상태:

- 게임 기록은 local storage에 저장된다.
- settings persistence는 아직 미구현이다.

향후 예정:

- settings repository 추가
- sound/music/vibration/auto check table 기본값 저장

## 7. Features Layer

화면 단위 feature 구조를 따른다.

### 7.1 Splash

```text
lib/features/splash/splash_screen.dart
```

역할:

- 기기 언어에 따라 splash image 선택
- 일정 시간 뒤 `HomeScreen`으로 이동

사용 asset:

```text
assets/splash/main_eng.png
assets/splash/main_kor.png
```

### 7.2 Home / Main Menu

```text
lib/features/home/home_screen.dart
```

역할:

- 메인 메뉴 화면
- 언어별 완성 PNG button 표시
- Mission Setup, Records, Settings, Help로 이동
- Shop/Remove Ads는 현재 coming-soon `SnackBar`

주요 asset:

```text
assets/menu/background.png
assets/menu/main_menu_eng.png
assets/menu/main_menu_kor.png
assets/menu/menu_logo_eng.png
assets/menu/menu_logo_kor.png
assets/menu/menu_currency.png
assets/menu/menu_button_primary_frame.png
assets/menu/menu_button_secondary_frame.png
assets/menu/menu_shop_icon.png
assets/menu/menu_no_ads_icon.png
assets/menu/menu_help_icon.png

보존 asset:

assets/menu/menu_start_eng.png
assets/menu/menu_start_kor.png
assets/menu/menu_difficulty_eng.png
assets/menu/menu_difficulty_kor.png
assets/menu/menu_records_eng.png
assets/menu/menu_records_kor.png
assets/menu/menu_settings_eng.png
assets/menu/menu_settings_kor.png
assets/menu/menu_shop_eng.png
assets/menu/menu_shop_kor.png
assets/menu/menu_remove_ads_eng.png
assets/menu/menu_remove_ads_kor.png
assets/menu/menu_help_eng.png
assets/menu/menu_help_kor.png
```

주의:

- `main_menu_eng.png`, `main_menu_kor.png`는 visual reference다.
- active UI는 공통 배경 위에 개별 image part를 조합한다.
- visible exit button은 제거된 상태이며 다시 추가하지 않는다.
- 통화 패널은 현재 빈 프레임이며 금액/plus 동작은 미구현이다.

### 7.3 Mission Setup / Mode Select

```text
lib/features/mode_select/mode_select_screen.dart
```

역할:

- 난이도 선택
- digit count, attempts, timer 설정
- sound/music/vibration/auto check table UI 표시
- `GameConfig` 생성 후 game screen으로 이동

현재 상태:

- 큰 단일 파일이다.
- 향후 `lib/features/mode_select/widgets/`로 widget 분리 예정이다.

중요 규칙:

- 사용자 요청 전까지 non-scroll 유지
- `LayoutBuilder` 유지
- 공통 배경 유지
- visual-only task에서는 game logic 변경 금지

Mission Setup asset 위치:

```text
assets/mission_setup/
```

### 7.4 Game

```text
lib/features/game/game_controller.dart
lib/features/game/game_screen.dart
lib/features/game/widgets/
```

역할:

- `game_controller.dart`: 게임 상태와 규칙 관리
- `game_screen.dart`: gameplay UI
- `widgets/`: gameplay 화면 하위 UI

현재 widget:

```text
check_table.dart
code_slots.dart
guess_history_list.dart
limit_status_bar.dart
number_keypad.dart
```

보호 규칙:

- visual-only task에서는 `game_controller.dart`를 수정하지 않는다.
- `judge_code.dart`는 Access/Trace 판정 로직 수정 task에서만 수정한다.

향후 예정:

- gameplay UI asset 목록 정의
- `assets/game/` 생성
- final bomb-defusal game screen design 적용

### 7.5 Records

```text
lib/features/records/records_screen.dart
```

역할:

- 최근 게임 기록 표시
- best attempts, fastest time, recent plays 표시

주의:

- `GameRecord` schema는 migration plan 없이 변경하지 않는다.

### 7.6 Settings

```text
lib/features/settings/settings_screen.dart
```

현재 상태:

- placeholder 성격
- sound/music/vibration persistence 미구현

향후 예정:

- settings repository 추가
- `shared_preferences` 기반 저장
- Mission Setup과 연동

### 7.7 Tutorial / Help

```text
lib/features/tutorial/tutorial_screen.dart
```

현재 상태:

- device-language aware placeholder/help screen

## 8. 제한 모드 구조

난이도 기본값:

```text
Beginner: 2 digits, 20 attempts
Normal: 3 digits, 12 attempts
Expert: 4 digits, 7 attempts
```

시간 제한 옵션:

```text
OFF / 5 min / 10 min / 15 min / 20 min
```

`LimitMode` 규칙:

```text
If time is OFF:
  LimitMode.attemptsOnly

If time is enabled:
  LimitMode.attemptsAndTime
```

확인 필요:

- `GameConfig.defaults()` 내부 timeLimit 기본값과 Mission Setup의 time selector 기본값이 문서 의도와 완전히 일치하는지 확인 필요.

## 9. 게임 데이터 흐름

기본 흐름:

```text
SplashScreen
  -> HomeScreen
  -> Mission Setup / Mode Select
  -> GameConfig 생성
  -> GameScreen
  -> GameController
  -> judgeCode / codeGenerator
  -> Game result
  -> LocalRecordRepository
  -> RecordsScreen
```

입력/판정 흐름:

```text
NumberKeypad input
  -> GameController digit input
  -> submit
  -> judgeCode(answer, guess)
  -> JudgeResult(access, trace)
  -> GuessRecord 저장
  -> UI update
```

기록 저장 흐름:

```text
Game finished
  -> GameRecord 생성
  -> RecordRepository
  -> LocalRecordRepository(shared_preferences)
  -> RecordsScreen 표시
```

현재 상태 관리:

- 별도 외부 state management 패키지 없이 Flutter 기본 구조를 사용한다.
- `GameController`는 `ChangeNotifier`를 상속한다.
- 게임 화면은 controller 상태를 구독해 UI를 갱신한다. 구체 구독 방식은 `game_screen.dart` 확인 필요.
- 미션 설정 화면은 `StatefulWidget` 내부 state로 난이도, 시도, 시간, 옵션 값을 관리한다.

## 10. Assets 구조

현재 asset folder:

```text
assets/
  splash/
  menu/
  mission_setup/
```

현재 `pubspec.yaml`에 등록된 assets:

```yaml
assets:
  - assets/splash/
  - assets/menu/
  - assets/mission_setup/
```

향후 예정:

```text
assets/game/
```

Asset 관리 규칙:

- screen background는 공통 배경을 사용한다.
- screen-specific asset은 UI part 중심으로 둔다.
- 사용자 요청 없이 기존 asset 삭제 금지
- 사용하지 않는 실험 asset은 코드 참조 확인 후 정리한다.
- 새 asset folder를 추가하면 `pubspec.yaml` 등록 필요 여부를 확인한다.

## 11. 테스트 구조

현재 test:

```text
test/
  judge_code_test.dart
  game_controller_test.dart
```

원칙:

- 판정 로직 수정 시 `judge_code_test.dart` 확인
- controller 수정 시 `game_controller_test.dart` 확인
- visual-only task에서는 test logic을 건드리지 않는다.
- UI-only 문서/에셋 정리 작업에서는 테스트 실행이 필수는 아니지만, 코드 수정이 들어가면 analyze/test 확인을 권장한다.

## 12. 향후 구조 개선 방향

우선순위 높은 구조 개선:

1. `mode_select_screen.dart` widget 분리
2. Game Screen final UI 적용 후 gameplay widgets 정리
3. Settings persistence 추가 및 repository 구조 도입
4. Localization을 `AppText` helper에서 정식 구조로 개선
5. Release readiness 단계에서 Android metadata/icon/launch assets 정리

## 13. 구조 변경 시 주의사항

- 한 번에 대형 refactor를 하지 않는다.
- feature 단위로 작게 나눈다.
- logic, UI, asset 변경을 한 task에 섞지 않는다.
- 기존 routing과 `GameConfig` 흐름을 깨지 않는다.
- 화면 구조 변경 전 `docs/PROJECT_STATUS.md`와 `docs/NEXT_TASKS.md`를 확인한다.
- 구조 변경 후 문서의 실제 구조 설명이 달라지면 이 문서를 업데이트한다.
