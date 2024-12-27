#!/bin/zsh

# AppleScript Quick Action
#
# on run {input, parameters}
#     try
#         set command to { "~/.local/bin/auto-patch.sh" }

#         repeat with romOrPatchFile in input
#             set end of command to quoted form of POSIX path of romOrPatchFile
#         end repeat
#
#         set defaultDelimiters to AppleScript's text item delimiters
#         set AppleScript's text item delimiters to " "
#         set command to command as text
#         set AppleScript's text item delimiters to defaultDelimiters
#
#         do shell script command
#     on error message number status
#         display dialog ¬
#             "auto-patch.sh returned status code " & status & return & return & message ¬
#             with title "Failed to patch ROM!" ¬
#             with icon caution
#     end try
# end run

set -euo pipefail

function main {
    declare rom=()
    declare patches=()
    declare -A archives=()

    scan $@
    validate
    apply
}

function scan {
    declare ARC=${ARC-}

    for file in $@
    do
        case ${file:e} in
            (nes|sfc|z64|gb|gbc|gba|md|32x|iso)(|~))
                rom+=( $file )
            ;;

            ips|bps)
                patches+=( $file )
            ;;

            zip|rar|7z)
                [[ $ARC ]] && continue

                ARC=$file scan ${(f)"$(arc-list $file)"}
            ;;

            *)
                [[ $ARC ]] && continue

                echo Unrecognized file $file >&2
                return 1
            ;;
        esac

        if [[ $ARC ]]
        then
            archives[$file]=$ARC
        fi
    done

    if [[ $ARC ]] && (( ${#${archives[(Re)$ARC]}} == 0 ))
    then
        echo No ROMs or patches found in $ARC archive >&2
        return 2
    fi
}

function validate {
    declare error=0

    if (( ${#rom} == 0 ))
    then
        echo No ROMs found >&2
        echo >&2

        error=1
    fi

    if (( ${#rom} > 1 ))
    then
        echo Found multiple ROMs: >&2
        printf '- %s\n' ${(f)"$(path $rom)"} >&2
        echo >&2

        error=1
    fi

    if (( ${#patches} == 0 ))
    then
        echo No patches found >&2
        echo >&2

        error=1
    fi

    for arc in ${(iu)archives[@]}
    do
        declare files=${#${archives[(Re)$arc]}}

        if (( files > 1 ))
        then
            (( error )) && echo >&2
            echo Found multiple ROMs or patches in ${arc:t} archive: >&2
            printf '- %s\n' ${(ki)archives[(Re)$arc]} >&2
            echo >&2

            error=1
        fi
    done

    if (( error ))
    then
        return 3
    fi
}

function apply {
    if [[ ${archives[$rom]-} ]]
    then
        declare root=${archives[$rom]:h}
    else
        declare root=${rom:h}
    fi

    declare tmp; tmp=$(mktemp -d $root/.auto-patch-XXX)

    if [[ ${archives[$rom]-} ]]
    then
        arc-extract ${archives[$rom]} $tmp $rom
    else
        - cp $rom $tmp
    fi

    declare rom=$tmp/${${rom%\~}:t}

    if [[ -f $rom~ ]]
    then
        - mv $rom~ $rom
    fi

    for patch in $patches
    do
        if [[ ${archives[$patch]-} ]]
        then
            arc-extract ${archives[$patch]} $tmp $patch

            patch=$tmp/${patch:t}
        fi

        patch $rom $patch
    done

    if [[ ${rom:e} == md ]]
    then
        mdfx $rom
    fi

    declare out=$root/${rom:t}

    if [[ -f $out && ! -e $out~ ]]
    then
        - mv $out $out~
    fi

    - cp $rom $root

    rm -rf $tmp
}

function arc-list {
    declare arc=$1

    case ${arc:e} in
        zip) zipinfo -1 $arc ;;
        rar) unrar lb $arc ;;
        7z)  7zz l -ba $arc | cut -c 54- ;;

        *)
            echo Unrecognized archive $arc >&2
            return 4
        ;;
    esac
}

function arc-extract {
    declare arc=$1
    declare dir=$2
    declare files=( ${@:3} )

    case ${arc:e} in
        zip) - unzip -ujd $dir $arc $files ;;
        rar) - unrar e $arc $files $dir/ ;;
        7z)  - 7zz e $arc -o$dir ${files/#/-i!} ;;

        *)
            echo Unrecognized archive $arc >&2
            return 5
        ;;
    esac
}

function patch {
    declare rom=$1
    declare patch=$2

    flips --apply --ignore-checksum $patch $rom $rom
}

function unrar {
    - /opt/homebrew/bin/unrar $@
}

function 7zz {
    - /opt/homebrew/bin/7zz $@
}

function flips {
    - ${self:h}/flips $@
}

function mdfx {
    - ${self:h}/mdfx.py $@
}

function path {
    for file in $@
    do
        if [[ ${archives[$file]-} ]]
        then
            echo ${archives[$file]:t}::$file
        else
            echo ${file:t}
        fi
    done
}

function - {
    ${DRY_RUN:+echo} $@
}

self=$0 main $@
