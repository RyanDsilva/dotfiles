# Go conventions

- Format with `gofmt`/`goimports`; lint with `go vet` and golangci-lint. Tabs, not spaces.
- Handle every error explicitly; wrap with `fmt.Errorf("...: %w", err)`. No naked `_ =` on errors that matter.
- Accept interfaces, return structs. Keep interfaces small and defined by the consumer.
- Prefer table-driven tests with subtests (`t.Run`). Use `t.Parallel()` where safe.
- Use `context.Context` as the first arg for anything that blocks; never store it in a struct.
- Guard against nil maps/slices/pointers; prefer zero values that are usable.
- Naming: MixedCaps, short receiver names, no `Get` prefix on getters, `ErrX` sentinel errors.
