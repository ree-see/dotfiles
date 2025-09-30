function rollback --description "Rollback to previous nix-darwin generation"
    set -l target_gen ""
    set -l list_only false
    
    # Parse arguments
    for arg in $argv
        switch $arg
            case --list -l
                set list_only true
            case --help -h
                echo "Usage: rollback [GENERATION] [OPTIONS]"
                echo ""
                echo "Arguments:"
                echo "  GENERATION  - Generation number to rollback to (default: previous)"
                echo ""
                echo "Options:"
                echo "  --list, -l  - List available generations"
                echo "  --help, -h  - Show this help"
                echo ""
                echo "Examples:"
                echo "  rollback           # Rollback to previous generation"
                echo "  rollback 42        # Rollback to generation 42"
                echo "  rollback --list    # Show available generations"
                return 0
            case '*'
                # Assume it's a generation number
                if string match -qr '^\d+$' $arg
                    set target_gen $arg
                else
                    echo "Invalid generation number: $arg"
                    return 1
                end
        end
    end
    
    # List generations if requested
    if test $list_only = true
        echo "📦 Available nix-darwin generations:"
        sudo darwin-rebuild --list-generations
        return 0
    end
    
    # Show current state
    echo "📦 Current generation:"
    sudo darwin-rebuild --list-generations | tail -n 1
    
    # Determine target generation
    if test -z "$target_gen"
        # Get previous generation
        set -l generations (sudo darwin-rebuild --list-generations | tail -n 2 | head -n 1 | string match -r '^\s*(\d+)')
        if test -n "$generations[1]"
            set target_gen $generations[1]
        else
            echo "❌ Could not determine previous generation"
            return 1
        end
    end
    
    echo "🔄 Rolling back to generation $target_gen..."

    # Perform rollback
    if sudo darwin-rebuild switch --switch-generation $target_gen
        echo "✅ Successfully rolled back to generation $target_gen"
        echo "📦 Active generation:"
        sudo darwin-rebuild --list-generations | tail -n 1
    else
        echo "❌ Rollback failed"
        return 1
    end
end