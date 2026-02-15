## Overview

A dotfiles repository for managing macOS development environment setup. Running `provision.sh` automates Homebrew package installation, symlink creation for config files, and macOS system preferences.

## Structure

- `provision.sh` — Entrypoint. Clones the repo, installs Homebrew and Node.js, then runs the provisioner
- `provisioner/` — Provisioning tool written in Node.js (TypeScript). Task definitions are in `provisioner/src/main.ts`
- `Brewfile` — List of packages to install via Homebrew
- `claude/` — Global Claude Code settings (symlinked to `~/.claude/`)
- Per-tool config directories (`git/`, `zsh/`, `vim/`, `ghostty/`, `karabiner/`, `vscode/`, `starship/`, `peco/`, `ag/`, `intellij/`, `jupyter/`, `qmk/`) — Configuration files for each tool
