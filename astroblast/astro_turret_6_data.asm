//////////////////////////////////////////////////////////////////////////////
// astro_turret_6_data.asm
// file contains the data for turret 3 frames as they are stepped through.

#importonce

#import "../nv_c64_util/nv_color_macs.asm"
#import "../nv_c64_util/nv_screen_rect_macs.asm"


/////////////////
// turret 6 consts and variables
.const TURRET_6_START_ROW = 14
.const TURRET_6_START_COL = 37
.const TURRET_6_X_VEL = -3
.const TURRET_6_Y_VEL = 1
.const TURRET_6_CHAR_MEM_START = 1024 + (TURRET_6_START_ROW * 40) + 37  // 1621
.const TURRET_6_COLOR_MEM_START = $D800 + (TURRET_6_CHAR_MEM_START - 1024)
.const TURRET_6_MEM_VEL = ((40*TURRET_6_Y_VEL) + (TURRET_6_X_VEL))  //-43
.const TURRET_6_COLOR = NV_COLOR_YELLOW

// 3 chars make up turret 3 bullets, all beside each other on the row
// the right most is specified here the two beside it the next two chars 
// in the set so add 1 for the char to the left and add 2 for the char to 
// left of that one.
.const TURRET_6_CHAR_RIGHT = $2A

// number of raster frames for turret effect
.const TURRET_6_FRAMES=12

// when turret shot starts this will be non zero and count down each frame
// TurretStep will decrement it.
turret_6_count: .byte $00
turret_6_frame_number: .byte $00
turret_6_char_mem_cur: .word TURRET_6_CHAR_MEM_START  // current location of the bullet's tail
turret_6_color_mem_cur: .word TURRET_6_COLOR_MEM_START


.function DeathRectLeftT6(frame_num)
{
    .var char_col = TURRET_6_START_COL - ((frame_num-1) * 3)
    .var char_row = TURRET_6_START_ROW + (frame_num -1)
    .var screen_left = nv_screen_rect_char_to_screen_pixel_left(char_col, char_row)
    .eval screen_left = screen_left - 16 // two chars to the left
    .eval screen_left = screen_left + 4
    .return screen_left
}

.function DeathRectTopT6(frame_num)
{
    .var char_col = TURRET_6_START_COL - ((frame_num-1) * 3)
    .var char_row = TURRET_6_START_ROW + (frame_num -1)
    .var screen_top = nv_screen_rect_char_to_screen_pixel_top(char_col, char_row)
    .eval screen_top = screen_top + 3
    .return screen_top
}

.function DeathRectRightT6(frame_num)
{
    .var char_col = TURRET_6_START_COL - ((frame_num-1) * 3)
    .var char_row = TURRET_6_START_ROW + (frame_num -1)
    .var screen_right = nv_screen_rect_char_to_screen_pixel_right(char_col, char_row)
    .eval screen_right = screen_right - 4
    .return screen_right
}

.function DeathRectBottomT6(frame_num)
{
    .var char_col = TURRET_6_START_COL - ((frame_num-1) * 3)
    .var char_row = TURRET_6_START_ROW + (frame_num -1)
    .var screen_bottom = nv_screen_rect_char_to_screen_pixel_bottom(char_col, char_row)
    .eval screen_bottom = screen_bottom - 3
    .return screen_bottom
}

turret_6_all_color_stream:  
    .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL*0)
    .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL*1) 
    .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL*2) 
    .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL*3) 
    .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL*4) 
    .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL*5) 
    .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL*6) 
    .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL*7) 
    .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL*8) 
    .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL*9) 
    .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL*10) 

    .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL*0) - 1
    .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL*1) - 1
    .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL*2) - 1 
    .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL*3) - 1
    .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL*4) - 1
    .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL*5) - 1
    .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL*6) - 1
    .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL*7) - 1
    .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL*8) - 1
    .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL*9) - 1
    .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL*10) - 1

    .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL*0) - 2
    .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL*1) - 2
    .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL*2) - 2 
    .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL*3) - 2
    .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL*4) - 2
    .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL*5) - 2
    .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL*6) - 2
    .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL*7) - 2
    .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL*8) - 2
    .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL*9) - 2
    .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL*10) - 2
    .word $FFFF  // stream command marker
    .byte $FF    // stream quit command



