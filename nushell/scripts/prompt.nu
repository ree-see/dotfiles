# Custom prompt configuration
def create_left_prompt [] {
    let home = $nu.home-path
    let dir = (
        if ($env.PWD | path dirname) == $home { "~" } else { $env.PWD }
        | str replace $home "~"
    )
    
    let path_color = (ansi green)
    let separator_color = (ansi light_blue)  
    let reset_color = (ansi reset)
    
    # Get git status if in git repo
    let git_info = (do { 
        git branch --show-current 2>/dev/null 
    } | complete | get stdout | str trim)
    
    let git_segment = if ($git_info | is-not-empty) {
        $" (ansi purple)($git_info)(ansi reset)"
    } else {
        ""
    }
    
    $"($path_color)($dir)($git_segment)($reset_color) "
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