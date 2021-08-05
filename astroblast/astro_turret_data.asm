// astro_turret_data
#importonce

#import "../nv_c64_util/nv_color_macs.asm"

.const CHAR_PIXEL_WIDTH = $0008
.const CHAR_PIXEL_HEIGHT = $0008

 
.function CharCoordToScreenPixelsLeft(char_x, char_y)
{
    .var r_left
    .var r_top
    .var r_right
    .var r_bottom

    .const LEFT_OFFSET = 26
    .const TOP_OFFSET = 53
   
    // LEFT
    // (col * CHAR_PIXEL_WIDTH) + LEFT_OFFSET
    .eval r_left = CHAR_PIXEL_WIDTH
    .eval r_left = r_left * char_x
    .eval r_left = r_left + LEFT_OFFSET
    
    // TOP
    // (row * CHAR_PIXEL_HEIGHT) + TOP_OFFSET
    .eval r_top = CHAR_PIXEL_HEIGHT
    .eval r_top = r_top * char_y
    .eval r_top = r_top + TOP_OFFSET

    // RIGHT
    // add width to the left to get right
    .eval r_right =  r_left + CHAR_PIXEL_WIDTH

    // BOTTOM
    // add height to the top to get the bottom
    .eval r_bottom = r_top + CHAR_PIXEL_HEIGHT

    .return r_left
}

.function CharCoordToScreenPixelsTop(char_x, char_y)
{
    .var r_left
    .var r_top
    .var r_right
    .var r_bottom

    .const LEFT_OFFSET = 26
    .const TOP_OFFSET = 53
   
    // LEFT
    // (col * CHAR_PIXEL_WIDTH) + LEFT_OFFSET
    .eval r_left = CHAR_PIXEL_WIDTH
    .eval r_left = r_left * char_x
    .eval r_left = r_left + LEFT_OFFSET
    
    // TOP
    // (row * CHAR_PIXEL_HEIGHT) + TOP_OFFSET
    .eval r_top = CHAR_PIXEL_HEIGHT
    .eval r_top = r_top * char_y
    .eval r_top = r_top + TOP_OFFSET

    // RIGHT
    // add width to the left to get right
    .eval r_right =  r_left + CHAR_PIXEL_WIDTH

    // BOTTOM
    // add height to the top to get the bottom
    .eval r_bottom = r_top + CHAR_PIXEL_HEIGHT

    .return r_top
}

.function CharCoordToScreenPixelsRight(char_x, char_y)
{
    .var r_left
    .var r_top
    .var r_right
    .var r_bottom

    .const LEFT_OFFSET = 26
    .const TOP_OFFSET = 53
   
    // LEFT
    // (col * CHAR_PIXEL_WIDTH) + LEFT_OFFSET
    .eval r_left = CHAR_PIXEL_WIDTH
    .eval r_left = r_left * char_x
    .eval r_left = r_left + LEFT_OFFSET
    
    // TOP
    // (row * CHAR_PIXEL_HEIGHT) + TOP_OFFSET
    .eval r_top = CHAR_PIXEL_HEIGHT
    .eval r_top = r_top * char_y
    .eval r_top = r_top + TOP_OFFSET

    // RIGHT
    // add width to the left to get right
    .eval r_right =  r_left + CHAR_PIXEL_WIDTH

    // BOTTOM
    // add height to the top to get the bottom
    .eval r_bottom = r_top + CHAR_PIXEL_HEIGHT

    .return r_right
}

.function CharCoordToScreenPixelsBottom(char_x, char_y)
{
    .var r_left
    .var r_top
    .var r_right
    .var r_bottom

    .const LEFT_OFFSET = 26
    .const TOP_OFFSET = 53
   
    // LEFT
    // (col * CHAR_PIXEL_WIDTH) + LEFT_OFFSET
    .eval r_left = CHAR_PIXEL_WIDTH
    .eval r_left = r_left * char_x
    .eval r_left = r_left + LEFT_OFFSET
    
    // TOP
    // (row * CHAR_PIXEL_HEIGHT) + TOP_OFFSET
    .eval r_top = CHAR_PIXEL_HEIGHT
    .eval r_top = r_top * char_y
    .eval r_top = r_top + TOP_OFFSET

    // RIGHT
    // add width to the left to get right
    .eval r_right =  r_left + CHAR_PIXEL_WIDTH

    // BOTTOM
    // add height to the top to get the bottom
    .eval r_bottom = r_top + CHAR_PIXEL_HEIGHT

    .return r_bottom
}




