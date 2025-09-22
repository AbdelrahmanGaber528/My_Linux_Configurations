#!/usr/bin/env bash

SEARCH_PATHS=(
  "$HOME/Videos"
  "$HOME/void/videos"
  "$HOME/void/courses/Full-Video"
  "$HOME/void/courses/DB-CMU"
  "$HOME/void/courses/ImageProcessing"
)

# Step 1: Choose player
CHOICE=$(echo -e "mpv (video)\nvlc (video)" | rofi -dmenu -p "Choose player")
[[ -z "$CHOICE" ]] && exit 0

# Step 2: Show folder names
FOLDER_NAMES=()
for path in "${SEARCH_PATHS[@]}"; do
  FOLDER_NAMES+=("$(basename "$path")")
done

SELECTED_FOLDER=$(printf '%s\n' "${FOLDER_NAMES[@]}" | rofi -dmenu -p "Select folder")
[[ -z "$SELECTED_FOLDER" ]] && exit 0

# Map back to full path
FOLDER=""
for i in "${!FOLDER_NAMES[@]}"; do
  if [[ "${FOLDER_NAMES[$i]}" == "$SELECTED_FOLDER" ]]; then
    FOLDER="${SEARCH_PATHS[$i]}"
    break
  fi
done

# Step 3: Get video files
mapfile -t FILES < <(find "$FOLDER" -maxdepth 1 -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.webm" \))

if [ ${#FILES[@]} -eq 0 ]; then
  rofi -e "No video files found in $SELECTED_FOLDER"
  exit 0
fi

FILENAMES=()
for f in "${FILES[@]}"; do
  FILENAMES+=("$(basename "$f")")
done

# Step 4: Choose video
SELECTED=$(printf '%s\n' "${FILENAMES[@]}" | rofi -dmenu -p "Select video")
[[ -z "$SELECTED" ]] && exit 0

FILE=""
for i in "${!FILENAMES[@]}"; do
  if [[ "${FILENAMES[$i]}" == "$SELECTED" ]]; then
    FILE="${FILES[$i]}"
    break
  fi
done

# Step 5: Kill running players
pkill -x mpv
pkill -x vlc

# Step 6: Play video
case "$CHOICE" in
  "mpv (video)")
    mpv --no-terminal --loop=inf "$FILE" &
    ;;
  "vlc (video)")
    cvlc --loop "$FILE" &
    ;;
esac

