#!/usr/bin/env bash
# Snapshot Claude Code's native auto-memory (plain markdown, per-repo) to a folder.
# Usage: export-memory.sh [dest-dir]   (default: ~/claude-memory-export-<date>)
set -euo pipefail

src="$HOME/.claude/projects"
dest="${1:-$HOME/claude-memory-export-$(date +%Y%m%d)}"

if [ ! -d "$src" ]; then
  echo "No auto-memory found at $src"
  exit 0
fi

mkdir -p "$dest"
# Copy only the memory/ subdirs (skip session state / transcripts).
found=0
while IFS= read -r memdir; do
  repo=$(basename "$(dirname "$memdir")")
  cp -R "$memdir" "$dest/$repo"
  found=1
done < <(find "$src" -type d -name memory)

if [ "$found" -eq 1 ]; then
  echo "Exported per-repo memory to: $dest"
else
  echo "No memory/ directories found yet under $src"
fi