/////////////////
// turret IDs to pass when subroutines require an ID
.const TURRET_1_ID = $01
.const TURRET_2_ID = $02
.const TURRET_3_ID = $04
.const TURRET_4_ID = $08
.const TURRET_ALL_ID = $FF



//////////////////
// turret 1 consts and variables
.const TURRET_1_START_ROW = 10
.const TURRET_1_START_COL = 37
.const TURRET_1_COLOR = NV_COLOR_YELLOW
.const TURRET_1_CHAR = $5D
.const TURRET_1_BULLET_HEIGHT = 2
.const TURRET_1_Y_VEL = -1
.const TURRET_1_X_VEL = 0
.const TURRET_1_CHAR_MEM_START = 1461
.const TURRET_1_COLOR_MEM_START = $D800 + (TURRET_1_CHAR_MEM_START - 1024)
.const TURRET_1_MEM_VEL = ((40*TURRET_1_Y_VEL) + (TURRET_1_X_VEL))  // -40

// number of raster frames for turret effect
.const TURRET_1_FRAMES=8

// when turret shot starts this will be non zero and count down each frame
// TurretStep will decrement it.
turret_1_count: .byte 0

turret_1_all_color_stream:
        .word TURRET_1_COLOR_MEM_START + (TURRET_1_MEM_VEL * 0)
        .word TURRET_1_COLOR_MEM_START + (TURRET_1_MEM_VEL * 1)
        .word TURRET_1_COLOR_MEM_START + (TURRET_1_MEM_VEL * 2)
        .word TURRET_1_COLOR_MEM_START + (TURRET_1_MEM_VEL * 3)
        .word TURRET_1_COLOR_MEM_START + (TURRET_1_MEM_VEL * 4)
        .word TURRET_1_COLOR_MEM_START + (TURRET_1_MEM_VEL * 5)
        .word TURRET_1_COLOR_MEM_START + (TURRET_1_MEM_VEL * 6)
        .word TURRET_1_COLOR_MEM_START + (TURRET_1_MEM_VEL * 7)
        .word TURRET_1_COLOR_MEM_START + (TURRET_1_MEM_VEL * 8)
        .word TURRET_1_COLOR_MEM_START + (TURRET_1_MEM_VEL * 9)
        .word TURRET_1_COLOR_MEM_START + (TURRET_1_MEM_VEL * 10)
        .word $FFFF  // stream command marker
        .byte $FF    // stream quit command

turret_1_stream_frame_1:
        // copy characters to screen mem for the frame
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_1_CHAR    // new source byte is the bullet char
        .word TURRET_1_CHAR_MEM_START + (TURRET_1_MEM_VEL * 0)
        .word TURRET_1_CHAR_MEM_START + (TURRET_1_MEM_VEL * 1)
        
        // now copy the color to the color memory for this frame
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_1_COLOR   // new source byte is background color
        .word TURRET_1_COLOR_MEM_START + (TURRET_1_MEM_VEL * 0)
        .word TURRET_1_COLOR_MEM_START + (TURRET_1_MEM_VEL * 1)

        // set the rect for this frame
        .word $FFFF
        .byte $02, $08                // blk copy command for 8 bytes
        .word turret_1_bullet_rect    // dest base for block copy
        .word CharCoordToScreenPixelsLeft(TURRET_1_START_COL, TURRET_1_START_ROW)
        .word CharCoordToScreenPixelsTop(TURRET_1_START_COL, TURRET_1_START_ROW) - ((TURRET_1_BULLET_HEIGHT-1) * CHAR_PIXEL_HEIGHT)
        .word CharCoordToScreenPixelsRight(TURRET_1_START_COL, TURRET_1_START_ROW)
        .word CharCoordToScreenPixelsBottom(TURRET_1_START_COL, TURRET_1_START_ROW)
        
        // end the frame
        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command

