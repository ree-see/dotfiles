#!/bin/bash
# Automated new Mac setup script
# Automates most steps from NEW_LAPTOP_SETUP.md

set -e

STEP=0
TOTAL_STEPS=9

step() {
    STEP=$((STEP + 1))
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Step $STEP/$TOTAL_STEPS: $*"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

success() {
    echo "✅ $*"
}

error() {
    echo "❌ ERROR: $*"
    exit 1
}

warn() {
    echo "⚠️  WARNING: $*"
}

info() {
    echo "ℹ️  $*"
}

confirm() {
    echo ""
    read -p "⚡ $* [y/N]: " -n 1 response
    echo ""
    [[ "$response" == "y" || "$response" == "Y" ]]
}

# Banner
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Automated New MacBook Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "This script automates the setup from NEW_LAPTOP_SETUP.md"
echo "It will install and configure your complete development environment."
echo ""
info "Prerequisites:"
echo "  - macOS (Apple Silicon recommended)"
echo "  - Admin access"
echo "  - Internet connection"
echo ""

if ! confirm "Ready to begin automated setup?"; then
    echo "Setup cancelled."
    exit 0
fi

# Step 1: Check prerequisites
step "Checking prerequisites"

if [[ "$(uname -s)" != "Darwin" ]]; then
    error "This script is for macOS only"
fi

info "macOS version: $(sw_vers -productVersion)"
info "Architecture: $(uname -m)"

if [[ "$(uname -m)" != "arm64" ]]; then
    warn "Not Apple Silicon - some features may differ"
fi

success "Prerequisites check passed"

# Step 2: Install Nix
step "Installing Nix package manager"

if command -v nix &>/dev/null; then
    info "Nix already installed: $(nix --version | head -1)"
    if ! confirm "Reinstall Nix?"; then
        success "Skipping Nix installation"
    else
        info "Installing Nix..."
        curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
        success "Nix installed"
    fi
else
    info "Installing Nix..."
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install || error "Nix installation failed"
    success "Nix installed successfully"

    info "Please restart your terminal and re-run this script"
    exit 0
fi

# Step 3: Clone dotfiles
step "Cloning dotfiles repository"

if [[ -d ~/.config/.git ]]; then
    info "Dotfiles already cloned"
    current_remote=$(git -C ~/.config remote get-url origin 2>/dev/null)
    if [[ "$current_remote" == "https://github.com/ree-see/dotfiles.git" ]]; then
        success "Dotfiles repository already configured"
        if confirm "Pull latest changes?"; then
            git -C ~/.config pull
            success "Dotfiles updated"
        fi
    else
        warn "Different dotfiles repository detected: $current_remote"
        error "Please manually resolve dotfiles repository conflict"
    fi
elif [[ -d ~/.config ]]; then
    warn "~/.config exists but is not a git repository"
    if confirm "Backup and replace with dotfiles repository?"; then
        mv ~/.config ~/.config.backup.$(date +%Y%m%d-%H%M%S)
        git clone https://github.com/ree-see/dotfiles.git ~/.config
        success "Dotfiles cloned (backup created)"
    else
        error "Cannot proceed without dotfiles repository"
    fi
else
    info "Cloning dotfiles repository..."
    git clone https://github.com/ree-see/dotfiles.git ~/.config || error "Failed to clone dotfiles repository"
    success "Dotfiles cloned successfully"
fi

# Step 4: Build nix-darwin configuration
step "Building nix-darwin configuration"

info "This will install all packages and applications (~15-30 minutes)"
info "Installing:"
echo "  - Nix packages: helix, fish, yazi, zoxide, claude-code, gh, and more"
echo "  - Homebrew: PostgreSQL, mas, formulae and casks"
echo "  - Mac App Store apps: Magnet, Xcode, 1Password, etc."
echo ""

if ! confirm "Start nix-darwin build?"; then
    warn "Skipping nix-darwin build - system will be incomplete"
else
    cd ~/.config || error "Failed to change to ~/.config directory"

    info "Running nix-darwin build..."
    nix run nix-darwin -- switch --flake .#macbook || error "nix-darwin build failed - check output above"

    success "nix-darwin build completed successfully"
fi

# Step 5: Create SuperClaude symlink
step "Setting up SuperClaude framework"

if [[ -L ~/.claude ]]; then
    link_target=$(readlink ~/.claude)
    if [[ "$link_target" == "$HOME/.config/claude" ]]; then
        success "SuperClaude symlink already configured"
    else
        warn "~/.claude symlink points to: $link_target"
        if confirm "Fix symlink to point to ~/.config/claude?"; then
            rm ~/.claude
            ln -s ~/.config/claude ~/.claude
            success "SuperClaude symlink fixed"
        fi
    fi
elif [[ -e ~/.claude ]]; then
    warn "~/.claude exists but is not a symlink"
    if confirm "Backup and create symlink?"; then
        mv ~/.claude ~/.claude.backup.$(date +%Y%m%d-%H%M%S)
        ln -s ~/.config/claude ~/.claude
        success "SuperClaude symlink created (backup made)"
    fi
else
    ln -s ~/.config/claude ~/.claude
    success "SuperClaude symlink created"
fi

# Step 6: Set Fish as default shell
step "Configuring Fish shell"

fish_path="/run/current-system/sw/bin/fish"

if [[ "$SHELL" == "$fish_path" ]]; then
    success "Fish is already the default shell"
else
    info "Current shell: $SHELL"
    if confirm "Set Fish as default shell?"; then
        # Add Fish to allowed shells
        if ! grep -q "$fish_path" /etc/shells; then
            info "Adding Fish to /etc/shells (requires sudo)"
            echo "$fish_path" | sudo tee -a /etc/shells || error "Failed to add Fish to /etc/shells"
        fi

        # Change default shell
        info "Changing default shell to Fish (requires password)"
        chsh -s "$fish_path" || error "Failed to change default shell"

        success "Fish set as default shell"
        info "You'll need to logout and login for this to take full effect"
    else
        warn "Keeping current shell: $SHELL"
    fi
fi

# Step 7: Install asdf runtimes
step "Installing asdf runtimes"

if command -v asdf &>/dev/null; then
    # Ruby
    if confirm "Install Ruby 3.3.6 via asdf?"; then
        if ! asdf plugin list | grep -q ruby; then
            info "Adding Ruby plugin..."
            asdf plugin add ruby
        fi

        info "Installing Ruby 3.3.6 (this may take 5-10 minutes)..."
        asdf install ruby 3.3.6 || warn "Ruby installation failed"

        info "Setting Ruby 3.3.6 as global default..."
        asdf global ruby 3.3.6

        success "Ruby 3.3.6 installed and configured"
    fi

    # Node.js (optional)
    if confirm "Add Node.js plugin to asdf? (versions installed per-project)"; then
        if ! asdf plugin list | grep -q nodejs; then
            info "Adding Node.js plugin..."
            asdf plugin add nodejs
            success "Node.js plugin added"
        else
            info "Node.js plugin already installed"
        fi
    fi
else
    warn "asdf not found - runtime installation skipped"
    info "asdf should be installed by nix-darwin"
fi

# Step 8: Configure services
step "Configuring system services"

# PostgreSQL
if command -v brew &>/dev/null; then
    if confirm "Start PostgreSQL service?"; then
        info "Starting PostgreSQL@16..."
        brew services start postgresql@16

        sleep 2
        if brew services list | grep postgresql@16 | grep -q started; then
            success "PostgreSQL service started"

            if confirm "Create default database?"; then
                createdb "$(whoami)" || warn "Database creation failed (may already exist)"
                success "Default database configured"
            fi
        else
            warn "PostgreSQL may not have started correctly"
        fi
    fi
else
    warn "Homebrew not found - service configuration skipped"
fi

# Step 9: Run validation
step "Running system validation"

if [[ -x ~/.config/scripts/validate-system.fish ]]; then
    if confirm "Run comprehensive system validation?"; then
        info "Running validation script..."
        echo ""
        # Try to run with fish if available, otherwise skip
        if command -v fish &>/dev/null; then
            fish ~/.config/scripts/validate-system.fish
        else
            warn "Fish not available yet - validation skipped"
            info "Run manually after logout/login: ~/.config/scripts/validate-system.fish"
        fi
        echo ""
        success "Validation complete"
    fi
else
    warn "Validation script not found at ~/.config/scripts/validate-system.fish"
fi

# Completion
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 Automated Setup Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✅ Completed:"
echo "  - Nix package manager installed"
echo "  - Dotfiles repository cloned"
echo "  - nix-darwin configuration built"
echo "  - SuperClaude framework configured"
echo "  - Fish shell configured"
echo "  - Runtime versions installed"
echo "  - Services configured"
echo ""
echo "📋 Manual Steps Remaining:"
echo ""
echo "  1. Logout and login (for Fish shell to take effect)"
echo ""
echo "  2. Grant Terminal Full Disk Access:"
echo "     System Settings → Privacy & Security → Full Disk Access"
echo ""
echo "  3. GitHub CLI authentication:"
echo "     gh auth login"
echo ""
echo "  4. 1Password CLI sign-in:"
echo "     op signin"
echo ""
echo "  5. Configure Raycast:"
echo "     - Open Raycast"
echo "     - Grant accessibility permissions"
echo "     - Set hotkey (Cmd+Space)"
echo ""
echo "  6. Configure terminal apps (Warp/WezTerm)"
echo "     Settings will auto-load from ~/.config/"
echo ""
echo "📖 Full documentation: ~/.config/NEW_LAPTOP_SETUP.md"
echo ""
info "System is ready for development!"
echo ""