// table of the addresses of all the streams for each frame for turret 2
Turret6StreamAddrTable:
    .word turret_6_stream_frame_1
    .word turret_6_stream_frame_2
    .word turret_6_stream_frame_3
    .word turret_6_stream_frame_4
    .word turret_6_stream_frame_5
    .word turret_6_stream_frame_6
    .word turret_6_stream_frame_7
    .word turret_6_stream_frame_8
    .word turret_6_stream_frame_9
    .word turret_6_stream_frame_10
    .word turret_6_stream_frame_11
    .word turret_6_stream_frame_12

turret_6_stream_frame_1:
        // poke the bullet char
        .word $FFFF                       // stream command marker
        .byte $01, TURRET_6_CHAR_RIGHT    // new source byte is the bullet char
        .word TURRET_6_CHAR_MEM_START + (TURRET_6_MEM_VEL * 0)
        .word $FFFF                       // stream command marker
        .byte $01, TURRET_6_CHAR_RIGHT+1  // new source byte is the bullet char
        .word TURRET_6_CHAR_MEM_START + (TURRET_6_MEM_VEL * 0)-1
        .word $FFFF                       // stream command marker
        .byte $01, TURRET_6_CHAR_RIGHT+2  // new source byte is the bullet char
        .word TURRET_6_CHAR_MEM_START + (TURRET_6_MEM_VEL * 0)-2

        // poke the bullet color
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_6_COLOR   // new source byte is background color
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 0)
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 0)-1
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 0)-2

        // set the rect for this frame
        .word $FFFF
        .byte $02, $08                // blk copy command for 8 bytes
        .word turret_6_bullet_rect    // dest base for block copy
        .word DeathRectLeftT6(1)
        .word DeathRectTopT6(1)
        .word DeathRectRightT6(1)
        .word DeathRectBottomT6(1)

        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command

turret_6_stream_frame_2:
        // poke the bullet char
        .word $FFFF                       // stream command marker
        .byte $01, TURRET_6_CHAR_RIGHT    // new source byte is the bullet char
        .word TURRET_6_CHAR_MEM_START + (TURRET_6_MEM_VEL * 1)
        .word $FFFF                       // stream command marker
        .byte $01, TURRET_6_CHAR_RIGHT+1  // new source byte is the bullet char
        .word TURRET_6_CHAR_MEM_START + (TURRET_6_MEM_VEL * 1)-1
        .word $FFFF                       // stream command marker
        .byte $01, TURRET_6_CHAR_RIGHT+2  // new source byte is the bullet char
        .word TURRET_6_CHAR_MEM_START + (TURRET_6_MEM_VEL * 1)-2

        // poke the bullet color
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_6_COLOR   
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 1)
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 1)-1
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 1)-2

        // clear previous frame's bullet color
        .word $FFFF                 // stream command marker
        .byte $FE                   // new source byte is background color
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 0)
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 0)-1
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 0)-2

        // set the rect for this frame
        .word $FFFF
        .byte $02, $08                // blk copy command for 8 bytes
        .word turret_6_bullet_rect    // dest base for block copy
        .word DeathRectLeftT6(2)
        .word DeathRectTopT6(2)
        .word DeathRectRightT6(2)
        .word DeathRectBottomT6(2)

        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command

turret_6_stream_frame_3:
        // poke the bullet char
        .word $FFFF                       // stream command marker
        .byte $01, TURRET_6_CHAR_RIGHT    // new source byte is the bullet char
        .word TURRET_6_CHAR_MEM_START + (TURRET_6_MEM_VEL * 2)
        .word $FFFF                       // stream command marker
        .byte $01, TURRET_6_CHAR_RIGHT+1  // new source byte is the bullet char
        .word TURRET_6_CHAR_MEM_START + (TURRET_6_MEM_VEL * 2)-1
        .word $FFFF                       // stream command marker
        .byte $01, TURRET_6_CHAR_RIGHT+2  // new source byte is the bullet char
        .word TURRET_6_CHAR_MEM_START + (TURRET_6_MEM_VEL * 2)-2

        // poke the bullet color
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_6_COLOR   
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 2)
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 2)-1
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 2)-2

        // clear previous frame's bullet color
        .word $FFFF                 // stream command marker
        .byte $FE                   // new source byte is background color
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 1)
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 1)-1
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 1)-2

        // set the rect for this frame
        .word $FFFF
        .byte $02, $08                // blk copy command for 8 bytes
        .word turret_6_bullet_rect    // dest base for block copy
        .word DeathRectLeftT6(3)
        .word DeathRectTopT6(3)
        .word DeathRectRightT6(3)
        .word DeathRectBottomT6(3)

        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command


turret_6_stream_frame_4:
        // poke the bullet char
        .word $FFFF                       // stream command marker
        .byte $01, TURRET_6_CHAR_RIGHT    // new source byte is the bullet char
        .word TURRET_6_CHAR_MEM_START + (TURRET_6_MEM_VEL * 3)
        .word $FFFF                       // stream command marker
        .byte $01, TURRET_6_CHAR_RIGHT+1  // new source byte is the bullet char
        .word TURRET_6_CHAR_MEM_START + (TURRET_6_MEM_VEL * 3)-1
        .word $FFFF                       // stream command marker
        .byte $01, TURRET_6_CHAR_RIGHT+2  // new source byte is the bullet char
        .word TURRET_6_CHAR_MEM_START + (TURRET_6_MEM_VEL * 3)-2

        // poke the bullet color
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_6_COLOR   
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 3)
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 3)-1
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 3)-2

        // clear previous frame's bullet color
        .word $FFFF                 // stream command marker
        .byte $FE                   // new source byte is background color
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 2)
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 2)-1
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 2)-2

        // set the rect for this frame
        .word $FFFF
        .byte $02, $08                // blk copy command for 8 bytes
        .word turret_6_bullet_rect    // dest base for block copy
        .word DeathRectLeftT6(4)
        .word DeathRectTopT6(4)
        .word DeathRectRightT6(4)
        .word DeathRectBottomT6(4)

        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command


turret_6_stream_frame_5:
        // poke the bullet char
        .word $FFFF                       // stream command marker
        .byte $01, TURRET_6_CHAR_RIGHT    // new source byte is the bullet char
        .word TURRET_6_CHAR_MEM_START + (TURRET_6_MEM_VEL * 4)
        .word $FFFF                       // stream command marker
        .byte $01, TURRET_6_CHAR_RIGHT+1  // new source byte is the bullet char
        .word TURRET_6_CHAR_MEM_START + (TURRET_6_MEM_VEL * 4)-1
        .word $FFFF                       // stream command marker
        .byte $01, TURRET_6_CHAR_RIGHT+2  // new source byte is the bullet char
        .word TURRET_6_CHAR_MEM_START + (TURRET_6_MEM_VEL * 4)-2

        // poke the bullet color
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_6_COLOR   
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 4)
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 4)-1
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 4)-2

        // clear previous frame's bullet color
        .word $FFFF                 // stream command marker
        .byte $FE                   // new source byte is background color
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 3)
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 3)-1
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 3)-2

        // set the rect for this frame
        .word $FFFF
        .byte $02, $08                // blk copy command for 8 bytes
        .word turret_6_bullet_rect    // dest base for block copy
        .word DeathRectLeftT6(5)
        .word DeathRectTopT6(5)
        .word DeathRectRightT6(5)
        .word DeathRectBottomT6(5)

        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command


turret_6_stream_frame_6:
        // poke the bullet char
        .word $FFFF                       // stream command marker
        .byte $01, TURRET_6_CHAR_RIGHT    // new source byte is the bullet char
        .word TURRET_6_CHAR_MEM_START + (TURRET_6_MEM_VEL * 5)
        .word $FFFF                       // stream command marker
        .byte $01, TURRET_6_CHAR_RIGHT+1  // new source byte is the bullet char
        .word TURRET_6_CHAR_MEM_START + (TURRET_6_MEM_VEL * 5)-1
        .word $FFFF                       // stream command marker
        .byte $01, TURRET_6_CHAR_RIGHT+2  // new source byte is the bullet char
        .word TURRET_6_CHAR_MEM_START + (TURRET_6_MEM_VEL * 5)-2

        // poke the bullet color
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_6_COLOR   
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 5)
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 5)-1
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 5)-2

        // clear previous frame's bullet color
        .word $FFFF                 // stream command marker
        .byte $FE                   // new source byte is background color
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 4)
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 4)-1
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 4)-2

        // set the rect for this frame
        .word $FFFF
        .byte $02, $08                // blk copy command for 8 bytes
        .word turret_6_bullet_rect    // dest base for block copy
        .word DeathRectLeftT6(6)
        .word DeathRectTopT6(6)
        .word DeathRectRightT6(6)
        .word DeathRectBottomT6(6)

        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command


