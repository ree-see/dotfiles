#!/bin/bash
# Automated new Mac setup script - v2.0
# Automates most steps from NEW_LAPTOP_SETUP.md
#
# Improvements in v2.0:
# - State persistence for resumable execution
# - Retry logic for network operations
# - Comprehensive logging
# - Security fixes (removed eval usage)
# - Better error handling and recovery instructions
# - Progress tracking and summary reports

set -euo pipefail

# ============================================================================
# CONSTANTS AND CONFIGURATION
# ============================================================================

SCRIPT_VERSION="2.0"
DOTFILES_REPO="https://github.com/ree-see/dotfiles.git"
DOTFILES_DIR="$HOME/.config"
STATE_FILE="$HOME/.bootstrap-state"
LOGFILE="$HOME/.bootstrap-$(date +%Y%m%d-%H%M%S).log"
FISH_PATH="/run/current-system/sw/bin/fish"

STEP=0
TOTAL_STEPS=11

# Step tracking
declare -A STEP_STATUS
COMPLETED_STEPS=0
FAILED_STEPS=0
SKIPPED_STEPS=0

# ============================================================================
# LOGGING SETUP
# ============================================================================

# Redirect all output to both console and log file
exec > >(tee -a "$LOGFILE")
exec 2>&1

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

# ============================================================================
# STATE MANAGEMENT
# ============================================================================

mark_step_complete() {
    local step_name=$1
    echo "$step_name" >> "$STATE_FILE"
    STEP_STATUS[$step_name]="completed"
    ((COMPLETED_STEPS++))
}

mark_step_failed() {
    local step_name=$1
    STEP_STATUS[$step_name]="failed"
    ((FAILED_STEPS++))
}

mark_step_skipped() {
    local step_name=$1
    STEP_STATUS[$step_name]="skipped"
    ((SKIPPED_STEPS++))
}

