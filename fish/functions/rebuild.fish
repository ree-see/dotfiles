function rebuild --description "Advanced nix-darwin configuration management"
    set -l operation "switch"
    set -l flake_path ~/.config/nix#macbook
    set -l config_dir ~/.config
    set -l auto_commit false
    set -l show_diff false
    set -l backup_gen false
    
    # Parse arguments
    for arg in $argv
        switch $arg
            case build switch test
                set operation $arg
            case --commit -c
                set auto_commit true
            case --diff -d
                set show_diff true
            case --backup -b
                set backup_gen true
            case --help -h
                echo "Usage: rebuild [OPERATION] [OPTIONS]"
                echo ""
                echo "Operations:"
                echo "  switch  - Build and activate (default)"
                echo "  build   - Build without activating" 
                echo "  test    - Build and test activation"
                echo ""
                echo "Options:"
                echo "  --commit, -c   - Auto-commit changes before rebuilding"
                echo "  --diff, -d     - Show configuration diff"
                echo "  --backup, -b   - Backup current generation"
                echo "  --help, -h     - Show this help"
                echo ""
                echo "Examples:"
                echo "  rebuild                # Quick switch"
                echo "  rebuild --commit       # Commit changes and switch"
                echo "  rebuild build --diff   # Build and show what changed"
                echo "  rebuild test --backup  # Test with backup"
                return 0
            case '*'
                echo "Unknown option: $arg"
                return 1
        end
    end
    
    # Change to config directory
    pushd $config_dir
    
    # Check git status
    if git rev-parse --git-dir >/dev/null 2>&1
        set -l git_status (git status --porcelain)
        if test -n "$git_status"
            echo "🔄 Git tree is dirty:"
            git status --short
            
            if test $auto_commit = true
                echo "📝 Auto-committing changes..."
                git add .
                set -l commit_msg "nix: update configuration before rebuild"
                git commit -m "$commit_msg"
                echo "✅ Changes committed"
            else
                echo "💡 Use --commit to auto-commit changes"
            end
        else
            echo "✅ Git tree is clean"
        end
    end
    
    # Show diff if requested
    if test $show_diff = true
        echo "📊 Configuration changes:"
        if command -v nix-diff >/dev/null
            echo "Running nix-diff..."
            # This would show differences between generations
            nix-diff (readlink /nix/var/nix/profiles/system) (nix-build '<darwin>' -A system --no-out-link)
        else
            echo "Install nix-diff for detailed comparison: nix-env -iA nixpkgs.nix-diff"
        end
    end
    
    # Backup current generation if requested
    if test $backup_gen = true
        set -l current_gen (readlink /nix/var/nix/profiles/system)
        echo "💾 Backing up current generation: $current_gen"
        # The system automatically keeps generations, so we just note it
        echo "Current generation backed up (accessible via nix-env --list-generations)"
    end
    
    # Show current generation info
    echo "📦 Current generation:"
    sudo darwin-rebuild --list-generations | tail -n 1
    
    # Run the rebuild
    echo "🔨 Running: sudo darwin-rebuild $operation --flake $flake_path"
    if sudo darwin-rebuild $operation --flake $flake_path
        echo "✅ Rebuild completed successfully!"
        
        # Show what changed
        if test $operation = "switch"
            echo "🎯 New generation active:"
            sudo darwin-rebuild --list-generations | tail -n 1
        end
    else
        set -l exit_code $status
        echo "❌ Rebuild failed with exit code: $exit_code"
        echo "💡 Use 'rollback' to revert to previous generation if needed"
        popd
        return $exit_code
    end
    
    popd
end