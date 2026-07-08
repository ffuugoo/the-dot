# Zsh Cheat Sheet

Quick reference for writing zsh scripts and dotfiles. This is intentionally condensed;
use [INDEX.md](INDEX.md) to choose the relevant manpage, then render it on demand with
`man <manpage> | col -bx`.

## Script Shape

Full refs: `zshmisc`, `zshbuiltins`, `zshoptions`

```zsh
#!/bin/zsh

set -euo pipefail -o nullglob

function main {
    declare self=${self:a}
    declare root=${self:h}

    # parse args, declare arrays/maps, then dispatch
}

self=$0 main $@
```

- Prefer zsh features over POSIX portability unless another shell is explicitly required
- Prefer arrays for argument lists and file lists
- Zsh arrays are 1-indexed by default. Avoid `ksharrays` in normal zsh scripts
- Unquoted scalar parameters are not split on whitespace unless `shwordsplit` is set
- Unquoted empty scalar/array elements are elided. Use quotes or `(@)` when empties matter
- Keep destructive commands visually marked when using dry-run wrappers:

  ```zsh
  function - {
      ${DRY_RUN:+echo} $@
  }

  - rm -rf $items
  ```

## Expansion Order

Full ref: `zshexpn`

Useful mental model:

1. History expansion, unless disabled or non-interactive
2. Alias expansion while reading code
3. Process substitution: `<(...)`, `>(...)`, `=(...)`
4. Parameter, command, and arithmetic expansion
5. Brace expansion
6. Filename expansion: leading `~` and `=cmd`
7. Filename generation, i.e. globbing

Parameter expansion is its own world: flags, nested substitutions, splitting, joining,
subscripts, modifiers, and empty-argument removal have detailed ordering rules. When nested
expansion gets surprising, simplify it into named intermediate parameters.

## Quoting

Full ref: `zshmisc`, `zshexpn`

```zsh
'literal text'       # no parameter/command expansion
"$scalar"            # one word, preserves empty scalar
"${array[@]}"        # one word per array element, preserves empty elements
"${(@)array}"        # zsh-native equivalent
$'line\n'            # print-style escapes
```

- In zsh, `$array` expands to array elements, one word per element, but empty elements are
  removed if unquoted
- Use `"${(@)array}"` when passing an array through exactly
- Use `${(q)value}` or `${(qq)value}` when generating shell code or debug output
- Use `${(b)value}` when a value needs quoting for use as a pattern/file argument in contexts
  where pattern metacharacters matter

## Parameter Expansion

Full ref: `zshexpn`

### Basic Forms

```zsh
${name}              # value
${+name}             # 1 if set, else 0
${name-word}         # default if unset
${name:-word}        # default if unset or empty
${name+word}         # word if set
${name:+word}        # word if set and non-empty
${name=word}         # assign default if unset
${name:=word}        # assign default if unset or empty
${name::=word}       # assign unconditionally
${name?message}      # error if unset
${name:?message}     # error if unset or empty
```

### Length, Trimming, Filtering

```zsh
${#name}             # string length, or array length for array expression
${name#pattern}      # remove shortest prefix match
${name##pattern}     # remove longest prefix match
${name%pattern}      # remove shortest suffix match
${name%%pattern}     # remove longest suffix match
${name:#pattern}     # remove matching scalar/array elements
${array:|other}      # remove elements also present in array named other
${array:*other}      # keep only elements also present in array named other
```

Common examples:

```zsh
files=( ${files:#*.bak} )       # remove backup files from array
name=${file:t:r}                # tail, then remove extension
dir=${file:h}                   # head/dirname
ext=${file:e}                   # extension without dot
```

### Replacement

```zsh
${name/pattern/repl}            # replace first longest match
${name//pattern/repl}           # replace all matches
${name:/pattern/repl}           # replace only if whole value matches
${name/#pattern/repl}           # replace prefix match
${name/%pattern/repl}           # replace suffix match
${name:#pattern}                # remove elements that match whole pattern
```

