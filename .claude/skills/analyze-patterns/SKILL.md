---
name: analyze-patterns
description: Analyzes prompt history to detect repeated patterns and recommends automations (rules, skills, hooks) to eliminate repetition. Run this periodically to surface automation opportunities.
argument-hint: "[--threshold N] [--auto-implement]"
---

## Dynamic Context

Current prompt log:
!`cat .claude/prompt-tracking/prompt-log.jsonl 2>/dev/null || echo "No prompt log found."`

Current patterns registry:
!`cat .claude/prompt-tracking/patterns.json 2>/dev/null || echo "No patterns file found."`

Existing rules:
!`ls .claude/rules/ 2>/dev/null || echo "No rules yet."`

Existing skills:
!`ls .claude/skills/ 2>/dev/null || echo "No custom skills yet."`

Current hook config:
!`cat .claude/settings.json 2>/dev/null || echo "No settings.json found."`

## Your Task

Analyze the prompt log to detect repeated patterns and recommend automations.

### Step 1: Parse and Cluster

Read every entry in the prompt log. Group prompts that express the **same intent, instruction, or workflow** even if worded differently. Focus on semantic similarity, not exact string matches.

Examples of what counts as "the same pattern":
- "Use single quotes in TypeScript" and "Please use single quotes, not double quotes" → same pattern
- "Review this for security issues" and "Check this code for vulnerabilities" → same pattern
- "Run the tests after you edit" and "Make sure tests pass" → same pattern

### Step 2: Count and Filter

For each cluster:
- Count total occurrences
- Note the date range (first seen → last seen)
- Collect 2-3 representative sample prompts

Apply the detection threshold (default: 3, or override with `--threshold N` from `$ARGUMENTS`).

Skip any patterns already in `patterns.json` with status `approved`, `implemented`, or `rejected`.

### Step 3: Classify Using the Decision Tree

For each pattern above threshold, walk this tree:

```
Is this an INSTRUCTION (how Claude should behave/respond)?
│
├─ YES
│  ├─ Always applicable to this project?
│  │  ├─ YES, not path-specific
│  │  │  └─ TARGET: .claude/rules/<topic>.md
│  │  │     RISK: low → PR label: auto-merge
│  │  │
│  │  └─ YES, but only for certain file paths
│  │     └─ TARGET: .claude/rules/<topic>.md with paths: frontmatter
│  │        RISK: low → PR label: auto-merge
│  │
│  └─ Only relevant during certain types of tasks?
│     └─ TARGET: Skill with user-invocable: false
│        (Claude auto-invokes based on description match)
│        RISK: medium → PR label: needs-review
│
├─ NO → Is this a WORKFLOW (a repeatable action)?
│  │
│  ├─ YES
│  │  ├─ User triggers it explicitly (like a command)?
│  │  │  └─ TARGET: Skill (.claude/skills/<name>/SKILL.md)
│  │  │     RISK: medium → PR label: needs-review
│  │  │
│  │  └─ Should happen automatically without user intervention?
│  │     ├─ Before/after a specific tool runs?
│  │     │  └─ TARGET: Hook (PreToolUse/PostToolUse) with matcher
│  │     │     RISK: high → PR label: needs-review
│  │     │
│  │     ├─ On every prompt submission?
│  │     │  └─ TARGET: Hook (UserPromptSubmit)
│  │     │     RISK: high → PR label: needs-review
│  │     │
│  │     ├─ At session start?
│  │     │  └─ TARGET: Hook (SessionStart)
│  │     │     RISK: medium → PR label: needs-review
│  │     │
│  │     └─ When the agent finishes responding?
│  │        └─ TARGET: Hook (Stop)
│  │           RISK: high → PR label: needs-review
│  │
│  └─ NO → Is this about TOOL ACCESS or external services?
│     ├─ YES → TARGET: MCP server config or permission rule
│     │  RISK: high → PR label: needs-review
│     │
│     └─ NO → Is this a specialized ROLE/PERSONA?
│        └─ TARGET: Agent (.claude/agents/<name>.md)
│           RISK: medium → PR label: needs-review
```

### Step 4: Generate Recommendations

For each pattern, output:

```
### Pattern: [short description]
- **Occurrences:** N times across M sessions
- **First seen:** [date] | **Last seen:** [date]
- **Sample prompts:**
  1. "[exact prompt 1]"
  2. "[exact prompt 2]"
  3. "[exact prompt 3]"
- **Classification:** instruction | workflow | capability | role
- **Recommended mechanism:** rule | skill | hook | agent | mcp | permission
- **Target file:** [exact path where artifact would be created]
- **Risk level:** low | medium | high
- **PR label:** auto-merge | needs-review

**Draft implementation:**
[The complete file content that would be written]
```

### Step 5: Auto-Implementation (if requested)

If `$ARGUMENTS` contains `--auto-implement`:

For each recommended pattern:

1. Create branch: `pattern/<mechanism>-<short-name>`
2. Write the artifact file to the target path
3. Update `.claude/prompt-tracking/patterns.json`:
   - Add the pattern with status `proposed`
   - Include the sample prompts, classification, and target file
4. Commit with message: `pattern: add <mechanism> for <short description>`
5. Open PR with `gh pr create`:
   - Title: `Pattern: <short description>`
   - Body explaining what was detected, sample prompts, and what the automation does
   - Label: the appropriate risk label
6. Move to next pattern (each pattern gets its own branch and PR)

Without `--auto-implement`, just output the recommendations.

### Step 6: Summary

End with a summary:
- Total prompts analyzed
- Patterns detected (above threshold)
- Patterns already tracked (skipped)
- New patterns recommended
- If any patterns crossed the escalation threshold (default: 5), flag them prominently

## Important Rules

- Never propose a pattern that duplicates an existing rule, skill, hook, or agent
- Never modify existing automation artifacts — only create new ones
- If a pattern is ambiguous (could be instruction OR workflow), classify it as instruction (lower risk, easier to promote later)
- Always create PRs on new branches, never commit to main
- PR descriptions must explain the "why" — what repetitive behavior this eliminates
