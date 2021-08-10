// astro_wind_data
#importonce
#import "../nv_c64_util/nv_color_macs.asm"
#import "../nv_c64_util/nv_screen_macs.asm"

.const CHAR_COLON = $3A
.const CHAR_LOWEST_LINE = $46
.const CHAR_LOW_LINE = $43
.const CHAR_MED_LINE = $44
.const CHAR_HIGH_LINE = $45
.const CHAR_DASH = $2D
.const CHAR_PERIOD = $2E

.const CHAR_CUSTOM_FULL = $1B // 27
.const CHAR_CUSTOM_SPARSE = $1C // 28
.const CHAR_CUSTOM_FULL_LINES = $1D // 29
.const CHAR_CUSTOM_MEDIUM = $1E   // 30

.const WIND_GLIMMER_FRAMES = 7

wind_glimmer_count: .byte $00

///////////////////////////////////////////////////////
.const WG_BRIGHT_COLOR = NV_COLOR_WHITE
.const WG_MED_COLOR = NV_COLOR_LITE_GREY
.const WG_DIM_COLOR = NV_COLOR_GREY

.const WG_CHAR_GALE = $1B
.const WG_CHAR_GUST = $1E
.const WG_CHAR_WIND = $1C
.const WG_CHAR_BREEZE = $3A

// table of the addresses of all the streams for each frame
WindGlimmerStreamAddrTable:
    .word wind_glimmer_stream_frame_1
    .word wind_glimmer_stream_frame_2
    .word wind_glimmer_stream_frame_3
    .word wind_glimmer_stream_frame_4
    .word wind_glimmer_stream_frame_5
    .word wind_glimmer_stream_frame_6
    .word wind_glimmer_stream_frame_7

// list of color memory locations for frame 1
wg_f1_color_addr_list:
    .word nv_screen_color_addr_from_xy(37, 1)
    .word nv_screen_color_addr_from_xy(38, 3)
    .word nv_screen_color_addr_from_xy(37, 4)
    .word nv_screen_color_addr_from_xy(36, 5)
    .word nv_screen_color_addr_from_xy(39, 6)
    .word nv_screen_color_addr_from_xy(38, 7)
    .word nv_screen_color_addr_from_xy(37, 9)
    .word nv_screen_color_addr_from_xy(36, 11)
    .word nv_screen_color_addr_from_xy(38, 12)
    .word nv_screen_color_addr_from_xy(35, 15)
    .word nv_screen_color_addr_from_xy(36, 17)
    .word nv_screen_color_addr_from_xy(37, 18)
    .word nv_screen_color_addr_from_xy(36, 19)
    .word nv_screen_color_addr_from_xy(38, 21)
    .word nv_screen_color_addr_from_xy(36, 24)
    .word $FFFF

wg_f2_color_addr_list:
    .word nv_screen_color_addr_from_xy(33, 1)
    .word nv_screen_color_addr_from_xy(31, 3)
    .word nv_screen_color_addr_from_xy(32, 4)
    .word nv_screen_color_addr_from_xy(32, 5)
    .word nv_screen_color_addr_from_xy(33, 6)
    .word nv_screen_color_addr_from_xy(34, 9)
    .word nv_screen_color_addr_from_xy(32, 12)
    .word nv_screen_color_addr_from_xy(30, 14)
    .word nv_screen_color_addr_from_xy(32, 18)
    .word nv_screen_color_addr_from_xy(33, 21)
    .word nv_screen_color_addr_from_xy(31, 23)
    .word $FFFF

wg_f3_color_addr_list:
    .word nv_screen_color_addr_from_xy(28, 3)
    .word nv_screen_color_addr_from_xy(26, 5)
    .word nv_screen_color_addr_from_xy(29, 9)
    .word nv_screen_color_addr_from_xy(26, 12)
    .word nv_screen_color_addr_from_xy(25, 14)
    .word nv_screen_color_addr_from_xy(27, 18)
    .word nv_screen_color_addr_from_xy(27, 21)
    .word nv_screen_color_addr_from_xy(26, 22)
    .word $FFFF

wg_f4_color_addr_list:
    .word nv_screen_color_addr_from_xy(24, 3)
    .word nv_screen_color_addr_from_xy(22, 5)
    .word nv_screen_color_addr_from_xy(24, 9)
    .word nv_screen_color_addr_from_xy(20, 12)
    .word nv_screen_color_addr_from_xy(21, 14)
    .word nv_screen_color_addr_from_xy(24, 18)
    .word nv_screen_color_addr_from_xy(23, 21)
    .word nv_screen_color_addr_from_xy(20, 21)
    .word $FFFF

wg_f5_color_addr_list:
    .word nv_screen_color_addr_from_xy(19, 3)
    .word nv_screen_color_addr_from_xy(18, 5)
    .word nv_screen_color_addr_from_xy(15, 12)
    .word nv_screen_color_addr_from_xy(16, 14)
    .word nv_screen_color_addr_from_xy(19, 20)
    .word nv_screen_color_addr_from_xy(16, 22)
    .word $FFFF

