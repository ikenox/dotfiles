import sys
import os
import datetime
import subprocess

from keyhac import *


def configure(keymap):

    # --------------------------------------------------------------------
    # Text editer setting for editting config.py file

    # Setting with program file path (Simple usage)
    if 1:
        keymap.editor = "TextEdit"
        #keymap.editor = "Sublime Text 2"
        

    # Setting with callable object (Advanced usage)
    if 0:
        def editor(path):
            subprocess.call([ "open", "-a", "TextEdit", path ])
        keymap.editor = editor

    keymap_global = keymap.defineWindowKeymap()

    # Ctrl-hjkl to allow
    keymap_global[ "Ctrl-K" ] = "Up"
    keymap_global[ "Ctrl-J" ] = "Down"
    keymap_global[ "Ctrl-H" ] = "Left"
    keymap_global[ "Ctrl-L" ] = "Right"

    keymap_global[ "Ctrl-M" ] = "Back"

    # Google IME toggle
    keymap_global[ "O-RShift" ] = keymap.InputKeyCommand("(104)") #かな
    keymap_global[ "O-LShift" ] = keymap.InputKeyCommand("(102)") #英

    keymap_global[ "Ctrl-OpenBracket" ] = "Escape"

