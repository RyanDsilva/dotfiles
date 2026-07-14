#!/usr/bin/env bash
# PreToolUse(Bash): hard-block destructive commands.
# Fires even under --dangerously-skip-permissions (hooks run regardless of mode).
cmd=$(jq -r '.tool_input.command // empty' 2>/dev/null)
[ -z "$cmd" ] && exit 0

deny() {
  jq -n --arg r "$1" \
    '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
  exit 0
}

# recursive rm (rm -r / -rf / -fr / -R ...)
printf '%s' "$cmd" | grep -Eq 'rm[[:space:]]+-[a-zA-Z]*[rR]' \
  && deny "recursive rm blocked by guard hook - delete manually if truly intended"
# force-push to a protected branch (either flag order)
printf '%s' "$cmd" | grep -Eq 'git[[:space:]]+push([[:space:]]|.)*(--force|-f)([[:space:]]|.)*(main|master)' \
  && deny "force-push to main/master blocked"
printf '%s' "$cmd" | grep -Eq 'git[[:space:]]+push([[:space:]]|.)*(main|master)([[:space:]]|.)*(--force|-f)' \
  && deny "force-push to main/master blocked"
# hard reset
printf '%s' "$cmd" | grep -Eq 'git[[:space:]]+reset[[:space:]]+--hard' \
  && deny "git reset --hard blocked - confirm manually"
# sudo / curl|sh
printf '%s' "$cmd" | grep -Eq '(^|[^[:alnum:]])sudo([[:space:]]|$)' \
  && deny "sudo blocked inside Claude"
printf '%s' "$cmd" | grep -Eq 'curl[^|]*\|[[:space:]]*(sudo[[:space:]]+)?(sh|bash)' \
  && deny "curl | sh blocked - download and inspect first"
exit 0
