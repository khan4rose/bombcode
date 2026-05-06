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
| Check Table | 구현됨 | 자동 표시와 수동 digit mark cycling 지원 |
| Records | 구현됨 | `shared_preferences` 기반 최근 기록과 통계 표시 |
| Tutorial / Settings | 구현됨, persistence 필요 | Settings에 Sound / Music / Vibration / Check Table UI-only controls 표시 |
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

## 7. 현재 이슈 / 주의사항

| 이슈 | 상태 | 메모 |
| --- | --- | --- |
| Main Menu 최종 visual QA | 확인 필요 | 여러 기기 크기에서 버튼 크기, 간격, touch target, green edge artifact 확인 필요 |
| Android viewport metrics 반복 / 자동 종료 | 관찰 중 | `WindowInsets changed`, `FlutterJNI: Sending viewport metrics`, `Lost connection to device`, `vendor.mesa.virtgpu.kumquat` 로그가 간헐적으로 발생. `adjustNothing` 적용 및 software rendering 실행에서 현재 정상 작동 확인됨 |
| Currency panel | 미구현 | amount text와 plus-button 동작이 아직 없음 |
| `mode_select_screen.dart` 파일 크기 | 개선 예정 | 별도 작업으로 widget 분리 필요 |
| Mission Setup asset 품질 | 관찰 중 | difficulty on/off button과 slider track은 갱신됨. 실제 화면에서 투명 가장자리, 내부 panel 보존, 텍스트 가독성 최종 QA 필요 |
| Game Screen 최종 art | 미구현 | 최종 폭탄 해체 UI layout과 asset 필요 |
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

Emulator debug connection 문제가 발생하면 다음을 시도:

```bash
flutter clean
flutter pub get
flutter run
flutter run --enable-software-rendering
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
4. Game Screen asset 목록 정의
