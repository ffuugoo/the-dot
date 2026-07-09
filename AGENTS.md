# Dots for Clankers

This is personal dotfiles repo.

See [README](README.md) for brief description, `dots.sh` usage and `dots.conf` directive format.

This file adds additional context that README doesn't cover.


## Linking and Editing Config Files

Re-run `dots.sh` only when adding new file or changing link destination.

Files in `$HOME` are symlinks into this repo, so editing any file here
immediately takes effect in `$HOME`.

Linker always skips `.DS_Store`, `.git`, and nested `.gitignore` files.


## Configuration Gotchas

Things about `dots.conf` that README doesn't make obvious:

- `*` wildcard matches dotfiles (`globdots` is set), so `.config/*` matches `.config/.foo`
- `pattern` must match at least one existing file or the whole directive errors,
  you can't add directive ahead of creating the file
- `pattern` must resolve inside the repo (absolute patterns are rejected),
  but `=> destination` may be absolute
- `!` exclude directive can't have `=> destination` modifier


## Repo Map

- Basic shell configs are at repo root:
  `.zshrc`, `.profile`, `.gitconfig`, `.ssh/config`
- `.config` contains app configs:
  `agents`, `claude`, `codex`, `ghostty`, `sublime-merge`, `sublime-text`, `zed`
- `.local/bin` contains small personal tools:
  dev cache cleanup script, ROM-hacking helpers, mounting utilities
- `macOS/` tracks installed Homebrew formulae/casks and preferred `defaults`
- `Library/KeyBindings/DefaultKeyBinding.dict` – additional macOS key bindings
- `userscripts/*.user.css` – per-site User CSS tweaks


## Repo-Local Configs

Top-level `.claude/` and `.codex/` directories (if present) are repo-local configs,
excluded from linking via `!` directives and apply only when working on *this* repo.

Global configs that get linked into `$HOME` live under `.config/`:

- `.config/claude` → `~/.claude`
- `.config/codex`  → `~/.codex`
