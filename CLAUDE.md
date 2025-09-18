# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Development Commands

### Nix Darwin System Management
- `rebuild` - Build and activate nix-darwin configuration (default: switch)
- `rebuild build` - Build without activating 
- `rebuild --commit` - Auto-commit changes before rebuilding
- `rebuild --diff` - Show configuration diff
- `rollback` - Revert to previous nix-darwin generation
- `nixstatus` - Check system status and configuration

### Configuration Management
- `cfg <tool>` - Edit configuration files for various tools
  - `cfg helix` - Edit Helix editor config
  - `cfg nix` - Edit nix configuration
  - `cfg fish` - Edit Fish shell config
  - `cfg wezterm` - Edit WezTerm terminal config
  - `cfg zellij` - Edit Zellij terminal multiplexer config

### Development Utilities
- `mkcd <directory>` - Create directory and cd into it
- `mkcd dir1 dir2 dir3` - Create multiple directories, cd to last

## Architecture Overview

This is a **macOS nix-darwin configuration repository** that manages system packages, applications, and dotfiles using Nix flakes. The system is configured for development with multiple shells and terminal environments.

### Core Configuration Structure

```
~/.config/
├── nix/
│   └── flake.nix           # Main nix-darwin system configuration
├── fish/
│   └── config.fish         # Fish shell configuration
├── helix/                 # Helix editor configuration
├── wezterm/              # WezTerm terminal configuration
├── zellij/               # Zellij multiplexer configuration
└── yazi/                 # Yazi file manager configuration
```

### System Package Management

The system uses **nix-darwin** with flakes for declarative package management. All packages and applications are defined in `/Users/reesee/.config/nix/flake.nix`:

- **Nix packages**: Helix, Fish, Zellij, Node.js, Ruby, development tools
- **Homebrew integration**: PostgreSQL, rbenv, Raycast, Ghostty, WezTerm
- **Mac App Store apps**: Magnet, Xcode

### Shell Environment

The repository uses **Fish shell** as the primary shell with configuration management.

### Development Tools Integration

- **Editor**: Helix (`hx`) as primary editor
- **Terminal**: WezTerm with advanced features (background images, GPU optimization)
- **Multiplexer**: Zellij for session management
- **File Manager**: Yazi for terminal-based file operations
- **Version Control**: Lazygit for enhanced Git workflows

### Configuration Management Pattern

The system follows a modular configuration pattern where:
1. Each tool has its own configuration directory
2. Fish functions provide configuration management via `cfg` command
3. System rebuilds are managed through custom `rebuild` command with safety features
4. All changes can be rolled back using generation management

## Important Notes

- The flake is configured for `aarch64-darwin` (Apple Silicon)
- Touch ID is enabled for sudo authentication
- System manages both Nix packages and Homebrew formulae
- Use `rebuild --help` or any custom command with `--help` for detailed usage information