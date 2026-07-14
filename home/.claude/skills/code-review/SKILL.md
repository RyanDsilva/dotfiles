---
name: code-review
description: Review a diff or code for correctness, security, and quality. Use when asked to review code, a PR, or changes.
allowed-tools: Read, Grep, Glob, Bash(git diff:*), Bash(git log:*)
---
Review the target code (default: the working-tree diff - get it with `git diff` / `git diff --staged`).

Report findings grouped by severity (blocker / should-fix / nit), each as `file:line - problem - fix`. Cover:
- Correctness: edge cases, off-by-one, nil/undefined, error paths, concurrency.
- Security: injection, secrets in code, unsafe input handling, authz gaps.
- Design: naming, duplication, wrong abstraction, leaky boundaries.
- Tests: missing coverage for the change, especially failure cases.
- Fit: does it match the surrounding code's conventions?

Be concrete and specific. Do not restate what linters/formatters already enforce. If nothing is wrong, say so plainly rather than inventing nits.
