# BoomCode Flutter 재개발 Codex 지시서

> 목적: 기존 Android/Kotlin 방향으로 정리했던 4자리 비밀번호 추리 게임 **BoomCode**를 Flutter로 다시 구현한다.  
> 핵심 변경: 야구게임 느낌을 없애기 위해 `Strike/Ball` 용어를 사용하지 않고, 해커/암호 해독 느낌의 `Access/Trace`를 사용한다.  
> 추가 변경: 기존 횟수 제한에 더해 **시간 제한**을 추가하고, 사용자가 `횟수 제한만`, `시간 제한만`, `횟수+시간 제한 둘 다` 선택할 수 있게 만든다.

---

## 0. Codex 작업 원칙

이 문서는 Codex에게 그대로 전달할 개발 지시서다.

Codex는 아래 원칙을 반드시 따른다.

1. Flutter 프로젝트 기준으로 작성한다.
2. Android 우선 출시를 목표로 한다.
3. 광고, 로그인, 서버, 온라인 랭킹, 결제 검증 기능은 1차 MVP에서 제외한다.
4. 모든 데이터는 기기 내부에만 저장한다.
5. 어린이도 할 수 있는 전 연령 게임으로 만든다.
6. 폭력, 도박, 성인 요소는 넣지 않는다.
7. 글씨는 크게, 버튼은 누르기 쉽게, 색상만으로 정보를 구분하지 않게 만든다.
8. 기능 추가보다 1차 출시 가능한 완성도를 우선한다.
9. 코드 수정 전후에는 항상 빌드/실행 가능한 상태를 유지한다.
10. 막히면 `원인 - 해결 - 재발방지`를 기록한다.

---

## 1. 앱 개요

### 앱 이름

- 영어명: **BoomCode**
- 한글명 후보: **붐코드** 또는 **폭탄코드**

### 장르

- 숫자 암호 추리 퍼즐
- 오프라인 싱글 플레이
- 논리 추론 게임

### 콘셉트

플레이어는 해커 또는 암호 해독가가 되어 숨겨진 숫자 코드를 찾아낸다.  
정답 코드는 0~9 숫자로 구성되며, 각 시도 후 시스템이 `Access`와 `Trace` 힌트를 제공한다.  
플레이어는 힌트를 분석해 가능한 숫자와 위치를 좁혀 최종 코드를 해독한다.

### 한 줄 설명

숨겨진 숫자 코드를 입력하고, `Access/Trace` 힌트를 분석해 제한 조건 안에서 암호를 해독하는 오프라인 논리 퍼즐 게임.

---

## 2. 기존 규칙 정리

### 기본 규칙

1. 정답은 숫자로만 구성한다.
2. 숫자는 0~9를 사용한다.
3. 같은 숫자는 중복 사용하지 않는다.
4. 첫 번째 자리에 0이 올 수 있다. 예: `0123` 가능.
5. 플레이어 입력도 중복 숫자를 허용하지 않는다.
6. 숫자 외 문자 입력은 원천 차단한다.
7. 텍스트 입력창보다 숫자 버튼 선택 방식을 우선한다.
8. 정답을 맞히면 게임 클리어다.
9. 제한 조건을 초과하면 게임 오버다.
10. 다시 시작하면 같은 난이도와 같은 제한 옵션으로 새 정답을 생성한다.

---

## 3. 용어 변경: Strike/Ball 금지

### 절대 사용 금지 용어

앱 화면, 코드 주석, 변수명, 문자열 리소스에서 아래 용어를 사용하지 않는다.

- Strike
- Ball
- S
- B
- 스트라이크
- 볼
- 숫자야구
- baseball

단, 내부 개발 문서에서 과거 규칙을 설명할 때만 예외적으로 언급할 수 있으나 실제 앱 코드에는 넣지 않는다.

### 새 용어

| 기존 의미 | 새 용어 | 약어 | 설명 |
|---|---|---|---|
| 숫자와 위치가 모두 맞음 | Access | A | 코드의 해당 위치까지 정확히 접근 성공 |
| 숫자는 맞지만 위치가 다름 | Trace | T | 코드 안에 존재하는 흔적은 찾았지만 위치는 다름 |

