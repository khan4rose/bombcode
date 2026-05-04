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
| Mission Setup | 구현됨, polish 필요 | 난이도, 시도, 시간, 옵션 UI 구성 |
| 게임 로직 | 완료 | 정답 생성, 입력, 판정, 타이머, 성공/실패 처리 |
| Check Table | 구현됨 | 자동 표시와 수동 digit mark cycling 지원 |
| Records | 구현됨 | `shared_preferences` 기반 최근 기록과 통계 표시 |
| Tutorial / Settings | Placeholder | `AppText` 기반 한국어/영어 문구 표시 |
| Tests | 구현됨 | `judge_code_test.dart`, `game_controller_test.dart` |

## 4. 현재 구현된 기능

### 4.1 Flutter 기본 구조

- `lib/main.dart`에서 `BoomCodeApp` 실행
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
- 하단 utility button은 작게 조정되어 있으며 간격도 축소됨
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
- 일부 asset이 없을 경우 fallback widget 사용

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
- `15 min`
- `20 min`

LimitMode:

- 시간이 `OFF`이면 `LimitMode.attemptsOnly`
- 시간이 켜져 있으면 `LimitMode.attemptsAndTime`

현재 옵션 상태:

- Sound / Music / Vibration / Auto Check Table 컨트롤은 현재 UI-only
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

### 4.8 Records

- `lib/data/local_record_repository.dart`
- `shared_preferences` 기반 local storage 사용
- 최근 게임 기록 저장
- best attempts, fastest time, recent plays 표시

### 4.9 Tutorial / Settings Placeholder

- 현재 placeholder 성격의 화면
- `AppText`를 통해 기기 언어 기반 한국어/영어 문구 표시

### 4.10 Tests

현재 테스트 파일:

```text
test/judge_code_test.dart
test/game_controller_test.dart
```

## 5. 아직 구현되지 않은 기능

- 전체 화면의 최종 게임 UI art
- Game Screen용 최종 이미지 asset 및 정확한 폭탄 해체 UI layout
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
- Primary / Secondary / Bottom 버튼 텍스트 스타일이 분리되었다.
- Start Game과 Difficulty 사이의 수직 간격은 현재 없다.
- 하단 utility button은 최신 크기 기준에서 축소되었고 버튼 간 간격도 줄었다.
- Currency panel은 향후 Flutter text를 넣기 위한 blank frame이며 `BoxFit.fill`로 짧고 두껍게 표시한다.
- `AppBackground`가 공통 배경 widget으로 사용된다.
- Android Manifest에는 emulator 안정성을 위해 Impeller 비활성화 metadata가 있는 것으로 기존 문서에 기록되어 있다. 확인 필요.

## 7. 현재 이슈 / 주의사항

| 이슈 | 상태 | 메모 |
| --- | --- | --- |
| Main Menu 최종 visual QA | 확인 필요 | 여러 기기 크기에서 버튼 크기, 간격, touch target, green edge artifact 확인 필요 |
| Currency panel | 미구현 | amount text와 plus-button 동작이 아직 없음 |
| `mode_select_screen.dart` 파일 크기 | 개선 예정 | 별도 작업으로 widget 분리 필요 |
| Mission Setup asset 품질 | 확인 필요 | 단계적으로 생성되어 일부 PNG는 최종 style QA 필요 |
| Game Screen 최종 art | 미구현 | 최종 폭탄 해체 UI layout과 asset 필요 |
| Settings persistence | 미구현 | sound/music/vibration/language override 저장 없음 |
| 실제 audio/haptics | 미구현 | sound/music/vibration 컨트롤이 실제 기능과 연결되지 않음 |
| Shop/Ads | 미구현 | 결제, 광고, 광고 제거 시스템 없음 |
| 정식 localization | 미구현 | 현재는 단순 `AppText` helper 기반 |
| Release readiness | 미구현 | Android icon, launch assets, release config 필요 |

추가 주의사항:

- Home menu는 더 이상 문구가 박힌 버튼 PNG를 active UI로 사용하지 않는다.
- Main Menu 버튼은 공통 button frame PNG 위에 Flutter `Text`를 렌더링한다.
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

Emulator debug connection 문제가 발생하면 다음을 시도:

```bash
flutter clean
flutter pub get
flutter run
```

추가 조치:

- Android Emulator cold boot
- 새 emulator image 생성
- VS Code 터미널에서 `Ctrl + C` 종료 후 연결이 불안정하면 emulator 재시작

## 9. 다음 작업 요약

우선순위 기준 다음 후보:

1. Main Menu 최종 visual QA 및 불필요 asset 정리
2. Mission Setup asset visual QA
3. Mission Setup layout fine tuning
4. `mode_select_screen.dart` widget 분리
5. Game Screen asset 목록 정의
