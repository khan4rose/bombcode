# CODEX_PROMPT_PACK.md

> 목적: Web ChatGPT에서 만든 지시서를 Codex에 붙여넣을 때 사용하는 실전 프롬프트 모음이다.

---

## 1. 기본 실행 프롬프트

```text
You are the BoomCode project executor.

Read docs/MASTER_CONTEXT.md first.
Then execute the task below.

[Task]
작업명:

[Target Files]
-

[Changes]
-

[Constraints]
- Do not modify unrelated files.
- Do not run commands unless explicitly allowed.
- Keep non-scroll layout if this is a main/menu/setup/game screen.
- Preserve existing game logic unless this is a logic task.

[Done Definition]
-
```

---

## 2. UI 작업 프롬프트

```text
UI-only task.

Read:
- docs/MASTER_CONTEXT.md
- docs/UI_GUIDELINES.md
- target file

Task:
[화면/파일명] UI를 아래 기준으로 수정한다.

Target File:
-

Required Changes:
-

Must Keep:
- Common background: assets/menu/background.png
- AppBackground usage if already used
- SafeArea / LayoutBuilder responsive structure
- Non-scroll screen structure unless impossible
- Flutter-rendered text

Do Not Modify:
- lib/features/game/game_controller.dart
- lib/core/utils/judge_code.dart
- lib/domain/models/game_config.dart
- unrelated assets
- android/

After finishing:
- Update docs/MASTER_CONTEXT.md
- Update docs/NEXT_TASKS.md
```

---

## 3. 디버깅 작업 프롬프트

```text
Debug task.

Read:
- docs/MASTER_CONTEXT.md
- docs/NEXT_TASKS.md
- files mentioned in the error log

Problem Log:
[여기에 에러 로그 붙여넣기]

Task:
- Identify the smallest safe fix.
- Modify only files directly related to the error.
- Do not refactor unrelated code.
- Do not run commands unless allowed.

Report:
- Cause
- Changed files
- Commands I should run next
```

---

## 4. 문서 업데이트 프롬프트

```text
Documentation-only task.

Read:
- docs/MASTER_CONTEXT.md
- docs/PROJECT_STATUS.md
- docs/NEXT_TASKS.md

Update only docs.

Goal:
-

Do not modify:
- lib/
- assets/
- pubspec.yaml
- android/
- test/

After updating, ensure:
- MASTER_CONTEXT.md is concise
- NEXT_TASKS.md has correct TODO/DOING/DONE state
- PROJECT_STATUS.md separates implemented and planned features
```

---

## 5. 작업 쪼개기 프롬프트

```text
Read docs/MASTER_CONTEXT.md and docs/NEXT_TASKS.md.

Break the following goal into small Codex-safe tasks.

Goal:
[큰 목표]

Rules:
- One task = one screen/file group
- Do not mix UI, logic, assets, and docs
- Each task must have target files
- Each task must have do-not-modify files
- Each task must have done definition
```

---

## 6. 작업 완료 점검 프롬프트

```text
Review the changes from the current task.

Check:
- Did you modify only allowed files?
- Did you preserve protected logic?
- Did you update MASTER_CONTEXT.md?
- Did you update NEXT_TASKS.md?
- What commands should I run?

Do not make new code changes unless necessary.
```

---