### UI 표시 예시

- `2 Access / 1 Trace`
- `Access 2 · Trace 1`
- `A2 / T1`
- 한국어 보조 설명: `위치 일치 2개 · 숫자만 일치 1개`

### 추천 화면 표시

초보자에게는 처음부터 `A/T`만 보여주지 말고 아래처럼 함께 표시한다.

```text
Access 2  |  Trace 1
위치까지 맞은 숫자 2개 / 숫자는 있지만 위치가 다른 숫자 1개
```

중급 이상 또는 설정에서 간단 표시를 선택하면 다음처럼 표시한다.

```text
A2 / T1
```

---

## 4. Access / Trace 판정 로직

### 정의

- `Access`: 입력 숫자와 정답 숫자가 같은 위치에 있을 때 증가한다.
- `Trace`: 입력 숫자가 정답 안에 존재하지만 위치가 다를 때 증가한다.
- 한 숫자는 Access와 Trace에 동시에 포함될 수 없다.
- 정답과 입력 모두 중복 숫자가 없으므로 판정은 단순하게 처리한다.

### 예시

정답: `1234`

| 입력 | 결과 | 설명 |
|---|---:|---|
| 1234 | Access 4 / Trace 0 | 완전 일치 |
| 1243 | Access 2 / Trace 2 | 1,2 위치 일치 / 3,4 위치 다름 |
| 5678 | Access 0 / Trace 0 | 포함 숫자 없음 |
| 4321 | Access 0 / Trace 4 | 숫자는 모두 있으나 위치가 다름 |
| 1035 | Access 1 / Trace 1 | 1은 위치 일치, 3은 위치 다름 |

### Dart 함수 요구사항

Codex는 아래 형태의 순수 함수를 만든다.

```dart
class JudgeResult {
  final int access;
  final int trace;

  const JudgeResult({required this.access, required this.trace});
}

JudgeResult judgeCode({
  required List<int> answer,
  required List<int> guess,
}) {
  // TODO: 구현
}
```

필수 테스트 케이스:

```dart
answer 1234, guess 1234 => access 4, trace 0
answer 1234, guess 1243 => access 2, trace 2
answer 1234, guess 5678 => access 0, trace 0
answer 1234, guess 4321 => access 0, trace 4
answer 1234, guess 1035 => access 1, trace 1
```

---

## 5. 제한 옵션 설계

기존에는 횟수 제한 중심이었으나, Flutter 버전에서는 시간 제한을 추가한다.

### 제한 옵션 모드

사용자는 게임 시작 전 제한 방식을 선택할 수 있다.

| 모드 | 설명 | 게임 오버 조건 |
|---|---|---|
| Attempts Only | 횟수 제한만 사용 | 남은 시도 횟수 0 |
| Time Only | 시간 제한만 사용 | 남은 시간 0초 |
| Attempts + Time | 횟수와 시간 둘 다 사용 | 둘 중 하나라도 0이 되면 실패 |

### 내부 enum

```dart
enum LimitMode {
  attemptsOnly,
  timeOnly,
  attemptsAndTime,
}
```

### 게임 상태 예시

```dart
class GameConfig {
  final Difficulty difficulty;
  final int codeLength;
  final int? maxAttempts;
  final Duration? timeLimit;
  final LimitMode limitMode;
  final bool autoCheckTable;

  const GameConfig({
    required this.difficulty,
    required this.codeLength,
    required this.maxAttempts,
    required this.timeLimit,
    required this.limitMode,
    required this.autoCheckTable,
  });
}
```

### 제한 로직 규칙

1. `attemptsOnly`:
   - `maxAttempts`는 null이면 안 된다.
   - `timeLimit`은 null이어도 된다.
   - 게임 화면에는 남은 횟수를 크게 표시한다.
   - 시간 타이머는 표시하지 않는다.

2. `timeOnly`:
   - `timeLimit`은 null이면 안 된다.
   - `maxAttempts`는 null이어도 된다.
   - 게임 화면에는 남은 시간을 크게 표시한다.
   - 시도 횟수는 기록용으로만 표시할 수 있다.
   - 시도 횟수 때문에 게임 오버되면 안 된다.

