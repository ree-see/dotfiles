# Agent Guidelines for .config Repository

## Desired Features
[✓] Replace apple menu bar with sketchy bar
[] start using aerospace
[] yazi integration to helix
[] hotreloading in helix

## Repository Structure
This is a dotfiles configuration repository containing config files for fish shell, helix editor, zellij terminal multiplexer, ghostty terminal, nix-darwin system flake, opencode, and a production-ready SketchyBar setup.

## Build/Test/Lint Commands
- **Nix rebuild**: `darwin-rebuild build --flake .#macbook` (from nix/ directory)
- **Fish syntax check**: `fish -n file.fish` (check syntax without execution)
- **Helix language servers**: Configured in languages.toml with auto-formatting
- **SketchyBar management**: `bar <command>` (reload, start, kill, apple, status)
- **No traditional test suites** - configs are validated by their respective applications

## Code Style Guidelines

### Fish Shell (*.fish)
- Use descriptive function names with hyphens: `fish_prompt`, `mkcd`, `bar`
- Include function descriptions: `function name --description 'Description'`
- Use `set -l` for local variables, proper color handling
- Follow fish shell conventions for variable names and scoping
- Add tab completions for complex functions in completions/ directory

### Configuration Files
- **TOML files**: Use consistent indentation, group related settings
- **Nix files**: Follow nixpkgs formatting with proper attribute alignment
- **KDL files**: Use consistent spacing and grouping for keybinds

### Language-Specific Formatting
- **Python**: ruff formatter, line-length 88, auto-format enabled
- **Ruby**: rubocop via bundle exec, auto-format enabled  
- **HTML/CSS**: prettier parser, auto-format enabled
- **Nix**: nixfmt formatting, auto-format enabled

## Error Handling
- Fish functions should handle errors gracefully with status checks
- Nix configurations should use proper error handling and fallbacks
- No specific error handling patterns for config files

## SketchyBar Implementation - COMPLETED ✅
### Production-Ready Two-Pill Design Implementation

**🎯 Final Design Achieved:**
```
[App Icon + Name] ←→ [CPU • Battery • WiFi • DateTime]
```

**✅ Implementation Complete:**
- **Two-pill layout**: Left pill (app focus) + Right pill (system status)
- **Liquid glass background**: Semi-transparent blur effects with proper spacing
- **Shell-based plugins**: Reliable real-time updates without Lua complexity
- **Smart features**: App-specific icons, WiFi signal strength, battery status
- **Production management**: Fish function `bar` with reload/start/kill/revert commands
- **Clean codebase**: Organized directory structure with only essential files

**📁 Structure:**
- `sketchybar/start_two_pill.sh` - Main startup script (production)
- `sketchybar/reload.sh` - Quick reload wrapper
- `sketchybar/plugins/*.sh` - 5 working shell plugins
- `sketchybar/icons/*.svg` - Custom icons available for future use
- `fish/functions/bar.fish` - Management command with tab completion

**🔧 Key Technical Details:**
- **Notch spacing**: 200px for MacBook Pro compatibility
- **Bar dimensions**: 28px height with 10px offset, transparent main bar
- **Pill backgrounds**: Individual glass backgrounds with 14px corner radius
- **Auto-cleanup**: Removes lua_loader automatically on startup
- **WiFi detection**: Uses ping + system_profiler for reliable connectivity
- **Colors**: Comprehensive color scheme in helpers/colors.lua

**🚀 Usage:**
- `bar reload` - Reload SketchyBar
- `bar apple` - Revert to Apple menu bar  
- `bar status` - Check current state
