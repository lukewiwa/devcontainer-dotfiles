#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing dotfiles..."

# Detect OS
OS="$(uname -s)"
case "$OS" in
    Darwin*)
        OS_NAME="macOS"
        ;;
    Linux*)
        OS_NAME="Linux"
        ;;
    *)
        OS_NAME="Unknown"
        ;;
esac
echo "Detected OS: $OS_NAME"

# Install mise if not present
if ! command -v mise &> /dev/null; then
    echo "mise not found, installing..."

    if [ "$OS_NAME" = "macOS" ]; then
        # Install mise on macOS
        echo "Installing mise via official installer..."
        curl https://mise.run | sh

        # Add mise to PATH for current session
        export PATH="${HOME}/.local/bin:${PATH}"

        # Verify installation
        if ! command -v mise &> /dev/null; then
            echo "ERROR: mise installation failed"
            exit 1
        fi
        echo "mise installed successfully"
    else
        # On Linux/dev containers, mise should be pre-installed via feature
        echo "ERROR: mise not found. In dev containers, add the mise feature to your devcontainer.json"
        exit 1
    fi
else
    echo "mise already installed"
fi

# Link global mise config
echo "Linking mise config..."
MISE_CONFIG="${HOME}/.config/mise/config.toml"
mkdir -p "$(dirname "$MISE_CONFIG")"
ln -sf "${SCRIPT_DIR}/.config/mise/config.toml" "$MISE_CONFIG"
echo "  Linked: $MISE_CONFIG"

# Trust mise config file (suppress warning if already trusted)
echo "Trusting mise config..."
mise trust 2>&1 | grep -v "No untrusted config files found" || true

# Install tools from global mise config
echo "Installing tools via mise..."
mise install --yes
# Activate for current shell session
eval "$(mise activate bash)"

# Install just completions
echo "Installing just completions..."
if command -v just &> /dev/null; then
    mkdir -p "${HOME}/.oh-my-zsh/completions"
    just --completions zsh > "${HOME}/.oh-my-zsh/completions/_just"
    echo "  Installed just completions"
else
    echo "  just not found, skipping completions"
fi

# Symlink dotfiles
echo "Linking dotfiles..."

link_file() {
    local src="${SCRIPT_DIR}/${1}"
    local dest="${HOME}/${2:-$1}"

    if [ -f "$src" ]; then
        mkdir -p "$(dirname "$dest")"
        ln -sf "$src" "$dest"
        echo "  Linked: $dest"
    fi
}

link_file ".zsh_aliases"
link_file ".gitconfig"
link_file ".gitignore_global" ".config/git/ignore"
link_file ".config/lazygit/config.yml" ".config/lazygit/config.yml"

# Setup zsh integration
setup_shell() {
    local shell_rc="${HOME}/.zshrc"
    local marker="# dotfiles-setup"

    # Skip if already configured
    if grep -q "$marker" "$shell_rc" 2>/dev/null; then
        echo "Shell already configured"
        return
    fi

    echo "Configuring zsh..."
    cat >> "$shell_rc" << EOF

# dotfiles-setup
export PATH="\${HOME}/.local/bin:\${PATH}"

# mise
eval "\$(mise activate zsh)"

# Aliases
[ -f ~/.zsh_aliases ] && source ~/.zsh_aliases
EOF
    echo "  Updated: $shell_rc"
}

setup_shell

echo "Done! Tools installed:"
mise list