3. `attemptsAndTime`:
   - `maxAttempts`와 `timeLimit` 모두 null이면 안 된다.
   - 남은 횟수와 남은 시간을 모두 표시한다.
   - 둘 중 하나라도 먼저 0이 되면 게임 오버다.

### 게임 오버 우선순위

1. 먼저 정답 여부를 판정한다.
2. 정답이면 즉시 성공 처리한다.
3. 정답이 아니면 시도 횟수를 차감한다.
4. 이후 제한 조건을 검사한다.
5. 타이머가 0이 되는 순간에도 제한 조건을 검사한다.
6. 실패 원인은 명확히 저장한다.

```dart
enum GameOverReason {
  solved,
  attemptsExhausted,
  timeExpired,
}
```

---

## 6. 난이도 설계

초기 MVP에서는 3단계 난이도를 제공한다.  
단, 기존 대화에서 2자리~4자리 확장 가능성이 있었으므로 구조는 확장 가능하게 만든다.

### MVP 난이도

| 난이도 | 코드 길이 | 횟수 제한 기본값 | 시간 제한 기본값 | Check Table |
|---|---:|---:|---:|---|
| Beginner | 4자리 | 20회 | 5분 | 자동 |
| Normal | 4자리 | 12회 | 3분 | 자동 또는 수동 선택 |
| Expert | 4자리 | 7회 | 2분 | 수동 |

### 추후 확장 후보

| 모드 | 코드 길이 | 설명 |
|---|---:|---|
| Training | 2자리 | 완전 초보 연습 |
| Easy | 3자리 | 초등학생/초보자용 |
| Classic | 4자리 | 기본 게임 |

MVP에서는 화면 복잡도를 줄이기 위해 4자리 3난이도를 우선한다.  
2자리/3자리 모드는 코드 구조만 확장 가능하게 설계하고 출시 후 추가한다.

---

## 7. 화면 구성

### 7.1 Home Screen

필수 요소:

- BoomCode 로고
- `Start Mission` 버튼
- `Tutorial` 버튼
- `Records` 버튼
- `Settings` 버튼
- 한글/영문 대응 가능한 문자열 구조

주의:

- 배경은 너무 어둡거나 산만하지 않게 한다.
- 해커 느낌은 살리되 어린이도 무섭지 않게 만든다.
- 폭탄 콘셉트는 과격하지 않게 상징적으로만 사용한다.

### 7.2 Mode Select Screen

플레이어가 다음을 선택한다.

1. 난이도
2. 제한 방식
   - Attempts Only
   - Time Only
   - Attempts + Time
3. Check Table 방식
   - 자동
   - 수동

초보자는 기본값을 제공한다.

기본 추천:

- Beginner: Attempts Only, 20회, 자동 Check Table
- Normal: Attempts + Time, 12회, 3분, 자동
- Expert: Attempts + Time, 7회, 2분, 수동

### 7.3 Game Screen

필수 요소:

- 상단: 난이도 / 제한 모드
- 남은 횟수 표시
- 남은 시간 표시
- 현재 입력 코드 슬롯 4개
- 숫자 키패드 0~9
- Delete 버튼
- Submit 버튼
- 입력 이력 리스트
- 각 이력에 `Access / Trace` 결과 표시
- Check Table 영역
- Pause 버튼

### 7.4 Result Screen

성공 시:

- `CODE UNLOCKED`
- 정답 코드 표시
- 사용 시도 횟수
- 걸린 시간
- 난이도
- 제한 모드
- 최고 기록 갱신 여부
- 다시 하기
- 홈으로

실패 시:

- `ACCESS DENIED`
- 실패 원인 표시
  - 횟수 소진
  - 시간 종료
- 정답 코드 공개 여부는 설정 가능하게 하되 MVP에서는 공개한다.
- 다시 하기
- 홈으로

---

## 8. Check Table / 메모 기능

### 목적

플레이어가 각 숫자 0~9의 가능성을 추론할 수 있게 돕는다.

### 상태값

```dart
enum DigitMark {
  unknown,
  possible,
  impossible,
  accessCandidate,
  traceCandidate,
}
```

### 자동 Check Table

