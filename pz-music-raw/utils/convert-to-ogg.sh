#!/bin/bash

convertOgg() {
    local input=$1 output=$2
    ffmpeg -nostdin -hide_banner -loglevel error -y -i "$input" \
        -map 0:a:0 -c:a libvorbis -q:a 8 -f ogg "$output"
}
