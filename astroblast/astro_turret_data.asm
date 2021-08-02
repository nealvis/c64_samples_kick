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
