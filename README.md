# lily58-encoder

QMK keymap for a Mechboards Lily58 Pro with a Helios (RP2040) controller and one rotary encoder on the left half.

## Workflow

The keymap arrays are authored in **QMK Configurator** and exported as `lily58pro_enc.vN.json`. Custom C (encoder behavior, future macros) lives in `encoder.inc`. `compile.sh` glues them together.

```
lily58pro_enc.vN.json  →  qmk json2c  →  keymap.c
                                            +
                                       encoder.inc
                                            ↓
                ~/qmk_firmware/keyboards/mechboards/lily58/pro/keymaps/lily58pro_enc/keymap.c
                                            +
                                         rules.mk
                                            ↓
                                qmk compile -e CONVERT_TO=helios
                                            ↓
                                          .uf2
```

### Editing the keymap

1. Open the latest `lily58pro_enc.vN.json` in [QMK Configurator](https://config.qmk.fm).
2. Make changes, export as a new `lily58pro_enc.v(N+1).json` next to the others.
3. Run `./compile.sh` — it picks the highest-versioned JSON automatically.
4. Pass an explicit file to override: `./compile.sh lily58pro_enc.v3.json`.

### Editing encoder behavior

Edit `encoder.inc`, then rerun `./compile.sh`. The JSON is untouched.

### Flashing

Double-tap reset on the left half (Helios), wait for `RPI-RP2` to mount, then:

```sh
cp mechboards_lily58_pro_lily58pro_enc_helios.uf2 /Volumes/RPI-RP2/
```

Repeat for the right half. (The encoder is on the left, but both halves run the same firmware.)

## Encoder behavior: A vs B

QMK offers two ways to define encoder behavior; `encoder.inc` is set up for **B** by default but supports **A** if you uncomment the callback block.

### B. `encoder_map` (declarative, layer-aware)

```c
const uint16_t PROGMEM encoder_map[][NUM_ENCODERS][NUM_DIRECTIONS] = {
    [0] = { ENCODER_CCW_CW(KC_VOLD, KC_VOLU) },
    [1] = { ENCODER_CCW_CW(KC_PGUP, KC_PGDN) },
    ...
};
```

- One row per layer, one entry per encoder, two keycodes per entry (CCW, CW).
- Best when each layer wants different encoder behavior with plain keycodes.
- Requires `ENCODER_MAP_ENABLE = yes` in `rules.mk`.

### A. `encoder_update_user` (callback)

```c
bool encoder_update_user(uint8_t index, bool clockwise) {
    if (index == 0) tap_code(clockwise ? KC_VOLU : KC_VOLD);
    return false;
}
```

- Arbitrary C — conditionals, macros, mod-aware behavior, multi-tap, etc.
- Not layer-aware on its own; you'd inspect `get_highest_layer(layer_state)` yourself.
- Works without `ENCODER_MAP_ENABLE`.

### Using both

A and B can coexist. `encoder_update_user` runs first; return `true` to fall through to `encoder_map`, `false` to override. Good for "fancy on layer 0, plain map elsewhere."

## File index

| file | purpose | edited by |
|---|---|---|
| `lily58pro_enc.v*.json` | keymap layers (versioned) | QMK Configurator |
| `encoder.inc` | encoder map / callback | hand |
| `rules.mk` | per-keymap build flags | hand |
| `config.h` | extra `#define`s (right-half encoder pins, etc.) | hand |
| `keymap.c` | `qmk json2c` output, for inspection only | generated |
| `compile.sh` | end-to-end build | hand |
| `*.uf2` | flashable firmware | generated |

## Encoders

Two rotary encoders, one on each half:

- **Left** (`index 0`) — declared in the upstream `keyboard.json`.
- **Right** (`index 1`) — added via this repo's `config.h` (`ENCODER_*_PINS_RIGHT`), since the stock `keyboard.json` doesn't declare it.

Behavior is defined in `encoder.inc`. The callback (`encoder_update_user`) handles macro entries and falls through to `encoder_map` for everything else.