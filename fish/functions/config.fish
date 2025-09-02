set --global as aerospace
set --global gh ghostty

function config --description 'Edit configuration files with helix editor'
    set -l config_dir ~/.config
    
    if test (count $argv) -eq 0
        echo "Usage: config <app> [file]"
        echo "Available configs:"
        for dir in (ls $config_dir)
            if test -d $config_dir/$dir
                echo "  $dir"
            end
        end
        return 1
    end
    
    set -l app $argv[1]
    set -l config_path $config_dir/$app
    
    # Handle app aliases
    switch $app
        case as
            set config_path $config_dir/aerospace
        case gh
            set config_path $config_dir/ghostty
    end
    
    if not test -e $config_path
        echo "Config not found: $config_path"
        return 1
    end
    
    # If specific file provided, open that file
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
            # Look for common config file names
            for config_file in config.toml config.kdl config config.fish
                if test -f $config_path/$config_file
                    hx $config_path/$config_file
                    return
                end
            end
            # If no main config file found, open directory
            hx $config_path
        else
            hx $config_path
        end
    end
end
