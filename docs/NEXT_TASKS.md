# NEXT_TASKS

이 문서는 앞으로 진행할 작업을 Codex가 작은 단위로 처리할 수 있도록 나눈 작업 목록이다. 각 작업은 가능하면 별도 Codex chat/task에서 진행한다.

## 작업 원칙

- 한 번에 하나의 task group만 처리한다.
- 작업 전 관련 문서를 먼저 확인한다.
- 작업 전 대상 파일의 현재 내용을 읽는다.
- 관련 없는 파일은 수정하지 않는다.
- user-created asset은 보존한다.
- generated asset은 사용자 요청 없이 삭제하지 않는다.
- 작업 완료 후 변경 파일, 변경 내용, 사용자가 실행할 명령어를 보고한다.

---

## Priority 1. 현재 빌드 안정화

### Task 1.0 Android viewport metrics 반복 / 자동 종료 원인 확인

상태: WATCH

목표:

- Android Emulator 실행 중 `WindowInsets changed`, `FlutterJNI: Sending viewport metrics`, `Lost connection to device`가 반복되거나 앱이 자동 종료되는 원인을 확인한다.

현재 메모:

- Home 화면 하단 icon-only 버튼 전환 이후 emulator에서 viewport metrics 반복과 device connection lost가 보고되었다.
- `SafeArea(bottom: false)`와 `MediaQuery.removePadding(removeBottom: true)`를 Home 화면에 적용해 보았으나 해결되지 않아 롤백했다.
- 하단 icon asset은 `196x196` 투명 PNG이며, 코드에서는 터치 영역과 보이는 icon size를 분리했다.
- 2026-05-05: `android:windowSoftInputMode`를 `adjustResize`에서 `adjustNothing`으로 변경했다. 이후 사용자가 현재 정상 작동을 확인했다.
- 재발 시 logcat에서 `FATAL EXCEPTION`, `AndroidRuntime`, `SIG`, `WindowInsets`, `FlutterJNI`, `com.example.bombcode` 기준으로 다시 확인한다.

작업 체크리스트:

- [ ] 사용자가 실행한 `flutter analyze` 결과 확인
- [ ] `flutter clean`, `flutter pub get`, `flutter run` 재실행 결과 확인
- [ ] 종료가 반복되면 `flutter run -v` 또는 Android logcat에서 `FATAL EXCEPTION`, `ANR`, `WindowInsets`, `MainActivity`, `FlutterJNI` 로그 확인
- [ ] Flutter 예외인지 Android window/insets 문제인지 구분
- [ ] Android 쪽 edge-to-edge, navigation bar, manifest/theme 설정 확인
- [ ] Home 화면 layout 계산이 viewport/insets 변화에 민감한지 재검토
- [ ] 필요한 경우에만 `android/` 또는 Home UI의 최소 수정 적용

수정 금지:

- 게임 판정 로직
- 난이도 로직
- 광고/코인/상점 로직
- 저장 로직
- 관련 없는 feature screen

예상 점검 명령어:

```bash
dart format .
flutter analyze
flutter clean
flutter pub get
flutter run
flutter run -v
```

### Task 1.1 Analyze/Test 이슈 수정

상태: TODO

목표:

- `flutter analyze`와 `flutter test`에서 보고된 문제만 최소 수정한다.

작업 체크리스트:

- [ ] 사용자가 제공한 정확한 에러/경고 로그를 읽는다.
- [ ] analyzer/test failure에 언급된 파일만 수정한다.
- [ ] 수정 범위를 최소화한다.
- [ ] 필요 시 사용자에게 아래 점검 명령 실행을 안내한다.

예상 점검 명령어:

```bash
dart format .
flutter analyze
flutter test
```

수정 금지:

- `assets/`
- `android/`
- 관련 없는 feature screen

---

## Priority 2. Main Menu / Mission Setup 화면 다듬기

### Task 2.0 Main Menu Visual QA 및 Asset Cleanup

상태: DONE

목표:

- 공통 버튼 프레임 PNG와 Flutter 렌더링 텍스트를 사용한 현재 Main Menu를 최종 점검한다.
- 2026-05-04 작업에서 active Main Menu는 공통 버튼 프레임 PNG와 Flutter 렌더링 텍스트 구조로 정리되었다.

검토 대상:

```text
lib/features/home/home_screen.dart
assets/menu/menu_*_eng.png
assets/menu/menu_*_kor.png
assets/menu/menu_button_primary_frame.png
assets/menu/menu_button_secondary_frame.png
assets/menu/menu_shop_icon.png
assets/menu/menu_no_ads_icon.png
assets/menu/menu_help_icon.png
```

작업 체크리스트:

