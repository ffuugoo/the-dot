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

        if [[ $ARC ]]; then
            archives[$file]=$ARC
        fi
    done

    if [[ $ARC ]] && (( ${#${archives[(Re)$ARC]}} == 0 )); then
        echo No ROMs or patches found in $ARC archive >&2
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
                echo Found multiple ROMs/patches in ${arc:t} archive: >&2
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
        process-rom $rom
    done
}

function process-rom {
    # ROM file
    declare rom=$1

    # Working directory
    declare root=${${archives[$rom]:-$rom}:h}

    # Extract/copy ROM into temporary directory
    if [[ ${archives[$rom]-} || $patches ]]; then
        # Create temporary directory
        declare tmp; tmp=$(mktemp -d $root/.romhack-XXX)

        # Automatically cleanup temporary directory
        trap 'rm -r $tmp' EXIT INT ERR

        # Extract/copy ROM
        if [[ ${archives[$rom]-} ]]; then
            arc-extract $arc $tmp $rom
        elif [[ $patches ]]; then
            - cp $rom $tmp
        fi

        # Update ROM path
        rom=$tmp/${${rom:t}%\~}

        # Rename ROM~ to ROM
        restore-file $rom
    fi

    # Path ROM
    for patch in $patches; do
        # Extract patch into temporary directory
        if [[ ${archives[$patch]-} ]]; then
            # Extract patch
            arc-extract ${archives[$patch]} $tmp $patch

            # Update patch path
            patch=${tmp[$root]}/${patch:t}
        fi

        # Patch ROM
        patch $rom $patch
    done

    # Apply cleanups/fixes
    case ${rom:e} in
        cue) cleanup-cue-file $rom ;;
        md) mdfx $rom ;;
    esac

    # Cleanup ROM name
    declare out; out=$(cleanup-rom-path $root/${rom:t})

    # Backup ROM as ROM~
    backup-file $out

    # Move/rename ROM
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

    # Backup file as file~
    for file in $files; do
        backup-file $dir/${file:t}
    done

    # Extract files from archive
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

function cleanup-rom-path {
    # ROM path
    declare rom=$1

    # Cleanup ROM path
    echo ${rom:h}/$(cleanup-rom-name ${rom:t:r}).${${rom:e}%\~}
}

function cleanup-rom-name {
    # ROM name
    declare rom=$1

    # Parse Disk/Track number
    declare disk; [[ $rom =~ (Disk [0-9]+) ]] && disk=$match
    declare track; [[ $rom =~ (Track [0-9]+) ]] && track=$match

    # Cleanup ROM name
    # - Replace `Title - Sub Title` with `Title. Sub Title`
    # - Remove trailing `(USA) (Virtual Console)` tags
    rom=$(echo $rom | sed -E -e 's| +- +|. |' -e 's| *\(.*\) *||')

    # Append Disk/Track number
    [[ $disk ]] && rom+=" ($disk)"
    [[ $track ]] && rom+=" ($track)"

    echo $rom
}

function cleanup-cue-file {
    # CUE file
    declare file=$1

    declare cue; cue=$(cat $file)

    backup-file $file
    touch $file

    for line in ${(f)cue}; do
        if [[ $line =~ 'FILE +"(.*)" +(.*)' ]]; then
            declare rom=${match[1]}
            declare type=${match[2]}

            rom=$(cleanup-rom-name ${rom:r})

            echo FILE \"$rom\" $type >> $file
        else
            echo $line >> $file
        fi
    done

    rm -f $file~
}

function backup-file {
    for file in $@; do
        if [[ -f $file && ! -e $file~ ]]; then
            - mv $file $file~
        fi
    done
}

function restore-file {
    for file in $@; do
        if [[ $file == *~ ]]; then
            - mv $file ${file%\~}
        fi
    done
}

function patch {
    declare rom=$1
    declare patch=$2

    case ${patch:e} in
        ips|bps)
            flips --apply --ignore-checksum $patch $rom $rom
        ;;

        *)
            echo Unrecognized patch $patch >&2
            return 6
        ;;
    esac
}

function unrar {
    - unrar $@
}

function 7zz {
    - 7zz $@
}

function flips {
    - flips $@
}

function mdfx {
    - mdfx.py $@
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