Use `${~pattern}` when the pattern is stored in a parameter and should be active:

```zsh
pattern='*.txt'
print -l ${~pattern}
```

### Array Zipping

```zsh
${a:^b}             # alternate elements, stop at shorter array
${a:^^b}            # alternate elements, repeat shorter input
```

### Substring Compatibility Form

```zsh
${name:offset}
${name:offset:length}
```

Offsets here are shell-compatible and 0-based, unlike native zsh subscripts

## Parameter Expansion Flags

Full ref: `zshexpn`

Flags go after the opening brace:

```zsh
${(flags)name}
${(@f)"$(cmd)"}
${(j:,:)array}
```

Most useful flags:

| Flag        | Description                                                                   |
| ----------- | ----------------------------------------------------------------------------- |
| `@`         | Preserve array elements in quotes; `"${(@)array}"`                            |
| `f`         | Split lines. Shorthand for splitting on newline                               |
| `F`         | Join array with newlines                                                      |
| `s:string:` | Split on `string`. Use `(@s:string:)` to preserve empty fields                |
| `j:string:` | Join array elements with `string`                                             |
| `p`         | Interpret print-style escapes in a later separator, often with `s`            |
| `z`         | Split as shell syntax, respecting quotes                                      |
| `Z:opts:`   | Like `z`, with options for comments/newlines                                  |
| `q`         | Quote so the result can be reused as shell input. Repeat for stronger quoting |
| `Q`         | Remove one level of quotes                                                    |
| `b`         | Backslash-quote characters special to pattern matching                        |
| `e`         | Re-evaluate the result for parameter/command/arithmetic substitutions         |
| `P`         | Treat the value as a parameter name and expand that parameter                 |
| `k`         | Expand keys of an associative array                                           |
| `v`         | Expand values; useful with `k`, e.g. `${(@kv)map}`                            |
| `u`         | Remove duplicate array elements                                               |
| `o`         | Sort array ascending                                                          |
| `O`         | Sort array descending                                                         |
| `n`         | Numeric sort when combined with `o`/`O`                                       |
| `L`         | Lowercase                                                                     |
| `U`         | Uppercase                                                                     |
| `C`         | Capitalize                                                                    |
| `%`         | Expand prompt escapes. `%%` performs fuller prompt expansion                  |
| `D`         | Abbreviate directories with named-directory syntax                            |
| `A`         | Assignment-oriented array handling; check the full page before using          |

Common combinations:

```zsh
lines=( "${(@f)$(cmd)}" )       # split command output into lines
lines=( ${(f)"$(cmd)"} )        # common compact form
csv=${(j:,:)items}              # join with comma
items=( ${(s:,:)csv} )          # split on comma, eliding empties
items=( ${(@s:,:)csv} )         # split on comma, preserving empties
print -l ${(o)items}            # sorted list
print -l ${(u)items}            # unique list
print ${(qqq)value}             # visibly quoted/debuggable
```

## History-Style Modifiers

Full ref: `zshexpn`

These work after history references, parameter expansions, and glob results

| Modifier   | Description                                                         |
| ---------- | ------------------------------------------------------------------- |
| `:h`       | Head/dirname. With digits, preserve that many leading components    |
| `:t`       | Tail/basename. With digits, preserve that many trailing components  |
| `:r`       | Remove one filename extension                                       |
| `:e`       | Keep only the extension                                             |
| `:a`       | Logical absolute path, resolves `.` and `..`                        |
| `:A`       | Absolute path with symlink resolution where available               |
| `:P`       | Realpath-like absolute path; allows nonexistent trailing components |
| `:c`       | Resolve command name through `$path`                                |
| `:l`       | Lowercase                                                           |
| `:u`       | Uppercase                                                           |
| `:q`       | Quote words                                                         |
| `:Q`       | Remove one level of quotes                                          |
| `:s/l/r/`  | Substitute first literal `l` with `r`                               |
| `:gs/l/r/` | Substitute globally                                                 |

