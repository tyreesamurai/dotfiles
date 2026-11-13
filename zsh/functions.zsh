# `git` with no args opens lazygit; with args it's normal git
git() {
  if (( $# == 0 )) && (( $+commands[lazygit] )); then
    lazygit
  else
    command git "$@"
  fi
}

# Wipe cached completions and restart the shell
refresh-completions() {
  rm -f "$ZSH_CACHE_DIR"/completions/_*(N) "$ZSH_CACHE_DIR"/zcompdump*(N)
  exec zsh
}
