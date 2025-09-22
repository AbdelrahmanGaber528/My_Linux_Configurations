#!/usr/bin/env bash

PID_FILE="/tmp/screenrecord.pid"
OUTPUT_DIR="$HOME/Videos/Records"
mkdir -p "$OUTPUT_DIR"

if [ -f "$PID_FILE" ]; then
    # Stop recording
    kill "$(cat "$PID_FILE")"
    rm "$PID_FILE"
    notify-send "📹 Screen Recording" "Recording stopped"
else
    # Start recording (video only, no audio)
    OUTPUT_FILE="$OUTPUT_DIR/record_$(date +'%Y-%m-%d_%H-%M-%S').mp4"
    wf-recorder -f "$OUTPUT_FILE" &
    echo $! > "$PID_FILE"
    notify-send "📹 Screen Recording" "Recording started"
fi

