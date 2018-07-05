#!/bin/bash

_update_ps1() {
	PS1="$(powerline-go -error $? --newline)"
}

if [ "$TERM" != "linux" ]; then
	PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
fi
