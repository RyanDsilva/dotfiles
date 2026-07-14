{ config, pkgs, user, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
  # Edit-in-place: the real file stays in this repo, the app path just points at it.
  mkLink = config.lib.file.mkOutOfStoreSymlink;
in

{
  home.username = user;
  home.homeDirectory = "/Users/${user}";
  home.stateVersion = "24.11";

  # ------------------------------------------------------------------ packages
  home.packages = with pkgs; [
    # search / files / git
    ripgrep      # fast search
    fd           # fast find
    fzf          # fuzzy finder
    jq           # json on the command line
    lazygit
    delta        # syntax-highlighted git diffs (wired into git below)

    # system & monitoring
    dust         # du, visual
    duf          # df, prettier
    procs        # ps, human-readable
    hyperfine    # command benchmarking
    tokei        # count lines of code

    # data / http / text
    yq-go        # jq for YAML/XML/TOML
    sd           # sed, intuitive
    jless        # JSON pager
    xh           # fast HTTP client
    glow         # render markdown in the terminal
    watchexec    # run a command on file changes

    # language toolchain managers (they own per-project versions; no global conflicts)
    mise         # per-project Node/Go/etc versions
    uv           # Python packaging / venvs
    bun          # JS runtime + package manager
    rustup       # Rust toolchains
    go

    # native build tools
    ffmpeg
    cmake

    # LaTeX (declarative, replaces basictex/tex-live-utility)
    texliveMedium

    # font everything renders in
    maple-mono.NF   # VERIFY: confirm this attr on first `nix flake check`
  ];
  fonts.fontconfig.enable = true;

  home.sessionVariables.EDITOR = "zed --wait";

  # ~/Screenshots target for the screencapture.location default set in configuration.nix
  home.file."Screenshots/.keep".text = "";

  # Trusted SSH signing keys, keyed by email (principal), for local commit-signature
  # verification. Referenced by gpg.ssh.allowedSignersFile in the git config below.
  home.file.".config/git/allowed_signers".text =
    "ryan.dsilva.98@gmail.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICiPn/1lTAdPv9x4cpS1ZSOLJJ6w78TlhvXFRXT6PSoZ\n";

  # -------------------------------------------------------------------- theme
  # Catppuccin Frappé, blue accent, applied to every supported program at once.
  catppuccin = {
    enable = true;
    # Keep opting ports in by hand (below) instead of auto-enrolling every
    # supported program when the new autoEnable default flips on.
    autoEnable = false;
    flavor = "frappe";
    accent = "blue";
    bat.enable = true;
    starship.enable = true;
    btop.enable = true;
    fzf.enable = true;
  };

  # --------------------------------------------- CLI tools (home-manager modules)
  # Modules wire shell integration automatically, so no hand-written eval hooks.
  programs.eza = {
    enable = true;
    git = true;
  };
  programs.bat.enable = true;
  programs.btop.enable = true;
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    flags = [ "--disable-up-arrow" ];  # keep Up = normal history; Ctrl-R = atuin
  };
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.gh.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;  # cached per-project flake dev shells
  };

  # -------------------------------------------------------------------- shell
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;      # ghost text from history
    syntaxHighlighting.enable = true;  # commands turn green when valid
    history = {
      size = 50000;
      save = 50000;
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;   # a leading space keeps a command out of history
      share = true;
      extended = true;
    };
    initContent = ''
      bindkey '^f' autosuggest-accept
    '';
    shellAliases = {
      ".." = "cd ..";
      add = "git add .";
      push = "git push";
      pull = "git pull";
      m = "git switch main";
      cc = "claude --dangerously-skip-permissions";
      ls = "eza";
      ll = "eza -la --git --icons";
      cat = "bat";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      # Tasteful single line: dir + git + nix-shell + relevant language versions.
      # Language modules only render inside a matching project, so it stays clean.
      format =
        "$directory$git_branch$git_status$nix_shell"
        + "$nodejs$python$golang$rust$cmd_duration$line_break$character";

      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
      };

      git_branch.format = "[$symbol$branch]($style) ";
      # Compact status glyphs: !modified +staged ?untracked ⇡ahead ⇣behind, etc.
      git_status = {
        format = "([$all_status$ahead_behind]($style) )";
        modified = "!\${count}";
        staged = "+\${count}";
        untracked = "?\${count}";
        stashed = "*\${count}";
        renamed = "»\${count}";
        deleted = "✘\${count}";
        conflicted = "=\${count}";
        ahead = "⇡\${count}";
        behind = "⇣\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
      };

      # Snowflake shows when you're inside a nix/direnv dev shell.
      nix_shell.format = "[❄️ $name]($style) ";

      cmd_duration.format = "[$duration]($style) ";

      character = {
        success_symbol = "[❯](blue)";
        error_symbol = "[❯](red)";
      };
    };
  };

  # ---------------------------------------------------------------------- git
  programs.git = {
    enable = true;
    ignores = [
      ".DS_Store"
      "result"
      "result-*"
      ".direnv/"
      ".env"
      ".env.local"
    ];
    # Freeform git config (26.05 renamed userName/userEmail/aliases/extraConfig into this).
    settings = {
      user.name = "Ryan Dsilva";
      user.email = "ryan.dsilva.98@gmail.com";

      alias = {
        s = "status -sb";
        lg = "log --oneline --graph --decorate";
        co = "checkout";
        br = "branch";
        undo = "reset --soft HEAD~1";
        amend = "commit --amend --no-edit";
      };

      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      push.default = "simple";
      pull.rebase = true;
      fetch.prune = true;
      fetch.pruneTags = true;
      rebase.autoStash = true;
      rebase.autoSquash = true;
      diff.algorithm = "histogram";
      diff.colorMoved = "default";
      merge.conflictStyle = "zdiff3";
      rerere.enabled = true;
      rerere.autoUpdate = true;
      commit.verbose = true;
      column.ui = "auto";
      branch.sort = "-committerdate";
      tag.sort = "version:refname";
      help.autocorrect = "prompt";
      core.autocrlf = "input";

      # SSH commit signing via 1Password. Two one-time steps to turn it on:
      #   1. paste your SSH *public* key into user.signingkey below
      #   2. flip commit.gpgsign to true, and add the same key as a Signing Key on GitHub
      # Left off by default so commits never fail before you've done step 1.
      gpg.format = "ssh";
      gpg.ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      user.signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICiPn/1lTAdPv9x4cpS1ZSOLJJ6w78TlhvXFRXT6PSoZ ryan.dsilva.98@gmail.com";
      commit.gpgsign = true;
      # Lets `git log --show-signature` verify our own SSH-signed commits locally
      # (GitHub verifies via the Signing key you added there; this is the local half).
      gpg.ssh.allowedSignersFile = "${config.home.homeDirectory}/.config/git/allowed_signers";
    };
  };

  # delta moved out of programs.git into its own module (26.05). Explicit git
  # integration replaces the deprecated automatic enablement.
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };

  # 1Password as the SSH agent (keys never leave 1Password).
  # enableDefaultConfig = false opts out of home-manager's implicit "*" defaults
  # (being removed in a future release); we set exactly what we want on "*" instead.
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings."*" = {
      # Path contains a space ("Group Containers"), so it must be quoted in the
      # generated config or ssh errors with "extra arguments at end of line".
      identityAgent = ''"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"'';
    };
  };

  # ------------------------------------------------ edit-in-place config symlinks
  # These point each app's real config path at the file in this repo. Edit in the
  # app OR edit the repo file - it's the same file, versioned, no rebuild needed.
  home.file.".config/ghostty/config".source = mkLink "${dotfiles}/home/.config/ghostty/config";
  home.file.".config/herdr".source = mkLink "${dotfiles}/home/.config/herdr";

  home.file.".config/zed/settings.json".source = mkLink "${dotfiles}/home/.config/zed/settings.json";
  home.file.".config/zed/keymap.json".source = mkLink "${dotfiles}/home/.config/zed/keymap.json";

  home.file."Library/Application Support/Code/User/settings.json".source =
    mkLink "${dotfiles}/home/vscode/settings.json";
  home.file."Library/Application Support/Code/User/keybindings.json".source =
    mkLink "${dotfiles}/home/vscode/keybindings.json";

  # Claude Code. Secrets (settings.local.json, .credentials.json) and machine-local
  # state (projects/ auto-memory) live only in ~/.claude, never symlinked or committed.
  # Everything below is edit-in-place: tweak a skill/agent/hook here or in ~/.claude,
  # it's the same file, and it grows with you.
  home.file.".claude/settings.json".source = mkLink "${dotfiles}/home/.claude/settings.json";
  home.file.".claude/statusline.sh".source = mkLink "${dotfiles}/home/.claude/statusline.sh";
  home.file.".claude/CLAUDE.md".source = mkLink "${dotfiles}/home/AGENTS.md";
  home.file.".claude/agents".source = mkLink "${dotfiles}/home/.claude/agents";
  home.file.".claude/skills".source = mkLink "${dotfiles}/home/.claude/skills";
  home.file.".claude/rules".source = mkLink "${dotfiles}/home/.claude/rules";
  home.file.".claude/hooks".source = mkLink "${dotfiles}/home/.claude/hooks";
  home.file.".claude/memory/preferences.md".source =
    mkLink "${dotfiles}/home/.claude/memory/preferences.md";
}
