# TypeScript / JavaScript conventions

- Format and lint with Biome. 2-space indent. Prefer `bun`/`pnpm` over npm.
- `strict` TypeScript. No `any` - use `unknown` + narrowing. Prefer `type` aliases and discriminated unions.
- Prefer `const`, immutability, and pure functions. Avoid classes unless they earn their keep.
- Handle async errors explicitly; no floating promises. Model absence with `T | undefined`, not `null` sprinkled everywhere.
- Tests with Vitest/Jest; test behavior, not implementation. Co-locate `*.test.ts`.
- Validate external input at the boundary (zod or equivalent) before trusting types.
