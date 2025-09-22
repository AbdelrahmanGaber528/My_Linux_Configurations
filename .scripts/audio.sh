#!/usr/bin/env bash

# Set your music directory
MUSIC_DIR="$HOME/void/Audio/"
FILE=$(find "$MUSIC_DIR" -type f \( -iname "*.mp3" -o -iname "*.wav" -o -iname "*.flac" \) \
    -printf "%f\n" | \
    rofi -dmenu -i -p "Choose a track:")

# Exit if no selection
[ -z "$FILE" ] && exit

# Find full path by filename
FULL_PATH=$(find "$MUSIC_DIR" -type f -name "$FILE" | head -n 1)

# Kill any previous mpv instance (optional)
pkill -x mpv 2>/dev/null

# Start mpv in background (no terminal output)
mpv --no-terminal --quiet "$FULL_PATH" &

# Run cava in a terminal to see animations
TERMINAL="${TERMINAL:-kitty}"
$TERMINAL -e cava
