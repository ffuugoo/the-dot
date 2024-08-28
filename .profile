declare CARGO=$HOME/.cargo/bin
declare PYTHON=$HOME/Library/Python/3.12/bin:/opt/homebrew/opt/python@3.12/libexec/bin
declare BREW=/opt/homebrew/bin:/opt/homebrew/sbin

export PATH=~/.local/bin:$CARGO:$PYTHON:$BREW:$PATH

export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_INSTALL_CLEANUP=1

if [[ -d /Library/Developer/CommandLineTools/usr ]]
then
	export DYLD_FALLBACK_LIBRARY_PATH=/Library/Developer/CommandLineTools/usr/lib
fi

export DISPLAY=SHITFUCK
