# Automated Developer Framework

A GitHub template repository pre-configured with Claude Code automation. Clone it, configure it, and every future project inherits AI-powered issue handling and code review.

## How It Works

This template implements a multi-agent automation framework using GitHub Actions and Claude Code. The system includes 10 workflows (agents) that handle implementation, code review, CI diagnosis, scheduled maintenance, and more. Agents communicate through labels, comments, and workflow chaining to create a self-healing development loop.

**For the complete technical specification** — including all workflow triggers, state machines, handoff chains, authentication flow, edge cases, and file structure — see **[docs/flow-diagram.md](docs/flow-diagram.md)**.

## What You Get

**Reactive workflows:**
- **`@claude` on issues and PRs** — implements requests and creates PRs
- **Automatic code review** — reviews every PR when opened or updated
- **PR size guardian** — warns when PRs exceed 400 lines
- **CI Doctor** — diagnoses failures and posts fix suggestions

**Scheduled maintenance:**
- **Daily digest** — morning summary of completed work, PRs needing review (with risk assessment), and blockers
- **Agent health report** — weekly Friday report on Claude's effectiveness and recommendations
- **Stale issue gardener** — weekly Monday cleanup of inactive issues
- **Doc Drift Detector** — weekly Monday check for outdated documentation

**Infrastructure:**
- **PR risk labeling** — auto-merge, needs-review, or blocked labels for triage
- **Template sync** — automatic PRs when the template updates
- **Max-first auth** — free tier first, API fallback

For detailed workflow specifications, state machines, and handoff chains, see [docs/flow-diagram.md](docs/flow-diagram.md).

## How You Work With Claude

| Where | What you do | What Claude does |
|---|---|---|
| **GitHub Issues** | Create issue with `@claude` + task description | Reads issue, implements, opens PR (issue closes when PR merges) |
| **Issue comments** | Reply with `@claude` + follow-up or correction | Continues work on same issue, adjusts approach |
| **PR comments** | Comment `@claude fix X` on Claude's PR | Pushes new commits to the PR branch |
| **PR review** | Submit review with `@claude` in body | Addresses review feedback, pushes fixes |
| **Your own PRs** | Just open a PR | Claude auto-reviews with inline comments + size check (warns if >400 lines) |
| **CI failures** | (nothing — automatic) | Posts diagnostic comment on PR: what failed, why, suggested fix |
| **Daily digest** | Read the daily-digest issue (mobile notification) | Created automatically — summarizes activity, flags what needs you |
| **Agent health report** | (nothing — automatic) | Runs weekly Friday 9am UTC — tracks PRs, merge rate, risk labels, workflow failures, with recommendations |
| **Stale issue gardener** | (nothing — automatic) | Runs weekly Monday 9am UTC — marks stale issues, closes abandoned ones, labels new issues |
| **Doc Drift Detector** | (nothing — automatic) | Runs weekly Monday 10am UTC — compares docs against code, opens PR with fixes |
| **Actions tab** | Check workflow runs for cost, turn count, errors | Logs show every step Claude took |

