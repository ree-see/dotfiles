# Nushell Environment Configuration

# Default editor
$env.EDITOR = "hx"

# App aliases (similar to your Fish setup)
$env.AS = "aerospace" 
$env.GH = "ghostty"

# Add nix apps to PATH
$env.PATH = ($env.PATH | split row (char esep) | prepend '/run/current-system/sw/bin' | prepend '/nix/var/nix/profiles/default/bin')

# Zoxide integration
zoxide init nushell | save -f ~/.config/nushell/zoxide.nu

# Custom prompt indicators  
$env.PROMPT_INDICATOR = "❯ "
$env.PROMPT_INDICATOR_VI_INSERT = "❯ "
$env.PROMPT_INDICATOR_VI_NORMAL = "〉"