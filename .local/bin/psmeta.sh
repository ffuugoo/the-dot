#!/bin/zsh

set -euo pipefail

function main {
    $@
}

function id {
    declare serial=(
        SCPS SLPS SLPM
        SCUS SLUS
        SCES SLES
    )

    declare id=()

    for iso in $@; do
        id=( ${(f)$(iso-list $iso ${serial/%/*})} )

        if (( ${#id} == 0 )); then
            echo Game ID not found >&2
            return 1
        elif (( ${#id} > 1 )); then
            echo Multiple game IDs found: $id >&2
            return 2
        fi

        # echo ${${id//_/-}//./}
        echo $id
    done
}

function iso-list {
    declare iso=$1
    declare files=( ${@:2} )

    bsdtar --file $iso --list $files 2>/dev/null || :
}

function art {
    declare arc=$1
    declare dir=$2
    declare ids=( ${@:3} )

    case $arc in
        *.zip) unzip -ujd $dir $arc ${${ids/#/*}/%/*} ;;
        *.7z) 7zz e $arc -o$dir ${${ids/#/-ir!*}/%/*} ;;

        *)
            echo Unrecognized archive $arc >&2
            return 3
        ;;
    esac
}

function cfg {
    declare ids=( $@ )

    :
}

main $@
