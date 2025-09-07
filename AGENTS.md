# Agent Guidelines for .config Repository

## Desired Features
[] Replace apple menu bar with sketchy bar
[] start using aerospace
[] yazi integration to helix
[] hotreloading in helix

## Repository Structure
This is a dotfiles configuration repository containing config files for fish shell, helix editor, zellij terminal multiplexer, ghostty terminal, nix-darwin system flake, and opencode.

## Build/Test/Lint Commands
- **Nix rebuild**: `darwin-rebuild build --flake .#macbook` (from nix/ directory)
- **Fish syntax check**: `fish -n file.fish` (check syntax without execution)
- **Helix language servers**: Configured in languages.toml with auto-formatting
- **No traditional test suites** - configs are validated by their respective applications

## Code Style Guidelines

### Fish Shell (*.fish)
- Use descriptive function names with hyphens: `fish_prompt`, `mkcd`
- Include function descriptions: `function name --description 'Description'`
- Use `set -l` for local variables, proper color handling
- Follow fish shell conventions for variable names and scoping

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

## Roadmap: SketchyBar Implementation
### Goal: Replace Apple menu bar with SketchyBar using Lua plugins

1. **Add SketchyBar to nix/flake.nix** - Include sketchybar package in environment.systemPackages
2. **Create sketchybar/ directory** - Set up configuration structure with sketchybarrc and plugins/
3. **Configure Lua plugins** - Implement modular Lua-based configuration for bar items
4. **System integration** - Add LaunchAgent plist and disable macOS menu bar via system defaults
5. **Testing** - Verify bar loads correctly and all plugins function as expected


[✓] Add SketchyBar package to nix/flake.nix environment.systemPackages
[✓] Create sketchybar/ directory structure with sketchybarrc and plugins/ subdirectory
[✓] Initialize git repository in sketchybar/ directory for version control
[✓] Research SketchyBar Lua plugin configuration patterns and examples
[✓] Create main sketchybarrc configuration file with fish shell
[✓] Implement focused app display plugin (left side)
[✓] Implement CPU percentage plugin
[✓] Implement 1Password integration plugin
[✓] Implement battery percentage plugin
[✓] Implement expandable network manager (WiFi/Bluetooth)
[✓] Implement clock plugin with 24hr format and 'Sun Sep 07 hh:mm' date format
[✓] Fix critical and potential issues from code review
[ ] Test development branch extensively before merging to main
[ ] Add macOS system defaults to disable built-in menu bar in nix/flake.nix
[ ] Create LaunchAgent plist for auto-starting SketchyBar
[ ] Deploy to production: merge development branch to main
