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
- 2026-05-06: emulator에서 `vendor.mesa.virtgpu.kumquat`, `Lost connection to device`가 재발했으나 `flutter run --enable-software-rendering`으로 정상 작동을 확인했다. 코드 문제보다 emulator GPU/virtgpu 이슈 가능성이 높다.
- 2026-05-07: `flutter run`에서 DDS WebSocket 연결 실패(`Connection closed before full header was received`)가 반복 보고되었다. `--disable-dds --enable-software-rendering` 우회 실행이 필요하다.
- 2026-05-07: `assembleDebug`/`assembleRelease` 중 `org.jetbrains.kotlin.incremental.storage.*` close stack이 반복 보고되었다. Gradle/Kotlin incremental cache 손상 또는 file lock 가능성이 있으며 `kotlin.incremental=false`와 Gradle cache cleanup을 검토한다.
- 2026-05-07: BoomCode MVP는 portrait-only로 고정했다. Flutter `SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])`와 Android `android:screenOrientation="portrait"`을 적용해 landscape overflow 전환 자체를 막는다.
- 재발 시 logcat에서 `FATAL EXCEPTION`, `AndroidRuntime`, `SIG`, `WindowInsets`, `FlutterJNI`, `com.example.bombcode` 기준으로 다시 확인한다.

작업 체크리스트:

- [ ] 사용자가 실행한 `flutter analyze` 결과 확인
- [ ] `flutter clean`, `flutter pub get`, `flutter run` 재실행 결과 확인
- [ ] 종료가 반복되면 `flutter run -v` 또는 Android logcat에서 `FATAL EXCEPTION`, `ANR`, `WindowInsets`, `MainActivity`, `FlutterJNI` 로그 확인
- [ ] Flutter 예외인지 Android window/insets 문제인지 구분
- [ ] Android 쪽 edge-to-edge, navigation bar, manifest/theme 설정 확인
- [ ] Home 화면 layout 계산이 viewport/insets 변화에 민감한지 재검토
- [ ] DDS 실패 시 `flutter run --disable-dds --enable-software-rendering` 확인
- [ ] Gradle Kotlin incremental storage 에러 반복 시 `android/gradle.properties`에 `kotlin.incremental=false`, `kotlin.incremental.useClasspathSnapshot=false`, `org.gradle.caching=false` 적용 검토
- [ ] `FAILURE`, `What went wrong`, 첫 `Caused by` 로그 확보
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
flutter run --enable-software-rendering
flutter run --disable-dds --enable-software-rendering
```

### Task 1.1 Analyze/Test 이슈 수정

상태: DONE

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
- [x] Digits / Timer / Reward summary card 영역, 아이콘, 텍스트 크기 확대
- 완료 메모: Mission Setup의 back icon을 title block 오른쪽 아래로 이동하고, difficulty button 크기/간격/두께, summary card 크기, LIMIT MODE 위치/간격, Attempts/Time slider 동기화, Start Mission 텍스트 정렬을 미세 조정했다.

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

상태: DONE

목표:

- 이미지 생성 전 gameplay UI에 필요한 asset 목록과 size를 문서로 정의한다.

작업 체크리스트:

- [x] planning doc만 생성/수정
- [x] code slots asset 정의
- [x] keypad buttons asset 정의
- [x] status panels asset 정의
- [x] history rows asset 정의
- [x] check table asset 정의
- [x] pause button asset 정의
- [x] 각 asset의 예상 size와 transparent PNG 여부 정의
- 완료 메모: `docs/GAME_SCREEN_ASSET_LIST.md`를 생성/보완해 Game Screen redesign에 필요한 asset 이름, 목적, 권장 크기, transparent PNG 여부, text bake-in 여부, 상태 값, Required/Optional 기준, visual style detail, layout priority, check table 표시 기준, Task 3.2 단계별 생성 순서를 정리했다.

수정 금지:

- Dart source files
- existing assets

### Task 3.2-A Game Screen Core Input Assets 생성

상태: DONE

목표:

- Game Screen의 core input area asset만 먼저 생성해 main password input area의 visual style을 검증한다.

저장 위치:

```text
assets/game/
```

작업 체크리스트:

- [x] `assets/game/` 생성 여부 확인
- [x] `bomb_device_frame.png` 생성 및 reference style 기준 재작업
- [x] `code_slot_empty.png` 생성
- [x] `code_slot_filled.png` 생성
- [x] `code_slot_selected.png` 생성
- [x] `keypad_button_idle.png` 생성
- [x] `keypad_button_pressed.png` 생성
- [x] `keypad_button_disabled.png` 생성
- [x] dark industrial bomb-defusal console style, transparent PNG, no baked text 기준 확인
- [x] visual QA preview 생성: `tmp/visual_qa/game_core_input_assets_reworked_preview.png`
- [x] 기술 검증: RGBA PNG, 권장 크기, border alpha, green/chroma pixel 확인
- 완료 메모: Task 3.2-A asset 7개는 사용자가 제공한 reference style 방향으로 재작업되어 승인되었다. `pubspec.yaml` asset 등록은 Task 3.3-A UI 적용 시 `assets/game/` 추가로 처리했다.

수정 금지:

- game logic
- mission setup assets

후속:

- Task 3.2-B Status / History Panel Assets 생성: DONE
- Task 3.2-C Check Table / Memo Assets 생성: DONE
- Task 3.2-D Modal / Result Assets 생성: DONE

### Task 3.2-B Status / History Panel Assets 생성

상태: DONE

목표:

- Game Screen 상단 status, latest Access/Trace, recent history 영역에 사용할 asset을 생성한다.

생성 파일:

```text
assets/game/game_header_panel.png
assets/game/status_panel_small.png
assets/game/access_trace_panel.png
assets/game/history_panel.png
assets/game/history_row_panel.png
assets/game/status_history_assets_preview.png
```

완료 메모:

- Task 3.2-A와 같은 bomb-defusal console style로 5개 panel asset을 생성했다.
- 이후 visual polish 1회를 통해 header/status/history panel을 더 compact하게 조정했다.
- 최종 크기: `game_header_panel.png` 720x112, `status_panel_small.png` 220x96, `access_trace_panel.png` 640x96, `history_panel.png` 680x220, `history_row_panel.png` 640x72.
- 기존 Task 3.2-A asset은 수정하지 않았다.

### Task 3.2-C Check Table / Memo Assets 생성

상태: DONE

목표:

- Check Table container와 digit marker 상태 asset을 생성한다.

생성 파일:

```text
assets/game/check_table_panel.png
assets/game/digit_marker_unknown.png
assets/game/digit_marker_possible.png
assets/game/digit_marker_impossible.png
assets/game/digit_marker_access_candidate.png
assets/game/digit_marker_trace_candidate.png
assets/game/check_table_assets_preview.png
```

완료 메모:

- marker 5종은 text/number bake-in 없이 brightness, border, accent, pattern 차이로 상태가 구분되도록 제작했다.
- 기존 Task 3.2-A/B asset은 수정하지 않았다.

### Task 3.2-D Modal / Result Assets 생성

상태: DONE

목표:

- Pause, success result, failure result modal과 modal action button asset을 생성한다.

생성 파일:

```text
assets/game/pause_modal_panel.png
assets/game/result_modal_success.png
assets/game/result_modal_failure.png
assets/game/modal_primary_button.png
assets/game/modal_secondary_button.png
assets/game/modal_result_assets_preview.png
```

완료 메모:

- modal/result asset 5개를 생성한 뒤 visual polish 1회를 수행했다.
- success는 subtle cyan/blue 안정 상태, failure는 red/orange warning device 상태, pause는 neutral dark panel로 구분했다.
- preview는 720x1800 구성으로 갱신해 success/failure/pause modal이 겹치지 않게 했다.
- 기존 Task 3.2-A/B/C asset은 수정하지 않았다.

### Task 3.2-E Main Play Redesign Required Assets generation

상태: DONE

목표:

- 사용자가 승인한 bomb-centric redesign plan을 실제 구현할 수 있도록 required asset을 생성한다.
- 상단 bomb hero device가 main play screen의 주인공처럼 보이도록 stable/caution/danger/critical 상태 asset을 준비한다.
- Check Table을 main screen에서 숨기고 modal/bottom sheet로 열 수 있도록 button/modal asset을 준비한다.
- Delete/Submit 전용 keypad action button asset을 준비한다.

생성 파일:

```text
assets/game/bomb_hero_stable.png
assets/game/bomb_hero_caution.png
assets/game/bomb_hero_danger.png
assets/game/bomb_hero_critical.png
assets/game/current_code_panel.png
assets/game/check_table_open_button.png
assets/game/keypad_delete_button.png
assets/game/keypad_submit_button.png
assets/game/keypad_submit_disabled.png
assets/game/check_table_modal_panel.png
assets/game/modal_close_button.png
assets/game/main_play_required_assets_preview.png
```

완료 메모:

- `docs/GAME_SCREEN_REDESIGN_PLAN.md`를 생성하고 사용자가 승인한 뒤, 요청 보완사항을 반영했다.
- Required asset generation 단계에 QA preview `assets/game/main_play_required_assets_preview.png`를 추가했다.
- bomb hero 4종은 같은 pixel size, 같은 transparent canvas, 같은 device alignment를 유지해야 한다는 규칙을 문서에 추가했다.
- keypad action button 3종은 기존 `keypad_button_*` 계열과 높이감, bevel, metal texture를 맞춰야 한다는 규칙을 문서에 추가했다.
- required asset 11개와 preview 1개를 생성했다.
- `bomb_hero_*` 4종은 최초 `720x400 RGBA`로 생성했다. 이후 사용자가 교체한 hero 이미지는 checkerboard background를 투명화하고 `720x405 RGBA`로 최소 보정했다.
- `current_code_panel.png`는 `680x180 RGBA`, `check_table_modal_panel.png`는 `680x520 RGBA`, `modal_close_button.png`는 `112x112 RGBA`로 생성했다.
- 이후 사용자가 bomb hero/device asset의 visual rework를 요청해 아래 5개 asset과 preview를 다시 재작업했다.

Visual rework 대상:

```text
assets/game/bomb_device_frame.png
assets/game/bomb_hero_stable.png
assets/game/bomb_hero_caution.png
assets/game/bomb_hero_danger.png
assets/game/bomb_hero_critical.png
assets/game/main_play_required_assets_preview.png
```

Visual rework 완료 메모:

- 기존 flat panel/frame 느낌을 줄이고 stylized but believable bomb-defusal device 느낌을 강화했다.
- side housing, cables, connectors, bolts, warning lights, recessed display area, stage별 glow/meter 차이를 반영했다.
- `bomb_device_frame.png`는 단순 input frame이 아니라 bomb hero의 하위 입력 장치 모듈처럼 재작업했다.
- bomb hero 4종은 같은 canvas, 같은 silhouette/body shape, 같은 display-safe area 위치를 유지한다.
- 텍스트, 숫자, 난이도, timer, attempts 값은 bake-in하지 않았다.
- RGBA PNG, transparent corner alpha, bright chroma-green pixel 여부를 확인했다.

### Task 3.3-A Game Screen Asset-backed Layout Implementation

상태: DONE / SUPERSEDED BY 3.3-C

목표:

- 승인된 Task 3.2-A/B/C/D game asset을 Game Screen main gameplay view에 1차 적용한다.

작업 대상:

```text
lib/features/game/game_screen.dart
lib/features/game/widgets/*
pubspec.yaml
```

현재 적용 내용:

- [x] `pubspec.yaml`에 `assets/game/` 등록 추가
- [x] `game_asset_paths.dart` 추가
- [x] `asset_frame.dart` 추가
- [x] `LimitStatusBar`에 `game_header_panel.png`, `status_panel_small.png` 적용
- [x] `CodeSlots`에 `bomb_device_frame.png`, `code_slot_empty/filled/selected.png` 적용
- [x] `NumberKeypad`에 `keypad_button_idle/pressed/disabled.png` 적용
- [x] delete/submit은 1차 적용 당시 전용 keypad action asset이 없어 modal button asset으로 임시 적용
- [x] latest Access/Trace 영역에 `access_trace_panel.png` 적용
- [x] recent history 영역에 `history_panel.png`, `history_row_panel.png` 적용
- [x] Check Table 영역에 `check_table_panel.png`, `digit_marker_*` 적용
- [x] pause/result modal에 Task 3.2-D asset 적용
- [x] `game_controller.dart`, `judge_code.dart`, `game_config.dart` 수정 없음
- [x] asset 이미지 파일 수정 없음

검증 상태:

- [x] 사용자가 `dart format` 실행. `pubspec.yaml`을 format 대상에 포함해 YAML parse error가 출력되었으나 Dart 파일 format은 진행됨.
- [ ] `flutter analyze` 결과 확인 필요
- [ ] `flutter test` 결과 확인 필요
- [ ] `flutter run` 화면 QA 필요
- [ ] Android emulator debug service connection issue가 재발할 수 있음. `flutter run --enable-software-rendering` 우선 권장.

주의 / 후속:

- 작은 화면에서 non-scroll overflow 여부 확인 필요.
- keypad touch target, code slot 숫자 가독성, check table 높이, history compact 표시 QA 필요.
- delete/submit 전용 action button asset은 Task 3.2-E에서 생성 완료했고 Task 3.3-C에서 Dart UI에 연결했다.

### Task 3.3-C Main Play Screen Bomb-Centric Layout implementation

상태: DONE / VERIFY BLOCKED BY BUILD

목표:

- Task 3.2-E에서 생성/재작업한 bomb hero 중심 asset을 Game Screen main gameplay layout에 적용한다.
- Check Table grid를 main screen에서 제거하고 button/modal 흐름으로 전환하기 위한 기반을 만든다.
- 기존 game logic은 유지하고 UI 구조만 bomb-centric layout으로 재배치한다.

작업 대상:

```text
lib/features/game/game_screen.dart
lib/features/game/widgets/*
pubspec.yaml  # 신규 asset 등록이 필요한 경우만
```

작업 체크리스트:

- [x] `docs/GAME_SCREEN_REDESIGN_PLAN.md` 다시 확인
- [x] `bomb_hero_stable/caution/danger/critical.png` asset path 추가
- [x] visual stage 계산 helper 추가
- [x] bomb hero section 적용
- [x] difficulty / attempts left / time left Flutter Text overlay 적용
- [x] `current_code_panel.png` 기반 Current Code section 적용
- [x] `keypad_delete_button.png`, `keypad_submit_button.png`, `keypad_submit_disabled.png` 연결
- [x] latest Access/Trace result section은 READY panel 없이 최근 결과가 있을 때만 compact text로 표시
- [x] History title 제거, compact 내부 scroll 구조 적용
- [x] Check Table grid를 main screen에서 제거하고 우상단 icon button 배치
- [x] `game_controller.dart`, `judge_code.dart`, `game_config.dart` 변경 없음 확인

완료 메모:

- 상단 `LimitStatusBar`, READY panel, pause button, main Check Table bar, tried/current count utility bar를 제거했다.
- Bomb hero를 화면 상단 중심의 핵심 visual로 확대하고 hero 내부에 difficulty/left/time Flutter Text를 overlay했다.
- `bomb_device_frame.png`는 더 이상 main Game Screen code path에서 사용하지 않는다.
- 사용자 교체 hero 이미지는 checkerboard background를 투명화하고 emulator 부담을 줄이기 위해 `720x405 RGBA`로 최소 보정했다.
- `flutter analyze`에서 nullable `maxAttempts` 문제가 보고되어 UI stage helper에 null/0 check를 추가했다.
- Live QA는 DDS/Gradle Kotlin incremental build 이슈로 아직 완료되지 않았다.

수정 금지:

- `lib/features/game/game_controller.dart`
- `lib/core/utils/judge_code.dart`
- `lib/domain/models/game_config.dart`
- 게임 규칙
- Access / Trace 판정
- 난이도 로직
- attempts/timer 로직
- `android/`

### Task 3.3-D Check Table Modal / Bottom Sheet implementation

상태: PARTIAL

목표:

- Check Table button을 눌렀을 때 modal, bottom sheet, 또는 overlay로 Check Table을 표시한다.
- 기존 digit marker 상태와 manual marking 흐름은 유지한다.

작업 체크리스트:

- [x] main screen 기본 상태에서 Check Table grid 미표시
- [x] 우상단 icon button으로 Check Table entry 배치
- [x] bottom sheet 안에서 기존 `CheckTable`과 `digit_marker_*` 재사용
- [x] 기존 `DigitMark` 상태 mapping 유지
- [x] manual marking 흐름 유지
- [ ] `check_table_modal_panel.png` 적용
- [ ] `modal_close_button.png` 적용

### Task 3.3-E Game Screen Responsive QA and Visual Polish

상태: IN PROGRESS / LATEST POLISH VERIFY NEEDED

목표:

- bomb-centric Game Screen 구현 후 작은 화면과 font scale에서 overflow, 가독성, touch target을 확인한다.
- 2026-05-07 Game Screen final polish 기준으로 `Bomb HUD -> Current Code -> Keypad -> History` 흐름, compact keypad, tactical history table, History 내 Check Table button을 live QA한다.

작업 체크리스트:

- [x] 360x800 기준 overflow 이슈 1차 확인 및 height/spacing 조정
- [ ] 더 작은 화면 확인
- [ ] font scale 확인
- [x] keypad touch target 48dp 이상 유지하도록 button height 고정
- [x] History internal scroll 구조 유지
- [ ] bomb hero stage 전환 시 위치 흔들림 없음 확인
- [x] Flutter Text overlay가 bomb hero display-safe area 안에 들어가도록 label/content padding 조정
- [x] Check Table modal entry를 History panel 오른쪽 위 utility button으로 이동
- [x] History inner frame 중복감을 줄이도록 단일 dark tactical surface와 subtle texture 적용
- [x] History `# / CODE / RESULT` header와 row column alignment 재정렬
- [x] Check Table entry를 bulb PNG + circular frame으로 변경하고 History header 높이에 맞춤
- [x] `bomb_hero_critical.png` optical size를 다른 bomb hero state에 맞게 소폭 축소
- [ ] 최신 Check Table bulb/circular icon이 기능 버튼처럼 보이는지 live visual QA
- [ ] History fixed height 복귀 후 empty/1-row/many-row 상태 확인
- [ ] Bomb hero critical 축소 후 HUD 숫자 가독성 및 stage 전환 흔들림 확인
- [ ] latest polish 후 `dart format`, `flutter analyze`, `flutter test` 확인
- [x] Bomb hero stage animation loop 추가: image shake/scale 없이 light/glow overlay만 반복
- [x] Bomb hero stage image 전환을 crossfade로 자연스럽게 처리
- [x] Number/Delete/Submit keypad press scale feedback 추가
- [x] Success/Failure result ambience overlay asset 생성
- [x] 결과 표시를 새 전체 화면 대신 기존 Game Screen 위 dark overlay + ambience image + result modal로 변경
- [x] result modal fade + subtle scale transition 적용
- [ ] success/failure overlay brightness, modal readability, and small-screen overflow live QA

최근 적용 메모:

- Bomb HUD 내부 난이도 텍스트 제거.
- LEFT/TIME label과 숫자를 stage color와 동기화.
- Attempts는 `06 /7`처럼 suffix spacing을 약간 둠.
- ACCESS / TRACE 별도 상단 요약 제거.
- Current Code는 얇은 Flutter frame + slot 중심 구조로 경량화.
- Main flow를 `Bomb HUD -> Current Code -> Keypad -> History`로 변경.
- Keypad는 Current Code 중심축에 맞춘 compact width와 48dp button height를 사용.
- History는 compact tactical table로 조정하고, header/row column structure를 공유.
- History panel inner frame은 code-side dark surface overlay로 약화했고, header/body가 같은 surface 안에서 보이도록 정리.
- History body에는 visible pattern이 아닌 낮은 alpha의 CustomPainter brushed line/speck texture를 적용.
- History panel 오른쪽 위에 Check Table button 배치.
- Check Table button icon은 사용자 교체 이미지에서 panel/background를 제거한 `check_table_bulb_icon.png`를 사용하며, circular frame 안에 표시.
- `bomb_hero_critical.png`는 canvas size를 유지한 채 internal content만 소폭 줄여 optical size를 맞춤.
- `assets/game/bomb_hero_*` near-white matte를 dark matte로 보정했고 `.bak_matte` backup이 생성됨.
- Bomb stage animation polish: hero images stay fixed; only glow/light overlays animate in a loop, stage image swaps crossfade, and Critical avoids shake/jitter.
- Keypad feedback polish: number/delete buttons use subtle 100ms scale feedback, submit uses a stronger press scale, and disabled buttons remain static.
- Result overlay polish: `assets/game/bomb_defused_overlay.png` and `assets/game/bomb_exploded_overlay.png` were generated. Game results now overlay the current gameplay screen with a dark translucent barrier, result ambience image, subtle green/cyan or red flash, and existing result modal content. Text/buttons remain Flutter-rendered; no new dependencies were added.

### Task 3.3 Game Screen Design 적용

상태: IN PROGRESS / GAME SCREEN POLISH APPLIED

목표:

- `GameScreen`에 최종 asset과 responsive layout을 적용한다.

작업 대상:

```text
lib/features/game/game_screen.dart
lib/features/game/widgets/*
lib/core/widgets/app_background.dart  # 필요한 경우만
```

작업 체크리스트:

- [x] `lib/features/game/game_screen.dart` 읽기
- [x] `lib/features/game/widgets/*` 읽기
- [x] 최종 asset 기반 responsive layout 1차 적용
- [x] Game Screen final polish 반영: Bomb HUD, Current Code, Keypad, History table, Check Table entry 위치/아이콘
- [x] UI-only 범위 유지. `game_controller.dart`, `judge_code.dart`, `game_config.dart` 변경 없음
- [ ] 최신 polish 후 format/analyze/test/live QA 확인

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

상태: PARTIAL

목표:

- sound / music / vibration / auto check table 기본값을 local storage에 저장한다.

작업 체크리스트:

- [x] sound volume 저장/로드 foundation 추가 (`GameSoundEffects`)
- [x] vibration enabled 저장/로드 foundation 추가 (`GameHaptics`)
- [x] `shared_preferences` 사용
- [x] Mission Setup 마지막 `GameConfig` 저장/로드 (`LocalGameConfigRepository`)
- [x] Home Start Game이 마지막 저장 config로 바로 시작
- [x] 저장 config가 없으면 Normal + Attempts OFF + Time OFF 기본값 사용
- [ ] music 설정 저장/로드
- [ ] auto check table 설정을 Settings와 Mission Setup 사이에 일관되게 연결
- [ ] language override 저장/로드
- [ ] records storage schema는 반드시 필요한 경우에만 변경

최근 적용 메모:

- `lib/core/utils/game_sound_effects.dart`: sound slider 값이 0이면 효과음 skip, 0보다 크면 Flutter `SystemSound` 호출.
- `lib/core/feedback/game_haptics.dart`: vibration setting이 꺼져 있으면 `HapticFeedback` skip.
- `lib/data/local_game_config_repository.dart`: 마지막 GameConfig를 JSON string으로 저장.
- Attempts OFF is represented by `GameConfig.maxAttempts == null`; Time OFF remains `timeLimit == null`.
- `LimitMode.none` added for Attempts OFF + Time OFF.

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
3. `Task 1.0` Android/DDS/Gradle Kotlin build 안정화
4. `Task 3.3-E` Game Screen latest polish 검증 및 마감 QA
