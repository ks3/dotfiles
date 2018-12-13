#!/bin/bash

# add to sudoers config
#  %admin ALL=(ALL) NOPASSWD: /opt/macports/sbin/openconnect hostname -u username --passwd-on-stdin --background
#  %admin ALL=(ALL) NOPASSWD: /usr/bin/pkill -INT -f /opt/macports/sbin/openconnect hostname

# needed for urlencode / urldecode
source ~/.bash_functions


declare -a CONNECTIONS
declare -a NAMES

declare BACKEND
declare HOST
declare USER


function FillConnectionDetails() {
    declare name="$1"
    declare data

    BACKEND=
    HOST=
    USER=

    for data in "${CONNECTIONS[@]}"; do
        if [[ ${data%%|*} == $name ]]; then
            # 1st field is connection name, strip it
            data="${data#*|}"

            # 2nd field is backend
            BACKEND="${data%%|*}"
            data="${data#*|}"

            # 3rd field is host
            HOST="${data%%|*}"
            data="${data#*|}"

            # 4th field is user
            USER="${data%%|*}"
        fi
    done
}

function GetConnectionNames() {
    declare data
    NAMES=()

    for data in "${CONNECTIONS[@]}"; do
        NAMES+=("${data%%|*}")
    done
}

function GetPassword() {
    declare -r DESC="Please enter the password for user ${USER} on host ${HOST}"
    declare -r PROMPT="Password:"

    echo -en "SETDESC ${DESC}\nSETPROMPT ${PROMPT}\nGETPIN\n" | ${PINENTRY} | awk '/^D / {print $2}'
}

function IsAnyConnectionActive() {
    declare name
    for name in "${NAMES[@]}"; do
        IsConnectionActive "${name}"
        [[ $? -eq 0 ]] && return 0
    done

    return 1
}

function IsConnectionActive() {
    FillConnectionDetails "$1"

    if [[ $BACKEND == openconnect ]]; then
        pgrep -q -f "${OPENCONNECT} ${HOST}"
        return $?
    elif [[ $BACKEND == openvpn ]]; then
        pgrep -q -f "${OPENVPN} ${HOST}/${USER}.conf"
        return $?
    else
        return 255
    fi

    return 1
}


# ensure user directory exists
[[ -e ~/.vpn ]] || mkdir ~/.vpn
cd ~/.vpn || exit 255

# ensure settings file exists
if [[ ! -e ~/.vpn/settings.sh ]]; then
    cat > ~/.vpn/settings.sh <<-_EOF_
		#!/bin/bash

		declare -r OPENCONNECT='openconnect'
		declare -r OPENVPN='openvpn'
		declare -r CONNECTED='VPN | color=black'
		declare -r DISCONNECTED='VPN | color=#cccccc'

		CONNECTIONS+=('Cisco Connection|openconnect|host|user')
		CONNECTIONS+=('OpenVPN Connection|openvpn|host|user')
		_EOF_
fi

# source settings file
[[ -e ~/.vpn/settings.sh ]] && source ~/.vpn/settings.sh



GetConnectionNames

if [[ -n $1 && -n $2 ]]; then
    connection="$(urldecode "$2")"
    FillConnectionDetails "${connection}"
    if [[ -z $BACKEND || -z $HOST || -z $USER ]]; then
        osascript \
            -e 'on run(argv)' \
            -e 'tell application "System Events"' \
            -e '  display dialog item 1 of argv buttons {"OK"} with icon caution with title "No such connection"' \
            -e '  return' \
            -e 'end tell' \
            -e 'end' \
            -- "Connection ${connection} not found"
        exit 255
    fi

    case "$1" in
        connect)
            if [[ $BACKEND == openconnect ]]; then
                GetPassword "${USER}" | sudo ${OPENCONNECT} ${HOST} -u "${USER}" --passwd-on-stdin --background
            elif [[ $BACKEND == openvpn ]]; then
                (echo "${USER}"; GetPassword "${USER}") | sudo ${OPENVPN} ${HOST}/${USER}.conf
            fi
            ;;
        disconnect)
            if [[ $BACKEND == openconnect ]]; then
                sudo pkill -INT -f "${OPENCONNECT} ${HOST}"
            elif [[ $BACKEND == openvpn ]]; then
                sudo pkill -INT -f "${OPENVPN} ${HOST}/${USER}.conf"
            fi
            ;;
    esac

    exit
fi


if IsAnyConnectionActive; then
    echo "${CONNECTED}"
else
    echo "${DISCONNECTED}"
fi

echo '---'
for connection in "${NAMES[@]}"; do
    connection_arg="$(urlencode "${connection}")"

    if IsConnectionActive "${connection}"; then
        echo "Disconnect $connection | bash='$0' param1=disconnect param2='${connection_arg}' terminal=false refresh=true"
    else
        echo "Connect $connection | bash='$0' param1=connect param2='${connection_arg}' terminal=false refresh=true"
    fi
done
