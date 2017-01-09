#!/usr/bin/env python3

import vim
from requests import get

OPEN_WEATHER_API_KEY = "your Open Weather API key"

def get_weather():
    """
    Get weather from each line in the buffer
    """
    buff = vim.current.buffer
    for idx, line in enumerate(buff):
        buff[idx] = line + "\t" + get_openweather(line)["weather"][0]["main"] # append the weather in the line


def get_weather_selection():
    """
    Method to demonstrate a "possible" integration between vim and python
    """
    buf = vim.current.buffer # get current vim buffer
    start = buf.mark("<") # get the begin of the selection
    end = buf.mark(">") # get the end of the selection
    location = get_text(start, end) # get the selection text with the city name
    line = buf[end[0]-1] + "\t" + get_openweather(location)["weather"][0]["main"] # append the weather in the line
    buf[end[0]-1] = line # update line in the buffer

def get_text(start, end):
    """
    Method used to get the text delimited by start and end markers
    """
    buf = vim.current.buffer
    text = ""
    for line in buf[start[0]-1:end[0]]:
        text += line
    last_index = (len(text) - len(buf[end[0]-1])) + end[1] + 1
    return text[start[1]:last_index]

def get_openweather(city):
    url="http://api.openweathermap.org/data/2.5/weather" # open weather endpoint
    payload = {"q": city, "APPID": OPEN_WEATHER_API_KEY} # prepare the request params
    request = get(url, payload) # send request to the Open Weather API
    return request.json()
