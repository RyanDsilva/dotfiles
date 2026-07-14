#!/usr/bin/env bash
# Idempotent Claude Code setup: MCP servers + plugins. No secrets.
# Run after the first darwin-rebuild (bootstrap.sh calls it), or any time to
# reconcile. Safe to re-run.
set -uo pipefail

command -v claude >/dev/null 2>&1 || { echo "claude CLI not found; open Claude Code once, then re-run."; exit 0; }

echo "==> MCP servers (user scope)"
# add() only adds if not already present.
add_mcp() {
  local name="$1"; shift
  if claude mcp list 2>/dev/null | grep -q "^${name}\b"; then
    echo "    $name already configured"
  else
    echo "    adding $name"
    claude mcp add "$name" --scope user "$@" || echo "    (failed to add $name; check the command)"
  fi
}
add_mcp context7 -- npx -y @upstash/context7-mcp
add_mcp playwright -- npx -y @playwright/mcp@latest
add_mcp sequential-thinking -- npx -y @modelcontextprotocol/server-sequential-thinking

echo "==> Plugins (LSP code-intelligence for your stacks)"
# The official marketplace (claude-plugins-official) is available by default.
# Plugin names can drift between releases; adjust if an install fails.
for plugin in \
  lsp-typescript \
  lsp-python \
  lsp-go \
  lsp-rust ; do
  echo "    installing $plugin"
  claude plugin install "${plugin}@claude-plugins-official" 2>/dev/null \
    || echo "    (could not install $plugin - check the name with: claude plugin marketplace)"
done

echo "==> Done. Verify with: claude mcp list  and  claude plugin list"