Beginner에서는 시스템이 자동으로 힌트를 반영한다.

예:

- 입력 결과가 `Access 0 / Trace 0`이면 해당 입력 숫자들은 `impossible`로 표시한다.
- Access/Trace가 있는 숫자는 `possible` 또는 `traceCandidate`로 표시한다.

주의:

자동 추론은 너무 복잡하게 만들지 않는다.  
1차 MVP에서는 완벽한 논리 엔진보다 학습 보조 기능으로 충분하다.

### 수동 Check Table

Expert에서는 사용자가 직접 숫자를 탭해서 상태를 바꿀 수 있다.

탭 순서 예시:

`unknown -> possible -> impossible -> accessCandidate -> traceCandidate -> unknown`

색상만으로 구분하지 말고 아이콘/텍스트를 함께 표시한다.

---

## 9. 데이터 저장

MVP에서는 로컬 저장만 사용한다.

추천 패키지:

- `shared_preferences`

저장 항목:

```dart
class GameRecord {
  final Difficulty difficulty;
  final LimitMode limitMode;
  final int codeLength;
  final int attemptsUsed;
  final int? maxAttempts;
  final int elapsedSeconds;
  final int? timeLimitSeconds;
  final DateTime playedAt;
  final bool success;
}
```

기록 화면 표시:

- 난이도별 최고 기록
- 최소 시도 성공 기록
- 최단 시간 성공 기록
- 최근 플레이 기록

정렬 기준:

1. 성공 기록 우선
2. 시도 횟수 적은 순
3. 시간이 짧은 순

---

## 10. Flutter 프로젝트 구조

Codex는 아래 구조를 기준으로 파일을 생성/정리한다.

```text
lib/
  main.dart
  app.dart
  core/
    constants/
      app_strings.dart
      app_colors.dart
    utils/
      code_generator.dart
      judge_code.dart
      timer_formatter.dart
  domain/
    enums/
      difficulty.dart
      limit_mode.dart
      game_status.dart
      game_over_reason.dart
      digit_mark.dart
    models/
      game_config.dart
      guess_record.dart
      judge_result.dart
      game_record.dart
  data/
    record_repository.dart
    local_record_repository.dart
  features/
    home/
      home_screen.dart
    mode_select/
      mode_select_screen.dart
    game/
      game_screen.dart
      game_controller.dart
      widgets/
        code_slots.dart
        number_keypad.dart
        limit_status_bar.dart
        guess_history_list.dart
        check_table.dart
    tutorial/
      tutorial_screen.dart
    records/
      records_screen.dart
    settings/
      settings_screen.dart
```

상태 관리는 MVP에서는 `ChangeNotifier` 또는 `ValueNotifier`로 단순하게 시작한다.  
규모가 커지면 Riverpod으로 변경할 수 있지만, 현재는 과한 구조를 피한다.

---

## 11. 핵심 클래스 설계

### Difficulty

```dart
enum Difficulty {
  beginner,
  normal,
  expert,
}
```

### GuessRecord

```dart
class GuessRecord {
  final List<int> guess;
  final JudgeResult result;
  final int attemptNumber;
  final int elapsedSeconds;

  const GuessRecord({
    required this.guess,
    required this.result,
    required this.attemptNumber,
    required this.elapsedSeconds,
  });
}
```

### GameStatus

```dart
enum GameStatus {
  ready,
  playing,
  paused,
  success,
  failed,
}
```

### GameController 필수 기능

```dart
class GameController extends ChangeNotifier {
  // 상태
  // answer
  // currentGuess
  // history
  // remainingAttempts
  // remainingSeconds
  // status
  // gameOverReason

  void start(GameConfig config);
  void pause();
  void resume();
  void inputDigit(int digit);
  void deleteDigit();
  void submitGuess();
  void restartSameConfig();
  void tickOneSecond();
}
```

주의:

- `submitGuess()`에서 입력이 완성되지 않았으면 제출 불가.
- 중복 숫자는 버튼 단계에서 비활성화한다.
- 이미 입력한 숫자는 다시 누를 수 없게 한다.
- 게임 종료 후에는 입력을 막는다.
- 일시정지 중에는 타이머를 멈춘다.

