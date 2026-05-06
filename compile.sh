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

echo "==> Generating keymap.c from $json"
qmk json2c -o keymap.c "$json"

echo "==> Compiling firmware (CONVERT_TO=helios)"
qmk compile -e CONVERT_TO=helios "$json"

qmk_home="${QMK_HOME:-$HOME/qmk_firmware}"

uf2=$(ls -t "$qmk_home"/*lily58*helios*.uf2 2>/dev/null | head -n 1)
if [[ -n "$uf2" ]]; then
    cp "$uf2" .
    echo "==> Copied $(basename "$uf2") to $(pwd)"
else
    echo "Warning: no .uf2 found in $qmk_home" >&2
fi
