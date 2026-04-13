# Wiwa's dotfiles

Personal dotfiles for VS Code dev containers. Uses [mise](https://mise.jdx.dev/) for tool management.

## Setup

Add to your VS Code user settings:

```json
{
    "dotfiles.repository": "https://github.com/lukewiwa/devcontainer-dotfiles.git",
    "dotfiles.installCommand": "install.sh"
}
```

VS Code will clone and run the install script automatically when creating dev containers.

## Repo-local behavior in dev containers

This setup is designed for dev containers and avoids global Just/Git config:

- Copies a template justfile to `.justfile` in the current repo root only if `.justfile` does not already exist.
- Configures Git for the current repo by adding a local include for this dotfiles repo `.gitconfig` (stored in `.git/config`).

### Optional: pre-install mise as a dev container feature

```json
{
  "dev.containers.defaultFeatures": {
    "ghcr.io/devcontainers/features/common-utils:2": {
      "installZsh": true
    },
    "ghcr.io/devcontainers-extra/features/mise:1": {}
  }
}
```
