HISTFILE=~/.zhistory
HISTSIZE=10000
SAVEHIST=10000


declare opts=(
	inc_append_history

	hist_fcntl_lock

	hist_save_no_dups

	hist_expire_dups_first
	hist_ignore_all_dups
	hist_ignore_dups

	hist_find_no_dups

	hist_ignore_space
	hist_no_functions
	hist_no_store

	hist_reduce_blanks

	hist_verify


	cd_silent
	pushd_silent

	always_to_end
	complete_in_word
	no_list_beep

	correct
	correct_all

	# glob_dots
	# numeric_glob_sort
	# magic_equal_subst

	interactive_comments
)

setopt $opts


zstyle ':completion:*' menu select

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zcompcache


if [[ ! -e ~/.zcomet || -d ~/.zcomet ]]
then
	if [[ ! -e ~/.zcomet ]]
	then
		git clone https://github.com/agkozak/zcomet.git ~/.zcomet/bin
	fi

	if [[ -e ~/.zcomet/bin/zcomet.zsh ]] && source ~/.zcomet/bin/zcomet.zsh
	then
		zcomet fpath zsh-users/zsh-completions src

		zcomet load zdharma-continuum/fast-syntax-highlighting
		zcomet load hlissner/zsh-autopair

		# zcomet load romkatv/gitstatus

		if [[ -v TERM_PROGRAM && $TERM_PROGRAM == 'iTerm.app' ]]
		then
			zcomet snippet /Applications/iTerm.app/Contents/Resources/iterm2_shell_integration.zsh
		fi

		zstyle ':zcomet:compinit' dump-file ~/.zcompdump

		zcomet compinit
	fi
fi

if ! functions zcomet &>/dev/null
then
	autoload -U compinit && compinit
fi


declare -A ps

if functions iterm2_prompt_mark &>/dev/null
then
	ps[iterm2]="%{$(iterm2_prompt_mark)%}"
fi

if [[ $USER != ffuugoo && $USER != root ]]
then
	ps[user]=%n
fi

if [[ -v SSH_CLIENT ]]
then
	ps[host]=%m
fi

ps[at]=${ps[user]:+${ps[host]:+@}}
ps[user-host-sep]=${ps[user]:+${ps[host]:+ }}

ps[user-host]=${ps[user]}${ps[at]}${ps[host]}${ps[user-host-sep]}

ps[prompt]='%(?:%F{blue}:%F{red})%B%#%f%b '
ps[status]='%(?::%F{red}%B(%?%)%f%b )'
ps[pwd]='%50<...<%~%<<'

declare PS1=${ps[iterm2]}${ps[user-host]}${ps[prompt]}
declare RPS1=${ps[status]}${ps[pwd]}


declare -A key

function key { [[ $# -eq 2 && -n $1 && -n $2 && -v terminfo[$2] ]] && key[$1]=$terminfo[$2] }
function bind { [[ $# -eq 2 && -n $1 && -n $2 && -v key[$1] ]] && bindkey -- $key[$1] $2 }

key  Backspace   kbs
key  Delete      kdch1
key  Up          kcuu1
key  Down        kcud1
key  Left        kcub1
key  Right       kcuf1
key  Alt-Up      kUP3
key  Alt-Down    kDN3
key  Alt-Left    kLFT3
key  Alt-Right   kRIT3
key  Home        khome
key  End         kend
key  PageUp      kpp
key  PageDown    knp
key  Shift-Tab   kcbt

bind  Backspace   backward-delete-char
bind  Delete      delete-char
bind  Up          up-line-or-history
bind  Down        down-line-or-history
bind  Left        backward-char
bind  Right       forward-char
bind  Alt-Up      history-beginning-search-backward
bind  Alt-Down    history-beginning-search-forward
bind  Alt-Left    backward-word
bind  Alt-Right   forward-word
bind  Home        beginning-of-line
bind  End         end-of-line
bind  PageUp      beginning-of-buffer-or-history
bind  PageDown    end-of-buffer-or-history
bind  Shift-Tab   reverse-menu-complete

bindkey  '\E[<=>?~'  backward-delete-word

if [[ -v terminfo[smkx] && -v terminfo[rmkx] ]]
then
	function zle-line-init { echoti smkx } && zle -N zle-line-init
	function zle-line-finish { echoti rmkx } && zle -N zle-line-finish
fi


alias clear="clear && printf '\e[3J'"
alias less="less -F --mouse --wheel-lines=3"
alias ls="ls --color=auto"