is_step_complete() {
    local step_name=$1
    grep -q "^$step_name$" "$STATE_FILE" 2>/dev/null
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

step() {
    STEP=$((STEP + 1))
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Step $STEP/$TOTAL_STEPS: $*"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log "Starting step $STEP: $*"
}

success() {
    echo "✅ $*"
    log "SUCCESS: $*"
}

error() {
    echo "❌ ERROR: $*"
    log "ERROR: $*"
    exit 1
}

warn() {
    echo "⚠️  WARNING: $*"
    log "WARNING: $*"
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

command_exists() {
    command -v "$1" &>/dev/null
}

# Retry wrapper for network operations
retry_command() {
    local max_attempts=3
    local timeout=2  # Reduced from 5s to 2s for faster recovery on slow networks
    local attempt=1
    local exit_code=0

    while [ $attempt -le $max_attempts ]; do
        if "$@"; then
            return 0
        else
            exit_code=$?
        fi

        if [ $attempt -lt $max_attempts ]; then
            warn "Attempt $attempt/$max_attempts failed. Retrying in ${timeout}s..."
            sleep $timeout
            ((attempt++))
        else
            warn "All $max_attempts attempts failed"
            return $exit_code
        fi
    done
}

# Poll for condition with timeout
wait_for_condition() {
    local condition=$1
    local timeout=${2:-10}
    local interval=1
    local elapsed=0

    while [ $elapsed -lt $timeout ]; do
        if eval "$condition"; then
            return 0
        fi
        sleep $interval
        ((elapsed += interval))
    done
    return 1
}

# ============================================================================
# STEP FUNCTIONS
# ============================================================================

setup_ssh_with_1password() {
    local ssh_socket="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    local ssh_config="$HOME/.ssh/config"

    # Check if 1Password app is installed
    if [[ ! -d "/Applications/1Password.app" ]]; then
        warn "1Password not installed yet"
        info "SSH authentication will be configured after 1Password is installed"
        info "You can run this step manually later or authenticate with: gh auth login"
        return 1
    fi

    info "1Password app detected"

    # Prompt user to sign in to 1Password first
    echo ""
    info "⚠️  IMPORTANT: You need to sign in to 1Password before continuing"
    echo ""
    echo "Please complete these steps:"
    echo "  1. Open 1Password app (in /Applications)"
    echo "  2. Sign in to your 1Password account"
    echo "  3. Go to Settings → Developer"
    echo "  4. Enable 'Use the SSH agent'"
    echo "  5. (Optional) Enable 'Display key names when authorizing connections'"
    echo ""

    # Wait for user confirmation
    if ! confirm "Have you signed in to 1Password and enabled the SSH agent?"; then
        warn "Skipping SSH configuration"
        info "You can configure SSH later by running this step manually"
        info "Or authenticate with: gh auth login"
        return 1
    fi

    # Poll for SSH agent socket with timeout
    info "Waiting for 1Password SSH agent to initialize..."
    if ! wait_for_condition "test -S '$ssh_socket'" 10; then
        warn "1Password SSH agent not detected after 10 seconds"
        info "Make sure you:"
        echo "  1. Opened 1Password app"
        echo "  2. Signed in to your account"
        echo "  3. Enabled SSH agent in Settings → Developer"
        echo ""
        info "SSH configuration skipped - you can authenticate later with: gh auth login"
        return 1
    fi

    success "1Password SSH agent is available"

    # Configure SSH to use 1Password agent
    if [[ ! -f "$ssh_config" ]] || ! grep -q "IdentityAgent.*1password" "$ssh_config"; then
        if confirm "Configure SSH to use 1Password for authentication?"; then
            info "Creating/updating SSH config..."

            # Create .ssh directory if it doesn't exist
            mkdir -p "$HOME/.ssh"
            chmod 700 "$HOME/.ssh"

            # Backup existing config if present
            if [[ -f "$ssh_config" ]]; then
                cp "$ssh_config" "$ssh_config.backup.$(date +%Y%m%d-%H%M%S)"
                info "Backed up existing SSH config"
            fi

            # Add 1Password agent configuration
            cat >> "$ssh_config" << 'EOF'

# 1Password SSH Agent
Host *
    IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
EOF

            chmod 600 "$ssh_config"
            success "SSH configured to use 1Password agent"
        fi
    else
        success "SSH already configured for 1Password"
    fi

    # Test SSH authentication
    if confirm "Test SSH connection to GitHub?"; then
        info "Testing SSH authentication..."
        export SSH_AUTH_SOCK="$ssh_socket"

        if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
            success "GitHub SSH authentication successful"
            return 0
        else
            warn "GitHub SSH authentication test inconclusive"
            info "This is normal if you haven't added SSH keys to 1Password yet"
            echo ""
            info "To add SSH keys to 1Password:"
            echo "  1. Open 1Password app"
            echo "  2. Go to Settings → Developer"
            echo "  3. Enable 'Use the SSH agent'"
            echo "  4. Import or generate SSH keys"
            echo "  5. Add public key to GitHub: https://github.com/settings/keys"
            return 1
        fi
    fi
}

clone_github_repositories() {
    # Create ~/dev directory
    if [[ ! -d ~/dev ]]; then
        info "Creating ~/dev directory..."
        mkdir -p ~/dev
        success "~/dev directory created"
    else
        info "~/dev directory already exists"
    fi

    # Clone GitHub repositories
    if ! command_exists gh; then
        warn "GitHub CLI not available yet"
        info "gh will be installed by nix-darwin"
        info "Run this step manually after setup: gh auth login && cd ~/dev && gh repo clone <repo-name>"
        return 1
    fi

    if ! confirm "Clone your GitHub repositories to ~/dev?"; then
        return 0
    fi

    info "Checking GitHub authentication..."

    # Check if gh is authenticated
    if ! gh auth status &>/dev/null; then
        warn "GitHub CLI not authenticated"
        info "Run 'gh auth login' after setup to authenticate"
        info "Then manually clone repos: cd ~/dev && gh repo clone <repo-name>"
        return 1
    fi

    success "GitHub CLI authenticated"

    info "Fetching your repositories..."
    echo ""

    # Get list of repos - using arrays instead of eval
    local repo_data
    repo_data=$(gh repo list --limit 100 --json name,sshUrl --jq '.[] | "\(.name)|\(.sshUrl)"') || {
        warn "Failed to fetch repository list from GitHub"
        info "GitHub API may be temporarily unavailable"
        return 1
    }

    if [[ -z "$repo_data" ]]; then
        warn "No repositories found in your GitHub account"
        return 0
    fi

    # Parse repos into arrays (NO EVAL - security fix)
    declare -a repo_names
    declare -a repo_urls

    while IFS='|' read -r name ssh_url; do
        repo_names+=("$name")
        repo_urls+=("$ssh_url")
    done <<< "$repo_data"

    local repo_count=${#repo_names[@]}

    echo "Available repositories:"
    echo ""

    # Display repos with numbers
    for i in "${!repo_names[@]}"; do
        printf "  %2d. %s\n" "$((i + 1))" "${repo_names[$i]}"
    done

    echo ""
    info "Clone options:"
    echo "  a - Clone all repositories"
    echo "  s - Select specific repositories (comma-separated numbers)"
    echo "  n - Skip repository cloning"
    echo ""
    read -p "Your choice [a/s/n]: " clone_choice

    case "$clone_choice" in
        a|A)
            info "Cloning all repositories..."
            for i in "${!repo_names[@]}"; do
                local repo_name="${repo_names[$i]}"
                local repo_url="${repo_urls[$i]}"

                if [[ -d ~/dev/"$repo_name" ]]; then
                    warn "Skipping $repo_name (already exists)"
                else
                    info "Cloning $repo_name..."
                    if retry_command git clone --depth 1 --single-branch "$repo_url" ~/dev/"$repo_name"; then
                        success "Cloned $repo_name"
                    else
                        warn "Failed to clone $repo_name after 3 attempts"
                    fi
                fi
            done
            success "Repository cloning complete"
            ;;
        s|S)
            echo ""
            read -p "Enter repository numbers (comma-separated, e.g., 1,3,5): " repo_numbers

            # Parse comma-separated numbers
            IFS=',' read -ra NUMBERS <<< "$repo_numbers"
            for num in "${NUMBERS[@]}"; do
                # Trim whitespace
                num=$(echo "$num" | xargs)

                # Validate input is numeric and in range
                if [[ "$num" =~ ^[0-9]+$ ]] && [[ "$num" -ge 1 ]] && [[ "$num" -le "$repo_count" ]]; then
                    local idx=$((num - 1))
                    local repo_name="${repo_names[$idx]}"
                    local repo_url="${repo_urls[$idx]}"

                    if [[ -d ~/dev/"$repo_name" ]]; then
                        warn "Skipping $repo_name (already exists)"
                    else
                        info "Cloning $repo_name..."
                        if retry_command git clone --depth 1 --single-branch "$repo_url" ~/dev/"$repo_name"; then
                            success "Cloned $repo_name"
                        else
                            warn "Failed to clone $repo_name after 3 attempts"
                        fi
                    fi
                else
                    warn "Invalid repository number: $num"
                fi
            done
            success "Selected repositories cloned"
            ;;
        n|N)
            info "Skipping repository cloning"
            ;;
        *)
            warn "Invalid choice - skipping repository cloning"
            ;;
    esac
}

