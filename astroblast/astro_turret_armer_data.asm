//////////////////////////////////////////////////////////////////////////////
// astro_turret_armer_data.asm
// file contains the data for turret 3 frames as they are stepped through.

#importonce

#import "../nv_c64_util/nv_color_macs.asm"
//#import "../nv_c64_util/nv_screen_rect_macs.asm"
#import "../nv_c64_util/nv_screen_macs.asm"
#import "astro_vars_data.asm"

/////////////////
// starfield consts and variables

//.const STAR_COLOR = NV_COLOR_LITE_GREY
//.const STAR_CHAR_SMALL = $2E 
//.const STAR_CHAR_MED = $51

// number of steps which in this case won't be the same as number of frames
// frames for turret effect
.const TURRET_ARM_FRAMES=5

// number of seconds it should take to arm the turret
.const TURRET_SECONDS_TO_ARM = 1.75

// number of frames it takes before a step should be made
.const TURRET_FRAMES_BETWEEN_STEPS = ((TURRET_SECONDS_TO_ARM * ASTRO_FPS) / TURRET_ARM_FRAMES)



// when turret arming starts this will be non zero and count down each frame
turret_arm_count: .byte $00
turret_currently_armed: .byte $00
turret_second_counter: .byte $00
turret_second_saved_value: .byte $00

// count down some number of frames between steps.  This is the counter.
turret_arm_frame_counter: .byte $00   

// table of the addresses of all the streams for each frame for turret 2
TurretArmStreamAddrTable:
    .word turret_arm_stream_frame_1
    .word turret_arm_stream_frame_2
    .word turret_arm_stream_frame_3
    .word turret_arm_stream_frame_4
    .word turret_arm_stream_frame_5


turret_arm_stream_empty_frame:
    .word $FFFF
    .word $FF


.const TURRET_ARM_ROW = 10
.const TURRET_ARM_COL = 38
.const TURRET_ARM_CHAR_TOP = $53
.const TURRET_ARM_CHAR_BOTTOM = $4A

turret_arm_stream_frame_1:
/*
    .word $FFFF
    .byte $01, TURRET_ARM_CHAR_TOP
    .word nv_screen_char_addr_from_yx(TURRET_ARM_ROW, TURRET_ARM_COL)

    .word $FFFF
    .byte $01, TURRET_ARM_CHAR_BOTTOM
    .word nv_screen_char_addr_from_yx(TURRET_ARM_ROW+1, TURRET_ARM_COL)
*/
    .word $FFFF
    .byte $01, NV_COLOR_RED
    .word nv_screen_color_addr_from_yx(TURRET_ARM_ROW, TURRET_ARM_COL)
    .word nv_screen_color_addr_from_yx(TURRET_ARM_ROW+1, TURRET_ARM_COL)

    .word nv_screen_color_addr_from_yx(TURRET_ARM_ROW+3, TURRET_ARM_COL)
    .word nv_screen_color_addr_from_yx(TURRET_ARM_ROW+4, TURRET_ARM_COL)

    .word $FFFF
    .word $FF

turret_arm_stream_frame_2:
    .word $FFFF
    .byte $01, NV_COLOR_LITE_RED
    .word nv_screen_color_addr_from_yx(TURRET_ARM_ROW, TURRET_ARM_COL)
    .word nv_screen_color_addr_from_yx(TURRET_ARM_ROW+1, TURRET_ARM_COL)

    .word nv_screen_color_addr_from_yx(TURRET_ARM_ROW+3, TURRET_ARM_COL)
    .word nv_screen_color_addr_from_yx(TURRET_ARM_ROW+4, TURRET_ARM_COL)

    .word $FFFF
    .word $FF


turret_arm_stream_frame_3:
    .word $FFFF
    .byte $01, NV_COLOR_LITE_GREY
    .word nv_screen_color_addr_from_yx(TURRET_ARM_ROW, TURRET_ARM_COL)
    .word nv_screen_color_addr_from_yx(TURRET_ARM_ROW+1, TURRET_ARM_COL)

    .word nv_screen_color_addr_from_yx(TURRET_ARM_ROW+3, TURRET_ARM_COL)
    .word nv_screen_color_addr_from_yx(TURRET_ARM_ROW+4, TURRET_ARM_COL)

    .word $FFFF
    .word $FF


turret_arm_stream_frame_4:
    .word $FFFF
    .byte $01, NV_COLOR_LITE_GREY
    .word nv_screen_color_addr_from_yx(TURRET_ARM_ROW, TURRET_ARM_COL)
    .word nv_screen_color_addr_from_yx(TURRET_ARM_ROW+1, TURRET_ARM_COL)

    .word nv_screen_color_addr_from_yx(TURRET_ARM_ROW+3, TURRET_ARM_COL)
    .word nv_screen_color_addr_from_yx(TURRET_ARM_ROW+4, TURRET_ARM_COL)

    .word $FFFF
    .word $FF


turret_arm_stream_frame_5:    
    .word $FFFF
    .byte $01, NV_COLOR_YELLOW
    .word nv_screen_color_addr_from_yx(TURRET_ARM_ROW, TURRET_ARM_COL)
    .word nv_screen_color_addr_from_yx(TURRET_ARM_ROW+1, TURRET_ARM_COL)

    .word nv_screen_color_addr_from_yx(TURRET_ARM_ROW+3, TURRET_ARM_COL)
    .word nv_screen_color_addr_from_yx(TURRET_ARM_ROW+4, TURRET_ARM_COL)

    .word $FFFF
    .word $FF


