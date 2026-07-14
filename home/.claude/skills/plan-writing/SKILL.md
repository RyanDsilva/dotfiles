---
name: plan-writing
description: Write an implementation plan before coding. Use when asked to plan a feature or approach, or before a non-trivial change.
---
Produce a written plan before touching code. Structure:

- Goal: one sentence on what "done" means, in user terms.
- Context: the files/systems involved and current behavior (read them first - don't assume).
- Approach: the chosen design and why, plus one alternative you rejected and why.
- Steps: an ordered, checkable list of concrete changes.
- Risks / out-of-scope: what could break, and what this explicitly does not do.
- Verification: how you'll prove it works end-to-end.

Keep it tight. Prefer the simplest design that's robust and maintainable over the clever one. Surface open questions instead of guessing.
