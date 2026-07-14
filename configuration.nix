{ user, ... }:

{
  # Determinate already manages the Nix daemon, so nix-darwin shouldn't.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin"; # use x86_64-darwin for Intel CPU

  system.primaryUser = user;
  users.users.${user} = {
    home = "/Users/${user}";
  };
  system.stateVersion = 6;

  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 2;          # fast key repeat
      InitialKeyRepeat = 15;  # short delay before repeat
      AppleShowAllExtensions = true;
      # Menu bar stays visible on purpose (decision 9): _HIHideMenuBar intentionally unset.

      # Typing sanity: stop macOS rewriting code/commands as I type.
      ApplePressAndHoldEnabled = false;             # hold a key = repeat, not accent popup
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;   # keep literal -- in CLI flags
      NSAutomaticQuoteSubstitutionEnabled = false;  # keep straight quotes in code/JSON
      NSAutomaticPeriodSubstitutionEnabled = false;

      # Real F1-F12 by default (already how this Mac is set).
      "com.apple.keyboard.fnState" = true;
    };

    dock = {
      autohide = false;        # always visible, matches how I run it
      orientation = "left";    # dock on the left
      tilesize = 42;
      show-recents = false;    # no recent-apps clutter
      mru-spaces = false;      # keep Spaces in a fixed order
    };

    finder = {
      FXPreferredViewStyle = "Nlsv";        # list view
      CreateDesktop = false;                # clean desktop
      ShowPathbar = true;
      ShowStatusBar = true;
      FXDefaultSearchScope = "SCcf";        # search the current folder, not the whole Mac
      FXEnableExtensionChangeWarning = false;
    };

    screencapture = {
      location = "~/Screenshots";           # off the desktop (dir created in home.nix)
      type = "png";
      disable-shadow = true;
    };

    WindowManager = {
      GloballyEnabled = false;                  # Stage Manager off
      EnableStandardClickToShowDesktop = false; # don't hide windows on a stray wallpaper click
    };

    trackpad.Clicking = true;                   # tap to click

    CustomUserPreferences = {
      # Stats menu-bar app. Adjust keys after tweaking Stats in its GUI once and
      # running: defaults read eu.exelban.Stats
      "eu.exelban.Stats" = {
        CPU_state = "true";
        RAM_state = "true";
        Network_state = "true";
        Battery_state = "false";
        combinedModulesInOneMenuBar = "true";
        update-interval = "3";
        telemetry = "false";
      };

      # --- Privacy / telemetry opt-outs (safe tier, no SIP) ---
      # Personalized ads + ad tracking
      "com.apple.AdLib" = {
        allowApplePersonalizedAdvertising = false;
        forceLimitAdTracking = true;
      };
      # Siri off (Apple Intelligence stays on - handled separately)
      "com.apple.assistant.support" = { "Assistant Enabled" = false; };
      "com.apple.Siri" = {
        StatusMenuVisible = false;
        VoiceTriggerUserEnabled = false;
      };
      # Siri / Spotlight suggestions + Lookup
      "com.apple.lookup.shared".LookupSuggestionsDisabled = true;
      "com.apple.suggestions".SuggestionsAppLibraryEnabled = false;
      # Proactive usage donation
      "com.apple.UsageTracking" = {
        CoreDonationsEnabled = false;
        UDCAutomationEnabled = false;
      };
      # No crash-report dialog nag
      "com.apple.CrashReporter".DialogType = "none";
    };

    # System-scoped (/Library/Preferences) telemetry opt-out: don't auto-submit
    # diagnostics to Apple.
    CustomSystemPreferences."com.apple.SubmitDiagInfo" = {
      AutoSubmit = false;
      AutoSubmitVersion = 4;
    };
  };

  nix-homebrew = {
    enable = true;
    inherit user;
  };
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";  # remove anything not listed here (see AGENTS.md - intentional)
    onActivation.autoUpdate = true;
    onActivation.extraFlags = [ "--force" ];
    brews = [
      "herdr"          # terminal agent multiplexer
      "just"           # command runner
      "jj"             # jujutsu VCS
      "mkcert"         # local HTTPS certs
      "wget"
      "hf"             # Hugging Face CLI
      "cocoapods"      # Flutter/iOS builds need it
      "duti"           # set Ghostty as default terminal handler (used by bootstrap.sh)
    ];
    casks = [
      "1password-cli"        # the `op` command (distributed as a cask, not a formula)
      "ghostty"              # terminal
      "zed"                  # editor (daily)
      "visual-studio-code"   # editor (fallback / heavy extensions)
      "claude-code"          # agent CLI
      "1password"            # passwords + SSH agent + commit signing
      "orbstack"             # Docker / Linux VMs
      "raycast"              # launcher + window management
      "google-chrome"
      "brave-browser"
      "stats"                # menu-bar system monitor
      "android-studio"       # Android / Flutter
      "flutter"              # Flutter SDK
      "skim"                 # PDF viewer (LaTeX SyncTeX)
    ];
    # Xcode is not a cask; bootstrap.sh prints a reminder to install it from the App Store.
    # Xcode Command Line Tools are installed non-interactively by bootstrap.sh.
  };
}
