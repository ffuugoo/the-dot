#!/bin/zsh

set -euo pipefail

function index {
	cat <<-EOF
		# Zsh Man Page Index

	EOF

	toc zsh \
		Entry point for shell invocation, startup behavior, compatibility modes, \
		restricted shells, and where the rest of the manual is split.

	toc zshroadmap \
		Guided reading path through the manual, useful when deciding which reference \
		page covers an interactive, scripting, completion, or customization topic.

	toc zshmisc \
		Core shell language reference: command syntax, control flow, quoting, \
		redirection, execution rules, functions, jobs, signals, tests, arithmetic, \
		and prompt escapes.

	toc zshexpn \
		Detailed rules for how zsh turns input text into words and filenames, \
		including substitution order, parameter flags, globbing, qualifiers, \
		and pattern behavior.

	toc zshparam \
		Reference for shell variables and zsh parameter types, including arrays, \
		positional parameters, scoping, tied parameters, and special parameters \
		maintained by the shell.

	toc zshoptions \
		Catalog of shell behavior switches for scripting, interactive use, globbing, \
		completion, history, job control, prompts, and compatibility modes.

	toc zshbuiltins \
		Reference for commands implemented by zsh itself, including declaration, \
		module, history, directory, job, resource-limit, eval, option, \
		and introspection builtins.

	toc zshzle \
		Reference for the interactive line editor: keymaps, widgets, \`bindkey\`, \
		\`zle\`, user-defined editing functions, standard editing commands, \
		and highlighting.

	toc zshcompwid \
		Low-level programmable completion API for writing custom completion widgets \
		and match generators directly against completion internals.

	toc zshcompsys \
		High-level function-based completion system used by \`compinit\`, including \
		configuration with \`zstyle\`, completers, matchers, tags, contexts, \
		and helper functions.

	toc zshcompctl \
		Legacy completion system centered on the \`compctl\` builtin\; mainly useful \
		for understanding old configs or simple pre-compsys completion definitions.

	toc zshmodules \
		Reference for optional zsh modules loaded with \`zmodload\`, and the builtins, \
		parameters, conditions, math functions, or editor features each module provides.

	toc zshtcpsys \
		Function layer over \`zsh/net/tcp\` for opening TCP sessions, sending data, \
		accepting connections, managing session state, and customizing TCP hooks.

	toc zshzftpsys \
		Autoloaded FTP client function suite built on \`zsh/zftp\`, covering sessions, \
		transfers, bookmarks, remote globbing, completion, and transfer progress behavior.

	toc zshcontrib \
		Documentation for bundled contributed functions and utilities, including \
		help integration, hooks, recent directories, VCS info, prompt themes, \
		ZLE helpers, MIME tools, and miscellaneous user-facing functions.
}

function toc {
	declare manpage=$1
	declare description=( ${@:2} )

	cat <<-EOF
		## \`$manpage\`

		$(echo $description | fmt -w 100)

		Sections:
		$(render $manpage | sections | list)

	EOF
}

function render {
	man $@ | col -bx
}

function sections {
	sed -n '/^[A-Z][A-Z0-9 _-]*$/p' $@
}

function list {
	sed 's/^/- /' $@
}

index
