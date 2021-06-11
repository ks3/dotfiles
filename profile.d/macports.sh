#!/bin/bash

if [[ -d /opt/macports/bin ]]; then
    PATH="$PATH:/opt/macports/bin"
    PATH="$PATH:/opt/macports/sbin"

    outdated="$(port outdated 2>&1)"
    if [[ "$outdated" != "No installed ports are outdated." ]]; then
        echo "$outdated"
        echo
    fi
fi

