#!/bin/zsh

# AppleScript Quick Action
#
# on run {input, parameters}
#     try
#         set command to { "~/.local/bin/romhack.sh" }
#
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
#             "romhack.sh returned status code " & status & return & return & message ¬
#             with title "Failed to patch ROM!" ¬
#             with icon caution
#     end try
# end run

set -euo pipefail

function main {
    declare roms=()
    declare patches=()
    declare -A archives=()

    scan $@
    validate
    process
}

function scan {
    declare ARC=${ARC-}

    for file in $@; do
        case ${file:e} in
            (nes|sfc|z64|gb|gbc|gba|md|32x|cue|bin|iso)(|~))
                roms+=( $file )
            ;;

            ips|bps|ups|xdelta|delta|ppf)
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

        if [[ $ARC ]]; then
            archives[$file]=$ARC
        fi
    done

    if [[ $ARC ]] && (( ${#${archives[(Re)$ARC]}} == 0 )); then
        echo No ROMs or patches found in ${ARC:t} archive >&2
        return 2
    fi
}

function validate {
    declare error=0

    if (( ${#roms} == 0 )); then
        echo No ROMs found >&2
        echo >&2

        error=1
    fi

    if (( ${#patches} > 0 )); then

        if (( ${#roms} > 1 )); then
            echo Found multiple ROMs: >&2
            printf '- %s\n' ${(f)"$(path $roms)"} >&2
            echo >&2

            error=1
        fi

        for arc in ${(iu)archives[@]}; do
            declare files=${#${archives[(Re)$arc]}}

            if (( files > 1 )); then
                (( error )) && echo >&2
                echo Found multiple ROMs or patches in ${arc:t} archive: >&2
                printf '- %s\n' ${(ki)archives[(Re)$arc]} >&2
                echo >&2

                error=1
            fi
        done

    fi

    if (( error )); then
        return 3
    fi
}

function process {
    for rom in $roms; do
        TMP='' process-rom $rom
    done
}

function process-rom {
    declare rom=$1

    declare arc=${archives[$rom]-}
    declare root=${${arc:-$rom}:h}

    if [[ $arc || $patches ]]; then
        TMP=$(mktemp -d $root/.romhack-XXX)

        trap 'rm -r $TMP' EXIT INT ERR

        if [[ $arc ]]; then
            arc-extract $arc $TMP $rom
        elif [[ $patches ]]; then
            - cp $rom $TMP
        fi

        rom=$TMP/${rom:t}

        for patch in $patches; do
            declare arc=${archives[$patch]-}

            if [[ $arc ]]; then
                arc-extract $arc $TMP $patch
                patch=$TMP/${patch:t}
            fi

            patch $rom $patch
        done
    fi

    case ${rom:e} in
        cue) cleanup-cue-file $rom ;;
        md)  - mdfx.py $rom ;;
    esac

    declare out; out=$(cleanup-rom-path $root/${rom:t})

    backup-file $out
    - mv $rom $out
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

    backup-file $dir/${^files:t}

    case ${arc:e} in
        zip) - unzip -ujd $dir $arc ${(b)files} ;;
        rar) - unrar e $arc ${${files//'*'/'\*'}//'?'/'\?'} $dir/ ;;
        7z)  - 7zz e $arc -o$dir ${${files//'*'/'\*'}//'?'/'\?'} ;;

        *)
            echo Unrecognized archive $arc >&2
            return 5
        ;;
    esac
}

function patch {
    declare rom=$1
    declare patch=$2

    case ${patch:e} in
        ips|bps|ups)
            - flips --apply --ignore-checksum $patch $rom $rom
        ;;

        xdelta|delta|ppf)
            - multipatch --apply $patch $rom $rom
        ;;

        *)
            echo Unrecognized patch $patch >&2
            return 6
        ;;
    esac
}

function cleanup-cue-file {
    declare file=$1

    declare cue; cue=$(cat $file)

    backup-file $file
    touch $file

    for line in ${(f)cue}; do
        if [[ $line =~ 'FILE +"(.*)" +(.*)' ]]; then
            declare rom=${match[1]}
            declare type=${match[2]}

            rom=$(cleanup-rom-path $rom)

            echo FILE \"$rom\" $type >> $file
        else
            echo $line >> $file
        fi
    done

    rm -f $file~
}

function cleanup-rom-path {
    declare rom=$1

    declare dir=${${rom:h}:/./}
    declare ext=${rom:e}

    declare rom=${rom:t:r}

    echo ${dir}${dir:+/}$(cleanup-rom-name $rom)${ext:+.}${ext%\~}
}

function cleanup-rom-name {
    declare rom=$1

    declare tags=()

    [[ $rom =~ (Disk [0-9]+) ]] && tags+=( $match )
    [[ $rom =~ (Track [0-9]+) ]] && tags+=( $match )

    rom=$(echo $rom | cleanup-rom-name-impl)

    echo ${rom} \(${^tags}\)
}

function cleanup-rom-name-impl {
    sed -E \
        -e 's:^ +| +$::' \
        -e 's: +: :g' \
        -e 's:^The |, The::g' \
        -e 's: - :. :g' \
        -e 's:\(.*\)::g' \
        -e 's:(Disk|Track) [0-9]+::g' \
        -e 's: +: :g' \
        -e 's:^ +| +$::'
}

function backup-file {
    for file in $@; do
        if [[ -f $file && ! -e $file~ ]]; then
            - mv $file $file~
        fi
    done
}

function path {
    for file in $@; do
        if [[ ${archives[$file]-} ]]; then
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
