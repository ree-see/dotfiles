# New MacBook Setup Guide

Complete checklist for reproducing this exact system configuration on a new Mac.

## Prerequisites
- macOS installed (Apple Silicon / aarch64)
- Internet connection established
- Admin access to the Mac

## Step 1: Install Nix Package Manager

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Restart terminal after installation.

## Step 2: Clone Dotfiles Repository

```bash
# Clone into ~/.config
git clone https://github.com/ree-see/dotfiles.git ~/.config

# Navigate to config directory
cd ~/.config
```

**Important**: The SuperClaude framework is included at `~/.config/claude/`

## Step 3: Initial nix-darwin Build

```bash
cd ~/.config
nix run nix-darwin -- switch --flake .#macbook
```

This will install:
- **Nix packages**: helix, fish, yazi, zoxide, claude-code, gh, 1password-cli, pre-commit, asdf, nodejs, pnpm, go, golangci-lint, lua, nil, uv, watchman, TypeScript tools, prettier
- **Fonts**: JetBrains Mono Nerd Font
- **Homebrew**: PostgreSQL@16, mas, libyaml, openssl@3, ifstat
- **Homebrew casks**: Raycast, Spotify, Warp, WezTerm
- **Mac App Store apps**: 1Password for Safari, Apple Configurator, Magnet, OverPicture, Wipr, Xcode

**Note**: This may take 15-30 minutes on first run.

## Step 4: Create SuperClaude Symlink

```bash
# The claude directory is in ~/.config/claude
# Create symlink at ~/.claude for compatibility
ln -s ~/.config/claude ~/.claude
```

## Step 5: Set Fish as Default Shell

```bash
# Add Fish to allowed shells
echo /run/current-system/sw/bin/fish | sudo tee -a /etc/shells

# Change default shell
chsh -s /run/current-system/sw/bin/fish
```

Logout and login for shell change to take effect.

## Step 6: Install Runtime Versions with asdf

```bash
# Ruby
asdf plugin add ruby
asdf install ruby 3.3.6
asdf global ruby 3.3.6

# Node.js (optional, project-specific)
asdf plugin add nodejs
# Install Node versions as needed per project
```

## Step 7: Configure Services

### PostgreSQL
```bash
# Start PostgreSQL service
brew services start postgresql@16

# Verify it's running
brew services list | grep postgresql

# Optional: Create default database
createdb $(whoami)
```

### 1Password CLI
```bash
# Sign in to 1Password
op signin
```

## Step 8: Manual Configuration Steps

### Grant Terminal Full Disk Access
1. Open System Settings → Privacy & Security → Full Disk Access
2. Add your terminal app (Warp or WezTerm)
3. Restart terminal

### Configure Raycast
1. Open Raycast
2. Grant accessibility permissions
3. Set hotkey (recommended: Cmd+Space)
4. Configure extensions as needed

### GitHub CLI Authentication
```bash
gh auth login
# Choose: GitHub.com → SSH → Follow prompts
```

### WezTerm Configuration
WezTerm config is automatically loaded from `~/.config/wezterm/wezterm.lua`
- Config includes: Font, colors, pane management, copy/paste keybindings
- No manual setup needed

### Warp Configuration
1. Open Warp
2. Settings → Features → Set Fish as default shell
3. Fish config is automatically loaded from `~/.config/fish/config.fish`

## Step 9: Run Automated Validation

**Run the comprehensive validation script**:
```bash
~/.config/scripts/validate-system.fish
```

This script tests:
- All 18 Nix packages (helix, fish, node, pnpm, go, etc.)
- All 3 Homebrew formulae (postgresql@16, mas, ifstat)
- All 4 Homebrew casks (raycast, spotify, warp, wezterm)
- All 6 Mac App Store apps (including Xcode, 1Password, etc.)
- asdf Ruby installation and version
- Custom Fish commands (rebuild, config, newproject, etc.)
- Configuration files (flake.nix, fish config, helix, wezterm, claude)
- SuperClaude framework symlink
- System defaults (Dock, Finder settings)
- PostgreSQL service status
- Font installation
- Git configuration
- Shell and PATH setup

**Expected output**:
```
✅ Passed:  54
⚠️  Warnings: 1 (default shell - expected on first run)
❌ Failed:  0
```

If any tests fail, the script will show exactly what's missing.

## Step 10: Manual Verification

### Test System Commands
```bash
# Verify Nix packages
hx --version                    # Helix editor (custom build)
fish --version                  # Fish shell
pnpm --version                  # pnpm package manager
go version                      # Go language
claude --version                # Claude Code CLI

# Verify Homebrew packages
psql --version                  # PostgreSQL 16.x
brew services list              # Should show postgresql running

# Verify asdf
ruby --version                  # Ruby 3.3.6
asdf current                    # Show all runtime versions

# Verify custom Fish commands
rebuild --help                  # nix-darwin rebuild helper
config --help                   # Config file editor
newproject --help               # Project scaffolding
nixstatus                       # System generation info
```

