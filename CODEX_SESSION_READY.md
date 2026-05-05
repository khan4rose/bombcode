# Codex 새 창 세션 준비 지시서

**작성일**: 2026-05-05  
**목적**: 새 Codex 창에서 프로젝트 연속성 확보  
**상태**: 세션 시작 전 필독

---

## 1. 반드시 읽을 문서 (순서대로)

Codex 새 세션 시작 시 다음 문서를 이 순서대로 읽어야 합니다:

```
1. docs/PROJECT_STATUS.md        → 현재 구현 완료 상태 파악
2. docs/NEXT_TASKS.md             → 우선순위별 작업 목록 확인
3. docs/CODEX_INSTRUCTIONS.md     → 작업 규칙 & 금지사항 확인
4. docs/ARCHITECTURE.md           → 구조 변경 시 필독
5. docs/UI_GUIDELINES.md          → UI 작업 시 필독
6. docs/BoomCode_Flutter_Codex.md → 프로젝트 콘셉트 및 용어 확인
```

---

## 2. 현재 프로젝트 상황 (2026-05-05 기준)

### 2.1 완료된 영역 ✅

| 영역 | 상태 | 비고 |
|------|------|------|
| Flutter 기본 구조 | 완료 | main.dart, app.dart 진입점 OK |
| Splash 화면 | 완료 | 한/영 자동 선택 |
| Home/Main Menu | 완료 | 공통 배경 + Flutter 렌더링 텍스트 버튼 |
| Mission Setup | 구현됨 | UI polish 필요 |
| Game 로직 | 완료 | Access/Trace 판정, 타이머, 성공/실패 |
| Records 시스템 | 완료 | shared_preferences 기반 |
| 테스트 코드 | 구현됨 | judge_code_test, game_controller_test |

### 2.2 현재 문제점 🔴

| Task | 상태 | 원인 | 영향 |
|------|------|------|------|
| Task 1.0 | TODO | Android viewport metrics 반복 | 앱 자동 종료 |
| Task 1.1 | TODO | flutter analyze/test 경고 | 빌드 품질 |
| Task 2.1+ | BLOCKED | Task 1.0 완료까지 대기 | UI polish 미연기 |

### 2.3 Home 화면 상태 (최종)

```
✅ English/Korean 텍스트를 Flutter Text로 렌더링
✅ Start Game은 red primary button
✅ 다른 메인 버튼은 dark secondary button
✅ Start Game과 Difficulty 사이 gap 없음
✅ Records/Settings는 작은 responsive gap
✅ 하단 icon-only 보조 메뉴 (utility buttons)
✅ Currency panel은 blank frame (미래용)
✅ Exit 버튼 제거됨

⚠️  이 상태에서 Android emulator viewport metrics 반복 문제 발생
    (원인 미확인, 조사 필요)
```

---

## 3. 다음 작업: Task 1.0 Android Viewport Metrics 문제 해결

### 3.1 작업 목표

```
Android Emulator 실행 중 다음 문제 확인 및 해결:
- WindowInsets changed
- FlutterJNI: Sending viewport metrics (반복)
- Lost connection to device
- 앱 자동 종료
```

### 3.2 현재 메모

```
• Home 화면 하단 icon-only 버튼 전환 이후 문제 발생
• SafeArea(bottom: false) 시도했으나 미해결
• MediaQuery.removePadding(removeBottom: true) 시도했으나 미해결
• 하단 icon asset: 196x196 투명 PNG
• 코드에서 터치 영역과 보이는 size 분리됨
```

### 3.3 Codex 작업 체크리스트

**준비 단계:**
- [ ] 사용자가 제공할 `flutter analyze` 결과 확인
- [ ] 사용자가 제공할 `flutter run -v` verbose 로그 또는 Android logcat 확인

**진단 단계:**
- [ ] Home 화면 코드 (`lib/features/home/home_screen.dart`) 완전히 읽기
- [ ] 하단 icon buttons 부분 분석 (배치, 크기, 패딩, 마진)
- [ ] layout 계산이 viewport/insets 변화에 민감한지 검토
- [ ] `SafeArea` 사용 방식 재검토
- [ ] `LayoutBuilder` 크기 계산 로직 재검토

**수정 대상 검토:**
- [ ] Flutter 코드 문제인지 Android 설정 문제인지 판단
- [ ] 필요 시 Home UI 최소 수정 계획 수립
- [ ] 필요 시 Android manifest/theme 최소 수정 계획 수립

**수정 실행:**
- [ ] 필요한 코드/설정 수정 (최소 범위)
- [ ] 빌드 테스트
- [ ] 문제 재현 확인

