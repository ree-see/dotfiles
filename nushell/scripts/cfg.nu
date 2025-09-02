# Edit configuration files with helix editor
def cfg [app: string, file?: string] {
    let config_dir = $"($env.HOME)/.config"
    
    # Show usage if no app provided
    if ($app | is-empty) {
        print "Usage: cfg <app> [file]"
        print "Available configs:"
        ls $config_dir 
        | where type == dir 
        | get name 
        | path basename 
        | each { |item| print $"  ($item)" }
        return
    }
    
    # Handle app aliases  
    let resolved_app = match $app {
        "as" => "aerospace",
        "gh" => "ghostty", 
        _ => $app
    }
    
    let config_path = $"($config_dir)/($resolved_app)"
    
    # Check if config exists
    if not ($config_path | path exists) {
        print $"❌ Config not found: ($config_path)"
        return
    }
    
    # Handle specific file or auto-detect
    if ($file != null) {
        let file_path = $"($config_path)/($file)"
        if ($file_path | path exists) {
            hx $file_path
        } else {
            print $"❌ File not found: ($file_path)"
        }
    } else {
        # Try to find common config file names
        let common_configs = ["config.toml", "config.kdl", "config", "config.fish", "flake.nix"]
        let found_configs = (
            $common_configs 
            | each { |name| $"($config_path)/($name)" }
            | where { |path| $path | path exists }
        )
        
        if ($found_configs | length) > 0 {
            hx ($found_configs | first)
        } else {
            # Open the directory if no main config found
            hx $config_path  
        }
    }
}