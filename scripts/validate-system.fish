#!/usr/bin/env fish
# Comprehensive nix-darwin reproducibility validation script
# Tests that new laptop matches expected configuration

set -g PASS_COUNT 0
set -g FAIL_COUNT 0
set -g WARN_COUNT 0

function test_pass
    set -g PASS_COUNT (math $PASS_COUNT + 1)
    echo "✅ PASS: $argv"
end

function test_fail
    set -g FAIL_COUNT (math $FAIL_COUNT + 1)
    echo "❌ FAIL: $argv"
end

function test_warn
    set -g WARN_COUNT (math $WARN_COUNT + 1)
    echo "⚠️  WARN: $argv"
end

echo "================================"
echo "System Reproducibility Validation"
echo "================================"
echo ""

# Test 1: Nix packages
echo "📦 Testing Nix Packages..."
# Map package names to their actual executables
set -l nix_checks \
    "hx:helix" \
    "fish:fish" \
    "yazi:yazi" \
    "zoxide:zoxide" \
    "claude:claude-code" \
    "gh:gh" \
    "mkalias:mkalias" \
    "op:1password-cli" \
    "pre-commit:pre-commit" \
    "asdf:asdf" \
    "node:nodejs" \
    "pnpm:pnpm" \
    "go:go" \
    "golangci-lint:golangci-lint" \
    "lua:lua" \
    "nil:nil" \
    "uv:uv" \
    "watchman:watchman"

for check in $nix_checks
    set cmd (string split ":" $check)[1]
    set pkg (string split ":" $check)[2]
    if command -v $cmd >/dev/null 2>&1
        test_pass "Nix package: $pkg ($cmd)"
    else
        test_fail "Nix package missing: $pkg (command: $cmd)"
    end
end

# Test 2: Homebrew formulae
echo ""
echo "🍺 Testing Homebrew Formulae..."
set brew_formulae mas postgresql@16 ifstat
for formula in $brew_formulae
    if brew list --formula | grep -q "^$formula\$"
        test_pass "Homebrew formula: $formula"
    else
        test_fail "Homebrew formula missing: $formula"
    end
end

# Test 3: Homebrew casks
echo ""
echo "📱 Testing Homebrew Casks..."
set casks 1password claude google-chrome raycast spotify warp wezterm
for cask in $casks
    if brew list --cask | grep -q "^$cask\$"
        test_pass "Homebrew cask: $cask"
    else
        test_fail "Homebrew cask missing: $cask"
    end
end

# Test 4: Mac App Store apps
echo ""
echo "🍎 Testing Mac App Store Apps..."
set -l mas_apps \
    "1569813296:1Password for Safari" \
    "1037126344:Apple Configurator" \
    "441258766:Magnet" \
    "1188020834:OverPicture" \
    "1662217862:Wipr" \
    "497799835:Xcode"

for app in $mas_apps
    set app_id (string split ":" $app)[1]
    set app_name (string split ":" $app)[2]
    if mas list | grep -q "^$app_id"
        test_pass "Mac App Store: $app_name"
    else
        test_warn "Mac App Store app missing: $app_name (run: mas install $app_id)"
    end
end

# Test 5: asdf runtimes
echo ""
echo "⚙️  Testing asdf Runtimes..."
if asdf plugin list | grep -q ruby
    test_pass "asdf plugin: ruby"
    if asdf current ruby | grep -q "3.3.6"
        test_pass "Ruby version: 3.3.6"
    else
        test_warn "Ruby 3.3.6 not set (run: asdf install ruby 3.3.6 && asdf global ruby 3.3.6)"
    end
else
    test_warn "asdf ruby plugin not installed (run: asdf plugin add ruby)"
end

# Test 6: Custom Fish commands
echo ""
echo "🐟 Testing Custom Fish Commands..."
set fish_commands rebuild rollback nixstatus config mkcd newproject
for cmd in $fish_commands
    if type -q $cmd
        test_pass "Fish command: $cmd"
    else
        test_fail "Fish command missing: $cmd"
    end
end

# Test 7: Configuration files
echo ""
echo "📝 Testing Configuration Files..."
set config_files \
    "$HOME/.config/nix/flake.nix" \
    "$HOME/.config/fish/config.fish" \
    "$HOME/.config/helix/config.toml" \
    "$HOME/.config/wezterm/wezterm.lua" \
    "$HOME/.config/claude/RULES.md" \
    "$HOME/.config/claude/FLAGS.md"

