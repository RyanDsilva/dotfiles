#!/usr/bin/env bash
# Desktop notification + sound cue.
#   arg 1: "input" (Claude needs you, Glass) or "done" (finished, Hero)
# The repo name goes in the subtitle so you know which pane/agent pinged.
kind="${1:-done}"
repo=$(basename "$PWD" 2>/dev/null)
case "$kind" in
  input) msg="Needs your input"; sound="Glass" ;;
  *)     msg="Finished";         sound="Hero"  ;;
esac

if command -v terminal-notifier >/dev/null 2>&1; then
  terminal-notifier -title "Claude Code" -subtitle "$repo" -message "$msg" \
    -sender com.anthropic.claudefordesktop >/dev/null 2>&1
else
  osascript -e "display notification \"$msg\" with title \"Claude Code\" subtitle \"$repo\"" >/dev/null 2>&1
fi
afplay "/System/Library/Sounds/${sound}.aiff" >/dev/null 2>&1 &
exit 0
