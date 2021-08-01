//////////////////////////////////////////////////////////////////////////////
// astro_turret_code.asm
//////////////////////////////////////////////////////////////////////////////
// The following subroutines should be called from the main engine
// as follows
// TurretInit: Call once before main loop and before other routines
// TurretStep: Call once every raster frame through the main loop
// TurretStart: Call to start the effect See subroutine header for params
// TurretActive: Call to determine if a turret active
// TurretForceStop: Call to force effect to stop if it is active
// TurretCleanup: Call at end of program after main loop to clean up
//////////////////////////////////////////////////////////////////////////////

#importonce 
#import "astro_vars_data.asm"
#import "astro_turret_data.asm"
#import "../nv_c64_util/nv_screen_macs.asm"
#import "../nv_c64_util/nv_screen_rect_macs.asm"


//////////////////////////////////////////////////////////////////////////////
// call once to initialize turret variables and stuff
TurretInit:
    lda #$00
    sta turret_1_count
    sta turret_2_count
    rts
// TurretInit end
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// subroutine to start a turret shooting.  The actual shooting will 
// happen in TurretStep
// Params: 
//   Accum: set to the turret ID of the turret that should start
TurretStart:
    // accum should be loaded by caller
    sta turret_start_ids

TurretStartTry1:
    lda #TURRET_1_ID
    bit turret_start_ids
    beq TurretStartTry2
TurretStartIs1:
    lda #TURRET_1_FRAMES
    sta turret_1_count

TurretStartTry2:
    lda #TURRET_2_ID
    bit turret_start_ids
    beq TurretStartTry3
TurretStartIs2:
    lda #TURRET_2_FRAMES
    sta turret_2_count

TurretStartTry3:
    lda #TURRET_3_ID
    bit turret_start_ids

    // TODO

TurretStartDone:
    rts

turret_start_ids: .byte 0
// TurretStart subroutine end
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// subroutine to determine if a turret is currently active
// Params:
//   Accum: set to the turret ID of the turret to query,
//          or TURRET_ALL_ID to know if any turret is active
// Return:
//   Accum: will be zero if not active or non zero if is active
// TOOD: make it return a bit mask with one bit for each possible
//       bullet so caller will know exactly which bullet is active
TurretLdaActive:
    sta turret_active_ids
    lda #$00
    sta turret_active_retval

  TurretActiveTry1:
    lda #TURRET_1_ID
    bit turret_active_ids
    beq TurretActiveTry2
  TurretActiveIs1:
    ldx turret_1_count
    beq TurretActiveTry2
    ora turret_active_retval
    sta turret_active_retval

  TurretActiveTry2:
    lda #TURRET_2_ID
    bit turret_active_ids
    beq TurretActiveTry3
  TurretActiveIs2:
    ldx turret_2_count
    beq TurretActiveTry3
    ora turret_active_retval
    sta turret_active_retval

  TurretActiveTry3:
    lda #TURRET_3_ID
    bit turret_active_ids
    // TODO

  TurretActiveDone:
    lda turret_active_retval
    rts

turret_active_ids: .byte 0
turret_active_retval: .byte 0
// TurretActive subroutine end
//////////////////////////////////////////////////////////////////////////////

.macro turret_clear_rect(rect)
{
    .var index
    lda #$00
    .for (index=0; index < 8; index++)
    {
        sta rect+index
    }
}

.macro turret_force_stop_id_1()
{
    lda #$00
    turret_clear_rect(turret_1_bullet_rect)
    sta turret_1_count
    lda background_color
    .var char_row
    .for (char_row = TURRET_1_START_ROW; char_row>=0; char_row--)
    {
        nv_screen_poke_color_a(char_row, TURRET_1_START_COL)
    }

}

.macro turret_force_stop_id_2()
{

}
//////////////////////////////////////////////////////////////////////////////
// subroutine to force turret effect to stop if it is active. if not 
// active then should do nothing
// Params:
//   Accum: set to the turret ID of the turret to query,
//          or TURRET_ALL_ID to know if any turret is active
// 
TurretForceStop:
    sta turret_force_stop_ids

  TurretForceStopTry1:
    lda #TURRET_1_ID
    bit turret_force_stop_ids
    beq TurretForceStopTry2
  TurretForceStopIs1:
    turret_force_stop_id_1()

  TurretForceStopTry2:
    lda #TURRET_2_ID
    bit turret_force_stop_ids
    beq TurretForceStopTry3
  TurretForceStopIs2:
    turret_force_stop_id_2()

  TurretForceStopTry3:
    lda #TURRET_3_ID
    bit turret_force_stop_ids
    // TODO

  TurretForceStopDone:
    lda turret_active_retval

    rts