---

## 12. 타이머 구현 지시

Flutter에서는 `Timer.periodic`을 사용한다.

필수 규칙:

1. GameController가 dispose될 때 Timer를 반드시 cancel한다.
2. pause 상태에서는 시간이 줄어들지 않는다.
3. success/failed 상태에서는 Timer를 cancel한다.
4. timeOnly 또는 attemptsAndTime일 때만 Timer를 시작한다.
5. attemptsOnly에서는 Timer를 시작하지 않는다.
6. 화면 회전은 MVP에서 세로 고정 권장.

---

## 13. UX / 접근성 지시

### 글씨 크기

- 주요 숫자: 28sp 이상
- 버튼 숫자: 24sp 이상
- 일반 설명: 16sp 이상

### 버튼

- 최소 터치 영역 48dp 이상
- 숫자 버튼 간격 충분히 확보
- Delete와 Submit은 실수 방지 위해 명확히 구분

### 색약 배려

색상만으로 상태를 표현하지 않는다.

예:

- 가능: `?`
- 제외: `X`
- 위치 후보: `A`
- 흔적 후보: `T`

### 어린이 친화

- 실패 문구는 자극적이지 않게 한다.
- `ACCESS DENIED` 아래에는 `다시 도전하면 됩니다!` 같은 부드러운 문구를 넣는다.
- 과한 폭발 이미지나 공포감 있는 사운드는 사용하지 않는다.

---

## 14. 문자열 리소스 방향

Flutter MVP에서는 `AppStrings` 클래스로 시작한다.  
추후 `flutter_localizations`와 ARB 파일로 확장한다.

필수 문자열:

```dart
class AppStrings {
  static const appName = 'BoomCode';
  static const startMission = 'Start Mission';
  static const tutorial = 'Tutorial';
  static const records = 'Records';
  static const settings = 'Settings';
  static const access = 'Access';
  static const trace = 'Trace';
  static const codeUnlocked = 'CODE UNLOCKED';
  static const accessDenied = 'ACCESS DENIED';
  static const attemptsOnly = 'Attempts Only';
  static const timeOnly = 'Time Only';
  static const attemptsAndTime = 'Attempts + Time';
}
```

한글 버전도 고려하되, 코드 내부 기본 키는 영어로 유지한다.

---

## 15. 튜토리얼 구성

튜토리얼은 4~5페이지로 구성한다.

1. 목표 설명
   - 숨겨진 코드를 찾는 게임
2. Access 설명
   - 숫자와 위치가 모두 맞음
3. Trace 설명
   - 숫자는 있지만 위치가 다름
4. 입력과 기록
   - 시도 이력을 보고 추론
5. 제한 조건
   - 횟수 제한, 시간 제한, 둘 다 가능

튜토리얼 예시 문구:

```text
Access는 숫자와 위치가 모두 맞았다는 뜻입니다.
Trace는 숫자는 코드 안에 있지만 위치가 다르다는 뜻입니다.
```

---

## 16. 테스트 지시

Codex는 최소한 아래 테스트를 작성하거나 수동 검증 목록으로 남긴다.

### 로직 테스트

- 정답 생성 시 중복 숫자가 없는가?
- 첫 자리에 0이 올 수 있는가?
- 입력에서 중복 숫자가 막히는가?
- Access/Trace 판정이 정확한가?
- Attempts Only에서 횟수 0이면 실패하는가?
- Time Only에서 시간 0이면 실패하는가?
- Attempts + Time에서 둘 중 하나라도 0이면 실패하는가?
- 정답을 맞히면 제한 조건보다 성공 판정이 우선인가?
- 일시정지 중 타이머가 멈추는가?
- 게임 종료 후 타이머가 멈추는가?

### UI 테스트

- 작은 화면에서도 버튼이 잘리는가?
- 숫자 버튼이 충분히 큰가?
- Access/Trace가 야구게임처럼 보이지 않는가?
- 색상을 보지 않아도 상태를 알 수 있는가?
- 어린이가 읽기 쉬운가?

---

## 17. Codex 작업 순서

Codex는 아래 순서대로 작업한다.

### 1단계: 프로젝트 기본 구조 생성

