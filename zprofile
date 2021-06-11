if [[ ! -z $TERM && $TERM != dumb && -z $STY && -z $TMUX ]]; then
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

if [[ -d ~/.profile.d ]]; then
    for s in ~/.profile.d/*.sh; do
        [[ -r $s ]] && source "$s"
    done
fi

