if [[ -z $PS1 ]]; then
    return
fi

[[ -f ~/.bash_aliases ]]   && source ~/.bash_aliases
[[ -f ~/.bash_functions ]] && source ~/.bash_functions

pathmunge ~/.local/bin
pathmunge ~/bin
pathmunge /opt/macports/bin after
pathmunge /opt/macports/sbin after

if [[ -d ~/.profile.d ]]; then
    for s in ~/.profile.d/*.sh; do
        [[ -r $s ]] && source $s
    done
fi

unset PROMPT_COMMAND

export EDITOR="vim"
export LESS="RX"
export PS1="[\u@$(hostname -s | tr 'A-Z' 'a-z') \w]\\$ "
export QUOTING_STYLE="literal"

umask 0027
