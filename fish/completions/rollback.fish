# Completions for rollback command
complete -c rollback -f

# Complete with available generation numbers
complete -c rollback -a "(darwin-rebuild --list-generations 2>/dev/null | string match -r '^\s*(\d+)' | head -20)" -d "Available generation"

# Options
complete -c rollback -l list -s l -d "List available generations"
complete -c rollback -l help -s h -d "Show help message"