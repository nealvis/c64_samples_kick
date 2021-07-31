//////////////////////////////////////////////////////////////////////////////
// astro_turret_code.asm
//////////////////////////////////////////////////////////////////////////////
// The following subroutines should be called from the main engine
// as follows
// TurretInit: Call once before main loop and before other routines
// TurretStep: Call once every raster frame through the main loop
// TurretStart: Call to start the effect See subroutine header for params
// TurretForceStop: Call to force effect to stop if it is active
// TurretCleanup: Call at end of program after main loop to clean up
//////////////////////////////////////////////////////////////////////////////

#importonce 
#import "astro_vars_data.asm"
#import "astro_turret_data.asm"
#import "../nv_c64_util/nv_screen_macs.asm"
#import "../nv_c64_util/nv_sprite_extra_macs.asm"


//////////////////////////////////////////////////////////////////////////////
// call once to initialize turret variables and stuff
TurretInit:
    lda #$00
    sta turret_count
    sta turret_hit_ship_1
    rts
// TurretInit end
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// start a turret shooting.  the actual shooting will happen in TurretStep
TurretStart:
    lda #TURRET_FRAMES
    sta turret_count
    lda #$00
    sta turret_hit_ship_1
    rts
// TurretStart subroutine end
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// subroutine to force turret effect to stop if it is active. if not 
// active then should do nothing
TurretForceStop:
    lda #$00
    sta turret_bullet_rect1
    sta turret_bullet_rect1+1
    sta turret_bullet_rect1+2
    sta turret_bullet_rect1+3
    sta turret_bullet_rect1+4
    sta turret_bullet_rect1+5
    sta turret_bullet_rect1+6
    sta turret_bullet_rect1+7
    sta turret_count
    lda background_color
    .var char_row
    .for (char_row = TURRET_SHOT_START_ROW; char_row>=0; char_row--)
    {
        nv_screen_poke_color_a(char_row, TURRET_SHOT_START_COL)
    }

    rts
// TurretForceStop end
//////////////////////////////////////////////////////////////////////////////    


//////////////////////////////////////////////////////////////////////////////
// subroutine to call at end of program when done with all other wind
// data and routines.
TurretCleanup:
    jsr TurretForceStop
    rts
// TurretCleanup End
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// inline macro to set the bullet rectangle based on 
// turret position, frame number and bullet height
.macro turret_set_bullet_rect1(start_row, start_col, frame, bullet_height)
{
    // setup the bullet rectangle from turret 
    // set top char for this frame first
    ldx #start_col
    ldy #start_row - ((frame*bullet_height) - 1)
    nv_sprite_char_coord_to_screen_pixels_left_top(turret_bullet_rect1)
    
    // now expand down the screen for bullets more than one char high
    ldx #0
    ldy #bullet_height - 1
    nv_sprite_char_coord_to_screen_pixels_expand_right_bottom(turret_bullet_rect1)
}
// turret_set_bullet_rect1 macro end
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// call once per frame to have turret shoot 
TurretStep:
    lda turret_count    // check if turret is active (count != 0)
    bne TurretActive    // not zero so it is active 
    rts                 // turret not active at this time, just return
    
TurretActive:
    // lda turret_count // loaded above already
TurretTryFrame1:
    cmp #TURRET_FRAMES
    beq TurretWasFrame1
    jmp TurretTryFrame2

TurretWasFrame1:
    lda #TURRET_UP_CHAR
    ldx #TURRET_SHOT_COLOR
    nv_screen_poke_color_char_xa(TURRET_SHOT_START_ROW, TURRET_SHOT_START_COL)
    nv_screen_poke_color_char_xa(TURRET_SHOT_START_ROW-1, TURRET_SHOT_START_COL)

    turret_set_bullet_rect1(TURRET_SHOT_START_ROW, TURRET_SHOT_START_COL, 
                            1, TURRET_BULLET_HEIGHT)

TurretEndStep1:
    jmp TurretStepReturn

TurretTryFrame2:
    cmp #TURRET_FRAMES-1
    beq TurretWasFrame2
    jmp TurretTryFrame3

TurretWasFrame2:
    lda #TURRET_UP_CHAR
    ldx #TURRET_SHOT_COLOR
    nv_screen_poke_color_char_xa(TURRET_SHOT_START_ROW-2, TURRET_SHOT_START_COL)
    nv_screen_poke_color_char_xa(TURRET_SHOT_START_ROW-3, TURRET_SHOT_START_COL)

    lda background_color
    nv_screen_poke_color_a(TURRET_SHOT_START_ROW, TURRET_SHOT_START_COL)
    nv_screen_poke_color_a(TURRET_SHOT_START_ROW-1, TURRET_SHOT_START_COL)
    
    turret_set_bullet_rect1(TURRET_SHOT_START_ROW, TURRET_SHOT_START_COL, 
                            2, TURRET_BULLET_HEIGHT)