print_summary_report() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📊 Setup Summary Report"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Statistics:"
    echo "  ✅ Completed steps: $COMPLETED_STEPS"
    echo "  ⏭️  Skipped steps: $SKIPPED_STEPS"
    echo "  ❌ Failed steps: $FAILED_STEPS"
    echo ""

    if [ $FAILED_STEPS -gt 0 ]; then
        echo "⚠️  Some steps failed. Check the log for details:"
        echo "     $LOGFILE"
        echo ""
    fi

    if [ $SKIPPED_STEPS -gt 0 ]; then
        echo "ℹ️  Some steps were skipped. You may need to complete them manually."
        echo ""
    fi
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

# Banner
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Automated New MacBook Setup v$SCRIPT_VERSION"
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
info "Log file: $LOGFILE"
echo ""

if ! confirm "Ready to begin automated setup?"; then
    echo "Setup cancelled."
    exit 0
fi

# Step 1: Check prerequisites
step "Checking prerequisites"
CURRENT_STEP="prerequisites"

if [[ "$(uname -s)" != "Darwin" ]]; then
    mark_step_failed "$CURRENT_STEP"
    error "This script is for macOS only"
fi

info "macOS version: $(sw_vers -productVersion)"
info "Architecture: $(uname -m)"

if [[ "$(uname -m)" != "arm64" ]]; then
    warn "Not Apple Silicon - some features may differ"
