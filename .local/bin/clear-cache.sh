#!/bin/zsh

set -euo pipefail

function main {
    for target in ${@:-min}; do
        $target
    done
}

function all {
    zed
    sublime
    vscode
    sccache
    cargo
    npm
    zcomet
    zsh
}

function dev {
    sccache
    cargo
    npm
    zsh
}

function min {
    npm
    zsh
}

function zed {
    - rm -rf \
        ~/Library/Application\ Support/Zed/{db,languages,node,prettier} \
        ~/Library/Application\ Support/Zed/extensions/work \
        ~/Library/Caches/Zed \
        ~/.cache/zed
}

function sublime {
    sublime-text
    sublime-merge
}

function sublime-text {
    - rm -rf ~/Library/Caches/Sublime\ Text
}

function sublime-merge {
    - rm -rf ~/Library/Caches/Sublime\ Merge
}

function vscode {
    :
}

function sccache {
    - rm -rf ~/Library/Caches/Mozilla.sccache
}

function cargo {
    - rm -rf \
        ~/.cargo/registry \
        ~/.cargo/git
}

function npm {
    - rm -rf ~/.npm
}

function zcomet {
    - rm -rf ~/.zcomet
}

function zsh {
    - rm -rf \
        ~/.zcompdump \
        ~/.zcompdump.zwc \
        ~/.zcompcache \
        ~/.cache/fsh
}

function - {
    ${DRY_RUN:+echo} $@
}

main $@
