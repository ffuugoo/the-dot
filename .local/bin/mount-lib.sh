#!/bin/zsh

set -o rematch_pcre

function mount-info {
    declare mount=$1
    declare fields=( ${@:2} )

    declare info; info=( "${(f)$(diskutil info $mount)}" )

    for field in $fields; do
        match "^[[:space:]]*${(b)field}:[[:space:]]*(.*)[[:space:]]*$" $info
        echo ${match[1]}
    done
}

function mount-options {
    declare dev_or_mount=$1

    declare mount; mount=( "${(f)$(mount)}" )

    match "^(?:${(b)dev_or_mount} on .*|.* on ${(b)dev_or_mount}) \((.*)\)$" $mount
    echo ${(s:, :)match[1]}
}

function match {
    declare re=$1
    declare lines=( ${@:2} )

    for line in $lines; do
        if [[ $line =~ $re ]]; then
            return 0
        fi
    done

    return 1
}
