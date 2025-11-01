# Nix-Darwin Declarative Configuration Conversion Guide

## Purpose
Convert symlink-based dotfile management to pure nix-darwin declarative configuration for better reproducibility and system management.

## Current State (Symlink-Based)

### Files Currently Managed via Symlinks
```
~/.gitconfig → ~/.config/git/config
~/.ssh/config → ~/.config/ssh/config
~/.tool-versions → ~/.config/asdf/.tool-versions
~/.zshenv → ~/.config/zsh/.zshenv
~/.zprofile → ~/.config/zsh/.zprofile
```

### Why Convert to Nix-Darwin?

**Benefits**:
- Pure declarative configuration (no manual file operations)
- Atomic updates and rollbacks (entire system state versioned)
- Automatic generation from single source of truth
- Better integration with nix-darwin rebuild process
- Eliminates need for symlink management
- Clear separation of config definition vs generated files

**Trade-offs**:
- Learning curve for nix configuration syntax
- Generated files in nix store (not directly editable)
- Configuration must be rebuilt to apply changes

## Conversion Roadmap

### Phase 1: Git Configuration

**Current**: Symlink from `~/.gitconfig` to `~/.config/git/config`

**Nix-Darwin Configuration**:
```nix
# Add to flake.nix in the configuration section
programs.git = {
  enable = true;
  userName = "Jackson Risse";
  userEmail = "j.risse14@proton.me";

  extraConfig = {
    core = {
      editor = "hx";
    };
  };
};
```

**Migration Steps**:
1. Add `programs.git` configuration to `flake.nix`
2. Run `rebuild` to test
3. Verify with `git config --global --list`
4. Remove symlink: `rm ~/.gitconfig`
5. Remove tracked file: `git rm ~/.config/git/config`
6. Commit changes

**Verification**:
```bash
git config --global user.name  # Should show "Jackson Risse"
git config --global user.email # Should show "j.risse14@proton.me"
git config --global core.editor # Should show "hx"
```

### Phase 2: SSH Configuration

**Current**: Symlink from `~/.ssh/config` to `~/.config/ssh/config`

**Nix-Darwin Configuration**:
```nix
# Add to flake.nix in the configuration section
programs.ssh = {
  enable = true;

  extraConfig = ''
    Host *
      IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
  '';

  # Optional: Add specific host configurations
  matchBlocks = {
    "github.com" = {
      hostname = "github.com";
      user = "git";
      identitiesOnly = true;
    };
  };
};
```

**Migration Steps**:
1. Add `programs.ssh` configuration to `flake.nix`
2. Run `rebuild` to test
3. Verify with `ssh -G github.com | grep -i identityagent`
4. Test actual SSH connection: `ssh -T git@github.com`
5. Remove symlink: `rm ~/.ssh/config`
6. Remove tracked file: `git rm ~/.config/ssh/config`
7. Commit changes

**Verification**:
```bash
ssh -G github.com | grep -i identityagent
# Should show: identityagent ~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock

ssh -T git@github.com
# Should authenticate via 1Password and show: Hi <username>! You've successfully authenticated
```

### Phase 3: ASDF Tool Versions

**Current**: Symlink from `~/.tool-versions` to `~/.config/asdf/.tool-versions`

**Option A: Continue Using ASDF (Keep symlink)**
- ASDF is already installed via nix
- Per-project `.tool-versions` files still useful
- Keep the symlink for global defaults

**Option B: Manage via Nix Directly (Recommended)**
```nix
# Replace asdf with direct nix package management
environment.systemPackages = [
  # Instead of asdf-managed Ruby
  pkgs.ruby_3_3

  # Instead of asdf-managed Node (already have nodejs)
  pkgs.nodejs_22  # or specific version

  # Other runtimes as needed
  pkgs.python312
];
```

**Recommendation**:
- Use **Option B** for better integration and reproducibility
- Remove asdf dependency entirely once comfortable with nix
- Project-specific versions can use `shell.nix` or `flake.nix`

**Migration Steps (Option B)**:
1. Add specific runtime versions to `environment.systemPackages`
2. Run `rebuild` to install
3. Update PATH priorities (nix should come before asdf)
4. Test: `which ruby` should point to nix store
5. Remove asdf from systemPackages
6. Remove symlink: `rm ~/.tool-versions`
7. Remove tracked file: `git rm ~/.config/asdf/.tool-versions`
8. Commit changes

### Phase 4: Zsh Configuration

**Current**: Symlinks for `~/.zshenv` and `~/.zprofile`

**Nix-Darwin Configuration**:
```nix
# Add to flake.nix in the configuration section
programs.zsh = {
  enable = true;

  # Equivalent to ~/.zshenv
  envExtra = ''
    . "$HOME/.cargo/env"
  '';

  # Equivalent to ~/.zprofile
  profileExtra = ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
  '';

  # Additional zsh configuration
  enableCompletion = true;
  enableSyntaxHighlighting = true;

  # Optional: manage .zshrc here too
  initExtra = ''
    # Custom zsh initialization
  '';
};
```

