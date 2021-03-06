#!/usr/bin/env bash

if [[ -z $PS1 ]]; then
    return
fi

[[ -f ~/.bash_aliases ]]   && source ~/.bash_aliases
[[ -f ~/.bash_functions ]] && source ~/.bash_functions


if [[ -d ~/.profile.d ]]; then
    for s in ~/.profile.d/*.sh; do
        [[ -r $s ]] && source "$s"
    done
fi

pathmunge ~/.local/bin
pathmunge ~/Scripts

set -o vi

unset PROMPT_COMMAND

export hostname="${HOSTNAME,,}"
export BASH_SILENCE_DEPRECATION_WARNING=1
export EDITOR="vim"
export LESS="RX"
export PS1="\[\e[00;34m\][\u@${hostname%%.*} \w]\$\[\e[00m\] "
export QUOTING_STYLE="literal"

umask 0022