wg_f6_color_addr_list:
    .word nv_screen_color_addr_from_xy(13, 3)
    .word nv_screen_color_addr_from_xy(12, 9)
    .word nv_screen_color_addr_from_xy(10, 12)
    .word nv_screen_color_addr_from_xy(11, 14)
    .word nv_screen_color_addr_from_xy(13, 21)
    .word nv_screen_color_addr_from_xy(12, 23)
    .word $FFFF

wind_glimmer_stream_frame_1:
        // copy characters to screen mem for the frame
        .word $FFFF                 // stream command marker
        .byte $01, WG_CHAR_GALE     // new source byte is the gale wind char
        .word nv_screen_char_addr_from_xy(37, 1)
        .word nv_screen_char_addr_from_xy(38, 3)
        .word nv_screen_char_addr_from_xy(37, 4)
        .word nv_screen_char_addr_from_xy(36, 5)
        .word nv_screen_char_addr_from_xy(39, 6)
        .word nv_screen_char_addr_from_xy(38, 7)
        .word nv_screen_char_addr_from_xy(37, 9)
        .word nv_screen_char_addr_from_xy(36, 11)
        .word nv_screen_char_addr_from_xy(38, 12)
        .word nv_screen_char_addr_from_xy(35, 15)
        .word nv_screen_char_addr_from_xy(36, 17)
        .word nv_screen_char_addr_from_xy(37, 18)
        .word nv_screen_char_addr_from_xy(36, 19)
        .word nv_screen_char_addr_from_xy(38, 21)
        .word nv_screen_char_addr_from_xy(36, 24)

        // now copy the color to the color memory for this frame
        .word $FFFF                 // stream command marker
        .byte $01, WG_BRIGHT_COLOR   // new source byte is color
        .word $FFFF                 // command marker
        .byte $03                   // dest list command
        .word wg_f1_color_addr_list // the address of a list of dest addrs

        // end the frame
        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command


wind_glimmer_stream_frame_2:
        // copy characters to screen mem for the frame
        .word $FFFF                 // stream command marker
        .byte $01, WG_CHAR_GUST     // new source byte is the gale wind char
        .word nv_screen_char_addr_from_xy(33, 1)
        .word nv_screen_char_addr_from_xy(31, 3)
        .word nv_screen_char_addr_from_xy(32, 4)
        .word nv_screen_char_addr_from_xy(32, 5)
        .word nv_screen_char_addr_from_xy(33, 6)
        .word nv_screen_char_addr_from_xy(34, 9)
        .word nv_screen_char_addr_from_xy(32, 12)
        .word nv_screen_char_addr_from_xy(30, 14)
        .word nv_screen_char_addr_from_xy(32, 18)
        .word nv_screen_char_addr_from_xy(33, 21)
        .word nv_screen_char_addr_from_xy(31, 23)


        // now copy the color to the color memory for this frame
        .word $FFFF                 // stream command marker
        .byte $01, WG_BRIGHT_COLOR  // new source byte is color
        .word $FFFF                 // command marker
        .byte $03                   // dest list command
        .word wg_f2_color_addr_list // the address of a list of dest addrs

        // change color of Previous frame's chars to be more faint
        .word $FFFF                 // stream command marker
        .byte $01, WG_MED_COLOR     // new color
        .word $FFFF                 // command marker
        .byte $03                   // dest list command
        .word wg_f1_color_addr_list // the address of a list of dest addrs

        // end the frame
        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command


wind_glimmer_stream_frame_3:
        // copy characters to screen mem for the frame
        .word $FFFF                 // stream command marker
        .byte $01, WG_CHAR_WIND    // new source byte is the gust wind char
        .word nv_screen_char_addr_from_xy(28, 3)
        .word nv_screen_char_addr_from_xy(26, 5)
        .word nv_screen_char_addr_from_xy(29, 9)
        .word nv_screen_char_addr_from_xy(26, 12)
        .word nv_screen_char_addr_from_xy(25, 14)
        .word nv_screen_char_addr_from_xy(27, 18)
        .word nv_screen_char_addr_from_xy(27, 21)
        .word nv_screen_char_addr_from_xy(26, 22)

        // now copy the color to the color memory for this frame
        .word $FFFF                 // stream command marker
        .byte $01, WG_BRIGHT_COLOR   
        .word $FFFF                 // command marker
        .byte $03                   // dest list command
        .word wg_f3_color_addr_list // the address of a list of dest addrs

        // change color of previous frame
        // now copy the color to the color memory for this frame
        .word $FFFF                 // stream command marker
        .byte $01, WG_MED_COLOR     // new source byte is color
        .word $FFFF                 // command marker
        .byte $03                   // dest list command
        .word wg_f2_color_addr_list // the address of a list of dest addrs

        // change color of two frames back 
        .word $FFFF                 // stream command marker
        .byte $FE                   // src byte is background color
        .word $FFFF                 // command marker
        .byte $03                   // dest list command
        .word wg_f1_color_addr_list // the address of a list of dest addrs

        // end the frame
        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command


