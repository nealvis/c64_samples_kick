//////////////////////////////////////////////////////////////////////////////
// astro_turret_6_data.asm
// file contains the data for turret 3 frames as they are stepped through.

#importonce

#import "../nv_c64_util/nv_color_macs.asm"
//#import "../nv_c64_util/nv_screen_rect_macs.asm"
#import "../nv_c64_util/nv_screen_macs.asm"


.function ScreenToColorAddr(screen_addr)
{
    .return SCREEN_COLOR_START + (screen_addr - SCREEN_START)
}


/////////////////
// starfield consts and variables

.const STAR_COLOR = NV_COLOR_LITE_GREY
.const STAR_CHAR_SMALL = $2E 
.const STAR_CHAR_MED = $51

// number of raster frames for turret effect
.const STAR_FRAMES=10

// characters that make up the ringed plannet
// C = Center, L1 = left 1, R1 = Right 1
// U1 = Up 1, D1 = down 1
.const STAR_PLANET_CHAR_C = $5A
.const STAR_PLANET_CHAR_U1_R1 = $57
.const STAR_PLANET_CHAR_D1_L1 = $1D
.const STAR_PLANET_CHAR_D1_C = $5C
.const STAR_PLANET_CHAR_C_R1 = $5C
.const STAR_PLANET_CHAR_U1_C = $5E
.const STAR_PLANET_CHAR_C_L1 = $5E

.const planet_row = 15
.const planet_col = 8

// screen character addresses for planet
.const STAR_PLAN_CHR_C_ADDR = nv_screen_char_addr_from_yx(planet_row, planet_col)
.const STAR_PLAN_CHR_U1_R1_ADDR = STAR_PLAN_CHR_C_ADDR - NV_SCREEN_CHARS_PER_ROW +1
.const STAR_PLAN_CHR_D1_L1_ADDR = STAR_PLAN_CHR_C_ADDR + NV_SCREEN_CHARS_PER_ROW -1
.const STAR_PLAN_CHR_D1_C_ADDR = STAR_PLAN_CHR_C_ADDR + NV_SCREEN_CHARS_PER_ROW
.const STAR_PLAN_CHR_C_R1_ADDR = STAR_PLAN_CHR_C_ADDR + 1
.const STAR_PLAN_CHR_U1_C_ADDR = STAR_PLAN_CHR_C_ADDR - NV_SCREEN_CHARS_PER_ROW
.const STAR_PLAN_CHR_C_L1_ADDR = STAR_PLAN_CHR_C_ADDR - 1

// color addrs for ringed planet
.const STAR_PLAN_COLOR_C_ADDR = ScreenToColorAddr(STAR_PLAN_CHR_C_ADDR)
.const STAR_PLAN_COLOR_U1_R1_ADDR = ScreenToColorAddr(STAR_PLAN_CHR_U1_R1_ADDR)
.const STAR_PLAN_COLOR_D1_L1_ADDR = ScreenToColorAddr(STAR_PLAN_CHR_D1_L1_ADDR)
.const STAR_PLAN_COLOR_D1_C_ADDR = ScreenToColorAddr(STAR_PLAN_CHR_D1_C_ADDR)
.const STAR_PLAN_COLOR_C_R1_ADDR = ScreenToColorAddr(STAR_PLAN_CHR_C_R1_ADDR)
.const STAR_PLAN_COLOR_U1_C_ADDR = ScreenToColorAddr(STAR_PLAN_CHR_U1_C_ADDR)
.const STAR_PLAN_COLOR_C_L1_ADDR = ScreenToColorAddr(STAR_PLAN_CHR_C_L1_ADDR)


// when starfield starts this will be non zero and count down each frame
// until the starfield animation effect is done.
star_count: .byte $00

// small size stars go in these addrs
star_char_small_addr_list:
    .word nv_screen_char_addr_from_yx(3, 12)
    .word nv_screen_char_addr_from_yx(10, 34)
    .word nv_screen_char_addr_from_yx(4, 20)
    .word nv_screen_char_addr_from_yx(15, 25)
    .word nv_screen_char_addr_from_yx(20, 36)
    .word nv_screen_char_addr_from_yx(23, 27)
    .word nv_screen_char_addr_from_yx(7, 15)
    .word nv_screen_char_addr_from_yx(22, 38)
    .word nv_screen_char_addr_from_yx(6, 4)
    .word nv_screen_char_addr_from_yx(23, 6)
    .word nv_screen_char_addr_from_yx(12, 28)
    .word nv_screen_char_addr_from_yx(6, 17)
    .word $FFFF

