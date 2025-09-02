function empty_downloads --description "Deletes all files and folders in the Downloads directory"
    set -l downloads_path ~/Downloads
    if test -d $downloads_path
        echo "Deleting contents of $downloads_path..."
        rm -rf $downloads_path/*
        echo "Downloads folder is now empty."
    else
        echo "Error: Downloads folder not found at $downloads_path"
    end
end
