#!/bin/bash
# Quick one-liner installer for new Mac
# Usage: curl -fsSL https://raw.githubusercontent.com/ree-see/dotfiles/main/scripts/quick-install.sh | bash

set -e

echo "🚀 Starting quick Mac setup..."
echo ""

# Install Nix if not present
if ! command -v nix &> /dev/null; then
    echo "📦 Installing Nix package manager..."
    sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)
    echo "✅ Nix installed"
    echo ""
    echo "⚠️  Please restart your terminal and run this command again:"
    echo ""
    echo "  curl -fsSL https://raw.githubusercontent.com/ree-see/dotfiles/main/scripts/quick-install.sh | bash"
    echo ""
    exit 0
fi

# Clone dotfiles if not present
if [ ! -d "$HOME/.config/.git" ]; then
    echo "📥 Cloning dotfiles repository..."
    git clone https://github.com/ree-see/dotfiles.git "$HOME/.config"
    echo "✅ Dotfiles cloned"
else
    echo "✅ Dotfiles already present"
fi

# Run the full bootstrap script
if [ -x "$HOME/.config/scripts/bootstrap-new-mac-improved.sh" ]; then
    echo "🎯 Launching automated setup script v2.0..."
    echo ""
    bash "$HOME/.config/scripts/bootstrap-new-mac-improved.sh"
else
    echo "❌ Bootstrap script not found"
    echo "Please run manually:"
    echo "  cd ~/.config"
    echo "  ./scripts/bootstrap-new-mac-improved.sh"
    exit 1
fi
