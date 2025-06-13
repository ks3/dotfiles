#!/bin/bash

if [[ $OSTYPE =~ ^darwin ]]; then

    export CLICOLOR=1

    alias fix-calendar-sync="pkill CalendarAgent"
    alias flush-dns="sudo killall -HUP mDNSResponder && dscacheutil -flushcache"

    if [[ -x ~/Scripts/fix-ids ]]; then
        _output="$(~/Scripts/fix-ids)"
        if [[ -n $_output ]]; then
            echo "$_output"
            echo
        fi
        unset _output
    fi

    if test -x ~/Documents/Resources/SwiftBar/VPN.*.sh; then
        # shellcheck disable=SC2139
        alias vpn="${HOME}/Documents/Resources/SwiftBar/VPN.*.sh"
    fi

    # performance as non-root is terrible
    alias nmap="sudo nmap"

fi

