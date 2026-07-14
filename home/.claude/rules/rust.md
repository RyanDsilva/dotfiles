# Rust conventions

- Format with `rustfmt`; lint with `cargo clippy` (treat warnings seriously).
- Return `Result<T, E>` for fallible work; reserve `panic!`/`unwrap`/`expect` for truly impossible cases or tests. Use `?` for propagation.
- Model errors with `thiserror` (libraries) / `anyhow` (apps). Make illegal states unrepresentable with enums.
- Borrow over clone; clone deliberately, not to silence the borrow checker.
- Tests in `#[cfg(test)] mod tests`; add doctests for public APIs.
- Prefer iterators/combinators over manual loops where it reads clearly.
