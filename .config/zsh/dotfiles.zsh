eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"

# Load custom zsh completions (including just) from the user completion directory.
fpath=("$HOME/.zsh/completions" $fpath)
autoload -U compinit
compinit

# Neovim
alias vim="nvim"
alias vi="nvim"

# lazygit & lazydocker
alias lg="lazygit"
alias ld="lazydocker"

# fzf + bat (better file previewing)
alias fzfp='fzf --preview "bat --color=always {}"'

# jq pretty printing
alias jq="jq -C"

# glow for markdown
alias mdless="glow"

# Config shortcuts
alias nvimcfg="nvim ~/.config/nvim"
alias zshcfg="nvim ~/.zshrc"
alias brewcfg="nvim ~/.Brewfile"