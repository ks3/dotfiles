alias grep="/usr/bin/grep --color=auto"

if [[ $OSTYPE =~ ^darwin ]]; then
    alias ls="/bin/ls -F"
    alias flush-dns="unbound-control -q flush_zone . && sudo killall -HUP mDNSResponder && dscacheutil -flushcache"
else
    alias ls="/bin/ls --color=auto"
fi
