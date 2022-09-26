#!/bin/bash

export AWS_PAGER="less -FRX"

function aws-default-profile() {
    if [[ -z $1 ]]; then
        if [[ -e ~/.aws/default-profile ]]; then
            echo "Default profile is $(cat ~/.aws/default-profile)"
        else
            echo "No default profile is set"
        fi
    elif [[ $1 == unset ]]; then
        rm -f ~/.aws/default-profile &>/dev/null
    else
        echo "$1" > ~/.aws/default-profile
    fi
}

function aws-profile() {
    if [[ -z $1 ]]; then
        if [[ -n $AWS_PROFILE ]]; then
            echo "Current profile is $AWS_PROFILE"
        else
            echo "No profile is currently set"
        fi
    elif [[ $1 == unset ]]; then
        unset AWS_PROFILE
    else
        export AWS_PROFILE="$1"
    fi
}

function aws-profiles() {
    grep -Ev '^\s*#' ~/.aws/config | \
        grep -Eo 'profile [^]]+' | \
        awk '{print $2}' | \
        sort
}

function aws-login() {
    aws sso login --profile "$1"
}

function ssm-login() {
    local user='ec2-user'
    [[ $1 == ingest.lungmap.net ]] && user='ubuntu'
    ssm-session -u "$user" "$@"
}

if [[ -e ~/.aws/default-profile ]]; then
    aws-profile "$(cat ~/.aws/default-profile)"
fi

alias s3-sync="aws s3 sync --exclude '.git*'"
alias ssm-sessions="ssm-session -l"
