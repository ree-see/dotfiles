# Create directory and change into it
def mkcd [...dirs: string] {
    if ($dirs | is-empty) {
        print "Usage: mkcd <directory> [directories...]"
        print "Creates directory/directories and changes into the last one"
        return
    }
    
    # Store the target directory (last argument)
    let target_dir = ($dirs | last)
    
    # Create all directories
    try {
        mkdir ...$dirs
        print $"✅ Created directories: ($dirs | str join ', ')"
    } catch {
        print $"❌ Failed to create directories: ($dirs | str join ', ')"
        return
    }
    
    # Change to the target directory  
    try {
        cd $target_dir
        print $"📂 Now in: (pwd)"
    } catch {
        print $"❌ Failed to change to directory: ($target_dir)"
    }
}