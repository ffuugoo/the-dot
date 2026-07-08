---
name: docs
description: >-
  Use when looking up reference documentation for installed tools, languages,
  libraries, or services, including Zed, Sublime Text, Sublime Merge, Ghostty,
  GitHub, Rust, rust-analyzer, and Acorn. Covers manpages, web-hosted and
  GitHub-hosted docs.
---

# Docs 👩‍⚕️

How to fetch documentation from different sources.

## Manpages

Read local manpages with `man`. Set `MANWIDTH` for wider output and pipe through `col -bx`
to strip backspace overstrike.

```zsh
MANWIDTH=100 man <page> | col -bx
```

## Web Pages

Prefer `WebFetch` tool when available, it handles HTML-to-text conversion and follows redirects.
Otherwise fallback to `curl`. If needed, convert HTML to GitHub-flavored Markdown with `pandoc`.

```zsh
curl -sL <url> | pandoc --from html --to gfm --wrap none
```

## GitHub-Hosted Docs

Use `gh api` to browse files and directories in a remote repository without cloning it locally.

List single directory contents:

```zsh
gh api repos/<owner>/<repo>/contents/<dir> --jq '.[].path'
```

Recursively scan the whole file tree:

```zsh
gh api repos/<owner>/<repo>/git/trees/HEAD?recursive=1 \
  --jq '.tree[] | select(.path | test("^docs/.*\\.mdx?$")) | .path'
```

Read a single file as raw content:

```zsh
gh api repos/<owner>/<repo>/contents/<file> \
  -H 'Accept: application/vnd.github.raw'
```

Or fetch raw URL directly. Raw URLs avoid base64 decoding and rate-limit weight of API calls.

```zsh
curl -sL https://raw.githubusercontent.com/<owner>/<repo>/HEAD/<file>
```


## Reference Links

Where to find documentation for specific tools, languages, and services.

### Zed

- [Docs](https://github.com/zed-industries/zed/tree/main/docs/src)
- [Index](https://github.com/zed-industries/zed/blob/main/docs/src/SUMMARY.md)

### Sublime Text

- [Docs](https://www.sublimetext.com/docs/)

- [Community Docs](https://github.com/sublimetext-io/docs.sublimetext.io/tree/master/docs)
- [Community Docs Index](https://github.com/sublimetext-io/docs.sublimetext.io/blob/master/docs/.vitepress/config.ts)

### Sublime Merge

- [Docs](https://www.sublimemerge.com/docs/)

### Ghostty

- `ghostty(1)` and `ghostty(5)` manpages

- [Docs](https://github.com/ghostty-org/website/tree/main/docs)
- [Index](https://github.com/ghostty-org/website/blob/main/docs/nav.json)

### GitHub

- [Docs](https://docs.github.com/llms.txt)

### Rust

- [Rust Reference](https://github.com/rust-lang/reference/tree/master/src)
- [Rust Reference Index](https://github.com/rust-lang/reference/blob/master/src/SUMMARY.md)

- [Rustonomicon](https://github.com/rust-lang/nomicon/tree/master/src)
- [Rustonomicon Index](https://github.com/rust-lang/nomicon/blob/master/src/SUMMARY.md)

### rust-analyzer

- [Docs](https://github.com/rust-lang/rust-analyzer/tree/master/docs/book/src)
- [Index](https://github.com/rust-lang/rust-analyzer/blob/master/docs/book/src/SUMMARY.md)

### Acorn

- [Docs](https://flyingmeat.com/acorn/docs/)
