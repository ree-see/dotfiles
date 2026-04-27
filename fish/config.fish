# Fish shell configuration for nix-darwin system
# This configuration provides custom functions and environment setup
# 
# Key features:
# - Custom development commands (rebuild, config, mkcd)
# - Helix editor as default
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

    # Add Solana CLI to PATH
    if test -d $HOME/.local/share/solana/install/active_release/bin
        fish_add_path $HOME/.local/share/solana/install/active_release/bin
    end

    # Add Go binaries to PATH
    if test -d $HOME/go/bin
        fish_add_path $HOME/go/bin
    end

    zoxide init fish --cmd cd | source
end

# Environment variables
set -gx EDITOR /run/current-system/sw/bin/hx # Set Helix as default editor

source /Users/reesee/.config/op/plugins.sh

# pnpm
set -gx PNPM_HOME /Users/reesee/Library/pnpm
if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

# Created by `pipx` on 2025-11-01 23:56:39
set PATH $PATH /Users/reesee/Library/Python/3.9/bin

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

# ~/.config/fish/config.fish

function faucet
    source ~/.config/dehouse/privy.env
    uv run --project ~/dev/faucet ~/dev/faucet/faucet.py $argv
end

function fish_prompt
    set -l last_status $status

    # Line 1: [time] user@host cwd [jobs]
    set_color brblack
    echo -n '['(date +%H:%M:%S)'] '
    set_color green
    echo -n $USER'@'(hostname -s)' '
    set_color cyan
    echo -n (prompt_pwd)

    # Job count
    set -l jobs (jobs -p | wc -l | string trim)
    if test $jobs -gt 0
        set_color red
        echo -n " [$jobs]"
    end

    echo # newline

    # Line 2: (branch *) >
    set -l branch (git branch --show-current 2>/dev/null)
    if test -n "$branch"
        set_color yellow
        echo -n "($branch"

        # Dirty status
        if not git diff --quiet 2>/dev/null; or not git diff --cached --quiet 2>/dev/null
            set_color red
            echo -n " *"
        end

        set_color yellow
        echo -n ") "
    end

    set_color normal
    echo -n '> '
end

# OpenClaw Completion
source "/Users/reesee/.openclaw/completions/openclaw.fish"
