# Comprehensive Test Findings — v1 Template

**Date:** 2026-02-14
**Test repo:** `AdamCooke00/adf-test` (private, throwaway — delete after testing)
**Template repo:** `AdamCooke00/automated-developer-framework`

---

## Test Status

| Test | Status | Score | Key Finding |
|---|---|---|---|
| Test 1: Feature implementation | ✅ Complete | 26/35 | Good code, no PR created, verbose output |
| Test 2: Auto-review quality | ✅ Complete | 20/25 | Caught 5/8 bugs, posted after permission fixes |
| Test 3: Follow-up correction | ✅ Complete | Grading below | Both features implemented, still no PR |
| Test 4: Underspecified bug report | ✅ Complete | Grading below | Good investigation, still no PR |
| Test 5: Daily digest quality | Pending | — | — |
| Test 6: Auth fallback | Pending | — | — |

---

## Test 1: Feature Implementation (26/35)

**Issue #1:** "Build the initial todo list CLI. Users should be able to add, list, and remove todos. Store them persistently. Make it feel like a real tool."

**Runtime:** 2m 54s | **Turns:** ~11 | **Cost:** ~$0.26 | **Auth:** Max subscription

### What Claude did well

- Created `src/todo_manager.py` — clean `TodoManager` class with `TypedDict`, pathlib, JSON persistence
- Created `src/main.py` — argparse CLI with add/list/remove subcommands, proper exit codes
- Created 24 unit tests across 2 test files (edge cases: corrupted JSON, empty strings, whitespace, persistence)
- Updated `.gitignore` with `todo.json`
- Used type hints, pathlib, context managers, early returns — followed all Code Conventions
- Input validation with human-readable error messages

### What Claude did wrong

1. **Did NOT create a PR** — pushed branch + "Create PR ➔" link, never ran `gh pr create`
2. **Issue stayed open** — no PR to merge with "Closes #N"
3. **Comment was verbose** — task checklist + full summary instead of 2-3 concise sentences

### Scores

| Dimension | Score | Notes |
|---|---|---|
| Completeness | 4/5 | All 3 operations, tests, .gitignore. No PR created. |
| Code quality | 5/5 | Type hints, pathlib, TypedDict, error handling |
| Initiative | 4/5 | Edge case tests, corrupted JSON handling, help text |
| Judgment | 5/5 | Stayed in scope — stdlib only, no over-engineering |
| PR quality | 1/5 | No PR created |
| Communication | 3/5 | Verbose — task checklist unnecessary |
| Cost/efficiency | 4/5 | 3 min on Max |

---

## Test 2: Auto-Review Quality (20/25)

**PR #3:** Intentionally bad `src/export.py` with 8 planted bugs.

**Runtime:** 52s | **Turns:** 5 | **Cost:** $0.10 | **Auth:** Max subscription

### Review posted by `claude[bot]`

```
## Issues Found

**Bugs:**
- `src/export.py:5` — File handle `f` is never closed; use `with open("todo.json") as f:` instead.
- `src/export.py:8` — Will crash if `item["done"]` is boolean; convert to string: `str(item["done"])`.
- `src/export.py:4` — Missing type hint on `format` parameter; add `: str`.
- `src/export.py:4` — Missing return type hint; add `-> None`.

**Convention violations:**
- `src/export.py:1` — Uses `os` module but never references it; remove unused import.
- `src/export.py:2` — Uses `os.path` pattern; violates "use pathlib, not os.path" convention.
- `src/export.py:4` — Missing docstring on public function `export`.

**Missing tests:**
- No test file found for `export.py`; create `tests/test_export.py`.
```

### Bug detection scorecard

| Planted Issue | Caught? |
|---|---|
| `os` instead of `pathlib` | ✅ |
| `format` shadows builtin | ❌ |
| No context manager | ✅ |
| No error handling for missing file | ❌ |
| `item["done"]` bool+str crash | ✅ |
| Silent failure for unknown format | ❌ |
| No type hints | ✅ |
| No tests | ✅ |

**5/8 issues caught.** Missed: shadowed builtin, missing file handling, silent failure on unknown format.

### Scores

| Dimension | Score | Notes |
|---|---|---|
| Bug detection | 3/5 | Caught runtime crash + unclosed file. Missed 3 issues. |
| Convention enforcement | 4/5 | Flagged pathlib, type hints, docstring. Missed `format` shadowing. |
| Conciseness | 5/5 | One line per issue with file:line and fix. No fluff. Perfect. |
| Prioritization | 4/5 | Separated bugs/conventions/tests. |
| Actionability | 4/5 | Each fix is specific and implementable. |

### What it took to get reviews posting

**4 attempts** to get the review workflow working:

1. `/review` prompt, no `--allowedTools` → `gh pr list` permission denied, no review
2. `/review` prompt + `--allowedTools "Bash(gh*)"` → read commands worked, but `/review` skill doesn't call `gh pr review` to post
3. Explicit prompt + `--allowedTools "Bash(gh*)"` → read worked, `gh pr review` permission denied (write operations blocked separately)
4. Explicit prompt + `--dangerously-skip-permissions` → **worked** ✅

