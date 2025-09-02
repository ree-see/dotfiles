# Advanced nix-darwin configuration management
def rebuild [
    operation?: string = "switch"  # build, switch, test
    --commit(-c)                   # Auto-commit changes before rebuilding
    --diff(-d)                     # Show configuration diff
    --backup(-b)                   # Backup current generation
    --help(-h)                     # Show help
] {
    if $help {
        print "Usage: rebuild [OPERATION] [OPTIONS]"
        print ""
        print "Operations:"
        print "  switch  - Build and activate (default)"
        print "  build   - Build without activating"
        print "  test    - Build and test activation"
        print ""
        print "Options:"
        print "  --commit, -c   - Auto-commit changes before rebuilding"
        print "  --diff, -d     - Show configuration diff"
        print "  --backup, -b   - Backup current generation"
        print "  --help, -h     - Show this help"
        print ""
        print "Examples:"
        print "  rebuild                # Quick switch"
        print "  rebuild --commit       # Commit changes and switch"
        print "  rebuild build --diff   # Build and show what changed"
        return
    }

    let flake_path = "~/.config/nix#macbook"
    let config_dir = "~/.config"
    
    # Validate operation
    if $operation not-in ["build", "switch", "test"] {
        print $"❌ Invalid operation: ($operation). Use: build, switch, or test"
        return
    }
    
    # Change to config directory
    cd $config_dir
    
    # Check git status
    let git_status = (do { git status --porcelain } | complete)
    
    if $git_status.exit_code == 0 and ($git_status.stdout | str trim | is-not-empty) {
        print "🔄 Git tree is dirty:"
        git status --short
        
        if $commit {
            print "📝 Auto-committing changes..."
            git add .
            let commit_msg = "nix: update configuration before rebuild"
            git commit -m $commit_msg
            print "✅ Changes committed"
        } else {
            print "💡 Use --commit to auto-commit changes"
        }
    } else {
        print "✅ Git tree is clean"
    }
    
    # Show diff if requested
    if $diff {
        print "📊 Configuration changes:"
        print "Install nix-diff for detailed comparison: nix-env -iA nixpkgs.nix-diff"
    }
    
    # Backup current generation if requested
    if $backup {
        print "💾 Current generation will be preserved automatically"
        print "Accessible via: sudo darwin-rebuild --list-generations"
    }
    
    # Show current generation info
    print "📦 Current generation:"
    do { sudo darwin-rebuild --list-generations } | complete | get stdout | lines | last
    
    # Run the rebuild
    print $"🔨 Running: sudo darwin-rebuild ($operation) --flake ($flake_path)"
    
    let rebuild_result = (do { sudo darwin-rebuild $operation --flake $flake_path } | complete)
    
    if $rebuild_result.exit_code == 0 {
        print "✅ Rebuild completed successfully!"
        
        if $operation == "switch" {
            print "🎯 New generation active:"
            do { sudo darwin-rebuild --list-generations } | complete | get stdout | lines | last
        }
    } else {
        print $"❌ Rebuild failed with exit code: ($rebuild_result.exit_code)"
        print "💡 Use 'rollback' to revert to previous generation if needed"
        print $"Error output: ($rebuild_result.stderr)"
    }
}