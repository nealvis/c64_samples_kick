//////////////////////////////////////////////////////////////////////////////
// astro_turret_5_data.asm
// file contains the data for turret 2 frames as they are stepped through.

#importonce

#import "../nv_c64_util/nv_color_macs.asm"
#import "../nv_c64_util/nv_screen_rect_macs.asm"


/////////////////
// turret 2 consts and variables
.const TURRET_5_START_ROW = 14
.const TURRET_5_START_COL = 37
.const TURRET_5_COLOR = NV_COLOR_YELLOW
.const TURRET_5_CHAR = $4E
.const TURRET_5_BULLET_HEIGHT = 2

// number of raster frames for turret effect
.const TURRET_5_FRAMES=7


// when turret shot starts this will be non zero and count down each frame
// TurretStep will decrement it.
turret_5_count: .byte 0

.const TURRET_5_Y_VEL = 1
.const TURRET_5_X_VEL = -1
.const TURRET_5_CHARS_PER_FRAME = 1
//.const T5_ROW = TURRET_5_START_ROW
//.const T5_COL = TURRET_5_START_COL
.const TURRET_5_CHAR_MEM_START = 1024 + (TURRET_5_START_ROW * 40) + 37  // 1621
.const TURRET_5_COLOR_MEM_START = $D800 + (TURRET_5_CHAR_MEM_START - 1024)
.const TURRET_5_MEM_VEL = ((40*TURRET_5_Y_VEL) + (TURRET_5_X_VEL))  // 39

.function DeathRectLeftT5(frame_num)
{
    //.var char_col = TURRET_5_START_COL - ((frame_num * 2)-1)
    //.var char_row = TURRET_5_START_ROW - ((frame_num * 2)-1)
    .var char_col = TURRET_5_START_COL + ((frame_num-1) * (2*TURRET_5_X_VEL))
    .var char_row = TURRET_5_START_ROW + ((frame_num-1) * (2*TURRET_5_Y_VEL))

    .if (frame_num == 6)
    {
        .eval char_col = char_col - 1
        .eval char_row = char_row - 1
    }
    .var screen_left = nv_screen_rect_char_to_screen_pixel_left(char_col, char_row)
    .eval screen_left = screen_left +2
    .if (frame_num > 6)
    {
        .eval screen_left = 0
    }

    .return screen_left
}

.function DeathRectTopT5(frame_num)
{
    //.var char_col = TURRET_5_START_COL - ((frame_num * 2)-1)
    //.var char_row = TURRET_5_START_ROW - ((frame_num * 2)-1)
    .var char_col = TURRET_5_START_COL + ((frame_num-1) * (2*TURRET_5_X_VEL))
    .var char_row = TURRET_5_START_ROW + ((frame_num-1) * (2*TURRET_5_Y_VEL))

    .if (frame_num == 6)
    {
        .eval char_col = char_col - 1
        .eval char_row = char_row - 1
    }
    .var screen_top = nv_screen_rect_char_to_screen_pixel_top(char_col, char_row)
    .eval screen_top = screen_top +2
    .if (frame_num > 6)
    {
        .eval screen_top = 0
    }

    .return screen_top
}

.function DeathRectRightT5(frame_num)
{
    //.var char_col = TURRET_5_START_COL - ((frame_num * 2)-1)
    //.var char_row = TURRET_5_START_ROW - ((frame_num * 2)-1)
    .var char_col = TURRET_5_START_COL + ((frame_num-1) * (2*TURRET_5_X_VEL))
    .var char_row = TURRET_5_START_ROW + ((frame_num-1) * (2*TURRET_5_Y_VEL))

    .if (frame_num == 6)
    {
        .eval char_col = char_col - 1
        .eval char_row = char_row - 1
    }
    .var screen_right = nv_screen_rect_char_to_screen_pixel_right(char_col, char_row)
    .eval screen_right = screen_right+6
    .if (frame_num > 6)
    {
        .eval screen_right = 0
    }

    .return screen_right
}

.function DeathRectBottomT5(frame_num)
{
    //.var char_col = TURRET_5_START_COL - ((frame_num * 2)-1)
    //.var char_row = TURRET_5_START_ROW - ((frame_num * 2)-1)
    .var char_col = TURRET_5_START_COL + ((frame_num-1) * (2*TURRET_5_X_VEL))
    .var char_row = TURRET_5_START_ROW + ((frame_num-1) * (2*TURRET_5_Y_VEL))
    .if (frame_num == 6)
    {
        .eval char_col = char_col - 1
        .eval char_row = char_row - 1
    }
    .var screen_bottom = nv_screen_rect_char_to_screen_pixel_bottom(char_col, char_row)
    .eval screen_bottom = screen_bottom + 6
    .if (frame_num > 6)
    {
        .eval screen_bottom = 0
    }

    .return screen_bottom
}