- [x] English/Korean 버튼 텍스트를 Flutter `Text` 렌더링으로 전환
- [x] 보이는 exit button이 없는지 확인
- [x] 버튼 크기, 간격, 터치 영역이 모바일 화면에서 적절한지 확인
- [ ] live screen을 `assets/menu/main_menu_eng.png`, `assets/menu/main_menu_kor.png` 참고 이미지와 비교
- [x] Start Game이 red primary button인지 확인
- [x] 다른 main button이 dark secondary button인지 확인
- [x] Start Game과 Difficulty 사이 세로 간격이 없는지 확인
- [x] Records와 Settings가 위 버튼과 작은 responsive gap을 유지하는지 확인
- [x] Main buttons가 로고 무게감과 맞도록 두께 미세 조정
- [x] Currency panel이 미래 currency 표시용 blank frame으로 보이는지 확인
- [x] Currency panel이 길고 얇기보다 짧고 두꺼운지 확인
- [x] Bottom utility buttons가 화면 텍스트 없는 icon-only asset 구조를 사용하도록 정리
- [x] Bottom utility buttons가 화면 edge를 침범하지 않으면서 보조 메뉴처럼 보이는지 확인
- [x] Bottom utility icon asset의 바깥 배경을 투명 PNG로 정리
- [ ] 생성 PNG 주변 chroma-key/green edge artifact 확인
- [ ] 사용하지 않는 실험용 menu asset은 `home_screen.dart` 참조 여부 확인 후에만 정리

수정 금지:

- `lib/features/game/`
- `lib/features/mode_select/`
- `lib/domain/`
- `lib/data/`
- `android/`

후속 후보:

- blank currency panel 안에 Flutter-rendered currency text 추가
- currency text 추가 후 panel 위치를 오른쪽/아래로 조정할지 재검토
- 최신 실기기 screenshot 기준으로 bottom utility buttons 위치/폭 재검토
- Main Menu layout 승인 후 Mission Setup visual polish로 이동

### Task 2.1 Mission Setup Asset Visual QA

상태: DONE / WATCH

목표:

- Mission Setup PNG가 dark sci-fi metal style과 맞는지 검토하고 필요한 asset만 교체한다.

작업 범위:

```text
assets/mission_setup/
```

작업 체크리스트:

- [x] `slider_track.png`의 과도한 좌우 투명 여백을 제거하고 visible track을 canvas 대부분으로 확장
- [x] `difficulty_*_on.png` 3개를 사용자가 제공한 `D:\download\New_button.png` 기반 asset으로 교체
- [x] `difficulty_*_off.png` 3개를 사용자가 제공한 `D:\download\New_off.png` 기반 asset으로 교체
- [x] off button은 외부 검은 배경만 투명 처리하고, 프레임 내부 dark panel 색/질감은 보존
- [x] 버튼 텍스트는 이미지에 bake하지 않고 Flutter `Text` 유지
- [ ] 실제 기기/에뮬레이터에서 selected/off 버튼 대비, 투명 가장자리, 텍스트 가독성 최종 확인

수정 금지:

- `lib/features/game/`
- `lib/domain/`
- `lib/data/`
- `android/`

### Task 2.2 Mission Setup Layout Fine Tuning

상태: DONE

목표:

- Mission Setup을 reference design에 더 가깝게 만들되, 한 화면 non-scroll 구조를 유지한다.

작업 대상:

```text
lib/features/mode_select/mode_select_screen.dart
lib/features/settings/settings_screen.dart
```

작업 체크리스트:

- [x] 현재 파일 내용을 읽는다.
- [x] `LayoutBuilder`를 유지한다.
- [x] 공통 배경 `assets/menu/background.png`를 유지한다.
- [x] 모든 text는 Flutter widget으로 렌더링한다.
- [x] 단일 화면 non-scroll 구조를 유지한다.
- [x] 작은 화면 overflow 위험을 줄이도록 responsive section/button sizing을 조정한다.
- [x] Section title style을 DIFFICULTY / LIMIT MODE 공통 스타일로 통일
- [x] Difficulty button 내부 불필요한 작은 사각형 제거
- [x] Time summary card를 `TIME LIMIT / OFF` 또는 실제 시간 값으로 표시
- [x] Attempts/Time slider의 badge, tick, thumb 위치를 단일 값 리스트 기준으로 동기화
- [x] Difficulty / Limit Mode 영역 위치와 간격을 사용자 피드백 기준으로 아래쪽에 재배치
- [x] Start Mission 버튼의 key icon 제거 및 텍스트 중앙 정렬
- 완료 메모: Mission Setup의 back icon을 title block 오른쪽 아래로 이동하고, difficulty button 크기/간격/두께, LIMIT MODE 위치/간격, Attempts/Time slider 동기화, Start Mission 텍스트 정렬을 미세 조정했다.

수정 금지:

- `lib/features/game/game_controller.dart`
- `lib/core/utils/judge_code.dart`
- `assets/menu/`
- `android/`

### Task 2.3 Mission Setup Widget 분리

상태: TODO

목표:

- 동작 변경 없이 `mode_select_screen.dart`의 크기를 줄인다.

작업 체크리스트:

