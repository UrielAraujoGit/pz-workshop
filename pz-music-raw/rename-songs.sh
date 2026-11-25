#!/bin/bash
set -euo pipefail
shopt -s nullglob

declare -A destinations=()
for file in [0-9][0-9]' - '*.ogg; do
    [[ -f $file ]] || continue
    new_name=${file#[0-9][0-9] - }
    if [[ $new_name == .ogg || -e $new_name || -L $new_name || -n ${destinations[$new_name]+exists} ]]; then
        printf 'No se puede renombrar %s a %s\n' "$file" "$new_name" >&2
        exit 1
    fi
    destinations[$new_name]=$file
done

for new_name in "${!destinations[@]}"; do
    file=${destinations[$new_name]}
    mv -nT -- "$file" "$new_name"
    if [[ -e $file || -L $file ]]; then
        printf 'El destino ya existe: %s\n' "$new_name" >&2
        exit 1
    fi
    printf 'Renombrado: %s -> %s\n' "$file" "$new_name"
done
