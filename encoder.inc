// Encoder behavior — appended to the json2c-generated keymap.c by compile.sh.
//
// Encoder layout:
//   index 0 = left half encoder  (declared in keyboard.json)
//   index 1 = right half encoder (declared in this repo's config.h)
//
// Strategy: encoder_map for plain keycodes, with encoder_update_user for the
// one macro entry (layer 0 right encoder = tmux prev/next window). The
// callback runs first and returns true to fall through to encoder_map for
// everything it doesn't handle. See README for the A vs B writeup.

#if defined(ENCODER_MAP_ENABLE)
const uint16_t PROGMEM encoder_map[][NUM_ENCODERS][NUM_DIRECTIONS] = {
    // [layer] = { left (CCW, CW),                       right (CCW, CW)                                  }
    [0] = { ENCODER_CCW_CW(KC_VOLD, KC_VOLU),            ENCODER_CCW_CW(KC_TRNS, KC_TRNS) }, // right handled in callback
    [1] = { ENCODER_CCW_CW(KC_PGUP, KC_PGDN),            ENCODER_CCW_CW(LALT(KC_LEFT), LALT(KC_RIGHT)) },
    [2] = { ENCODER_CCW_CW(KC_UP,   KC_DOWN),            ENCODER_CCW_CW(KC_LEFT, KC_RGHT) },
    [3] = { ENCODER_CCW_CW(KC_TRNS, KC_TRNS),            ENCODER_CCW_CW(KC_TRNS, KC_TRNS) },
};
#endif

bool encoder_update_user(uint8_t index, bool clockwise) {
    // Layer 0, right encoder: tmux window navigation. Send the tmux prefix
    // (Ctrl+B) then P (prev) or N (next).
    if (index == 1 && get_highest_layer(layer_state) == 0) {
        tap_code16(RCTL(KC_B));
        tap_code(clockwise ? KC_N : KC_P);
        return false;  // handled
    }
    return true;  // fall through to encoder_map
}
