#!/usr/bin/env bash
# PreToolUse(Edit|Write|Read): block access to secret / key files.
file=$(jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null)
[ -z "$file" ] && exit 0
if printf '%s' "$file" | grep -Eq '(^|/)\.env($|\.[^/]*$)|\.pem$|(^|/)id_(rsa|ed25519|ecdsa)($|\.)|(^|/)secrets?/|(^|/)\.ssh/|(^|/)credentials(\.json)?$|\.p12$|\.pfx$|\.key$'; then
  jq -n '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:"Access to secret/key files is blocked by guard hook"}}'
fi
exit 0
