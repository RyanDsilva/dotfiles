---
name: handoff
description: Write a session handoff summary to JOURNAL.md. Use at the end of a work session, or when asked to hand off, journal, or summarize progress.
allowed-tools: Read, Edit, Write, Bash(git log:*), Bash(git status:*)
---
Append a dated entry to `./JOURNAL.md` (create it if absent) capturing, concisely:

- What changed: the concrete work done this session.
- State: what's passing/failing (tests, build), and anything left broken.
- Decisions: choices made and why (so future-you doesn't relitigate them).
- Surprises: anything unexpected discovered.
- Next: the single most important thing the next session should do first.

Keep it factual and short - this is precise continuity, not prose. Never include secrets.
