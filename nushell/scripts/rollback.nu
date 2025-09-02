# Rollback to previous nix-darwin generation
def rollback [
    generation?: int               # Generation number to rollback to
    --list(-l)                     # List available generations
    --help(-h)                     # Show help
] {
    if $help {
        print "Usage: rollback [GENERATION] [OPTIONS]"
        print ""
        print "Arguments:"
        print "  GENERATION  - Generation number to rollback to (default: previous)"
        print ""
        print "Options:"
        print "  --list, -l  - List available generations"
        print "  --help, -h  - Show this help"
        print ""
        print "Examples:"
        print "  rollback           # Rollback to previous generation"
        print "  rollback 42        # Rollback to generation 42"
        print "  rollback --list    # Show available generations"
        return
    }
    
    # List generations if requested
    if $list {
        print "📦 Available nix-darwin generations:"
        sudo darwin-rebuild --list-generations
        return
    }
    
    # Show current state
    print "📦 Current generation:"
    let current_gen = (do { sudo darwin-rebuild --list-generations } | complete | get stdout | lines | last)
    print $current_gen
    
    # Determine target generation
    let target_gen = if ($generation != null) {
        $generation
    } else {
        # Get previous generation number
        let generations = (do { sudo darwin-rebuild --list-generations } | complete | get stdout | lines | reverse)
        if ($generations | length) >= 2 {
            let prev_line = ($generations | get 1)
            $prev_line | parse "{gen} {rest}" | get gen | get 0 | into int
        } else {
            print "❌ Could not determine previous generation"
            return
        }
    }
    
    print $"🔄 Rolling back to generation ($target_gen)..."
    
    # Perform rollback
    let rollback_result = (do { sudo darwin-rebuild --rollback --switch-generation $target_gen } | complete)
    
    if $rollback_result.exit_code == 0 {
        print $"✅ Successfully rolled back to generation ($target_gen)"
        print "📦 Active generation:"
        do { sudo darwin-rebuild --list-generations } | complete | get stdout | lines | last
    } else {
        print "❌ Rollback failed"
        print $"Error: ($rollback_result.stderr)"
    }
}