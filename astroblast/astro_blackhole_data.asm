// astro_blackhole_data
#importonce

#import "astro_sprite_data.asm"

//////////////////
// blackhole variables and consts
.const HOLE_FRAMES = 5
.const HOLE_FRAMES_BETWEEN_STEPS = 10

// reduce velocity while count greater than 0
hole_count: .byte 0
hole_hit: .byte 0
hole_frame_counter: .byte 0

hole_sprite_data_ptr_table:
    .word sprite_hole_0
    .word sprite_hole_1
    .word sprite_hole_2
    .word sprite_hole_3
    .word sprite_hole_4


