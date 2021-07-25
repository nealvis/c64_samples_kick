
//////////////////////////////////////////////////////////////////////////////
// astro_vars_data.asm
#import "../nv_c64_util/nv_color_macs.asm"

#importonce

border_color: .byte NV_COLOR_BLUE
background_color: .byte NV_COLOR_BLACK

// some loop indices
frame_counter: .word 0
second_counter: .word 0
change_up_counter: .word 0
second_partial_counter: .word 0
key_cool_counter: .byte 0
quit_flag: .byte 0                  // set to non zero to quit
sprite_collision_reg_value: .byte 0 // updated each frame with sprite coll

cycling_color: .byte NV_COLOR_FIRST
change_up_flag: .byte 0