wind_glimmer_stream_frame_4:
        // copy characters to screen mem for the frame
        .word $FFFF                 // stream command marker
        .byte $01, WG_CHAR_BREEZE    // new source byte is the gust wind char
        .word nv_screen_char_addr_from_xy(24, 3)
        .word nv_screen_char_addr_from_xy(22, 5)
        .word nv_screen_char_addr_from_xy(24, 9)
        .word nv_screen_char_addr_from_xy(20, 12)
        .word nv_screen_char_addr_from_xy(21, 14)
        .word nv_screen_char_addr_from_xy(24, 18)
        .word nv_screen_char_addr_from_xy(23, 21)
        .word nv_screen_char_addr_from_xy(20, 21)


        // now copy the color to the color memory for this frame
        .word $FFFF                 // stream command marker
        .byte $01, WG_BRIGHT_COLOR   
        .word $FFFF                 // command marker
        .byte $03                   // dest list command
        .word wg_f4_color_addr_list // the address of a list of dest addrs

        // change color of previous frame
        // now copy the color to the color memory for this frame
        .word $FFFF                 // stream command marker
        .byte $01, WG_MED_COLOR     // new source byte is color
        .word $FFFF                 // command marker
        .byte $03                   // dest list command
        .word wg_f3_color_addr_list // the address of a list of dest addrs


        // change color of two frames back 
        .word $FFFF                 // stream command marker
        .byte $FE                   // background color is source byte
        .word $FFFF                 // command marker
        .byte $03                   // dest list command
        .word wg_f2_color_addr_list // the address of a list of dest addrs

        // end the frame
        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command


wind_glimmer_stream_frame_5:
        // copy characters to screen mem for the frame
        .word $FFFF                 // stream command marker
        .byte $01, WG_CHAR_BREEZE    // new source byte is the gust wind char
        .word nv_screen_char_addr_from_xy(19, 3)
        .word nv_screen_char_addr_from_xy(18, 5)
        .word nv_screen_char_addr_from_xy(15, 12)
        .word nv_screen_char_addr_from_xy(16, 14)
        .word nv_screen_char_addr_from_xy(19, 20)
        .word nv_screen_char_addr_from_xy(16, 22)

        // now copy the color to the color memory for this frame
        .word $FFFF                 // stream command marker
        .byte $01, WG_BRIGHT_COLOR   
        .word $FFFF                 // command marker
        .byte $03                   // dest list command
        .word wg_f5_color_addr_list // the address of a list of dest addrs


        // change color of previous frame to be more faint
        .word $FFFF                 // stream command marker
        .byte $01, WG_MED_COLOR     // new source byte is color
        .word $FFFF                 // command marker
        .byte $03                   // dest list command
        .word wg_f4_color_addr_list // the address of a list of dest addrs

        // change color of two frames back 
        .word $FFFF                 // stream command marker
        .byte $FE                   // background color is source byte
        .word $FFFF                 // command marker
        .byte $03                   // dest list command
        .word wg_f3_color_addr_list // the address of a list of dest addrs

        // end the frame
        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command


wind_glimmer_stream_frame_6:
        // copy characters to screen mem for the frame
        .word $FFFF                 // stream command marker
        .byte $01, WG_CHAR_BREEZE    // new source byte is the gust wind char
        .word nv_screen_char_addr_from_xy(13, 3)
        .word nv_screen_char_addr_from_xy(12, 9)
        .word nv_screen_char_addr_from_xy(10, 12)
        .word nv_screen_char_addr_from_xy(11, 14)
        .word nv_screen_char_addr_from_xy(13, 21)
        .word nv_screen_char_addr_from_xy(12, 23)

        // now copy the color to the color memory for this frame
        .word $FFFF                 // stream command marker
        .byte $01, WG_MED_COLOR   
        .word $FFFF                 // command marker
        .byte $03                   // dest list command
        .word wg_f6_color_addr_list // the address of a list of dest addrs

        // change color of previous frame to be more faint
        .word $FFFF                 // stream command marker
        .byte $01, WG_DIM_COLOR     // new source byte is color
        .word $FFFF                 // command marker
        .byte $03                   // dest list command
        .word wg_f5_color_addr_list // the address of a list of dest addrs

        // change color of two frames back 
        .word $FFFF                 // stream command marker
        .byte $FE                   // background color is source byte
        .word $FFFF                 // command marker
        .byte $03                   // dest list command
        .word wg_f4_color_addr_list // the address of a list of dest addrs

        // end the frame
        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command


wind_glimmer_stream_frame_7:
        // no new characters to screen mem for the frame

        // no new colors for new chars this frame because no new chars

        // change color of previous two frames frame to be background color
        .word $FFFF                 // stream command marker
        .byte $FE                   // new source byte is bg color
        // one frame back
        .word $FFFF                 // command marker
        .byte $03                   // dest list command
        .word wg_f6_color_addr_list // the address of a list of dest addrs

        // change color of two frames back 
        .word $FFFF                 // command marker
        .byte $03                   // dest list command
        .word wg_f5_color_addr_list // the address of a list of dest addrs

        // end the frame
        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command


