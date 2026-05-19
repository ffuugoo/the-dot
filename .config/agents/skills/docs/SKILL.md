---
name: docs
description: >-
  Use when looking up reference documentation for installed tools, languages,
  libraries, or services. Covers manpages, web docs, and GitHub-hosted docs.
---

# Docs 🦆

How to fetch documentation from common sources, in order of preference.

## Manpages

Render with `col -bx` so the output stays plain text without backspace overstrike

```zsh
man <page> | col -bx
```

For wider output, set `MANWIDTH`:

```zsh
MANWIDTH=100 man <page> | col -bx
```

## Web Pages

Prefer `WebFetch` when available; it handles HTML-to-text conversion and follows redirects

Fallback when `WebFetch` is not available:

```zsh
curl -sL <url>
```

`-s` silences progress, `-L` follows redirects. Pipe to a converter for readable output

## HTML to Markdown

Convert HTML to GitHub-flavored Markdown with `pandoc`:

```zsh
curl -sL <url> | pandoc --from html --to gfm --wrap none
```

Prereq: `pandoc` (`brew install pandoc`)

Fallback without `pandoc` (plain text, loses links/structure):

```zsh
curl -sL <url> | lynx -stdin -dump -nolist
# or
curl -sL <url> | w3m -dump -T text/html
```

## GitHub-Hosted Docs

Use `gh` to browse files and directories in a repository without cloning

List directory contents:

```zsh
gh api repos/<owner>/<repo>/contents/<path>
```

Returns JSON with file metadata. Filter paths with `--jq`:

```zsh
gh api repos/<owner>/<repo>/contents/docs --jq '.[].path'
```

Full recursive tree (all files):

```zsh
gh api repos/<owner>/<repo>/git/trees/HEAD?recursive=1 \
  --jq '.tree[] | select(.path | test("^docs/.*\\.mdx?$")) | .path'
```

Read a single file as raw content:

```zsh
gh api repos/<owner>/<repo>/contents/<path> \
  -H 'Accept: application/vnd.github.raw'
```

Or fetch raw URL directly:

```zsh
curl -sL https://raw.githubusercontent.com/<owner>/<repo>/HEAD/<path>
```

Raw URLs avoid base64 decoding and rate-limit weight of API calls

## Zed

- https://github.com/zed-industries/zed/tree/main/docs/src
- https://github.com/zed-industries/zed/blob/main/docs/src/SUMMARY.md

## Sublime Text

- https://www.sublimetext.com/docs/index.html

- https://github.com/sublimetext-io/docs.sublimetext.io/tree/master/docs
- https://github.com/sublimetext-io/docs.sublimetext.io/blob/master/docs/.vitepress/config.ts

## rust-analyzer

- https://github.com/rust-lang/rust-analyzer/tree/master/docs/book/src
- https://github.com/rust-lang/rust-analyzer/blob/master/docs/book/src/SUMMARY.md

## Ghostty

- `ghostty(1)` and `ghostty(5)` manpages

- https://github.com/ghostty-org/website/tree/main/docs
- https://github.com/ghostty-org/website/blob/main/docs/nav.json