turret_1_stream_frame_2:
        // set to bullet char poke bullet
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_1_CHAR    // new source byte is the bullet char
        .word TURRET_1_CHAR_MEM_START + (TURRET_1_MEM_VEL * 2)
        .word TURRET_1_CHAR_MEM_START + (TURRET_1_MEM_VEL * 3)
        
        // set color for bullets and poke bullet color
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_1_COLOR   // new source byte is yellow color
        .word TURRET_1_COLOR_MEM_START + (TURRET_1_MEM_VEL * 2)
        .word TURRET_1_COLOR_MEM_START + (TURRET_1_MEM_VEL * 3)

        // set to background color and clear previous frames color
        .word $FFFF                 // stream command marker
        .byte $FE                   // new source byte is background color
        .word TURRET_1_COLOR_MEM_START + (TURRET_1_MEM_VEL * 0)
        .word TURRET_1_COLOR_MEM_START + (TURRET_1_MEM_VEL * 1)

        // set the rect for this frame
        .word $FFFF
        .byte $02, $08                // blk copy command for 8 bytes
        .word turret_1_bullet_rect    // dest base for block copy
        .word CharCoordToScreenPixelsLeft(TURRET_1_START_COL, TURRET_1_START_ROW-2)
        .word CharCoordToScreenPixelsTop(TURRET_1_START_COL, TURRET_1_START_ROW-2) - ((TURRET_1_BULLET_HEIGHT-1) * CHAR_PIXEL_HEIGHT)
        .word CharCoordToScreenPixelsRight(TURRET_1_START_COL, TURRET_1_START_ROW-2)
        .word CharCoordToScreenPixelsBottom(TURRET_1_START_COL, TURRET_1_START_ROW-2)
        
        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command

turret_1_stream_frame_3:
        // set to bullet char poke bullet
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_1_CHAR    // new source byte is the bullet char
        .word TURRET_1_CHAR_MEM_START + (TURRET_1_MEM_VEL * 4)
        .word TURRET_1_CHAR_MEM_START + (TURRET_1_MEM_VEL * 5)
        
        // set color for bullets and poke bullet color
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_1_COLOR   // new source byte is yellow color
        .word TURRET_1_COLOR_MEM_START + (TURRET_1_MEM_VEL * 4)
        .word TURRET_1_COLOR_MEM_START + (TURRET_1_MEM_VEL * 5)

        // set to background color and clear previous frames color
        .word $FFFF                 // stream command marker
        .byte $FE                   // new source byte is background color
        .word TURRET_1_COLOR_MEM_START + (TURRET_1_MEM_VEL * 2)
        .word TURRET_1_COLOR_MEM_START + (TURRET_1_MEM_VEL * 3)

        // set the rect for this frame
        .word $FFFF
        .byte $02, $08                // blk copy command for 8 bytes
        .word turret_1_bullet_rect    // dest base for block copy
        .word CharCoordToScreenPixelsLeft(TURRET_1_START_COL, TURRET_1_START_ROW-4)
        .word CharCoordToScreenPixelsTop(TURRET_1_START_COL, TURRET_1_START_ROW-4) - ((TURRET_1_BULLET_HEIGHT-1) * CHAR_PIXEL_HEIGHT)
        .word CharCoordToScreenPixelsRight(TURRET_1_START_COL, TURRET_1_START_ROW-4)
        .word CharCoordToScreenPixelsBottom(TURRET_1_START_COL, TURRET_1_START_ROW-4)

        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command

turret_1_stream_frame_4:
        // set to bullet char poke bullet
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_1_CHAR    // new source byte is the bullet char
        .word TURRET_1_CHAR_MEM_START + (TURRET_1_MEM_VEL * 6)
        .word TURRET_1_CHAR_MEM_START + (TURRET_1_MEM_VEL * 7)
        
        // set color for bullets and poke bullet color
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_1_COLOR   // new source byte is yellow color
        .word TURRET_1_COLOR_MEM_START + (TURRET_1_MEM_VEL * 6)
        .word TURRET_1_COLOR_MEM_START + (TURRET_1_MEM_VEL * 7)

        // set to background color and clear previous frames color
        .word $FFFF                 // stream command marker
        .byte $FE                   // new source byte is background color
        .word TURRET_1_COLOR_MEM_START + (TURRET_1_MEM_VEL * 4)
        .word TURRET_1_COLOR_MEM_START + (TURRET_1_MEM_VEL * 5)

        // set the rect for this frame
        .word $FFFF
        .byte $02, $08                // blk copy command for 8 bytes
        .word turret_1_bullet_rect    // dest base for block copy
        .word CharCoordToScreenPixelsLeft(TURRET_1_START_COL, TURRET_1_START_ROW-6)
        .word CharCoordToScreenPixelsTop(TURRET_1_START_COL, TURRET_1_START_ROW-6) - ((TURRET_1_BULLET_HEIGHT-1) * CHAR_PIXEL_HEIGHT)
        .word CharCoordToScreenPixelsRight(TURRET_1_START_COL, TURRET_1_START_ROW-6)
        .word CharCoordToScreenPixelsBottom(TURRET_1_START_COL, TURRET_1_START_ROW-6)

        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command

