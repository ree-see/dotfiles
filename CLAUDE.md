# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Philosophy & Design Decisions

### Why nix-darwin over plain Homebrew?
- **Declarative configuration**: Entire system state is defined in code
- **Reproducibility**: Can recreate the exact environment on any Mac
- **Atomic upgrades/rollbacks**: System changes are versioned and reversible
- **Version pinning**: Lock package versions across rebuilds

### Why Fish over Zsh/Bash?
- **Better defaults**: Syntax highlighting and autosuggestions out of the box
- **Cleaner scripting**: More consistent and readable syntax
- **Custom functions**: Easy to create and manage utility commands

### Why Helix as primary editor?
- **Modal editing**: Vim-style efficiency
- **Built-in LSP**: No plugin management needed
- **Custom build**: Uses personal fork with modifications at `github:ree-see/helix`
- **Fast and lightweight**: Written in Rust

### Package Manager Strategy
- **Nix**: System tools, development utilities, CLI apps (helix, fish, node, etc.)
- **Homebrew**: GUI apps and services not in nixpkgs (WezTerm, Raycast, PostgreSQL)
- **pnpm**: Node.js packages (fast, disk-efficient, better monorepo support)
- **Not using**: rbenv was removed in favor of potential future consolidation with asdf or Nix

## Common Development Commands

### Nix Darwin System Management

- `rebuild` - Build and activate nix-darwin configuration (default: switch)
- `rebuild build` - Build without activating
- `rebuild --commit` - Auto-commit changes before rebuilding
- `rebuild --diff` - Show configuration diff
- `rollback` - Revert to previous nix-darwin generation
- `nixstatus` - Check system status and configuration

### Configuration Management

- `config <tool>` - Edit configuration files for various tools
  - `config helix` - Edit Helix editor config
  - `config nix` - Edit nix configuration
  - `config fish` - Edit Fish shell config
  - `config wezterm` - Edit WezTerm terminal config
  - `config zellij` - Edit Zellij terminal multiplexer config

### Development Utilities

- `mkcd <directory>` - Create directory and cd into it
- `mkcd dir1 dir2 dir3` - Create multiple directories, cd to last

### Project Creation

**Create a new project with Claude Code awareness**:
```fish
newproject <name> [--type node|ruby|python|web] [--tdd]
```

**What it does**:
1. Creates directory in `~/dev/<name>`
2. Initializes git repository
3. Adds CLAUDE.md that references global config at `/Users/reesee/.config/CLAUDE.md`
4. Creates appropriate `.gitignore` for project type
5. Sets up initial project structure
6. Optionally installs pre-commit hooks with `--tdd` flag
7. Makes initial commit

**Examples**:
```fish
newproject my-app --type node --tdd        # Node.js with TDD hooks
newproject my-site --type web              # Static web project
newproject api-server --type ruby --tdd    # Ruby with TDD
```

**Important**: The generated CLAUDE.md instructs Claude Code to read your global configuration first!

### Node.js Development

- **Package manager**: `pnpm` (installed via Nix)
- **Common commands**:
  - `pnpm install` - Install dependencies
  - `pnpm add <package>` - Add a package
  - `pnpm run <script>` - Run npm script
  - `pnpm dlx <package>` - Run package without installing (like npx)
- **Benefits over npm/yarn**: Faster installs, uses less disk space, better monorepo support

### Database Management

- **PostgreSQL**: Installed via Homebrew (not managed by nix-darwin)
- Check if running: `brew services list | grep postgresql`
- Start: `brew services start postgresql@14`
- Stop: `brew services stop postgresql@14`

### 1Password CLI Integration

- CLI tool: `op` (installed via Nix)
- Plugin aliases in `~/.config/op/plugins.sh`:
  - `gh` - GitHub CLI with 1Password auth
  - `twilio` - Twilio CLI with 1Password auth
- Configuration: `~/.config/op/plugins/`

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

- **Nix packages**: Helix, Fish, Zellij, Node.js, pnpm, development tools
- **Homebrew integration**: PostgreSQL, Raycast, WezTerm
- **Mac App Store apps**: Magnet

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
2. Fish functions provide configuration management via `config` command
3. System rebuilds are managed through custom `rebuild` command with safety features
4. All changes can be rolled back using generation management

## Git Workflow & Commit Guidelines

### When to Commit

- **Configuration changes**: Always commit immediately with descriptive messages
- **Code changes**: Ask before committing unless explicitly told to commit
- **Check status first**: Always run `git status` before committing

### Commit Message Format

Follow conventional commits style:
```
<type>: <description>

<body with details>

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

Types: `feat`, `fix`, `refactor`, `docs`, `style`, `test`, `chore`

### Branch Strategy

- **Main branch**: `main` (default for this config repo)
- **Feature branches**: Not typically used for personal config
- **Direct commits to main**: Acceptable for this repository

## Testing & Development Workflow

### TDD (Test-Driven Development)

When working on projects that use TDD:
1. Write tests first
2. Run tests to confirm they fail
3. Implement code to pass tests
4. Refactor while keeping tests green
5. Commit with all tests passing

### Pre-commit Hooks

**Setup in a project**:
```fish
setup-precommit  # Copies template and installs hooks
```

**Configuration**: `.pre-commit-config.yaml` in project root

**Included hooks**:
- File quality checks (trailing whitespace, EOF, merge conflicts)
- Security (detect private keys, check large files)
- Prettier formatting for JS/TS/JSON/YAML
- Optional: Test runner (uncomment for TDD)
- Optional: ESLint, Rubocop (uncomment as needed)

**Manual run**:
```fish
pre-commit run --all-files  # Run all hooks manually
```

**Template location**: `~/.config/templates/.pre-commit-config.yaml`

## Important Notes

- The flake is configured for `aarch64-darwin` (Apple Silicon)
- Touch ID is enabled for sudo authentication
- System manages both Nix packages and Homebrew formulae
- Use `rebuild --help` or any custom command with `--help` for detailed usage information
- Helix grammars are managed via git submodules at `helix/runtime/grammars/`
- The augments-mcp-server is also a git submodule

## Troubleshooting

### Rebuild Issues

- **Dirty git tree warning**: Normal if you have uncommitted changes
- **Full Disk Access error**: Grant terminal Full Disk Access in System Settings
- **Failed to build**: Run `rebuild --diff` to see what changed

### Rollback

If a rebuild breaks something:
```fish
rollback  # Reverts to previous generation
```

### Check Current Generation

```fish
nixstatus  # Shows current generation and recent changes
```