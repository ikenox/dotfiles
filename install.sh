#!/bin/bash

tmpfile=$(mktemp /tmp/dotfiles.playbook.XXXXXXXXXXXXX)
curl -f 'https://raw.githubusercontent.com/ikenox/dotfiles/master/playbook.yml' -o $tmpfile
ansible-playbook $tmpfile
