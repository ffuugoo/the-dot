#!/usr/bin/env python3

import argparse
import io
import os
import struct


def main():
    parser = argparse.ArgumentParser(
        prog = 'mdfx',
        description = 'tool to fix Sega Genesis ROM file checksum',
    )

    parser.add_argument(
        'roms',
        help = 'path to Sega Genesis ROM file', metavar = 'ROM',
        type = argparse.FileType('br+'), nargs = '+',
    )

    args = parser.parse_args()

    for rom in args.roms:
        stored_checksum = read_checksum(rom)
        calculated_checksum = calc_checksum(rom)

        if stored_checksum != calculated_checksum:
            print(f"Fixed checksum of {rom.name}")
            write_checksum(rom, calculated_checksum)


CHECKSUM_OFFSET = 0x18e
DATA_OFFSET = 0x200

def read_checksum(rom: io.BytesIO):
    rom.seek(CHECKSUM_OFFSET)
    return read_word(rom)

def calc_checksum(rom: io.BytesIO):
    rom.seek(DATA_OFFSET)

    checksum = 0

    for word in read_words(rom):
        checksum += word

    checksum &= 0xffff

    return checksum

def write_checksum(rom: io.BytesIO, checksum):
    rom.seek(CHECKSUM_OFFSET)
    write_word(rom, checksum)


FORMAT = struct.Struct('>H')

def read_word(io: io.BytesIO, format = FORMAT):
    return next(read_words(io, format))

def read_words(io: io.BytesIO, format = FORMAT):
    while bytes := io.read(format.size):
        bytes = bytes.ljust(format.size, b'\0')
        word, *_ = format.unpack(bytes)
        yield word

def write_word(io: io.BytesIO, word, format = FORMAT):
    io.write(format.pack(word))


if __name__ == "__main__":
    main()
