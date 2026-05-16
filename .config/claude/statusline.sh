#!/bin/zsh

set -euo pipefail

function main {
    declare input=$(cat)

    declare context session session_reset weekly weekly_reset
    context=$(json $input .context_window.used_percentage)
    session=$(json $input .rate_limits.five_hour.used_percentage)
    session_reset=$(json $input .rate_limits.five_hour.resets_at)
    weekly=$(json $input .rate_limits.seven_day.used_percentage)
    weekly_reset=$(json $input .rate_limits.seven_day.resets_at)

    context=$(round $context)
    session=$(round $session)
    session_reset="$(format-date-time $session_reset)"
    weekly=$(round $weekly)
    weekly_reset="$(format-date-time $weekly_reset)"

    echo "context: $context% | session: $session% [$session_reset] | week: $weekly% [$weekly_reset]"
}

function json {
    declare json=$1
    declare expr=$2

    jq -r "$expr // empty" <<< $json
}

function round {
    printf "%.0f" $1
}

function format-date-time {
    declare ts=$1

    echo $(format-date $ts) at $(date -r $ts +%H:%M)
}

function format-date {
    declare ts=$1

    declare today_epoch reset_epoch delta_days
    today_epoch=$(date -v0H -v0M -v0S +%s)
    reset_epoch=$(date -r $ts -v0H -v0M -v0S +%s)
    delta_days=$(( (reset_epoch - today_epoch) / 86400 ))

    case $delta_days in
        -*)            echo - ;;
        0)             echo today ;;
        1)             echo tomorrow ;;
        [2-6])         date -r $ts +%A ;;
        *)             date -r $ts +%d.%m ;;
    esac
}

main $@
