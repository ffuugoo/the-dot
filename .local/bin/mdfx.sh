#!/bin/zsh

function read-checksum {
    declare rom=$1

    declare checksum high low bytes

    bytes=$(head --bytes $(( 0x18e + 2 )) $rom | tail --bytes 2)

    printf -v high %d \'${bytes[1]}
    printf -v low %d \'${bytes[2]}

    (( checksum = high << 8 | low ))

    echo $checksum
}

function calc-checksum {
    declare rom=$1

    declare bytes high low checksum=0

    bytes=$(tail --bytes +$(( 0x200 + 1 )) $rom)
    bytes=( $(printf '%d\n' ${${(s::)bytes}/#/\'}) )

    for (( idx = 0; idx < ${#bytes}; idx++ ))
    do
        (( high = bytes[idx] )) || :
        (( low = bytes[idx + 1] )) || :
        (( checksum += high << 8 | low )) || :
    done

    (( checksum &= 0xffff )) || :

    echo $checksum
}

function write-checksum {
    declare rom=$1
    declare checksum=$2

    :
}


function seek {
    declare fd=$1
    declare pos=$2

    declare null

    IFS= read -r -u $fd -k $pos -d '' null
}

function read-word {
    declare fd=$1
    declare out=$2

    declare high low

    read-byte $fd high
    read-byte $fd low

    (( $out = high << 8 | low ))
}

function read-byte {
    declare fd=$1
    declare out=$2

    IFS= read -r -u $fd -k 1 -d '' $out
    printf -v $out %d \'${(P)out}
}
