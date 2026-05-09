# WEB_CHATGPT_USAGE_GUIDE.md

> 목적: 문서 5개와 MASTER_CONTEXT.md를 Web ChatGPT에서 어떻게 활용해 Codex 개발을 효율적으로 진행할지 설명한다.

---

## 1. 핵심 원칙

매번 문서 5개 전체를 올리지 않는다.

기본 구조:

```text
항상: MASTER_CONTEXT.md
필요할 때만: NEXT_TASKS.md / UI_GUIDELINES.md / ARCHITECTURE.md / PROJECT_STATUS.md / CODEX_INSTRUCTIONS.md
```

---

## 2. 언제 어떤 문서를 ChatGPT에 올릴까?

| 상황 | ChatGPT에 올릴 문서 |
| --- | --- |
| 다음 작업 선택 | `MASTER_CONTEXT.md` + `NEXT_TASKS.md` |
| UI 수정 지시서 작성 | `MASTER_CONTEXT.md` + `UI_GUIDELINES.md` + 스크린샷 |
| 구조 변경/파일 분리 | `MASTER_CONTEXT.md` + `ARCHITECTURE.md` |
| 현재 상태 재정리 | 문서 5개 전체 |
| Codex 행동 규칙 재정비 | `MASTER_CONTEXT.md` + `CODEX_INSTRUCTIONS.md` |
| 빌드/분석 에러 해결 | `MASTER_CONTEXT.md` + 에러 로그 |
| 문서가 오래되었거나 꼬임 | 문서 5개 전체로 `MASTER_CONTEXT.md` 재생성 |

---

## 3. Web ChatGPT 기본 프롬프트

```text
아래 MASTER_CONTEXT.md를 기준으로 Codex에 전달할 지시서를 만들어줘.

목표:
[내가 원하는 작업]

조건:
- 작업 1개만
- 대상 파일 명확히
- 수정 금지 파일 명확히
- 완료 기준 명확히
- Codex가 불필요하게 전체 프로젝트를 분석하지 않도록 짧게
- 작업 후 MASTER_CONTEXT.md와 NEXT_TASKS.md 업데이트 지시 포함

[MASTER_CONTEXT.md 붙여넣기]
```

---

## 4. UI 작업용 프롬프트

```text
아래 MASTER_CONTEXT.md와 UI_GUIDELINES.md, 그리고 스크린샷을 기준으로
Codex에 줄 UI 수정 지시서를 만들어줘.

조건:
- UI-only 작업
- game logic 수정 금지
- non-scroll 유지
- LayoutBuilder / SafeArea 유지
- 공통 배경 유지
- 대상 파일과 수정 금지 파일 명확히

[MASTER_CONTEXT.md]
[UI_GUIDELINES.md]
[스크린샷 또는 문제 설명]
```

---

## 5. 에러 해결용 프롬프트

```text
아래 MASTER_CONTEXT.md와 터미널 로그를 보고,
Codex가 최소 수정으로 해결할 수 있는 지시서를 만들어줘.

조건:
- 원인 후보를 먼저 분류
- 수정 대상 파일을 최대한 좁힘
- 관련 없는 리팩터 금지
- 사용자가 실행할 명령어도 포함

[MASTER_CONTEXT.md]
[터미널 로그]
```

---

## 6. 문서 5개 전체를 올려야 하는 경우

다음 경우에는 문서 5개 전체를 올려도 된다.

- 프로젝트 상태가 꼬였을 때
- 여러 Codex 세션이 지나서 MASTER_CONTEXT.md가 부정확해졌을 때
- 구조가 크게 바뀌었을 때
- 새 단계로 넘어갈 때
- 문서 간 내용이 충돌할 때

이때 ChatGPT에게 이렇게 요청한다:

```text
아래 문서 5개를 분석해서 최신 MASTER_CONTEXT.md를 다시 만들어줘.

조건:
- 실제 구현된 것과 예정된 것을 분리
- 현재 이슈와 다음 작업을 명확히
- Codex가 바로 읽고 실행할 수 있게 압축
- 중복 제거
- 보호 파일/수정 금지 규칙 유지

[문서 5개 붙여넣기]
```

---

## 7. Codex에 붙여넣기 전 체크리스트

ChatGPT가 만든 지시서에 다음이 들어 있는지 확인한다.

- [ ] 작업 이름
- [ ] 대상 파일
- [ ] 변경 내용
- [ ] 수정 금지 파일
- [ ] 완료 기준
- [ ] 문서 업데이트 지시
- [ ] 명령어 실행 금지 또는 허용 여부

---

## 8. 추천 개발 순서

현재 문서 기준 추천 순서:

1. Android viewport metrics / 자동 종료 원인 확인
2. `flutter analyze` / `flutter test` 이슈 수정
3. Main Menu 최종 visual QA
4. Mission Setup layout fine tuning
5. Mission Setup widget 분리
6. Game Screen asset list 정의
7. Game Screen assets 생성
8. Game Screen design 적용

단, 앱 실행이 불안정하면 UI polish보다 안정화가 먼저다.

---

## 9. 하루 작업 예시

### 아침/시작

- `MASTER_CONTEXT.md`를 ChatGPT에 붙여넣기
- 오늘 할 작업 1개 선택 요청
- Codex 지시서 받기

### 작업 중

- Codex에 지시서 붙여넣기
- 수정 후 사용자가 `dart format .`, `flutter analyze`, `flutter test`, `flutter run` 실행
- 에러 있으면 로그를 ChatGPT에 붙여넣기

### 작업 끝

- Codex가 문서 업데이트했는지 확인
- Git commit
- 다음 작업 후보만 남기기

---

## 10. 가장 중요한 운영 규칙

```text
ChatGPT는 판단과 지시서 작성.
Codex는 실행과 문서 업데이트.
문서 5개는 원본 기록.
MASTER_CONTEXT.md는 매일 쓰는 압축 기억.
```

---
