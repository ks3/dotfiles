#!/usr/bin/env bash

shopt -s extglob

if [[ -z $PS1 ]]; then
    return
fi

export COLOR_BLACK="\e[00;30m"
export COLOR_RED="\e[00;31m"
export COLOR_GREEN="\e[00;32m"
export COLOR_YELLOW="\e[00;33m"
export COLOR_BLUE="\e[00;34m"
export COLOR_MAGENTA="\e[00;35m"
export COLOR_CYAN="\e[00;36m"
export COLOR_WHITE="\e[00;37m"
export COLOR_RESET="\e[00m"

[[ -f ~/.bash_aliases ]]   && source ~/.bash_aliases
[[ -f ~/.bash_functions ]] && source ~/.bash_functions

pathmunge ~/.local/bin
pathmunge ~/Scripts

if [[ -d ~/.profile.d ]]; then
    for s in ~/.profile.d/*.sh; do
        [[ -r $s ]] && source "$s"
    done
fi
unset s

set -o vi

function _add_newlines() {
    exec </dev/tty

    # only do this if there is no input waiting on stdin
    #read -t 0 _
    #echo "Read returned: $?"
    #if read -t 0 -u 0; then
    #    return
    #else

    # slurp any waiting input, this is less than ideal
    _flush_stdin

    # get current cursor position
    local line
    local col
    IFS=';' read -rs -p$'\e[6n' -dR line col
    line="${line:2}"

    # if prior command output didn't end in newline, add indicator newline
    [[ $col -ne 1 ]] && echo "$"

    # add newline if we aren't at top of screen
    [[ $line -ne 1 ]] && echo ""

    #fi
}
_flush_stdin() {
    read -r -n 100000 -t 0.01
}
_reset_terminal() {
    stty sane
}
if [[ " ${PROMPT_COMMAND[*]} " != *" _add_newlines "* ]]; then
    PROMPT_COMMAND+=('_add_newlines')
fi
#if [[ " ${PROMPT_COMMAND[*]} " != *" _reset_terminal "* ]]; then
#    PROMPT_COMMAND+=('_reset_terminal')
#fi

export hostname="${HOSTNAME,,}"
export BASH_SILENCE_DEPRECATION_WARNING=1
export EDITOR="vim"
export LESS="RX"
export QUOTING_STYLE="literal"

#export PS0="\$(stty -echo)"
if [[ " ${PROMPT_COMMAND[*]} " != *" stty -echo "* ]]; then
    PROMPT_COMMAND+=('stty -echo')
fi
export GIT_PROMPT_START="\[${COLOR_CYAN}\]┌─── \u@${hostname%%.*} \[${COLOR_BLUE}\]\w\[${COLOR_RESET}\]"
export GIT_PROMPT_END="\[${COLOR_YELLOW}\]\${AWS_PROFILE:+ }\${AWS_PROFILE}\n\[${COLOR_CYAN}\]└─ \[${COLOR_BLUE}\]\$\[${COLOR_RESET}\] \[\$(_flush_stdin;stty echo)\]"
export PS1="${GIT_PROMPT_START}${GIT_PROMPT_END}"

umask 0022

[[ -e ~/.local/bashrc ]] && source ~/.local/bashrc
