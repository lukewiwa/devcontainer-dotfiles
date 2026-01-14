#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing devcontainer dotfiles..."

# Verify mise is installed (should be via dev container feature)
if ! command -v mise &> /dev/null; then
    echo "ERROR: mise not found. Add the mise feature to your devcontainer.json"
    exit 1
fi

# Trust mise config file (suppress warning if already trusted)
echo "Trusting mise config..."
mise trust 2>&1 | grep -v "No untrusted config files found" || true

# Install tools from mise.toml
echo "Installing tools via mise..."
mise install --yes

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

link_file ".zsh_aliases" ".zsh_aliases"
link_file ".gitconfig" ".gitconfig"

# Link global gitignore
GIG="$HOME/.config/git/ignore"
if [ -f "$SCRIPT_DIR/.gitignore_global" ]; then
    mkdir -p "$(dirname "$GIG")"
    ln -sf "$SCRIPT_DIR/.gitignore_global" "$GIG"
    echo "  Linked: $GIG"
fi

# Setup zsh integration
setup_shell() {
    local shell_rc="${HOME}/.zshrc"
    local marker="# devcontainer-dotfiles"

    # Skip if already configured
    if grep -q "$marker" "$shell_rc" 2>/dev/null; then
        echo "Shell already configured"
        return
    fi

    echo "Configuring zsh..."
    cat >> "$shell_rc" << EOF

# devcontainer-dotfiles
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
