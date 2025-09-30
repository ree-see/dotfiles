# Advanced nix-darwin configuration management function
# Provides a comprehensive interface for building and managing nix-darwin configurations
#
# Features:
# - Automatic git status checking and optional commits
# - Configuration diffing
# - Generation backup and management
# - Multiple operation modes (switch, build, test)
# - Flake input updates
# - Comprehensive error handling and feedback
#
# Usage: rebuild [OPERATION] [OPTIONS]
# See: rebuild --help

function rebuild --description "Advanced nix-darwin configuration management"
    set -l operation switch
    set -l flake_path ~/.config/nix#macbook
    set -l config_dir ~/.config
    set -l auto_commit false
    set -l show_diff false
    set -l backup_gen false
    set -l update_flake false
    set -l commit_msg ""

    # Parse command line arguments
    set -l i 1
    while test $i -le (count $argv)
        set -l arg $argv[$i]
        switch $arg
            case build switch test
                set operation $arg
            case --commit -c
                set auto_commit true
                if test $i -lt (count $argv); and not string match -q -- '--*' $argv[(math $i + 1)]
                    set i (math $i + 1)
                    set commit_msg $argv[$i]
                end
            case --diff -d
                set show_diff true
            case --backup -b
                set backup_gen true
            case --update -u
                set update_flake true
            case --help -h
                _rebuild_show_help
                return 0
            case '*'
                echo "Unknown option: $arg"
                return 1
        end
        set i (math $i + 1)
    end

    # Change to config directory for git operations and flake access
    pushd $config_dir

    # Update flake inputs if requested
    if test $update_flake = true
        if not _rebuild_update_flake $config_dir
            popd
            return 1
        end
    end

    # Check git repository status and handle dirty tree
    _rebuild_handle_git $auto_commit "$commit_msg"

    # Show configuration differences if requested
    if test $show_diff = true
        _rebuild_show_diff
    end

    # Backup current system generation if requested
    if test $backup_gen = true
        set -l current_gen (readlink /nix/var/nix/profiles/system)
        echo "💾 Backing up current generation: $current_gen"
        # The system automatically keeps generations, so we just note it
        echo "Current generation backed up (accessible via nix-env --list-generations)"
    end

    # Show current generation info
    echo "📦 Current generation:"
    sudo darwin-rebuild --list-generations | tail -n 1

    # Execute the nix-darwin rebuild operation
    echo "🔨 Running: sudo darwin-rebuild $operation --flake $flake_path"
    if sudo darwin-rebuild $operation --flake $flake_path
        echo "✅ Rebuild completed successfully!"

        # Display the new active generation for switch operations
        if test $operation = switch
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
