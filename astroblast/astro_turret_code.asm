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
//#import "../nv_c64_util/nv_debug_code.asm"

//////////////////////////////////////////////////////////////////////////////
// call once to initialize turret variables and stuff
TurretInit:
    lda #$00
    sta turret_1_count
    sta turret_1_cur_frame
    sta turret_2_count
    sta turret_3_count
    sta turret_3_frame_number
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
    lda #$01
    sta turret_1_cur_frame

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
    beq TurretActiveTry4
  TurretActiveIs3:
    ldx turret_3_count
    beq TurretActiveTry4
    ora turret_active_retval
    sta turret_active_retval

  TurretActiveTry4:
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
    sta turret_1_cur_frame
        // all positions to background color 
    lda background_color
    ldx #<turret_1_all_color_stream
    ldy #>turret_1_all_color_stream
    jsr TurretStreamProcessor

}

.macro turret_force_stop_id_2()
{
    lda #0
    sta turret_2_count

    // all positions to background color 
    lda background_color
    ldx #<turret_2_all_color_stream
    ldy #>turret_2_all_color_stream
    jsr TurretStreamProcessor
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
    jsr TurretStreamProcessor
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
    //TODO

    rts
// TurretStep subroutine end
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
Turret1DoStep:
{
    // sanity check that count isn't already zero
    lda turret_1_count
    beq Done                        // if count has hit zero then done
    
    lda #TURRET_1_FRAMES            // load total num frames
    sec                             // set carry for to prep for subtraction
    sbc turret_1_count              // sub cur count value to get zero based
                                    // frame count into accum
    asl                             // multiply by two since table is 16 bit addrs
    tay                             // put result in y its index to stream LSB
    lda Turret1StreamAddrTable, y   // load stream LSB in Accm
    tax                             // move LSB of stream start to x
    iny                             // inc index point to MSB of addr in table
    lda Turret1StreamAddrTable, y   // load accum with MSB of stream start
    tay                             // move MSB of stream start to Y addr
    jsr TurretStreamProcessor       // x, and y set for this frame's stream
                                    // so jsr to stream processor

    dec turret_1_count              // dec count
Done:
    rts
}

/*
//////////////////////////////////////////////////////////////////////////////
// subroutine to step turret 1
// it should only be called if turret 1 known to be active
// which means turret_1_count > 0
Turret1DoStep:    
    lda turret_1_count

Turret1TryFrame1:
    cmp #TURRET_1_FRAMES
    beq Turret1WasFrame1
    jmp Turret1TryFrame2

Turret1WasFrame1:
    ldx #<turret_1_stream_frame_1
    ldy #>turret_1_stream_frame_1
    jsr TurretStreamProcessor
    
Turret1EndStep1:
    jmp Turret1StepReturn

Turret1TryFrame2:
    cmp #TURRET_1_FRAMES-1
    beq Turret1WasFrame2
    jmp Turret1TryFrame3

Turret1WasFrame2:
    ldx #<turret_1_stream_frame_2
    ldy #>turret_1_stream_frame_2
    jsr TurretStreamProcessor

Turret1EndStep2:
    jmp Turret1StepReturn

Turret1TryFrame3:
    cmp #TURRET_1_FRAMES-2
    beq Turret1WasFrame3
    jmp Turret1TryFrame4

Turret1WasFrame3:
    ldx #<turret_1_stream_frame_3
    ldy #>turret_1_stream_frame_3
    jsr TurretStreamProcessor

Turret1EndStep3:
    jmp Turret1StepReturn

Turret1TryFrame4:
    cmp #TURRET_1_FRAMES-3
    beq Turret1WasFrame4
    jmp Turret1TryFrame5
Turret1WasFrame4:
    ldx #<turret_1_stream_frame_4
    ldy #>turret_1_stream_frame_4
    jsr TurretStreamProcessor

Turret1EndStep4:
    jmp Turret1StepReturn

Turret1TryFrame5:
    cmp #TURRET_1_FRAMES-4
    beq Turret1WasFrame5
    jmp Turret1TryFrame6
Turret1WasFrame5:
    ldx #<turret_1_stream_frame_5
    ldy #>turret_1_stream_frame_5
    jsr TurretStreamProcessor

Turret1EndStep5:
    jmp Turret1StepReturn

Turret1TryFrame6:
    cmp #TURRET_1_FRAMES-5
    beq Turret1WasFrame6
    jmp Turret1TryFrame7
Turret1WasFrame6:
    ldx #<turret_1_stream_frame_6
    ldy #>turret_1_stream_frame_6
    jsr TurretStreamProcessor

Turret1EndStep6:
    jmp Turret1StepReturn

Turret1TryFrame7:
    ldx #<turret_1_stream_frame_7
    ldy #>turret_1_stream_frame_7
    jsr TurretStreamProcessor
  
Turret1StepReturn:    
    dec turret_1_count    // decrement turret frame counter

Turret1StepDone:
    rts
// Turret1DoStep subroutine end
//////////////////////////////////////////////////////////////////////////////
*/


//////////////////////////////////////////////////////////////////////////////
// subroutine to step turret 2
// it should only be called if turret 2 known to be active
// which means turret_2_count > 0
Turret2DoStep:    
{
    lda turret_2_count

Turret2TryFrame1:
    cmp #TURRET_2_FRAMES
    beq Turret2WasFrame1
    jmp Turret2TryFrame2

Turret2WasFrame1:
    ldx #<turret_2_stream_frame_1
    ldy #>turret_2_stream_frame_1
    jsr TurretStreamProcessor

Turret2EndStep1:
    jmp Turret2StepReturn

Turret2TryFrame2:
    cmp #TURRET_2_FRAMES-1
    beq Turret2WasFrame2
    jmp Turret2TryFrame3

Turret2WasFrame2:
    ldx #<turret_2_stream_frame_2
    ldy #>turret_2_stream_frame_2
    jsr TurretStreamProcessor
    
Turret2EndStep2:
    jmp Turret2StepReturn

Turret2TryFrame3:
    cmp #TURRET_2_FRAMES-2
    beq Turret2WasFrame3
    jmp Turret2TryFrame4

Turret2WasFrame3:
    ldx #<turret_2_stream_frame_3
    ldy #>turret_2_stream_frame_3
    jsr TurretStreamProcessor

Turret2EndStep3:
    jmp Turret2StepReturn

Turret2TryFrame4:
    cmp #TURRET_2_FRAMES-3
    beq Turret2WasFrame4
    jmp Turret2TryFrame5
Turret2WasFrame4:
    ldx #<turret_2_stream_frame_4
    ldy #>turret_2_stream_frame_4
    jsr TurretStreamProcessor

Turret2EndStep4:
    jmp Turret2StepReturn

Turret2TryFrame5:
    cmp #TURRET_2_FRAMES-4
    beq Turret2WasFrame5
    jmp Turret2TryFrame6
Turret2WasFrame5:
    ldx #<turret_2_stream_frame_5
    ldy #>turret_2_stream_frame_5
    jsr TurretStreamProcessor

Turret2EndStep5:
    jmp Turret2StepReturn

Turret2TryFrame6:
    cmp #TURRET_2_FRAMES-5
    beq Turret2WasFrame6
    jmp Turret2TryFrame7
Turret2WasFrame6:
    ldx #<turret_2_stream_frame_6
    ldy #>turret_2_stream_frame_6
    jsr TurretStreamProcessor

Turret2EndStep6:
    jmp Turret2StepReturn

Turret2TryFrame7:
    ldx #<turret_2_stream_frame_7
    ldy #>turret_2_stream_frame_7
    jsr TurretStreamProcessor
    turret_clear_rect(turret_2_bullet_rect)
  
Turret2StepReturn:    
    dec turret_2_count    // decrement turret frame counter

Turret2StepDone:
    rts
}
// Turret2DoStep subroutine end
//////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////////////////
// subroutine to step turret 2
// it should only be called if turret 2 known to be active
// which means turret_2_count > 0
Turret3DoStep:    
{
    lda turret_3_count

Turret3TryFrame1:
    cmp #TURRET_3_FRAMES
    beq Turret3WasFrame1
    jmp Turret3TryFrame2

Turret3WasFrame1:
    ldx #<turret_3_stream_frame_1
    ldy #>turret_3_stream_frame_1
    jsr TurretStreamProcessor

Turret3EndStep1:
    jmp Turret3StepReturn

Turret3TryFrame2:
    cmp #TURRET_3_FRAMES-1
    beq Turret3WasFrame2
    jmp Turret3TryFrame3

Turret3WasFrame2:
    ldx #<turret_3_stream_frame_2
    ldy #>turret_3_stream_frame_2
    jsr TurretStreamProcessor
    
Turret3EndStep2:
    jmp Turret3StepReturn

Turret3TryFrame3:
    cmp #TURRET_3_FRAMES-2
    beq Turret3WasFrame3
    jmp Turret3TryFrame4

Turret3WasFrame3:
    ldx #<turret_3_stream_frame_3
    ldy #>turret_3_stream_frame_3
    jsr TurretStreamProcessor

Turret3EndStep3:
    jmp Turret3StepReturn

Turret3TryFrame4:
    cmp #TURRET_3_FRAMES-3
    beq Turret3WasFrame4
    jmp Turret3TryFrame5
Turret3WasFrame4:
    ldx #<turret_3_stream_frame_4
    ldy #>turret_3_stream_frame_4
    jsr TurretStreamProcessor

Turret3EndStep4:
    jmp Turret3StepReturn

Turret3TryFrame5:
    cmp #TURRET_3_FRAMES-4
    beq Turret3WasFrame5
    jmp Turret3TryFrame6
Turret3WasFrame5:
    ldx #<turret_3_stream_frame_5
    ldy #>turret_3_stream_frame_5
    jsr TurretStreamProcessor

Turret3EndStep5:
    jmp Turret3StepReturn

Turret3TryFrame6:
    cmp #TURRET_3_FRAMES-5
    beq Turret3WasFrame6
    jmp Turret3TryFrame7
Turret3WasFrame6:
    ldx #<turret_3_stream_frame_6
    ldy #>turret_3_stream_frame_6
    jsr TurretStreamProcessor

Turret3EndStep6:
    jmp Turret3StepReturn

Turret3TryFrame7:
    cmp #TURRET_3_FRAMES-6
    beq Turret3WasFrame7
    jmp Turret3TryFrame8

Turret3WasFrame7:
    ldx #<turret_3_stream_frame_7
    ldy #>turret_3_stream_frame_7
    jsr TurretStreamProcessor

Turret3EndStep7:
    jmp Turret3StepReturn

Turret3TryFrame8:
    cmp #TURRET_3_FRAMES-7
    beq Turret3WasFrame8
    jmp Turret3TryFrame9

Turret3WasFrame8:
    ldx #<turret_3_stream_frame_8
    ldy #>turret_3_stream_frame_8
    jsr TurretStreamProcessor

Turret3EndStep8:
    jmp Turret3StepReturn

Turret3TryFrame9:
    cmp #TURRET_3_FRAMES-8
    beq Turret3WasFrame9
    jmp Turret3TryFrame10

Turret3WasFrame9:
    ldx #<turret_3_stream_frame_9
    ldy #>turret_3_stream_frame_9
    jsr TurretStreamProcessor

Turret3EndStep9:
    jmp Turret3StepReturn


Turret3TryFrame10:
    cmp #TURRET_3_FRAMES-9
    beq Turret3WasFrame10
    jmp Turret3TryFrame11

Turret3WasFrame10:
    ldx #<turret_3_stream_frame_10
    ldy #>turret_3_stream_frame_10
    jsr TurretStreamProcessor

Turret3EndStep10:
    jmp Turret3StepReturn

Turret3TryFrame11:
    cmp #TURRET_3_FRAMES-10
    beq Turret3WasFrame11
    jmp Turret3TryFrame12

Turret3WasFrame11:
    ldx #<turret_3_stream_frame_11
    ldy #>turret_3_stream_frame_11
    jsr TurretStreamProcessor

Turret3EndStep11:
    jmp Turret3StepReturn

Turret3TryFrame12:
    ldx #<turret_3_stream_frame_12
    ldy #>turret_3_stream_frame_12
    jsr TurretStreamProcessor


Turret3StepReturn:    
    dec turret_3_count    // decrement turret frame counter

Turret3StepDone:
    rts
}
// Turret2DoStep subroutine end
//////////////////////////////////////////////////////////////////////////////



/*
.macro turret_3_poke_bullet_char(char_ptr, save_block)
{

    // store the turret 3 char in screen memory where char_ptr
    // points
    ldx #TURRET_3_CHAR_RIGHT
    nv_store_x_to_mem_ptr(char_ptr, save_block)

    // dec char pointer
    nv_adc16_immediate(char_ptr, $FFFF, char_ptr)
    inx
    nv_store_x_to_mem_ptr(char_ptr, save_block)

    // decrement char pointer once more
    nv_adc16_immediate(char_ptr, $FFFF, char_ptr)
    inx
    nv_store_x_to_mem_ptr(char_ptr, save_block)

}

.macro turret_3_poke_bullet_color_immed(color_ptr, save_block, immed_color)
{
    ldx #immed_color
    nv_store_x_to_mem_ptr(color_ptr, save_block)
    
    nv_adc16_immediate(color_ptr, $FFFF, color_ptr)
    nv_store_x_to_mem_ptr(color_ptr, save_block)

    nv_adc16_immediate(color_ptr, $FFFF, color_ptr)
    nv_store_x_to_mem_ptr(color_ptr, save_block)
}

.macro turret_3_poke_bullet_color_mem(color_ptr, save_block, color_addr)
{
    ldx color_addr
    nv_store_x_to_mem_ptr(color_ptr, save_block)
    
    nv_adc16_immediate(color_ptr, $FFFF, color_ptr)
    nv_store_x_to_mem_ptr(color_ptr, save_block)

    nv_adc16_immediate(color_ptr, $FFFF, color_ptr)
    nv_store_x_to_mem_ptr(color_ptr, save_block)
}

*/


/*
//////////////////////////////////////////////////////////////////////////////
// subroutine to step turret 3
// it should only be called if this turret known to be active
// which means turret_3_count > 0
Turret3DoStep_OLD:    
{
    lda turret_3_frame_number
    bne NotFirstFrame
IsFirstFrame:
    lda #TURRET_3_START_COL
    sta bullet_char_col    
    lda #TURRET_3_START_ROW
    sta bullet_char_row    
    jmp FirstFrameSkipPoint

NotFirstFrame:
    // not first frame 
    lda bullet_char_col
    clc
    adc #TURRET_3_X_VEL
    sta bullet_char_col

    lda bullet_char_row
    clc
    adc #TURRET_3_Y_VEL
    sta bullet_char_row

    // erase previous frame's bullet
    nv_xfer16_mem_mem(turret_3_color_mem_cur, color_ptr)
    turret_3_poke_bullet_color_mem(color_ptr, save_block, background_color)

    // move the bullet position
    nv_adc16_immediate(turret_3_char_mem_cur, TURRET_3_MEM_VEL, turret_3_char_mem_cur)
    nv_bgt16_immediate(turret_3_char_mem_cur, 1024, NotBeyondScreenMem)
    // moving beyond screen memory, so force quit
    lda #$00                    // set to 1 because dec to 0 below
    sta turret_3_count          // force last frame
    rts

NotBeyondScreenMem:
    // move the color mem ptr
    nv_adc16_immediate(turret_3_color_mem_cur, TURRET_3_MEM_VEL, turret_3_color_mem_cur)

FirstFrameSkipPoint:
    // first frame starts here and skips some stuff above like erasing
    // the previous frames bullet and checking for going off screen

    // xfer current screen char ptr to char_ptr
    nv_xfer16_mem_mem(turret_3_char_mem_cur, char_ptr)
    turret_3_poke_bullet_char(char_ptr, save_block)

    ///// now color
    nv_xfer16_mem_mem(turret_3_color_mem_cur, color_ptr)
    turret_3_poke_bullet_color_immed(color_ptr, save_block, TURRET_3_COLOR)

    ldx bullet_char_col
    ldy bullet_char_row
    nv_screen_rect_char_coord_to_screen_pixels(turret_3_bullet_rect)

    inc turret_3_frame_number
    dec turret_3_count          // decrement turret frame counter
    rts

save_block: .byte $00, $00
char_ptr: .word $0000
color_ptr: .word $0000

// head of the bullet for current frame
bullet_char_head_row: .byte 0
bullet_char_head_col: .byte 0

// start of bullet for current frame
bullet_char_row: .byte 0
bullet_char_col: .byte 0
}


// Turret3DoStep end
//////////////////////////////////////////////////////////////////////////////
*/


//   Accum: will change, Input: should hold the byte that will be stored 
//   X Reg: will change, Input: LSB of stream data's addr.  
//   Y Reg: will change, Input: MSB of Stream data's addr 
TurretStreamProcessor:
    nv_stream_proc_sr(temp_word, save_block, background_color)

temp_word: .word $0000
save_block: .word $0000
            .word $0000



