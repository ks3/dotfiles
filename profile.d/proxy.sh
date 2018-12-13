# helper functions for managing proxy settings

function proxy_on() {
    local exclude='localhost,127.0.0.1'

    local server
    local port

    echo -n 'Server: '
    read server
    echo -n 'Port: '
    read port

    local username
    local password
    local pre

    echo -n 'Username: '
    read username
    if [[ $username != '' ]]; then
        echo -n 'Password: '
        read -es password
        echo

        urlencode "$username" username
        urlencode "$password" password
        pre="$username:$password@"
    fi

    local protocol
    for protocol in http https ftp rsync; do
        export ${protocol}_proxy="http://$pre$server:$port/"
    done
}

function proxy_off() {
    local protocol
    for protocol in http https ftp rsync; do
        unset ${protocol}_proxy
    done
}
