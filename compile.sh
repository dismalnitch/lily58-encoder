#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

KEYBOARD="mechboards/lily58/pro"
KEYMAP="lily58pro_enc"
CONVERTER="helios"

QMK_HOME="${QMK_HOME:-$HOME/qmk_firmware}"
KEYMAP_DIR="$QMK_HOME/keyboards/$KEYBOARD/keymaps/$KEYMAP"

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

echo "==> Installing keymap + encoder.inc into $KEYMAP_DIR"
mkdir -p "$KEYMAP_DIR"
cat keymap.c encoder.inc > "$KEYMAP_DIR/keymap.c"
cp rules.mk config.h "$KEYMAP_DIR/"

echo "==> Compiling firmware (CONVERT_TO=$CONVERTER)"
qmk compile -kb "$KEYBOARD" -km "$KEYMAP" -e "CONVERT_TO=$CONVERTER"

uf2=$(ls -t "$QMK_HOME"/*"$KEYMAP"*.uf2 2>/dev/null | head -n 1)
if [[ -n "$uf2" ]]; then
    cp "$uf2" .
    echo "==> Copied $(basename "$uf2") to $(pwd)"
else
    echo "Warning: no .uf2 found in $QMK_HOME" >&2
fi