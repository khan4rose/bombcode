# CODEX_INSTRUCTIONS

이 문서는 Codex가 BoomCode 프로젝트에서 작업할 때 반드시 따라야 할 공통 규칙이다. 새 Codex chat/task를 시작할 때 먼저 읽고 작업한다.

## 1. 프로젝트 컨텍스트

| 항목 | 내용 |
| --- | --- |
| 프로젝트 경로 | `D:\jtj\bombcode` |
| 프로젝트 종류 | Flutter mobile game |
| 앱 이름 | BoomCode |
| 핵심 콘셉트 | Offline bomb-defusal themed numeric code deduction game |
| 필수 용어 | `Access / Trace` |

## 2. 작업 전 문서 확인 순서

1. `docs/PROJECT_STATUS.md`
   - 현재 구현 상태, 완료 항목, 미구현 항목, 문제점을 확인한다.
2. `docs/NEXT_TASKS.md`
   - 이번 작업이 어느 task에 해당하는지 확인한다.
3. `docs/CODEX_INSTRUCTIONS.md`
   - 작업 규칙과 금지 사항을 확인한다.
4. `docs/UI_GUIDELINES.md`
   - UI 작업이면 반드시 확인한다.
5. `docs/ARCHITECTURE.md`
   - 구조 변경, 파일 생성, refactor, 데이터 흐름 변경 작업이면 반드시 확인한다.
6. 수정 대상 파일의 현재 내용을 반드시 읽는다.

## 3. 용어 규칙

BoomCode는 숫자 야구가 아니라 폭탄 해체/암호 해독 게임이다.

반드시 사용할 용어:

- `Access`
- `Trace`
- `A/T`: 작은 UI에서 의도적으로 축약이 필요할 때만

사용 금지:

- `Strike`
- `Ball`
- `S/B`
- baseball terminology
- Korean baseball-scoring equivalents
- `baseball` as a game concept

의미:

- `Access`: 숫자와 위치가 모두 맞음
- `Trace`: 숫자는 맞지만 위치가 다름

## 4. 기본 작업 방식

- 파일 수정 전 반드시 현재 파일 내용을 먼저 읽는다.
- 요청된 작업을 해결할 수 있는 가장 작은 안전한 변경만 한다.
- 기존 코드 수정을 우선한다.
- 같은 목적의 파일, 위젯, 유틸을 중복 생성하지 않는다.
- 불필요한 새 파일 생성을 피한다.
- 새 파일은 작업 목적상 필요하고 기존 구조와 맞을 때만 만든다.
- 앱 전체를 rewrite하지 않는다.
- 관련 없는 refactor를 하지 않는다.
- 큰 파일 분리는 별도 task로 진행한다.
- 사용자 생성 asset을 삭제하지 않는다.
- 사용자 요청 없이 generated asset을 교체하지 않는다.
- 사용자 편집 내용이 있는 파일은 되돌리지 말고 그 위에서 작업한다.
- 불확실한 내용은 코드와 문서를 확인하고, 그래도 불확실하면 `확인 필요`로 남긴다.

작업 종류별 분리 원칙:

- visual-only task에서는 game logic을 건드리지 않는다.
- logic task에서는 asset/UI 변경을 피한다.
- 문서 task에서는 요청된 문서만 수정한다.

## 5. 명령어 실행 규칙

사용자가 보통 build/test/analyze 명령을 직접 실행한다. Codex는 사용자가 현재 task에서 명시적으로 허용하지 않는 한 다음 명령어를 직접 실행하지 않는다.

```bash
flutter run
flutter build
flutter test
flutter analyze
dart format
```

허용되는 작업:

- 필요한 project file 읽기
- 요청받은 문서 생성/수정
- 사용자가 요청한 image asset 생성
- 사용자가 허용한 경우에만 format/analyze/test 실행

## 6. Flutter 점검 명령어 안내

사용자에게 필요 시 다음 순서로 실행하라고 안내한다.

```bash
flutter pub get
dart format .
flutter analyze
flutter test
flutter run
```

Emulator debug connection이 불안정하면 다음도 안내한다.

```bash
flutter clean
flutter pub get
flutter run
```

추가 조치:

