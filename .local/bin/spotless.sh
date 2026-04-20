#!/bin/zsh

set -euo pipefail -o nullglob

function main {
    for mount in /Volumes/*; do
        spotless $mount
    done
}

function spotless {
    declare mount=$1

    mdutil -i off -d $mount
    rm -rf $mount/.Spotlight-V100
}

function install {
    :
}

function uninstall {
    :
}

function plist {
    :
}

main $@
