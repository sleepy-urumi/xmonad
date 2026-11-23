#!/usr/bin/env bash

set -uo pipefail

STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/focus-mode-$UID"
STATE_FILE="$STATE_DIR/processes"

mkdir -p "$STATE_DIR"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

log() {
    echo -e "${GREEN}[FOCUS]${RESET} $*"
}

warn() {
    echo -e "${YELLOW}[FOCUS]${RESET} $*"
}

# Programs to stop during focus mode.
# Add more applications if you want.
PROCESSES=(
    picom
    conky
    copyq
    flameshot
    variety
    nitrogen
    caffeine
    blueman-applet
    pavucontrol
)

start_focus() {
    if [[ -f "$STATE_FILE" ]]; then
        warn "Focus mode is already active."
        return
    fi

    touch "$STATE_FILE"

    log "Entering focus mode..."

    for proc in "${PROCESSES[@]}"; do
        if pgrep -x "$proc" >/dev/null 2>&1; then
            echo "$proc" >> "$STATE_FILE"
            pkill -TERM -x "$proc" 2>/dev/null || true
            log "Stopped $proc"
        fi
    done

    log "Focus mode enabled."
}

stop_focus() {
    if [[ ! -f "$STATE_FILE" ]]; then
        warn "Focus mode is not active."
        return
    fi

    log "Leaving focus mode..."

    while IFS= read -r proc; do
        case "$proc" in
            picom)
                picom >/dev/null 2>&1 &
                ;;
            conky)
                conky >/dev/null 2>&1 &
                ;;
            copyq)
                copyq >/dev/null 2>&1 &
                ;;
            flameshot)
                flameshot >/dev/null 2>&1 &
                ;;
            variety)
                variety >/dev/null 2>&1 &
                ;;
            nitrogen)
                nitrogen --restore >/dev/null 2>&1 &
                ;;
            caffeine)
                caffeine >/dev/null 2>&1 &
                ;;
            blueman-applet)
                blueman-applet >/dev/null 2>&1 &
                ;;
            pavucontrol)
                pavucontrol >/dev/null 2>&1 &
                ;;
        esac

        log "Restored $proc"
    done < "$STATE_FILE"

    rm -f "$STATE_FILE"

    log "Normal mode restored."
}


show_help() {
    echo "Focus Mode - XMonad"
    echo
    echo "Usage: focus_mode.sh [OPTION]"
    echo
    echo "Options:"
    echo "  start     Enable focus mode"
    echo "  stop      Disable focus mode and restore processes"
    echo "  toggle    Toggle focus mode (default)"
    echo "  status    Show current focus mode status"
    echo "  help      Show this help message"
    echo
    echo "Examples:"
    echo "  focus_mode.sh"
    echo "  focus_mode.sh start"
    echo "  focus_mode.sh stop"
    echo "  focus_mode.sh toggle"
    echo "  focus_mode.sh status"
}

case "${1:-toggle}" in
    start)
        start_focus
        ;;
    stop)
        stop_focus
        ;;
    toggle)
        if [[ -f "$STATE_FILE" ]]; then
            stop_focus
        else
            start_focus
        fi
        ;;
    status)
        if [[ -f "$STATE_FILE" ]]; then
            log "Focus mode is ON"
        else
            log "Focus mode is OFF"
        fi
        ;;
    help|-h|--help)
        show_help
        ;;
    *)
        warn "Unknown option: $1"
        echo
        show_help
        exit 1
        ;;
esac
