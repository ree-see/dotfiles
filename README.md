# Dotfiles & System Configuration

Declarative macOS configuration using nix-darwin for complete system reproducibility.

## 🚀 Quick Setup (New Laptop)

**One command to set up everything**:

```bash
curl -fsSL https://raw.githubusercontent.com/ree-see/dotfiles/main/scripts/quick-install.sh | bash
```

This automates:
- ✅ Nix package manager installation
- ✅ Dotfiles repository cloning
- ✅ All system packages and applications
- ✅ Fish shell configuration
- ✅ Runtime environments (Ruby, Node.js)
- ✅ Service configuration (PostgreSQL)
- ✅ System validation

**Time**: 20-35 minutes

**See**: [NEW_LAPTOP_SETUP.md](NEW_LAPTOP_SETUP.md) for detailed documentation.

## 🚀 Features

- **Declarative System Management**: Everything managed through nix-darwin flakes
- **Fish Shell**: Primary shell with custom commands
- **Modern Development Tools**: Helix editor (custom build), WezTerm/Warp terminals
- **Safe System Rebuilds**: Built-in rollback and generation management
- **Touch ID Integration**: Secure sudo authentication
- **Homebrew Integration**: Seamless integration with Mac-native apps
- **Automated Setup**: One-line installer for new machines

## 📦 What's Included

### System Packages (via Nix)
- **Editor**: Helix (custom build from github:ree-see/helix)
- **Shell**: Fish with custom commands
- **Tools**: yazi, zoxide, gh, 1password-cli, pre-commit, asdf
- **Languages**: Node.js, pnpm, Go, golangci-lint, Lua, nil, uv
- **Development**: watchman, TypeScript tools, prettier

### Applications (via Homebrew)
- **Formulae**: PostgreSQL@16, mas, libyaml, openssl@3, ifstat
- **Casks**: Raycast, Spotify, Warp, WezTerm

### Mac App Store Apps
- 1Password for Safari, Apple Configurator, Magnet, OverPicture, Wipr, Xcode

### System Settings
- Dock: Auto-hide, 48px icons, no recents
- Finder: Show extensions, path bar, full paths
- Trackpad: Tap to click
- Keyboard: Fast repeat, no auto-correct
- Screenshots: PNG to Desktop
- Screensaver: Immediate password

## 📁 Repository Structure

```
~/.config/
├── nix/
│   └── flake.nix              # System packages, apps, and macOS settings
├── fish/
│   ├── config.fish            # Fish shell configuration
│   └── functions/             # Custom Fish commands
├── helix/                     # Helix editor configuration
├── wezterm/
│   └── wezterm.lua           # WezTerm terminal configuration
├── claude/                    # Claude Code configuration
│   ├── agents/               # Specialist agent personas
│   └── commands/             # Slash commands
├── scripts/
│   ├── bootstrap-new-mac-improved.sh  # Automated setup script v2.0
│   ├── quick-install.sh               # One-line installer
│   ├── setup-ruby.fish                # Ruby environment setup
│   ├── validate-ruby.fish             # Ruby validation
│   └── validate-system.fish           # System validation
└── templates/                 # Project templates
```

## 🔧 Management Commands

### System Updates
```fish
rebuild              # Build and activate nix-darwin changes
rebuild --diff       # Preview changes before applying
rebuild --commit     # Commit changes before rebuilding
rollback             # Revert to previous generation
nixstatus            # Show current system generation
```

### Configuration
```fish
config helix         # Edit Helix config
config nix           # Edit nix configuration
config fish          # Edit Fish config
config wezterm       # Edit WezTerm config
```

### Project Management
```fish
newproject my-app --type node --tdd    # Scaffold new project
mkcd path/to/dir                       # Create and cd to directory
```

### Validation
```fish
~/.config/scripts/validate-system.fish  # Validate system configuration
```

## 📁 Configuration Structure