---

## Test 3: Follow-Up Correction

**Issue #4:** "The remove command should ask for confirmation before deleting. Also, add a 'done' command that marks a todo as complete instead of removing it."

**Runtime:** 2m 30s | **Turns:** 26 (hit max) | **Cost:** $0.76 | **Auth:** Max subscription

### What Claude implemented

- ✅ Confirmation prompt on remove ("Are you sure? (y/n):")
- ✅ New `done` command to mark todos complete
- ✅ Updated `Todo` data structure with `completed` boolean field
- ✅ Updated list display: `[X]` for completed, `[ ]` for incomplete
- ✅ 7 new tests (29 total, all passing)

### Assessment

- **Incremental change:** Modified existing code, not rewritten ✅
- **Both requests handled:** Yes ✅
- **Test coverage:** Good — 7 new tests for confirmation + done ✅
- **Scope discipline:** Stayed focused on requested features ✅
- **Continuity:** Correctly understood the existing codebase ✅
- **PR creation:** Still didn't create a PR ❌ (same "Create PR ➔" link pattern)
- **Output style:** Still verbose — task checklist + full summary ❌
- **Cost:** $0.76 is high — hit max-turns (26). May indicate inefficiency in tool usage.

### Scores

| Dimension | Score | Notes |
|---|---|---|
| Incremental change | 5/5 | Modified existing code properly |
| Both requests handled | 5/5 | Confirmation + done both implemented |
| Test coverage | 4/5 | 7 new tests, all passing. Could test more edge cases. |
| Scope discipline | 5/5 | No unrelated changes |
| Continuity | 5/5 | Understood codebase from Test 1 |

**Test 3 Total: 24/25** (code quality) — but deducted for no PR creation and verbose output.

---

## Test 4: Underspecified Bug Report

**Issue #5:** "The todo list breaks when I try to add a todo with special characters. Fix it."

**Runtime:** 1m 1s | **Turns:** 26 (hit max) | **Cost:** $0.65 | **Auth:** Max subscription

### What Claude did

- Investigated the code and found `json.dump()` was escaping unicode by default
- Added `ensure_ascii=False` to JSON encoding in `todo_manager.py:39`
- Added **10 new tests** covering: quotes, backslashes, unicode, emojis, special symbols, control characters
- All 29 tests passing

### Assessment

- **Investigation:** Analyzed the code for actual issues vs. asking for clarification ✅
- **Root cause:** Found the real issue (`ensure_ascii` default) and fixed it ✅
- **Test-first thinking:** 10 comprehensive regression tests ✅
- **Autonomy:** Acted on reasonable assumptions without blocking on "what special characters?" ✅
- **Communication:** Concise explanation of what was found ✅ (better than Tests 1 and 3)
- **PR creation:** Still no PR ❌
- **Cost:** $0.65 — hit max-turns. High for a one-line fix + tests.

### Scores

| Dimension | Score | Notes |
|---|---|---|
| Investigation | 5/5 | Analyzed code, found real issue |
| Root cause | 4/5 | Fixed the encoding issue. Could argue JSON already handles special chars fine — the "bug" may be fabricated. |
| Test-first thinking | 5/5 | 10 regression tests, excellent coverage |
| Autonomy | 5/5 | Didn't ask for clarification, made reasonable assumptions |
| Communication | 4/5 | Better than Tests 1/3 but still has task checklist |

**Test 4 Total: 23/25** (code quality) — but deducted for no PR creation.

---

## Recurring Issues Across All Tests

### 1. Claude never creates PRs

**Every test (1, 3, 4)** shows the same pattern:
- Claude pushes code to a branch
- Comments with a "Create PR ➔" link
- Never runs `gh pr create`

This is likely behavioral (the claude-code-action generates the "Create PR" link automatically as part of its output format). Even with `--dangerously-skip-permissions`, Claude doesn't create PRs.

**Impact:** No auto-review triggers, no risk labels, no issue auto-close.
**Fix needed:** CLAUDE.md instruction: "Always use `gh pr create` to open PRs. Do not rely on the Create PR link."

### 2. Output is verbose

All issue comments include:
- A task checklist (`[x] Read codebase`, `[x] Implement feature`, etc.)
- A full implementation summary
- A file list

The Output Style section says "answer the question directly, skip preamble" but Claude still adds structure that a human wouldn't need.

**Fix needed:** Strengthen CLAUDE.md Output Style to say "Do not include task checklists in issue comments."

### 3. Costs are high when hitting max-turns

| Test | Turns | Cost | Reasonable? |
|---|---|---|---|
| Test 1 | ~11 | $0.26 | Yes — initial implementation |
| Test 2 | 5 | $0.10 | Yes — review only |
| Test 3 | 26 (max) | $0.76 | High — 2 features, but shouldn't need 26 turns |
| Test 4 | 26 (max) | $0.65 | High — one-line fix + tests shouldn't need 26 turns |