Examples:

```zsh
root=${0:a:h}
name=${file:t:r}
ext=${file:e}
for page in /usr/share/man/man1/zsh*(:t:r); do ...; done
```

## Arrays

Full ref: `zshparam`

### Declaration And Assignment

```zsh
declare array=( one two three )
declare -a array
declare -A map=( [key]=value [other]=thing )

array=( one [3]=three four )
array+=( five six )
map+=( new value )
map[key]=value
```

Associative arrays must be declared before assignment:

```zsh
declare -A plugins=(
    [brew]=/opt/homebrew/share/zsh/site-functions
    [gitstatus]=/opt/homebrew/opt/gitstatus/gitstatus.plugin.zsh
)
```

For associative arrays, `map=( key value key value )` and `map=( [key]=value )` are both
valid, but do not mix the two forms in one assignment.

### Subscripts

```zsh
$array[1]            # first element
${array[1]}          # braced form
$array[-1]           # last element
$array[1,-1]         # all elements
$array[2,4]          # range
$string[2,5]         # substring
${array[@]}          # all elements
${array[*]}          # all elements; differs inside double quotes
```

Quoted all-elements behavior:

```zsh
"${array[@]}"        # one quoted word per element
"$array[*]"          # one quoted word, joined by first char of IFS
"${(@)array}"        # zsh-native preserve-elements form
```

### Element Assignment And Deletion

```zsh
array[2]=new
array[2]=( several values )     # replaces one element with several
array[2]=()                     # delete ordinary-array element
unset 'map[key]'                # delete associative-array element
```

Quote `typeset`/`declare` assignments with subscripts so brackets are not globbed:

```zsh
typeset "array[2]"=value
```

### Subscript Flags

Full ref: `zshparam`

Subscript flags go inside the brackets:

```zsh
${array[(i)pattern]}
${array[(r)pattern]}
${map[(e)*]}
```

Most useful flags:

| Flag        | Description                                                       |
| ----------- | ----------------------------------------------------------------- |
| `r`         | Return first value matching pattern                               |
| `R`         | Return last/all matching values                                   |
| `i`         | Return index/key of first match                                   |
| `I`         | Return index/key of last match; good for "not found" tests        |
| `e`         | Match literally instead of as a pattern                           |
| `k`         | For associative arrays, match keys as patterns and return a value |
| `K`         | Like `k`, but return all values with matching keys                |
| `n:expr:`   | Select nth match with `r`/`R`/`i`/`I`                             |
| `b:expr:`   | Begin search at a given element/character                         |
| `w`         | For scalars, subscript words instead of characters                |
| `s:string:` | Word separator for `w`                                            |
| `f`         | For scalars, subscript lines                                      |

Examples:

```zsh
if [[ ${array[(i)$value]} -le ${#array} ]]; then
    print found
fi

if [[ ${array[(I)$value]} -ne 0 ]]; then
    print found
fi

print ${map[$key]}
print ${map[(e)$literal_key]}
print ${(k)map}                 # keys
print ${(v)map}                 # values
print ${(kv)map}                # alternating keys and values
```

Pattern values substituted into reverse subscripts are active patterns. Use `(e)` for literal
matching, or quote the pattern carefully.

## Common Special Parameters

Full ref: `zshparam`

