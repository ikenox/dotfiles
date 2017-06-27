########################################
# ENVIRONMENT

export LANG=ja_JP.UTF-8
export LESSCHARSET=utf-8
export GOPATH=$HOME

export PATH=~/bin:/usr/local/bin:/usr/bin:/bin:/sbin:/usr/sbin

#######################################
# Settings

autoload -Uz colors
colors

setopt print_eight_bit
setopt no_beep
setopt no_flow_control
setopt ignore_eof
setopt interactive_comments
setopt auto_pushd
function chpwd() { ls }
setopt pushd_ignore_dups
setopt share_history
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt extended_glob

# ヒストリの設定
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

# 単語の区切り文字を指定する
autoload -Uz select-word-style
select-word-style default
# ここで指定した文字は単語区切りとみなされる
# / も区切りと扱うので、^W でディレクトリ１つ分を削除できる
zstyle ':zle:*' word-chars " /=;@:{},|"
zstyle ':zle:*' word-style unspecified

########################################
# 補完
# 補完機能を有効にする
autoload -Uz compinit
compinit

# 補完で小文字でも大文字にマッチさせる
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# ../ の後は今いるディレクトリを補完しない
zstyle ':completion:*' ignore-parents parent pwd ..

# sudo の後ろでコマンド名を補完する
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin \
                   /usr/sbin /usr/bin /sbin /bin /usr/X11R6/bin

# ps コマンドのプロセス名補完
zstyle ':completion:*:processes' command 'ps x -o pid,s,args'

########################################
# PROMPT

autoload -Uz vcs_info
setopt prompt_subst
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "%F{yellow}!"
zstyle ':vcs_info:git:*' unstagedstr "%F{red}+"
zstyle ':vcs_info:*' formats "%F{green}%c%u(%b)%f"
zstyle ':vcs_info:*' actionformats '(%b|%a)'
precmd () { vcs_info }

# notice ssh
SSH_STMT="%{${fg[blue]}%}ssh:%{${reset_color}%}"
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    P_SSH_STMT=$SSH_STMT
else
  case $(ps -o comm= -p $PPID) in
    sshd|*/sshd) P_SSH_STMT=$SSH_STMT;;
  esac
fi

PROMPT="%{${fg[white]}%}[$P_SSH_STMT%n@%m]%{${reset_color}%} 🗂  %~
"
PROMPT=$PROMPT'${vcs_info_msg_0_}\$ '
RPROMPT="%F{242}%D{%y-%m-%d %T}%f"


########################################
# Keymap

# ^R で履歴検索をするときに * でワイルドカードを使用出来るようにする
bindkey '^R' history-incremental-pattern-search-backward

########################################
# Alias

alias la='ls -a'
alias ll='ls -l'

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias mkdir='mkdir -p'

# sudo の後のコマンドでエイリアスを有効にする
alias sudo='sudo '

# fasd
alias a='fasd -a'        # any
alias s='fasd -si'       # show / search / select
alias d='fasd -d'        # directory
alias f='fasd -f'        # file
alias sd='fasd -sid'     # interactive directory selection
alias sf='fasd -sif'     # interactive file selection
alias z='fasd_cd -d'     # cd, same functionality as j in autojump
alias zz='fasd_cd -d -i' # cd with interactive selection

alias p='ps ax | peco'

########################################
# OS 別の設定
case ${OSTYPE} in
    darwin*)
        #Mac用の設定
        export CLICOLOR=1
        alias ls='ls -G -F'
        ;;
    linux*)
        #Linux用の設定
        alias ls='ls -F --color=auto'
        ;;
esac

########################################
# peco
function history-selection() {
  case ${OSTYPE} in
      darwin*)
          BUFFER=`history -n 1 | tail -r  | awk '!a[$0]++' | peco`
          ;;
      linux*)
          BUFFER="$(history -nr 1 | awk '!a[$0]++' | peco --query "$LBUFFER" | sed 's/\\n/\n/')"
          ;;
  esac
  CURSOR=$#BUFFER
  zle reset-prompt
}

zle -N history-selection
bindkey '^R' history-selection

function ghq-selection () {
  local selected_dir=$(ghq list -p | peco --query "$LBUFFER")
  if [ -n "$selected_dir" ]; then
    BUFFER="cd ${selected_dir}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N ghq-selection
bindkey '^G' ghq-selection

########################################
## Plugins

source ~/.zplug/init.zsh

zplug "zplug/zplug", hook-build:'zplug --self-manage'

zplug "zsh-users/zsh-syntax-highlighting"

zplug "b4b4r07/zsh-gomi", as:command, use:bin

zplug "b4b4r07/enhancd", use:init.sh
export ENHANCD_FILTER=peco

zplug load

########################################
# Load modules

if ls ~/zshrc.local 1> /dev/null 2>&1; then
  source ~/.zshrc.local
fi

setopt nonomatch
if ls ~/zshrc.module.* 1> /dev/null 2>&1; then
  source ~/.zshrc.module.*
fi

