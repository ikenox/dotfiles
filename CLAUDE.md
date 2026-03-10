## Overview

A dotfiles repository for managing macOS development environment setup. Running `provision.sh` automates Homebrew package installation, symlink creation for config files, and macOS system preferences.

## Structure

- `provision.sh` — Entrypoint. Clones the repo, installs Homebrew and Node.js, then runs the provisioner
- `provisioner/` — Provisioning tool written in Node.js (TypeScript). Task definitions are in `provisioner/src/main.ts`
- `Brewfile` — List of packages to install via Homebrew
- `claude/` — Global Claude Code settings (symlinked to `~/.claude/`)
- Per-tool config directories (`git/`, `zsh/`, `vim/`, `ghostty/`, `karabiner/`, `vscode/`, `starship/`, `peco/`, `ag/`, `intellij/`, `jupyter/`, `qmk/`) — Configuration files for each tool

## Note

- This is a dotfiles repo, so there are two kinds of config files that can be confused:
  - **Repo-internal config** — Files that configure this repository's own tooling (e.g., `.claude/`, `.git/`)
  - **Dotfiles-managed config** — Files checked into this repo to be symlinked to the home directory (e.g., `claude/`, `git/`)
- When an instruction about editing config is ambiguous about which one is intended, always ask for clarification before proceeding.
