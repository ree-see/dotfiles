#!/usr/bin/env bash
# macOS system defaults
# Run once on a new machine: bash ~/.config/scripts/macos-defaults.sh

set -euo pipefail

echo "Applying macOS defaults..."

# ── Dock ──────────────────────────────────────────────────────────────────────
defaults write com.apple.dock autohide              -bool true
defaults write com.apple.dock autohide-delay        -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.2
defaults write com.apple.dock orientation           -string "bottom"
defaults write com.apple.dock show-recents          -bool false
defaults write com.apple.dock tilesize              -int 48
defaults write com.apple.dock minimize-to-application -bool true
defaults write com.apple.dock mru-spaces            -bool false

# ── Finder ────────────────────────────────────────────────────────────────────
defaults write NSGlobalDomain  AppleShowAllExtensions        -bool true
defaults write com.apple.finder AppleShowAllFiles            -bool false
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder FXPreferredViewStyle         -string "Nlsv"
defaults write com.apple.finder ShowPathbar                  -bool true
defaults write com.apple.finder ShowStatusBar                -bool true
defaults write com.apple.finder _FXShowPosixPathInTitle      -bool true

# ── Trackpad ──────────────────────────────────────────────────────────────────
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking         -bool true
defaults write com.apple.AppleMultitouchTrackpad                   Clicking         -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool false

# ── Keyboard ──────────────────────────────────────────────────────────────────
defaults write NSGlobalDomain AppleKeyboardUIMode                    -int 3
defaults write NSGlobalDomain ApplePressAndHoldEnabled               -bool false
defaults write NSGlobalDomain InitialKeyRepeat                       -int 15
defaults write NSGlobalDomain KeyRepeat                              -int 2
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled       -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled     -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled   -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled    -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled   -bool false
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode     -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2    -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint        -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2       -bool true

# ── Screenshots ───────────────────────────────────────────────────────────────
defaults write com.apple.screencapture location -string "$HOME/Desktop"
defaults write com.apple.screencapture type     -string "png"

# ── Menu Bar Clock ────────────────────────────────────────────────────────────
defaults write com.apple.menuextra.clock Show24Hour -bool true
defaults write com.apple.menuextra.clock ShowDate   -int 1

# ── Activity Monitor ──────────────────────────────────────────────────────────
defaults write com.apple.ActivityMonitor IconType        -int 5
defaults write com.apple.ActivityMonitor OpenMainWindow  -bool true
defaults write com.apple.ActivityMonitor ShowCategory    -int 100

# ── Screensaver ───────────────────────────────────────────────────────────────
defaults write com.apple.screensaver askForPassword      -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# ── Apply ─────────────────────────────────────────────────────────────────────
killall Dock
killall Finder
killall SystemUIServer 2>/dev/null || true

echo "Done. Some changes may require a logout/restart to fully apply."
