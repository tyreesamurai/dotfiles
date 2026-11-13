alias k='kubectl'
alias vi='nvim'
alias vim='nvim'

if (( $+commands[eza] )); then
  alias ls='eza --group-directories-first'
  alias ll='eza -lah --group-directories-first --git'
  alias la='eza -a --group-directories-first'
  alias lt='eza --tree --level=2 --group-directories-first'
fi

(( $+commands[bat] )) && alias cat='bat --paging=never'
