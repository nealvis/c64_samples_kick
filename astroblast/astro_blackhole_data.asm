// astro_blackhole_data
#importonce

#import "astro_sprite_data.asm"

//////////////////
// blackhole variables and consts
.const HOLE_FRAMES = 5
.const HOLE_FRAMES_BETWEEN_STEPS = 4

// reduce velocity while count greater than 0
hole_count: .byte 0
hole_hit: .byte 0
hole_frame_counter: .byte 0
hole_change_vel_at_x_loc: .byte 0

hole_sprite_data_ptr_table:
    .word sprite_explosion_0
    .word sprite_explosion_1
    .word sprite_explosion_2
    .word sprite_explosion_3
    .word sprite_explosion_4

/*
    .word sprite_hole_2
    .word sprite_hole_3
    .word sprite_hole_4
*/

hole_rect:
    hole_x_left:   .word 0
    hole_y_top:    .word 0
    hole_x_right:  .word 0
    hole_y_bottom: .word 0
