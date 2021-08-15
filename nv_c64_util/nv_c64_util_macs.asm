#importonce

// verify that the nv_c64_util_data.asm file is imported some where
// because the _macs.asm files will depend on this.
#if !NV_C64_UTIL_DATA
.error "Error - nv_c64_util_macs.asm: NV_C64_UTIL_DATA not defined.  Import nv_c64_util_data.asm"
#endif

// the #if above doesn't seem to always work so..
// if data hasn't been imported yet, import it into default location
#importif !NV_C64_UTIL_DATA "nv_c64_util_default_data.asm"

// Import all the _macs.asm files here.  They will not generate any
// code or data just by importing them, but will make the macros
// available to use
#import "nv_branch16_macs.asm"
#import "nv_color_macs.asm"
#import "nv_debug_macs.asm"
#import "nv_joystick_macs.asm"
#import "nv_math8_macs.asm"
#import "nv_math16_macs.asm"
#import "nv_pointer_macs.asm"
#import "nv_screen_macs.asm"
#import "nv_sprite_extra_macs.asm"
#import "nv_sprite_macs.asm"
#import "nv_sprite_raw_macs.asm"
#import "nv_sprite_raw_collisions_macs.asm"
#import "nv_keyboard_macs.asm"
#import "nv_rand_macs.asm"
#import "nv_state_saver_macs.asm"
#import "nv_screen_rect_macs.asm"
#import "nv_stream_processor_macs.asm"

// For all the colX_tables below when there is no reasonable 
// value to poke to the screen (or when i haven't looked up
// the right value yet) for the corresponding key, 
// the table byte will be $40 which is just a grid pattern
.const NV_KEY_UNINITIALIZED = $A0
.const NV_KEY_A = $01
.const NV_KEY_B = $02
.const NV_KEY_C = $03
.const NV_KEY_D = $04
.const NV_KEY_E = $05
.const NV_KEY_F = $06
.const NV_KEY_G = $07
.const NV_KEY_H = $08
.const NV_KEY_I = $09
.const NV_KEY_J = $0A
.const NV_KEY_K = $0B
.const NV_KEY_L = $0C
.const NV_KEY_M = $0D
.const NV_KEY_N = $0E
.const NV_KEY_O = $0F
.const NV_KEY_P = $10
.const NV_KEY_Q = $11
.const NV_KEY_R = $12
.const NV_KEY_S = $13
.const NV_KEY_T = $14
.const NV_KEY_U = $15
.const NV_KEY_V = $16
.const NV_KEY_W = $17
.const NV_KEY_X = $18
.const NV_KEY_Y = $19
.const NV_KEY_Z = $1A

.const NV_KEY_0 = $30
.const NV_KEY_1 = $31
.const NV_KEY_2 = $32
.const NV_KEY_3 = $33
.const NV_KEY_4 = $34
.const NV_KEY_5 = $35
.const NV_KEY_6 = $36
.const NV_KEY_7 = $37
.const NV_KEY_8 = $38
.const NV_KEY_9 = $39

.const NV_KEY_COMMA = $2C
.const NV_KEY_PERIOD = $2E
.const NV_KEY_SPACE = $20   
.const NV_KEY_NO_KEY = $40  // Special value for no key
.const NOKEY = NV_KEY_NO_KEY