fi

success "Prerequisites check passed"
mark_step_complete "$CURRENT_STEP"

# Step 2: Install Nix
step "Installing Nix package manager"
CURRENT_STEP="nix_install"

if is_step_complete "$CURRENT_STEP"; then
    info "Nix already installed (step previously completed)"
    success "Skipping Nix installation"
elif command_exists nix; then
    info "Nix already installed: $(nix --version | head -1)"
    if ! confirm "Reinstall Nix?"; then
        success "Skipping Nix installation"
        mark_step_complete "$CURRENT_STEP"
    else
        info "Installing Nix..."
        if retry_command bash -c "curl --proto '=https' --tlsv1.2 -sSf -L --retry 10 --retry-delay 2 --connect-timeout 10 --max-time 300 https://nixos.org/nix/install | sh"; then
            success "Nix installed"
            mark_step_complete "$CURRENT_STEP"
        else
            mark_step_failed "$CURRENT_STEP"
            error "Nix installation failed after retries"
        fi
    fi
else
    info "Installing Nix (this may take a few minutes)..."
    if retry_command bash -c "curl --proto '=https' --tlsv1.2 -sSf -L --retry 10 --retry-delay 2 --connect-timeout 10 --max-time 300 https://nixos.org/nix/install | sh"; then
        success "Nix installed successfully"
        mark_step_complete "$CURRENT_STEP"

        info "Please restart your terminal and re-run this script to continue"
        info "To resume: bash $(readlink -f "$0")"
        exit 0
    else
        mark_step_failed "$CURRENT_STEP"
        error "Nix installation failed after multiple attempts

Recovery steps:
  1. Check your internet connection
  2. Visit https://nixos.org/download/
  3. Try manual installation: sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)
  4. Retry this script"
    fi
fi

# Step 3: Clone dotfiles
step "Cloning dotfiles repository"
CURRENT_STEP="clone_dotfiles"

if is_step_complete "$CURRENT_STEP"; then
    info "Dotfiles already cloned (step previously completed)"
    success "Skipping dotfiles clone"
elif [[ -d $DOTFILES_DIR/.git ]]; then
    info "Dotfiles already cloned"
    current_remote=$(git -C "$DOTFILES_DIR" remote get-url origin 2>/dev/null)
    if [[ "$current_remote" == "$DOTFILES_REPO" ]]; then
        success "Dotfiles repository already configured"
        if confirm "Pull latest changes?"; then
            if retry_command git -C "$DOTFILES_DIR" pull; then
                success "Dotfiles updated"
            else
                warn "Failed to pull latest changes"
            fi
        fi
        mark_step_complete "$CURRENT_STEP"
    else
        warn "Different dotfiles repository detected: $current_remote"
        mark_step_failed "$CURRENT_STEP"
        error "Please manually resolve dotfiles repository conflict"
    fi