| Parameter                    | Meaning                                                       |
| ---------------------------- | ------------------------------------------------------------- |
| `$?`, `$status`              | Exit status of the last command                               |
| `$pipestatus`                | Array of statuses from the last pipeline                      |
| `$#`, `$ARGC`                | Number of positional parameters                               |
| `$@`, `$*`, `$argv`          | Positional parameters as arrays                               |
| `$0`                         | Invocation name or function/script name, depending on options |
| `$!`                         | PID of last background job                                    |
| `$$`                         | PID of this shell process                                     |
| `$LINENO`                    | Current line number                                           |
| `$PWD`, `$OLDPWD`            | Current and previous working directory                        |
| `$RANDOM`                    | Pseudo-random integer from 0 to 32767                         |
| `$SECONDS`                   | Seconds since shell start or since assignment                 |
| `$ZSH_VERSION`               | Zsh version                                                   |
| `$ZSH_SCRIPT`                | Script path if invoked as a script                            |
| `$ZSH_SUBSHELL`              | Subshell nesting count                                        |
| `$TRY_BLOCK_ERROR`           | Error indicator inside `always` blocks                        |
| `$MATCH`, `$MBEGIN`, `$MEND` | Whole pattern/regexp match and indices                        |
| `$match`, `$mbegin`, `$mend` | Parenthesized submatches and indices                          |

Tied scalar/array parameters:

```zsh
path=( /opt/homebrew/bin $path )     # updates PATH
fpath=( ./functions $fpath )         # updates FPATH
manpath=( ./man $manpath )           # updates MANPATH
```

The lowercase form is usually the array, the uppercase form is the colon-separated scalar

## Globbing And Filename Generation

Full ref: `zshexpn`

Basic operators:

| Pattern           | Meaning                                     |
| ----------------- | ------------------------------------------- |
| `*`               | Any string, including empty                 |
| `?`               | Any single character                        |
| `[abc]`, `[^abc]` | Character class / negated class             |
| `[[:alpha:]]`     | Named character class                       |
| `<x-y>`           | Number in range. `<->` matches any number   |
| `(x|y)`           | Alternation/grouping                        |
| `^x`              | Anything except `x`; needs `extendedglob`   |
| `x~y`             | Match `x` except `y`; needs `extendedglob`  |
| `x#`              | Zero or more of `x`; needs `extendedglob`   |
| `x##`             | One or more of `x`; needs `extendedglob`    |
| `**/*`            | Recursive directories                       |
| `***/*`           | Recursive directories, following symlinks   |

Ksh-style operators need `kshglob`:

```zsh
@(pat)      # exactly pat
*(pat)      # zero or more
+(pat)      # one or more
?(pat)      # zero or one
!(pat)      # anything but pat
```

Common glob flags and qualifiers:

```zsh
*(N)        # null glob: no error and no literal pattern if no matches
*(D)        # include dotfiles
*(.)        # regular files
*(/)        # directories
*(@)        # symbolic links
(#i)pat     # case-insensitive match, needs extendedglob
(#b)(pat)   # set $match/$mbegin/$mend for parenthesized groups
(#m)pat     # set $MATCH/$MBEGIN/$MEND for whole match
```

Glob qualifiers can include history-style modifiers:

```zsh
print -l /usr/share/man/man1/zsh*(:t:r)
```

Use local qualifiers such as `(N)` when only one glob should have special behavior. Use options
such as `nullglob` or `globdots` when the whole script should behave that way.

## Filename And Process Substitution

Full ref: `zshexpn`

```zsh
~           # home directory
~user       # user's home directory
~name       # named directory
=cmd        # full path to command, when equals option is set
<(cmd)      # filename connected to cmd output
>(cmd)      # filename connected to cmd input
=(cmd)      # temp file containing cmd output
```

Use `=(cmd)` when the consumer needs a real seekable file, not a pipe or `/dev/fd` handle

## Complex Commands

Full ref: `zshmisc`

```zsh
if list; then
    ...
elif list; then
    ...
else
    ...
fi

for item in $items; do
    ...
done

for (( i = 1; i <= 10; i++ )); do
    ...
done

while list; do ...; done
until list; do ...; done
repeat 3; do ...; done

case $value in
    pat1|pat2) ... ;;
    pat3)      ... ;&   # fall through and execute next body
    pat4)      ... ;|   # keep testing following patterns
esac

( list )                # subshell
{ list }                # current shell

{ risky } always {
    cleanup
}

function name {
    ...
}
```

Notes:

