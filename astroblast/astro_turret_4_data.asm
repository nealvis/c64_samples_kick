//////////////////////////////////////////////////////////////////////////////
// astro_turret_4_data.asm
// file contains the data for turret 1 frames as they are stepped through.

#importonce

#import "../nv_c64_util/nv_color_macs.asm"
#import "../nv_c64_util/nv_screen_rect_macs.asm"



//////////////////
// turret 1 consts and variables
.const TURRET_4_START_ROW = 14
.const TURRET_4_START_COL = 37
.const TURRET_4_COLOR = NV_COLOR_YELLOW
.const TURRET_4_CHAR = $5D
.const TURRET_4_BULLET_HEIGHT = 2
.const TURRET_4_Y_VEL = 1
.const TURRET_4_X_VEL = 0
.const TURRET_4_CHAR_MEM_START = 1024 + (TURRET_4_START_ROW * 40) + 37
.const TURRET_4_COLOR_MEM_START = $D800 + (TURRET_4_CHAR_MEM_START - 1024)
.const TURRET_4_MEM_VEL = ((40*TURRET_4_Y_VEL) + (TURRET_4_X_VEL))  // -40

// number of raster frames for turret effect
.const TURRET_4_FRAMES=7

// when turret shot starts this will be non zero and count down each frame
// TurretStep will decrement it.
turret_4_count: .byte 0

turret_4_all_color_stream:
        .word TURRET_4_COLOR_MEM_START + (TURRET_4_MEM_VEL * 0)
        .word TURRET_4_COLOR_MEM_START + (TURRET_4_MEM_VEL * 1)
        .word TURRET_4_COLOR_MEM_START + (TURRET_4_MEM_VEL * 2)
        .word TURRET_4_COLOR_MEM_START + (TURRET_4_MEM_VEL * 3)
        .word TURRET_4_COLOR_MEM_START + (TURRET_4_MEM_VEL * 4)
        .word TURRET_4_COLOR_MEM_START + (TURRET_4_MEM_VEL * 5)
        .word TURRET_4_COLOR_MEM_START + (TURRET_4_MEM_VEL * 6)
        .word TURRET_4_COLOR_MEM_START + (TURRET_4_MEM_VEL * 7)
        .word TURRET_4_COLOR_MEM_START + (TURRET_4_MEM_VEL * 8)
        .word TURRET_4_COLOR_MEM_START + (TURRET_4_MEM_VEL * 9)
        .word TURRET_4_COLOR_MEM_START + (TURRET_4_MEM_VEL * 10)
        .word $FFFF  // stream command marker
        .byte $FF    // stream quit command


// table of the addresses of all the streams for each frame
Turret4StreamAddrTable:
    .word turret_4_stream_frame_1
    .word turret_4_stream_frame_2
    .word turret_4_stream_frame_3
    .word turret_4_stream_frame_4
    .word turret_4_stream_frame_5
    .word turret_4_stream_frame_6
    .word turret_4_stream_frame_7


turret_4_stream_frame_1:
        // copy characters to screen mem for the frame
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_4_CHAR    // new source byte is the bullet char
        .word TURRET_4_CHAR_MEM_START + (TURRET_4_MEM_VEL * 0)
        .word TURRET_4_CHAR_MEM_START + (TURRET_4_MEM_VEL * 1)
        
        // now copy the color to the color memory for this frame
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_4_COLOR   // new source byte is background color
        .word TURRET_4_COLOR_MEM_START + (TURRET_4_MEM_VEL * 0)
        .word TURRET_4_COLOR_MEM_START + (TURRET_4_MEM_VEL * 1)

        // set the rect for this frame
        .word $FFFF
        .byte $02, $08                // blk copy command for 8 bytes
        .word turret_4_bullet_rect    // dest base for block copy
        .word nv_screen_rect_char_to_screen_pixel_left(TURRET_4_START_COL, TURRET_4_START_ROW)
        .word nv_screen_rect_char_to_screen_pixel_top(TURRET_4_START_COL, TURRET_4_START_ROW) 
        .word nv_screen_rect_char_to_screen_pixel_right(TURRET_4_START_COL, TURRET_4_START_ROW)
        .word nv_screen_rect_char_to_screen_pixel_bottom(TURRET_4_START_COL, TURRET_4_START_ROW) + ((TURRET_4_BULLET_HEIGHT-1) * CHAR_PIXEL_HEIGHT)
        
        // end the frame
        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command

