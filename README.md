# devcontainer-dotfiles

Personal dotfiles for dev containers. Uses [mise](https://mise.jdx.dev/).

## Prerequisites

Add these features to your VS Code user settings in `dev.containers.defaultFeatures`:

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

## Setup

Add this to your VS Code settings (user settings, not workspace):

```json
{
    "dotfiles.repository": "lukewiwa/devcontainer-dotfiles",
    "dotfiles.installCommand": "install.sh"
}
```

That's it. VS Code will clone and run the install script automatically when creating dev containers.

## Adding tools

Edit `mise.toml` to add new tools:

```toml
[tools]
"github:your-org/your-tool" = "latest"
```

The `github` backend works with any tool that publishes binaries to GitHub releases. For tools not on GitHub, mise also supports `aqua` and `cargo` backends.
