#!/bin/sh

status=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)

if [ -z "$status" ]; then
    printf 'N/A'
    exit 0
fi

volume=$(printf '%s\n' "$status" | awk '{printf "%d", $2 * 100}')

if printf '%s' "$status" | grep -q MUTED; then
    printf 'MUTED'
else
    printf '%s%%' "$volume"
fi