turret_4_stream_frame_2:
        // set to bullet char poke bullet
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_4_CHAR    // new source byte is the bullet char
        .word TURRET_4_CHAR_MEM_START + (TURRET_4_MEM_VEL * 2)
        .word TURRET_4_CHAR_MEM_START + (TURRET_4_MEM_VEL * 3)
        
        // set color for bullets and poke bullet color
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_4_COLOR   // new source byte is yellow color
        .word TURRET_4_COLOR_MEM_START + (TURRET_4_MEM_VEL * 2)
        .word TURRET_4_COLOR_MEM_START + (TURRET_4_MEM_VEL * 3)

        // set to background color and clear previous frames color
        .word $FFFF                 // stream command marker
        .byte $FE                   // new source byte is background color
        .word TURRET_4_COLOR_MEM_START + (TURRET_4_MEM_VEL * 0)
        .word TURRET_4_COLOR_MEM_START + (TURRET_4_MEM_VEL * 1)

        // set the rect for this frame
        .word $FFFF
        .byte $02, $08                // blk copy command for 8 bytes
        .word turret_4_bullet_rect    // dest base for block copy
        .word nv_screen_rect_char_to_screen_pixel_left(TURRET_4_START_COL, TURRET_4_START_ROW+2)
        .word nv_screen_rect_char_to_screen_pixel_top(TURRET_4_START_COL, TURRET_4_START_ROW+2) 
        .word nv_screen_rect_char_to_screen_pixel_right(TURRET_4_START_COL, TURRET_4_START_ROW+2)
        .word nv_screen_rect_char_to_screen_pixel_bottom(TURRET_4_START_COL, TURRET_4_START_ROW+2) + ((TURRET_4_BULLET_HEIGHT-1) * CHAR_PIXEL_HEIGHT)
        
        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command

turret_4_stream_frame_3:
        // set to bullet char poke bullet
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_4_CHAR    // new source byte is the bullet char
        .word TURRET_4_CHAR_MEM_START + (TURRET_4_MEM_VEL * 4)
        .word TURRET_4_CHAR_MEM_START + (TURRET_4_MEM_VEL * 5)
        
        // set color for bullets and poke bullet color
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_4_COLOR   // new source byte is yellow color
        .word TURRET_4_COLOR_MEM_START + (TURRET_4_MEM_VEL * 4)
        .word TURRET_4_COLOR_MEM_START + (TURRET_4_MEM_VEL * 5)

        // set to background color and clear previous frames color
        .word $FFFF                 // stream command marker
        .byte $FE                   // new source byte is background color
        .word TURRET_4_COLOR_MEM_START + (TURRET_4_MEM_VEL * 2)
        .word TURRET_4_COLOR_MEM_START + (TURRET_4_MEM_VEL * 3)

        // set the rect for this frame
        .word $FFFF
        .byte $02, $08                // blk copy command for 8 bytes
        .word turret_4_bullet_rect    // dest base for block copy
        .word nv_screen_rect_char_to_screen_pixel_left(TURRET_4_START_COL, TURRET_4_START_ROW+4)
        .word nv_screen_rect_char_to_screen_pixel_top(TURRET_4_START_COL, TURRET_4_START_ROW+4) 
        .word nv_screen_rect_char_to_screen_pixel_right(TURRET_4_START_COL, TURRET_4_START_ROW+4)
        .word nv_screen_rect_char_to_screen_pixel_bottom(TURRET_4_START_COL, TURRET_4_START_ROW+4) + ((TURRET_4_BULLET_HEIGHT-1) * CHAR_PIXEL_HEIGHT)

        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command

turret_4_stream_frame_4:
        // set to bullet char poke bullet
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_4_CHAR    // new source byte is the bullet char
        .word TURRET_4_CHAR_MEM_START + (TURRET_4_MEM_VEL * 6)
        .word TURRET_4_CHAR_MEM_START + (TURRET_4_MEM_VEL * 7)
        
        // set color for bullets and poke bullet color
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_4_COLOR   // new source byte is yellow color
        .word TURRET_4_COLOR_MEM_START + (TURRET_4_MEM_VEL * 6)
        .word TURRET_4_COLOR_MEM_START + (TURRET_4_MEM_VEL * 7)

        // set to background color and clear previous frames color
        .word $FFFF                 // stream command marker
        .byte $FE                   // new source byte is background color
        .word TURRET_4_COLOR_MEM_START + (TURRET_4_MEM_VEL * 4)
        .word TURRET_4_COLOR_MEM_START + (TURRET_4_MEM_VEL * 5)

        // set the rect for this frame
        .word $FFFF
        .byte $02, $08                // blk copy command for 8 bytes
        .word turret_4_bullet_rect    // dest base for block copy
        .word nv_screen_rect_char_to_screen_pixel_left(TURRET_4_START_COL, TURRET_4_START_ROW+6)
        .word nv_screen_rect_char_to_screen_pixel_top(TURRET_4_START_COL, TURRET_4_START_ROW+6)
        .word nv_screen_rect_char_to_screen_pixel_right(TURRET_4_START_COL, TURRET_4_START_ROW+6)
        .word nv_screen_rect_char_to_screen_pixel_bottom(TURRET_4_START_COL, TURRET_4_START_ROW+6)  + ((TURRET_4_BULLET_HEIGHT-1) * CHAR_PIXEL_HEIGHT)

        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command

