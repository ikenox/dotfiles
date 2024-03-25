export PATH=~/.cargo/bin:~/bin:~/go/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/sbin:/usr/sbin:/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin:$PATH
export PATH=$(python3 -m site --user-base)"/bin":$PATH
eval "$(starship init zsh)"

if [ -f ~/.zshrc.local ]; then
  source ~/.zshrc.local
fi

export PATH=$HOME/.nodebrew/current/bin:$PATH

export HOMEBREW_NO_AUTO_UPDATE=1

# ===================
# settings
# ===================

export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=500000
export SAVEHIST=500000
setopt appendhistory
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

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

# https://github.com/alacritty/alacritty/issues/2027#issuecomment-455907223
export TERM=xterm-256color

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

# https://dev.classmethod.jp/articles/fzf-original-app-for-git-add/
function ga() {
    unbuffer git status -s | fzf -m --ansi --preview="echo {} | awk '{print \$2}' | xargs git diff --color" | awk '{print $2}' | xargs git add
}

function activate-nvm(){
   export NVM_DIR="$HOME/.config/nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
}

function docker-shell(){
   local target=$1
   docker build --target $target --progress=plain .
   docker run --rm -it $(docker build  --target $target -q .) /bin/bash
}

gg() {
  git branch -a --sort=-authordate |
    grep -v -e '->' -e '*' |
    perl -pe 's/^\h+//g' |
    perl -pe 's#^remotes/origin/##' |
    perl -nle 'print if !$c{$_}++' |
    peco |
    xargs git checkout
}

function connect_to_bluetooth_device(){
  local DEVICE_ID="$1"
  local res=$(blueutil --is-connected $DEVICE_ID)
  echo "pairing..."
  blueutil --pair $DEVICE_ID
  echo "paired. connecting..."
  sleep 1
  blueutil --connect $DEVICE_ID
  echo "connected"
}

# bun completions
[ -s "/Users/ikenonaoto/.bun/_bun" ] && source "/Users/ikenonaoto/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# pnpm
export PNPM_HOME="/Users/naoto.ikeno/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
