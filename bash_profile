if [[ $TERM != dumb && ! $STY && ! $TMUX ]]; then
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
    elif [[ -x /opt/macports/bin/$multiplexer ]]; then
        exec /opt/macports/bin/$multiplexer $multiplexer_args
    fi
fi

[[ -f ~/.bashrc ]] && source ~/.bashrc
