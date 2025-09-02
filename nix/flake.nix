{
  description = "MacOS nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

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

          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages = [
            pkgs.helix
            pkgs.zellij
            pkgs.fish
            pkgs.mkalias
            pkgs.nil
            pkgs.zellij
            pkgs._1password-cli
          ];

          fonts.packages = [
            pkgs.nerd-fonts.jetbrains-mono
          ];

          homebrew = {
            enable = true;
            brews = [
              "mas"
              "sst/tap/opencode"
              "postgresql"
              "rbenv"
            ];
            casks = [
              "raycast"
              "ghostty"
            ];
            masApps = {
              # "yoink" = 457622435;
              "magnet" = 441258766;
            };
            onActivation.cleanup = "zap";
            onActivation.autoUpdate = true;
            onActivation.upgrade = true;
          };

          system.activationScripts.applications.text =
            let
              env = pkgs.buildEnv {
                name = "system-applications";
                paths = config.environment.systemPackages;
                pathsToLink = "/Applications";
              };
            in
            pkgs.lib.mkForce ''
              # Set up applications.
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

          # macOS system settings
          system.defaults = {

          };
          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";

          # Enable alternative shell support in nix-darwin.
          programs.fish.enable = true;

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
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#simple
      darwinConfigurations."macbook" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
        ];
      };
    };
}
