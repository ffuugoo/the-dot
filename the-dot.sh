#!/usr/bin/env zsh

set -euo pipefail -o nullglob -o globdots


declare self=${0:A}
declare repo=${self:h}


declare ignore=(
	.DS_Store

	/.git

	brew.sh
	casks.txt
	formulas.txt
)

declare recurse=(
	.config
	.ssh
)

declare -A override=(
	[.config/sublime-text]='Library/Application Support/Sublime Text'
	[.config/sublime-merge]='Library/Application Support/Sublime Merge'
	[.config/clangd]='Library/Preferences/clangd'
)


function symlink-all {
	declare dir=${1:-$repo}

	if [[ $self != ${self:a} ]]
	then
		echo "'$self' is not an absolute path!" >&2
		return 1
	fi

	if [[ $repo != ${repo:a} ]]
	then
		echo "'$repo' is not an absolute path!" >&2
		return 2
	fi

	if [[ ! -d $repo ]]
	then
		echo "'$repo' is not a directory!" >&2
		return 3
	fi

	if [[ $dir != $repo && $dir != $repo/* ]]
	then
		echo "'$dir' is not a sub-directory of '$repo'!" >&2
		return 4
	fi

	if [[ ! -d $dir ]]
	then
		echo "'$dir' is not a directory!" >&2
		return 5
	fi

	for abs in $dir/*
	do
		if [[ $abs == $self ]]
		then
			continue
		fi

		declare rel=${abs#$repo/}

		if (( $ignore[(ie)/$rel] <= ${#ignore} || $ignore[(ie)${rel:t}] <= ${#ignore} ))
		then
			continue
		fi

		if [[ -d $abs ]] && (( $recurse[(ie)$rel] <= ${#recurse} ))
		then
			symlink-all $abs
		else
			declare src=$abs
			declare dst=~/"$(override-path $rel)"

			if [[ ! -e ${dst:h} ]]
			then
				mkdir -p ${dst:h}
			fi

			if [[ ! -d ${dst:h} ]]
			then
				echo "'${dst:h}' is not a directory!" >&2
				return 6
			fi

			if [[ -L $dst ]]
			then
				rm $dst
			fi

			if [[ -e $dst ]]
			then
				echo "'$dst' already exists (and is not a symlink)!" >&2
				return 7
			fi

			ln -s $src $dst
		fi
	done
}

function override-path {
	declare file_or_dir=$1

	if [[ $file_or_dir == /* || $file_or_dir == ~/* || $file_or_dir == ./* || $file_or_dir == ../* ]]
	then
		echo "'$file_or_dir' is not a non-prefixed relative path!" >&2
		return 8
	fi

	declare prefix=$file_or_dir

	while [[ $prefix != '.' && ! -v override[$prefix] ]]
	do
		prefix=${prefix:h}
	done

	if [[ $prefix != '.' ]]
	then
		echo ${file_or_dir/$prefix/$override[$prefix]}
	else
		echo $file_or_dir
	fi
}


symlink-all
