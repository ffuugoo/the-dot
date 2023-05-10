declare CARGO=$HOME/.cargo
declare PYTHON=$HOME/Library/Python/3.11/bin:/opt/homebrew/opt/python@3.11/libexec/bin
declare BREW=/opt/homebrew/bin

export PATH=$CARGO/bin:$PYTHON:$BREW:$PATH

export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_INSTALL_CLEANUP=1
export HOMEBREW_NO_GOOGLE_ANALYTICS=1

if [[ -d /Library/Developer/CommandLineTools/usr ]]
then
	export DYLD_FALLBACK_LIBRARY_PATH=/Library/Developer/CommandLineTools/usr/lib
fi

export DISPLAY=SHITFUCK