turret_force_stop_ids: .byte 0
// TurretForceStop end
//////////////////////////////////////////////////////////////////////////////    


//////////////////////////////////////////////////////////////////////////////
// subroutine to call at end of program when done with all other wind
// data and routines.
TurretCleanup:
    lda #TURRET_ALL_ID
    jsr TurretForceStop
    rts
// TurretCleanup End
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// inline macro to set the bullet rectangle based on 
// turret position, frame number and bullet height
.macro turret_1_set_bullet_rect(start_row, start_col, frame, bullet_height)
{
    // setup the bullet rectangle from turret 
    // set top char for this frame first
    ldx #start_col
    ldy #start_row - ((frame*bullet_height) - 1)
    nv_screen_rect_char_coord_to_screen_pixels_left_top(turret_1_bullet_rect)
    
    // now expand down the screen for bullets more than one char high
    ldx #0
    ldy #bullet_height - 1
    nv_screen_rect_char_coord_to_screen_pixels_expand_right_bottom(turret_1_bullet_rect)
}
// turret_1_set_bullet_rect macro end
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// inline macro to set the bullet rectangle based on 
// turret position, frame number and bullet height
.macro turret_set_bullet_rect(rect, start_row, start_col, frame, bullet_height)
{
    // setup the bullet rectangle from turret 
    // set top char for this frame first
    ldx #start_col
    ldy #start_row - ((frame*bullet_height) - 1)
    nv_screen_rect_char_coord_to_screen_pixels_left_top(rect)
    
    // now expand down the screen for bullets more than one char high
    ldx #0
    ldy #bullet_height - 1
    nv_screen_rect_char_coord_to_screen_pixels_expand_right_bottom(rect)
}
// turret_set_bullet_rect macro end
//////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////////////////
// call once per frame to have turret shoot 
TurretStep:
  TurretStepTry1:
    lda turret_1_count   // check if turret is active (count != 0)
    beq TurretStepTry2     // not zero so it is active 
    jsr Turret1DoStep

  TurretStepTry2:
    lda turret_2_count   // check if turret is active (count != 0)
    beq TurretStepTry3     // not zero so it is active 
    jsr Turret2DoStep
   
  TurretStepTry3:
    //TODO

    rts
// TurretStep subroutine end
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// subroutine to step turret 1
// it should only be called if turret 1 known to be active
// which means turret_1_count > 0
Turret1DoStep:    
    lda turret_1_count

TurretTryFrame1:
    cmp #TURRET_1_FRAMES
    beq TurretWasFrame1
    jmp TurretTryFrame2

TurretWasFrame1:
    lda #TURRET_1_CHAR
    ldx #TURRET_1_COLOR
    nv_screen_poke_color_char_xa(TURRET_1_START_ROW, TURRET_1_START_COL)
    nv_screen_poke_color_char_xa(TURRET_1_START_ROW-1, TURRET_1_START_COL)

    turret_1_set_bullet_rect(TURRET_1_START_ROW, TURRET_1_START_COL, 
                            1, TURRET_1_BULLET_HEIGHT)

TurretEndStep1:
    jmp TurretStepReturn

TurretTryFrame2:
    cmp #TURRET_1_FRAMES-1
    beq TurretWasFrame2
    jmp TurretTryFrame3

TurretWasFrame2:
    lda #TURRET_1_CHAR
    ldx #TURRET_1_COLOR
    nv_screen_poke_color_char_xa(TURRET_1_START_ROW-2, TURRET_1_START_COL)
    nv_screen_poke_color_char_xa(TURRET_1_START_ROW-3, TURRET_1_START_COL)

    lda background_color
    nv_screen_poke_color_a(TURRET_1_START_ROW, TURRET_1_START_COL)
    nv_screen_poke_color_a(TURRET_1_START_ROW-1, TURRET_1_START_COL)
    
    turret_1_set_bullet_rect(TURRET_1_START_ROW, TURRET_1_START_COL, 
                             2, TURRET_1_BULLET_HEIGHT)

TurretEndStep2:
    jmp TurretStepReturn

TurretTryFrame3:
    cmp #TURRET_1_FRAMES-2
    beq TurretWasFrame3
    jmp TurretTryFrame4

TurretWasFrame3:
    lda #TURRET_1_CHAR
    ldx #TURRET_1_COLOR
    nv_screen_poke_color_char_xa(TURRET_1_START_ROW-4, TURRET_1_START_COL)
    nv_screen_poke_color_char_xa(TURRET_1_START_ROW-5, TURRET_1_START_COL)

    lda background_color
    nv_screen_poke_color_a(TURRET_1_START_ROW-2, TURRET_1_START_COL)
    nv_screen_poke_color_a(TURRET_1_START_ROW-3, TURRET_1_START_COL)

    turret_1_set_bullet_rect(TURRET_1_START_ROW, TURRET_1_START_COL, 
                            3, TURRET_1_BULLET_HEIGHT)

