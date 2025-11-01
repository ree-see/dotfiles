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

    # Disable terminal focus reporting to prevent escape sequences in input
    # Fixes [I[O characters appearing in Claude Code and other applications
    printf '\e[?1004l'

    # Initialize asdf for multiple runtime version management
    if test -f /run/current-system/sw/share/asdf-vm/asdf.fish
        source /run/current-system/sw/share/asdf-vm/asdf.fish
    end

    # Add asdf shims to PATH (needed for Fish shell) - PRIORITY
    if test -d $HOME/.asdf/shims
        fish_add_path -g -p $HOME/.asdf/shims
    end

    # Add PostgreSQL to PATH
    if test -d /opt/homebrew/opt/postgresql@16/bin
        fish_add_path /opt/homebrew/opt/postgresql@16/bin
    end

    zoxide init fish --cmd cd | source
end

# Environment variables
set -gx EDITOR /run/current-system/sw/bin/hx # Set Helix as default editor

# ============================================
# Claude Code MCP Server API Keys
# ============================================

# Tavily API Key (Required for web search, extraction, crawling)
# Get your key from: https://app.tavily.com/
# Usage: Web search, content extraction, site crawling, site mapping
set -gx TAVILY_API_KEY "YOUR_TAVILY_API_KEY_HERE"

# Context7 API Key (Optional - provides higher rate limits and private repo access)
# Get your key from: https://context7.com/dashboard
# Usage: Up-to-date library documentation and code examples
# set -gx CONTEXT7_API_KEY "YOUR_CONTEXT7_API_KEY_HERE"

# 21st.dev Magic API Key (Required for UI component generation)
# Get your key from: https://21st.dev/magic/console
# Usage: UI component generation from 21st.dev library
# set -gx TWENTY_FIRST_API_KEY "YOUR_21ST_DEV_API_KEY_HERE"

# ============================================

source /Users/reesee/.config/op/plugins.sh

# pnpm
set -gx PNPM_HOME "/Users/reesee/Library/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
