# macOS Development Environment with Nix Darwin

A comprehensive, declarative macOS development environment managed through nix-darwin flakes, featuring dual shell support (Fish + Nushell) and modern terminal tools.

## 🚀 Features

- **Declarative System Management**: Everything managed through nix-darwin flakes
- **Dual Shell Environment**: Fish shell with enhanced Nushell integration
- **Modern Development Tools**: Helix editor, WezTerm terminal, Zellij multiplexer
- **Custom Configuration Management**: Unified `cfg` command for editing configs
- **Safe System Rebuilds**: Built-in rollback and generation management
- **Touch ID Integration**: Secure sudo authentication
- **Homebrew Integration**: Seamless integration with Mac-native apps

## 📦 What's Included

### System Packages (via Nix)
- **Editors**: Helix, Nil (Nix LSP)
- **Shells**: Fish, Nushell
- **Terminal Tools**: Zellij, Yazi, Zoxide, Lazygit
- **Development**: Node.js, TypeScript LSP, Prettier, Ruby, Solargraph
- **CLI Tools**: 1Password CLI, Watchman, Yarn

### Applications (via Homebrew)
- **Terminal**: Ghostty, WezTerm
- **Productivity**: Raycast
- **Databases**: PostgreSQL
- **Development**: rbenv

### Mac App Store Apps
- **Window Management**: Magnet
- **Development**: Xcode

## 🛠 Installation

### Prerequisites
- macOS (Apple Silicon recommended)
- Nix package manager
- Git

### Quick Setup

1. **Install Nix with flakes support**:
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```

2. **Clone this configuration**:
   ```bash
   git clone <your-repo-url> ~/.config
   cd ~/.config
   ```

3. **Initial system build**:
   ```bash
   # Build the configuration
   sudo darwin-rebuild build --flake .#macbook
   
   # If successful, activate it
   sudo darwin-rebuild switch --flake .#macbook
   ```

4. **Set up shells**:
   ```bash
   # Add Fish to available shells
   echo /run/current-system/sw/bin/fish | sudo tee -a /etc/shells
   
   # Change default shell to Fish
   chsh -s /run/current-system/sw/bin/fish
   ```

## 🎯 Usage

### Configuration Management

Edit any tool's configuration using the unified `cfg` command:

```bash
# Edit specific tool configs
cfg helix          # Helix editor settings
cfg nix            # Nix flake configuration  
cfg fish           # Fish shell config
cfg nushell        # Nushell configuration
cfg wezterm        # WezTerm terminal settings
cfg zellij         # Zellij multiplexer config
```

### System Management

Manage your nix-darwin system with enhanced commands:

```bash
# Quick system rebuild
rebuild

# Commit changes and rebuild
rebuild --commit

# Build without activating (test first)
rebuild build

# Show what will change
rebuild --diff

# Revert to previous generation
rollback

# Check system status
nixstatus
```

### Shell Experience

**Fish Shell** (Primary):
- Fast, user-friendly with autocompletions
- Minimal configuration in `fish/config.fish`

**Nushell** (Enhanced):
- Structured data and powerful pipelines
- Enhanced versions of all Fish functions
- Type-safe commands with built-in help

```bash
# Try Nushell anytime
nu

# Test enhanced commands
mkcd project1 project2     # Create multiple dirs, cd to last
rebuild --help             # Comprehensive help for all commands
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