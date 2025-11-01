# Dotfile Tracking Analysis for Deterministic Setup

## Analysis Date
2025-11-01

## Current State

### Already Tracked in ~/.config
- fish/ - Fish shell configuration
- helix/ - Helix editor configuration
- nix/ - Nix-darwin flake and system configuration
- wezterm/ - WezTerm terminal configuration
- yazi/ - Yazi file manager configuration
- op/ - 1Password CLI configuration
- scripts/ - Utility scripts
- templates/ - Project templates
- gh/ - GitHub CLI configuration
- git/ - Git configuration (partial)

### Currently Untracked in ~ Directory

## Recommendations by Category

### 🟢 SHOULD TRACK (Critical for Deterministic Setup)

#### Configuration Files
1. **~/.gitconfig**
   - Current location: Home directory
   - Recommendation: Move to `~/.config/git/config` and symlink
   - Rationale: Git configuration is essential for development workflow
   - Current content: User identity, editor preference (hx)

2. **~/.tool-versions**
   - Current location: Home directory
   - Recommendation: Move to `~/.config/asdf/.tool-versions` or document in nix
   - Rationale: Defines Ruby 3.3.6 and other runtime versions
   - Note: Consider managing via nix-darwin instead

3. **~/.ssh/config**
   - Current location: ~/.ssh/
   - Recommendation: Move to `~/.config/ssh/config` and symlink to ~/.ssh/config
   - Rationale: 1Password SSH agent integration is critical
   - Current content: IdentityAgent pointing to 1Password socket
   - Security note: Never track private keys

#### Shell Environment Files
4. **~/.zshenv**
   - Current content: `. "$HOME/.cargo/env"`
   - Recommendation: Move to `~/.config/zsh/.zshenv` and symlink
   - Rationale: Cargo environment setup (for Rust toolchain)

5. **~/.zprofile**
   - Current content: `eval "$(/opt/homebrew/bin/brew shellenv)"`
   - Recommendation: Move to `~/.config/zsh/.zprofile` and symlink
   - Rationale: Homebrew environment initialization

### 🟡 CONSIDER TRACKING (Project-Specific or Convenience)

6. **1Password CLI Configuration**
   - Current: `~/.config/op/` (already tracked)
   - Verify: Check if `~/.config/op/config` is properly tracked
   - Recommendation: Ensure all op configuration is in git

7. **~/.profile**
   - Recommendation: Review contents and determine if needed
   - May be redundant with fish/zsh configuration

### 🔴 DO NOT TRACK (Ephemeral, Generated, or Security-Sensitive)

#### Cache & State Directories
- **~/.asdf** - Runtime installations (managed by asdf)
- **~/.bundle** - Ruby gem cache
- **~/.cache** - Application cache
- **~/.cargo** - Rust toolchain and packages
- **~/.cocoapods** - iOS dependency cache
- **~/.docker** - Docker state
- **~/.expo** - Expo development cache
- **~/.gem** - Ruby gems
- **~/.local** - XDG local data
- **~/.npm** - npm cache
- **~/.rustup** - Rust toolchain manager state
- **~/.serena** - Serena MCP server state
- **~/.swiftpm** - Swift package manager cache
- **~/.warp** - Warp terminal settings (GUI app manages this)
- **~/.bun** - Bun runtime cache
- **~/.nix-defexpr** - Nix expression cache

#### Security-Sensitive
- **~/.ssh/id_ed25519** - Private SSH key (NEVER TRACK)
- **~/.ssh/id_ed25519.pub** - Public key (can track, but unnecessary)
- **~/.ssh/known_hosts** - Host fingerprints (generated)

#### Ephemeral Files
- **~/.bash_history** - Bash command history
- **~/.zsh_history** - Zsh command history
- **~/.viminfo** - Vim state
- **~/.lesshst** - Less history
- **~/.zcompdump** - Zsh completion cache
- **~/.DS_Store** - macOS metadata
- **~/.claude.json** - Claude CLI state (contains session data)

#### System-Managed
- **~/.app-store** - Mac App Store state
- **~/.learn** - Unknown learning tool state
- **~/.zsh_sessions** - Zsh session restoration

## Implementation Plan

### Step 1: Organize Configuration Structure
```bash
# Create new directories in ~/.config
mkdir -p ~/.config/git
mkdir -p ~/.config/ssh
mkdir -p ~/.config/zsh
mkdir -p ~/.config/asdf
```

### Step 2: Move Files to ~/.config
```bash
# Git configuration
mv ~/.gitconfig ~/.config/git/config
ln -s ~/.config/git/config ~/.gitconfig

# SSH configuration (keep sensitive files in ~/.ssh)
mv ~/.ssh/config ~/.config/ssh/config
ln -s ~/.config/ssh/config ~/.ssh/config

# Zsh configuration
mv ~/.zshenv ~/.config/zsh/.zshenv
ln -s ~/.config/zsh/.zshenv ~/.zshenv

mv ~/.zprofile ~/.config/zsh/.zprofile
ln -s ~/.config/zsh/.zprofile ~/.zprofile

# asdf tool versions
mv ~/.tool-versions ~/.config/asdf/.tool-versions
ln -s ~/.config/asdf/.tool-versions ~/.tool-versions
```

### Step 3: Update .gitignore in ~/.config
```gitignore
# Add to ~/.config/.gitignore if not already present
result/
.DS_Store
*.backup
claudedocs/research_*.md
```

### Step 4: Nix-Darwin Integration
Consider adding to flake.nix for home-manager:
```nix
# Future enhancement: Use home-manager for dotfile management
home-manager = {
  users.reesee = {
    home.file = {
      ".gitconfig".source = ./git/config;
      ".ssh/config".source = ./ssh/config;
      ".tool-versions".source = ./asdf/.tool-versions;
    };
  };
};
```

## Alternative Approach: Pure Nix Management

Instead of symlinks, consider managing everything through nix-darwin:

### Git Configuration via Nix
```nix
programs.git = {
  enable = true;
  userName = "Jackson Risse";
  userEmail = "j.risse14@proton.me";
  extraConfig = {
    core.editor = "hx";
  };
};
```

### SSH Configuration via Nix
```nix
programs.ssh = {
  enable = true;
  extraConfig = ''
    Host *
      IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
  '';
};
```

### ASDF Tool Versions
Document in nix-darwin or manage directly via nix packages instead of asdf.

## Summary Statistics

- **Total dotfiles/directories in ~**: 32
- **Should track**: 5 critical files
- **Already tracking**: 10+ directories in ~/.config
- **Should NOT track**: 27 ephemeral/cache directories and files

## Key Principles Applied

1. **Security First**: Never track private keys or sensitive credentials
2. **Reproducibility**: Track configuration that defines system behavior
3. **Separation**: Keep generated/cached data separate from configuration
4. **Simplicity**: Prefer nix-darwin declarative config over file tracking when possible
5. **Clarity**: Clear distinction between tracked config and runtime state

## Next Steps

1. Review and approve this analysis
2. Execute Step 1-3 to organize files
3. Test symlink approach to ensure no breakage
4. Consider migrating to pure nix-darwin configuration (Step 4)
5. Update bootstrap script to handle these configurations