### 3.4 수정 금지 사항 🚫

다음 영역은 Task 1.0과 무관하므로 수정하지 않음:

```
❌ lib/features/game/              (게임 로직)
❌ lib/core/utils/judge_code.dart (판정 로직)
❌ lib/domain/                     (데이터 모델)
❌ lib/data/                       (저장소)
❌ 난이도 기본값
❌ 광고/코인/상점 로직
❌ assets/ 직접 삭제
```

### 3.5 사용자가 실행할 명령어

Codex가 제시할 수정안 후 사용자가 실행:

```bash
# 정리
flutter clean

# 의존성 재설치
flutter pub get

# 형식 검사
dart format .

# 정적 분석 (문제 확인)
flutter analyze

# 빌드 테스트 (Android 타깃)
flutter run -v

# 또는 이뮬레이터에서 직접 테스트
flutter run
```

---

## 4. 문서 핵심 정리

### 4.1 핵심 용어 (절대 사용)

| 용어 | 의미 | 사용처 | 금지 용어 |
|------|------|--------|----------|
| **Access** | 숫자 + 위치 모두 맞음 | UI, 코드, 주석 | Strike |
| **Trace** | 숫자만 맞음, 위치 다름 | UI, 코드, 주석 | Ball |

### 4.2 난이도 기본값 (변경 금지)

```dart
Beginner: 2자리 코드, 기본 20시도
Normal:   3자리 코드, 기본 12시도
Expert:   4자리 코드, 기본 7시도
```

### 4.3 UI 규칙

```
기준 해상도: 360 x 800 dp
레이아웃: SafeArea + LayoutBuilder (반응형)
공통 배경: assets/menu/background.png
스타일: Dark sci-fi industrial
폰트: 크게, 명확하게
색상: 검정, metallic gray, red/cyan/yellow 강조
```

### 4.4 Codex 작업 원칙

```
1. 파일 수정 전 현재 내용 먼저 읽기
2. 요청된 작업만 최소한으로 수정
3. 새 파일 생성은 필요할 때만
4. 게임 로직/asset 무분별 변경 금지
5. flutter run/build/test/analyze 직접 실행 금지
   (사용자 허용 시에만)
6. 작업 완료 후 변경 파일/내용/명령어 보고
```

---

## 5. 파일 구조 빠른 참조

```
lib/
├── main.dart                      (앱 시작)
├── app.dart                       (theme, root)
├── core/
│   ├── constants/                 (색상, 텍스트, 상수)
│   ├── utils/                     (생성기, 판정, 반응형)
│   └── widgets/                   (공통 위젯)
├── data/                          (저장소)
├── domain/                        (모델, enum)
└── features/
    ├── splash/                    (스플래시)
    ├── home/                      (메인 메뉴) ⚠️ Task 1.0 대상
    ├── mode_select/               (미션 셋업)
    ├── game/                      (게임 로직)
    ├── records/                   (기록)
    ├── settings/                  (설정)
    └── tutorial/                  (튜토리얼)
```

---

## 6. Codex 세션 시작 체크리스트

새 Codex 세션이 시작되면 아래를 확인:

```
□ 문서 6개 읽기 완료
□ 현재 상황 이해 (완료/진행/미구현)
□ 다음 작업 확인 (Task 1.0)
□ 용어 규칙 확인 (Access/Trace)
□ 금지 사항 확인
□ 파일 구조 파악
□ 준비 완료 → 사용자 대기
```

---

## 7. 빠른 문제 해결 가이드

### 문제: "어느 파일을 수정해야 하나?"
→ 먼저 `ARCHITECTURE.md`의 구조 확인 후, 해당 파일 읽기

### 문제: "이 코드를 수정해도 될까?"
→ `CODEX_INSTRUCTIONS.md`의 "수정 금지" 섹션 확인

### 문제: "UI를 어떻게 만들어야 하나?"
→ `UI_GUIDELINES.md` 확인

### 문제: "다음 작업이 뭐지?"
→ `NEXT_TASKS.md`의 우선순위 확인

### 문제: "현재 상태가 뭐지?"
→ `PROJECT_STATUS.md`의 완료/미구현 표 확인

---

## 8. 연락처 & 피드백

이 문서가 최신이 아니거나 불명확한 부분이 있으면:

```
1. docs/ 폴더의 최신 문서 확인
2. 사용자에게 상황 보고
3. 명확한 요청 받은 후 진행
```

---

**지시서 완료. Codex 준비됨!**