turret_5_all_color_stream:
        .word TURRET_5_COLOR_MEM_START + (TURRET_5_MEM_VEL * 0)
        .word TURRET_5_COLOR_MEM_START + (TURRET_5_MEM_VEL * 1)
        .word TURRET_5_COLOR_MEM_START + (TURRET_5_MEM_VEL * 2)
        .word TURRET_5_COLOR_MEM_START + (TURRET_5_MEM_VEL * 3)
        .word TURRET_5_COLOR_MEM_START + (TURRET_5_MEM_VEL * 4)
        .word TURRET_5_COLOR_MEM_START + (TURRET_5_MEM_VEL * 5)
        .word TURRET_5_COLOR_MEM_START + (TURRET_5_MEM_VEL * 6)
        .word TURRET_5_COLOR_MEM_START + (TURRET_5_MEM_VEL * 7)
        .word TURRET_5_COLOR_MEM_START + (TURRET_5_MEM_VEL * 8)
        .word TURRET_5_COLOR_MEM_START + (TURRET_5_MEM_VEL * 9)
        .word TURRET_5_COLOR_MEM_START + (TURRET_5_MEM_VEL * 10)
        .word $FFFF  // stream command marker
        .byte $FF    // stream quit command

// table of the addresses of all the streams for each frame for turret 2
Turret5StreamAddrTable:
    .word turret_5_stream_frame_1
    .word turret_5_stream_frame_2
    .word turret_5_stream_frame_3
    .word turret_5_stream_frame_4
    .word turret_5_stream_frame_5
    .word turret_5_stream_frame_6
    .word turret_5_stream_frame_7


turret_5_stream_frame_1:
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_5_CHAR    // new source byte is the bullet char
        .word TURRET_5_CHAR_MEM_START + (TURRET_5_MEM_VEL * 0)
        .word TURRET_5_CHAR_MEM_START + (TURRET_5_MEM_VEL * 1)
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_5_COLOR   // new source byte is background color
        .word TURRET_5_COLOR_MEM_START + (TURRET_5_MEM_VEL * 0)
        .word TURRET_5_COLOR_MEM_START + (TURRET_5_MEM_VEL * 1)

        // set the rect for this frame
        .word $FFFF
        .byte $02, $08                // blk copy command for 8 bytes
        .word turret_5_bullet_rect    // dest base for block copy
        .word DeathRectLeftT5(1)
        .word DeathRectTopT5(1)
        .word DeathRectRightT5(1)
        .word DeathRectBottomT5(1)

        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command

turret_5_stream_frame_2:
        // set to bullet char poke bullet
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_5_CHAR    // new source byte is the bullet char
        .word TURRET_5_CHAR_MEM_START + (TURRET_5_MEM_VEL * 2)
        .word TURRET_5_CHAR_MEM_START + (TURRET_5_MEM_VEL * 3)
        
        // set color for bullets and poke bullet color
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_5_COLOR   // new source byte is yellow color
        .word TURRET_5_COLOR_MEM_START + (TURRET_5_MEM_VEL * 2)
        .word TURRET_5_COLOR_MEM_START + (TURRET_5_MEM_VEL * 3)

        // set to background color and clear previous frames color
        .word $FFFF                 // stream command marker
        .byte $FE                   // new source byte is background color
        .word TURRET_5_COLOR_MEM_START + (TURRET_5_MEM_VEL * 0)
        .word TURRET_5_COLOR_MEM_START + (TURRET_5_MEM_VEL * 1)

        // set the rect for this frame 
        .word $FFFF
        .byte $02, $08                // blk copy command for 8 bytes
        .word turret_5_bullet_rect    // dest base for block copy
        //.word nv_screen_rect_char_to_screen_pixel_left(TURRET_5_START_COL-3, TURRET_5_START_ROW-3)
        .word DeathRectLeftT5(2)
        .word DeathRectTopT5(2)
        .word DeathRectRightT5(2)
        .word DeathRectBottomT5(2)

        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command

turret_5_stream_frame_3:
        // set to bullet char poke bullet
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_5_CHAR    // new source byte is the bullet char
        .word TURRET_5_CHAR_MEM_START + (TURRET_5_MEM_VEL * 4)
        .word TURRET_5_CHAR_MEM_START + (TURRET_5_MEM_VEL * 5)
        
        // set color for bullets and poke bullet color
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_5_COLOR   // new source byte is yellow color
        .word TURRET_5_COLOR_MEM_START + (TURRET_5_MEM_VEL * 4)
        .word TURRET_5_COLOR_MEM_START + (TURRET_5_MEM_VEL * 5)

        // set to background color and clear previous frames color
        .word $FFFF                 // stream command marker
        .byte $FE                   // new source byte is background color
        .word TURRET_5_COLOR_MEM_START + (TURRET_5_MEM_VEL * 2)
        .word TURRET_5_COLOR_MEM_START + (TURRET_5_MEM_VEL * 3)

        // set the rect for this frame 
        .word $FFFF
        .byte $02, $08                // blk copy command for 8 bytes
        .word turret_5_bullet_rect    // dest base for block copy
        //.word nv_screen_rect_char_to_screen_pixel_left(TURRET_5_START_COL-5, TURRET_5_START_ROW-5)
        .word DeathRectLeftT5(3)
        .word DeathRectTopT5(3)
        .word DeathRectRightT5(3)
        .word DeathRectBottomT5(3)

        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command

