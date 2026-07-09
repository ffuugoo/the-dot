# Dots ᠅

Personal dotfiles. Linked into `$HOME` by [`dots.sh`](dots.sh).

## Usage

```sh
./dots.sh                 # create symlinks (default action)
./dots.sh --dry-run       # print ln/mkdir/rm commands without running them
./dots.sh --print-config  # print resolved-path => destination map
```

Linking creates missing parent directories and replaces existing symlinks,
but does not overwrite existing files and directories.

## Configuration

[`dots.conf`](dots.conf) lists what gets linked, one directive per line:

```text
[tag] ! pattern => destination
```

`pattern` is a repo-relative glob of files to link or exclude. It is always required.

The rest are optional modifiers:

- `[tag]` enables directive on one OS only: `[macOS]` or `[Linux]`
- `!` excludes files matched by earlier directives
- `=> destination` specifies explicit target path

By default (without `=> destination`) a file links to the same relative path in `$HOME`:
`.zshrc` as `~/.zshrc`, `.config/zed` as `~/.config/zed`.

When the pattern is a glob or destination ends in `/`, destination is treated as a directory
and files are linked *inside* it.

Child matches exclude parent dir from the link set: if `.config/zed` is matched,
`.config` is ignored.
