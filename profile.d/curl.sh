function curl_resolve() {
    declare host
    declare port=80
    declare ip="127.0.0.1"

    if [[ -n $HOST_OVERRIDE ]]; then
        ip=$HOST_OVERRIDE
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

    curl --resolve $host:$port:$ip "$@"
}
