export PATH=~/.cargo/bin:~/bin:~/go/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/sbin:/usr/sbin:/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin:$PATH

setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS

bindkey -d
bindkey '^D' peco-src

eval "$(starship init zsh)"

# ===================
# zsh
# ===================
source ~/.zplug/init.zsh

zplug "jimeh/zsh-peco-history", defer:2
zplug "zsh-users/zsh-autosuggestions"

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi
# Then, source plugins and add commands to $PATH
zplug load --verbose

function peco-src () {
  local selected_dir=$(ghq list -p | peco --query "$LBUFFER")
  if [ -n "$selected_dir" ]; then
    BUFFER="cd ${selected_dir}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N peco-src
bindkey '^G' peco-src
