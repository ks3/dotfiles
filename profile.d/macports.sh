#!/bin/bash

if [[ -d /opt/macports/bin ]]; then
    PATH="$PATH:/opt/macports/bin"
    PATH="$PATH:/opt/macports/sbin"

    hash gtimeout &>/dev/null && timeout="gtimeout 2"
    outdated="$(${timeout} port outdated 2>&1)"
    unset timeout

    if [[ "$outdated" != "No installed ports are outdated." ]]; then
        echo "$outdated"
        echo
    fi
fi