for file in $config_files
    if test -f $file
        test_pass "Config file exists: "(basename $file)
    else
        test_fail "Config file missing: $file"
    end
end

# Test 8: SuperClaude framework symlink
echo ""
echo "🔗 Testing SuperClaude Framework..."
if test -L $HOME/.claude
    if test (readlink $HOME/.claude) = "$HOME/.config/claude"
        test_pass "SuperClaude symlink: ~/.claude -> ~/.config/claude"
    else
        test_fail "SuperClaude symlink points to wrong location"
    end
else if test -d $HOME/.claude
    test_warn "~/.claude is a directory, not a symlink (expected symlink to ~/.config/claude)"
else
    test_fail "~/.claude does not exist"
end

# Test 9: System defaults (sample check)
echo ""
echo "⚙️  Testing System Defaults..."
if defaults read com.apple.dock autohide 2>/dev/null | grep -q "1"
    test_pass "Dock autohide enabled"
else
    test_warn "Dock autohide not enabled (may need logout/login)"
end

if defaults read NSGlobalDomain AppleShowAllExtensions 2>/dev/null | grep -q "1"
    test_pass "Finder shows all extensions"
else
    test_warn "Finder show all extensions not enabled (may need logout/login)"
end

# Test 10: PostgreSQL service
echo ""
echo "🐘 Testing PostgreSQL Service..."
if brew services list | grep postgresql@16 | grep -q started
    test_pass "PostgreSQL service running"
else
    test_warn "PostgreSQL not running (run: brew services start postgresql@16)"
end

# Test 11: Font installation
echo ""
echo "🔤 Testing Fonts..."
if test -d "$HOME/Library/Fonts/JetBrainsMonoNerdFont-Regular.ttf" -o -f "$HOME/Library/Fonts/JetBrainsMonoNerdFont-Regular.ttf"
    test_pass "JetBrains Mono Nerd Font installed"
else
    if fc-list | grep -i "jetbrains.*mono.*nerd" >/dev/null 2>&1
        test_pass "JetBrains Mono Nerd Font installed (system)"
    else
        test_warn "JetBrains Mono Nerd Font may not be installed"
    end
end

# Test 12: Git configuration
echo ""
echo "🔧 Testing Git Configuration..."
if test -d $HOME/.config/.git
    test_pass "Dotfiles git repository exists"
    set remote (git -C $HOME/.config remote get-url origin 2>/dev/null)
    if test "$remote" = "https://github.com/ree-see/dotfiles.git"
        test_pass "Dotfiles remote URL correct"
    else
        test_warn "Dotfiles remote URL: $remote"
    end
else
    test_fail "Dotfiles not a git repository"
end

# Test 13: Shell configuration
echo ""
echo "🐚 Testing Shell Configuration..."
if test "$SHELL" = "/run/current-system/sw/bin/fish"
    test_pass "Fish is default shell"
else
    test_warn "Default shell is $SHELL (expected Fish)"
end

# Test 14: PATH configuration
echo ""
echo "🛤️  Testing PATH Configuration..."
# Check if nix packages are accessible (better than checking PATH directly)
if command -v hx >/dev/null 2>&1
    test_pass "Nix packages accessible in PATH"
else
    test_fail "Nix packages not in PATH"
end

if string match -q "*/.asdf/shims*" $PATH
    test_pass "asdf shims in PATH"
else if command -v asdf >/dev/null 2>&1
    test_pass "asdf accessible (shims may be in PATH)"
else
    test_warn "asdf shims not in PATH"
end

# Summary
echo ""
echo "================================"
echo "Validation Summary"
echo "================================"
echo "✅ Passed:  $PASS_COUNT"
echo "⚠️  Warnings: $WARN_COUNT"
echo "❌ Failed:  $FAIL_COUNT"
echo ""

if test $FAIL_COUNT -eq 0
    if test $WARN_COUNT -eq 0
        echo "🎉 Perfect! System is fully reproduced."
        exit 0
    else
        echo "✅ System is mostly reproduced. Review warnings above."
        exit 0
    end
else
    echo "❌ System reproduction incomplete. Fix failures above."
    exit 1
end