turret_5_stream_frame_4:
        // set to bullet char poke bullet
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_5_CHAR    // new source byte is the bullet char
        .word TURRET_5_CHAR_MEM_START + (TURRET_5_MEM_VEL * 6)
        .word TURRET_5_CHAR_MEM_START + (TURRET_5_MEM_VEL * 7)
        
        // set color for bullets and poke bullet color
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_5_COLOR   // new source byte is yellow color
        .word TURRET_5_COLOR_MEM_START + (TURRET_5_MEM_VEL * 6)
        .word TURRET_5_COLOR_MEM_START + (TURRET_5_MEM_VEL * 7)

        // set to background color and clear previous frames color
        .word $FFFF                 // stream command marker
        .byte $FE                   // new source byte is background color
        .word TURRET_5_COLOR_MEM_START + (TURRET_5_MEM_VEL * 4)
        .word TURRET_5_COLOR_MEM_START + (TURRET_5_MEM_VEL * 5)

        // set the rect for this frame 
        .word $FFFF
        .byte $02, $08                // blk copy command for 8 bytes
        .word turret_5_bullet_rect    // dest base for block copy
        //.word nv_screen_rect_char_to_screen_pixel_left(TURRET_5_START_COL-7, TURRET_5_START_ROW-7)
        .word DeathRectLeftT5(4)
        .word DeathRectTopT5(4)
        .word DeathRectRightT5(4)
        .word DeathRectBottomT5(4)

        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command

turret_5_stream_frame_5:
        // set to bullet char poke bullet
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_5_CHAR    // new source byte is the bullet char
        .word TURRET_5_CHAR_MEM_START + (TURRET_5_MEM_VEL * 8)
        .word TURRET_5_CHAR_MEM_START + (TURRET_5_MEM_VEL * 9)
        
        // set color for bullets and poke bullet color
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_5_COLOR   // new source byte is yellow color
        .word TURRET_5_COLOR_MEM_START + (TURRET_5_MEM_VEL * 8)
        .word TURRET_5_COLOR_MEM_START + (TURRET_5_MEM_VEL * 9)

        // set to background color and clear previous frames color
        .word $FFFF                 // stream command marker
        .byte $FE                   // new source byte is background color
        .word TURRET_5_COLOR_MEM_START + (TURRET_5_MEM_VEL * 6)
        .word TURRET_5_COLOR_MEM_START + (TURRET_5_MEM_VEL * 7)

        // set the rect for this frame 
        .word $FFFF
        .byte $02, $08                // blk copy command for 8 bytes
        .word turret_5_bullet_rect    // dest base for block copy
        //.word nv_screen_rect_char_to_screen_pixel_left(TURRET_5_START_COL-9, TURRET_5_START_ROW-9)
        .word DeathRectLeftT5(5)
        .word DeathRectTopT5(5)
        .word DeathRectRightT5(5)
        .word DeathRectBottomT5(5)

        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command

turret_5_stream_frame_6:
        // set to bullet char poke bullet
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_5_CHAR    // new source byte is the bullet char
        .word TURRET_5_CHAR_MEM_START + (TURRET_5_MEM_VEL * 10)
        
        // set color for bullets and poke bullet color
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_5_COLOR   // new source byte is yellow color
        .word TURRET_5_COLOR_MEM_START + (TURRET_5_MEM_VEL * 10)

        // set to background color and clear previous frames color
        .word $FFFF                 // stream command marker
        .byte $FE                   // new source byte is background color
        .word TURRET_5_COLOR_MEM_START + (TURRET_5_MEM_VEL * 8)
        .word TURRET_5_COLOR_MEM_START + (TURRET_5_MEM_VEL * 9)

        // set the rect for this frame 
        .word $FFFF
        .byte $02, $08                // blk copy command for 8 bytes
        .word turret_5_bullet_rect    // dest base for block copy
        //.word nv_screen_rect_char_to_screen_pixel_left(TURRET_5_START_COL-10, TURRET_5_START_ROW-10)
        .word DeathRectLeftT5(6)
        .word DeathRectTopT5(6)
        .word DeathRectRightT5(6)
        .word DeathRectBottomT5(6)

        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command

turret_5_stream_frame_7:
        // no bullet just erasing last frame's bullet
        // set to background color and clear previous frames color
        .word $FFFF                 // stream command marker
        .byte $FE                   // new source byte is background color
        .word TURRET_5_COLOR_MEM_START + (TURRET_5_MEM_VEL * 10)

        // set the rect for this frame, clear it out
        .word $FFFF
        .byte $02, $08                // blk copy command for 8 bytes
        .word turret_5_bullet_rect    // dest base for block copy
        .word $0000, $0000, $0000, $0000

        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command


//////////////////////////////////////////////////////////////////////////////
// Data that will be modified via this wind effect and the main program can 
// take actions upon

// the death rectangle for bullet 2.  Turret step will update this 
// rect as the bullet travels.  the main engine can check this rectangle 
// for overlap with sprites and act accordingly.
turret_5_bullet_rect: .word $0000, $0000  // (left, top)
                      .word $0000, $0000  // (right, bottom)