- [ ] `lib/features/mode_select/widgets/` 생성 여부 결정
- [ ] private widget을 `lib/features/mode_select/widgets/` 아래로 분리
- [ ] UI 동작을 변경하지 않는다.
- [ ] layout proportions를 변경하지 않는다.
- [ ] assets를 변경하지 않는다.
- [ ] game config rules를 변경하지 않는다.
- [ ] 분리 후 analyze/test 확인을 사용자에게 안내하거나 허용 시 실행한다.

수정 금지:

- `lib/features/game/`
- `lib/domain/`
- `assets/`

---

## Priority 3. Gameplay Screen Redesign

### Task 3.1 Game Screen Asset List 정의

상태: TODO

목표:

- 이미지 생성 전 gameplay UI에 필요한 asset 목록과 size를 문서로 정의한다.

작업 체크리스트:

- [ ] planning doc만 생성/수정
- [ ] code slots asset 정의
- [ ] keypad buttons asset 정의
- [ ] status panels asset 정의
- [ ] history rows asset 정의
- [ ] check table asset 정의
- [ ] pause button asset 정의
- [ ] 각 asset의 예상 size와 transparent PNG 여부 정의

수정 금지:

- Dart source files
- existing assets

### Task 3.2 Game Screen Assets 생성

상태: TODO

목표:

- gameplay UI asset을 동일한 sci-fi metal style로 생성한다.

저장 위치:

```text
assets/game/
```

작업 체크리스트:

- [ ] `assets/game/` 생성 여부 확인
- [ ] dark sci-fi metal style로 gameplay UI part 생성
- [ ] 텍스트 baked-in 여부를 asset별로 명확히 결정
- [ ] `pubspec.yaml` asset 등록 필요 여부 확인

수정 금지:

- game logic
- mission setup assets

### Task 3.3 Game Screen Design 적용

상태: TODO

목표:

- `GameScreen`에 최종 asset과 responsive layout을 적용한다.

작업 대상:

```text
lib/features/game/game_screen.dart
lib/features/game/widgets/*
lib/core/widgets/app_background.dart  # 필요한 경우만
```

작업 체크리스트:

- [ ] `lib/features/game/game_screen.dart` 읽기
- [ ] `lib/features/game/widgets/*` 읽기
- [ ] 최종 asset 기반 responsive layout 적용
- [ ] UI bug가 증명된 경우에만 controller 변경 여부 검토

수정 금지:

- `lib/features/game/game_controller.dart` unless UI bug proves controller change is necessary
- `lib/core/utils/judge_code.dart`
- `lib/domain/models/game_config.dart`

---

## Priority 4. Localization

### Task 4.1 AppText 구조 개선 또는 Flutter Localization 전환

상태: TODO

목표:

- 현재 ad hoc `AppText`를 더 명확한 project-local string 구조 또는 Flutter ARB localization으로 전환한다.

작업 체크리스트:

- [ ] 현재 `lib/core/constants/app_text.dart` 구조 분석
- [ ] Korean/English 자동 전환 유지
- [ ] localization이 완전히 연결될 때까지 `PlatformDispatcher` fallback 보존
- [ ] ARB 또는 project-local string 구조 중 선택
- [ ] 기존 화면 텍스트 회귀 확인

수정 금지:

- game logic
- assets
- Android manifest

---

## Priority 5. Settings Persistence

### Task 5.1 설정값 저장

상태: TODO

목표:

- sound / music / vibration / auto check table 기본값을 local storage에 저장한다.

작업 체크리스트:

- [ ] settings repository 설계
- [ ] `shared_preferences` 사용
- [ ] sound/music/vibration/auto check table 기본값 저장
- [ ] Mission Setup에서 설정값 load
- [ ] records storage schema는 반드시 필요한 경우에만 변경

수정 금지:

- records storage schema unless absolutely required
- gameplay judgement logic

---

## Priority 6. Records Improvements

### Task 6.1 Records Screen 개선

상태: TODO

목표:

- Records 화면을 최종 visual style에 맞추고 stats 표시를 개선한다.

작업 체크리스트:

- [ ] `lib/features/records/records_screen.dart` 읽기
- [ ] records screen만 수정
- [ ] final visual style 반영
- [ ] stats 표시 개선
- [ ] `GameRecord` schema 변경이 필요하면 migration plan 추가

수정 금지:

- game controller
- mission setup

---

## Priority 7. Android Release Readiness

### Task 7.1 Launch / Icon / Metadata 정리

상태: TODO

목표:

- Android launch screen, app icon, label, package metadata를 배포 가능 수준으로 정리한다.

작업 범위:

```text
android/
assets/  # 필요한 경우만
```

작업 체크리스트:

- [ ] Android app icon 확정
- [ ] Android launch screen 확정
- [ ] app label 확인
- [ ] package metadata 확인
- [ ] release build 설정 확인

수정 금지:

- Flutter game logic
- mission setup UI

---

## 다음 Codex 작업 후보

1. `Task 2.0` 메인 메뉴 화면 QA 결과를 기준으로 레이아웃 또는 에셋 정리
2. `Task 2.3` 미션 설정 화면 widget 분리
3. `Task 3.1` 게임 화면 에셋 목록과 레이아웃 계획 문서화
