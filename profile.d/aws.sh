#!/bin/bash

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
        if [[ -n $AWS_DEFAULT_PROFILE ]]; then
            echo "Current profile is $AWS_DEFAULT_PROFILE"
        else
            echo "No profile is currently set"
        fi
    elif [[ $1 == unset ]]; then
        unset AWS_DEFAULT_PROFILE
    else
        export AWS_DEFAULT_PROFILE="$1"
    fi
}

function aws-login() {
    aws sso login --profile "$1"
}

if [[ -e ~/.aws/default-profile ]]; then
    aws-profile "$(cat ~/.aws/default-profile)"
fi

