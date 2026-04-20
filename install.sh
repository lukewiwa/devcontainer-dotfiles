#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing dotfiles..."


echo "Homebrew not found, installing..."
SHELL="/bin/zsh" NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"



eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"

# Install tools from Brewfile
echo "Installing tools via Brewfile..."
brew bundle --file="${SCRIPT_DIR}/Brewfile"

# Install just completions
echo "Installing just completions..."
if command -v just >/dev/null 2>&1; then
    completions_dir="${HOME}/.zsh/completions"
    mkdir -p "$completions_dir"
    just --completions zsh > "${completions_dir}/_just"
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
link_file ".config/zsh/dotfiles.zsh" ".config/zsh/dotfiles.zsh"

setup_repo_local_files() {
    local repo_root
    local just_src="${SCRIPT_DIR}/.config/just/justfile"
    local just_dest
    local gitconfig_src="${SCRIPT_DIR}/.gitconfig"

    if ! command -v git >/dev/null 2>&1; then
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

    touch "$shell_rc"

    # Remove existing dotfiles block if present
    if grep -q "$marker" "$shell_rc" 2>/dev/null; then
        sed -i.bak "/$marker/,/^# end dotfiles-setup$/d" "$shell_rc"
    fi

    echo "Configuring zsh..."
    cat >> "$shell_rc" << 'EOF'

# dotfiles-setup
source "$HOME/.config/zsh/dotfiles.zsh"
# end dotfiles-setup
EOF
}

setup_shell

echo "Done! Installed Homebrew packages:"
brew list --formula
