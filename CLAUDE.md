# CLAUDE.md

This file provides guidance to Claude Code when working in this repository.

## Philosophy & Design Decisions

### Why Fish over Zsh/Bash?
- **Better defaults**: Syntax highlighting and autosuggestions out of the box
- **Cleaner scripting**: More consistent and readable syntax
- **Custom functions**: Easy to create and manage utility commands

### Why Helix as primary editor?
- **Modal editing**: Vim-style efficiency
- **Built-in LSP**: No plugin management needed
- **Fast and lightweight**: Written in Rust

### Package Manager Strategy
- **zerobrew**: CLI tools and formulas (`zb bundle` from `~/.config/Brewfile`)
- **mise**: Runtime version management (Ruby, Node, Python) — replaces asdf
- **pnpm**: Node.js packages
- **gem/bundle**: Ruby packages
- **GUI apps**: Installed manually (1Password, WezTerm, Warp, Chrome, Spotify)

## New Mac Setup

```fish
bash ~/.config/scripts/bootstrap-new-mac.sh
```

## Common Commands

### Configuration Management

- `config helix`   — Edit Helix config
- `config fish`    — Edit Fish config
- `config wezterm` — Edit WezTerm config

### Development Utilities

- `mkcd <dir>` — Create directory and cd into it

### Project Creation

```fish
newproject <name> [--type node|ruby|python|web] [--tdd]
```

### Node.js Development

- **Package manager**: `pnpm`
- `pnpm install` / `pnpm add <pkg>` / `pnpm run <script>`

### Ruby Development

- **Version manager**: `mise`
- `mise use ruby@3.3.6`  — set Ruby version for project
- `mise install`         — install versions from `.tool-versions`

### Database (PostgreSQL@16)

- `brew services start postgresql@16`
- `psql postgres` / `createdb <name>` / `dropdb <name>`

### 1Password CLI

- CLI tool: `op`
- Plugin aliases in `~/.config/op/plugins.sh`

## Architecture Overview

```
~/.config/
├── Brewfile              # zerobrew package list
├── fish/                 # Fish shell config
├── helix/                # Helix editor config
├── wezterm/              # WezTerm terminal config
├── git/                  # Git config
├── ssh/                  # SSH config
├── scripts/
│   ├── bootstrap-new-mac.sh  # New machine setup
│   └── macos-defaults.sh     # macOS system preferences
└── templates/            # Pre-commit hook templates
```

## Git Workflow

- **Commit format**: conventional commits (`feat:`, `fix:`, `refactor:`, etc.)
- **Main branch**: `main` — direct commits acceptable for this config repo
- Always `git status` before committing

## Pre-commit Hooks

```fish
setup-precommit  # copies template and installs hooks
pre-commit run --all-files
```

Template: `~/.config/templates/.pre-commit-config.yaml`
