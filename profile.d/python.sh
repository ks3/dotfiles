#!/bin/bash

if [[ ! -e ~/.python ]]; then
    mkdir ~/.python
fi

if [[ ! -f ~/.python/current/bin/activate ]]; then
    if hash python3 &>/dev/null; then
        pyver="v$(python3 -c 'import sys;v=sys.version_info;print(f"{v.major}.{v.minor}")')"
        vdir="$HOME/.python/$pyver"
        if [[ ! -e $vdir ]]; then
            python3 -m venv --symlinks --system-site-packages --prompt "" "$HOME/.python/$pyver"
        fi
        ln -s "$vdir" ~/.python/current
        unset pyver vdir
    fi
fi

if [[ -f ~/.python/current/bin/activate ]]; then
    source ~/.python/current/bin/activate
fi
