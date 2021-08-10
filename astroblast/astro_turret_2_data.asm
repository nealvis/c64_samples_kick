//////////////////////////////////////////////////////////////////////////////
// astro_turret_2_data.asm
// file contains the data for turret 2 frames as they are stepped through.

#importonce

#import "../nv_c64_util/nv_color_macs.asm"
#import "../nv_c64_util/nv_screen_rect_macs.asm"


/////////////////
// turret 2 consts and variables
.const TURRET_2_START_ROW = 10
.const TURRET_2_START_COL = 37
.const TURRET_2_COLOR = NV_COLOR_YELLOW
.const TURRET_2_CHAR = $4D
.const TURRET_2_BULLET_HEIGHT = 2

// number of raster frames for turret effect
.const TURRET_2_FRAMES=7


// when turret shot starts this will be non zero and count down each frame
// TurretStep will decrement it.
turret_2_count: .byte 0

.const TURRET_2_Y_VEL = -1
.const TURRET_2_X_VEL = -1
.const TURRET_2_CHARS_PER_FRAME = 1
.const T2_ROW = TURRET_2_START_ROW
.const T2_COL = TURRET_2_START_COL
.const TURRET_2_CHAR_MEM_START = 1461
.const TURRET_2_COLOR_MEM_START = $D800 + (TURRET_2_CHAR_MEM_START - 1024)
.const TURRET_2_MEM_VEL = ((40*TURRET_2_Y_VEL) + (TURRET_2_X_VEL))  // -41

.function DeathRectLeftT2(frame_num)
{
    .var col = TURRET_2_START_COL - ((frame_num * 2)-1)
    .var row = TURRET_2_START_ROW - ((frame_num * 2)-1)
    .if (frame_num == 6)
    {
        .eval col = col + 1
        .eval row = row + 1
    }
    .var screen_left = nv_screen_rect_char_to_screen_pixel_left(col, row)
    .eval screen_left = screen_left +2
    .if (frame_num > 6)
    {
        .eval screen_left = 0
    }

    .return screen_left
}

.function DeathRectTopT2(frame_num)
{
    .var char_col = TURRET_2_START_COL - ((frame_num * 2)-1)
    .var char_row = TURRET_2_START_ROW - ((frame_num * 2)-1)
    .if (frame_num == 6)
    {
        .eval char_col = char_col + 1
        .eval char_row = char_row + 1
    }
    .var screen_top = nv_screen_rect_char_to_screen_pixel_top(char_col, char_row)
    .eval screen_top = screen_top +2
    .if (frame_num > 6)
    {
        .eval screen_top = 0
    }

    .return screen_top
}

.function DeathRectRightT2(frame_num)
{
    .var char_col = TURRET_2_START_COL - ((frame_num * 2)-1)
    .var char_row = TURRET_2_START_ROW - ((frame_num * 2)-1)
    .if (frame_num == 6)
    {
        .eval char_col = char_col + 1
        .eval char_row = char_row + 1
    }
    .var screen_right = nv_screen_rect_char_to_screen_pixel_right(char_col, char_row)
    .eval screen_right = screen_right+6
    .if (frame_num > 6)
    {
        .eval screen_right = 0
    }

    .return screen_right
}

.function DeathRectBottomT2(frame_num)
{
    .var char_col = TURRET_2_START_COL - ((frame_num * 2)-1)
    .var char_row = TURRET_2_START_ROW - ((frame_num * 2)-1)
    .if (frame_num == 6)
    {
        .eval char_col = char_col + 1
        .eval char_row = char_row + 1
    }
    .var screen_bottom = nv_screen_rect_char_to_screen_pixel_bottom(char_col, char_row)
    .eval screen_bottom = screen_bottom + 6
    .if (frame_num > 6)
    {
        .eval screen_bottom = 0
    }

    .return screen_bottom
}


turret_2_all_color_stream:
        .word TURRET_2_COLOR_MEM_START + (TURRET_2_MEM_VEL * 0)
        .word TURRET_2_COLOR_MEM_START + (TURRET_2_MEM_VEL * 1)
        .word TURRET_2_COLOR_MEM_START + (TURRET_2_MEM_VEL * 2)
        .word TURRET_2_COLOR_MEM_START + (TURRET_2_MEM_VEL * 3)
        .word TURRET_2_COLOR_MEM_START + (TURRET_2_MEM_VEL * 4)
        .word TURRET_2_COLOR_MEM_START + (TURRET_2_MEM_VEL * 5)
        .word TURRET_2_COLOR_MEM_START + (TURRET_2_MEM_VEL * 6)
        .word TURRET_2_COLOR_MEM_START + (TURRET_2_MEM_VEL * 7)
        .word TURRET_2_COLOR_MEM_START + (TURRET_2_MEM_VEL * 8)
        .word TURRET_2_COLOR_MEM_START + (TURRET_2_MEM_VEL * 9)
        .word TURRET_2_COLOR_MEM_START + (TURRET_2_MEM_VEL * 10)
        .word $FFFF  // stream command marker
        .byte $FF    // stream quit command

