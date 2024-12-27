#!/bin/zsh

set -euo pipefail -o nullglob -o globdots -o re_match_pcre

function main {
    declare self=${self:A}
    declare repo=${self:h}

    declare DRY_RUN=${DRY_RUN:-}
    declare action=link-dotfiles

    for arg in $@; do
        case $arg in
            --dry-run) DRY_RUN=1 ;;
            --link-dotfiles|--link) action=link-dotfiles ;;
            --print-config|--print|--test) action=print-config ;;

            *)
                echo "Invalid argument $arg" >&2
                return 1
            ;;
        esac
    done

    declare dotfiles=()
    declare -A links=()

    parse-config
    $action
}

function parse-config {
    cd $repo
    trap 'cd -' EXIT

    if [[ ! -f the-dot.conf ]]; then
        echo "Config file ${repo/$HOME/~}/the-dot.conf does not exist" >&2
        return 1
    fi

    declare tags=()

    case $(uname) in
        Darwin) tags+=( macos ) ;;
        Linux) tags+=( linux ) ;;
    esac

    declare line=0

    for directive in "${(@f)$(< the-dot.conf)}"
    do
        (( line += 1 ))

        if [[ $directive =~ ^\s*$ ]]; then
            continue
        fi

        if [[ ! $directive =~ '^\s*(?:\[(.+?)\]\s*)?(!)?\s*(.+?)(?:\s*=>\s*(.+))?\s*$' ]]; then
            echo "Invalid config directive on line $line" >&2
            echo $directive >&2
            return 2
        fi

        declare tag=${match[1]:-}
        declare exclude=${match[2]:-}
        declare pattern=${match[3]:-}
        declare link=${match[4]:-}

        case ${tag:l} in
            ''|macos|linux) : ;;

            *)
                echo "Invalid config directive on line $line: invalid tag $tag" >&2
                return 3
            ;;
        esac

        if [[ $exclude && $link ]]; then
            echo "Invalid config directive on line $line: exclude pattern can't specify link-path" >&2
            echo $directive >&2
            return 4
        fi

        if [[ $pattern == /* ]]; then
            echo "Invalid config directive on line $line: pattern can't be absolute" >&2
            echo $directive >&2
            return 5
        fi

        if [[ ${pattern:A} != $repo/* ]]; then
            echo "Invalid config directive on line $line: pattern does not point within repo" >&2
            echo $directive >&2
            return 6
        fi

        if [[ $tag && ! ${tags[(r)${tag:l}]:-} ]]; then
            continue
        fi

        declare matched=( ${~pattern} )

        if (( ${#matched} == 0 )); then
            echo "Invalid config directive on line $line: pattern did not match any files" >&2
            echo $directive >&2
            return 7
        fi

        for dotfile in $matched; do
            if [[ $exclude ]]; then
                dotfiles=( ${dotfiles:#$dotfile} )
                unset links\[$dotfile\]
                continue
            fi

            case ${dotfile:t} in
                .DS_Store|.git|.gitmodules) continue ;;
            esac

            if [[ ${dotfile:t} == .gitignore && ${dotfile:h} != '' ]]; then
                continue
            fi

            if [[ ! ${dotfiles[(r)$dotfile]:-} ]]; then
                dotfiles+=( $dotfile )
            fi

            if [[ $link ]]; then
                if [[ $pattern == *'*'* || $link == */ ]]; then
                    links[$dotfile]=${link%%/}/${dotfile:t}
                else
                    links[$dotfile]=$link
                fi
            else
                unset links\[$dotfile\]
            fi
        done

        for dotfile in $dotfiles; do
            if [[ ${dotfiles[(r)$dotfile/*]:-} ]]; then
                dotfiles=( ${dotfiles:#$dotfile} )
                unset links\[$dotfile\]
            fi
        done
    done
}

function link-dotfiles {
    for dotfile in $dotfiles; do
        declare link=${links[$dotfile]:-$dotfile}

        if [[ $link != /* ]]; then
            link=~/$link
        fi

        if [[ -L $link && ${link:A} == $repo/$dotfile ]]; then
            continue
        fi

        if [[ ! -e ${link:h} ]]; then
            - mkdir -p ${link:h}
        elif [[ ! -d ${link:h} ]]; then
            echo "${link:h} already exists and is not a directory!" >&2
            return 8
        fi

        if [[ -L $link ]]; then
            - rm $link
        elif [[ -e $link ]]; then
            echo "$link already exists and is not a symlink!" >&2
            return 9
        fi

        - ln -s $repo/$dotfile $link
    done
}

function print-config {
    for dotfile in $dotfiles
    do
        echo $dotfile ${links[$dotfile]:+'=>'} ${links[$dotfile]:-}
    done
}

function - {
    ${DRY_RUN:+echo} $@
}

self=$0 main $@
