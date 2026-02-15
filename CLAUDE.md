# CLAUDE.md

<!-- Keep this file under 500 lines. It loads into context on every run,
so every line costs tokens. Move detailed workflow instructions into
.claude/rules/ or skills as the project grows. -->

## Project Overview
<!-- What does this project do? What problem does it solve? Write one paragraph.
Example: "This is a REST API for managing inventory across multiple warehouses.
It handles real-time stock tracking, automated reorder alerts, and integrates
with our shipping provider APIs." -->

## Tech Stack
<!-- List the languages, frameworks, and key libraries used in this project.
Example:
- TypeScript + Node.js 20
- Express.js for HTTP server
- PostgreSQL 16 with Prisma ORM
- Jest for testing
- ESLint + Prettier for formatting
-->

## Project Structure
<!-- Describe the directory layout so Claude understands where things live.
Example:
- src/           Application source code
- src/routes/    HTTP route handlers
- src/models/    Database models
- src/services/  Business logic
- tests/         Test files (mirrors src/ structure)
- docs/          Documentation
-->

## Development Commands
<!-- List the commands Claude needs to build, test, and run the project.
Example:
- `npm install`        Install dependencies
- `npm run dev`        Start dev server with hot reload
- `npm run build`      Production build
- `npm test`           Run all tests
- `npm run test:watch` Run tests in watch mode
- `npm run lint`       Run linter
- `npm run lint:fix`   Auto-fix lint issues
-->

## Code Conventions
<!-- Define the rules Claude must follow when writing code.
Example:
- Use TypeScript strict mode — no `any` types
- Functions over 20 lines should be broken up
- Use named exports, not default exports
- Error messages must be human-readable strings
- Use early returns instead of nested if/else
- All async functions must have error handling
-->

## Testing Requirements
<!-- Describe how tests should be written and run.
Example:
- Every new function needs a unit test
- Integration tests go in tests/integration/
- Use descriptive test names: "should return 404 when user not found"
- Mock external services, never call real APIs in tests
- Aim for >80% coverage on new code
-->

## PR and Review Guidelines
<!-- Define what makes a good PR in this project.
Example:
- PRs should change fewer than 400 lines when possible
- Include a description of what changed and why
- Add tests for new functionality
- Update documentation if changing public APIs
- One concern per PR — don't mix refactoring with features
-->

## PR Risk Labeling (do not remove)

When creating PRs, always assess risk and add exactly one of these labels:

- `auto-merge` — Docs, formatting, dependency bumps, trivial fixes with passing tests. Safe to merge without human review.
- `needs-review` — New features, refactors, architecture changes, security-related code. Requires human review before merge.
- `blocked` — Cannot proceed without human input or decision.

Default to `needs-review` when uncertain. Never use `auto-merge` for changes that touch authentication, authorization, payment, or data deletion logic.
