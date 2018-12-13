[[ -f ~/.bashrc ]] && source ~/.bashrc

if [[ $TERM != dumb && ! $STY && ! $TMUX ]]; then
    # use tmux by default
    multiplexer="tmux"
    multiplexer_args=""

    if [[ $SSH_CLIENT ]]; then
        # but use screen in SSH sessions
        multiplexer="screen"
        multiplexer_args="-xRR"
    fi

    hash $multiplexer &>/dev/null && exec $multiplexer $multiplexer_args
fi
