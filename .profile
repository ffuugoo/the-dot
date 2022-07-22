declare CARGO=$HOME/.cargo
declare ENV=$HOME/Development/.env
declare PYTHON=$HOME/Library/Python/3.9/bin
declare BREW=/usr/local/opt

export PATH=$CARGO/bin:$ENV/gnubin:$ENV/nxlog/bin:$ENV/xcc/bin:$PYTHON:$BREW/apr/bin:$BREW/openjdk/bin:$PATH


declare LIBS=( apr libiconv openssl@1.1 pcre2 )

export CPPFLAGS=${:--I/usr/local/opt/${^LIBS}/include}
export LDFLAGS=${:--L/usr/local/opt/${^LIBS}/lib}


export DISPLAY=SHITFUCK