// table of the addresses of all the streams for each frame for turret 2
Turret2StreamAddrTable:
    .word turret_2_stream_frame_1
    .word turret_2_stream_frame_2
    .word turret_2_stream_frame_3
    .word turret_2_stream_frame_4
    .word turret_2_stream_frame_5
    .word turret_2_stream_frame_6
    .word turret_2_stream_frame_7


turret_2_stream_frame_1:
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_2_CHAR    // new source byte is the bullet char
        .word TURRET_2_CHAR_MEM_START + (TURRET_2_MEM_VEL * 0)
        .word TURRET_2_CHAR_MEM_START + (TURRET_2_MEM_VEL * 1)
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_2_COLOR   // new source byte is background color
        .word TURRET_2_COLOR_MEM_START + (TURRET_2_MEM_VEL * 0)
        .word TURRET_2_COLOR_MEM_START + (TURRET_2_MEM_VEL * 1)

        // set the rect for this frame
        .word $FFFF
        .byte $02, $08                // blk copy command for 8 bytes
        .word turret_2_bullet_rect    // dest base for block copy
        .word DeathRectLeftT2(1)
        .word DeathRectTopT2(1)
        .word DeathRectRightT2(1)
        .word DeathRectBottomT2(1)

        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command

turret_2_stream_frame_2:
        // set to bullet char poke bullet
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_2_CHAR    // new source byte is the bullet char
        .word TURRET_2_CHAR_MEM_START + (TURRET_2_MEM_VEL * 2)
        .word TURRET_2_CHAR_MEM_START + (TURRET_2_MEM_VEL * 3)
        
        // set color for bullets and poke bullet color
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_2_COLOR   // new source byte is yellow color
        .word TURRET_2_COLOR_MEM_START + (TURRET_2_MEM_VEL * 2)
        .word TURRET_2_COLOR_MEM_START + (TURRET_2_MEM_VEL * 3)

        // set to background color and clear previous frames color
        .word $FFFF                 // stream command marker
        .byte $FE                   // new source byte is background color
        .word TURRET_2_COLOR_MEM_START + (TURRET_2_MEM_VEL * 0)
        .word TURRET_2_COLOR_MEM_START + (TURRET_2_MEM_VEL * 1)

        // set the rect for this frame 
        .word $FFFF
        .byte $02, $08                // blk copy command for 8 bytes
        .word turret_2_bullet_rect    // dest base for block copy
        //.word nv_screen_rect_char_to_screen_pixel_left(TURRET_2_START_COL-3, TURRET_2_START_ROW-3)
        .word DeathRectLeftT2(2)
        .word DeathRectTopT2(2)
        .word DeathRectRightT2(2)
        .word DeathRectBottomT2(2)

        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command

turret_2_stream_frame_3:
        // set to bullet char poke bullet
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_2_CHAR    // new source byte is the bullet char
        .word TURRET_2_CHAR_MEM_START + (TURRET_2_MEM_VEL * 4)
        .word TURRET_2_CHAR_MEM_START + (TURRET_2_MEM_VEL * 5)
        
        // set color for bullets and poke bullet color
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_2_COLOR   // new source byte is yellow color
        .word TURRET_2_COLOR_MEM_START + (TURRET_2_MEM_VEL * 4)
        .word TURRET_2_COLOR_MEM_START + (TURRET_2_MEM_VEL * 5)

        // set to background color and clear previous frames color
        .word $FFFF                 // stream command marker
        .byte $FE                   // new source byte is background color
        .word TURRET_2_COLOR_MEM_START + (TURRET_2_MEM_VEL * 2)
        .word TURRET_2_COLOR_MEM_START + (TURRET_2_MEM_VEL * 3)

        // set the rect for this frame 
        .word $FFFF
        .byte $02, $08                // blk copy command for 8 bytes
        .word turret_2_bullet_rect    // dest base for block copy
        //.word nv_screen_rect_char_to_screen_pixel_left(TURRET_2_START_COL-5, TURRET_2_START_ROW-5)
        .word DeathRectLeftT2(3)
        .word DeathRectTopT2(3)
        .word DeathRectRightT2(3)
        .word DeathRectBottomT2(3)

        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command

