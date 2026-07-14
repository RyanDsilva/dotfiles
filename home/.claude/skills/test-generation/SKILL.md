---
name: test-generation
description: Generate tests for code. Use when asked to write tests or add coverage.
---
Write tests that match the project's existing framework and style (detect it: Jest/Vitest, pytest, `go test`, `cargo test`, etc. - read a neighboring test first).

Prioritize:
- The happy path, then edge cases (empty, boundary, large, unicode), then failure paths (errors, timeouts, invalid input).
- Table-driven / parametrized style where the language favors it (Go, pytest, Rust).
- Behavior, not implementation details. Assert on observable outputs, not internals.

Run the suite and iterate until green. Don't test what the type system already guarantees. Report what you covered and any gaps you deliberately left.
