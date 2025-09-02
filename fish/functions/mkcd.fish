function mkcd --description "Create a directory and change into it"
    if test (count $argv) -eq 0
        echo "Usage: mkcd <directory> [directories...]"
        echo "Creates directory/directories and changes into the last one"
        return 1
    end
    
    # Store the last directory to cd into
    set -l target_dir $argv[-1]
    
    # Create all directories
    if not mkdir -pv $argv
        echo "Failed to create directory: $argv"
        return 1
    end
    
    # Change to the last directory specified
    if not cd $target_dir
        echo "Failed to change to directory: $target_dir"
        return 1
    end
    
    # Show where we ended up
    echo "Now in: $(pwd)"
end
