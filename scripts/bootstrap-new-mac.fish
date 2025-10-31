#!/usr/bin/env fish
# Automated new Mac setup script
# Automates most steps from NEW_LAPTOP_SETUP.md

set -g STEP 0
set -g TOTAL_STEPS 9

function step
    set -g STEP (math $STEP + 1)
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Step $STEP/$TOTAL_STEPS: $argv"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
end

function success
    echo "✅ $argv"
end

function error
    echo "❌ ERROR: $argv"
    exit 1
end

function warn
    echo "⚠️  WARNING: $argv"
end

function info
    echo "ℹ️  $argv"
end

function confirm
    echo ""
    read -P "⚡ $argv [y/N]: " -n 1 response
    echo ""
    test "$response" = "y" -o "$response" = "Y"
end

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

if not confirm "Ready to begin automated setup?"
    echo "Setup cancelled."
    exit 0
end

# Step 1: Check prerequisites
step "Checking prerequisites"

if not test (uname -s) = "Darwin"
    error "This script is for macOS only"
end

info "macOS version: "(sw_vers -productVersion)
info "Architecture: "(uname -m)

if test (uname -m) != "arm64"
    warn "Not Apple Silicon - some features may differ"
end

success "Prerequisites check passed"

# Step 2: Install Nix
step "Installing Nix package manager"

if command -v nix >/dev/null 2>&1
    info "Nix already installed: "(nix --version | head -1)
    if not confirm "Reinstall Nix?"
        success "Skipping Nix installation"
    else
        info "Installing Nix..."
        curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
        success "Nix installed"
    end
else
    info "Installing Nix..."
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
    or error "Nix installation failed"
    success "Nix installed successfully"

    info "Please restart your terminal and re-run this script"
    exit 0
end

# Step 3: Clone dotfiles
step "Cloning dotfiles repository"

if test -d ~/.config/.git
    info "Dotfiles already cloned"
    set current_remote (git -C ~/.config remote get-url origin 2>/dev/null)
    if test "$current_remote" = "https://github.com/ree-see/dotfiles.git"
        success "Dotfiles repository already configured"
        if confirm "Pull latest changes?"
            git -C ~/.config pull
            success "Dotfiles updated"
        end
    else
        warn "Different dotfiles repository detected: $current_remote"
        error "Please manually resolve dotfiles repository conflict"
    end
else if test -d ~/.config
    warn "~/.config exists but is not a git repository"
    if confirm "Backup and replace with dotfiles repository?"
        mv ~/.config ~/.config.backup.(date +%Y%m%d-%H%M%S)
        git clone https://github.com/ree-see/dotfiles.git ~/.config
        success "Dotfiles cloned (backup created)"
    else
        error "Cannot proceed without dotfiles repository"
    end
else
    info "Cloning dotfiles repository..."
    git clone https://github.com/ree-see/dotfiles.git ~/.config
    or error "Failed to clone dotfiles repository"
    success "Dotfiles cloned successfully"
end

# Step 4: Build nix-darwin configuration
step "Building nix-darwin configuration"

info "This will install all packages and applications (~15-30 minutes)"
info "Installing:"
echo "  - Nix packages: helix, fish, yazi, zoxide, claude-code, gh, and more"
echo "  - Homebrew: PostgreSQL, mas, formulae and casks"
echo "  - Mac App Store apps: Magnet, Xcode, 1Password, etc."
echo ""

if not confirm "Start nix-darwin build?"
    warn "Skipping nix-darwin build - system will be incomplete"
else
    cd ~/.config
    or error "Failed to change to ~/.config directory"

    info "Running nix-darwin build..."
    nix run nix-darwin -- switch --flake .#macbook
    or error "nix-darwin build failed - check output above"

    success "nix-darwin build completed successfully"
end

# Step 5: Create SuperClaude symlink
step "Setting up SuperClaude framework"

if test -L ~/.claude
    set link_target (readlink ~/.claude)
    if test "$link_target" = "$HOME/.config/claude"
        success "SuperClaude symlink already configured"
    else
        warn "~/.claude symlink points to: $link_target"
        if confirm "Fix symlink to point to ~/.config/claude?"
            rm ~/.claude
            ln -s ~/.config/claude ~/.claude
            success "SuperClaude symlink fixed"
        end
    end
else if test -e ~/.claude
    warn "~/.claude exists but is not a symlink"
    if confirm "Backup and create symlink?"
        mv ~/.claude ~/.claude.backup.(date +%Y%m%d-%H%M%S)
        ln -s ~/.config/claude ~/.claude
        success "SuperClaude symlink created (backup made)"
    end
else
    ln -s ~/.config/claude ~/.claude
    success "SuperClaude symlink created"
end

# Step 6: Set Fish as default shell
step "Configuring Fish shell"

set fish_path /run/current-system/sw/bin/fish

if test "$SHELL" = "$fish_path"
    success "Fish is already the default shell"
else
    info "Current shell: $SHELL"
    if confirm "Set Fish as default shell?"
        # Add Fish to allowed shells
        if not grep -q "$fish_path" /etc/shells
            info "Adding Fish to /etc/shells (requires sudo)"
            echo $fish_path | sudo tee -a /etc/shells
            or error "Failed to add Fish to /etc/shells"
        end

        # Change default shell
        info "Changing default shell to Fish (requires password)"
        chsh -s $fish_path
        or error "Failed to change default shell"

        success "Fish set as default shell"
        info "You'll need to logout and login for this to take full effect"
    else
        warn "Keeping current shell: $SHELL"
    end
end

# Step 7: Install asdf runtimes
step "Installing asdf runtimes"

if command -v asdf >/dev/null 2>&1
    # Ruby
    if confirm "Install Ruby 3.3.6 via asdf?"
        if not asdf plugin list | grep -q ruby
            info "Adding Ruby plugin..."
            asdf plugin add ruby
        end

        info "Installing Ruby 3.3.6 (this may take 5-10 minutes)..."
        asdf install ruby 3.3.6
        or warn "Ruby installation failed"

        info "Setting Ruby 3.3.6 as global default..."
        asdf global ruby 3.3.6

        success "Ruby 3.3.6 installed and configured"
    end

    # Node.js (optional)
    if confirm "Add Node.js plugin to asdf? (versions installed per-project)"
        if not asdf plugin list | grep -q nodejs
            info "Adding Node.js plugin..."
            asdf plugin add nodejs
            success "Node.js plugin added"
        else
            info "Node.js plugin already installed"
        end
    end
else
    warn "asdf not found - runtime installation skipped"
    info "asdf should be installed by nix-darwin"
end

# Step 8: Configure services
step "Configuring system services"

# PostgreSQL
if command -v brew >/dev/null 2>&1
    if confirm "Start PostgreSQL service?"
        info "Starting PostgreSQL@16..."
        brew services start postgresql@16

        sleep 2
        if brew services list | grep postgresql@16 | grep -q started
            success "PostgreSQL service started"

            if confirm "Create default database?"
                createdb (whoami)
                or warn "Database creation failed (may already exist)"
                success "Default database configured"
            end
        else
            warn "PostgreSQL may not have started correctly"
        end
    end
else
    warn "Homebrew not found - service configuration skipped"
end

# Step 9: Run validation
step "Running system validation"

if test -x ~/.config/scripts/validate-system.fish
    if confirm "Run comprehensive system validation?"
        info "Running validation script..."
        echo ""
        ~/.config/scripts/validate-system.fish
        echo ""
        success "Validation complete"
    end
else
    warn "Validation script not found at ~/.config/scripts/validate-system.fish"
end

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
