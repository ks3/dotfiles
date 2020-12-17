#!/bin/bash

if [[ -d /opt/macports/bin ]]; then
    pathmunge /opt/macports/bin after
    pathmunge /opt/macports/sbin after

    outdated="$(port outdated 2>&1)"
    if [[ "$outdated" != "No installed ports are outdated." ]]; then
        echo "$outdated"
        echo
    fi
fi

