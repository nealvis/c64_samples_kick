//////////////////////////////////////////////////////////////////////////////
// astro_keyboard_macs.asm
//////////////////////////////////////////////////////////////////////////////

#importonce 
#import "../nv_c64_util/nv_c64_util_macs.asm"

// These are the keys that do something in the game
.const KEY_SHIP1_SLOW_X = NV_KEY_A
.const KEY_SHIP1_FAST_X = NV_KEY_D
.const KEY_QUIT = NV_KEY_Q
.const KEY_PAUSE = NV_KEY_P
.const KEY_INC_BORDER_COLOR = NV_KEY_0
.const KEY_DEC_BORDER_COLOR = NV_KEY_9
.const KEY_INC_BACKGROUND_COLOR = NV_KEY_8
.const KEY_DEC_BACKGROUND_COLOR = NV_KEY_7
.const KEY_INC_VOLUME = NV_KEY_PERIOD
.const KEY_DEC_VOLUME = NV_KEY_COMMA
//.const KEY_PLAY = NV_KEY_SPACE

.const KEY_EXPERIMENTAL_01 = NV_KEY_V
.const KEY_EXPERIMENTAL_02 = NV_KEY_B
.const KEY_EXPERIMENTAL_03 = NV_KEY_N
.const KEY_EXPERIMENTAL_04 = NV_KEY_M
.const KEY_EXPERIMENTAL_05 = NV_KEY_O

.const KEY_WINNER_CONTINUE = NV_KEY_P