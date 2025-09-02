# Show nix-darwin configuration status
def nixstatus [
    --packages(-p)                 # Show installed packages
    --services(-s)                 # Show running services  
    --all(-a)                      # Show everything
    --help(-h)                     # Show help
] {
    if $help {
        print "Usage: nixstatus [OPTIONS]"
        print ""
        print "Options:"
        print "  --packages, -p  - Show installed packages"
        print "  --services, -s  - Show running services"
        print "  --all, -a      - Show everything"
        print "  --help, -h     - Show this help"
        print ""
        print "Examples:"
        print "  nixstatus           # Show basic status"
        print "  nixstatus --all     # Show comprehensive status"
        print "  nixstatus -p        # Show only packages"
        return
    }
    
    # Set flags for --all
    let show_packages = $packages or $all
    let show_services = $services or $all
    
    print "🍎 nix-darwin System Status"
    print "=========================="
    
    # Current generation
    print ""
    print "📦 Current Generation:"
    let current_gen_result = (do { sudo darwin-rebuild --list-generations } | complete)
    if $current_gen_result.exit_code == 0 {
        print ($current_gen_result.stdout | lines | last)
    } else {
        print "❌ Could not get current generation info"
    }
    
    # Git status of config
    print ""
    print "📝 Configuration Git Status:"
    cd ~/.config
    
    let git_check = (do { git rev-parse --git-dir } | complete)
    if $git_check.exit_code == 0 {
        let git_status = (do { git status --porcelain } | complete)
        if $git_status.exit_code == 0 and ($git_status.stdout | str trim | is-not-empty) {
            print "🔄 Uncommitted changes:"
            git status --short
        } else {
            print "✅ Clean (no uncommitted changes)"
        }
        
        let commit_info = (do { git log -1 --pretty=format:"%h - %s" } | complete)
        if $commit_info.exit_code == 0 {
            print $"📍 Current commit: ($commit_info.stdout)"
        }
    } else {
        print "❌ Not a git repository"
    }
    
    # System info
    print ""
    print "💻 System Info:"
    let macos_version = (do { sw_vers -productVersion } | complete | get stdout | str trim)
    print $"   macOS: ($macos_version)"
    
    let nix_version = (do { nix --version } | complete | get stdout | lines | first)
    print $"   Nix: ($nix_version)"
    
    print "   nix-darwin: Available via nix-darwin flake"
    
    # Show packages if requested
    if $show_packages {
        print ""
        print "📦 System Packages (from nix-darwin):"
        print "   helix, zellij, fish, nushell, mkalias, nil, 1password-cli, zoxide"
        
        print ""
        print "📦 User Environment Packages:"
        let user_packages = (do { nix-env -q --installed } | complete)
        if $user_packages.exit_code == 0 {
            let package_lines = ($user_packages.stdout | lines | where { |line| $line | str trim | is-not-empty })
            let total_count = ($package_lines | length)
            
            if $total_count > 0 {
                $package_lines | first 20 | each { |pkg| print $"   ($pkg)" }
                if $total_count > 20 {
                    print $"   ... and ($total_count - 20) more packages (total: ($total_count))"
                }
            } else {
                print "   No user packages installed"
            }
        }
    }
    
    # Show services if requested
    if $show_services {
        print ""
        print "🔧 System Services:"
        let services = (do { launchctl list } | complete)
        if $services.exit_code == 0 {
            $services.stdout | lines | where { |line| $line =~ "nix" } | first 10 | each { |service| print $"   ($service)" }
        }
    }
    
    # Recent generations
    print ""
    print "🕒 Recent Generations (last 5):"
    let recent_gens = (do { sudo darwin-rebuild --list-generations } | complete)
    if $recent_gens.exit_code == 0 {
        $recent_gens.stdout | lines | last 5 | each { |gen| print $"   ($gen)" }
    } else {
        print "❌ Could not get generation info"
    }
}