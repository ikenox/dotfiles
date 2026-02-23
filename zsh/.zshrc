export PATH=~/.cargo/bin:~/bin:~/.local/bin:~/go/bin:/opt/homebrew/bin:/usr/bin:/usr/local/bin:/bin:/sbin:/usr/sbin:/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin:$PATH

eval "$(starship init zsh)"

if [ -f ~/.zshrc.local ]; then
  source ~/.zshrc.local
fi

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

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# mise
if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
fi

function new-git-worktree() {
    git worktree add ".git/my-worktrees/$1" -b "$1"
    cd ".git/my-worktrees/$1"
}

function ww() {
    local dir
    dir=$(git worktree list | peco | awk '{print $1}')
    [ -n "$dir" ] && cd "$dir"
}

function remove-all-git-worktrees() {
    local main_wt
    main_wt=$(git worktree list --porcelain | head -1 | sed 's/^worktree //')
    git worktree list --porcelain | grep '^worktree ' | sed 's/^worktree //' | while read -r wt; do
        [ "$wt" = "$main_wt" ] && continue
        echo "Removing worktree: $wt"
        git worktree remove --force "$wt"
    done
}
