# CODEX_AUTOMATION_SYSTEM.md

> 목적: BoomCode 프로젝트에서 Codex 사용량을 줄이고, 문서 5개 + MASTER_CONTEXT.md를 기준으로 작업을 끊기지 않게 이어가기 위한 운영 시스템이다.

---

## 1. 전체 운영 구조

```text
문서 5개
  ↓ 압축
MASTER_CONTEXT.md
  ↓ 작업 선택/지시
Codex
  ↓ 코드/문서 수정
PROJECT_STATUS.md / NEXT_TASKS.md / MASTER_CONTEXT.md 업데이트
```

역할:

| 도구 | 역할 |
| --- | --- |
| Web ChatGPT | 문서 분석, 지시서 생성, 작업 전략 수립 |
| Codex | 실제 코드 수정, 파일 생성, 문서 업데이트 |
| VS Code Chat | 간단 질문용 또는 사용하지 않아도 됨 |
| NotebookLM | 문서 전체 흐름 점검용 보조 도구 |

---

## 2. Codex 새 세션 시작 프롬프트

Codex 새 작업을 시작할 때 아래를 그대로 붙여넣는다.

```text
You are the BoomCode project executor.

First read:
1. docs/MASTER_CONTEXT.md
2. docs/NEXT_TASKS.md
3. docs/CODEX_INSTRUCTIONS.md

Then do the following:
1. Select exactly ONE task from NEXT_TASKS.md unless I specify a task.
2. Move the selected task to DOING.
3. Read every target file before editing.
4. Make the smallest safe change.
5. Do not modify unrelated files.
6. Do not run flutter/dart/git commands unless I explicitly allow it.
7. After finishing, update:
   - docs/NEXT_TASKS.md
   - docs/PROJECT_STATUS.md if implementation status changed
   - docs/MASTER_CONTEXT.md

Report only:
- Changed files
- What changed
- Commands I should run
- Next recommended task
```

---

## 3. 특정 작업 지정 프롬프트

```text
Use the project documents and execute only this task:

Task ID:
Task Name:

Rules:
- Modify only files related to this task.
- Read target files first.
- Do not refactor unrelated code.
- Do not run commands unless allowed.
- Update NEXT_TASKS.md and MASTER_CONTEXT.md after completion.
```

---

## 4. 문서만 업데이트시키는 프롬프트

코드를 건드리면 안 될 때 사용한다.

```text
Documentation-only task.

Read the current docs and update only:
- docs/MASTER_CONTEXT.md
- docs/NEXT_TASKS.md
- docs/PROJECT_STATUS.md if needed

Do not modify:
- Dart files
- assets/
- pubspec.yaml
- android/

Goal:
[여기에 문서 정리 목표 작성]
```

---

## 5. 작업 완료 후 Codex에게 시킬 문장

```text
Before you finish, update docs/MASTER_CONTEXT.md:
- Current Active Task
- Latest Result
- Remaining Issues
- User Commands To Run

Also update docs/NEXT_TASKS.md:
- Move completed task from DOING to DONE
- Add follow-up TODO only if necessary
```

---

## 6. 작업 단위 규칙

좋은 작업 단위:

- 한 파일 또는 한 화면 중심
- 30~90분 안에 끝날 수 있는 규모
- UI / logic / asset / document 중 하나만 포함
- 완료 기준이 명확함

나쁜 작업 단위:

- 전체 UI 개선
- 게임 전체 리팩터링
- 모든 화면 반응형 수정
- 앱 완성해줘
- 알아서 정리해줘

---

## 7. Codex 사용량 절약 규칙

- 매번 문서 5개를 전부 붙이지 않는다.
- Codex에게는 `MASTER_CONTEXT.md`를 먼저 읽게 한다.
- 필요한 경우에만 원본 문서 1개를 추가로 읽게 한다.
- 한 세션에서 작업 1개만 수행한다.
- 실패하면 같은 세션에서 계속 크게 수정하지 말고, 로그를 받아 Web ChatGPT에서 새 지시서를 만든다.

---

## 8. Web ChatGPT 사용 루틴

매일 또는 새 작업 전에:

1. 최신 `MASTER_CONTEXT.md`를 ChatGPT에 붙여넣는다.
2. 필요한 경우 `NEXT_TASKS.md`만 추가로 붙여넣는다.
3. 다음 프롬프트를 사용한다.

```text
아래 MASTER_CONTEXT.md를 기준으로 현재 가장 안전한 다음 Codex 작업 1개를 선택하고,
Codex에 붙여넣을 지시서를 만들어줘.

조건:
- 작업 1개만
- 대상 파일 명확히
- 수정 금지 파일 명확히
- 완료 기준 명확히
- Codex 사용량 최소화
```

---

## 9. 장애 발생 시 루틴

### 빌드/실행 문제

1. 사용자가 터미널 로그를 복사한다.
2. Web ChatGPT에 `MASTER_CONTEXT.md + 로그`를 붙여넣는다.
3. ChatGPT가 원인 분류와 Codex 지시서를 만든다.
4. Codex는 관련 파일만 읽고 최소 수정한다.

### UI가 마음에 안 들 때

1. 스크린샷을 Web ChatGPT에 올린다.
2. `MASTER_CONTEXT.md`를 같이 제공한다.
3. ChatGPT가 UI 수정 지시서를 만든다.
4. Codex는 해당 화면 파일만 수정한다.

### 문서가 꼬였을 때

1. 문서 5개를 Web ChatGPT에 올린다.
2. `MASTER_CONTEXT.md`를 재생성한다.
3. Codex에는 새 `MASTER_CONTEXT.md`만 사용한다.

---

## 10. 하루 개발 루틴

```text
1. flutter run 또는 현재 화면 확인
2. 문제/목표 결정
3. Web ChatGPT에 MASTER_CONTEXT.md 제공
4. Codex 지시서 생성
5. Codex 실행
6. 사용자가 flutter analyze/test/run 실행
7. 결과 로그 확인
8. 문서 업데이트 확인
9. Git commit
```

---

## 11. Git 루틴

사용자가 직접 실행 권장:

```bash
git status --short
git add .
git status --short
git diff --cached --stat
git commit -m "Update project docs and task status"
git log --oneline -5
git push
```

첫 push 또는 branch 확인이 필요할 때:

```bash
git branch --show-current
git push -u origin <branch-name>
```

---
