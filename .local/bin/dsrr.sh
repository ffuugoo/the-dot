#!/bin/zsh

set -euo pipefail -o nullglob

function main {
    declare self=${self:a}
    declare root=${self:h}

    TMP='' $@
}

function clean {
    declare mod=$1
    declare game=${2:-}

    remove-junk $mod

    if [[ $game ]]; then
        remove-untracked-dirs $mod $game
    fi
}

function scrub {
    declare mod=$1
    declare game=$2
    declare backup=${3:-}

    clean $mod $game

    BACKUP=${backup:a} remove-map-edits $mod
    BACKUP=${backup:a} remove-untracked-files $mod $game

    fix-giant-tree $mod $game
    find-missing-textures $mod $game
}

function remove-junk {
    declare mod=$1

    cd $mod

    - rm -rf \
        ModEngine2 \
        menu \
        msg

    - find . \
        -type f \
        \( \
            -iname '.DS_Store' -or \
            -iname '*.flver' -or \
            -iname '*.bak*' -or \
            -iname '*.prev*' -or \
            -iname '*.xml' -or \
            -iname '*Copy*' \
        \) \
        -delete

    cd -
}

function remove-map-edits {
    declare mod=$1

    cd $mod
    remove-or-backup \
        event \
        map/*/*.hkxbdt \
        map/*/*.hkxbhd \
        map/*/*.mcg \
        map/*/*.mcp \
        map/*/*.nvmbnd.dcx \
        map/*/*.nvmdump \
        map/*/*.arealoadlist \
        map/MapStudio* \
        param/GameParam
    cd -
}

function fix-giant-tree {
    declare mod=$1
    declare game=$2

    TMP=$(mktemp -d $root/.dsrr-XXX)
    trap 'rm -r $TMP' EXIT

    - bnd.py -x $game/map/m10/m10_0001.tpfbdt $TMP \
        \\m10_bg_giant_tree_n.tpf.dcx \
        \\m10_bg_giant_tree_s.tpf.dcx \
        \\m10_bg_giant_tree.tpf.dcx

    for file in $TMP/*; do
        - mv $file ${file#\\}
    done

    - bnd.py -a $mod/map/m10/m10_0001.tpfbdt $TMP/*
}

function find-missing-textures {
    declare mod=$1
    declare game=$2

    TMP=$(mktemp -d $root/.dsrr-XXX)
    trap 'rm -r $TMP' EXIT

    for mod_archive in $mod/map/*/m??_????.tpfbhd; do
        declare game_archive=${mod_archive/$mod/$game}

        if [[ ! -f $game_archive ]]; then
            continue
        fi

        list-textures $mod_archive > $TMP/dsrr.txt
        list-textures $game_archive > $TMP/dsr.txt

        declare missing=$(diff $TMP/dsrr.txt $TMP/dsr.txt)

        if [[ $missing ]]; then
            echo MISSING TEXTURES IN ${mod_archive#$mod/}
            echo $missing
            echo
        fi
    done
}

function list-textures {
    bnd.py -l $1 | sed -e 's/^\\//'
}

function remove-untracked-dirs {
    remove-untracked $1 $2 -type d
}

function remove-untracked-files {
    remove-untracked $1 $2 -type f
}

function remove-untracked {
    declare mod=$1
    declare game=$2
    declare args=( ${@:3} )

    declare untracked; untracked=( "${(f)$(find-untracked $mod $game $args)}" )

    if [[ $untracked ]]; then
        cd $mod
        remove-or-backup $untracked
        cd -
    fi
}

function find-untracked {
    declare mod=$1
    declare game=$2
    declare args=( ${@:3} )

    TMP=$(mktemp -d $root/.dsrr-XXX)
    trap 'rm -r $TMP' EXIT

    cd $mod
    declare dirs=( * )
    find $dirs $args > $TMP/dsrr.txt
    cd -

    cd $game
    declare dirs=( ${~${(j:|:)dirs}} )
    find $dirs $args > $TMP/dsr.txt
    cd -

    diff $TMP/dsr.txt $TMP/dsrr.txt
}

function diff {
    grep -v -Fxi -f $1 $2
}

function remove-or-backup {
    if [[ ${BACKUP:-} ]]; then
        backup $BACKUP ${SOURCE:-.} $@
    else
        - rm -rf $@
    fi
}

function backup {
    declare backup=${1:a}
    declare source=${2:a}
    declare items=( ${${@:3}:a} )

    for item in $items; do
        if [[ $item != $source/* ]]; then
            echo "$item is not under $source" >&2
            return 1
        fi

        declare target=${${item:h}/$source/$backup}

        - mkdir -p $target
        - mv $item $target
    done
}

function - {
    ${DRY_RUN:+echo} $@
}

self=$0 main $@