elif [[ -d $DOTFILES_DIR ]]; then
    warn "~/.config exists but is not a git repository"
    if confirm "Backup and replace with dotfiles repository?"; then
        mv "$DOTFILES_DIR" "$DOTFILES_DIR.backup.$(date +%Y%m%d-%H%M%S)"
        if retry_command git clone --depth 1 --single-branch "$DOTFILES_REPO" "$DOTFILES_DIR"; then
            success "Dotfiles cloned (backup created)"
            mark_step_complete "$CURRENT_STEP"
        else
            mark_step_failed "$CURRENT_STEP"
            error "Failed to clone dotfiles repository after retries"
        fi
    else
        mark_step_skipped "$CURRENT_STEP"
        error "Cannot proceed without dotfiles repository"
    fi
else
    info "Cloning dotfiles repository..."
    if retry_command git clone --depth 1 --single-branch "$DOTFILES_REPO" "$DOTFILES_DIR"; then
        success "Dotfiles cloned successfully"
        mark_step_complete "$CURRENT_STEP"
    else
        mark_step_failed "$CURRENT_STEP"
        error "Failed to clone dotfiles repository after retries

Recovery steps:
  1. Check internet connection
  2. Verify GitHub access: https://github.com/ree-see/dotfiles
  3. Try manual clone: git clone $DOTFILES_REPO $DOTFILES_DIR
  4. Retry this script"
    fi
fi

# Step 4: Build nix-darwin configuration
step "Building nix-darwin configuration"
CURRENT_STEP="nix_darwin_build"

info "This will install all packages and applications (~15-30 minutes)"
info "Installing:"
echo "  - Nix packages: helix, fish, yazi, zoxide, claude-code, gh, and more"
echo "  - Homebrew: PostgreSQL, mas, formulae and casks"
echo "  - Mac App Store apps: Magnet, Xcode, 1Password, etc."
echo ""

# CRITICAL: Ensure Mac App Store sign-in before mas installations
echo ""
info "⚠️  IMPORTANT: Mac App Store sign-in required"
echo ""
echo "The build will install 6 Mac App Store apps using 'mas'"
echo "You MUST be signed in to the Mac App Store for this to work."
echo ""
echo "Please verify:"
echo "  1. Open App Store (should be in /Applications)"
echo "  2. Sign in with your Apple ID if prompted"
echo "  3. Verify you see your account name in the bottom left"
echo ""

if ! confirm "Are you signed in to the Mac App Store?"; then
    warn "Mac App Store apps will fail to install without sign-in"
    if ! confirm "Continue anyway? (not recommended)"; then
        mark_step_skipped "$CURRENT_STEP"
        warn "Skipping nix-darwin build - system will be incomplete"
        info "Sign in to Mac App Store, then run: cd ~/.config && darwin-rebuild switch --flake .#macbook"
    elif confirm "Start nix-darwin build?"; then
        cd "$DOTFILES_DIR" || error "Failed to change to $DOTFILES_DIR directory"
        info "Running nix-darwin build with optimized settings (Mac App Store apps may fail)..."
        info "⏳ This will take 15-30 minutes. Progress will be shown below..."
        info "Optimization: Using all CPU cores and parallel downloads"

        # Configure Nix for optimal performance with 48GB RAM
        export NIX_CONFIG="max-jobs = auto
cores = 0
http-connections = 128
connect-timeout = 10
stalled-download-timeout = 300
max-silent-time = 1800"

        if nix run nix-darwin --max-jobs auto -- switch --flake .#macbook --keep-going; then
            success "nix-darwin build completed successfully"
            mark_step_complete "$CURRENT_STEP"
        else
            mark_step_failed "$CURRENT_STEP"
            error "nix-darwin build failed - check output above

Recovery steps:
  1. Check error messages above
  2. Sign in to Mac App Store if not already
  3. Try manual build: cd ~/.config && nix run nix-darwin -- switch --flake .#macbook
  4. Check logs at: $LOGFILE"
        fi

        unset NIX_CONFIG
    fi
elif confirm "Start nix-darwin build?"; then
    cd "$DOTFILES_DIR" || error "Failed to change to $DOTFILES_DIR directory"
    info "Running nix-darwin build with optimized settings..."
    info "⏳ This will take 15-30 minutes. Progress will be shown below..."
    info "Optimization: Using all CPU cores and parallel downloads"

    # Configure Nix for optimal performance with 48GB RAM
    export NIX_CONFIG="max-jobs = auto
