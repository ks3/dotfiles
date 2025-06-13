function mkcd() {
    local d="$1"
    if [[ -z $d || -e $d ]]; then
        echo "Usage: mkcd <new-directory>" >&2
        return 1
    fi
    mkdir "$d" && cd "$d"
}

function pathmunge() {
    local p="$1"
    local w="$2"

    # do nothing if given path doesn't exist
    if [[ ! -d $p ]]; then
        return
    fi

    # remove path if it already exists so that we can change it's priority
    if [[ :$PATH: =~ :$p: ]]; then
        local t=":$PATH:"
        t="${t//$p:}"
        t="${t#:}"
        t="${t%:}"
        PATH="$t"
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
