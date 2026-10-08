#!/bin/bash

for file in *.ogg; do
    new_name="${file#[0-9][0-9] - }"

    if [[ "$file" != "$new_name" ]]; then
        mv -- "$file" "$new_name"
        echo "Renombrado: $file -> $new_name"
    fi
done