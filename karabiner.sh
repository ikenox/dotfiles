#!/bin/sh

cli=/Applications/Karabiner.app/Contents/Library/bin/karabiner

$cli set repeat.wait 30
/bin/echo -n .
$cli set repeat.initial_wait 200
/bin/echo -n .
$cli set option.vimode_control_hjkl 1
/bin/echo -n .
$cli set private.map_ctrl_semicolon_to_backspace 1
/bin/echo -n .
/bin/echo
