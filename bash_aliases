alias ffuf="ffuf -c -ic"
alias grep="/usr/bin/grep --color=auto"

alias reset-workspace="awsProfile unset; cd ~; clear"
alias apu="awsProfile unset"
alias rw="reset-workspace"

if [[ ! $OSTYPE =~ ^darwin ]]; then
    alias ls="/bin/ls --color=auto"
fi

alias obsidian-docs="cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/Documents"
alias noteplan-docs="cd ~/Library/Containers/co.noteplan.NotePlan3/Data/Library/Application\ Support/co.noteplan.NotePlan3"
alias work="cd ~/Documents/Active"

alias serve="python3 -m http.server --bind 127.0.0.1"

#alias butane='docker run --rm --interactive       \
#              --security-opt label=disable        \
#              --volume ${PWD}:/pwd --workdir /pwd \
#              quay.io/coreos/butane:release'

alias htb="cd ~/Documents/Active/htb"
