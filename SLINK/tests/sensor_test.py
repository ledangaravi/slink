#! /usr/bin/env python3

import sensor
import time

s = sensor.LoadSensor()
s.config_amp_gain(7)
s.config_set_input_MUX(0)
s.config_set_data_rate(8)
s.config_set_mode(0)

print("Calibrating...")
s.calibrate()
print("Calibrated.")

time.sleep(2)

while (True):
    sample = s.get_sample()
    print(sample)