- `&&` and `||` combine pipelines into sublists
- `coproc` creates a two-way pipe to a pipeline
- `time pipeline` reports timing
- `[[ expression ]]` is the main conditional form
- `(( expression ))` evaluates arithmetic and returns status 0 for non-zero

## Functions And Autoloading

Full ref: `zshmisc`, `zshbuiltins`

```zsh
function name {
    declare arg=$1
    return 0
}

name() {
    ...
}
```

- Functions run in the current shell process and share cwd and file descriptors
- Function arguments become positional parameters inside the function
- `return` exits a function; `exit` exits the shell/script
- Alias expansion happens when a function is read, not when it is run

Autoloading:

```zsh
fpath=( ~/functions $fpath )
autoload -Uz my-function
```

Use `autoload -Uz` for normal zsh function files: `-U` suppresses alias expansion while loading,
and `-z` selects zsh-style autoloading.

## Conditional Expressions

Full ref: `zshmisc`

Use `[[ ... ]]` for tests. Its arguments behave as single words; filename generation is not
performed unless explicitly forced with a glob qualifier such as `(#qN)`.

Common file tests:

| Test                            | Meaning                                   |
| ------------------------------- | ----------------------------------------- |
| `-e file`, `-a file`            | Exists                                    |
| `-f file`                       | Regular file                              |
| `-d file`                       | Directory                                 |
| `-L file`, `-h file`            | Symlink                                   |
| `-r file`, `-w file`, `-x file` | Readable, writable, executable/searchable |
| `-s file`                       | Exists and size > 0                       |
| `-p file`                       | FIFO                                      |
| `-S file`                       | Socket                                    |
| `-O file`, `-G file`            | Owned by effective user/group             |
| `file1 -nt file2`               | Newer than                                |
| `file1 -ot file2`               | Older than                                |
| `file1 -ef file2`               | Same file                                 |

Strings and patterns:

```zsh
[[ -n $value ]]                 # non-empty
[[ -z $value ]]                 # empty
[[ -v map[$key] ]]              # variable/subscript is set
[[ $file = *.txt ]]             # pattern match
[[ $file != *.tmp ]]            # pattern non-match
[[ $a < $b ]]                   # ASCII lexical order
[[ $a > $b ]]
```

Regex:

```zsh
if [[ $line =~ '^\s*(.+?)\s*$' ]]; then
    print $MATCH
    print -l $match
fi
```

- With `re_match_pcre`, `=~` uses PCRE through `zsh/pcre`
- Without it, `=~` uses POSIX extended regex through `zsh/regex`
- Successful matches set `$MATCH`, `$MBEGIN`, `$MEND`, and parenthesized captures in
  `$match`, `$mbegin`, `$mend`, unless `bash_rematch` is set

Numeric comparisons inside `[[ ... ]]`:

```zsh
[[ $a -eq $b ]]
[[ $a -ne $b ]]
[[ $a -lt $b ]]
[[ $a -le $b ]]
[[ $a -gt $b ]]
[[ $a -ge $b ]]
```

Prefer `(( ... ))` for arithmetic-heavy conditions:

```zsh
if (( ${#items} > 0 )); then
    ...
fi
```

## Arithmetic

Full ref: `zshmisc`

```zsh
(( count += 1 ))
(( ok = count > 0 ))
print $(( 16#ff + 1 ))
```

- `(( expr ))` is equivalent to `let "expr"`
- Status is 0 if the expression evaluates non-zero, 1 if zero, 2 on error
- Variables can be referenced by name without `$`
- Integers support `0x`, `0b`, and `base#number`
- Use underscores for readability: `1_000_000`
- Declare numeric parameters when type matters:

  ```zsh
  integer count=0
  float ratio=0.0
  typeset -i 16 hex
  ```

Important footgun: if a variable is first assigned in arithmetic context, zsh may type it as
integer. Initialize as `0.0` or declare `float` before fractional arithmetic.

## Redirection And File Descriptors

Full ref: `zshmisc`