turret_1_stream_frame_5:
        // set to bullet char poke bullet
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_1_CHAR    // new source byte is the bullet char
        .word TURRET_1_CHAR_MEM_START + (TURRET_1_MEM_VEL * 8)
        .word TURRET_1_CHAR_MEM_START + (TURRET_1_MEM_VEL * 9)
        
        // set color for bullets and poke bullet color
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_1_COLOR   // new source byte is yellow color
        .word TURRET_1_COLOR_MEM_START + (TURRET_1_MEM_VEL * 8)
        .word TURRET_1_COLOR_MEM_START + (TURRET_1_MEM_VEL * 9)

        // set to background color and clear previous frames color
        .word $FFFF                 // stream command marker
        .byte $FE                   // new source byte is background color
        .word TURRET_1_COLOR_MEM_START + (TURRET_1_MEM_VEL * 6)
        .word TURRET_1_COLOR_MEM_START + (TURRET_1_MEM_VEL * 7)

        // set the rect for this frame
        .word $FFFF
        .byte $02, $08                // blk copy command for 8 bytes
        .word turret_1_bullet_rect    // dest base for block copy
        .word CharCoordToScreenPixelsLeft(TURRET_1_START_COL, TURRET_1_START_ROW-8)
        .word CharCoordToScreenPixelsTop(TURRET_1_START_COL, TURRET_1_START_ROW-8 - ((TURRET_1_BULLET_HEIGHT-1) * CHAR_PIXEL_HEIGHT))
        .word CharCoordToScreenPixelsRight(TURRET_1_START_COL, TURRET_1_START_ROW-8)
        .word CharCoordToScreenPixelsBottom(TURRET_1_START_COL, TURRET_1_START_ROW-8)

        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command

turret_1_stream_frame_6:
        // set to bullet char poke bullet
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_1_CHAR    // new source byte is the bullet char
        .word TURRET_1_CHAR_MEM_START + (TURRET_1_MEM_VEL * 10)
        
        // set color for bullets and poke bullet color
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_1_COLOR   // new source byte is yellow color
        .word TURRET_1_COLOR_MEM_START + (TURRET_1_MEM_VEL * 10)

        // set to background color and clear previous frames color
        .word $FFFF                 // stream command marker
        .byte $FE                   // new source byte is background color
        .word TURRET_1_COLOR_MEM_START + (TURRET_1_MEM_VEL * 8)
        .word TURRET_1_COLOR_MEM_START + (TURRET_1_MEM_VEL * 9)

        // set the rect for this frame
        .word $FFFF
        .byte $02, $08                // blk copy command for 8 bytes
        .word turret_1_bullet_rect    // dest base for block copy
        .word CharCoordToScreenPixelsLeft(TURRET_1_START_COL, TURRET_1_START_ROW-10)
        .word CharCoordToScreenPixelsTop(TURRET_1_START_COL, TURRET_1_START_ROW-10)
        .word CharCoordToScreenPixelsRight(TURRET_1_START_COL, TURRET_1_START_ROW-10)
        .word CharCoordToScreenPixelsBottom(TURRET_1_START_COL, TURRET_1_START_ROW-10)

        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command

turret_1_stream_frame_7:
        // no bullet for frame 7, its already off screen

        // set to background color and clear previous frames color
        .word $FFFF                 // stream command marker
        .byte $FE                   // new source byte is background color
        .word TURRET_1_COLOR_MEM_START + (TURRET_1_MEM_VEL * 10)

        // set the rect for this frame, clear it out
        .word $FFFF
        .byte $02, $08                // blk copy command for 8 bytes
        .word turret_1_bullet_rect    // dest base for block copy
        .word $0000, $0000, $0000, $0000

        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command



/////////////////
// turret 2 consts and variables
.const TURRET_2_START_ROW = 10
.const TURRET_2_START_COL = 37
.const TURRET_2_COLOR = NV_COLOR_YELLOW
.const TURRET_2_CHAR = $4D
.const TURRET_2_BULLET_HEIGHT = 2

