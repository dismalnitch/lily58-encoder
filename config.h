#pragma once

// The stock mechboards/lily58/pro keyboard.json only declares the left
// encoder. Add the right-half encoder pins here. The Helios converter
// remaps these AVR-style labels to RP2040 GPIOs at compile time.
#define ENCODER_A_PINS_RIGHT { F5 }
#define ENCODER_B_PINS_RIGHT { F4 }