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

link_file ".gitignore_global" ".config/git/ignore"
link_file ".config/lazygit/config.yml" ".config/lazygit/config.yml"

setup_repo_local_files() {
    local repo_root
    local just_src="${SCRIPT_DIR}/.config/just/justfile"
    local just_dest
    local gitconfig_src="${SCRIPT_DIR}/.gitconfig"

    if ! command -v git &> /dev/null; then
        echo "Git not found, skipping repo-local setup"
        return
    fi

    if ! repo_root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
        echo "Not inside a git repository, skipping repo-local setup"
        return
    fi

    echo "Configuring repo-local files in: ${repo_root}"

    just_dest="${repo_root}/.justfile"
    if [ -f "$just_dest" ]; then
        echo "  Found existing .justfile, leaving it unchanged"
    else
        cp "$just_src" "$just_dest"
        echo "  Copied: $just_dest"
    fi

    if git -C "$repo_root" config --local --get-all include.path | grep -Fxq "$gitconfig_src"; then
        echo "  Local git include already configured"
    else
        git -C "$repo_root" config --local --add include.path "$gitconfig_src"
        echo "  Added local git include: $gitconfig_src"
    fi
}

setup_repo_local_files

# Setup zsh integration
setup_shell() {
    local shell_rc="${HOME}/.zshrc"
    local marker="# dotfiles-setup"

    # Remove existing dotfiles block if present
    if grep -q "$marker" "$shell_rc" 2>/dev/null; then
        sed -i.bak "/$marker/,/^# end dotfiles-setup$/d" "$shell_rc"
    fi

    echo "Configuring zsh..."
    cat >> "$shell_rc" << EOF

# dotfiles-setup
export PATH="\${HOME}/.local/bin:\${PATH}"

# mise (provides tools, aliases, and environment)
eval "\$(mise activate zsh)"


setup_shell

echo "Done! Tools installed:"
mise list
