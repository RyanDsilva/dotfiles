#!/usr/bin/env bash
# Takes a fresh Mac from nothing to a built nix-darwin config.
# Run this once. After it finishes, use ./rebuild.sh for every later change.
# Designed to be non-interactive: the only prompt is your sudo password (macOS
# requires it for system-level changes).
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

echo "==> Step 1: Xcode Command Line Tools (headless, no GUI prompt)"
if xcode-select -p >/dev/null 2>&1; then
  echo "    already installed"
else
  # The softwareupdate trick installs the CLT without the click-through dialog.
  TRIGGER="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
  touch "$TRIGGER"
  LABEL="$(softwareupdate -l 2>/dev/null \
    | awk -F'Label: ' '/Command Line Tools/{print $2}' \
    | sort -V | tail -n1)"
  if [ -n "$LABEL" ]; then
    softwareupdate -i "$LABEL" --verbose || true
  else
    echo "    (could not resolve a CLT label; falling back to xcode-select --install)"
    xcode-select --install || true
  fi
  rm -f "$TRIGGER"
fi

echo "==> Step 2: Determinate Nix"
if command -v nix >/dev/null 2>&1; then
  echo "    nix already installed, skipping"
else
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
    | sh -s -- install --no-confirm
  # shellcheck disable=SC1091
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

echo "==> Step 3: symlink this repo to ~/.dotfiles"
# home.nix resolves its mkOutOfStoreSymlink paths through ~/.dotfiles, so this
# has to exist before the first switch or the build will fail to find them.
ln -sfn "$DIR" ~/.dotfiles

echo "==> Step 4: match the configured username to this machine (non-interactive)"
REAL_USER="$(whoami)"
FLAKE_USER="$(sed -nE 's/^[[:space:]]*user = "([^"]+)";.*/\1/p' "$DIR/flake.nix" | head -n1)"
if [ -n "$FLAKE_USER" ] && [ "$FLAKE_USER" != "$REAL_USER" ]; then
  echo "    Rewriting flake.nix user \"$FLAKE_USER\" -> \"$REAL_USER\""
  sed -i '' -E "s/^([[:space:]]*user = \")[^\"]+(\";.*)/\1${REAL_USER}\2/" "$DIR/flake.nix"
else
  echo "    flake.nix already matches \"$REAL_USER\""
fi

echo "==> Step 5: first darwin-rebuild switch (pinned to nix-darwin-26.05)"
# darwin-rebuild doesn't exist yet on a fresh machine, so run it straight from
# the flake this once. sudo resets PATH, so resolve nix's absolute path first.
NIX_BIN="$(command -v nix)"
sudo "$NIX_BIN" run github:nix-darwin/nix-darwin/nix-darwin-26.05#darwin-rebuild -- \
  switch --flake ~/.dotfiles#mac

echo "==> Step 6: VS Code extensions (non-interactive)"
if command -v code >/dev/null 2>&1 && [ -f "$DIR/home/vscode/extensions.txt" ]; then
  while IFS= read -r ext; do
    case "$ext" in ''|\#*) continue;; esac
    code --install-extension "$ext" --force || true
  done < "$DIR/home/vscode/extensions.txt"
else
  echo "    (code CLI not on PATH yet; open VS Code once, then re-run this step)"
fi

echo "==> Step 7: set Ghostty as the default terminal handler (best effort)"
if command -v duti >/dev/null 2>&1; then
  duti -s com.mitchellh.ghostty public.unix-executable all 2>/dev/null || true
  duti -s com.mitchellh.ghostty public.shell-script all 2>/dev/null || true
fi

echo "==> Step 8: Claude Code MCP servers + plugins"
if [ -x "$DIR/home/.claude/setup-claude.sh" ]; then
  "$DIR/home/.claude/setup-claude.sh" || echo "    (setup-claude.sh had issues; re-run it after opening Claude Code once)"
fi

echo
echo "==> Done. Use ./rebuild.sh for future changes."
echo
echo "    Two optional one-time steps this script cannot automate:"
echo "    - Xcode: install it from the App Store (only needed for iOS/native builds)."
echo "    - Git commit signing: paste your 1Password SSH public key into user.signingkey"
echo "      in home.nix, flip commit.gpgsign to true, add the key as a Signing Key on"
echo "      GitHub, then run ./rebuild.sh."
