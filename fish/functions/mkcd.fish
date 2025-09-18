# Directory creation and navigation utility
# Creates one or more directories and changes into the last one
#
# Usage: mkcd <directory> [directories...]
# Examples:
#   mkcd new-project              # Create and cd to new-project
#   mkcd src/components/ui        # Create nested directories, cd to ui
#   mkcd dir1 dir2 dir3           # Create multiple dirs, cd to dir3

function mkcd --description "Create a directory and change into it"
    if test (count $argv) -eq 0
        echo "Usage: mkcd <directory> [directories...]"
        echo "Creates directory/directories and changes into the last one"
        return 1
    end
    
    # Store the last directory argument as the target for cd
    set -l target_dir $argv[-1]
    
    # Create all specified directories with verbose output
    if not mkdir -pv $argv
        echo "Failed to create directory: $argv"
        return 1
    end
    
    # Navigate to the last directory that was created
    if not cd $target_dir
        echo "Failed to change to directory: $target_dir"
        return 1
    end
    
    # Display current working directory for confirmation
    echo "Now in: $(pwd)"
end
