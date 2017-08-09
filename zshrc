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
        alias ls='ls -G'
        ;;
    linux*)
        #Linux用の設定
        alias ls='ls --color=auto'
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

function peco-file() {
    local filepath=$(ag -l | peco --prompt 'PATH >')
    if [ -n "$filepath" ]; then
        if [ -n "$BUFFER" ]; then
            BUFFER="$BUFFER $(echo $filepath | tr '\n' ' ')"
            CURSOR=$#BUFFER
        else
            if [ -f "$filepath" ]; then
                BUFFER="$EDITOR $filepath"
                zle accept-line
            fi
        fi
    fi
}
zle -N peco-file
bindkey '^p' peco-file

########################################
## tmux

function is_exists() { type "$1" >/dev/null 2>&1; return $?; }
function is_osx() { [[ $OSTYPE == darwin* ]]; }
function is_screen_running() { [ ! -z "$STY" ]; }
function is_tmux_runnning() { [ ! -z "$TMUX" ]; }
function is_screen_or_tmux_running() { is_screen_running || is_tmux_runnning; }
function shell_has_started_interactively() { [ ! -z "$PS1" ]; }
function is_ssh_running() { [ ! -z "$SSH_CONECTION" ]; }

function tmux_automatically_attach_session()
{
    if is_screen_or_tmux_running; then
        ! is_exists 'tmux' && return 1

        if is_tmux_runnning; then
            echo "${fg_bold[red]} _____ __  __ _   ___  __ ${reset_color}"
            echo "${fg_bold[red]}|_   _|  \/  | | | \ \/ / ${reset_color}"
            echo "${fg_bold[red]}  | | | |\/| | | | |\  /  ${reset_color}"
            echo "${fg_bold[red]}  | | | |  | | |_| |/  \  ${reset_color}"
            echo "${fg_bold[red]}  |_| |_|  |_|\___//_/\_\ ${reset_color}"
        elif is_screen_running; then
            echo "This is on screen."
        fi
    else
        if shell_has_started_interactively && ! is_ssh_running; then
            if ! is_exists 'tmux'; then
                echo 'Error: tmux command not found' 2>&1
                return 1
            fi

            if tmux has-session >/dev/null 2>&1 && tmux list-sessions | grep -qE '.*]$'; then
                # detached session exists
                tmux list-sessions
                echo -n "Tmux: attach? (y/N/num) "
                read
                if [[ "$REPLY" =~ ^[Yy]$ ]] || [[ "$REPLY" == '' ]]; then
                    tmux attach-session
                    if [ $? -eq 0 ]; then
                        echo "$(tmux -V) attached session"
                        return 0
                    fi
                elif [[ "$REPLY" =~ ^[0-9]+$ ]]; then
                    tmux attach -t "$REPLY"
                    if [ $? -eq 0 ]; then
                        echo "$(tmux -V) attached session"
                        return 0
                    fi
                fi
            fi

            if is_osx && is_exists 'reattach-to-user-namespace'; then
                # on OS X force tmux's default command
                # to spawn a shell in the user's namespace
                tmux_config=$(cat $HOME/.tmux.conf <(echo 'set-option -g default-command "reattach-to-user-namespace -l $SHELL"'))
                tmux -f <(echo "$tmux_config") new-session && echo "$(tmux -V) created new session supported OS X"
            else
                tmux new-session && echo "tmux created new session"
            fi
        fi
    fi
}
tmux_automatically_attach_session

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

setopt nonomatch
for f (~/.zshrc.local ~/.zshrc.module.*) source $f
