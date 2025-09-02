function nixstatus --description "Show nix-darwin configuration status"
    set -l show_packages false
    set -l show_services false
    set -l show_all false
    
    # Parse arguments
    for arg in $argv
        switch $arg
            case --packages -p
                set show_packages true
            case --services -s
                set show_services true
            case --all -a
                set show_all true
            case --help -h
                echo "Usage: nixstatus [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --packages, -p  - Show installed packages"
                echo "  --services, -s  - Show running services"
                echo "  --all, -a      - Show everything"
                echo "  --help, -h     - Show this help"
                echo ""
                echo "Examples:"
                echo "  nixstatus           # Show basic status"
                echo "  nixstatus --all     # Show comprehensive status"
                echo "  nixstatus -p        # Show only packages"
                return 0
            case '*'
                echo "Unknown option: $arg"
                return 1
        end
    end
    
    # Set show_all flags
    if test $show_all = true
        set show_packages true
        set show_services true
    end
    
    echo "🍎 nix-darwin System Status"
    echo "=========================="
    
    # Current generation
    echo ""
    echo "📦 Current Generation:"
    sudo darwin-rebuild --list-generations | tail -n 1
    
    # Git status of config
    echo ""
    echo "📝 Configuration Git Status:"
    pushd ~/.config
    if git rev-parse --git-dir >/dev/null 2>&1
        set -l git_status (git status --porcelain)
        if test -n "$git_status"
            echo "🔄 Uncommitted changes:"
            git status --short
        else
            echo "✅ Clean (no uncommitted changes)"
        end
        echo "📍 Current commit: "(git rev-parse --short HEAD)" - "(git log -1 --pretty=format:"%s")
    else
        echo "❌ Not a git repository"
    end
    popd
    
    # System info
    echo ""
    echo "💻 System Info:"
    echo "   macOS: "(sw_vers -productVersion)
    echo "   Nix: "(nix --version | head -n 1)
    echo "   nix-darwin: "(/run/current-system/sw/bin/darwin-rebuild --help 2>/dev/null | head -n 1 | string match -r 'darwin-rebuild.*' || echo "version unknown")
    
    # Show packages if requested
    if test $show_packages = true
        echo ""
        echo "📦 Installed Nix Packages:"
        nix-env -q --installed | head -20
        set -l total_packages (nix-env -q --installed | wc -l | string trim)
        echo "   ... and "(math $total_packages - 20)" more packages (total: $total_packages)"
    end
    
    # Show services if requested  
    if test $show_services = true
        echo ""
        echo "🔧 System Services:"
        launchctl list | grep nix | head -10
    end
    
    # Recent generations
    echo ""
    echo "🕒 Recent Generations (last 5):"
    sudo darwin-rebuild --list-generations | tail -n 5
end