TurretEndStep2:
    jmp TurretStepReturn

TurretTryFrame3:
    cmp #TURRET_FRAMES-2
    beq TurretWasFrame3
    jmp TurretTryFrame4

TurretWasFrame3:
    lda #TURRET_UP_CHAR
    ldx #TURRET_SHOT_COLOR
    nv_screen_poke_color_char_xa(TURRET_SHOT_START_ROW-4, TURRET_SHOT_START_COL)
    nv_screen_poke_color_char_xa(TURRET_SHOT_START_ROW-5, TURRET_SHOT_START_COL)

    lda background_color
    nv_screen_poke_color_a(TURRET_SHOT_START_ROW-2, TURRET_SHOT_START_COL)
    nv_screen_poke_color_a(TURRET_SHOT_START_ROW-3, TURRET_SHOT_START_COL)

    turret_set_bullet_rect1(TURRET_SHOT_START_ROW, TURRET_SHOT_START_COL, 
                            3, TURRET_BULLET_HEIGHT)

TurretEndStep3:
    jmp TurretStepReturn

TurretTryFrame4:
    cmp #TURRET_FRAMES-3
    beq TurretWasFrame4
    jmp TurretTryFrame5
TurretWasFrame4:
    lda #TURRET_UP_CHAR
    ldx #TURRET_SHOT_COLOR
    nv_screen_poke_color_char_xa(TURRET_SHOT_START_ROW-6, TURRET_SHOT_START_COL)
    nv_screen_poke_color_char_xa(TURRET_SHOT_START_ROW-7, TURRET_SHOT_START_COL)

    lda background_color
    nv_screen_poke_color_a(TURRET_SHOT_START_ROW-4, TURRET_SHOT_START_COL)
    nv_screen_poke_color_a(TURRET_SHOT_START_ROW-5, TURRET_SHOT_START_COL)
    turret_set_bullet_rect1(TURRET_SHOT_START_ROW, TURRET_SHOT_START_COL, 
                            4, TURRET_BULLET_HEIGHT)

TurretEndStep4:
    jmp TurretStepReturn

TurretTryFrame5:
    cmp #TURRET_FRAMES-4
    beq TurretWasFrame5
    jmp TurretTryFrame6
TurretWasFrame5:
    lda #TURRET_UP_CHAR
    ldx #TURRET_SHOT_COLOR
    nv_screen_poke_color_char_xa(TURRET_SHOT_START_ROW-8, TURRET_SHOT_START_COL)
    nv_screen_poke_color_char_xa(TURRET_SHOT_START_ROW-9, TURRET_SHOT_START_COL)
    lda background_color
    nv_screen_poke_color_a(TURRET_SHOT_START_ROW-6, TURRET_SHOT_START_COL)
    nv_screen_poke_color_a(TURRET_SHOT_START_ROW-7, TURRET_SHOT_START_COL)

    turret_set_bullet_rect1(TURRET_SHOT_START_ROW, TURRET_SHOT_START_COL, 
                            5, TURRET_BULLET_HEIGHT)

TurretEndStep5:
    jmp TurretStepReturn

TurretTryFrame6:
    cmp #TURRET_FRAMES-5
    beq TurretWasFrame6
    jmp TurretTryFrame7
TurretWasFrame6:
    lda #TURRET_UP_CHAR
    ldx #TURRET_SHOT_COLOR
    nv_screen_poke_color_char_xa(TURRET_SHOT_START_ROW-10, TURRET_SHOT_START_COL)
    lda background_color
    nv_screen_poke_color_a(TURRET_SHOT_START_ROW-8, TURRET_SHOT_START_COL)
    nv_screen_poke_color_a(TURRET_SHOT_START_ROW-9, TURRET_SHOT_START_COL)
    turret_set_bullet_rect1(TURRET_SHOT_START_ROW, TURRET_SHOT_START_COL, 
                            6, 1)  // bullet only one char for this frame
TurretEndStep6:
    jmp TurretStepReturn

TurretTryFrame7:
    lda background_color
    nv_screen_poke_color_a(TURRET_SHOT_START_ROW-10, TURRET_SHOT_START_COL)

  
TurretStepReturn:    
    dec turret_count    // decrement turret frame counter

TurretStepDone:
    rts
// TurretStep subroutine end
//////////////////////////////////////////////////////////////////////////////
