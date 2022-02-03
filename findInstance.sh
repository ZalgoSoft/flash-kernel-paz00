#!/bin/bash
# flashing led
while true ; do echo 255 > /sys/devices/soc0/gpio-leds/leds/wifi-led/brightness ; sleep 0.1 ; echo 0 > /sys/devices/soc0/gpio-leds/leds/wifi-led/brightness ; sleep 0.1;  done
-
