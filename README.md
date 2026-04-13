# Wiwa's dotfiles

Personal dotfiles for Debian-based VS Code dev containers. Uses Homebrew + Brewfile for tool management.

## Setup

Add to your VS Code user settings:

```json
{
    "dotfiles.repository": "https://github.com/lukewiwa/devcontainer-dotfiles.git",
    "dotfiles.installCommand": "install.sh"
}
```

VS Code will clone and run the install script automatically when creating dev containers.

## Target environment

- Debian/Ubuntu-based devcontainer images
- Linux only (not intended for host macOS setup)

## What gets installed

Tools are installed from [Brewfile](Brewfile) via `brew bundle`.
Homebrew installation and dependency checks are handled by the official Homebrew installer.

Current packages:

- bat
- delta
- fzf
- glow
- jq
- just
- lazydocker
- lazygit
- neovim

Shell init and aliases are managed in `.config/zsh/dotfiles.zsh` and sourced from `~/.zshrc` by the installer.

## Repo-local behavior in dev containers

This setup is designed for dev containers and avoids global Just/Git config:

- Copies a template justfile to `.justfile` in the current repo root only if `.justfile` does not already exist.
- Configures Git for the current repo by adding a local include for this dotfiles repo `.gitconfig` (stored in `.git/config`).
