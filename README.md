# Wiwa's dotfiles

Personal dotfiles for VS Code dev containers and macOS. Uses [mise](https://mise.jdx.dev/) for tool management.

## macOS Setup

Clone and run the install script:

```bash
git clone https://github.com/lukewiwa/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

The script will automatically:
- Install mise if not already present
- Install all tools defined in `.config/mise/config.toml`
- Activate shell aliases defined in mise config
- Symlink dotfiles to your home directory
- Configure your zsh shell
- Install Homebrew packages from `Brewfile` (if brew is available)

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
    "dotfiles.repository": "https://github.com/lukewiwa/dotfiles.git",
    "dotfiles.installCommand": "install.sh"
}
```

That's it. VS Code will clone and run the install script automatically when creating dev containers.

## Adding tools and aliases

Edit `.config/mise/config.toml` to add new tools or shell aliases:

```toml
[tools]
"github:your-org/your-tool" = "latest"

[shell_alias]
myalias = "your-command here"
```

The `github` backend works with any tool that publishes binaries to GitHub releases. For tools not on GitHub, mise also supports `aqua` and `cargo` backends.

Shell aliases are automatically activated by `mise activate zsh` and support all shell syntax.
