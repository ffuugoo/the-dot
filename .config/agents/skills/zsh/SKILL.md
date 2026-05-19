---
name: zsh
description: >-
  Use when writing, reviewing, or editing shell scripts, Zsh scripts, dotfiles,
  shell startup files, completion setup, prompts, zstyle configuration, or shell
  utilities. Prefer this skill whenever the user asks about Zsh or shell scripts
  in general, unless they specifically mention another shell such as Bash, Fish,
  etc.
---

# Zsh 🐚

Use zsh as zsh, not as portable POSIX shell, unless the user explicitly asks for portability

## Base Guidelines

- Prefer compact, idiomatic zsh over portable shell ceremony
- Write scripts for known environments, not public defensive CLIs, unless asked otherwise
- Prefer readable density: use zsh-specific constructs when they make the code shorter or clearer

## Script Shape

- Use `#!/bin/zsh` and `set -euo pipefail`; add options inline when useful

- Simple scripts may stay inline:

  ```zsh
  #!/bin/zsh

  set -euo pipefail

  declare root=${0:a:h}
  declare manpages=( $@ )

  for manpage in $manpages; do
    man $manpage | col -bx > $root/$manpage.txt
  done
  ```

- Non-trivial scripts should use small named functions
- Order functions top-to-bottom from orchestration to detail: `main` first, core functions
  in usage order, low-level helpers last
- Make scripts read forward, with later functions filling in details introduced by
  the higher-level flow

- Put derived paths, declarations, and argument parsing near the top of an inline script or
  function, then keep the action phase small

- When using `main`, call `main $@` at the bottom after all function definitions
- If `main` needs to reference the `$0` path, use `self=$0 main $@`

## Declarations and Data

- Declare functions with `function function-name` and variables with `declare variable_name=value`
- Use arrays for lists and command arguments
- Use associative arrays for lookup and state maps
- Split declaration and assignment for command substitution when capturing the status code matters

## Arguments and Expansion

- Prefer unquoted zsh expansions; quote when preserving empty values or exact word boundaries

- Prefer zsh-native path, glob, and parameter modifiers when clear:
  `${0:a:h}`, `${file:t}`, `${file:e}`, `${name:r}`, `${@:2}`, `${array:#value}`
- Use zsh array and glob flags directly when they make the code clearer:
  `${(f)"$(cmd)"}`, `${(iu)array}`, `${(b)files}`, `${^items}`, `${~pattern}`

- For small helpers, accept `$@` instead of `$1` when forwarding all arguments is equally clear
- Preserve stdin-or-files behavior for simple filters when it comes for free:

  ```zsh
  function list {
    sed 's/^/- /' $@
  }
  ```

## Output, Errors, and Safety

- Keep comments sparse; use blank lines to separate phases instead of narrating obvious code
- Keep output quiet by default

- Rely on `set -e` for ordinary command failures instead of checking every command manually
- Add precondition checks when a command could succeed while doing the wrong thing, especially
  when mutable operations can overwrite or remove user-owned state
- Print errors to stderr and include the concrete bad input
- Return explicit status codes for user-facing validation failures

- For cleanup traps that need function state after return, call the function as `STATE='' process`
  and set the state variable inside the function so it survives function scope without leaving a
  global behind:

  ```zsh
  function process {
    TMP=$(mktemp -d)
    trap 'rm -r $TMP' EXIT INT ERR

    # ...
  }

  TMP='' process
  ```

- Use a simple dry-run wrapper when dry-run is useful:

  ```zsh
  function danger {
    - rm -rf /
  }

  function - {
    ${DRY_RUN:+echo} $@
  }

  DRY_RUN=1 danger
  ```

- Consider dry-run for multi-step mutation workflows when it helps inspect planned actions or
  debug behavior
- Omit dry-run for repeatable generated outputs when misuse is unlikely and recovery is simple

## Validation

- Use `zsh -n script.zsh` for syntax checks

## References

- See [`CHEAT.md`] for the condensed working reference
- When exact behavior matters, render a manpage with `man $manpage | col -bx`
- Use [`INDEX.md`] to select the relevant zsh manpage; use [`index.sh`] to regenerate [`INDEX.md`]
- For concrete style examples, inspect [`man.sh`] for a short non-trivial utility and
  [`index.sh`] for top-to-bottom document-generation structure

[`CHEAT.md`]: CHEAT.md
[`INDEX.md`]: INDEX.md
[`index.sh`]: index.sh
[`man.sh`]: man.sh
