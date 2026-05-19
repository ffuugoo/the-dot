#!/bin/zsh

set -euo pipefail -o nullglob

function main {
    declare root=${self:a:h}

    declare output=''
    declare manpages=()

    if (( $# == 1 )); then
        output=''
        manpages=( $@ )
    elif (( $# >= 2 )); then
        output=$1
        manpages=( ${@:2} )
    else
        output=$root
        manpages=( /usr/share/man/man1/zsh*(:t:r) )
        manpages=( ${manpages:#zshall} )
    fi

    if [[ ! $output ]]; then
        render $manpages
    else
        mkdir -p $output

        for manpage in $manpages; do
            render $manpage > $output/$manpage.txt
        done
    fi
}

function render {
    MANWIDTH=100 man $@ | col -bx
}

self=$0 main $@
