#!/bin/bash

convertOgg() {
    local input="$1"
    output="$OUTPUT_DIR/$(basename "$filename").ogg"

    # Skip if the OGG already exists
    if [ -f "$output" ]; then
        echo "Skipping: $i (already converted)"
        continue
    fi

    echo "Converting: $i -> $output"

    ffmpeg -i "$i" -vn -c:a libvorbis -q:a 8 -f ogg "$output"
}