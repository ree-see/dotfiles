# New Mac Setup

## Automated (recommended)

```bash
git clone https://github.com/ree-see/dotfiles.git ~/.config
bash ~/.config/scripts/bootstrap-new-mac.sh
```

That's it for the automated part. Then do the manual steps below.

---

## What the bootstrap script does

1. Installs Xcode CLI tools
2. Installs zerobrew
3. Runs `zb bundle` from `~/.config/Brewfile` (all CLI tools)
4. Sets Fish as default shell
5. Runs `mise install` for runtimes
6. Installs claude-code via npm
7. Applies macOS defaults (dock, finder, keyboard, etc.)

---

## Manual steps after bootstrap

### 1Password
- Install from https://1password.com
- Sign in to your account
- Settings → Developer → enable "Use the SSH agent"

### SSH
```bash
mkdir -p ~/.ssh && chmod 700 ~/.ssh
```
Add to `~/.ssh/config`:
```
Host *
    IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
```
Generate SSH key in 1Password → Settings → Developer → Create New SSH Key, then add the public key to GitHub at https://github.com/settings/keys.

Test: `ssh -T git@github.com`

### GitHub CLI
```bash
gh auth login
```

### GUI apps (install manually)
- WezTerm → https://wezfurlong.org/wezterm
- Warp → https://warp.dev
- Chrome → https://google.com/chrome
- Spotify → https://spotify.com

### Terminal permissions
System Settings → Privacy & Security → Full Disk Access → add Warp/WezTerm

### Runtimes
```bash
mise use ruby@3.3.6    # or whatever version you need
mise use node@lts
```

### PostgreSQL
```bash
brew services start postgresql@16
createdb $(whoami)
```

---

## Verify everything works

```fish
hx --version        # Helix
fish --version      # Fish
mise current        # Runtime versions
ruby --version      # Ruby via mise
pnpm --version      # pnpm
psql --version      # PostgreSQL
gh auth status      # GitHub
ssh -T git@github.com  # SSH via 1Password
```

---

## Day-to-day maintenance

**Add a package:**
```bash
zb install <package>
zb export -f ~/.config/Brewfile   # update Brewfile
```

**New project:**
```fish
newproject my-app --type node --tdd
```

**Update packages:**
```bash
zb upgrade
```

**macOS defaults reset (new machine or after OS update):**
```bash
bash ~/.config/scripts/macos-defaults.sh
```

---

## What's not tracked in git

- `~/.ssh/` — managed by 1Password
- `~/.tool-versions` — per-project, lives in each repo
- Browser settings and extensions
- App preferences (Warp, Spotify, etc.)
