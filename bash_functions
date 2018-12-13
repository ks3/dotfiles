function pathmunge() {
    local p="$1"
    local w="$2"

    if [[ :$PATH: =~ :$p: ]]; then
        return
    fi

    if [[ ! -d $p ]]; then
        return
    fi

    if [[ $w = after ]]; then
        PATH="$PATH:$p"
    else
        PATH="$p:$PATH"
    fi
    export PATH
}

function urlencode() {
    local in="${1}"
    local out="${2}"
    local force="${3}"
    local encoded=""

    local -i i=0
    while [[ $i -lt ${#in} ]]; do
        local char="${in:i:1}"
        if [[ ${char} =~ [a-zA-Z0-9.~_-] && -z ${force} ]]; then
            encoded="${encoded}${char}"
        else
            encoded="${encoded}$(printf '%%%02X' "'${char}")"
        fi
        ((i++))
    done

    if [[ -n ${out} ]]; then
        eval ${out}='${encoded}'
    else
        echo "${encoded}"
    fi
}

function urldecode() {
    local in="${1}"
    local out="${2}"
    local decoded=""

    in="${in//+/ }"
    decoded="$(printf '%b' "${in//%/\\x}")"

    if [[ -n ${out} ]]; then
        eval ${out}='${decoded}'
    else
        echo "${decoded}"
    fi
}
