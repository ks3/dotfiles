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
    PROMPT_NEWLINE=""

    if [[ -n $AWS_PROFILE ]]; then
        PROMPT_AWS=" $AWS_PROFILE"
    fi

    local branch="$(git branch --show-current 2>/dev/null)"
    local index=""
    local work=""
    local status=""
    if [[ -n $branch ]]; then
        while IFS= read -r line; do
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

    # get current cursor position
    local line
    local col
    IFS=';' read -rs -p$'\e[6n' -dR line col
    line="${line:2}"
    if [[ $col -ne 1 ]]; then
        # if prior command output didn't end in newline, add indicator newline
        PROMPT_NEWLINE=$'$\n'
    #elif [[ $line -ne 1 ]]; then
    #    # add newline if we aren't at top of screen
    #    PROMPT_NEWLINE=$'\n'
    fi

    # reset terminal settings
    stty sane
}
PROMPT_COMMAND=prompt_command

export COLOR_PROMPT="\[\e[00;34m\]"
export COLOR_BLACK="\[\e[38;5;0m\]"
export COLOR_BLUE="\[\e[38;5;26m\]"
export COLOR_GREEN="\[\e[38;5;40m\]"
export COLOR_PURPLE="\[\e[38;5;135m\]"
export COLOR_ORANGE="\[\e[38;5;214m\]"
export COLOR_YELLOW="\[\e[38;5;226m\]"
export COLOR_WHITE="\[\e[38;5;255m\]"
export COLOR_RESET="\[\e[00m\]"

export hostname="${HOSTNAME,,}"
export BASH_SILENCE_DEPRECATION_WARNING=1
export EDITOR="vim"
export LESS="RX"
export QUOTING_STYLE="literal"

export PS1="\${PROMPT_NEWLINE}${COLOR_PROMPT}[\u@${hostname%%.*}:\w${COLOR_WHITE}\${PROMPT_GIT}${COLOR_ORANGE}\${PROMPT_AWS}${COLOR_PROMPT}]\$ ${COLOR_RESET}"

umask 0022

[[ -e ~/.local/bashrc ]] && source ~/.local/bashrc
