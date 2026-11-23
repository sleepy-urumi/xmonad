#!/bin/bash

CONFIRM=$(printf 'No\nYes' | dmenu \
    -i \
    -fn "EB Garamond-14" \
    -nb "#2A2D3F" \
    -nf "#C6D9C1" \
    -sb "#41465C" \
    -sf "#c5a04b" \
    -p "Confirm suspending?")

if [ "$CONFIRM" = "Yes" ]; then
    
    loginctl suspend && sleep 1 && betterlockscreen -l
else

    dunstify \
    --appname="System" \
    --icon=system-suspend \
    --timeout=4000 \
    "  ✧ System" \
    "Suspending system aborted."
fi
