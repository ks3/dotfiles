#!/usr/bin/env bash

_vpn() {
    shopt -s extglob
    local cur prev words cword line
    _init_completion || return

    while read -r line; do
        line="${line%%+( )?(dis)connected}"
        line="${line//\'/\\\'}"
        line="${line// /\\ }"
        if [[ $line == "$cur"* ]]; then
            COMPREPLY+=("${line}")
        fi
    done < <(vpn </dev/null)
}
complete -F _vpn vpn