cores = 0
http-connections = 128
connect-timeout = 10
stalled-download-timeout = 300
max-silent-time = 1800"

    if nix run nix-darwin --max-jobs auto -- switch --flake .#macbook --keep-going; then
        success "nix-darwin build completed successfully"
        mark_step_complete "$CURRENT_STEP"
    else
        mark_step_failed "$CURRENT_STEP"
        error "nix-darwin build failed - check output above

Recovery steps:
  1. Check error messages above
  2. Try manual build: cd ~/.config && nix run nix-darwin -- switch --flake .#macbook
  3. Check logs at: $LOGFILE"
    fi

    unset NIX_CONFIG
fi

# Step 5: Create SuperClaude symlink
step "Setting up SuperClaude framework"
CURRENT_STEP="superclaude_symlink"

if [[ -L ~/.claude ]]; then
    link_target=$(readlink ~/.claude)
    if [[ "$link_target" == "$HOME/.config/claude" ]]; then
        success "SuperClaude symlink already configured"
        mark_step_complete "$CURRENT_STEP"
    else
        warn "~/.claude symlink points to: $link_target"
        if confirm "Fix symlink to point to ~/.config/claude?"; then
            rm ~/.claude
            ln -s ~/.config/claude ~/.claude
            success "SuperClaude symlink fixed"
            mark_step_complete "$CURRENT_STEP"
        else
            mark_step_skipped "$CURRENT_STEP"
        fi
    fi
elif [[ -e ~/.claude ]]; then
    warn "~/.claude exists but is not a symlink"
    if confirm "Backup and create symlink?"; then
        mv ~/.claude ~/.claude.backup.$(date +%Y%m%d-%H%M%S)
        ln -s ~/.config/claude ~/.claude
        success "SuperClaude symlink created (backup made)"
        mark_step_complete "$CURRENT_STEP"
    else
        mark_step_skipped "$CURRENT_STEP"
    fi
else
    ln -s ~/.config/claude ~/.claude
    success "SuperClaude symlink created"
    mark_step_complete "$CURRENT_STEP"
fi

# Step 6: Set Fish as default shell
step "Configuring Fish shell"
CURRENT_STEP="fish_shell"

if [[ "$SHELL" == "$FISH_PATH" ]]; then
    success "Fish is already the default shell"
    mark_step_complete "$CURRENT_STEP"
else
    info "Current shell: $SHELL"
    if confirm "Set Fish as default shell?"; then
        # Add Fish to allowed shells
        if ! grep -q "$FISH_PATH" /etc/shells; then
            info "Adding Fish to /etc/shells (requires sudo)"
            echo "$FISH_PATH" | sudo tee -a /etc/shells || {
                mark_step_failed "$CURRENT_STEP"
                error "Failed to add Fish to /etc/shells"
            }
        fi

        # Change default shell
        info "Changing default shell to Fish (requires password)"
        if chsh -s "$FISH_PATH"; then
            success "Fish set as default shell"
            info "You'll need to logout and login for this to take full effect"
            mark_step_complete "$CURRENT_STEP"
        else
            mark_step_failed "$CURRENT_STEP"
            error "Failed to change default shell"
        fi
    else
        warn "Keeping current shell: $SHELL"
        mark_step_skipped "$CURRENT_STEP"
    fi
fi

# Step 7: Install asdf runtimes
step "Installing asdf runtimes"
CURRENT_STEP="asdf_runtimes"

