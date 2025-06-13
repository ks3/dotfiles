#!/bin/bash

export DOCKER_SCAN_SUGGEST=false

if [[ $(uname -m) == arm64 ]]; then
    alias docker-amd64="DOCKER_DEFAULT_PLATFORM=linux/amd64 docker"
fi
