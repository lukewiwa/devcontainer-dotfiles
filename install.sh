#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing dotfiles..."


# Tools (Homebrew packages, zsh) come from devcontainer features listed in the
# host dotfiles' .config/devcontainer/defaults.json, not from this script.

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
link_file "bin/git-account" ".local/bin/git-account"

setup_repo_local_files() {
    local repo_root
    local just_src="${SCRIPT_DIR}/.config/just/justfile"
    local just_dest

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
}

# Git config comes from the host: VS Code's dev.containers.copyGitConfig (or `wust dc-up`)
# copies ~/.gitconfig in. Pick a repo's account (agent key + email) with `git account`, here or via `wust git-pin`.

setup_repo_local_files

# Claude Code skills, shared with the host. Public, so https needs no auth.
# Cloned outside ~/.claude, which is a per-project volume, so every container gets a fresh copy.
claude_config="${HOME}/.claude-config"
if [ -d "${claude_config}/.git" ]; then
    git -C "$claude_config" pull --ff-only || echo "  Couldn't update claude-config, using existing copy"
else
    git clone https://github.com/lukewiwa/claude-config.git "$claude_config" \
        || echo "  Couldn't clone claude-config, skipping"
fi
[ -x "${claude_config}/install.sh" ] && "${claude_config}/install.sh"

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

echo "Done!"
