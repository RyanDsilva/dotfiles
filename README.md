# dotfiles

My personal Mac setup, managed with nix-darwin and home-manager.
One repo, one command, and a fresh Mac ends up configured the same way every time.

Aesthetic: minimal, Catppuccin Frappé (blue accent), Maple Mono. Editor: Zed + VS Code (no Vim). Agent CLI: Claude Code, supervised with herdr.

## What you get

Running the switch builds:

- **System settings** - dark mode, fast key repeat, dock on the left, clean Finder, typing sanity (no autocorrect/smart-quotes), screenshots to `~/Screenshots`.
- **Homebrew apps** - Ghostty, Zed, VS Code, Claude Code, 1Password, OrbStack, Raycast, Chrome, Brave, Stats, Android Studio, Flutter, Skim, plus CLI formulae (herdr, just, jj, mkcert, wget, hf, cocoapods, duti, 1password-cli).
- **Nix packages** - a modern CLI toolbelt, language toolchain managers, and TeX Live (see below).
- **Shell** - zsh with autosuggestions, syntax highlighting, atuin history, zoxide, fzf, direnv, and a starship prompt.
- **Editors** - Zed and VS Code, themed and pre-configured for JS/TS, Python, Rust, Go.
- **Git** - identity, sane defaults, delta diffs, and 1Password SSH commit signing (opt-in).
- **Claude Code** - portable settings, an upgraded statusline, and desktop notifications.

## Prerequisites

- Apple Silicon Mac, by default. Intel: set `nixpkgs.hostPlatform = "x86_64-darwin";` in `configuration.nix`.

## Fresh-machine setup

From a bare clone:

```sh
git clone <this-repo> dotfiles
cd dotfiles
./bootstrap.sh
```

`bootstrap.sh` is non-interactive (the only prompt is your `sudo` password) and does, in order:

1. Installs the Xcode Command Line Tools headlessly (no GUI dialog).
2. Installs Determinate Nix if missing.
3. Symlinks this repo to `~/.dotfiles` (config files resolve through this path).
4. Rewrites the `user` line in `flake.nix` to your macOS username automatically.
5. Runs the first `darwin-rebuild switch`.
6. Installs the VS Code extensions from `home/vscode/extensions.txt`.
7. Registers Ghostty as the default terminal handler.

> **Homebrew `zap` warning:** `configuration.nix` sets `homebrew.onActivation.cleanup = "zap"`, so the first switch **uninstalls any Homebrew app not listed** in `brews`/`casks`. This is intentional (it keeps the machine reproducible). Review the lists before your first run.

### Validate without applying

Once Nix is installed you can check the config builds without touching your system:

```sh
nix flake check
nix build .#darwinConfigurations.mac.system --dry-run
```

## Daily use

Edit config files in place, then apply:

```sh
./rebuild.sh
```

## How the symlinks work (edit-in-place)

The files under `home/` are the **real** files. `home.nix` uses `mkOutOfStoreSymlink` to point each app's real config path straight at the file in this repo, so editing here (or in the app's own UI) is editing your live config - no rebuild needed for a config-file change.

| App | Repo file | Lands at |
|---|---|---|
| Ghostty | `home/.config/ghostty/config` | `~/.config/ghostty/config` |
| Zed | `home/.config/zed/settings.json` | `~/.config/zed/settings.json` |
| VS Code | `home/vscode/settings.json` | `~/Library/Application Support/Code/User/settings.json` |
| herdr | `home/.config/herdr/` | `~/.config/herdr/` |
| Claude Code | `home/.claude/settings.json` | `~/.claude/settings.json` |

You only run `./rebuild.sh` when you change something that isn't a symlinked file - a package list, a macOS default, git settings.

## Tools and how to use them

### Shell and navigation
- **zoxide** - smarter `cd`. `z foo` jumps to the most-used dir matching "foo"; `zi` picks interactively.
- **atuin** - searchable shell history. Press `Ctrl-R` for a fuzzy, per-directory history search.
- **fzf** - fuzzy finder. `Ctrl-T` (files), `Ctrl-R` (history via atuin), `Alt-C` (cd into a dir).
- **eza** - modern `ls` (aliased). `ll` = long list with git status and icons.
- **bat** - `cat` with syntax highlighting and a git gutter (aliased to `cat`).
- **starship** - the prompt; shows dir, git branch/status, and command duration.
- **direnv** - per-project environments. Drop a `.envrc` (`use flake` for nix projects) and the env auto-loads on `cd`.

### Search, data, files
- **ripgrep (`rg`)** - fast recursive search. `fd` - fast file find. `jq` / **yq** - JSON / YAML on the CLI.
- **sd** - find-and-replace (`sd 'foo' 'bar' file`). **jless** - a foldable JSON pager. **glow** - render Markdown.
- **xh** - HTTP client (`xh get example.com`). **watchexec** - run a command on file changes.

### System
- **btop** - resource monitor. **dust** - visual `du`. **duf** - prettier `df`. **procs** - readable `ps`.
- **hyperfine** - benchmark commands. **tokei** - count lines of code.

### Git
- **lazygit** - full-screen git TUI. **jj** - jujutsu, a git-compatible VCS.
- **delta** - the diff pager (built into `git diff`/`git show`). **gh** - GitHub CLI (`gh pr create`, `gh pr view --web`).
- Aliases: `s` status, `lg` graph log, `undo` soft-undo last commit, `amend`. Plus `add`/`push`/`pull`/`m` (switch main).