```zsh
cmd < file              # stdin from file
cmd > file              # stdout to file, obeys clobber
cmd >| file             # force overwrite
cmd >> file             # append
cmd 2> errors.log       # stderr
cmd > out 2>&1          # stderr to current stdout target
cmd &> out              # stdout and stderr
cmd |& next             # stderr + stdout into pipe
cmd <<< $word           # here-string
cmd <<EOF               # here-doc
...
EOF
cmd <<-EOF              # here-doc, strip leading tabs
	...
EOF
```

Redirections are processed left to right:

```zsh
cmd >out 2>&1           # both to out
cmd 2>&1 >out           # stderr stays where stdout originally was
```

Open file descriptors into parameters:

```zsh
integer fd
exec {fd}>log.txt
print "message" >&$fd
exec {fd}>&-
```

This allocates a descriptor at least 10 and stores the number in `$fd`. It only allocates or
closes the descriptor; use `exec` or command redirection to attach it.

## Options

Full ref: `zshoptions`

Set options:

```zsh
set -euo pipefail
setopt nullglob globdots re_match_pcre
unsetopt nomatch
[[ -o nullglob ]] && print on
```

Option names are case-insensitive and ignore underscores. `no_foo` inverts `foo`.

Script options:

| Option          | Also                   | Meaning                                      |
| --------------- | ---------------------- | -------------------------------------------- |
| `err_exit`      | `set -e`               | Exit on unhandled command failure            |
| `no_unset`      | `set -u`               | Error on unset parameter expansion           |
| `pipefail`      |                        | Pipeline status fails if any component fails |
| `no_glob`       | `set -f`, `noglob cmd` | Disable filename generation                  |
| `no_exec`       | `set -n`               | Parse but do not execute                     |
| `xtrace`        | `set -x`               | Trace commands                               |
| `verbose`       | `set -v`               | Print shell input as read                    |
| `local_options` |                        | Restore option changes at function exit      |
| `local_traps`   |                        | Restore traps at function exit               |
| `privileged`    | `zsh -p`               | Avoid user startup files when elevated       |

Globbing/pattern options:

| Option              | Meaning                                                     |
| ------------------- | ----------------------------------------------------------- |
| `null_glob`         | Unmatched globs disappear. Prefer `(N)` for local behavior  |
| `nomatch`           | Unmatched globs are errors. Default zsh behavior            |
| `bad_pattern`       | Bad glob patterns are errors                                |
| `glob_dots`         | Dotfiles do not require explicit leading dot                |
| `extended_glob`     | Enable `^`, `~`, `#`, glob flags                            |
| `bare_glob_qual`    | Treat trailing `(...)` as glob qualifiers when possible     |
| `glob_subst`        | Treat expansion results as patterns where possible          |
| `ksh_glob`          | Enable ksh-style `@(x)`, `!(x)`, etc.                       |
| `equals`            | Enable `=cmd` filename expansion                            |
| `magic_equal_subst` | Expand `~`/`=` after `name=` command arguments              |
| `re_match_pcre`     | Use PCRE for `[[ string =~ regex ]]`                        |

Compatibility options to know but usually avoid:

| Option               | Meaning                                           |
| -------------------- | ------------------------------------------------- |
| `sh_word_split`      | Split unquoted parameter expansions like sh/bash  |
| `ksh_arrays`         | 0-index arrays and ksh-like array behavior        |
| `ksh_zero_subscript` | Treat subscript 0 as subscript 1. Not recommended |
| `posix_builtins`     | POSIX special-builtin behavior                    |
| `c_precedences`      | More C-like arithmetic precedence                 |
| `force_float`        | Treat arithmetic constants as floating point      |

Interactive/dotfile options often seen:

```zsh
setopt interactive_comments
setopt inc_append_history hist_ignore_dups hist_reduce_blanks
setopt always_to_end complete_in_word no_list_beep
setopt correct correct_all
setopt cd_silent pushd_silent
```

## Builtins Worth Remembering

Full ref: `zshbuiltins`

### Declarations

