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


//////////////////////////////////////////////////////////////////////////////
// call once to initialize turret variables and stuff
TurretInit:
    lda #$00
    sta turret_1_count
    sta turret_2_count
    sta turret_2_frame_number
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

TurretStartTry2:
    lda #TURRET_2_ID
    bit turret_start_ids
    beq TurretStartTry3
TurretStartIs2:
    lda #TURRET_2_FRAMES
    sta turret_2_count
    lda #0
    sta turret_2_frame_number

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
    lda #0
    sta turret_2_count
    sta turret_2_frame_number
    lda background_color
    nv_screen_poke_color_to_coord_list(turret_2_char_coords)
}

.macro turret_force_stop_id_3(save_block)
{
    lda #0
    sta turret_3_count
    sta turret_3_frame_number
    nv_store16_immediate(turret_3_char_mem_cur, TURRET_3_CHAR_MEM_START)
    nv_store16_immediate(turret_3_color_mem_cur, TURRET_3_COLOR_MEM_START)

    lda background_color
    //nv_stream_proc(turret_3_all_color_stream, save_block)
    ldx #<turret_3_all_color_stream
    ldy #>turret_3_all_color_stream
    jsr TurretStreamProcess

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
// turret position, frame number and bullet height.
// macro params: 
//   rect: is the address of the rect to update
//         this is 8 bytes, 4 16bit ints (left, top, right, bottom) 
//         in screen pixel coords
//   start_row: pass the row number of the bullet in character coords
//   start_col: pass the col number of the bullet in char coords
//   frame number is the frame
/*
.macro turret_set_bullet_3_rect(rect, start_row, start_col, frame, bullet_width, bullet_height)
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
*/
// turret_set_bullet_rect macro end
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
// subroutine to step turret 2
// it should only be called if this turret known to be active
// which means turret_2_count > 0
Turret2DoStep:    
{
    ldy #$00
    ldx turret_2_frame_number
    bne Loop
    jmp FirstFrameNoErase
Loop:
    iny
    iny
    dex
    bne Loop

// erase last frame's bullets
EraseLastFrame:
    sty save_index
    dey
    dey
    lda turret_2_char_coords, y
    tax
    iny
    lda turret_2_char_coords, y
    tay
    lda background_color
    //   X Reg: screen column
    //   Y Reg: screen row
    //   Accum: color to poke
    nv_screen_poke_color_xya()
    ldy save_index
FirstFrameNoErase:

    // y reg should now have the index into the coord list
    lda turret_2_char_coords, y
    bpl NotEndOfCoords
    jmp NoMoreCoords
NotEndOfCoords:
    tax
    stx save_x
    iny
    lda turret_2_char_coords, y
    tay
    sty save_y
    lda #TURRET_2_CHAR

    //   X Reg: screen column
    //   Y Reg: screen row
    //   Accum: char to poke
    nv_screen_poke_char_xya()

    ldy save_y
    ldx save_x
    lda #NV_COLOR_WHITE
    //   X Reg: screen column
    //   Y Reg: screen row
    //   Accum: color to poke
    nv_screen_poke_color_xya()

    ldy save_y
    ldx save_x
    nv_screen_rect_char_coord_to_screen_pixels(turret_2_bullet_rect)

NoMoreCoords:
Turret2StepReturn:    
    dec turret_2_count          // decrement turret frame counter
    beq IsLastFrame
    jmp NotLastFrame
IsLastFrame:
    ldy save_y
    ldx save_x
    lda background_color
    nv_screen_poke_color_xya()

NotLastFrame:
    inc turret_2_frame_number   // increment the current frame

Turret2StepDone:
    rts
save_index: .byte 0
save_x: .byte 0
save_y: .byte 0
}

// Turret2DoStep end
//////////////////////////////////////////////////////////////////////////////



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

//////////////////////////////////////////////////////////////////////////////
// subroutine to step turret 3
// it should only be called if this turret known to be active
// which means turret_3_count > 0
Turret3DoStep:    
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



//   Accum: will change, Input: should hold the byte that will be stored 
//   X Reg: will change, Input: LSB of stream data's addr.  
//   Y Reg: will change, Input: MSB of Stream data's addr 
TurretStreamProcess:
    nv_stream_proc_sr(temp_word, save_block)

temp_word: .word $0000
save_block: .word $0000
            .word $0000



