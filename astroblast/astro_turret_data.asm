// astro_turret_data
#importonce

#import "../nv_c64_util/nv_color_macs.asm"

//////////////////
// turret consts and variables
.const TURRET_SHOT_START_ROW = 10
.const TURRET_SHOT_START_COL = 37
.const TURRET_SHOT_COLOR = NV_COLOR_YELLOW
.const TURRET_UP_CHAR = $5D
.const TURRET_BULLET_HEIGHT = 2

// number of raster frames for turret effect
.const TURRET_FRAMES=8


//////////////////////////////////////////////////////////////////////////////
// Data that will be modified via this wind effect and the main program can 
// take actions upon

// when turret shot starts this will be non zero and count down each frame
// TurretStep will decrement it.
turret_count: .byte 0

// the death rectangle for bullet 1.  Turret step will update this 
// rect as the bullet travels.  the main engine can check this rectangle 
// for overlap with sprites and act accordingly.
turret_bullet_rect1: .word $0000, $0000  // (left, top)
                     .word $0000, $0000  // (right, bottom)

