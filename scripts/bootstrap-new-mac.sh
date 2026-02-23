#!/usr/bin/env bash
# New Mac bootstrap
# Usage: bash ~/.config/scripts/bootstrap-new-mac.sh

set -euo pipefail

echo "==> Bootstrapping new Mac..."

# ── 1. Xcode CLI tools ────────────────────────────────────────────────────────
if ! xcode-select -p &>/dev/null; then
  echo "==> Installing Xcode CLI tools..."
  xcode-select --install
  read -rp "Press enter once the install completes..."
fi

# ── 2. Zerobrew ───────────────────────────────────────────────────────────────
if ! command -v zb &>/dev/null; then
  echo "==> Installing zerobrew..."
  curl -fsSL https://raw.githubusercontent.com/lucasgelfond/zerobrew/main/install.sh | bash
fi

# ── 3. Install packages from Brewfile ─────────────────────────────────────────
echo "==> Installing packages..."
zb bundle -f "$HOME/.config/Brewfile"

# ── 4. Set Fish as default shell ──────────────────────────────────────────────
FISH_PATH="$(which fish)"
if [[ "$SHELL" != "$FISH_PATH" ]]; then
  echo "==> Setting Fish as default shell..."
  echo "$FISH_PATH" | sudo tee -a /etc/shells
  chsh -s "$FISH_PATH"
fi

# ── 5. mise — activate runtimes ───────────────────────────────────────────────
echo "==> Activating mise..."
mise install 2>/dev/null || echo "No .tool-versions found, skipping runtime installs."

# ── 6. claude-code ────────────────────────────────────────────────────────────
if ! command -v claude &>/dev/null; then
  echo "==> Installing claude-code..."
  npm install -g @anthropic-ai/claude-code
fi

# ── 7. macOS defaults ─────────────────────────────────────────────────────────
echo "==> Applying macOS defaults..."
bash "$HOME/.config/scripts/macos-defaults.sh"

# ── 8. Casks (requires Homebrew as fallback) ──────────────────────────────────
if command -v brew &>/dev/null; then
  echo "==> Installing casks via Homebrew..."
  brew install --cask 1password google-chrome mactex opencode-desktop spotify warp wezterm
else
  echo "==> Install these manually (zerobrew doesn't support casks yet):"
  echo "    1Password       → https://1password.com"
  echo "    Google Chrome   → https://google.com/chrome"
  echo "    MacTeX          → https://tug.org/mactex"
  echo "    OpenCode        → https://opencode.ai"
  echo "    Spotify         → https://spotify.com"
  echo "    Warp            → https://warp.dev"
  echo "    WezTerm         → https://wezfurlong.org/wezterm"
fi

# ── 9. Non-package-manager installs ───────────────────────────────────────────
echo "==> Installing bun..."
curl -fsSL https://bun.sh/install | bash

echo "==> Installing Solana CLI..."
sh -c "$(curl -sSfL https://release.anza.xyz/stable/install)"

echo ""
echo "Done. Restart your terminal."
