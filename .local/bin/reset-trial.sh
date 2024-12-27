#!/bin/zsh

set -euo pipefail

function all {
    better-zip
}

function better-zip {
    defaults write com.macitbetter.betterzip TableColumnSorter5.0 -float "$(date +%s)"
    rm -f ~/Library/Application\ Support/.mibprofile
}

function crossover {
    defaults write com.codeweavers.CrossOver FirstRunDate -date "$(date +%Y-%m-%dT%TZ)"

    for bottle in ~/Library/Application\ Support/CrossOver/Bottles/*
    do
        rm -f $bottle/.update-timestamp

        cp $bottle/system.reg{,~}

        sed -i \
            -E '/^\[Software\\\\CodeWeavers\\\\CrossOver\\\\/,/^\[/ { /^\[Software\\\\CodeWeavers\\\\CrossOver\\\\/ d; /^\[/! d; }' \
            $bottle/system.reg
    done
}

if (( $# ))
then
    $@
else
    all
fi