// medium size chars go in these addrs
star_char_med_addr_list:
    .word nv_screen_char_addr_from_yx(14, 22)
    .word nv_screen_char_addr_from_yx(07, 9)
    .word nv_screen_char_addr_from_yx(20, 14)
    .word nv_screen_char_addr_from_yx(4, 22)
    .word $FFFF

star_color_addr_list:
    // small stars color
    .word nv_screen_color_addr_from_yx(3, 12)
    .word nv_screen_color_addr_from_yx(10, 34)
    .word nv_screen_color_addr_from_yx(4, 20)
    .word nv_screen_color_addr_from_yx(15, 25)
    //.word nv_screen_color_addr_from_yx(20, 37)
    .word nv_screen_color_addr_from_yx(23, 27)
    .word nv_screen_color_addr_from_yx(7, 15)
    .word nv_screen_color_addr_from_yx(22, 38)
    .word nv_screen_color_addr_from_yx(6, 4)
    .word nv_screen_color_addr_from_yx(23, 6)
    .word nv_screen_color_addr_from_yx(12, 28)
    .word nv_screen_color_addr_from_yx(6, 17)

    // medium stars color
    .word nv_screen_color_addr_from_yx(14, 22)
    .word nv_screen_color_addr_from_yx(07, 9)
    .word nv_screen_color_addr_from_yx(20, 14)
    .word nv_screen_color_addr_from_yx(4, 22)

    .word $FFFF


star_color_twinkle_1_addr_list:
    // small stars color
    .word nv_screen_color_addr_from_yx(3, 12)
    .word nv_screen_color_addr_from_yx(10, 34)
    //.word nv_screen_color_addr_from_yx(4, 20)
    //.word nv_screen_color_addr_from_yx(15, 25)
    .word nv_screen_color_addr_from_yx(20, 36)
    //.word nv_screen_color_addr_from_yx(23, 27)
    .word nv_screen_color_addr_from_yx(7, 15)
    //.word nv_screen_color_addr_from_yx(22, 38)
    //.word nv_screen_color_addr_from_yx(6, 4)
    .word nv_screen_color_addr_from_yx(23, 6)
    //.word nv_screen_color_addr_from_yx(12, 28)
    .word nv_screen_color_addr_from_yx(6, 17)

    // medium stars color
    .word nv_screen_color_addr_from_yx(14, 22)
    //.word nv_screen_color_addr_from_yx(07, 9)
    //.word nv_screen_color_addr_from_yx(20, 14)
    .word nv_screen_color_addr_from_yx(4, 22)

    .word $FFFF

star_color_twinkle_2_addr_list:
    // small stars color
    //.word nv_screen_color_addr_from_yx(3, 12)
    //.word nv_screen_color_addr_from_yx(10, 34)
    .word nv_screen_color_addr_from_yx(4, 20)
    .word nv_screen_color_addr_from_yx(15, 25)
    //.word nv_screen_color_addr_from_yx(20, 36)
    //.word nv_screen_color_addr_from_yx(23, 27)
    //.word nv_screen_color_addr_from_yx(7, 15)
    //.word nv_screen_color_addr_from_yx(22, 38)
    .word nv_screen_color_addr_from_yx(6, 4)
    //.word nv_screen_color_addr_from_yx(23, 6)
    //.word nv_screen_color_addr_from_yx(12, 28)
    //.word nv_screen_color_addr_from_yx(6, 17)

    // medium stars color
    //.word nv_screen_color_addr_from_yx(14, 22)
    .word nv_screen_color_addr_from_yx(07, 9)
    .word nv_screen_color_addr_from_yx(20, 14)
    //.word nv_screen_color_addr_from_yx(4, 22)

    .word $FFFF



