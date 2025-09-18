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
    
    # Autostart Zellij terminal multiplexer (currently disabled)
    # Uncomment the line below to auto-start Zellij in new shells
    # eval "$(zellij setup --generate-auto-start fish)"
end

# Environment variables
set -gx EDITOR /run/current-system/sw/bin/hx  # Set Helix as default editor
