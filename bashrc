#!/usr/bin/env bash

shopt -s extglob

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

function prompt_command() {
    PROMPT_AWS=""
    PROMPT_GIT=""

    if [[ -n $AWS_PROFILE ]]; then
        PROMPT_AWS=" $AWS_PROFILE"
    fi

    local branch="$(git branch --show-current 2>/dev/null)"
    local index=""
    local work=""
    local status=""
    if [[ -n $branch ]]; then
        while IFS= read line; do
            c=${line:0:1}
            if [[ $c != ' ' && $index != *"$c"* ]]; then
                index="${index}$c"
            fi
            c=${line:1:1}
            if [[ $c != ' ' && $work != *"$c"* ]]; then
                work="${work}$c"
            fi
        done < <(git status --short)
        if [[ -n $index || -n $work ]]; then
            status="${index}:${work}"
        fi
        PROMPT_GIT=" ${branch}${status:+(}${status}${status:+)}"
    fi
}

#unset PROMPT_COMMAND
PROMPT_COMMAND=prompt_command

COLOR_YELLOW="\[\e[01;33m\]"
COLOR_BLUE="\[\e[00;34m\]"
COLOR_MAGENTA="\[\e[00;35m\]"
COLOR_WHITE="\[\e[01;37m\]"
COLOR_RESET="\[\e[00m\]"
export hostname="${HOSTNAME,,}"
export BASH_SILENCE_DEPRECATION_WARNING=1
export EDITOR="vim"
export LESS="RX"
#export PS1="${COLOR_BLUE}[\u@${hostname%%.*}${COLOR_YELLOW}\${PROMPT_AWS:+ }\${PROMPT_AWS}${COLOR_MAGENTA}\${PROMPT_GIT:+ }\${PROMPT_GIT}${COLOR_BLUE} \w]\$${COLOR_RESET} "
export PS1="${COLOR_BLUE}[\u@${hostname%%.*}:\w${COLOR_WHITE}\${PROMPT_GIT}${COLOR_YELLOW}\${PROMPT_AWS}${COLOR_BLUE}]\$ ${COLOR_RESET}"
export QUOTING_STYLE="literal"

umask 0022
