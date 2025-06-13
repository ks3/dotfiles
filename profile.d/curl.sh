#!/bin/bash

curlResolve() {
    declare host="localhost"
    declare port=80
    declare ip="127.0.0.1"

    if [[ -n $CURL_IP ]]; then
        ip="$CURL_IP"
    fi

    for arg in "$@"; do
        if [[ $arg =~ ^https?:\/\/ ]]; then
            host="$arg"
            host="${host#*//}"
            host="${host%%/*}"
            if [[ $host =~ : ]]; then
                port=$host
                port=${port##*:}
                host=${host%%:*}
            fi
        fi
    done

    curl --resolve "$host:$port:$ip" "$@"
}
