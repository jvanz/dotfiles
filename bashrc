#!/bin/bash

alias lt="ll -t"
alias lst="ls -t"
alias myip="curl http://ipecho.net/plain; echo"
alias ..="cd .."
alias ...="cd ../.."
alias clipboard='xclip -sel clip'
alias osc='osc -A opensuse'
alias iosc='osc -A https://api.suse.de'
alias k8s='kubectl'

export MAINTAINER="jvanz@jvanz.com"
export MALLOC_PERTURB_=$(($RANDOM % 255 + 1))
export EDITOR="nvim"
export GYP_GENERATORS=ninja
export GOPATH=$HOME/go

export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$HOME/.local/share/pkgconfig:$HOME/.local/lib/pkgconfig

export PATH=$PATH:$HOME/.local/bin:$GOPATH/bin:$HOME/.local/usr/bin

# consider packages installed in the home directory
export CFLAGS="$CFLAGS -I$HOME/.local/include"
export CPPFLAGS="$CPPFLAGS -I$HOME/.local/include"
export LDFLAGS="$LDFLAGS -L$HOME/.local/lib"
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/.local/lib

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi
