{
  description = "MacOS nix-darwin system flake";

  # This flake provides a declarative nix-darwin configuration for macOS
  #
  # Key features:
  # - Custom Helix editor build from local development path
  # - Comprehensive development environment with Node.js, Ruby, and development tools
  # - Homebrew integration for applications not available in nixpkgs
  # - Touch ID sudo authentication
  # - Automatic application linking to /Applications/Nix Apps
  #
  # Usage:
  #   darwin-rebuild switch --flake .#macbook
  #   Or use the custom `rebuild` command from fish shell
  #
  # The configuration targets Apple Silicon Macs (aarch64-darwin)

  inputs = {
    # Core nix packages and darwin system management
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Custom Helix editor build from local development repository
    # This allows using a custom-built version with personal modifications
    helix-custom = {
      url = "github:ree-see/helix/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Homebrew repositories for applications not available in nixpkgs
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      helix-custom,
      homebrew-core,
      homebrew-cask,
      nixpkgs,
    }:
    let
      configuration =
        { pkgs, config, ... }:
        {

          system.primaryUser = "reesee";

          nixpkgs.config.allowUnfree = true;
          # need to install ghostty version 1.1.3 is flagged as broken from nixpkgs
          # nixpkgs.config.allowBroken = true;

          # System packages installed via Nix
          # These are available system-wide and managed declaratively
          # To search for packages: nix search nixpkgs <package-name>
          environment.systemPackages = [
            # Core development tools
            helix-custom.packages.${pkgs.system}.default # Custom Helix editor build
            pkgs.fish # Fish shell
            pkgs.yazi # Terminal file manager
            pkgs.zoxide # Smart cd replacement
            pkgs.claude-code # Claude Code CLI
            pkgs.gh

            # System utilities
            pkgs.mkalias # Create macOS aliases
            pkgs._1password-cli # 1Password CLI
            pkgs.pre-commit # Git pre-commit hook framework
            pkgs.asdf-vm # Multiple runtime version manager

            # Development languages and runtimes
            pkgs.nodejs # Node.js runtime
            pkgs.nodePackages.pnpm # Fast, disk-efficient package manager
            pkgs.go # Go programming language
            pkgs.golangci-lint # Go linter
            pkgs.lua # Lua scripting language
            pkgs.nil # Nix language server
            pkgs.uv # python package manager

            # Development monitoring
            pkgs.watchman # File watching service

            # JavaScript/TypeScript development tools
            pkgs.nodePackages.typescript-language-server
            pkgs.nodePackages.vscode-langservers-extracted # Includes eslint-language-server
            pkgs.nodePackages.prettier
          ];

          # System fonts installed via Nix
          fonts.packages = [
            pkgs.nerd-fonts.jetbrains-mono # JetBrains Mono with Nerd Font icons
          ];

          # Homebrew integration for applications not available in nixpkgs
          homebrew = {
            enable = true;

            # Command-line tools via Homebrew
            brews = [
              "mas" # Mac App Store CLI
              "postgresql@16" # PostgreSQL database
              "libyaml" # YAML parser library for Ruby
              "openssl@3" # OpenSSL for Ruby compilation
              "ifstat" # Network interface statistics
            ];

            # GUI applications via Homebrew Cask
            casks = [
              "1password" # Password manager desktop app
              "claude" # AI assistant desktop app
              "google-chrome" # Web browser
              "raycast" # Productivity launcher
              "spotify" # Music streaming
              "warp" # Modern terminal with AI features
              "wezterm" # Advanced terminal emulator
            ];

            # Mac App Store applications
            masApps = {
              "1password-for-safari" = 1569813296; # Safari extension for 1Password
              "apple-configurator" = 1037126344; # Apple device management
              "magnet" = 441258766; # Window management
              "overpicture" = 1188020834; # Picture-in-picture for any window
              "wipr" = 1662217862; # Safari content blocker
              "xcode" = 497799835; # Apple development IDE
            };

            # Homebrew maintenance settings
            onActivation.cleanup = "zap"; # Remove unlisted packages
            onActivation.autoUpdate = true; # Update Homebrew itself
            onActivation.upgrade = true; # Upgrade installed packages
          };

          # Custom activation script to link Nix applications to /Applications
          # This makes Nix-installed GUI apps accessible via Spotlight and Finder
          system.activationScripts.applications.text =
            let
              env = pkgs.buildEnv {
                name = "system-applications";
                paths = config.environment.systemPackages;
                pathsToLink = "/Applications";
              };
            in
            pkgs.lib.mkForce ''
              # Set up applications in /Applications/Nix Apps
              echo "setting up /Applications..." >&2
              rm -rf /Applications/Nix\ Apps
              mkdir -p /Applications/Nix\ Apps
              find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
              while read -r src; do
              app_name=$(basename "$src")
              echo "copying $src" >&2
              ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
              done
            '';

          # Security configuration
          security.pam.services.sudo_local.touchIdAuth = true; # Enable Touch ID for sudo

          # macOS system preferences
          # These settings are applied declaratively and will be set on every rebuild
          system.defaults = {
            # Dock settings
            dock = {
              autohide = true; # Automatically hide and show the Dock
              autohide-delay = 0.0; # Remove Dock show delay
              autohide-time-modifier = 0.2; # Speed up Dock animation
              orientation = "bottom"; # Dock position
              show-recents = false; # Don't show recent applications
              tilesize = 48; # Icon size
              minimize-to-application = true; # Minimize windows into application icon
              mru-spaces = false; # Don't automatically rearrange spaces
            };

            # Finder settings
            finder = {
              AppleShowAllExtensions = true; # Show all file extensions
              AppleShowAllFiles = false; # Don't show hidden files by default
              FXEnableExtensionChangeWarning = false; # Disable file extension change warning
              FXPreferredViewStyle = "Nlsv"; # List view by default
              ShowPathbar = true; # Show path bar
              ShowStatusBar = true; # Show status bar
              _FXShowPosixPathInTitle = true; # Show full path in title
            };

            # Trackpad settings
            trackpad = {
              Clicking = true; # Tap to click
              TrackpadRightClick = true; # Two-finger right click
              TrackpadThreeFingerDrag = false; # Disable three finger drag
            };

            # Keyboard settings
            NSGlobalDomain = {
              AppleKeyboardUIMode = 3; # Full keyboard access for all controls
              ApplePressAndHoldEnabled = false; # Disable press-and-hold for accent characters
              InitialKeyRepeat = 15; # Fast initial key repeat (normal = 15)
              KeyRepeat = 2; # Fast key repeat (normal = 2)
              NSAutomaticCapitalizationEnabled = false; # Disable automatic capitalization
              NSAutomaticDashSubstitutionEnabled = false; # Disable smart dashes
              NSAutomaticPeriodSubstitutionEnabled = false; # Disable period with double-space
              NSAutomaticQuoteSubstitutionEnabled = false; # Disable smart quotes
              NSAutomaticSpellingCorrectionEnabled = false; # Disable auto-correct
              NSNavPanelExpandedStateForSaveMode = true; # Expand save panel by default
              NSNavPanelExpandedStateForSaveMode2 = true; # Expand save panel by default
              PMPrintingExpandedStateForPrint = true; # Expand print panel by default
              PMPrintingExpandedStateForPrint2 = true; # Expand print panel by default
            };

            # Screen settings
            screencapture = {
              location = "~/Desktop"; # Save screenshots to Desktop
              type = "png"; # Screenshot format
            };

            # Menu bar and system UI
            menuExtraClock = {
              Show24Hour = true; # 24-hour time format
              ShowDate = 1; # Show date in menu bar (0 = never, 1 = always, 2 = when space allows)
            };

            # Activity Monitor
            ActivityMonitor = {
              IconType = 5; # Show CPU usage in Dock icon
              OpenMainWindow = true; # Open main window on launch
              ShowCategory = 100; # Show all processes
            };

            # Other settings
            screensaver = {
              askForPassword = true; # Require password after screensaver
              askForPasswordDelay = 0; # Immediately require password
            };
          };

          # Nix configuration
          nix.settings.experimental-features = "nix-command flakes"; # Enable flakes and new CLI

          # Shell configuration
          programs.fish.enable = true; # Enable Fish shell system-wide

          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;

          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 6;

          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = "aarch64-darwin";
        };
    in
    {
      # Darwin configuration for macbook
      # Build with: darwin-rebuild switch --flake .#macbook
      # Or use the custom `rebuild` command from Fish shell
      darwinConfigurations."macbook" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
        ];
      };
    };
}
