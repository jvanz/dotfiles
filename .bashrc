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

export PATH=$PATH:$HOME/.local/bin:$GOPATH/bin

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