// number of raster frames for turret effect
.const TURRET_2_FRAMES=12


// when turret shot starts this will be non zero and count down each frame
// TurretStep will decrement it.
turret_2_count: .byte 0
turret_2_frame_number: .byte 0

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
    .var screen_left = CharCoordToScreenPixelsLeft(col, row)
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
    .var screen_top = CharCoordToScreenPixelsTop(char_col, char_row)
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
    .var screen_right = CharCoordToScreenPixelsRight(char_col, char_row)
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
    .var screen_bottom = CharCoordToScreenPixelsBottom(char_col, char_row)
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
        //.word CharCoordToScreenPixelsLeft(TURRET_2_START_COL-3, TURRET_2_START_ROW-3)
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
        //.word CharCoordToScreenPixelsLeft(TURRET_2_START_COL-5, TURRET_2_START_ROW-5)
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
        //.word CharCoordToScreenPixelsLeft(TURRET_2_START_COL-7, TURRET_2_START_ROW-7)
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
        //.word CharCoordToScreenPixelsLeft(TURRET_2_START_COL-9, TURRET_2_START_ROW-9)
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
        //.word CharCoordToScreenPixelsLeft(TURRET_2_START_COL-10, TURRET_2_START_ROW-10)
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



/////////////////
// turret 3 consts and variables
.const TURRET_3_START_ROW = 10
.const TURRET_3_START_COL = 37
.const TURRET_3_X_VEL = -3
.const TURRET_3_Y_VEL = -1
.const TURRET_3_CHAR_MEM_START = 1461
.const TURRET_3_COLOR_MEM_START = $D800 + (TURRET_3_CHAR_MEM_START - 1024)
.const TURRET_3_MEM_VEL = ((40*TURRET_3_Y_VEL) + (TURRET_3_X_VEL))  //-43
.const TURRET_3_COLOR = NV_COLOR_YELLOW

// two chars make up turret 3 bullets, both beside each other on the row
.const TURRET_3_CHAR_RIGHT = $25 // $4D
.const TURRET_3_CHAR_LEFT = $4D

.const TURRET_3_BULLET_HEIGHT = 1
.const TURRET_3_BULLET_WIDTH = 2

// number of raster frames for turret effect
.const TURRET_3_FRAMES=12

// when turret shot starts this will be non zero and count down each frame
// TurretStep will decrement it.
turret_3_count: .byte $00
turret_3_frame_number: .byte $00
turret_3_char_mem_cur: .word TURRET_3_CHAR_MEM_START  // current location of the bullet's tail
turret_3_color_mem_cur: .word TURRET_3_COLOR_MEM_START

turret_3_all_color_stream:  
    .word TURRET_3_COLOR_MEM_START + (TURRET_3_MEM_VEL*0)
    .word TURRET_3_COLOR_MEM_START + (TURRET_3_MEM_VEL*1) 
    .word TURRET_3_COLOR_MEM_START + (TURRET_3_MEM_VEL*2) 
    .word TURRET_3_COLOR_MEM_START + (TURRET_3_MEM_VEL*3) 
    .word TURRET_3_COLOR_MEM_START + (TURRET_3_MEM_VEL*4) 
    .word TURRET_3_COLOR_MEM_START + (TURRET_3_MEM_VEL*5) 
    .word TURRET_3_COLOR_MEM_START + (TURRET_3_MEM_VEL*6) 
    .word TURRET_3_COLOR_MEM_START + (TURRET_3_MEM_VEL*7) 
    .word TURRET_3_COLOR_MEM_START + (TURRET_3_MEM_VEL*8) 
    .word TURRET_3_COLOR_MEM_START + (TURRET_3_MEM_VEL*9) 
    .word TURRET_3_COLOR_MEM_START + (TURRET_3_MEM_VEL*10) 

    .word TURRET_3_COLOR_MEM_START + (TURRET_3_MEM_VEL*0) - 1
    .word TURRET_3_COLOR_MEM_START + (TURRET_3_MEM_VEL*1) - 1
    .word TURRET_3_COLOR_MEM_START + (TURRET_3_MEM_VEL*2) - 1 
    .word TURRET_3_COLOR_MEM_START + (TURRET_3_MEM_VEL*3) - 1
    .word TURRET_3_COLOR_MEM_START + (TURRET_3_MEM_VEL*4) - 1
    .word TURRET_3_COLOR_MEM_START + (TURRET_3_MEM_VEL*5) - 1
    .word TURRET_3_COLOR_MEM_START + (TURRET_3_MEM_VEL*6) - 1
    .word TURRET_3_COLOR_MEM_START + (TURRET_3_MEM_VEL*7) - 1
    .word TURRET_3_COLOR_MEM_START + (TURRET_3_MEM_VEL*8) - 1
    .word TURRET_3_COLOR_MEM_START + (TURRET_3_MEM_VEL*9) - 1
    .word TURRET_3_COLOR_MEM_START + (TURRET_3_MEM_VEL*10) - 1

    .word TURRET_3_COLOR_MEM_START + (TURRET_3_MEM_VEL*0) - 2
    .word TURRET_3_COLOR_MEM_START + (TURRET_3_MEM_VEL*1) - 2
    .word TURRET_3_COLOR_MEM_START + (TURRET_3_MEM_VEL*2) - 2 
    .word TURRET_3_COLOR_MEM_START + (TURRET_3_MEM_VEL*3) - 2
    .word TURRET_3_COLOR_MEM_START + (TURRET_3_MEM_VEL*4) - 2
    .word TURRET_3_COLOR_MEM_START + (TURRET_3_MEM_VEL*5) - 2
    .word TURRET_3_COLOR_MEM_START + (TURRET_3_MEM_VEL*6) - 2
    .word TURRET_3_COLOR_MEM_START + (TURRET_3_MEM_VEL*7) - 2
    .word TURRET_3_COLOR_MEM_START + (TURRET_3_MEM_VEL*8) - 2
    .word TURRET_3_COLOR_MEM_START + (TURRET_3_MEM_VEL*9) - 2
TestStream:
    .word TURRET_3_COLOR_MEM_START + (TURRET_3_MEM_VEL*10) - 2
    .word $FFFF  // stream command marker
    .byte $FF    // stream quit command

//////////////////////////////////////////////////////////////////////////////
// Data that will be modified via this wind effect and the main program can 
// take actions upon

// the death rectangle for bullet 1.  Turret step will update this 
// rect as the bullet travels.  the main engine can check this rectangle 
// for overlap with sprites and act accordingly.
turret_1_bullet_rect: .word $0000, $0000  // (left, top)
                      .word $0000, $0000  // (right, bottom)

// the death rectangle for bullet 2.  Turret step will update this 
// rect as the bullet travels.  the main engine can check this rectangle 
// for overlap with sprites and act accordingly.
turret_2_bullet_rect: .word $0000, $0000  // (left, top)
                      .word $0000, $0000  // (right, bottom)

// the death rectangle for bullet 2.  Turret step will update this 
// rect as the bullet travels.  the main engine can check this rectangle 
// for overlap with sprites and act accordingly.
turret_3_bullet_rect: .word $0000, $0000  // (left, top)
                      .word $0000, $0000  // (right, bottom)