### Test Claude Code Setup
```bash
# Check SuperClaude framework is accessible
ls -la ~/.claude                # Should be symlink to ~/.config/claude
ls ~/.claude/*.md               # Should list MODE_*.md, RULES.md, etc.

# Test Claude Code
claude
```

## System State Reference

### Declarative Configuration
All system state is defined in `~/.config/nix/flake.nix`:

**Nix Packages** (environment.systemPackages):
- Editor: helix (custom build from github:ree-see/helix)
- Shell: fish
- Tools: yazi, zoxide, gh, 1password-cli, pre-commit, asdf
- Languages: nodejs, pnpm, go, golangci-lint, lua, nil, uv
- Development: watchman, typescript-language-server, eslint, prettier

**Homebrew Formulae**:
- postgresql@16, mas, libyaml, openssl@3, ifstat

**Homebrew Casks**:
- raycast, spotify, warp, wezterm

**Mac App Store**:
- 1Password for Safari (1569813296)
- Apple Configurator (1037126344)
- Magnet (441258766)
- OverPicture (1188020834)
- Wipr (1662217862)
- Xcode (497799835)

**System Defaults** (configured in flake.nix):
- Dock: Auto-hide, no recents, 48px icons
- Finder: Show extensions, path bar, status bar
- Trackpad: Tap to click
- Keyboard: Fast repeat, no auto-correct
- Screenshots: PNG format to Desktop
- Menu bar: 24-hour time
- Screensaver: Immediate password requirement

### Configuration Files
All tracked in git at `~/.config/`:
- `nix/flake.nix` - System packages and settings
- `fish/config.fish` - Fish shell configuration
- `helix/` - Helix editor config
- `wezterm/wezterm.lua` - WezTerm terminal config
- `claude/` - SuperClaude framework (symlinked to ~/.claude)

### Not Tracked (Manual Setup Required)
- [ ] SSH keys (~/.ssh/)
- [ ] GPG keys (if used)
- [ ] 1Password account credentials
- [ ] GitHub authentication
- [ ] Raycast preferences and extensions
- [ ] Browser settings and extensions
- [ ] Project-specific .tool-versions files

## Managing the System

### Update Configuration
```bash
cd ~/.config
# Make changes to nix/flake.nix or other configs
rebuild                         # Build and activate changes
```

### Rollback Changes
```bash
rollback                        # Revert to previous generation
```

### Check System Status
```bash
nixstatus                       # Show current generation
```

### Update All Packages
```bash
cd ~/.config
nix flake update               # Update flake inputs
rebuild                        # Apply updates
```

## Troubleshooting

### "darwin-rebuild: command not found"
First time only, use:
```bash
nix run nix-darwin -- switch --flake ~/.config#macbook
```

### Homebrew not in PATH
Logout and login, or:
```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### Fish not recognized as valid shell
```bash
# Verify Fish is in /etc/shells
cat /etc/shells | grep fish

# If not, add it:
echo /run/current-system/sw/bin/fish | sudo tee -a /etc/shells
```

### PostgreSQL connection errors
```bash
# Check service status
brew services list | grep postgresql

# Restart if needed
brew services restart postgresql@16
```

### asdf runtime not switching
```bash
# Verify .tool-versions exists in project
cat .tool-versions

# Install if version missing
asdf install
```

## Development Workflow

### Create New Project
```bash
newproject my-app --type node --tdd
# Creates ~/dev/my-app with git, .gitignore, CLAUDE.md, and optional TDD hooks
```

### Clone Existing Projects
```bash
cd ~/dev
git clone <repo-url>
cd <project>
asdf install                   # Install runtimes from .tool-versions
pnpm install                   # Install Node dependencies (if Node project)
bundle install                 # Install Ruby gems (if Ruby project)
```

## Expected Setup Time

- Nix installation: 5 minutes
- nix-darwin first build: 20-30 minutes (downloads all packages)
- Manual configuration: 15 minutes
- Verification: 5 minutes

**Total: ~45-55 minutes**

## Post-Setup

### Backup Strategy
- **System config**: Automatically backed up via git (push changes regularly)
- **Projects**: Individual git repos in ~/dev/
- **Application data**: Time Machine or cloud backup
- **Secrets**: 1Password

### Keep System Updated
```bash
# Weekly or as needed:
cd ~/.config
git pull                       # Get latest config changes
nix flake update              # Update package versions
rebuild                       # Apply updates
```

### Test Reproducibility
This setup guide should produce a system identical to the original. Document any manual steps discovered during setup and add them to this guide.
