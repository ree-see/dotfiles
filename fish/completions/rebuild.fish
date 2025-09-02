# Completions for rebuild command
complete -c rebuild -f

# Complete with darwin-rebuild operations
complete -c rebuild -a "switch" -d "Build and activate configuration"
complete -c rebuild -a "build" -d "Build configuration without activating"
complete -c rebuild -a "test" -d "Build and test configuration"

# Options
complete -c rebuild -l commit -s c -d "Auto-commit changes before rebuilding"
complete -c rebuild -l diff -s d -d "Show configuration diff"
complete -c rebuild -l backup -s b -d "Backup current generation"
complete -c rebuild -l help -s h -d "Show help message"