/*
.const T3_ROW = TURRET_3_START_ROW
.const T3_COL = TURRET_3_START_COL
turret_3_char_coords: .byte T2_COL, T2_ROW      // x, y ie col, row
                      .byte T2_COL-1, T2_ROW
                      .byte T2_COL-2, T2_ROW

                      .byte T2_COL-3, T2_ROW-1
                      .byte T2_COL-4, T2_ROW-1
                      .byte T2_COL-5, T2_ROW-1

                      .byte T2_COL-6, T2_ROW-2
                      .byte T2_COL-7, T2_ROW-2
                      .byte T2_COL-8, T2_ROW-2

                      .byte T2_COL-9, T2_ROW-3
                      .byte T2_COL-10, T2_ROW-3
                      .byte T2_COL-11, T2_ROW-3

                      .byte T2_COL-12, T2_ROW-4
                      .byte T2_COL-13, T2_ROW-4
                      .byte T2_COL-14, T2_ROW-4

                      .byte T2_COL-15, T2_ROW-5
                      .byte T2_COL-16, T2_ROW-5
                      .byte T2_COL-17, T2_ROW-5

                      .byte T2_COL-18, T2_ROW-6
                      .byte T2_COL-19, T2_ROW-6
                      .byte T2_COL-20, T2_ROW-6

                      .byte T2_COL-21, T2_ROW-7
                      .byte T2_COL-22, T2_ROW-7
                      .byte T2_COL-23, T2_ROW-7

                      .byte T2_COL-24, T2_ROW-8
                      .byte T2_COL-25, T2_ROW-8
                      .byte T2_COL-26, T2_ROW-8

                      .byte T2_COL-27, T2_ROW-9
                      .byte T2_COL-28, T2_ROW-9
                      .byte T2_COL-29, T2_ROW-9

                      .byte T2_COL-30, T2_ROW-10
                      .byte T2_COL-31, T2_ROW-10
                      .byte T2_COL-32, T2_ROW-10

                      .byte $FF


turret_3_first_char_addrs:  
    .word TURRET_3_CHAR_MEM_START + (TURRET_3_MEM_VEL*0)
    .word TURRET_3_CHAR_MEM_START + (TURRET_3_MEM_VEL*1) 
    .word TURRET_3_CHAR_MEM_START + (TURRET_3_MEM_VEL*2) 
    .word TURRET_3_CHAR_MEM_START + (TURRET_3_MEM_VEL*3) 
    .word TURRET_3_CHAR_MEM_START + (TURRET_3_MEM_VEL*4) 
    .word TURRET_3_CHAR_MEM_START + (TURRET_3_MEM_VEL*5) 
    .word TURRET_3_CHAR_MEM_START + (TURRET_3_MEM_VEL*6) 
    .word TURRET_3_CHAR_MEM_START + (TURRET_3_MEM_VEL*7) 
    .word TURRET_3_CHAR_MEM_START + (TURRET_3_MEM_VEL*8) 
    .word TURRET_3_CHAR_MEM_START + (TURRET_3_MEM_VEL*9) 
    .word TURRET_3_CHAR_MEM_START + (TURRET_3_MEM_VEL*10) 
    .word $FFFF

turret_3_second_char_addrs:  
    .word TURRET_3_CHAR_MEM_START + (TURRET_3_MEM_VEL*0) - 1
    .word TURRET_3_CHAR_MEM_START + (TURRET_3_MEM_VEL*1) - 1
    .word TURRET_3_CHAR_MEM_START + (TURRET_3_MEM_VEL*2) - 1 
    .word TURRET_3_CHAR_MEM_START + (TURRET_3_MEM_VEL*3) - 1
    .word TURRET_3_CHAR_MEM_START + (TURRET_3_MEM_VEL*4) - 1
    .word TURRET_3_CHAR_MEM_START + (TURRET_3_MEM_VEL*5) - 1
    .word TURRET_3_CHAR_MEM_START + (TURRET_3_MEM_VEL*6) - 1
    .word TURRET_3_CHAR_MEM_START + (TURRET_3_MEM_VEL*7) - 1
    .word TURRET_3_CHAR_MEM_START + (TURRET_3_MEM_VEL*8) - 1
    .word TURRET_3_CHAR_MEM_START + (TURRET_3_MEM_VEL*9) - 1
    .word TURRET_3_CHAR_MEM_START + (TURRET_3_MEM_VEL*10) - 1
    .word $FFFF

turret_3_third_char_addrs:  
    .word TURRET_3_CHAR_MEM_START + (TURRET_3_MEM_VEL*0) - 2
    .word TURRET_3_CHAR_MEM_START + (TURRET_3_MEM_VEL*1) - 2
    .word TURRET_3_CHAR_MEM_START + (TURRET_3_MEM_VEL*2) - 2 
    .word TURRET_3_CHAR_MEM_START + (TURRET_3_MEM_VEL*3) - 2
    .word TURRET_3_CHAR_MEM_START + (TURRET_3_MEM_VEL*4) - 2
    .word TURRET_3_CHAR_MEM_START + (TURRET_3_MEM_VEL*5) - 2
    .word TURRET_3_CHAR_MEM_START + (TURRET_3_MEM_VEL*6) - 2
    .word TURRET_3_CHAR_MEM_START + (TURRET_3_MEM_VEL*7) - 2
    .word TURRET_3_CHAR_MEM_START + (TURRET_3_MEM_VEL*8) - 2
    .word TURRET_3_CHAR_MEM_START + (TURRET_3_MEM_VEL*9) - 2
    .word TURRET_3_CHAR_MEM_START + (TURRET_3_MEM_VEL*10) - 2
    .word $FFFF
*/