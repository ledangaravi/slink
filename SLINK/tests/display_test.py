#! /usr/bin/env python3

import emo
import time
display = emo.Emo()

display.show_string("0|1")
time.sleep(5)
for i in range(3):
    for i in range(0, 100, 1):
        display.show_progressbar_with_text(i/100, "0|1    ")
        time.sleep(0.01)
        #display.scroll_text("Hello!")
    
    for i in range(100, 0, -1):
        display.show_progressbar_with_text(i/100, "HELLO")
        time.sleep(0.01)
    #display.scroll_text("Hello!")
display.scroll_text("HELLO")


