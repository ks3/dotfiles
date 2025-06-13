if [[ $TERM != dumb && ! $STY && ! $TMUX && $TERM_PROGRAM != vscode && $TERM_PROGRAM != iTerm.app ]]; then
    # use tmux by default
    multiplexer="tmux"
    multiplexer_args=""

    if [[ -n $SSH_CLIENT ]]; then
        # but use screen in SSH sessions
        multiplexer="screen"
        multiplexer_args="-qxRR"
    fi

    if hash $multiplexer &>/dev/null; then
        exec $multiplexer $multiplexer_args
    elif [[ -x /opt/homebrew/bin/$multiplexer ]]; then
        exec /opt/homebrew/bin/$multiplexer $multiplexer_args
    elif [[ -x /opt/macports/bin/$multiplexer ]]; then
        exec /opt/macports/bin/$multiplexer $multiplexer_args
    fi
fi

[[ -f ~/.bashrc ]] && source ~/.bashrc

#if hash brew &>/dev/null; then
#    _output="$(brew outdated -q 2>&1)"
#    if [[ -n $_output ]]; then
#        echo "Outdated Homebrew packages:"
#        while read -r _package; do
#            echo "  - $_package"
#        done < <(echo "$_output")
#    fi
#    unset _output _package
#fi
