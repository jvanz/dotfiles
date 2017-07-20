#!/bin/bash

# TMUX
if which tmux >/dev/null 2>&1; then
	#if not inside a tmux session, and if no session is started, start a new session
	test -z "$TMUX" && (tmux attach || tmux new-session)
fi

alias lla="ll -a"
alias myip="curl http://ipecho.net/plain; echo"
alias ..="cd .."
alias ...="cd ../.."
alias clipboard='xclip -sel clip'

export MAINTAINER="guilherme.sft@gmail.com"
export MALLOC_PERTURB_=$(($RANDOM % 255 + 1))
export EDITOR="vim"
export GYP_GENERATORS=ninja

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

