#!/usr/bin/env bash

BOOK_DIR="$HOME/void/Books"

# Step 1: List folders
mapfile -t FOLDERS < <(find "$BOOK_DIR" -mindepth 1 -maxdepth 1 -type d -printf "%f\n")

# Show folders in Rofi
SELECTED_FOLDER=$(printf "%s\n" "${FOLDERS[@]}" | rofi -dmenu -i -p "Select Folder")

if [ -n "$SELECTED_FOLDER" ]; then
    TARGET_DIR="$BOOK_DIR/$SELECTED_FOLDER"

    # Step 2: List books inside selected folder
    mapfile -t BOOK_PATHS < <(find "$TARGET_DIR" -type f \( -iname "*.pdf" -o -iname "*.xopp" -o -iname "*.epub" -o -iname "*.xxp" \))
    BOOK_NAMES=()
    for path in "${BOOK_PATHS[@]}"; do
        BOOK_NAMES+=("$(basename "$path")")
    done

    # Show books in Rofi
    SELECTED_BOOK=$(printf "%s\n" "${BOOK_NAMES[@]}" | rofi -dmenu -i -p "Select Book")

    # Open selected book
    if [ -n "$SELECTED_BOOK" ]; then
        for i in "${!BOOK_NAMES[@]}"; do
            if [[ "${BOOK_NAMES[$i]}" == "$SELECTED_BOOK" ]]; then
                xournalpp "${BOOK_PATHS[$i]}"
                break
            fi
        done
    fi
fi

