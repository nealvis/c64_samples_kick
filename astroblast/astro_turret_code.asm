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
#import "../nv_c64_util/nv_pointer_macs.asm"
#import "../nv_c64_util/nv_stream_processor_macs.asm"
#import "../nv_c64_util/nv_debug_macs.asm"
#import "astro_stream_processor_macs.asm"
#import "astro_stream_processor_code.asm"
//#import "../nv_c64_util/nv_debug_code.asm"

//////////////////////////////////////////////////////////////////////////////
// call once to initialize turret variables and stuff
TurretInit:
    lda #$00
    sta turret_1_count
    sta turret_2_count
    sta turret_3_count
    sta turret_3_frame_number
    sta turret_4_count
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
    beq TurretStartTry4
TurretStartIs3:
    lda #TURRET_3_FRAMES
    sta turret_3_count
    lda #0
    sta turret_3_frame_number
    nv_store16_immediate(turret_3_color_mem_cur, TURRET_3_COLOR_MEM_START)
    nv_store16_immediate(turret_3_char_mem_cur, TURRET_3_CHAR_MEM_START)

TurretStartTry4:
    lda #TURRET_4_ID
    bit turret_start_ids
    beq TurretStartTry5
TurretStartIs4:
    lda #TURRET_4_FRAMES
    sta turret_4_count

TurretStartTry5:
// todo

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
    beq TurretActiveTry4
  TurretActiveIs3:
    ldx turret_3_count
    beq TurretActiveTry4
    ora turret_active_retval
    sta turret_active_retval

  TurretActiveTry4:
    lda #TURRET_4_ID
    bit turret_active_ids
    beq TurretActiveTry5
  TurretActiveIs4:
    ldx turret_4_count
    beq TurretActiveTry5
    ora turret_active_retval
    sta turret_active_retval

  TurretActiveTry5:  
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
    turret_clear_rect(turret_1_bullet_rect)
    lda #$00
    sta turret_1_count
        // all positions to background color 
    lda background_color
    ldx #<turret_1_all_color_stream
    ldy #>turret_1_all_color_stream
    jsr AstroStreamProcessor
}

.macro turret_force_stop_id_2()
{
    lda #0
    sta turret_2_count

    // all positions to background color 
    lda background_color
    ldx #<turret_2_all_color_stream
    ldy #>turret_2_all_color_stream
    jsr AstroStreamProcessor
}

.macro turret_force_stop_id_3(save_block)
{
    lda #0
    sta turret_3_count
    sta turret_3_frame_number
    nv_store16_immediate(turret_3_char_mem_cur, TURRET_3_CHAR_MEM_START)
    nv_store16_immediate(turret_3_color_mem_cur, TURRET_3_COLOR_MEM_START)

    // all positions to background color 
    lda background_color
    ldx #<turret_3_all_color_stream
    ldy #>turret_3_all_color_stream
    jsr AstroStreamProcessor
}

.macro turret_force_stop_id_4()
{
    turret_clear_rect(turret_4_bullet_rect)
    lda #$00
    sta turret_4_count
        // all positions to background color 
    lda background_color
    ldx #<turret_4_all_color_stream
    ldy #>turret_4_all_color_stream
    jsr AstroStreamProcessor
}


//////////////////////////////////////////////////////////////////////////////
// subroutine to force turret effect to stop if it is active. if not 
// active then should do nothing
// Params:
//   Accum: set to the turret ID of the turret to query,
//          or TURRET_ALL_ID to know if any turret is active
// 
TurretForceStop:
{
    sta turret_force_stop_ids

  TurretForceStopTry1:
    lda #TURRET_1_ID
    bit turret_force_stop_ids
    bne TurretForceStopIs1
    jmp TurretForceStopTry2
  TurretForceStopIs1:
    turret_force_stop_id_1()

  TurretForceStopTry2:
    lda #TURRET_2_ID
    bit turret_force_stop_ids
    bne TurretForceStopIs2
    jmp TurretForceStopTry3
  TurretForceStopIs2:
    turret_force_stop_id_2()

  TurretForceStopTry3:
    lda #TURRET_3_ID
    bit turret_force_stop_ids
    bne TurretForceStopIs3
    jmp TurretForceStopTry4
  TurretForceStopIs3:
    turret_force_stop_id_3(turret_force_stop_save_block)

  TurretForceStopTry4:
    lda #TURRET_4_ID
    bit turret_force_stop_ids
    bne TurretForceStopIs4
    jmp TurretForceStopTry5
  TurretForceStopIs4:
    turret_force_stop_id_4()

  TurretForceStopTry5:  
    // TODO

  TurretForceStopDone:
    lda turret_active_retval
    rts
turret_force_stop_save_block: .byte $00, $00
turret_force_stop_ids: .byte 0
}
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
// call once per frame to have turret shoot 
TurretStep:
  TurretStepTry1:
    lda turret_1_count     // check if turret is active (count != 0)
    beq TurretStepTry2     // not zero so it is active 
    jsr Turret1DoStep

  TurretStepTry2:
    lda turret_2_count     // check if turret is active (count != 0)
    beq TurretStepTry3     // not zero so it is active 
    jsr Turret2DoStep
   
  TurretStepTry3:
    lda turret_3_count     // check if turret is active (count != 0)
    beq TurretStepTry4     // not zero so it is active 
    jsr Turret3DoStep

  TurretStepTry4:
    lda turret_4_count     // check if turret is active (count != 0)
    beq TurretStepTry5     // not zero so it is active 
    jsr Turret4DoStep

  TurretStepTry5:
    //TODO

    rts
// TurretStep subroutine end
//////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////////////////
// subroutine to call to step turret 1
Turret1DoStep:
    astro_effect_step_sr(AstroStreamProcessor, turret_1_count, 
                         TURRET_1_FRAMES, Turret1StreamAddrTable)


//////////////////////////////////////////////////////////////////////////////
// subroutine to call to step turret 2
Turret2DoStep:
    astro_effect_step_sr(AstroStreamProcessor, turret_2_count, 
                         TURRET_2_FRAMES, Turret2StreamAddrTable)

// Turret2DoStep - end
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// subroutine to call to step turret 3
Turret3DoStep:
    astro_effect_step_sr(AstroStreamProcessor, turret_3_count, 
                         TURRET_3_FRAMES, Turret3StreamAddrTable)

// Turret3DoStep - end
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// subroutine to call to step turret 1
Turret4DoStep:
    astro_effect_step_sr(AstroStreamProcessor, turret_4_count, 
                         TURRET_4_FRAMES, Turret4StreamAddrTable)

// Turret4DoStep - end
//////////////////////////////////////////////////////////////////////////////



