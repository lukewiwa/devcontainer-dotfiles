eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"

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