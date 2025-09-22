#!/usr/bin/env bash

# ----------------------------------------
# Configuration
# ----------------------------------------
WALLPAPER_DIR="${1:-$HOME/Pictures/Wallpapers}"
ROFI_THEME="$HOME/.config/rofi/wall_changer/config.rasi"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache/.wallpapers}/thumbnails"
THUMB_SIZE="400x400"

# ----------------------------------------
# Setup
# ----------------------------------------
mkdir -p "$CACHE_DIR"

# Find all valid image files in the wallpaper directory
mapfile -t IMG_FILES < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.webp" \))

# ----------------------------------------
# NEW: Synchronize Cache
# ----------------------------------------
# Create a quick lookup map of existing wallpaper basenames
declare -A existing_wallpapers
for img_file in "${IMG_FILES[@]}"; do
    existing_wallpapers["$(basename "$img_file")"]=1
done

# Loop through thumbnails and delete any that are stale (don't have a matching wallpaper)
for thumb_file in "$CACHE_DIR"/*.png; do
    # Check if the file exists to avoid errors on an empty cache
    [ -f "$thumb_file" ] || continue

    thumb_basename=$(basename "$thumb_file" .png)
    if [[ ! ${existing_wallpapers[$thumb_basename]} ]]; then
        # echo "Removing stale thumbnail: $thumb_basename"
        rm "$thumb_file"
    fi
done

# ----------------------------------------
# Main Logic
# ----------------------------------------
# Exit if no images are found
if [ "${#IMG_FILES[@]}" -eq 0 ]; then
    echo "No images found!"
    exit 1
fi

# Generate thumbnails and build the input string for Rofi
ROFI_INPUT=""
for IMG_FILE in "${IMG_FILES[@]}"; do
    BASENAME=$(basename "$IMG_FILE")
    NAME_WITHOUT_EXT="${BASENAME%.*}"
    EXTENSION="${BASENAME##*.}"

    # Truncate long names for better display in Rofi
    if [ ${#NAME_WITHOUT_EXT} -gt 22 ]; then
        DISPLAY_NAME="${NAME_WITHOUT_EXT:0:19}....${EXTENSION}"
    else
        DISPLAY_NAME="${NAME_WITHOUT_EXT}.${EXTENSION}"
    fi

    # Generate a thumbnail if it doesn't already exist in the cache
    THUMB_FILE="$CACHE_DIR/${BASENAME}.png"
    if [ ! -f "$THUMB_FILE" ]; then
        convert "$IMG_FILE" -auto-orient -thumbnail "${THUMB_SIZE}^" -gravity center -extent "$THUMB_SIZE" "$THUMB_FILE"
    fi

    # Append the formatted line to the Rofi input string
    ROFI_INPUT+="${DISPLAY_NAME}\0icon\x1f${THUMB_FILE}\0info\x1f${IMG_FILE}\n"
done

# Show the Rofi menu and get the index of the selected item
SELECTED_INDEX=$(echo -en "$ROFI_INPUT" | rofi -dmenu \
    -show-icons \
    -theme "$ROFI_THEME" \
    -p "Select Wallpaper" \
    -format 'i' \
    -selected-row 0
)

# Exit if the user cancelled (e.g., pressed Esc)
if [ -z "$SELECTED_INDEX" ]; then
    exit 0
fi

# Get the full path of the selected wallpaper using the index
WALLPAPER_PATH="${IMG_FILES[$SELECTED_INDEX]}"

# Final check to ensure the file exists before setting it
if [ ! -f "$WALLPAPER_PATH" ]; then
    echo "Error: Selected file '$WALLPAPER_PATH' not found!"
    exit 1
fi

# Use hyprctl to set the new wallpaper
hyprctl hyprpaper preload "$WALLPAPER_PATH"
hyprctl hyprpaper wallpaper "eDP-1,$WALLPAPER_PATH"
