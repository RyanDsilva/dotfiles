#!/usr/bin/env bash
# PostToolUse(Edit|Write): auto-format the edited file.
# Fails silently so a missing formatter never blocks Claude.
file=$(jq -r '.tool_input.file_path // empty' 2>/dev/null)
[ -z "$file" ] && exit 0
[ -f "$file" ] || exit 0
case "$file" in
  *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs|*.json|*.jsonc|*.css|*.md)
    { biome format --write "$file" \
        || npx --no-install biome format --write "$file" \
        || npx --no-install prettier --write "$file"; } >/dev/null 2>&1 ;;
  *.py)
    ruff format "$file" >/dev/null 2>&1
    ruff check --fix "$file" >/dev/null 2>&1 ;;
  *.rs)
    rustfmt "$file" >/dev/null 2>&1 ;;
  *.go)
    gofmt -w "$file" >/dev/null 2>&1
    goimports -w "$file" >/dev/null 2>&1 ;;
esac
exit 0
