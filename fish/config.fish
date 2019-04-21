set PATH ~/bin ~/go/bin /usr/local/bin /usr/bin /bin /sbin /usr/sbin $PATH

alias c=clear

fish_vi_key_bindings

set -U fish_cursor_default     block      blink
set -U fish_cursor_insert      line       blink
set -U fish_cursor_replace_one underscore blink
set -U fish_cursor_visual      block

function fish_user_key_bindings
  bind -M insert jf "if commandline -P; commandline -f cancel; else; set fish_bind_mode default; commandline -f backward-char force-repaint; end"

  bind -M insert \cf forward-word
  bind -M insert \cb backward-word

  bind \cf forward-word
  bind \cb backward-word

  # bind yy fish_clipboard_copy
  # bind Y fish_clipboard_copy
  # bind p fish_clipboard_paste
  # bind -M visual y "fish_clipboard_copy; set fish_bind_mode default"

  bind -M visual H beginning-of-line
  bind H beginning-of-line
  bind -M visual L end-of-line
  bind L end-of-line

  # plugin-peco
  bind -M insert \cr peco_select_history
end

# fish-ghq
set GHQ_SELECTOR peco