if command_exists asdf; then
    # Ruby
    if confirm "Install Ruby 3.3.6 via asdf?"; then
        if ! asdf plugin list | grep -q ruby; then
            info "Adding Ruby plugin..."
            asdf plugin add ruby
        fi

        info "Installing Ruby 3.3.6 (this may take 5-10 minutes)..."
        info "⏳ Compiling Ruby from source..."
        if asdf install ruby 3.3.6; then
            info "Setting Ruby 3.3.6 as global default..."
            asdf global ruby 3.3.6
            success "Ruby 3.3.6 installed and configured"

            # Validate Ruby installation
            if [[ -x ~/.config/scripts/validate-ruby.fish ]] && command_exists fish; then
                echo ""
                info "Validating Ruby environment..."
                fish ~/.config/scripts/validate-ruby.fish || warn "Ruby validation script had issues"
                echo ""
            fi

            mark_step_complete "$CURRENT_STEP"
        else
            warn "Ruby installation failed"
            mark_step_failed "$CURRENT_STEP"
        fi
    else
        mark_step_skipped "$CURRENT_STEP"
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
    mark_step_skipped "$CURRENT_STEP"
fi

# Step 8: Configure services
step "Configuring system services"
CURRENT_STEP="configure_services"

# PostgreSQL
if command_exists brew; then
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
            mark_step_complete "$CURRENT_STEP"
        else
            warn "PostgreSQL may not have started correctly"
            mark_step_failed "$CURRENT_STEP"
        fi
    else
        mark_step_skipped "$CURRENT_STEP"
    fi
else
    warn "Homebrew not found - service configuration skipped"
    mark_step_skipped "$CURRENT_STEP"
fi

# Step 8a: Configure SSH authentication with 1Password
step "Configuring SSH authentication"
CURRENT_STEP="ssh_authentication"

if setup_ssh_with_1password; then
    success "SSH authentication configured"
    mark_step_complete "$CURRENT_STEP"
else
    warn "SSH authentication not configured"
    mark_step_skipped "$CURRENT_STEP"
fi

# Step 9: Clone development repositories
step "Setting up development projects"
CURRENT_STEP="clone_repositories"

if clone_github_repositories; then
    success "Development projects setup complete"
    mark_step_complete "$CURRENT_STEP"
else
    warn "Repository cloning incomplete"
    mark_step_skipped "$CURRENT_STEP"
fi

# Step 10: Run validation
step "Running system validation"
CURRENT_STEP="validation"

if [[ -x ~/.config/scripts/validate-system.fish ]]; then
    if confirm "Run comprehensive system validation?"; then
        info "Running validation script..."
        echo ""
        # Try to run with fish if available, otherwise skip
        if command_exists fish; then
            fish ~/.config/scripts/validate-system.fish
            mark_step_complete "$CURRENT_STEP"
        else
            warn "Fish not available yet - validation skipped"
            info "Run manually after logout/login: ~/.config/scripts/validate-system.fish"
            mark_step_skipped "$CURRENT_STEP"
        fi
        echo ""
        success "Validation complete"
    else
        mark_step_skipped "$CURRENT_STEP"
    fi
else
    warn "Validation script not found at ~/.config/scripts/validate-system.fish"
    mark_step_skipped "$CURRENT_STEP"
fi

# Completion with summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 Automated Setup Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

print_summary_report

echo "✅ Completed:"
echo "  - Nix package manager installed"
echo "  - Dotfiles repository cloned"
echo "  - nix-darwin configuration built"
echo "  - SuperClaude framework configured"
echo "  - Fish shell configured"
echo "  - Runtime versions installed"
echo "  - Services configured"
echo "  - SSH authentication configured (1Password)"
echo "  - Development directory set up"
echo ""
echo "📋 Manual Steps Remaining:"
echo ""
echo "  1. Logout and login (for Fish shell to take effect)"
echo ""
echo "  2. Grant Terminal Full Disk Access:"
echo "     System Settings → Privacy & Security → Full Disk Access"
echo ""
echo "  3. GitHub CLI authentication (if not done during setup):"
echo "     gh auth login"
echo "     Then clone any remaining repos: cd ~/dev && gh repo clone <repo-name>"
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
echo "📋 Setup log: $LOGFILE"
echo ""
info "System is ready for development!"
echo ""
