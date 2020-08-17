
def get_text(start, end, buf):
    """
    Method used to get the text delimited by start and end markers
    """
    text = ""
    for line in buf[start[0]-1:end[0]]:
        text += line
    last_index = (len(text) - len(buf[end[0]-1])) + end[1] + 1
    return text[start[1]:last_index]

def get_selected_text(buff):
    """
    Get the selected text for the given buffer
    """
    start = buff.mark("<") # get the begin of the selection
    end = buff.mark(">") # get the end of the selection
    return (get_text(start, end, buff), start, end)

def replace(start, end, buff, text):
    """
    Replace the string between start and end to the given text
    """
    buff[start[0]-1] = buff[start[0]-1][:start[1]] + text + buff[end[0]-1][end[1]:]
    del buff[start[0]: end[0]]
