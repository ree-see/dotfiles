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

    # Initialize rbenv for Ruby development
    if command -v rbenv >/dev/null
        rbenv init - fish | source
    end

    # Autostart Zellij terminal multiplexer (currently disabled)
    # Uncomment the line below to auto-start Zellij in new shells
    # eval "$(zellij setup --generate-auto-start fish)"
    zoxide init fish | source
end

# Environment variables
set -gx EDITOR /run/current-system/sw/bin/hx # Set Helix as default editor
source /Users/reesee/.config/op/plugins.sh
