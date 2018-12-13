alias grep="/usr/bin/grep --color=auto"

if [[ $OSTYPE =~ ^darwin ]]; then
    alias ls="/bin/ls -G"
else
    alias ls="/bin/ls --color=auto"
fi
