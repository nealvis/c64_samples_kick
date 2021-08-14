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
