# 少し凝った zshrc
# License : MIT
# http://mollifier.mit-license.org/

script_dir=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)

########################################
# android

export ANDROID_HOME=/usr/local/Cellar/android-sdk/24.4.1_1
export ANDROID_TOOLS=/usr/local/Cellar/android-sdk/24.4.1_1/tools
export ANDROID_PLATFORM_TOOLS=/usr/local/Cellar/android-sdk/24.4.1_1/platform-tools

PATH=$PATH:$ANDROID_HOME:$ANDROID_TOOLS:$ANDROID_PLATFORM_TOOLS:.

[ -s "/Users/ikeno/.dnx/dnvm/dnvm.sh" ] && . "/Users/ikeno/.dnx/dnvm/dnvm.sh" # Load dnvm

export LANG=en_US.UTF-8
export LESSCHARSET=utf-8
export PATH=/usr/bin:/bin:/sbin:/usr/sbin:$PATH
export JAVA_HOME=`/usr/libexec/java_home -v 1.8`
export PATH="/Applications/sdk/tools:$PATH"
export PATH=$HOME/.rbenv/bin:$PATH
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PATH="$HOME/.rbenv/bin:$PATH"
export PATH=/usr/local/bin:$PATH

export HOMEBREW_CASK_OPTS="--appdir=/Applications"

eval "$(rbenv init - zsh)"
eval "$(pyenv init - zsh)"

#######################################
# 環境変数
export LANG=ja_JP.UTF-8

# fasd
alias a='fasd -a'        # any
alias s='fasd -si'       # show / search / select
alias d='fasd -d'        # directory
alias f='fasd -f'        # file
alias sd='fasd -sid'     # interactive directory selection
alias sf='fasd -sif'     # interactive file selection
alias z='fasd_cd -d'     # cd, same functionality as j in autojump
alias zz='fasd_cd -d -i' # cd with interactive selection

# 色を使用出来るようにする
autoload -Uz colors
colors

# ヒストリの設定
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

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

PROMPT="%{${fg[green]}%}[%n@%m]%{${reset_color}%} %~
"
PROMPT=$PROMPT'${vcs_info_msg_0_}%# '
RPROMPT="%F{242}%D{%y-%m-%d %T}%f"



########################################
# オプション
# 日本語ファイル名を表示可能にする
setopt print_eight_bit

# beep を無効にする
setopt no_beep

# フローコントロールを無効にする
setopt no_flow_control

# Ctrl+Dでzshを終了しない
setopt ignore_eof

# '#' 以降をコメントとして扱う
setopt interactive_comments

# ディレクトリ名だけでcdする
setopt auto_cd

# cd したら自動的にpushdする
setopt auto_pushd

# cdしたら自動でls
function chpwd() { ls }

# 重複したディレクトリを追加しない
setopt pushd_ignore_dups

# 同時に起動したzshの間でヒストリを共有する
setopt share_history

# 同じコマンドをヒストリに残さない
setopt hist_ignore_all_dups

# スペースから始まるコマンド行はヒストリに残さない
setopt hist_ignore_space

# ヒストリに保存するときに余分なスペースを削除する
setopt hist_reduce_blanks

# 高機能なワイルドカード展開を使用する
setopt extended_glob

########################################
# キーバインド

# ^R で履歴検索をするときに * でワイルドカードを使用出来るようにする
bindkey '^R' history-incremental-pattern-search-backward

########################################
# エイリアス

alias la='ls -a'
alias ll='ls -l'

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias mkdir='mkdir -p'

# sudo の後のコマンドでエイリアスを有効にする
alias sudo='sudo '

# グローバルエイリアス
alias -g L='| less'
alias -g G='| grep'

# Gitのエイリアス
git config --global alias.co checkout
git config --global alias.st 'status'
git config --global alias.ci 'commit -a'
git config --global alias.di 'diff'
git config --global alias.br 'branch'

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
function peco-history-selection() {
    BUFFER=`history -n 1 | tail -r  | awk '!a[$0]++' | peco`
    CURSOR=$#BUFFER
    zle reset-prompt
}

zle -N peco-history-selection
bindkey '^R' peco-history-selection


########################################
## cd

function peco-cd()
{
    local var
    local dir
    if [ ! -t 0 ]; then
    var=$(cat -)
    dir=$(echo -n $var | peco)
    else
        return 1
    fi

    if [ -d "$dir" ]; then
        cd "$dir"
    else
        echo "'$dir' was not directory." >&2
        return 1
    fi
    zle reset-prompt
  }

function peco-find-cd()
{
  find . -maxdepth 5 | peco-cd
}

zle -N peco-find-cd
bindkey '^Q' peco-find-cd

########################################
## enhancd

source ${script_dir}/repositories/enhancd/init.sh
function enhancd()
{
  cd
}

zle -N enhancd
bindkey '^U' enhancd

