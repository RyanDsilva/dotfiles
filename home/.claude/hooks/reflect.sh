#!/usr/bin/env bash
# Stop hook: reflect on the finished session and append durable, cross-project
# preferences to ~/.claude/memory/preferences.md so Claude compounds knowledge of
# how *you* like to work. Runs headless and best-effort.
#
# Safety: the nested reflection is scoped to file tools only (Read/Edit/Write) -
# it cannot run shell commands or anything else. It is NOT run with skipped
# permissions.
#
# Cost/behavior notes:
#   - Spends a small amount of tokens per session end for the reflection pass.
#   - preferences.md is a plain file in your dotfiles repo: review/revert via git.
#   - To DISABLE: remove the reflect.sh entry from the "Stop" hook in settings.json.

# Prevent infinite recursion: the nested `claude` call below also fires Stop.
[ -n "${CLAUDE_REFLECT_RUNNING:-}" ] && exit 0
command -v claude >/dev/null 2>&1 || exit 0

input=$(cat 2>/dev/null)
transcript=$(printf '%s' "$input" | jq -r '.transcript_path // empty' 2>/dev/null)
[ -z "$transcript" ] && exit 0
[ -f "$transcript" ] || exit 0

prefs="$HOME/.claude/memory/preferences.md"
mkdir -p "$(dirname "$prefs")"

prompt="Read the session transcript at: ${transcript}
Extract ONLY durable, cross-project preferences the user expressed or implied
through corrections - things that should shape how you work in every repo
(tooling choices, style/workflow rules, communication preferences, recurring
corrections). Ignore project-specific facts, one-off instructions, and anything
secret. Read ${prefs} first and append only genuinely new, non-duplicate bullets
(one specific, verifiable line each) to it. If nothing durable came up, make no
changes. Produce no user-facing output."

# Headless, backgrounded so it never delays session end. Scoped to file tools
# only (no Bash / execution). Bounded turns. Guard var stops the nested run from
# re-triggering this hook.
CLAUDE_REFLECT_RUNNING=1 nohup claude -p "$prompt" \
  --allowedTools "Read,Edit,Write" \
  --max-turns 12 \
  >/dev/null 2>&1 &
exit 0