TurretEndStep3:
    jmp TurretStepReturn

TurretTryFrame4:
    cmp #TURRET_1_FRAMES-3
    beq TurretWasFrame4
    jmp TurretTryFrame5
TurretWasFrame4:
    lda #TURRET_1_CHAR
    ldx #TURRET_1_COLOR
    nv_screen_poke_color_char_xa(TURRET_1_START_ROW-6, TURRET_1_START_COL)
    nv_screen_poke_color_char_xa(TURRET_1_START_ROW-7, TURRET_1_START_COL)

    lda background_color
    nv_screen_poke_color_a(TURRET_1_START_ROW-4, TURRET_1_START_COL)
    nv_screen_poke_color_a(TURRET_1_START_ROW-5, TURRET_1_START_COL)
    turret_1_set_bullet_rect(TURRET_1_START_ROW, TURRET_1_START_COL, 
                             4, TURRET_1_BULLET_HEIGHT)

TurretEndStep4:
    jmp TurretStepReturn

TurretTryFrame5:
    cmp #TURRET_1_FRAMES-4
    beq TurretWasFrame5
    jmp TurretTryFrame6
TurretWasFrame5:
    lda #TURRET_1_CHAR
    ldx #TURRET_1_COLOR
    nv_screen_poke_color_char_xa(TURRET_1_START_ROW-8, TURRET_1_START_COL)
    nv_screen_poke_color_char_xa(TURRET_1_START_ROW-9, TURRET_1_START_COL)
    lda background_color
    nv_screen_poke_color_a(TURRET_1_START_ROW-6, TURRET_1_START_COL)
    nv_screen_poke_color_a(TURRET_1_START_ROW-7, TURRET_1_START_COL)

    turret_1_set_bullet_rect(TURRET_1_START_ROW, TURRET_1_START_COL, 
                            5, TURRET_1_BULLET_HEIGHT)

TurretEndStep5:
    jmp TurretStepReturn

TurretTryFrame6:
    cmp #TURRET_1_FRAMES-5
    beq TurretWasFrame6
    jmp TurretTryFrame7
TurretWasFrame6:
    lda #TURRET_1_CHAR
    ldx #TURRET_1_COLOR
    nv_screen_poke_color_char_xa(TURRET_1_START_ROW-10, TURRET_1_START_COL)
    lda background_color
    nv_screen_poke_color_a(TURRET_1_START_ROW-8, TURRET_1_START_COL)
    nv_screen_poke_color_a(TURRET_1_START_ROW-9, TURRET_1_START_COL)
    turret_1_set_bullet_rect(TURRET_1_START_ROW, TURRET_1_START_COL, 
                            6, 1)  // bullet only one char for this frame
TurretEndStep6:
    jmp TurretStepReturn

TurretTryFrame7:
    lda background_color
    nv_screen_poke_color_a(TURRET_1_START_ROW-10, TURRET_1_START_COL)

  
TurretStepReturn:    
    dec turret_1_count    // decrement turret frame counter

TurretStepDone:
    rts
// Turret1DoStep subroutine end
//////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////////////////
// subroutine to step turret 1
// it should only be called if turret 1 known to be active
// which means turret_2_count > 0
Turret2DoStep:    
    lda turret_2_count
    
Turret2TryFrame1:
    cmp #TURRET_2_FRAMES
    beq Turret2WasFrame1
    jmp Turret2TryFrame2

Turret2WasFrame1:
    lda #TURRET_2_CHAR
    ldx #TURRET_2_COLOR
    nv_screen_poke_color_char_xa(TURRET_2_START_ROW, TURRET_2_START_COL)
    nv_screen_poke_color_char_xa(TURRET_2_START_ROW-1, TURRET_2_START_COL)

    turret_set_bullet_rect(turret_2_bullet_rect,
                            TURRET_2_START_ROW, TURRET_2_START_COL, 
                            1, TURRET_2_BULLET_HEIGHT)

Turret2EndStep1:
    jmp Turret2StepReturn

Turret2TryFrame2:
    cmp #TURRET_2_FRAMES-1
    beq Turret2WasFrame2
    jmp Turret2TryFrame3

