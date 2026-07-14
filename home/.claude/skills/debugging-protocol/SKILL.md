---
name: debugging-protocol
description: Systematic bug fixing. Use when investigating a bug, failure, crash, or unexpected behavior.
---
Fix the root cause, not the symptom. Follow this loop:

1. Reproduce: get the bug failing in the most end-to-end way you can (a test, a command, a script that mimics the real user path). Do not proceed on a guess.
2. Locate: narrow to the smallest code responsible. Read the actual code and data flow; add temporary logging/asserts if needed.
3. Root-cause: explain *why* it happens in one sentence before changing anything.
4. Fix: make the minimal change that addresses the cause. No drive-by rewrites.
5. Verify: re-run the reproduction; confirm it passes and nothing adjacent broke. Remove temporary debug code.

State the root cause and the verification result explicitly when done.
