# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a chezmoi-managed dotfiles repository for macOS. The repository uses chezmoi's templating system to manage configuration files across machines, with a strong emphasis on 1Password integration for secrets management.

## Critical Architecture Details

### Directory Structure

- **Source root**: `.chezmoiroot` is set to `home/`, meaning all managed files are in the `home/` directory
- **Target destination**: Files in `home/` are managed as if they were in `~/` (user's home directory)
- **Naming conventions**:
    - `dot_` prefix → `.` (e.g., `dot_gitconfig` becomes `~/.gitconfig`)
    - `private_` prefix → Creates files with restricted permissions (600)
    - `run_onchange_` prefix → Scripts that run when their content changes
    - `.tmpl` suffix → Template files processed by chezmoi's Go templating engine

### Configuration Files

- **chezmoi config**: `~/.config/chezmoi/chezmoi.toml`
    - Editor: VS Code (`code --wait`)
    - Diff/merge tool: Kaleidoscope (`ksdiff`)
    - Pre-hook: `.install-1password.sh` runs before reading source state
- **Data file**: `home/.chezmoidata/packages.yaml` contains all Homebrew packages/taps/casks

### 1Password Integration

The repository heavily integrates with 1Password:

- `.install-1password.sh` runs as a pre-hook to ensure `op` CLI is available
- Git commits are signed using 1Password SSH agent
- Configuration files likely use 1Password references (syntax: `op://vault/item/field`)

### Package Management

Package installation is declarative via `packages.yaml`:

- Uses `run_onchange_before_install-packages-darwin.sh.tmpl` to install packages
- Template reads from `.chezmoidata/packages.yaml` (accessible via `.packages.darwin` in templates)
- Installs via `brew bundle --no-lock --file=/dev/stdin`

## Common Commands

### Basic Chezmoi Workflow

```bash
# Preview changes before applying
chezmoi diff

# Apply changes to home directory
chezmoi apply

# Edit a managed file in VS Code
chezmoi edit ~/.gitconfig

# Add a new file to be managed
chezmoi add ~/.newconfig

# Update chezmoi source from home directory changes
chezmoi re-add

# See what files are managed
chezmoi managed
```

### Working with Templates

```bash
# View rendered template output
chezmoi cat ~/.zshrc

# Execute template to see what would be applied
chezmoi execute-template < home/some_file.tmpl
```

### Package Management

```bash
# Add packages: Edit home/.chezmoidata/packages.yaml
# Then apply changes (triggers run_onchange script)
chezmoi apply

# To manually trigger package installation:
bash home/run_onchange_before_install-packages-darwin.sh.tmpl
```

### Development Tools

```bash
# Format files (Prettier configured for TOML and INI)
npm run format

# The repo includes prettier-plugin-toml and prettier-plugin-ini
```

## Key Configuration Files

- **Zsh setup**:
    - `home/dot_zshrc` - Main zsh config
    - `home/dot_zsh_plugins.txt` - Antidote plugin definitions
    - Uses: Starship prompt, zoxide, mcfly, antidote plugin manager
- **Git config**: `home/dot_gitconfig` - Extensive git aliases and configuration
- **Shell tools**: nvim (editor), gh (GitHub CLI), lazygit, fzf, eza, bat, delta

## Important Behaviors

1. **Template Processing**: Any file with `.tmpl` suffix has access to:
    - `.chezmoi.os` - Operating system
    - `.packages.darwin.*` - Package lists from `.chezmoidata/packages.yaml`
    - Standard Go template functions

2. **Run-once Scripts**: Files prefixed with `run_onchange_` execute when:
    - Their content hash changes
    - First time applying the dotfiles

3. **1Password Requirement**: This setup requires 1Password CLI and desktop app for:
    - SSH signing of git commits
    - Potentially other secret references in config files

4. **macOS-specific**: Configuration is heavily macOS-optimized (see `mac-tweaks.md` for system preferences)

## When Editing Files

- Always edit files in the chezmoi source directory (`~/.local/share/chezmoi/home/`)
- Use `chezmoi edit` to edit files properly (opens in configured editor)
- After manual edits to source, use `chezmoi apply` to update home directory
- If editing `packages.yaml`, remember it's in `home/.chezmoidata/` not `home/`

## Working with Claude Code

### Important Workflow

**NEVER apply changes directly to `~/` when working in this repository!**

When Claude Code suggests changes:

1. **Work in the chezmoi source**: All edits should be in `~/.local/share/chezmoi/home/`
2. **Review changes**: User reviews the changes in the source directory
3. **User applies**: The user runs `chezmoi apply` after reviewing
4. **Don't auto-apply**: Claude should NOT run `chezmoi apply` or make changes to `~/` directly

This ensures all changes are:

- Tracked in version control
- Reviewable before deployment
- Properly templated and managed by chezmoi

### Claude Code Configuration

This repository includes Claude Code configuration:

- **Settings**: `home/dot_claude/settings.json` - Includes hooks, permissions, and sandbox config
- **Archive script**: `home/dot_local/bin/executable_archive-claude-conversation.sh`

The PreCompact hook archives conversation transcripts before compaction, preserving context for documentation improvement and analysis. See `docs/claude-code-setup.md` for details.

### Testing Changes

Before applying chezmoi changes:

```bash
# Test hook functionality
./test-archive-hook.sh

# Preview what will change
chezmoi diff

# Apply when ready
chezmoi apply
```
