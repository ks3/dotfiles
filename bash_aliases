alias grep="/usr/bin/grep --color=auto"
alias reset-workspace="aws-profile unset; cd ~; clear"

alias apu="aws-profile unset"
alias rw="reset-workspace"

if [[ $OSTYPE =~ ^darwin ]]; then
    alias ls="/bin/ls -G"
    alias flush-dns="sudo killall -HUP mDNSResponder && dscacheutil -flushcache"
else
    alias ls="/bin/ls --color=auto"
fi
