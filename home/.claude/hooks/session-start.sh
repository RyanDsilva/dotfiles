#!/usr/bin/env bash
# SessionStart: surface git context + the latest journal entry so a resumed
# session has precise continuity.
input=$(cat 2>/dev/null)
dir=$(printf '%s' "$input" | jq -r '.cwd // .workspace.current_dir // empty' 2>/dev/null)
[ -z "$dir" ] && dir="$PWD"

git -C "$dir" rev-parse --git-dir >/dev/null 2>&1 || exit 0

branch=$(git -C "$dir" branch --show-current 2>/dev/null)
commits=$(git -C "$dir" log --oneline -5 2>/dev/null)
ctx="git branch: ${branch}"$'\n'"recent commits:"$'\n'"${commits}"

if [ -f "$dir/JOURNAL.md" ]; then
  ctx="${ctx}"$'\n\n'"latest JOURNAL.md (tail):"$'\n'"$(tail -n 40 "$dir/JOURNAL.md")"
fi

jq -n --arg c "$ctx" \
  '{hookSpecificOutput:{hookEventName:"SessionStart",additionalContext:$c}}'
exit 0