turret_6_stream_frame_7:
        // poke the bullet char
        .word $FFFF                       // stream command marker
        .byte $01, TURRET_6_CHAR_RIGHT    // new source byte is the bullet char
        .word TURRET_6_CHAR_MEM_START + (TURRET_6_MEM_VEL * 6)
        .word $FFFF                       // stream command marker
        .byte $01, TURRET_6_CHAR_RIGHT+1  // new source byte is the bullet char
        .word TURRET_6_CHAR_MEM_START + (TURRET_6_MEM_VEL * 6)-1
        .word $FFFF                       // stream command marker
        .byte $01, TURRET_6_CHAR_RIGHT+2  // new source byte is the bullet char
        .word TURRET_6_CHAR_MEM_START + (TURRET_6_MEM_VEL * 6)-2

        // poke the bullet color
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_6_COLOR   
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 6)
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 6)-1
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 6)-2

        // clear previous frame's bullet color
        .word $FFFF                 // stream command marker
        .byte $FE                   // new source byte is background color
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 5)
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 5)-1
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 5)-2

        // set the rect for this frame
        .word $FFFF
        .byte $02, $08                // blk copy command for 8 bytes
        .word turret_6_bullet_rect    // dest base for block copy
        .word DeathRectLeftT6(7)
        .word DeathRectTopT6(7)
        .word DeathRectRightT6(7)
        .word DeathRectBottomT6(7)

        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command


turret_6_stream_frame_8:
        // poke the bullet char
        .word $FFFF                       // stream command marker
        .byte $01, TURRET_6_CHAR_RIGHT    // new source byte is the bullet char
        .word TURRET_6_CHAR_MEM_START + (TURRET_6_MEM_VEL * 7)
        .word $FFFF                       // stream command marker
        .byte $01, TURRET_6_CHAR_RIGHT+1  // new source byte is the bullet char
        .word TURRET_6_CHAR_MEM_START + (TURRET_6_MEM_VEL * 7)-1
        .word $FFFF                       // stream command marker
        .byte $01, TURRET_6_CHAR_RIGHT+2  // new source byte is the bullet char
        .word TURRET_6_CHAR_MEM_START + (TURRET_6_MEM_VEL * 7)-2

        // poke the bullet color
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_6_COLOR   
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 7)
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 7)-1
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 7)-2

        // clear previous frame's bullet color
        .word $FFFF                 // stream command marker
        .byte $FE                   // new source byte is background color
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 6)
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 6)-1
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 6)-2

        // set the rect for this frame
        .word $FFFF
        .byte $02, $08                // blk copy command for 8 bytes
        .word turret_6_bullet_rect    // dest base for block copy
        .word DeathRectLeftT6(8)
        .word DeathRectTopT6(8)
        .word DeathRectRightT6(8)
        .word DeathRectBottomT6(8)

        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command


turret_6_stream_frame_9:
        // poke the bullet char
        .word $FFFF                       // stream command marker
        .byte $01, TURRET_6_CHAR_RIGHT    // new source byte is the bullet char
        .word TURRET_6_CHAR_MEM_START + (TURRET_6_MEM_VEL * 8)
        .word $FFFF                       // stream command marker
        .byte $01, TURRET_6_CHAR_RIGHT+1  // new source byte is the bullet char
        .word TURRET_6_CHAR_MEM_START + (TURRET_6_MEM_VEL * 8)-1
        .word $FFFF                       // stream command marker
        .byte $01, TURRET_6_CHAR_RIGHT+2  // new source byte is the bullet char
        .word TURRET_6_CHAR_MEM_START + (TURRET_6_MEM_VEL * 8)-2

        // poke the bullet color
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_6_COLOR   
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 8)
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 8)-1
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 8)-2

        // clear previous frame's bullet color
        .word $FFFF                 // stream command marker
        .byte $FE                   // new source byte is background color
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 7)
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 7)-1
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 7)-2

        // set the rect for this frame
        .word $FFFF
        .byte $02, $08                // blk copy command for 8 bytes
        .word turret_6_bullet_rect    // dest base for block copy
        .word DeathRectLeftT6(9)
        .word DeathRectTopT6(9)
        .word DeathRectRightT6(9)
        .word DeathRectBottomT6(9)

        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command

