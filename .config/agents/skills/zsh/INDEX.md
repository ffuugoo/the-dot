# Zsh Man Page Index

## `zsh`

Entry point for shell invocation, startup behavior, compatibility modes, restricted shells, and
where the rest of the manual is split.

Sections:
- NAME
- OVERVIEW
- DESCRIPTION
- AUTHOR
- AVAILABILITY
- MAILING LISTS
- THE ZSH FAQ
- THE ZSH WEB PAGE
- THE ZSH USERGUIDE
- INVOCATION
- COMPATIBILITY
- RESTRICTED SHELL
- FILES
- SEE ALSO

## `zshroadmap`

Guided reading path through the manual, useful when deciding which reference page covers an
interactive, scripting, completion, or customization topic.

Sections:
- NAME
- WHEN THE SHELL STARTS
- INTERACTIVE USE
- OPTIONS
- PATTERN MATCHING
- GENERAL COMMENTS ON SYNTAX
- PROGRAMMING

## `zshmisc`

Core shell language reference: command syntax, control flow, quoting, redirection, execution rules,
functions, jobs, signals, tests, arithmetic, and prompt escapes.

Sections:
- NAME
- PRECOMMAND MODIFIERS
- COMPLEX COMMANDS
- ALTERNATE FORMS FOR COMPLEX COMMANDS
- RESERVED WORDS
- ERRORS
- COMMENTS
- ALIASING
- QUOTING
- REDIRECTION
- OPENING FILE DESCRIPTORS USING PARAMETERS
- MULTIOS
- REDIRECTIONS WITH NO COMMAND
- COMMAND EXECUTION
- FUNCTIONS
- AUTOLOADING FUNCTIONS
- ANONYMOUS FUNCTIONS
- SPECIAL FUNCTIONS
- JOBS
- SIGNALS
- ARITHMETIC EVALUATION
- CONDITIONAL EXPRESSIONS
- EXPANSION OF PROMPT SEQUENCES
- SIMPLE PROMPT ESCAPES
- CONDITIONAL SUBSTRINGS IN PROMPTS

## `zshexpn`

Detailed rules for how zsh turns input text into words and filenames, including substitution order,
parameter flags, globbing, qualifiers, and pattern behavior.

Sections:
- NAME
- DESCRIPTION
- HISTORY EXPANSION
- PROCESS SUBSTITUTION
- PARAMETER EXPANSION
- COMMAND SUBSTITUTION
- ARITHMETIC EXPANSION
- BRACE EXPANSION
- FILENAME EXPANSION
- FILENAME GENERATION

## `zshparam`

Reference for shell variables and zsh parameter types, including arrays, positional parameters,
scoping, tied parameters, and special parameters maintained by the shell.

Sections:
- NAME
- DESCRIPTION
- ARRAY PARAMETERS
- POSITIONAL PARAMETERS
- LOCAL PARAMETERS
- PARAMETERS SET BY THE SHELL
- PARAMETERS USED BY THE SHELL

## `zshoptions`

Catalog of shell behavior switches for scripting, interactive use, globbing, completion, history,
job control, prompts, and compatibility modes.

Sections:
- NAME
- SPECIFYING OPTIONS
- DESCRIPTION OF OPTIONS
- OPTION ALIASES
- SINGLE LETTER OPTIONS

## `zshbuiltins`

Reference for commands implemented by zsh itself, including declaration, module, history, directory,
job, resource-limit, eval, option, and introspection builtins.

Sections:
- NAME
- SHELL BUILTIN COMMANDS

## `zshzle`

Reference for the interactive line editor: keymaps, widgets, `bindkey`, `zle`, user-defined editing
functions, standard editing commands, and highlighting.

Sections:
- NAME
- DESCRIPTION
- KEYMAPS
- ZLE BUILTINS
- ZLE WIDGETS
- USER-DEFINED WIDGETS
- STANDARD WIDGETS
- CHARACTER HIGHLIGHTING

## `zshcompwid`

Low-level programmable completion API for writing custom completion widgets and match generators
directly against completion internals.

Sections:
- NAME
- DESCRIPTION
- COMPLETION SPECIAL PARAMETERS
- COMPLETION BUILTIN COMMANDS
- COMPLETION CONDITION CODES
- COMPLETION MATCHING CONTROL
- COMPLETION WIDGET EXAMPLE

## `zshcompsys`

High-level function-based completion system used by `compinit`, including configuration with
`zstyle`, completers, matchers, tags, contexts, and helper functions.

Sections:
- NAME
- DESCRIPTION
- INITIALIZATION
- COMPLETION SYSTEM CONFIGURATION
- CONTROL FUNCTIONS
- BINDABLE COMMANDS
- UTILITY FUNCTIONS
- COMPLETION SYSTEM VARIABLES
- COMPLETION DIRECTORIES

## `zshcompctl`

Legacy completion system centered on the `compctl` builtin; mainly useful for understanding old
configs or simple pre-compsys completion definitions.

Sections:
- NAME
- DESCRIPTION
- COMMAND FLAGS
- OPTION FLAGS
- ALTERNATIVE COMPLETION
- EXTENDED COMPLETION
- EXAMPLE

## `zshmodules`

Reference for optional zsh modules loaded with `zmodload`, and the builtins, parameters, conditions,
math functions, or editor features each module provides.

Sections:
- NAME
- DESCRIPTION

## `zshtcpsys`

Function layer over `zsh/net/tcp` for opening TCP sessions, sending data, accepting connections,
managing session state, and customizing TCP hooks.

Sections:
- NAME
- DESCRIPTION
- TCP USER FUNCTIONS
- TCP USER-DEFINED FUNCTIONS
- TCP UTILITY FUNCTIONS
- TCP USER PARAMETERS
- TCP USER-DEFINED PARAMETERS
- TCP UTILITY PARAMETERS
- TCP EXAMPLES
- TCP BUGS

## `zshzftpsys`

Autoloaded FTP client function suite built on `zsh/zftp`, covering sessions, transfers, bookmarks,
remote globbing, completion, and transfer progress behavior.

Sections:
- NAME
- DESCRIPTION
- INSTALLATION
- FUNCTIONS
- MISCELLANEOUS FEATURES

## `zshcontrib`

Documentation for bundled contributed functions and utilities, including help integration, hooks,
recent directories, VCS info, prompt themes, ZLE helpers, MIME tools, and miscellaneous user-facing
functions.

Sections:
- NAME
- DESCRIPTION
- UTILITIES
- REMEMBERING RECENT DIRECTORIES
- ABBREVIATED DYNAMIC REFERENCES TO DIRECTORIES
- GATHERING INFORMATION FROM VERSION CONTROL SYSTEMS
- PROMPT THEMES
- ZLE FUNCTIONS
- EXCEPTION HANDLING
- MIME FUNCTIONS
- MATHEMATICAL FUNCTIONS
- USER CONFIGURATION FUNCTIONS
- OTHER FUNCTIONS
