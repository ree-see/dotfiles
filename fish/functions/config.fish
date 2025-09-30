# Configuration file editor function
# Provides quick access to edit configuration files for various tools
#
# Usage: config <app> [file]
# Examples:
#   config helix | hx      # Edit main Helix config
#   config nix             # Edit nix flake
#   config fish            # Edit Fish config
#   config wezterm | wez   # Edit WezTerm config
#   config aerospace | as  # Edit Aerospace config (alias)

function config --description 'Edit configuration files with helix editor'
    set -l config_dir ~/.config

    # Show usage and available configurations if no arguments provided
    if test (count $argv) -eq 0
        echo "Usage: config <app> [file]"
        echo "Available configs:"
        for dir in (ls $config_dir)
            if test -d $config_dir/$dir
                echo "  $dir"
            end
        end
        echo ""
        echo "Aliases: as (aerospace), gh (ghostty)"
        return 1
    end

    set -l app $argv[1]
    set -l config_path $config_dir/$app

    # Handle app aliases for convenience
    switch $app
        case as
            set config_path $config_dir/aerospace
        case wez
            set config_path $config_dir/wezterm
        case hx
            set config_path $config_dir/helix
    end

    if not test -e $config_path
        echo "Config not found: $config_path"
        return 1
    end

    # If specific file provided, open that file directly
    if test (count $argv) -gt 1
        set -l file_path $config_path/$argv[2]
        if test -f $file_path
            hx $file_path
        else
            echo "File not found: $file_path"
            return 1
        end
    else
        # Open the config directory or main config file
        if test -d $config_path
            # Look for common config file names in order of preference
            for config_file in config.toml config.kdl config config.fish
                if test -f $config_path/$config_file
                    hx $config_path/$config_file
                    return
                end
            end
            # If no main config file found, open the directory
            hx $config_path
        else
            # Open the file directly if it's not a directory
            hx $config_path
        end
    end
end