**Automation boundaries:**
- Claude works autonomously within a single issue/PR until it completes or hits `--max-turns`
- It does NOT chain tasks (finishing issue A doesn't make it start issue B)
- It does NOT act without a trigger (`@claude` mention or PR open)
- You control pace by controlling when you create issues and respond to PRs

**Multi-project management:**
- Each project has its own daily digest — one mobile notification per project per day
- https://github.com/pulls shows all open PRs across repos in one view
- GitHub notification settings let you filter by repo/label

## Setup After Cloning

### Step 1: Create your repo from this template

**Option A — GitHub UI:**
Click **"Use this template"** > **"Create a new repository"** on the template's GitHub page.

**Option B — CLI:**
```bash
gh repo create my-new-project --template <your-username>/automated-developer-framework --public
gh repo clone my-new-project
cd my-new-project
```

### Step 2: Create an Anthropic workspace for this project

Each project should have its own workspace so you can set independent spend limits.

1. Go to https://console.anthropic.com → **Settings** → **Workspaces**
2. Click **Create Workspace**
3. Name it after your project (e.g., "my-new-project")
4. Go to the workspace's **Limits** tab and set a monthly spend limit (e.g., $25/month)
5. Create an API key inside this workspace — save it for Step 4

This workspace limit is your cost control. If multiple projects share one Anthropic account, each project's workspace has its own independent ceiling.

### Step 3: Install the Claude GitHub App

The Claude GitHub App is required for Claude to interact with your repo (comment on issues, push to branches, post reviews).

**Option A — Via Claude Code CLI (recommended):**
```bash
claude /install-github-app
```

**Option B — Manual install:**
1. Go to https://github.com/apps/claude
2. Click **Install**
3. Select your account or organization
4. Choose **"Only select repositories"** and pick your new repo
5. Click **Install**

### Step 4: Add your secrets

Go to your GitHub repo → **Settings** → **Secrets and variables** → **Actions** and add:

| Secret | Source | Required? |
|---|---|---|
| `CLAUDE_CODE_OAUTH_TOKEN` | Run `claude setup-token` in your terminal | Recommended (uses your Max subscription) |
| `ANTHROPIC_API_KEY` | From the workspace you created in Step 2 | Recommended (fallback when Max is rate-limited) |
| `PAT_TOKEN` | GitHub PAT (classic) with `repo`, `read:org`, and `workflow` scopes | Required for workflow file changes and template sync |

You need **at least one** of the first two. Both is ideal — see [How Auth Works](#how-auth-works) below.

**Why `PAT_TOKEN`?** GitHub's default `GITHUB_TOKEN` cannot create or modify files in `.github/workflows/`. The `PAT_TOKEN` is used by both the Claude workflow (to push branches) and the template sync workflow (to read from the template repo and open PRs). To create one: go to https://github.com/settings/tokens → **Generate new token (classic)** → select **`repo`**, **`read:org`**, and **`workflow`** scopes → add it as a secret: `gh secret set PAT_TOKEN -R <your-repo>`.

### Step 5: Configure template sync

Open `.github/workflows/template-sync.yml` and replace `<owner>/automated-developer-framework` with the actual GitHub path to your template repo (e.g., `myusername/automated-developer-framework`).

The template sync workflow uses the same `PAT_TOKEN` secret as the Claude workflow — no additional secrets needed.

**Required repo setting:** Go to your repo → **Settings** → **Actions** → **General** → scroll to "Workflow permissions" → check **"Allow GitHub Actions to create and approve pull requests"** → Save. Without this, the sync can push the branch but can't open the PR.

If you don't want automatic sync, delete this workflow file.

### Step 6: Customize CLAUDE.md

Open `CLAUDE.md` and fill in every section. This is the single most impactful thing you can do — it tells Claude how your project works, what conventions to follow, and what commands to run.

At minimum, fill in:
- **Project Overview** — what the project does
- **Tech Stack** — languages and frameworks
- **Development Commands** — how to build, test, and lint

Delete the HTML comments (`<!-- ... -->`) as you fill in real content. Keep CLAUDE.md under 500 lines — it loads into every run and longer files waste tokens. Move detailed workflow instructions into `.claude/rules/` or skills as the project grows.

### Step 7: Add your project code

Add your source files, commit, and push:
```bash
git add .
git commit -m "Initial project setup"
git push origin main
```

## How Auth Works

The workflows use a **Max-first, API-fallback** pattern: your Max subscription (already paid for) runs first at no additional cost, with automatic fallback to API key only on auth failures. Double-charge protection prevents paying twice when Max completes work but hits the turn limit.

**Configuration options:**
- **Both secrets set (recommended):** Max handles most runs for free; API key covers rate-limited periods
- **Only `CLAUDE_CODE_OAUTH_TOKEN`:** Free automation, but workflows fail if Max is rate-limited
- **Only `ANTHROPIC_API_KEY`:** Every run costs money, but no rate-limit interruptions

For the complete authentication flow diagram and technical details, see [docs/flow-diagram.md](docs/flow-diagram.md#authentication-flow).

## Daily Digest & Auto-Merge

The daily digest runs every morning at 8am UTC, creating a GitHub issue with: completed work, PRs needing review (with risk assessment), blockers, and upcoming tasks. Install the [GitHub mobile app](https://github.com/mobile) for push notifications.

Auto-merge automatically merges PRs labeled `auto-merge` after review passes. PRs labeled `needs-review` or `blocked` wait for human approval. No configuration needed.

For technical details on label behavior, workflow chaining, and state transitions, see [docs/flow-diagram.md](docs/flow-diagram.md#agentic-handoff-chains).

## Cost Control

Cost is controlled at the Anthropic console level — no in-repo watchdog needed:

1. **One workspace per project** — independent monthly spend limits per project
2. **Workspace limits are hard caps** — Anthropic stops API calls when the limit is reached
3. **`--max-turns` caps per workflow** — prevents any single run from consuming excessive tokens

**Cost guidance (API key usage only — Max runs are free):**
- Auto-reviews (5 turns, Sonnet) ≈ $0.01-0.05 per review
- `@claude` implementations (25 turns) ≈ $0.10-1.00 depending on complexity
- Set workspace limits to match your comfort level per project

**Monitor spend:** View per-workspace cost breakdowns at [platform.claude.com/claude-code](https://platform.claude.com/claude-code) or the Usage page in your [Anthropic console](https://console.anthropic.com).

**Note on workspaces:** When you first authenticate Claude Code, a workspace called "Claude Code" is auto-created. This is separate from the per-project workspaces you create manually.

## Test That It Works

### Test 1: Reactive workflow
Open a new issue with this body:
```
@claude List all files in this repository and describe what each one does.
```
Within a couple of minutes, Claude should post a comment on the issue with the answer.

### Test 2: Auto-review
Open a PR with any small change (edit the README, add a file, etc.). The **Claude Code Review** workflow should trigger automatically and post a review comment on the PR.

### Test 3: Implementation
Open an issue with this body:
```
@claude Create a simple hello world script in the language specified in CLAUDE.md.
Open a PR with the implementation.
```
Claude should create a branch, add the file, and open a PR.

### Test 4: Verify auth fallback
Check the **Actions** tab after a workflow run. You'll see which step executed — "Run with Max subscription" or "Fallback to API key." If Max succeeded, the fallback step shows as skipped.

If anything fails, check the **Actions** tab in your repo for workflow run logs.

## Staying Updated

GitHub templates are a one-time copy — your project doesn't automatically get updates when the template improves. The `template-sync.yml` workflow solves this.

**How it works:**
- Runs every Monday at midnight UTC (and on manual trigger)
- Compares your repo against the template
- Opens a PR with any new changes, labeled `template_sync`
- You review and merge (or close) the PR
- Project-specific files (`CLAUDE.md`, `README.md`, `.gitignore`, `.claude/`) are excluded via `.templatesyncignore`

**Trigger manually:**
Go to **Actions** > **Template Sync** > **Run workflow** to check for updates now.

**Resolve conflicts:**
If the PR has merge conflicts (because you changed a workflow file the template also changed), resolve them in the PR branch like any normal conflict.

## Improving CLAUDE.md Over Time

When Claude makes wrong assumptions or doesn't follow your preferences, feed corrections back into `CLAUDE.md` so they stick:

```
@claude Update CLAUDE.md to add this rule: always use vitest, not jest, for tests
```

Claude will commit the change directly. Over time, your CLAUDE.md becomes a living document that captures your project's accumulated knowledge.

## Customization

### Adjust max-turns (cost vs. capability)
Edit the `claude_args` line in each workflow file (update both the Max and fallback steps):

| Workflow | Default | What it controls |
|---|---|---|
| `.github/workflows/claude.yml` | `--max-turns 25` | How many steps Claude takes on `@claude` requests |
| `.github/workflows/claude-review.yml` | `--max-turns 5` | How many steps Claude takes during review |
| `.github/workflows/pr-size-guardian.yml` | `--max-turns 3` | How many steps Claude takes checking PR size |
| `.github/workflows/ci-doctor.yml` | `--max-turns 10` | How many steps Claude takes diagnosing CI failures |
| `.github/workflows/daily-digest.yml` | `--max-turns 10` | How many steps Claude takes generating the digest |
| `.github/workflows/agent-health-report.yml` | `--max-turns 10` | How many steps Claude takes generating the health report |
| `.github/workflows/stale-issue-gardener.yml` | `--max-turns 10` | How many steps Claude takes managing stale issues |
| `.github/workflows/doc-drift-detector.yml` | `--max-turns 10` | How many steps Claude takes detecting doc drift |

Lower = cheaper and faster. Higher = Claude can handle more complex tasks.

### Change the model
Add `--model` to `claude_args` in the workflow files:
```yaml
claude_args: "--max-turns 25 --dangerously-skip-permissions --model claude-sonnet-4-5-20250929"
```

Available models:
- `claude-sonnet-4-5-20250929` — fast, cost-effective, good for most tasks (default)
- `claude-opus-4-6` — strongest reasoning, use for complex implementation

### Change the trigger phrase
Add the `trigger_phrase` input to the claude.yml workflow steps:
```yaml
with:
  claude_code_oauth_token: ${{ secrets.CLAUDE_CODE_OAUTH_TOKEN }}
  trigger_phrase: "/ai"
  claude_args: "--max-turns 25 --dangerously-skip-permissions"
```
Then use `/ai` instead of `@claude` in comments.

## What This Template Does NOT Do (v1)

- **Cross-repo digest** — each project gets its own daily digest; there's no single summary across all projects

These can all be added later as separate workflow files.

## File Overview

The repository contains 10 workflow files in `.github/workflows/` (reactive and scheduled agents), `CLAUDE.md` (project instructions for Claude), and configuration files. For the complete file structure with descriptions, see [docs/flow-diagram.md](docs/flow-diagram.md#file-structure).

## Resources

- [Claude Code Action repository](https://github.com/anthropics/claude-code-action)
- [Claude Code GitHub Actions docs](https://code.claude.com/docs/en/github-actions)
- [CLAUDE.md best practices](https://code.claude.com/docs/en/memory)
- [Anthropic API console](https://console.anthropic.com)
- [Anthropic workspaces](https://support.anthropic.com/en/articles/9796807-creating-and-managing-workspaces)
- [Managing costs](https://code.claude.com/docs/en/costs)
- [Analytics dashboard](https://code.claude.com/docs/en/analytics)
