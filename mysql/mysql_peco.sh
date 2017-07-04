#!/bin/sh
BUFFER=$(sed -e "s/\\040/ /g" ~/.mysql_history | sed -e 's/\\//g' | egrep ";$" | egrep -i "^select|^update|^insert|^show|^commit|^use|^pager|^desc" | awk '!a[$0]++' | peco);
echo $BUFFER > ~/dotfiles/mysql/.tmp.sql