- Android Emulator cold boot
- 새 emulator image 생성
- VS Code에서 `flutter run`을 `Ctrl + C`로 중단한 뒤 연결이 꼬이면 emulator 재시작

## 7. 주요 파일 보호 규칙

### Visual-only task에서 건드리지 말 것

```text
lib/features/game/game_controller.dart
lib/core/utils/judge_code.dart
lib/domain/models/game_config.dart
```

### Mission Setup 관련 중요 파일

```text
lib/features/mode_select/mode_select_screen.dart
```

규칙:

- 현재 큰 파일이므로 신중히 수정한다.
- 사용자 요청 없이 scroll 구조로 바꾸지 않는다.
- visual-only task에서는 game logic 변경을 하지 않는다.

### Home / Main Menu 관련 중요 파일

```text
lib/features/home/home_screen.dart
```

규칙:

- active UI에서는 text baked button image를 사용하지 않는다.
- 버튼은 공통 frame/icon PNG와 Flutter 렌더링 `Text`를 조합한다.
- 하단 utility button은 icon-only PNG를 사용하고 화면 텍스트를 표시하지 않는다.
- 하단 utility button의 의미는 Semantics label로 유지한다.
- 하단 utility button의 터치 영역과 보이는 icon size는 분리한다.
- Android viewport metrics 반복 문제가 발생하면 Flutter UI 변경만으로 단정하지 말고 Android window/insets 로그를 확인한다.
- 기존 text baked button asset은 보존하되 사용자 요청 없이 삭제하지 않는다.
- 사용자 요청 없이 visible exit button을 재도입하지 않는다.
- 사용자 요청 없이 full-screen image-map 방식으로 전환하지 않는다.

### 공통 배경

```text
lib/core/widgets/app_background.dart
assets/menu/background.png
```

규칙:

- 모든 주요 화면의 공통 배경 기준이다.
- 사용자 요청 없이 화면별 full background image를 새로 만들지 않는다.

## 8. 문서 작업 규칙

- 문서 작업을 할 때는 요청된 문서만 생성/수정한다.
- 코드, asset, `pubspec.yaml`, `android/`는 수정하지 않는다.
- 완료된 기능과 예정 기능을 섞어 쓰지 않는다.
- 구현되지 않은 기능은 `미구현` 또는 `예정`으로 표시한다.
- 불확실한 내용은 `확인 필요`로 표시한다.
- 기존 문서의 중요한 정보는 역할에 맞게 이동하고 중복은 제거한다.

문서 변경 후 필요한 경우 다음 문서도 함께 일관성 있게 갱신한다.

- `docs/PROJECT_STATUS.md`
- `docs/NEXT_TASKS.md`
- `docs/CODEX_INSTRUCTIONS.md`
- `docs/UI_GUIDELINES.md`
- `docs/ARCHITECTURE.md`

## 9. Git 작업 주의사항

- 사용자가 명시하지 않으면 commit, push, reset, checkout을 수행하지 않는다.
- `git reset --hard`, `git checkout -- <file>` 같은 되돌리기 명령은 사용자가 명확히 요청한 경우에만 사용한다.
- commit 요청을 받으면 먼저 `git status --short`로 변경 범위를 확인한다.
- 관련 없는 변경은 되돌리지 않는다.
- `git add .`는 `.gitignore`가 local scratch/review folder를 제외하는지 확인한 뒤에만 권장한다.

`git add .` 전에 확인할 local scratch/review folder 예:

```text
tmp/
Old_Save/
assets/capture/
```

권장 Git 확인 순서:

```bash
git status --short
git add .
git status --short
git diff --cached --stat
git commit -m "Update project status and task notes"
git log --oneline -5
git push
```

첫 push일 수 있으면 브랜치를 확인한다.

```bash
git branch --show-current
git push -u origin <branch-name>
```

## 10. 작업 후 보고 형식

각 task 완료 후 반드시 다음을 보고한다.

- 변경된 파일 목록
- 변경 요약
- 실행했거나 사용자가 실행할 명령어
- 다음 추천 작업

응답은 간결하게 작성한다. 긴 구현 덤프는 사용자가 요청하지 않으면 포함하지 않는다.