```zsh
declare name=value
local name=value
typeset name=value
integer count=0
float ratio=0.0
readonly name=value
export NAME=value
```

`declare`, `local`, and `typeset` are mostly the same interface. Common flags:

| Flag                    | Meaning                                  |
| ----------------------- | ---------------------------------------- |
| `-a`                    | Array                                    |
| `-A`                    | Associative array                        |
| `-i [base]`             | Integer, optionally with output base     |
| `-F [n]`                | Floating point, fixed decimal display    |
| `-E [n]`                | Floating point, scientific display       |
| `-r`                    | Readonly                                 |
| `-x`                    | Export                                   |
| `-g`                    | Do not create a function-local parameter |
| `-p`                    | Print restorable declaration             |
| `-T scalar array [sep]` | Tie scalar and array like `PATH`/`path` |
| `-U`                    | Keep unique values in arrays             |
| `-L`, `-R`, `-Z`        | Pad/justify on expansion                 |
| `-l`, `-u`              | Lowercase/uppercase on expansion         |

Important: if an assignment uses command substitution and you care about its exit status, split
declaration from assignment:

```zsh
declare out
out=$(cmd)
```

### Functions And Commands

```zsh
functions              # list functions
functions name         # print function
unfunction name
autoload -Uz name
builtin cd -- "$dir"   # force builtin
command git status     # force external command lookup
exec command           # replace shell
eval "$code"           # re-read as shell code; avoid unless intentional
source file            # same as `. file`
```

### Options And Positional Parameters

```zsh
set -euo pipefail
set -- $args
shift
setopt nullglob
unsetopt nullglob
```

`set -A array values...` assigns arrays, but `array=( values... )` is usually clearer

### Output

```zsh
print -r -- $value     # raw print, no escape processing
print -l -- $array     # one argument per line
print -P -- '%F{red}x%f'
printf '%s\n' $array
echo                   # avoid for anything non-trivial
```

Prefer `print -r --` or `printf` over `echo` when values may begin with `-` or contain escapes

### Input

```zsh
read line
read -r line           # raw backslashes
read -A array          # words into array
read -k 1 key          # one character
read -q 'answer?Continue? '    # y/n style query
```

### Traps And Cleanup

```zsh
trap 'rm -r $TMP' EXIT INT ERR
trap - EXIT
```

Use traps close to the temporary resource they protect. Remember that functions share the caller
environment; an `EXIT` trap set inside a function runs when the function completes.

### Lookup And Introspection

```zsh
whence name            # what would be executed
whence -v name         # verbose
where name             # all matches
which name             # csh-style output
type name              # equivalent-ish interface
functions name
typeset -p name
```

### Directories And Jobs

```zsh
cd dir
cd -
pushd dir
popd
dirs -v
jobs
fg %1
bg %1
wait $pid
```

### Modules, Styles, ZLE

```zsh
zmodload zsh/mathfunc
zmodload zsh/pcre
zstyle ':completion:*' menu select
bindkey $key[Left] backward-char
zle -N widget-name function-name
```

- `zmodload` loads optional modules
- `zstyle` stores structured configuration used heavily by completion and contributed functions
- `bindkey` and `zle` live in the ZLE docs; keep detailed line-editor work in
  `zshzle`

## Precommand Modifiers

Full ref: `zshmisc`

```zsh
command cmd            # external command lookup, not shell function
builtin cmd            # builtin command lookup
exec cmd               # replace shell process
noglob cmd *           # disable globbing for this command
nocorrect cmd          # disable spelling correction
- cmd                  # run with '-' prepended to argv[0]
```

## Full Reference Map

- Expansion, flags, modifiers, globbing: `zshexpn`
- Arrays, subscripts, special parameters: `zshparam`
- Syntax, functions, conditions, arithmetic, redirection: `zshmisc`
- Options: `zshoptions`
- Builtins: `zshbuiltins`
- Line editor: `zshzle`
- Completion system: `zshcompsys`
- Loadable modules: `zshmodules`
