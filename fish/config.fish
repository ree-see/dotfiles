# Fish shell configuration for nix-darwin system
# This configuration provides custom functions and environment setup
# 
# Key features:
# - Custom development commands (rebuild, config, mkcd)
# - Helix editor as default
# - Zellij integration (optional autostart)
#
# Custom functions are defined in fish/functions/ directory

if status is-interactive
    # Commands to run in interactive sessions can go here

    # Initialize asdf for multiple runtime version management
    if test -f /run/current-system/sw/share/asdf-vm/asdf.fish
        source /run/current-system/sw/share/asdf-vm/asdf.fish
    end

    # Add asdf shims to PATH (needed for Fish shell)
    if test -d $HOME/.asdf/shims
        fish_add_path -p $HOME/.asdf/shims
    end

    # Add PostgreSQL to PATH
    if test -d /opt/homebrew/opt/postgresql@16/bin
        fish_add_path /opt/homebrew/opt/postgresql@16/bin
    end

    zoxide init fish | source
end

# Environment variables
set -gx EDITOR /run/current-system/sw/bin/hx # Set Helix as default editor
source /Users/reesee/.config/op/plugins.sh
