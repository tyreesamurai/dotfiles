export ZSH="$HOME/.oh-my-zsh"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting web-search)



source $ZSH/oh-my-zsh.sh
eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/my-theme.yaml)"


alias vim="nvim"
alias oo="cd ~/Desktop/studies/zettelkasten/"
alias or='vim ~/desktop/studies/zettelkasten/inbox/*.md'
alias projects="cd ~/Desktop/studies/personal/coding/projects/"
alias conf='cd ~/.config/'
alias zconf="vim ~/.zshrc"
alias leetcode="nvim leetcode.nvim"

export PATH="$HOME/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"
export PATH="~/.local/bin:$PATH"
export PATH="/usr/local/mysql-9.1.0-macos14-arm64/bin:$PATH"

eval "$(zoxide init --cmd cd zsh)"
