# Agent Guidelines for .config Repository

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