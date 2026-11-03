# Wiwa's dotfiles

Personal dotfiles for Debian-based VS Code dev containers: shell aliases and tool config only.

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

Nothing. Tools (Homebrew packages via `ghcr.io/lukewiwa/debian-features/homebrew-packages`, zsh as the
default shell via `common-utils`) are devcontainer features, listed in the host dotfiles'
`.config/devcontainer/defaults.json` and applied by VS Code (`dev.containers.defaultFeatures`) and `wust dc-up`.

Shell init and aliases are managed in `.config/zsh/dotfiles.zsh` and sourced from `~/.zshrc` by the installer.

## Claude Code config

The installer clones [claude-config](https://github.com/lukewiwa/claude-config) to `~/.claude-config` and
links its skills into `~/.claude/skills`, the same as on the host.

## Repo-local behavior in dev containers

This setup is designed for dev containers and avoids global Just config:

- Copies a template justfile to `.justfile` in the current repo root only if `.justfile` does not already exist.

Git config isn't set here. It comes from the host: VS Code's `dev.containers.copyGitConfig` (or `wust dc-up`)
copies `~/.gitconfig` in. Inside a container, pick which forwarded agent key and email a repo uses with:

```bash
git account                  # fzf over the agent's keys; email = key comment
git account wsp.com          # non-interactive: the key whose line matches
git account gmail --email luke.wiwatowski@wsp.com   # wsp-digital: personal key, WSP email
```

It writes `.git/account.pub` + `.git/account.gitconfig` (included last in `.git/config`, so it beats older
pins) and accepts new host keys, so the first push works without a `known_hosts`. `.git` is shared with the
host, so the host repo picks it up too.