### Language toolchains
Nix installs the *managers*; they own per-project versions (no global conflicts):
- **mise** - per-project runtime versions. `mise use node@22` in a repo pins it there.
- **uv** - Python. `uv init`, `uv add requests`, `uv run script.py`.
- **bun** - JS runtime + package manager. `bun install`, `bun run dev`.
- **rustup** - Rust toolchains. `go` - installed globally (projects manage deps via `go.mod`).
- **cmake** / **ffmpeg** - native build + media tooling.

### LaTeX
- **texliveMedium** (via nix) - a reproducible TeX Live. Build with `latexmk -pdf file.tex`; preview in **Skim** (SyncTeX-aware).

### Editors
- **Zed** (daily) - opens with `zed .`. Extensions auto-install from `settings.json`. Formats on save (Biome for JS/TS, Ruff for Python, rustfmt, gofmt).
- **VS Code** (`code .`) - same theme/formatters; extensions come from `home/vscode/extensions.txt`.

### Claude Code + herdr
- **claude** - the agent CLI (`cc` alias runs it with permissions skipped). Statusline shows model, context %, git branch, and session cost. Desktop notifications fire when it finishes or needs input.
- **herdr** - terminal multiplexer for supervising multiple agents. Prefix is `Ctrl-b` (see `home/.config/herdr/config.toml`).

## Claude Code

A full, portable Claude Code setup lives under `home/.claude/` and is symlinked edit-in-place, so it travels to any machine and grows as you tune it. Secrets and machine-local state (`settings.local.json`, `.credentials.json`, `projects/` auto-memory) are never committed.

- **Skills** (`skills/`, auto-invoked when relevant): `code-review`, `security-review`, `debugging-protocol`, `plan-writing`, `test-generation`, `explain-codebase`, `handoff` (writes a session summary to `JOURNAL.md`), `reflect` (learns your durable preferences).
- **Subagents** (`agents/`): `code-reviewer` and `security-auditor` (read-only), `debugger`, `test-writer`, `planner`, `researcher` (cheap web research). Each runs in its own context with scoped tools.
- **Hooks** (`hooks/`, wired in `settings.json`):
  - `format.sh` - auto-formats after edits (Biome / Ruff / rustfmt / gofmt).
  - `guard-bash.sh` / `guard-files.sh` - hard-block `rm -rf`, force-push to main, `sudo`, `curl|sh`, and reads/edits of `.env`/keys. These fire even under `cc` (skip-permissions), because hooks run regardless of permission mode.
  - `session-start.sh` - injects git branch, recent commits, and the latest `JOURNAL.md` entry at session start.
  - `notify.sh` - desktop notification + sound (Glass = needs input, Hero = done) with the repo name in the subtitle.
  - `reflect.sh` - at session end, a scoped headless pass appends durable, cross-project preferences to `memory/preferences.md`. Disable by removing it from the `Stop` hook in `settings.json`.
- **Per-language rules** (`rules/{go,python,typescript,rust}.md`): your conventions, loaded when relevant. Edit freely.
- **Memory**: native auto-memory stays on (plain markdown at `~/.claude/projects/<repo>/memory/`). `export-memory.sh` snapshots it to a folder. `memory/preferences.md` is a global, `@import`ed preference store that the `reflect` skill/hook grows over time - version-controlled and inspectable.
- **Permissions**: a curated allow list plus a hard deny list (secrets, `rm -rf`, force-push, `sudo`) as defense-in-depth for non-skip runs.
- **MCP + plugins**: `setup-claude.sh` (run by `bootstrap.sh`, idempotent, no secrets) adds the Context7, Playwright, and Sequential-thinking MCP servers and installs the LSP code-intelligence plugins for your four languages.

Tune any of it by editing the files here or in `~/.claude` - they're the same files.

## macOS cleanup (optional, safe-tier)

Privacy/telemetry hardening that keeps SIP on and is fully reversible.

- **Declarative** (`configuration.nix`, applied on `./rebuild.sh`): opts out of personalized ads, diagnostics auto-submit, usage donation, and Siri + suggestions - all via `defaults`, no SIP.
- **`./cleanup-macos.sh`** (run on demand): disables analytics, Siri, and iCloud-Photos **user** launch agents (`gui/$UID`), leaving Apple Intelligence, core iCloud (Drive/Passwords/Notes), and Location/Find My on. It has a hardcoded do-not-disable guard (contactsd, AirPlayXPCHelper, donotdisturbd, chronod, rapportd, sharingd…) so it can't brick core UX, offers to remove unused bundled apps (GarageBand/iMovie/iWork - re-downloadable), and prints the iCloud toggles to flip by hand.
- **`./revert-cleanup.sh`**: re-enables every agent and restores the script-set default.

Nothing here needs SIP disabled or touches system daemons. See the script headers for details.

## Make it yours

- **Username** - `bootstrap.sh` sets it automatically, or edit the single `user = "ryan"` line in `flake.nix`.
- **Host label** `"mac"` appears in `flake.nix`, `rebuild.sh`, and `bootstrap.sh` - keep them in sync if you rename it.
- **Git signing** - off by default. To enable: paste your 1Password SSH public key into `user.signingkey` in `home.nix`, flip `commit.gpgsign` to `true`, add the key as a Signing Key on GitHub, then `./rebuild.sh`.

## Repo tour

- `flake.nix` - entry point; wires nixpkgs, nix-darwin, home-manager, nix-homebrew, catppuccin.
- `configuration.nix` - system config: macOS defaults, Homebrew.
- `home.nix` - user config: packages, shell, git, theme, and the edit-in-place symlinks.
- `home/` - the real config files (Ghostty, Zed, VS Code, herdr, Claude, shared `AGENTS.md`).
- `bootstrap.sh` / `rebuild.sh` - first-time setup / re-apply.

## License

MIT No Attribution. See `LICENSE`.