```
~/.config/
├── nix/
│   └── flake.nix              # Main system configuration
├── fish/
│   └── config.fish            # Fish shell setup
├── nushell/
│   ├── config.nu              # Nushell main config
│   ├── env.nu                 # Environment variables
│   └── scripts/               # Custom Nushell commands
│       ├── mod.nu             # Module loader
│       ├── cfg.nu             # Configuration editor
│       ├── rebuild.nu         # System rebuild management
│       ├── rollback.nu        # Generation rollback
│       ├── nixstatus.nu       # System status checker
│       └── mkcd.nu            # Enhanced directory creation
├── helix/
│   ├── config.toml            # Editor configuration
│   ├── languages.toml         # Language server setup
│   └── themes/mytheme.toml    # Custom theme
├── wezterm/                   # Advanced terminal configuration
│   ├── wezterm.lua            # Main config
│   ├── config/                # Modular configuration
│   └── utils/                 # GPU optimization utilities
├── zellij/                    # Terminal multiplexer config
├── yazi/                      # File manager configuration  
└── CLAUDE.md                  # AI assistant guidance
```

## 🔧 Customization

### Adding New Packages

Edit `nix/flake.nix` and add packages to `environment.systemPackages`:

```nix
environment.systemPackages = [
  pkgs.neovim        # Add new packages here
  pkgs.git
  # ... existing packages
];
```

### Adding Homebrew Apps

Add to the `homebrew` section in `flake.nix`:

```nix
homebrew = {
  casks = [
    "visual-studio-code"  # Add new casks
    # ... existing casks
  ];
  brews = [
    "wget"               # Add new brews  
    # ... existing brews
  ];
};
```

### Creating Custom Commands

Add new Nushell commands in `nushell/scripts/`:

1. Create `nushell/scripts/mycommand.nu`
2. Add `export use mycommand.nu mycommand` to `nushell/scripts/mod.nu`
3. Rebuild: `rebuild`

## 🚨 Troubleshooting

### System Won't Build
```bash
# Check for syntax errors
nix flake check

# Build without activation first
rebuild build

# Check specific error logs
sudo darwin-rebuild build --flake .#macbook --show-trace
```

### Rollback Failed Changes
```bash
# List available generations
sudo darwin-rebuild --list-generations

# Rollback to previous generation
rollback

# Or rollback to specific generation
sudo darwin-rebuild --switch --rollback --flake .#macbook
```

### Shell Issues
```bash
# Reset to default shell
chsh -s /bin/zsh

# Check available shells
cat /etc/shells

# Verify Fish installation
which fish
```

## 🔄 Migration Guide

### From Existing macOS Setup

1. **Backup current configs**:
   ```bash
   cp -r ~/.config ~/.config.backup
   ```

2. **Identify current packages**:
   ```bash
   brew list > brew-packages.txt
   ls /Applications > applications.txt
   ```

3. **Install this configuration** (see Installation above)

4. **Migrate personal settings**:
   - Copy any custom scripts or aliases
   - Update `flake.nix` with your preferred packages
   - Customize configs in each tool's directory

### From Other Nix Configurations

- Replace the `flake.nix` inputs and outputs
- Merge your packages into `environment.systemPackages`
- Adapt any NixOS-specific options to nix-darwin equivalents

## 📖 Learning Resources

### Nix & NixOS
- [Nix Pills](https://nixos.org/guides/nix-pills/) - Deep dive into Nix
- [nix-darwin Manual](https://daiderd.com/nix-darwin/manual/) - macOS-specific options
- [Nix Flakes](https://nixos.wiki/wiki/Flakes) - Modern Nix configuration

### Shell & Terminal
- [Fish Documentation](https://fishshell.com/docs/current/) - Fish shell guide
- [Nushell Book](https://www.nushell.sh/book/) - Structured shell guide  
- [WezTerm Config](https://wezfurlong.org/wezterm/config/files.html) - Terminal configuration

### Development Tools
- [Helix Documentation](https://docs.helix-editor.com/) - Modern modal editor
- [Zellij Docs](https://zellij.dev/) - Terminal multiplexer guide

## 🤝 Contributing

1. Fork this repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Test your changes: `rebuild build`
4. Commit your changes: `git commit -m 'Add amazing feature'`
5. Push to the branch: `git push origin feature/amazing-feature`
6. Open a Pull Request

## 📝 License

This configuration is open source and available under the [MIT License](LICENSE).

## ⭐ Acknowledgments

- [nix-darwin](https://github.com/LnL7/nix-darwin) - Nix modules for macOS
- [WezTerm Config](https://github.com/KevinSilvester/wezterm-config) - Terminal configuration inspiration
- [Helix Editor](https://helix-editor.com/) - Modern modal editor
- [Nushell](https://www.nushell.sh/) - Structured data shell

---

**Ready to dive in?** Start with `rebuild --help` and explore your new development environment! 🚀