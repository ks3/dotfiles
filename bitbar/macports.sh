#!/bin/bash

# ensure user directory exists
[[ -e ~/.macports ]] || mkdir ~/.macports

# ensure settings file exists
if [[ ! -e ~/.macports/settings.sh ]]; then
    cat > ~/.macports/settings.sh <<-_EOF_
		#!/bin/bash

		declare -r PORT="port"
		declare -r CANARY="${HOME}/.macports/canary"
		declare -r INTERVAL=3600 # how often to sync, in seconds

		declare -r OK="MacPorts: OK"
		declare -r UPDATE="MacPorts: Updates"
		_EOF_
fi

# source settings file
[[ -e ~/.macports/settings.sh ]] && source ~/.macports/settings.sh

declare -i CURRENT_TS=$(date +%s)
declare -i FILE_TS=0
declare -i AGE


if [[ -n $1 && $1 == upgrade ]]; then
    sudo port upgrade outdated
    exit
fi

if [[ -f ${CANARY} ]]; then
    FILE_TS=$(date -r ${CANARY} +%s)
fi

AGE=$((${CURRENT_TS} - ${FILE_TS}))


if [[ ${AGE} -gt ${INTERVAL} ]]; then
    sudo ${PORT} sync &>/dev/null && touch ${CANARY}
fi

declare -i NUM_OUTDATED=$(${PORT} -q outdated | wc -l)
if [[ ${NUM_OUTDATED} -gt 0 ]]; then
    echo "${UPDATE}"
    echo "---"
    echo "${NUM_OUTDATED} ports have updates | bash='$0' param1=upgrade terminal=false refresh=true"
else
    echo "${OK}"
fi
