declare LOCAL=~/.local/bin:~/.cargo/bin:~/Library/Python/3.14/bin

declare ORBSTACK=~/.orbstack/bin

declare BREW=/opt/homebrew
declare RUST=$BREW/opt/rustup/bin
declare PYTHON=$BREW/opt/python/libexec/bin
declare MAKE=$BREW/opt/make/libexec/gnubin

export PATH=$LOCAL:$ORBSTACK:$RUST:$PYTHON:$MAKE:$PATH

export HOMEBREW_NO_ENV_HINTS=1

if [[ -d /Library/Developer/CommandLineTools/usr/lib ]]; then
    export DYLD_FALLBACK_LIBRARY_PATH=/Library/Developer/CommandLineTools/usr/lib
fi

export DISPLAY=SHITFUCK