- Flutter 기본 앱 정리
- 폴더 구조 생성
- Home Screen 작성
- 테마 기본 설정

### 2단계: 도메인 모델/로직 구현

- Difficulty
- LimitMode
- GameStatus
- GameOverReason
- JudgeResult
- GameConfig
- GuessRecord
- code generator
- judgeCode 함수

### 3단계: GameController 구현

- 게임 시작
- 숫자 입력
- 삭제
- 제출
- 판정
- 성공/실패 처리
- 제한 조건 처리
- 타이머 처리

### 4단계: Game Screen 구현

- 코드 슬롯
- 숫자 키패드
- 제한 상태바
- 입력 기록 리스트
- Check Table

### 5단계: Mode Select 구현

- 난이도 선택
- 제한 방식 선택
- 자동/수동 Check Table 선택
- 선택값으로 GameConfig 생성

### 6단계: Tutorial / Records / Settings 구현

- 튜토리얼 화면
- 로컬 기록 저장
- 기록 화면
- 설정 화면 기초

### 7단계: 테스트 및 정리

- 불필요한 코드 제거
- 문자열 정리
- 빌드 확인
- Android 에뮬레이터 실행 확인

---

## 18. 현재 MVP 범위

### 반드시 포함

- 오프라인 플레이
- 4자리 코드
- 중복 숫자 금지
- 첫 자리 0 허용
- Access/Trace 판정
- 난이도 3단계
- 횟수 제한
- 시간 제한
- 횟수/시간 제한 모드 선택
- 튜토리얼
- 최고 기록/최소 시도/최단 시간 저장
- 자동/수동 Check Table 기초

### 제외

- 광고
- 로그인
- 서버
- 온라인 랭킹
- 인앱 결제
- 소셜 공유
- 복잡한 AI 힌트
- 5자리 이상 모드
- 화려한 애니메이션 과다 사용

---

## 19. 완료 기준

Codex 작업 완료 기준은 다음과 같다.

1. `flutter run`으로 Android 에뮬레이터에서 실행된다.
2. 홈 화면에서 게임 시작이 가능하다.
3. 난이도와 제한 모드를 선택할 수 있다.
4. 게임 화면에서 숫자 입력/삭제/제출이 가능하다.
5. Access/Trace 결과가 정확히 표시된다.
6. Attempts Only 모드가 정상 작동한다.
7. Time Only 모드가 정상 작동한다.
8. Attempts + Time 모드가 정상 작동한다.
9. 성공/실패 화면이 표시된다.
10. 기록이 기기 내부에 저장된다.
11. 앱 화면 어디에도 Strike/Ball/숫자야구 느낌의 용어가 나오지 않는다.

---

## 20. Codex에게 줄 첫 작업 명령 예시

아래 문장을 Codex에 붙여넣고 시작한다.

```text
이 Flutter 프로젝트를 BoomCode 게임으로 구현해줘.
첨부한 Markdown 지시서를 기준으로 작업해.
먼저 lib 폴더 구조를 만들고, Access/Trace 판정 로직과 GameController부터 구현해줘.
Strike/Ball 용어는 앱 코드와 UI에서 절대 사용하지 마.
제한 옵션은 attemptsOnly, timeOnly, attemptsAndTime 세 가지 enum으로 만들고,
횟수 제한만, 시간 제한만, 둘 다 제한하는 로직을 모두 구현해줘.
작업 후 변경한 파일 목록과 다음 작업 체크리스트를 알려줘.
```

---

## 21. 다음 작업 체크리스트

- [ ] Flutter 프로젝트 폴더 확인
- [ ] `lib` 구조 생성
- [ ] 도메인 enum/model 생성
- [ ] `judgeCode()` 구현
- [ ] `generateAnswer()` 구현
- [ ] `GameController` 구현
- [ ] 제한 모드 로직 구현
- [ ] 타이머 cancel/dispose 처리
- [ ] Home Screen 구현
- [ ] Mode Select Screen 구현
- [ ] Game Screen 구현
- [ ] Result Screen 구현
- [ ] Tutorial Screen 구현
- [ ] Records 저장 구현
- [ ] Android 에뮬레이터 실행 테스트