Tests 3 and 4 hit the max-turns limit. This suggests Claude is spending turns on overhead (reading files it doesn't need, verbose internal processing). The Output Style section says "minimize tool calls" but it's not being followed effectively.

**Fix needed:** Consider reducing `--max-turns` from 25 to 15 for typical tasks. Add CLAUDE.md instruction: "Minimize tool calls — read only files you need, batch operations where possible."

---

## Changes Made During Testing

### Workflow fixes (must port to template)

| File | Change | Why |
|---|---|---|
| `claude.yml` | Added `--dangerously-skip-permissions` | Without this, Claude can't run `gh pr create`, `gh issue close`, etc. |
| `claude-review.yml` | Added `--dangerously-skip-permissions` | Without this, Claude can't run `gh pr review` to post reviews |
| `claude-review.yml` | Replaced `/review` prompt with explicit instructions | `/review` skill doesn't post to GitHub — need to tell Claude to use `gh pr review` |
| `claude-review.yml` | Added `show_full_output: true` | Debug only — remove before finalizing |

### CLAUDE.md fixes (must add to template)

1. "Always use `gh pr create` to open PRs. Do not just push to a branch and provide a link."
2. "Do not include task checklists in issue comments."
3. "Minimize tool calls — batch file reads, avoid reading files you don't need."

---

## Model Discovery

- **Default model:** `claude-sonnet-4-5-20250929` (Sonnet)
- Not specified anywhere — action uses its default
- Haiku used for internal routing/classification
- To change: add `--model claude-opus-4-6` to `claude_args`

---

## Test 5: Daily Digest (16/20)

**Runtime:** 1m 29s | **Turns:** ~8 | **Cost:** ~$0.10 | **Auth:** Max subscription

### Digest issue created: #6 "Daily Digest — 2026-02-15"

```
## Completed
- PR #2: Implement todo list CLI with add, list, and remove commands — merged
- Issue #1: Build the todo list CLI — closed

## Needs Review
- **PR #3: Add CSV export feature** — CRITICAL
  - New export functionality in src/export.py
  - Code has multiple issues: no file closing, no error handling, ...
  - Missing tests for new functionality
  - Requires review and fixes before merge

## Blocked
None

## Upcoming
- Issue #4: Add confirmation and done command — assigned to @claude, not started
- Issue #5: Bug: special characters break todo add — assigned to @claude, not started
```

### Assessment

| Dimension | Score | Notes |
|---|---|---|
| Accuracy | 4/5 | Correctly categorized merged PR, closed issue, and critical PR. Issues #4/#5 show "not started" but Claude already pushed branches — can't see un-PR'd work. |
| Risk assessment | 5/5 | PR #3 correctly flagged as CRITICAL with specific issues |
| Scannability | 4/5 | Clean structure, 30-second scan. Could be shorter. |
| Conciseness | 3/5 | Good but could be more compact |

---

## Test 6: Auth Fallback (skipped)

Skipped to save API key costs. The fallback mechanism was verified at the plumbing level during testing — all 5 completed tests show "Fallback to API key: skipped" in the logs, confirming Max-first auth works and the fallback step is properly conditional.

---

## Final Scorecard

```
Test 1 — Feature Implementation:     26/35
Test 2 — Code Review Quality:        20/25
Test 3 — Follow-up Iteration:        24/25
Test 4 — Ambiguous Bug Report:       23/25
Test 5 — Daily Digest:               16/20
Test 6 — Auth Fallback:              skipped (plumbing verified)

Total: 109/130

Autonomy level: HIGH (100+ threshold)
```

### Strengths
- **Code quality is excellent** — follows conventions, writes comprehensive tests, handles edge cases
- **Investigation skills are strong** — analyzes code for root causes, doesn't ask trivial clarifying questions
- **Review quality is good** — when it works, catches most issues with concise actionable feedback
- **Scope discipline** — stays focused, doesn't over-engineer

### Weaknesses (fixable via CLAUDE.md + workflow changes)
- **Never creates PRs** — pushes branches + "Create PR" link (behavioral, not permissions)
- **Verbose output** — task checklists and summaries in every comment
- **High turn count** — Tests 3/4 hit 26-turn max for moderate tasks ($0.65-0.76)
- **Review workflow broken out of the box** — `/review` skill + default permissions don't work

### Critical Template Fixes Required

**Workflow files (all 3):**
1. Add `--dangerously-skip-permissions` to all `claude_args` — without this, Claude can't run `gh` commands to create PRs, post reviews, or create issues
2. Replace `/review` prompt with explicit instructions to use `gh pr review`

**CLAUDE.md:**
1. Add: "Always use `gh pr create` to open PRs after implementing changes"
2. Add: "Do not include task checklists in issue comments"
3. Strengthen: "Minimize tool calls" instruction
