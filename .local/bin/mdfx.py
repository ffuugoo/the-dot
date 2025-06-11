#!/usr/bin/env python3

import argparse
import struct
import typing


def main():
    parser = argparse.ArgumentParser(
        prog = 'mdfx', description = 'tool to fix Sega Genesis ROM file checksum',
    )

    parser.add_argument(
        'roms',
        metavar = 'ROM', help = 'path to Sega Genesis ROM file', nargs = '+',
        type = argparse.FileType('br+'),
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

def read_checksum(rom: typing.BinaryIO):
    rom.seek(CHECKSUM_OFFSET)
    return read_word(rom)

def calc_checksum(rom: typing.BinaryIO):
    rom.seek(DATA_OFFSET)

    checksum = 0

    for word in read_words(rom):
        checksum += word

    checksum &= 0xffff

    return checksum

def write_checksum(rom: typing.BinaryIO, checksum: int):
    rom.seek(CHECKSUM_OFFSET)
    write_word(rom, checksum)


WORD = struct.Struct('>H')

def read_word(io: typing.BinaryIO):
    return next(read_words(io))

def read_words(io: typing.BinaryIO):
    while bytes := io.read(WORD.size):
        word, *_ = WORD.unpack(bytes.ljust(WORD.size, b'\0'))
        yield word

def write_word(io: typing.BinaryIO, word: int):
    io.write(WORD.pack(word))


if __name__ == '__main__':
    main()
