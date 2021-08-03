// astro_turret_data
#importonce

#import "../nv_c64_util/nv_color_macs.asm"

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

// number of raster frames for turret effect
.const TURRET_1_FRAMES=8

// when turret shot starts this will be non zero and count down each frame
// TurretStep will decrement it.
turret_1_count: .byte 0


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

.const TURRET_2_CHARS_PER_FRAME = 1
.const T2_ROW = TURRET_2_START_ROW
.const T2_COL = TURRET_2_START_COL
turret_2_char_coords: .byte T2_COL, T2_ROW      // x, y ie col, row
                      .byte T2_COL-1, T2_ROW-1
                      .byte T2_COL-2, T2_ROW-2
                      .byte T2_COL-3, T2_ROW-3
                      .byte T2_COL-4, T2_ROW-4
                      .byte T2_COL-5, T2_ROW-5
                      .byte T2_COL-6, T2_ROW-6
                      .byte T2_COL-7, T2_ROW-7
                      .byte T2_COL-8, T2_ROW-8
                      .byte T2_COL-9, T2_ROW-9
                      .byte T2_COL-10, T2_ROW-10
                      .byte $FF      

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


turret_3_first_color_addrs:  
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
    .word $FFFF

turret_3_second_color_addrs:  
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
    .word $FFFF

turret_3_third_color_addrs:  
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
    .word TURRET_3_COLOR_MEM_START + (TURRET_3_MEM_VEL*10) - 2
    .word $FFFF


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