turret_6_stream_frame_10:
        // poke the bullet char
        .word $FFFF                       // stream command marker
        .byte $01, TURRET_6_CHAR_RIGHT    // new source byte is the bullet char
        .word TURRET_6_CHAR_MEM_START + (TURRET_6_MEM_VEL * 9)
        .word $FFFF                       // stream command marker
        .byte $01, TURRET_6_CHAR_RIGHT+1  // new source byte is the bullet char
        .word TURRET_6_CHAR_MEM_START + (TURRET_6_MEM_VEL * 9)-1
        .word $FFFF                       // stream command marker
        .byte $01, TURRET_6_CHAR_RIGHT+2  // new source byte is the bullet char
        .word TURRET_6_CHAR_MEM_START + (TURRET_6_MEM_VEL * 9)-2

        // poke the bullet color
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_6_COLOR   
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 9)
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 9)-1
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 9)-2

        // clear previous frame's bullet color
        .word $FFFF                 // stream command marker
        .byte $FE                   // new source byte is background color
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 8)
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 8)-1
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 8)-2

        // set the rect for this frame
        .word $FFFF
        .byte $02, $08                // blk copy command for 8 bytes
        .word turret_6_bullet_rect    // dest base for block copy
        .word DeathRectLeftT6(10)
        .word DeathRectTopT6(10)
        .word DeathRectRightT6(10)
        .word DeathRectBottomT6(10)

        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command


turret_6_stream_frame_11:
        // poke the bullet char
        .word $FFFF                       // stream command marker
        .byte $01, TURRET_6_CHAR_RIGHT    // new source byte is the bullet char
        .word TURRET_6_CHAR_MEM_START + (TURRET_6_MEM_VEL * 10)
        .word $FFFF                       // stream command marker
        .byte $01, TURRET_6_CHAR_RIGHT+1  // new source byte is the bullet char
        .word TURRET_6_CHAR_MEM_START + (TURRET_6_MEM_VEL * 10)-1
        .word $FFFF                       // stream command marker
        .byte $01, TURRET_6_CHAR_RIGHT+2  // new source byte is the bullet char
        .word TURRET_6_CHAR_MEM_START + (TURRET_6_MEM_VEL * 10)-2

        // poke the bullet color
        .word $FFFF                 // stream command marker
        .byte $01, TURRET_6_COLOR   
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 10)
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 10)-1
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 10)-2

        // clear previous frame's bullet color
        .word $FFFF                 // stream command marker
        .byte $FE                   // new source byte is background color
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 9)
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 9)-1
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 9)-2

        // set the rect for this frame
        .word $FFFF
        .byte $02, $08                // blk copy command for 8 bytes
        .word turret_6_bullet_rect    // dest base for block copy
        .word DeathRectLeftT6(11)
        .word DeathRectTopT6(11)
        .word DeathRectRightT6(11)
        .word DeathRectBottomT6(11)

        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command

turret_6_stream_frame_12:
        // no bullet at this frame its off the screen, just erase last frame

        // clear previous frame's bullet color
        .word $FFFF                 // stream command marker
        .byte $FE                   // new source byte is background color
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 10)
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 10)-1
        .word TURRET_6_COLOR_MEM_START + (TURRET_6_MEM_VEL * 10)-2

        // set the rect for this frame, no death rect so clear it.
        .word $FFFF
        .byte $02, $08                // blk copy command for 8 bytes
        .word turret_6_bullet_rect    // dest base for block copy
        .word $0000, $0000, $0000, $0000

        .word $FFFF                 // stream command marker
        .byte $FF                   // stream quit command




//////////////////////////////////////////////////////////////////////////////
// Data that will be modified via this wind effect and the main program can 
// take actions upon

// the death rectangle for bullet 2.  Turret step will update this 
// rect as the bullet travels.  the main engine can check this rectangle 
// for overlap with sprites and act accordingly.
turret_6_bullet_rect: .word $0000, $0000  // (left, top)
                      .word $0000, $0000  // (right, bottom)
