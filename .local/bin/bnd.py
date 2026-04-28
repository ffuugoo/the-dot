#!/usr/bin/env python3

import argparse
import contextlib
import pathlib
import shutil
import struct
import typing


def main():
    parser = argparse.ArgumentParser(
        prog = 'bnd',
        description = 'tool to manipulate BND archives',
    )

    command = parser.add_mutually_exclusive_group()
    command.add_argument('-l', '--list',    help = 'list files in the archive',        action = 'store_true')
    command.add_argument('-x', '--extract', help = 'extract files from the archive', action = 'store_true')
    command.add_argument('-a', '--append',  help = 'append files to the archive',    action = 'store_true')

    parser.add_argument('archive', metavar = 'ARCHIVE', help = 'path to the BND archive',                             nargs = '?', type = pathlib.Path)
    parser.add_argument('output',  metavar = 'OUTPUT',  help = 'directory to extract files to',                       nargs = '?', type = pathlib.Path)
    parser.add_argument('files',   metavar = 'FILE',    help = 'list of files to extract from/append to the archive', nargs = '*', type = pathlib.Path)

    args = parser.parse_args()

    if not (args.list or args.extract or args.append) and args.archive:
        args.list = True

    if args.list:
        if not args.archive:
            raise Error('ARCHIVE argument is required')

        list_files(args.archive)
    elif args.extract:
        if not (args.archive and args.output and args.files):
            raise Error('ARCHIVE, OUTPUT and FILE arguments are required')

        extract(args.archive, args.output, args.files)
    elif args.append:
        if not (args.archive and (args.output or args.files)):
            raise Error('ARCHIVE and FILE arguments are required')

        append(args.archive, [args.output] + args.files)
    else:
        parser.print_help()


def list_files(bnd_path: pathlib.Path):
    header, _ = bnd(bnd_path)

    for record in read_bhf(header):
        print(record['filename'])

def extract(bnd_path: pathlib.Path, output: pathlib.Path, filenames: list[pathlib.Path]):
    header, data = bnd(bnd_path)
    records = { record['filename']: record for record in read_bhf(header) }

    with data.open('br') as data:
        for filename in map(str, filenames):
            if filename not in records:
                raise Error(f"file {filename} not found in {header}")

            record = records[filename]

            copy_from_stream_into_file(
                FileView(data, record['offset'], record['size']),
                output / filename,
            )

def append(bnd_path: pathlib.Path, files: list[pathlib.Path]):
    header, data = bnd(bnd_path)
    records = { record['filename']: record for record in read_bhf(header) }

    with data.open('ba') as data:
        for file in files:
            if file.name in records:
                raise Error(f"file {file.name} already exists in {header}")

            records[file.name] = {
                'filename': file.name,
                'offset': data.tell(),
                'size': file.stat().st_size,
            }

            copy_from_file_into_stream(file, data)

    write_bhf(header, list(records.values()))


def bnd(path: pathlib.Path):
    HEADER_EXT = '.tpfbhd'
    DATA_EXT = '.tpfbdt'

    if path.suffix == HEADER_EXT:
        header = path
        data = path.with_suffix(DATA_EXT)
    elif path.suffix == DATA_EXT:
        header = path.with_suffix(HEADER_EXT)
        data = path
    else:
        raise Error(f"BND archive path {path} has invalid file extension, valid extensions are {HEADER_EXT} and {DATA_EXT}")

    if not header.is_file():
        raise Error(f"BND header file {header} does not exist or is not a file")

    if not data.is_file():
        raise Error(f"BND data file {data} does not exist or is not a file")

    return (header, data)

def read_bhf(path: pathlib.Path):
    with path.open('br') as file:
        records = read_bhf_header(file)

        for record in read_bhf_records(file, records):
            yield record

def write_bhf(path: pathlib.Path, records: list[typing.Any]):
    with path.open('bw') as file:
        write_bhf_header(file, len(records))
        write_bhf_records(file, records)
        write_bhf_filenames(file, map(lambda record: record['filename'], records))

def copy_from_stream_into_file(stream: typing.BinaryIO, path: pathlib.Path):
    with open(path, 'bw') as file:
        shutil.copyfileobj(stream, file)

def copy_from_file_into_stream(path: pathlib.Path, stream: typing.BinaryIO):
    with path.open('br') as file:
        shutil.copyfileobj(file, stream)


BHF_HEADER = struct.Struct('< 12s 3i 8s')

BHF_MAGIC = b'BHF307D7R6\x00\x00'
BHF_VERSION = (0x74, 0x54)
BHF_NULL = 0x00
BHF_PADDING = b'\x00' * 8

BHF_RECORD = struct.Struct('< 6i')

BHF_SEPARATOR = 0x40


def read_bhf_header(file: typing.BinaryIO) -> int:
    magic, version, records, null, padding = BHF_HEADER.unpack(file.read(BHF_HEADER.size))

    assert magic == BHF_MAGIC
    assert version in BHF_VERSION
    assert null == BHF_NULL
    assert padding == BHF_PADDING

    return records

def read_bhf_records(file: typing.BinaryIO, records: int):
    for _ in range(records):
        separator, size, offset, id, filename_offset, _size = BHF_RECORD.unpack(file.read(BHF_RECORD.size))

        assert separator == BHF_SEPARATOR
        assert size == _size

        record = {
            'id': id,
            'filename': read_bhf_filename(file, filename_offset),
            'offset': offset,
            'size': size,
        }

        yield record

def read_bhf_filename(file: typing.BinaryIO, offset: int):
    with seek(file, offset):
        filename = read_null_terminated_string(file)
        assert filename
        return filename

def write_bhf_header(file: typing.BinaryIO, records: int):
    file.write(BHF_HEADER.pack(
        BHF_MAGIC,
        BHF_VERSION[0],
        records,
        BHF_NULL,
        BHF_PADDING,
    ))

def write_bhf_records(file: typing.BinaryIO, records: list[typing.Any]):
    header_size = BHF_HEADER.size
    records_size = BHF_RECORD.size * len(records)

    filename_offset = header_size + records_size

    for id, record in enumerate(records):
        file.write(BHF_RECORD.pack(
            BHF_SEPARATOR,
            record['size'],
            record['offset'],
            id,
            filename_offset,
            record['size'],
        ))

        filename_offset += len(record['filename']) + 1

def write_bhf_filenames(file: typing.BinaryIO, filenames: typing.Iterable[str]):
    for filename in filenames:
        file.write(filename.encode('ascii') + b'\x00')


class FileView:
    def __init__(self, file: typing.BinaryIO, offset: int, size: int):
        assert offset >= 0
        assert size >= 0

        file.seek(offset)

        self.file = file
        self.size = size

    def read(self, size = -1):
        if size < 0:
            size = self.size

        bytes = self.file.read(size)
        self.size -= len(bytes)

        return bytes

    def close(self):
        pass

@contextlib.contextmanager
def seek(file: typing.BinaryIO, offset: int):
    current_offset = file.tell()

    try:
        file.seek(offset)
        yield file
    finally:
        file.seek(current_offset)

def read_null_terminated_string(file: typing.BinaryIO):
    bytes = bytearray()

    while (byte := file.read(1)) and byte != b'\x00':
        bytes.extend(byte)

    return bytes.decode()


class Error(Exception):
    pass


if __name__ == '__main__':
    main()