// table of the addresses of all the streams for each frame for turret 2
StarStreamAddrTable:
    .word star_stream_frame_1
    .word star_stream_frame_2
    .word star_stream_empty_frame
    .word star_stream_empty_frame
    .word star_stream_twinkle_1_frame
    .word star_stream_empty_frame
    .word star_stream_empty_frame
    .word star_stream_twinkle_2_frame
    .word star_stream_empty_frame
    .word star_stream_empty_frame

star_stream_empty_frame:
    .word $FFFF
    .word $FF

// Frame 1 setup the static stuff like planet
// and star characters, then in other frames 
// play with colors
star_stream_frame_1:
    // copy the small star characters to the screen memory for this frame
    .word $FFFF                 // stream command marker
    .byte $01, STAR_CHAR_SMALL  // new src byte is small star character
    .word $FFFF                 // command marker
    .byte $03                   // dest list command
    .word star_char_small_addr_list   // the address of a list of dest addrs

    // copy the medium star characters to the screen memory 
    .word $FFFF                     // stream command marker
    .byte $01, STAR_CHAR_MED        // new src byte is small star character
    .word $FFFF                     // command marker
    .byte $03                       // dest list command
    .word star_char_med_addr_list   // the address of a list of dest addrs

    // ringed planet chars
    .word $FFFF
    .byte $01, STAR_PLANET_CHAR_C 
    .word STAR_PLAN_CHR_C_ADDR
    .word $FFFF
    .byte $01, STAR_PLANET_CHAR_U1_R1
    .word STAR_PLAN_CHR_U1_R1_ADDR
    .word $FFFF
    .byte $01, STAR_PLANET_CHAR_D1_L1
    .word STAR_PLAN_CHR_D1_L1_ADDR
    .word $FFFF
    .byte $01, STAR_PLANET_CHAR_D1_C
    .word STAR_PLAN_CHR_D1_C_ADDR
    //.word $FFFF
    //.byte $01, STAR_PLANET_CHAR_C_R1
    .word STAR_PLAN_CHR_C_R1_ADDR
    .word $FFFF
    .byte $01, STAR_PLANET_CHAR_U1_C
    .word STAR_PLAN_CHR_U1_C_ADDR
    //.word $FFFF
    //.byte $01, STAR_PLANET_CHAR_C_L1
    .word STAR_PLAN_CHR_C_L1_ADDR

    // ringed planet colors
    .word $FFFF
    .byte $01, NV_COLOR_BROWN
    .word STAR_PLAN_COLOR_C_ADDR
    .word $FFFF
    .byte $01, NV_COLOR_LITE_GREY
    .word STAR_PLAN_COLOR_U1_R1_ADDR
    .word STAR_PLAN_COLOR_D1_L1_ADDR
    .word STAR_PLAN_COLOR_D1_C_ADDR
    .word STAR_PLAN_COLOR_C_R1_ADDR
    .word STAR_PLAN_COLOR_U1_C_ADDR
    .word STAR_PLAN_COLOR_C_L1_ADDR

    // end the frame
    .word $FFFF                 // stream command marker
    .byte $FF                   // stream quit command

star_stream_frame_2:
    // copy the color for the small and med star characters to the screen
    .word $FFFF                 // stream command marker
    .byte $01, STAR_COLOR       // star color
    .word $FFFF                 // stream cmd marker
    .byte $03                   // dest list cmd 
    .word star_color_addr_list  // address of list of addrs in color mem

    .word $FFFF
    .byte $FF


star_stream_twinkle_1_frame:
    // copy the color for the small and med star characters to the screen
    .word $FFFF                 // stream command marker
    .byte $01, NV_COLOR_GREY    // star color
    .word $FFFF                 // stream cmd marker
    .byte $03                   // dest list cmd 
    .word star_color_twinkle_1_addr_list  // address of list of addrs in color mem
    .word $FFFF
    .byte $FF

star_stream_twinkle_2_frame:
    // copy the color for the small and med star characters to the screen
    .word $FFFF                 // stream command marker
    .byte $01, NV_COLOR_RED   // star color
    .word $FFFF                 // stream cmd marker
    .byte $03                   // dest list cmd 
    .word star_color_twinkle_2_addr_list  // address of list of addrs in color mem
    .word $FFFF
    .byte $FF
