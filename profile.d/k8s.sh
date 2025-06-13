#!/usr/bin/env bash

kubeExec() {
    if [[ -z $1 ]]; then
        echo "Usage: kubeExec <pod-name>" >&2
        return
    fi
    local pod="$1"
    shift
    kubectl exec "$@" --stdin --tty "$pod" -- /bin/sh
}
