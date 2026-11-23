#!/bin/sh

current=$(cat /sys/class/backlight/intel_backlight/brightness)
max=$(cat /sys/class/backlight/intel_backlight/max_brightness)

percent=$((current * 100 / max))

printf '%s%%' "$percent"
