# 🐚 Nushell Setup Guide - Your Fish Functions Ported!

## 🚀 Quick Start

Your Nushell setup is ready! All your Fish functions have been ported with enhanced features.

### Testing Your Setup
```bash
# From Fish, test Nushell
nu

# Test your custom commands
cfg --help
mkcd --help
rebuild --help
nixstatus --help
rollback --help
```

## 📁 File Structure
```
~/.config/nushell/
├── config.nu              # Main configuration
├── env.nu                  # Environment variables & aliases  
└── scripts/
    ├── mod.nu              # Module loader
    ├── cfg.nu              # Config file editor
    ├── mkcd.nu             # Create and cd to directory
    ├── rebuild.nu          # nix-darwin management
    ├── rollback.nu         # Generation rollback
    ├── nixstatus.nu        # System status
    └── prompt.nu           # Custom prompt
```

## 🎯 Ported Functions Comparison

### `cfg` Function (renamed from `config`)
**Fish:**
```fish
config helix          # Open helix config
config as             # Open aerospace (alias)
```

**Nushell (Enhanced, renamed to avoid conflict):**
```nushell
cfg helix             # Same functionality
cfg as                # Same aliases work
cfg --help            # Built-in help system
config env            # Nushell's built-in (opens env.nu)
```

### `mkcd` Function  
**Fish:**
```fish
mkcd new-project      # Create and cd to directory
```

**Nushell (Enhanced):**
```nushell
mkcd new-project      # Same functionality
mkcd dir1 dir2 dir3   # Create multiple, cd to last
mkcd --help           # Built-in help
```

### `rebuild` Function
**Fish:**
```fish
rebuild --commit      # Commit and rebuild
rebuild build --diff  # Build with diff
```

**Nushell (Same features + Better error handling):**
```nushell
rebuild --commit      # Same functionality
rebuild build --diff  # Same options
rebuild --help        # Comprehensive help
```

## ✨ Nushell Advantages

### 1. **Structured Data**
```nushell
# List files as structured data
ls | where size > 1mb | sort-by modified

# System info as tables
sys | get host
ps | where cpu > 50
```

### 2. **Better Error Handling**
- All custom commands have built-in `--help`
- Clear error messages with context
- Structured error handling with `try/catch`

### 3. **Type Safety**
- Parameter types are enforced
- Auto-completion knows parameter types
- Better validation

### 4. **Modern Features**
- JSON/YAML/TOML parsing built-in
- HTTP requests: `http get https://api.github.com`
- Data manipulation: `open file.json | get data.items`

## 🔄 Migration Strategy

### Phase 1: Parallel Usage (Current)
- Keep Fish as your default shell
- Run `nu` to test Nushell when you want
- All your functions work in both shells

### Phase 2: Gradual Adoption
```bash
# Test workflows in Nushell
nu -c "rebuild build"
nu -c "cfg nix"
nu -c "nixstatus --all"
```

### Phase 3: Full Switch (When Ready)
```bash
# Change default shell (optional)
chsh -s $(which nu)
```

## 🔧 Configuration Highlights

### Environment Variables
- `$env.AS = "aerospace"` - App aliases work
- `$env.EDITOR = "hx"` - Helix as default editor
- PATH includes nix apps

### Custom Prompt
- Shows current directory
- Git branch information  
- Error codes on failure
- Similar to your Fish prompt

### Aliases
- `ll`, `la`, `l` for listing
- Git shortcuts: `gs`, `ga`, `gc`, `gp`

## 🎨 Nushell-Specific Tips

### Data Exploration
```nushell
# Explore system processes
ps | where name =~ "helix"

# Check disk usage
du | sort-by size | last 10

# Parse JSON responses
http get https://api.github.com/users/reesee | get name
```

### Working with Files
```nushell
# Open and manipulate config files  
open ~/.config/helix/config.toml | get editor

# Convert between formats
open data.json | to yaml | save data.yaml
```

## 🚨 Fallback Strategy

If you ever want to go back:
1. **Temporary:** Exit Nushell with `exit` to return to Fish
2. **Permanent:** Switch back to Fish as default with `chsh -s $(which fish)`
3. **Remove:** Remove `pkgs.nushell` from nix-darwin config

Your Fish configuration remains untouched on the `main` branch!

## 🎯 Next Steps

1. **Test the functions:** Try `rebuild`, `config`, `mkcd`, etc.
2. **Explore data features:** Try `ls`, `ps`, `sys` for structured data
3. **Learn gradually:** Use Nushell for specific tasks, Fish for others
4. **Experiment:** The `nu` branch keeps everything safe

---

**Ready to explore?** Run `nu` and start testing your ported functions! 🚀