Turret2WasFrame2:
    lda #TURRET_2_CHAR
    ldx #TURRET_2_COLOR
    nv_screen_poke_color_char_xa(TURRET_2_START_ROW-2, TURRET_2_START_COL)
    nv_screen_poke_color_char_xa(TURRET_2_START_ROW-3, TURRET_2_START_COL)

    lda background_color
    nv_screen_poke_color_a(TURRET_2_START_ROW, TURRET_2_START_COL)
    nv_screen_poke_color_a(TURRET_2_START_ROW-1, TURRET_2_START_COL)
    
    turret_set_bullet_rect(turret_2_bullet_rect,
                           TURRET_2_START_ROW, TURRET_2_START_COL, 
                           2, TURRET_2_BULLET_HEIGHT)

Turret2EndStep2:
    jmp Turret2StepReturn

Turret2TryFrame3:
    cmp #TURRET_2_FRAMES-2
    beq Turret2WasFrame3
    jmp Turret2TryFrame4

Turret2WasFrame3:
    lda #TURRET_2_CHAR
    ldx #TURRET_2_COLOR
    nv_screen_poke_color_char_xa(TURRET_2_START_ROW-4, TURRET_2_START_COL)
    nv_screen_poke_color_char_xa(TURRET_2_START_ROW-5, TURRET_2_START_COL)

    lda background_color
    nv_screen_poke_color_a(TURRET_2_START_ROW-2, TURRET_2_START_COL)
    nv_screen_poke_color_a(TURRET_2_START_ROW-3, TURRET_2_START_COL)

    turret_set_bullet_rect(turret_2_bullet_rect,
                           TURRET_2_START_ROW, TURRET_2_START_COL, 
                           3, TURRET_2_BULLET_HEIGHT)

Turret2EndStep3:
    jmp Turret2StepReturn

Turret2TryFrame4:
    cmp #TURRET_2_FRAMES-3
    beq Turret2WasFrame4
    jmp Turret2TryFrame5
Turret2WasFrame4:
    lda #TURRET_2_CHAR
    ldx #TURRET_2_COLOR
    nv_screen_poke_color_char_xa(TURRET_2_START_ROW-6, TURRET_2_START_COL)
    nv_screen_poke_color_char_xa(TURRET_2_START_ROW-7, TURRET_2_START_COL)

    lda background_color
    nv_screen_poke_color_a(TURRET_2_START_ROW-4, TURRET_2_START_COL)
    nv_screen_poke_color_a(TURRET_2_START_ROW-5, TURRET_2_START_COL)
    turret_set_bullet_rect(turret_2_bullet_rect, 
                           TURRET_2_START_ROW, TURRET_2_START_COL, 
                           4, TURRET_2_BULLET_HEIGHT)

Turret2EndStep4:
    jmp Turret2StepReturn

Turret2TryFrame5:
    cmp #TURRET_2_FRAMES-4
    beq Turret2WasFrame5
    jmp Turret2TryFrame6
Turret2WasFrame5:
    lda #TURRET_2_CHAR
    ldx #TURRET_2_COLOR
    nv_screen_poke_color_char_xa(TURRET_2_START_ROW-8, TURRET_2_START_COL)
    nv_screen_poke_color_char_xa(TURRET_2_START_ROW-9, TURRET_2_START_COL)
    lda background_color
    nv_screen_poke_color_a(TURRET_2_START_ROW-6, TURRET_2_START_COL)
    nv_screen_poke_color_a(TURRET_2_START_ROW-7, TURRET_2_START_COL)

    turret_set_bullet_rect(turret_2_bullet_rect, 
                           TURRET_2_START_ROW, TURRET_2_START_COL, 
                           5, TURRET_2_BULLET_HEIGHT)

Turret2EndStep5:
    jmp Turret2StepReturn

Turret2TryFrame6:
    cmp #TURRET_2_FRAMES-5
    beq Turret2WasFrame6
    jmp Turret2TryFrame7
Turret2WasFrame6:
    lda #TURRET_2_CHAR
    ldx #TURRET_2_COLOR
    nv_screen_poke_color_char_xa(TURRET_2_START_ROW-10, TURRET_2_START_COL)
    lda background_color
    nv_screen_poke_color_a(TURRET_2_START_ROW-8, TURRET_2_START_COL)
    nv_screen_poke_color_a(TURRET_2_START_ROW-9, TURRET_2_START_COL)
    turret_set_bullet_rect(turret_2_bullet_rect, 
                           TURRET_2_START_ROW, TURRET_2_START_COL, 
                           6, 1)  // bullet only one char for this frame
Turret2EndStep6:
    jmp Turret2StepReturn

Turret2TryFrame7:
    lda background_color
    nv_screen_poke_color_a(TURRET_2_START_ROW-10, TURRET_2_START_COL)

  
Turret2StepReturn:    
    dec turret_2_count    // decrement turret frame counter

Turret2StepDone:
    rts

// Turret2DoStep end
//////////////////////////////////////////////////////////////////////////////