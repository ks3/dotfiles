#!/bin/bash

if [[ $OSTYPE =~ ^darwin ]]; then
    if [[ -x ~/Scripts/fix-ids ]]; then
        output="$(~/Scripts/fix-ids)"
        if [[ -n $output ]]; then
            echo "$output"
            echo
        fi
    fi
fi

