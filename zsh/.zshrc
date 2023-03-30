export PATH=~/.cargo/bin:~/bin:~/go/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/sbin:/usr/sbin:/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin:$PATH
eval "$(starship init zsh)"

# ===================
# settings
# ===================
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS

setopt inc_append_history
setopt share_history

bindkey -d
bindkey '^G' peco-src

# https://stackoverflow.com/a/12403798
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word

# stop word-deletion on '/'
autoload -U select-word-style
select-word-style bash

# disable closing window by Ctrl-D
set -o ignoreeof

# case-insensitive completion for lowercase
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}'

# ===================
# plugin management
# ===================
# Download Znap, if it's not there yet.
[[ -f ~/.znap/zsh-snap/znap.zsh ]] ||
    git clone --depth 1 -- \
        https://github.com/marlonrichert/zsh-snap.git ~/.znap/zsh-snap
# Start Znap
source ~/.znap/zsh-snap/znap.zsh
# plugins
znap source zsh-users/zsh-autosuggestions
znap source zsh-users/zsh-syntax-highlighting
znap source jimeh/zsh-peco-history

# ====================
# functions
# ====================

function peco-src () {
  local selected_dir=$(ghq list -p | peco --layout=bottom-up --query "$LBUFFER")
  if [ -n "$selected_dir" ]; then
    BUFFER="cd ${selected_dir}"
    zle accept-line
  fi
}
zle -N peco-src
