complete -c config -f

# Complete with available config directories
complete -c config -n "test (count (commandline -opc)) -eq 1" -a "(ls ~/.config | grep -v '^\.')"

# Complete with alias shortcuts
complete -c config -n "test (count (commandline -opc)) -eq 1" -a "as" -d "aerospace config"
complete -c config -n "test (count (commandline -opc)) -eq 1" -a "gh" -d "ghostty config"

# Complete with files in the selected config directory
complete -c config -n "test (count (commandline -opc)) -eq 2" -a "
    set -l app (commandline -opc)[2]
    set -l config_dir ~/.config/\$app
    
    # Handle aliases
    switch \$app
        case as
            set config_dir ~/.config/aerospace
        case gh  
            set config_dir ~/.config/ghostty
    end
    
    if test -d \$config_dir
        ls \$config_dir 2>/dev/null
    end
"