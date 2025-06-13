#!/bin/bash

if hash perl &>/dev/null; then
    perlver="$(perl -e '($v=$^V)=~s/\.[^\.]+$//;print $v')"
    [[ -d "$HOME/.perl/$perlver" ]] || mkdir -p "$HOME/.perl/$perlver"

    export PERL_MB_OPT="--install_base $HOME/.perl/$perlver"
    export PERL_MM_OPT="INSTALL_BASE=$HOME/.perl/$perlver"
    export PERL5LIB="$HOME/.perl/$perlver/lib/perl5"
    export PERL_LOCAL_LIB_ROOT="$HOME/.perl/$perlver"

    [[ -d "$HOME/.perl/$perlver/bin" ]] && PATH="$PATH:$HOME/.perl/$perlver/bin"
    unset perlver
fi
