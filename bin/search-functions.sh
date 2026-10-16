# ===== SEARCH FUNCTIONS
# Combines ripgrep / ripgrep-all / fd / bat / fzf so searching through files in CLI isn't the WORST.
# fzf + fd integration is in .fzfrc

# Fuzzy string search- shows line + column

alias fzfs='rgs'
rgs() {
  rg --column --line-number --no-heading --color=always "$1" | \
  fzf --ansi --delimiter : --preview "bat --color=always {1} --highlight-line {2}"
}

export -f rgs

# Fuzzy string search all matching lines, smartcase + extra rg flags
alias fzfa='rgf'
rgf() {
  rg --line-number --no-heading --color=always --smart-case "$@" |
    fzf --ansi --delimiter ':' \
        --preview 'bat --color=always --highlight-line {2} {1}' \
        --preview-window '+{2}/2'
}

export -f rgf

# Search within files via fzf - temporarily switches from using fd to rga
alias fzff='rga-fzf'

rga-fzf() {
  RG_PREFIX="rg --files-with-matches"
  local file
  file="$(
    FZF_DEFAULT_COMMAND="${RG_PREFIX} '$1' '$2'" \
    fzf-tmux -p -h 40% -w 100% -x 0 -y 40 --reverse --keep-right --info=inline -e --preview="[[ ! -z {} ]] && rga --pretty --colors=match:fg:229,160,57 -C=3 {q} {}")"
}
export -f rga-fzf

# ---------

alias fzfl='rg-live'
# Live FZF search - "I'm exploring"
rg-live() {
  RELOAD='reload:rg --column --color=always --smart-case {q} || :'
  fzf --disabled --ansi \
      --bind "start:${RELOAD}" --bind "change:${RELOAD}" \
      --bind 'enter:become(vim {1} +{2})' \
      --delimiter : \
      --query "$*" \
      --preview 'bat --style=full --color=always --highlight-line {2} {1}' \
      --preview-window '~4,+{2}+4/3,<80(up)'
}   
export -f rg-live


# --- /etc/ fuzzy file finder (opens in $EDITOR) --- (might not keep)
# sets fallback to nano instead of vim because wtf
etc() {
  fd -t f "$1" /etc/ | fzf | xargs -r "${EDITOR:-nano}"
}
