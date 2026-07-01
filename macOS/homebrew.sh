#!/bin/zsh

set -euo pipefail

function main {
    declare root=${self:a:h}

    sync-list $root/homebrew-formulae.txt --formulae --full-name --installed-on-request
    sync-list $root/homebrew-casks.txt --casks
}

function sync-list {
    declare file=$1
    declare brew=( ${@:2} )

    declare packages=( $(brew list $brew) )
    declare list=( $(cat $file | sed 's/#.*//') )

    declare installed=( ${packages:#(${~${(j:|:)list}})} )

    if [[ $installed ]]; then
        printf '%s\n' '' $installed >> $file
    fi

    declare removed=( ${list:#(${~${(j:|:)packages}})} )

    if [[ $removed ]]; then
        sed -E -e "/^(${(j:|:)removed})/s/^/# /" -i '' $file
    fi
}

self=$0 main $@
