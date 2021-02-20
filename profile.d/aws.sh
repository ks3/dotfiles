#!/bin/bash

function aws-default-profile() {
    if [[ -z $1 ]]; then
        if [[ -n $AWS_DEFAULT_PROFILE ]]; then
            echo "Default profile is currently $AWS_DEFAULT_PROFILE"
        else
            echo "Default profile is currently unset"
        fi
    elif [[ $1 == unset ]]; then
        unset AWS_DEFAULT_PROFILE
        rm -f ~/.aws/default-profile &>/dev/null
    else
        export AWS_DEFAULT_PROFILE="$1"
        echo "$1" > ~/.aws/default-profile
    fi
}

function aws-login() {
    aws sso login --profile "$1"
}

if [[ -e ~/.aws/default-profile ]]; then
    aws-default-profile "$(cat ~/.aws/default-profile)"
fi

