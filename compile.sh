#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

if [[ $# -ge 1 ]]; then
    json="$1"
else
    json=$(ls -1 lily58pro_enc.v*.json 2>/dev/null \
        | sort -t v -k2 -n \
        | tail -n 1)
    if [[ -z "$json" ]]; then
        echo "No lily58pro_enc.v<num>.json files found" >&2
        exit 1
    fi
fi

echo "Compiling $json -> keymap.c"
qmk json2c -o keymap.c "$json"