#!/bin/bash

alias lla="ll -a"
alias myip="curl http://ipecho.net/plain; echo"
alias ..="cd .."
alias ...="cd ../.."
alias clipboard='xclip -sel clip'

export MAINTAINER="guilherme.sft@gmail.com"
export MALLOC_PERTURB_=$(($RANDOM % 255 + 1))
export EDITOR="vim"
export GYP_GENERATORS=ninja
export GOPATH=$HOME/go

export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$HOME/.local/share/pkgconfig

export PATH=$PATH:$HOME/.local/bin:$GOPATH/bin

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

function _update_ps1() {
	PS1="$(~/go/bin/powerline-go -error $?)"
}

if [ "$TERM" != "linux" ]; then
	PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
fi
