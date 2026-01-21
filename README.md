# dotfiles

![Test Installation](https://github.com/lukewiwa/devcontainer-dotfiles/workflows/Test%20Installation/badge.svg)

Personal dotfiles for VS Code dev containers and macOS. Uses [mise](https://mise.jdx.dev/) for tool management.

## macOS Setup

On macOS, simply clone and run the install script:

```bash
git clone https://github.com/lukewiwa/devcontainer-dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

The script will automatically:
- Install mise if not already present
- Install all tools defined in `.config/mise/config.toml`
- Symlink dotfiles to your home directory
- Configure your zsh shell

## Dev Container Setup

### Prerequisites (Optional)

For faster setup in dev containers, you can pre-install mise via features in your VS Code user settings:

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

If mise is not pre-installed, the install script will automatically install it.

### VS Code Dotfiles Integration

Add this to your VS Code settings (user settings, not workspace):

```json
{
    "dotfiles.repository": "https://github.com/lukewiwa/devcontainer-dotfiles.git",
    "dotfiles.installCommand": "install.sh"
}
```

That's it. VS Code will clone and run the install script automatically when creating dev containers.

## Adding tools

Edit `.config/mise/config.toml` to add new tools:

```toml
[tools]
"github:your-org/your-tool" = "latest"
```

The `github` backend works with any tool that publishes binaries to GitHub releases. For tools not on GitHub, mise also supports `aqua` and `cargo` backends.

## How it works

The install script:
1. Detects your operating system (macOS or Linux)
2. Installs mise if not already present (via the official installer)
3. Symlinks `.config/mise/config.toml` to `~/.config/mise/config.toml` as your **global mise config**
4. Installs all tools defined in the config
5. Symlinks dotfiles (`.gitconfig`, `.zsh_aliases`, etc.) to your home directory
6. Configures zsh integration for mise and aliases

Your tools are available globally in all projects and directories, not just in specific project directories.

**Note**: The script now installs mise automatically on all platforms, so you don't need to pre-install it or use the dev container feature. However, using the mise feature in dev containers is still recommended as it's faster.
