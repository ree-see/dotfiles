# Custom prompt configuration
def create_left_prompt [] {
    # Get username
    let username = $env.USER
    
    # Get current directory
    let home = $nu.home-path
    let dir = (
        if ($env.PWD | path dirname) == $home { "~" } else { $env.PWD }
        | str replace $home "~"
    )
    
    # Define colors
    let username_color = (ansi cyan)
    let path_color = (ansi green)
    let reset_color = (ansi reset)
    
    # Get git branch if in git repo
    let git_info = (do -i { 
        git branch --show-current
    } | complete | if ($in.exit_code == 0) { $in.stdout | str trim } else { "" })
    
    let git_segment = if ($git_info | is-not-empty) {
        $" (ansi purple)($git_info)(ansi reset)"
    } else {
        ""
    }
    
    # Combine into requested format: <username> <pwd> <git branch> >
    $"($username_color)($username)($reset_color) ($path_color)($dir)($reset_color)($git_segment) > "
}

def create_right_prompt [] {
    # Show last command duration if over 1 second
    let last_exit_code = $env.LAST_EXIT_CODE
    if $last_exit_code != 0 {
        $"(ansi red)[($last_exit_code)](ansi reset)"
    } else {
        ""
    }
}

# Override default prompts
$env.PROMPT_COMMAND = { create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = { create_right_prompt }