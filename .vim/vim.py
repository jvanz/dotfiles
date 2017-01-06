#!/usr/bin/env python3

import vim

def get_selection():
    buf = vim.current.buffer
    start = buf.mark("<")
    end = buf.mark(">")
    selection = ""
    for line in buf[start[0]-1:end[0]]:
        selection += line
    last_index = (len(selection) - len(buf[end[0]-1])) + end[1] + 1
    return selection[start[1]:last_index]
