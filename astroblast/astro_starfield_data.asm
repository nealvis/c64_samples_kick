//////////////////////////////////////////////////////////////////////////////
// astro_turret_6_data.asm
// file contains the data for turret 3 frames as they are stepped through.

#importonce

#import "../nv_c64_util/nv_color_macs.asm"
//#import "../nv_c64_util/nv_screen_rect_macs.asm"
#import "../nv_c64_util/nv_screen_macs.asm"


/////////////////
// turret 6 consts and variables
//.const TURRET_6_START_ROW = 14
//.const TURRET_6_START_COL = 37
//.const TURRET_6_X_VEL = -3
//.const TURRET_6_Y_VEL = 1
//.const TURRET_6_CHAR_MEM_START = 1024 + (TURRET_6_START_ROW * 40) + 37  // 1621
//.const TURRET_6_COLOR_MEM_START = $D800 + (TURRET_6_CHAR_MEM_START - 1024)
//.const TURRET_6_MEM_VEL = ((40*TURRET_6_Y_VEL) + (TURRET_6_X_VEL))  //-43

.const STAR_COLOR = NV_COLOR_LITE_GREY
.const STAR_CHAR_SMALL = $2E 

// number of raster frames for turret effect
.const STAR_FRAMES=3

// when starfield starts this will be non zero and count down each frame
// until the starfield animation effect is done.
star_count: .byte $00

star_char_addr_list:
    .word nv_screen_char_addr_from_yx(3, 12)
    .word nv_screen_char_addr_from_yx(10, 35)
    .word nv_screen_char_addr_from_yx(4, 20)
    .word nv_screen_char_addr_from_yx(15, 25)
    .word nv_screen_char_addr_from_yx(20, 37)
    .word nv_screen_char_addr_from_yx(23, 27)
    .word nv_screen_char_addr_from_yx(7, 15)
    .word nv_screen_char_addr_from_yx(22, 38)
    .word nv_screen_char_addr_from_yx(6, 4)
    .word nv_screen_char_addr_from_yx(23, 6)
    .word nv_screen_char_addr_from_yx(12, 28)
    .word nv_screen_char_addr_from_yx(6, 17)
    .word $FFFF

star_color_addr_list:
    .word nv_screen_color_addr_from_yx(3, 12)
    .word nv_screen_color_addr_from_yx(10, 35)
    .word nv_screen_color_addr_from_yx(4, 20)
    .word nv_screen_color_addr_from_yx(15, 25)
    .word nv_screen_color_addr_from_yx(20, 37)
    .word nv_screen_color_addr_from_yx(23, 27)
    .word nv_screen_color_addr_from_yx(7, 15)
    .word nv_screen_color_addr_from_yx(22, 38)
    .word nv_screen_color_addr_from_yx(6, 4)
    .word nv_screen_color_addr_from_yx(23, 6)
    .word nv_screen_color_addr_from_yx(12, 28)
    .word nv_screen_color_addr_from_yx(6, 17)
    .word $FFFF

// table of the addresses of all the streams for each frame for turret 2
StarStreamAddrTable:
    .word star_stream_frame_1
    .word star_stream_frame_1
    .word star_stream_frame_1

star_stream_frame_1:
        // copy the star characters to the screen memory for this frame
        .word $FFFF                 // stream command marker
        .byte $01, STAR_CHAR_SMALL  // new src byte is small star character
        .word $FFFF                 // command marker
        .byte $03                   // dest list command
        .word star_char_addr_list   // the address of a list of dest addrs

        // copy the color for the star characters to the screen
        .word $FFFF                 // stream command marker
        .byte $01, STAR_COLOR       // star color
        .word $FFFF                 // stream cmd marker
        .byte $03                   // dest list cmd 
        .word star_color_addr_list  // address of list of addrs in color mem

        // end the frame
        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command

