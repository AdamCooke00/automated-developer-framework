#!/usr/bin/env bash
# Prompt logger for the pattern tracking system.
# Called by UserPromptSubmit hook. Receives hook JSON via stdin.
# Appends a one-line JSON entry to prompt-log.jsonl.

# Skip in CI — we only track human developer prompts
if [ -n "$CI" ] || [ -n "$GITHUB_ACTIONS" ]; then
  exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/prompt-log.jsonl"

# Read hook input from stdin
INPUT=$(cat)

# Generate timestamp
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date +"%Y-%m-%dT%H:%M:%SZ")

# Extract fields and write structured log entry
if command -v jq &>/dev/null; then
  echo "$INPUT" | jq -c \
    --arg ts "$TIMESTAMP" \
    '{logged_at: $ts, prompt: .prompt, session_id: .session_id, cwd: .cwd}' \
    >> "$LOG_FILE" 2>/dev/null
else
  # Fallback: write raw hook input (still valid JSONL)
  echo "$INPUT" >> "$LOG_FILE"
fi

# Always exit 0 — logging must never block the user's prompt
exit 0
