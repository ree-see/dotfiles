# Nushell Configuration

# General settings
$env.config = {
    show_banner: false
    table: {
        mode: rounded
        index_mode: always
    }
    completions: {
        case_sensitive: false
        quick: true
        partial: true
        algorithm: "fuzzy"
    }
    history: {
        max_size: 100_000
        sync_on_enter: true
        file_format: "sqlite"
    }
    ls: {
        use_ls_colors: true
        clickable_links: true
    }

    rm: {
        always_trash: false
    }
    explore: {
        help_banner: true
        exit_esc: true
    }
}

# Load zoxide (create if doesn't exist)
if ("~/.config/nushell/zoxide.nu" | path expand | path exists) {
    source ~/.config/nushell/zoxide.nu
}

# Source custom scripts directly
source ~/.config/nushell/scripts/cfg.nu
source ~/.config/nushell/scripts/mkcd.nu
source ~/.config/nushell/scripts/rebuild.nu
source ~/.config/nushell/scripts/rollback.nu
source ~/.config/nushell/scripts/nixstatus.nu
source ~/.config/nushell/scripts/prompt.nu

# Aliases
alias ll = ls -la
alias la = ls -la  
alias l = ls

# Git aliases
alias gs = git status
alias ga = git add
alias gc = git commit
alias gp = git push
source $"($nu.home-path)/.cargo/env.nu"
