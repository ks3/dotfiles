alias grep="/usr/bin/grep --color=auto"

if [[ $OSTYPE =~ ^darwin ]]; then
    alias ls="/bin/ls -G"
    alias flush-dns="sudo killall -HUP mDNSResponder && dscacheutil -flushcache"
else
    alias ls="/bin/ls --color=auto"
fi