turret_2_stream_frame_4:
        // set to bullet char poke bullet
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_2_CHAR    // new source byte is the bullet char
        .word TURRET_2_CHAR_MEM_START + (TURRET_2_MEM_VEL * 6)
        .word TURRET_2_CHAR_MEM_START + (TURRET_2_MEM_VEL * 7)
        
        // set color for bullets and poke bullet color
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_2_COLOR   // new source byte is yellow color
        .word TURRET_2_COLOR_MEM_START + (TURRET_2_MEM_VEL * 6)
        .word TURRET_2_COLOR_MEM_START + (TURRET_2_MEM_VEL * 7)

        // set to background color and clear previous frames color
        .word $FFFF                 // stream command marker
        .byte $FE                   // new source byte is background color
        .word TURRET_2_COLOR_MEM_START + (TURRET_2_MEM_VEL * 4)
        .word TURRET_2_COLOR_MEM_START + (TURRET_2_MEM_VEL * 5)

        // set the rect for this frame 
        .word $FFFF
        .byte $02, $08                // blk copy command for 8 bytes
        .word turret_2_bullet_rect    // dest base for block copy
        //.word nv_screen_rect_char_to_screen_pixel_left(TURRET_2_START_COL-7, TURRET_2_START_ROW-7)
        .word DeathRectLeftT2(4)
        .word DeathRectTopT2(4)
        .word DeathRectRightT2(4)
        .word DeathRectBottomT2(4)

        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command

turret_2_stream_frame_5:
        // set to bullet char poke bullet
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_2_CHAR    // new source byte is the bullet char
        .word TURRET_2_CHAR_MEM_START + (TURRET_2_MEM_VEL * 8)
        .word TURRET_2_CHAR_MEM_START + (TURRET_2_MEM_VEL * 9)
        
        // set color for bullets and poke bullet color
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_2_COLOR   // new source byte is yellow color
        .word TURRET_2_COLOR_MEM_START + (TURRET_2_MEM_VEL * 8)
        .word TURRET_2_COLOR_MEM_START + (TURRET_2_MEM_VEL * 9)

        // set to background color and clear previous frames color
        .word $FFFF                 // stream command marker
        .byte $FE                   // new source byte is background color
        .word TURRET_2_COLOR_MEM_START + (TURRET_2_MEM_VEL * 6)
        .word TURRET_2_COLOR_MEM_START + (TURRET_2_MEM_VEL * 7)

        // set the rect for this frame 
        .word $FFFF
        .byte $02, $08                // blk copy command for 8 bytes
        .word turret_2_bullet_rect    // dest base for block copy
        //.word nv_screen_rect_char_to_screen_pixel_left(TURRET_2_START_COL-9, TURRET_2_START_ROW-9)
        .word DeathRectLeftT2(5)
        .word DeathRectTopT2(5)
        .word DeathRectRightT2(5)
        .word DeathRectBottomT2(5)

        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command

turret_2_stream_frame_6:
        // set to bullet char poke bullet
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_2_CHAR    // new source byte is the bullet char
        .word TURRET_2_CHAR_MEM_START + (TURRET_2_MEM_VEL * 10)
        
        // set color for bullets and poke bullet color
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_2_COLOR   // new source byte is yellow color
        .word TURRET_2_COLOR_MEM_START + (TURRET_2_MEM_VEL * 10)

        // set to background color and clear previous frames color
        .word $FFFF                 // stream command marker
        .byte $FE                   // new source byte is background color
        .word TURRET_2_COLOR_MEM_START + (TURRET_2_MEM_VEL * 8)
        .word TURRET_2_COLOR_MEM_START + (TURRET_2_MEM_VEL * 9)

        // set the rect for this frame 
        .word $FFFF
        .byte $02, $08                // blk copy command for 8 bytes
        .word turret_2_bullet_rect    // dest base for block copy
        //.word nv_screen_rect_char_to_screen_pixel_left(TURRET_2_START_COL-10, TURRET_2_START_ROW-10)
        .word DeathRectLeftT2(6)
        .word DeathRectTopT2(6)
        .word DeathRectRightT2(6)
        .word DeathRectBottomT2(6)

        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command

turret_2_stream_frame_7:
        // no bullet just erasing last frame's bullet
        // set to background color and clear previous frames color
        .word $FFFF                 // stream command marker
        .byte $FE                   // new source byte is background color
        .word TURRET_2_COLOR_MEM_START + (TURRET_2_MEM_VEL * 10)

        // set the rect for this frame, clear it out
        .word $FFFF
        .byte $02, $08                // blk copy command for 8 bytes
        .word turret_2_bullet_rect    // dest base for block copy
        .word $0000, $0000, $0000, $0000

        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command


//////////////////////////////////////////////////////////////////////////////
// Data that will be modified via this wind effect and the main program can 
// take actions upon

// the death rectangle for bullet 2.  Turret step will update this 
// rect as the bullet travels.  the main engine can check this rectangle 
// for overlap with sprites and act accordingly.
turret_2_bullet_rect: .word $0000, $0000  // (left, top)
                      .word $0000, $0000  // (right, bottom)

