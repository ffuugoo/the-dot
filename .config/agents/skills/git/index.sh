#!/bin/zsh

set -euo pipefail

function index {
	cat <<-EOF
		# Git Man Page Index

	EOF

	toc git \
		Entry point for Git invocation, global options, command categories, repository \
		concepts, environment variables, security notes, and links to broader docs.

	desc gitcli \
		Command-line syntax conventions, option parsing, revision and path ambiguity, \
		pathspec placement, pager behavior, aliases, and scripting expectations.

	cat <<-EOF
		## Subcommands

		For command-specific behavior, consult the subcommand manual page directly.
		E.g., \`git-checkout\`, \`git-diff\`, \`git-rebase\`, \`git-reset\`.

	EOF

	desc giteveryday \
		Practical minimum command set for individual developers, contributors, \
		integrators, and repository administrators.

	desc gitglossary \
		Definitions for Git terms such as refs, index, pathspecs, remotes, object \
		names, upstream branches, and working trees.

	toc gitrevisions \
		Revision naming syntax, ranges, ancestry selectors, reflog selectors, refname \
		disambiguation, and commit-set notation.

	toc gitattributes \
		Per-path attributes controlling diff, merge, text normalization, filters, \
		archive behavior, and generated files.

	toc gitignore \
		Ignore pattern files, precedence, pattern syntax, negation, directory matches, \
		and common ignore behavior.

	toc git-config \
		Reading and writing Git configuration, config file scopes, value types, \
		conditional includes, and built-in configuration variables.

	toc githooks \
		Client-side and server-side hook names, invocation points, arguments, \
		environment, and bypass behavior.
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

function desc {
	declare manpage=$1
	declare description=( ${@:2} )

	cat <<-EOF
		## \`$manpage\`

		$(echo $description | fmt -w 100)

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
