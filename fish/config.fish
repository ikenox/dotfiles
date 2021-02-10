set PATH ~/.cargo/bin ~/bin ~/go/bin /usr/local/bin /usr/bin /bin /sbin /usr/sbin /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin $PATH
export CLOUDSDK_PYTHON=(which python3)

alias c=clear
alias gs "git status"
alias gl "git log"

function bb
  git branch -a --sort=-authordate | grep -v -e '->' -e '*' | perl -pe 's/^\h+//g' | perl -pe 's#^remotes/origin/###' | perl -nle 'print if !$c{$_}++' | peco | xargs git checkout
end

# fish_vi_key_bindings
fish_default_key_bindings

function fish_user_key_bindings
  # bind -M insert jf "if commandline -P; commandline -f cancel; else; set fish_bind_mode default; commandline -f backward-char force-repaint; end"

  bind \ca beginning-of-line
  bind \ce end-of-line

  # bind -M insert \cf forward-word
  # bind -M insert \cb backward-word
  bind \cf forward-word
  bind \cb backward-word

  # bind yy fish_clipboard_copy
  # bind Y fish_clipboard_copy
  # bind p fish_clipboard_paste
  # bind -M visual y fish_clipboard_copy end-selection

  #bind -M visual H beginning-of-line
  #bind H beginning-of-line
  #bind -M visual L end-of-line
  #bind L end-of-line
  #bind -M insert \e ""

  bind \cd ""

  bind zz peco_z

  # plugin-peco
  bind \cr peco_select_history
end

function peco_select_history
  if test (count $argv) = 0
    set peco_flags --layout=bottom-up
  else
    set peco_flags --layout=bottom-up --query "$argv"
  end

  history|peco $peco_flags|read foo

  if [ $foo ]
    commandline $foo
  else
    commandline ''
  end
end

function peco_z
        z -l | peco | awk '{ print $2 }' | read recentd
        cd $recentd
        commandline -f repaint
end

# fish-ghq
set GHQ_SELECTOR peco

function pyenv_init
    which pyenv >/dev/null && source (pyenv init - | psub)
end

function parsejwt
    cat | grep -oE '\..*\.' | grep -oE '[^.]+' | base64 -D | jq
end
