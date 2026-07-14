---
name: explain-codebase
description: Explain an unfamiliar codebase or module. Use when asked how a project works, its architecture, or where to start.
allowed-tools: Read, Grep, Glob, Bash(git log:*)
---
Give a tour that gets someone productive fast:

- Entry points: where execution starts (main, server bootstrap, CLI, routes).
- Architecture: the major components and how they relate (a short text diagram is fine).
- Data flow: how a typical request/operation moves through the system.
- Key files: the 5-10 files that matter most, one line each.
- Conventions: how this repo does things (naming, layering, testing, config).
- Where to make changes: point to the right place for common tasks.

Read before you assert. Cite `file:line`. Skip boilerplate; focus on what's load-bearing.
