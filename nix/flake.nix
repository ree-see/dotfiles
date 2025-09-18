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
      url = "path:/Users/reesee/dev/helix";
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
            helix-custom.packages.${pkgs.system}.default  # Custom Helix editor build
            pkgs.fish          # Fish shell
            pkgs.zellij        # Terminal multiplexer
            pkgs.yazi          # Terminal file manager
            pkgs.lazygit       # Git TUI
            pkgs.zoxide        # Smart cd replacement
            pkgs.claude-code   # Claude Code CLI
            
            # System utilities
            pkgs.mkalias       # Create macOS aliases
            pkgs._1password-cli # 1Password CLI
            
            # Development languages and runtimes
            pkgs.nodejs        # Node.js runtime
            pkgs.yarn          # Node.js package manager
            pkgs.ruby          # Ruby language
            pkgs.lua           # Lua scripting language
            pkgs.nil           # Nix language server
            
            # Development monitoring
            pkgs.watchman      # File watching service

            # JavaScript/TypeScript development tools
            pkgs.nodePackages.typescript-language-server
            pkgs.nodePackages.vscode-langservers-extracted # Includes eslint-language-server
            pkgs.nodePackages.prettier
            # pkgs.nodePackages."@expo/cli"  # Expo CLI for React Native

            # Ruby development tools
            pkgs.rubyPackages.solargraph   # Ruby language server
          ];
          # System fonts installed via Nix
          fonts.packages = [
            pkgs.nerd-fonts.jetbrains-mono  # JetBrains Mono with Nerd Font icons
          ];

          # Homebrew integration for applications not available in nixpkgs
          homebrew = {
            enable = true;
            
            # Command-line tools via Homebrew
            brews = [
              "mas"          # Mac App Store CLI
              "postgresql"   # PostgreSQL database
              "rbenv"        # Ruby version manager
            ];
            
            # GUI applications via Homebrew Cask
            casks = [
              "raycast"      # Productivity launcher
              "ghostty"      # GPU-accelerated terminal
              "wezterm"      # Advanced terminal emulator
            ];
            
            # Mac App Store applications
            masApps = {
              # "yoink" = 457622435;     # Clipboard manager (disabled)
              "magnet" = 441258766;      # Window management
              "xcode" = 497799835;       # Apple's IDE
            };
            
            # Homebrew maintenance settings
            onActivation.cleanup = "zap";      # Remove unlisted packages
            onActivation.autoUpdate = true;    # Update Homebrew itself
            onActivation.upgrade = true;       # Upgrade installed packages
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
          security.pam.services.sudo_local.touchIdAuth = true;  # Enable Touch ID for sudo

          # macOS system preferences
          system.defaults = {
            # NSGlobalDomain._HIHideMenuBar = true;  # Hide menu bar (disabled)
          };
          
          # Nix configuration
          nix.settings.experimental-features = "nix-command flakes";  # Enable flakes and new CLI

          # Shell configuration
          programs.fish.enable = true;  # Enable Fish shell system-wide

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