turret_4_stream_frame_5:
        // set to bullet char poke bullet
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_4_CHAR    // new source byte is the bullet char
        .word TURRET_4_CHAR_MEM_START + (TURRET_4_MEM_VEL * 8)
        .word TURRET_4_CHAR_MEM_START + (TURRET_4_MEM_VEL * 9)
        
        // set color for bullets and poke bullet color
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_4_COLOR   // new source byte is yellow color
        .word TURRET_4_COLOR_MEM_START + (TURRET_4_MEM_VEL * 8)
        .word TURRET_4_COLOR_MEM_START + (TURRET_4_MEM_VEL * 9)

        // set to background color and clear previous frames color
        .word $FFFF                 // stream command marker
        .byte $FE                   // new source byte is background color
        .word TURRET_4_COLOR_MEM_START + (TURRET_4_MEM_VEL * 6)
        .word TURRET_4_COLOR_MEM_START + (TURRET_4_MEM_VEL * 7)

        // set the rect for this frame
        .word $FFFF
        .byte $02, $08                // blk copy command for 8 bytes
        .word turret_4_bullet_rect    // dest base for block copy
        .word nv_screen_rect_char_to_screen_pixel_left(TURRET_4_START_COL, TURRET_4_START_ROW+8)
        .word nv_screen_rect_char_to_screen_pixel_top(TURRET_4_START_COL, TURRET_4_START_ROW+8) 
        .word nv_screen_rect_char_to_screen_pixel_right(TURRET_4_START_COL, TURRET_4_START_ROW+8)
        .word nv_screen_rect_char_to_screen_pixel_bottom(TURRET_4_START_COL, TURRET_4_START_ROW+8) + ((TURRET_4_BULLET_HEIGHT-1) * CHAR_PIXEL_HEIGHT)

        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command

turret_4_stream_frame_6:
        // set to bullet char poke bullet
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_4_CHAR    // new source byte is the bullet char
        .word TURRET_4_CHAR_MEM_START + (TURRET_4_MEM_VEL * 10)
        
        // set color for bullets and poke bullet color
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_4_COLOR   // new source byte is yellow color
        .word TURRET_4_COLOR_MEM_START + (TURRET_4_MEM_VEL * 10)

        // set to background color and clear previous frames color
        .word $FFFF                 // stream command marker
        .byte $FE                   // new source byte is background color
        .word TURRET_4_COLOR_MEM_START + (TURRET_4_MEM_VEL * 8)
        .word TURRET_4_COLOR_MEM_START + (TURRET_4_MEM_VEL * 9)

        // set the rect for this frame
        .word $FFFF
        .byte $02, $08                // blk copy command for 8 bytes
        .word turret_4_bullet_rect    // dest base for block copy
        .word nv_screen_rect_char_to_screen_pixel_left(TURRET_4_START_COL, TURRET_4_START_ROW+10)
        .word nv_screen_rect_char_to_screen_pixel_top(TURRET_4_START_COL, TURRET_4_START_ROW+10)
        .word nv_screen_rect_char_to_screen_pixel_right(TURRET_4_START_COL, TURRET_4_START_ROW+10)
        .word nv_screen_rect_char_to_screen_pixel_bottom(TURRET_4_START_COL, TURRET_4_START_ROW+10)

        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command

turret_4_stream_frame_7:
        // no bullet for frame 7, its already off screen

        // set to background color and clear previous frames color
        .word $FFFF                 // stream command marker
        .byte $FE                   // new source byte is background color
        .word TURRET_4_COLOR_MEM_START + (TURRET_4_MEM_VEL * 10)

        // set the rect for this frame, clear it out
        .word $FFFF
        .byte $02, $08                // blk copy command for 8 bytes
        .word turret_4_bullet_rect    // dest base for block copy
        .word $0000, $0000, $0000, $0000

        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command



//////////////////////////////////////////////////////////////////////////////
// Data that will be modified via this wind effect and the main program can 
// take actions upon

// the death rectangle for bullet 1.  Turret step will update this 
// rect as the bullet travels.  the main engine can check this rectangle 
// for overlap with sprites and act accordingly.
turret_4_bullet_rect: .word $0000, $0000  // (left, top)
                      .word $0000, $0000  // (right, bottom)