**Migration Steps**:
1. Add `programs.zsh` configuration to `flake.nix`
2. Run `rebuild` to test
3. Open new terminal and verify environment
4. Check `echo $PATH` includes expected paths
5. Verify cargo and brew are available
6. Remove symlinks: `rm ~/.zshenv ~/.zprofile`
7. Remove tracked files: `git rm ~/.config/zsh/.zshenv ~/.config/zsh/.zprofile`
8. Commit changes

**Verification**:
```bash
# Start new zsh shell
zsh

# Verify cargo
which cargo  # Should be available

# Verify homebrew
which brew   # Should be available

# Check PATH
echo $PATH   # Should include cargo, homebrew, nix paths
```

## Complete Migration Example

### Updated flake.nix Structure
```nix
{
  description = "MacOS nix-darwin system flake";

  # ... inputs section unchanged ...

  outputs = inputs@{ self, nix-darwin, ... }:
  let
    configuration = { pkgs, config, ... }: {

      # ... existing configuration ...

      # Git configuration (replacing symlink)
      programs.git = {
        enable = true;
        userName = "Jackson Risse";
        userEmail = "j.risse14@proton.me";
        extraConfig = {
          core.editor = "hx";
        };
      };

      # SSH configuration (replacing symlink)
      programs.ssh = {
        enable = true;
        extraConfig = ''
          Host *
            IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
        '';
      };

      # Zsh configuration (replacing symlinks)
      programs.zsh = {
        enable = true;
        envExtra = ''
          . "$HOME/.cargo/env"
        '';
        profileExtra = ''
          eval "$(/opt/homebrew/bin/brew shellenv)"
        '';
        enableCompletion = true;
        enableSyntaxHighlighting = true;
      };

      # Runtime management (replacing asdf)
      environment.systemPackages = [
        # ... existing packages ...
        pkgs.ruby_3_3
        # Remove pkgs.asdf-vm if going full nix
      ];

      # ... rest of configuration ...
    };
  in {
    darwinConfigurations."macbook" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };
  };
}
```

## Migration Sequence

**Recommended Order**:
1. **Git** (least risky, easy to verify)
2. **SSH** (critical but straightforward)
3. **Zsh** (impacts shell environment)
4. **ASDF/Runtimes** (most complex, do last)

**Per Configuration**:
1. Add nix configuration
2. Test with `rebuild --test` (doesn't activate)
3. Verify with `rebuild switch` (activates)
4. Test functionality thoroughly
5. Only after verification: remove symlinks and tracked files
6. Commit changes

## Testing Strategy

### Before Migration
```bash
# Document current working state
git config --global --list > ~/pre-migration-git.txt
ssh -G github.com > ~/pre-migration-ssh.txt
asdf current > ~/pre-migration-asdf.txt
env > ~/pre-migration-env.txt
```

### After Each Phase
```bash
# Compare post-migration state
git config --global --list > ~/post-migration-git.txt
diff ~/pre-migration-git.txt ~/post-migration-git.txt

# Verify functionality
git clone git@github.com:ree-see/test-repo.git /tmp/test
cd /tmp/test && git status
```

### Rollback Procedure
```bash
# If something breaks
rollback  # Uses custom fish function to revert generation

# Or manually
darwin-rebuild switch --rollback
```

## Post-Migration Benefits

1. **Single Source of Truth**: All configuration in `flake.nix`
2. **Atomic Updates**: Change config → rebuild → instant rollback if issues
3. **Easier New Machine Setup**: `git clone` + `rebuild` = complete system
4. **Clear Separation**: Config definitions vs generated outputs
5. **Version History**: Nix generations track all system states

## Maintenance

### Making Configuration Changes
```bash
# Edit configuration
hx ~/.config/nix/flake.nix

# Apply changes
rebuild

# Verify
# ... test new configuration ...

# Commit if satisfied
git add ~/.config/nix/flake.nix
git commit -m "feat: update git configuration"
```

### No More Manual File Editing
Before: Edit `~/.config/git/config` → commit → push
After: Edit `flake.nix` → rebuild → commit → push

Generated files in `/nix/store/` are managed automatically.

## Timeline

**Week 1**: Git + SSH migration and testing
**Week 2**: Zsh migration and environment verification
**Week 3**: Runtime management strategy (asdf vs nix)
**Week 4**: Full integration testing and documentation

## Resources

- [nix-darwin options](https://daiderd.com/nix-darwin/manual/index.html)
- [programs.git options](https://nix-community.github.io/home-manager/options.html#opt-programs.git.enable)
- [programs.ssh options](https://nix-community.github.io/home-manager/options.html#opt-programs.ssh.enable)
- [programs.zsh options](https://nix-community.github.io/home-manager/options.html#opt-programs.zsh.enable)
