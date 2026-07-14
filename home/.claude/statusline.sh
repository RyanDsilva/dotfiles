#!/usr/bin/env bash
# Claude Code statusline. Reads session JSON on stdin, prints one line.
# Shows: model | context % used | git branch | session cost.
set -euo pipefail

input=$(cat)
model=$(printf '%s' "$input" | jq -r '.model.display_name // empty')
used=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty')
cost=$(printf '%s' "$input" | jq -r '.cost.total_cost_usd // empty')
dir=$(printf '%s' "$input" | jq -r '.workspace.current_dir // empty')

out="$model"
[ -n "$used" ] && out="$out | ctx: $(printf '%.0f' "$used")%"

if [ -n "$dir" ]; then
  branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null || true)
  [ -n "$branch" ] && out="$out | ⎇ $branch"
fi

if [ -n "$cost" ] && [ "$cost" != "0" ]; then
  out="$out | \$$(printf '%.2f' "$cost")"
fi

printf '%s' "$out"
