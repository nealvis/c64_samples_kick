//////////////////////////////////////////////////////////////////////////////
// astro_blackhole_data.asm 
//////////////////////////////////////////////////////////////////////////////
// The following subroutines should be called from the main engine
// as follows
// HoleInit: Call once before main loop
// HoleStep: Call once every raster frame through the main loop
// HoleStart: Call to start the effect
// HoleForceStop: Call to force effect to stop if it is active
// HoleCleanup: Call at end of program after main loop to clean up
//////////////////////////////////////////////////////////////////////////////
#importonce 

#import "../nv_c64_util/nv_c64_util_macs_and_data.asm"
#import "astro_vars_data.asm"
#import "astro_blackhole_data.asm"
#import "astro_ships_code.asm"
#import "../nv_c64_util/nv_rand_macs.asm"

//////////////////////////////////////////////////////////////////////////////
// subroutine to start the initialize effect, call once before main loop
HoleInit:
{
    // reduce velocity while count greater than 0
    lda #$00
    sta hole_count
    sta hole_hit

    jsr blackhole.Setup
    jsr blackhole.SetLocationFromExtraData

    rts
}

//////////////////////////////////////////////////////////////////////////////
// subroutine to start the effect
HoleStart:
{
    lda hole_count
    bne HoleAlreadyStarted
    lda #HOLE_FRAMES
    sta hole_count
    lda #HOLE_FRAMES_BETWEEN_STEPS
    sta hole_frame_counter

    // start sprite out at first frame of its animation
    ldx #<sprite_hole_0
    lda #>sprite_hole_0
    jsr blackhole.SetDataPtr

    nv_store16_immediate(blackhole.x_loc, NV_SPRITE_RIGHT_WRAP_DEFAULT)
    //lda #NV_SPRITE_TOP_WRAP_DEFAULT
    nv_rand_byte_a(true)
    //and #$7F
    clc
    adc #NV_SPRITE_TOP_WRAP_DEFAULT

    // set Y velocity.  start with positive 1 but 
    // get random bit to decide to change
    sta blackhole.y_loc
    lda #1
    sta blackhole.y_vel
    nv_rand_byte_a(true)
    sta hole_change_vel_at_x_loc
    and #$01
    bne SkipNegVelY
NegVelY:
    lda #$FF
    sta blackhole.y_vel
SkipNegVelY:
    lda #$FF    
    sta blackhole.x_vel

    jsr blackhole.Enable
HoleAlreadyStarted:
    rts
}

//////////////////////////////////////////////////////////////////////////////
// Subroutine to determine if hole is active
// Accum: will be set to non zero if active or zero if not active
HoleActive:
{
    lda hole_count
    rts
}
//
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// subroutine to call once per raster frame while blackhole is active
// if hole_count is zero then this routine will do nothing. 
// continually calling the routine will eventually get to 
// the state of hole_count = 0 so its safe
// to call this once every raster frame regardless of if effect is active
// or not.  
HoleStep:
{
    lda hole_count
    bne HoleStillStepping
    rts
    
HoleStillStepping:
    // sprite movement, every frame
    // change the Y velocity of hole when its left of
    // the hole_change_vel_at_x_loc 
    lda hole_change_vel_at_x_loc
    cmp blackhole.x_loc              // set carry if accum >= Mem
    bcc NoChange                     // branch if hole x_loc < hole_change_at_x_loc
Change:
    nv_rand_byte_a(true)             // get random byte in Accum
    and #$3F                         // make sure its not bigger than 63
    sta scratch_byte                 // store this random num betwn 0-63
    lda hole_change_vel_at_x_loc     // setup to subtract the random from
    sec                              // the last change location
    sbc scratch_byte                 // do subtraction
    sta hole_change_vel_at_x_loc     // save the next x location to change
    nv_rand_byte_a(true)             // get new random byte
    and #$03                         // make sure its between 0 and 3
    tax                              // use the rand between 0-3 as index
    lda y_vel_table,x                // look up the new y vel in table
    sta blackhole.y_vel              // store new y vel
NoChange:    
    jsr blackhole.MoveInExtraData
    nv_bgt16_immediate(blackhole.x_loc, 20, HoleStillAlive)
    // hole is done if we get here
    jsr HoleForceStop
    rts
HoleStillAlive:
    // update in memory location based on velocity
    jsr blackhole.SetLocationFromExtraData

    // update the hitbox based on updated location
    jsr HoleUpdateRect

    // check if time to animate the sprite
    dec hole_frame_counter
    bne HoleStepDone            // if not zero then not time yet
   
    // is time to animate sprite

    // reset our frame counter between animation steps
    lda #HOLE_FRAMES_BETWEEN_STEPS
    sta hole_frame_counter

    // get zero based frame number into y reg
    // then multiply by two to get the index 
    // into our sprite data ptr address table
    lda #HOLE_FRAMES
    sec
    sbc hole_count
    asl
    tay         // y reg now holds index into table of the
                // byte that has the LSB of the sprite data ptr

    // LSB of sprite's data ptr to x and
    // MSB to Accum so we can call the SetDataPtr
    ldx hole_sprite_data_ptr_table, y
    iny 
    lda hole_sprite_data_ptr_table, y
    jsr blackhole.SetDataPtr

    // decrement the count 
    dec hole_count
    bne HoleStepDone
    lda #HOLE_FRAMES-2  // last few frames repeat
    //lda #HOLE_FRAMES
    sta hole_count    

HoleStepDone:
    rts
y_vel_table: 
    .byte $00
    .byte $01
    .byte $FF
    .byte $00    
}
// HoleStep End.    
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// subroutine to call to force the effect to stop if it is active. if not 
// active then should have no effect
HoleForceStop:
{
    lda #$00
    sta hole_count
    sta hole_hit
    jsr blackhole.Disable
    rts
}
// HoleForceStop End
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// subroutine to call at end of program when done with all other effect
// data and routines.
HoleCleanup:
    jsr HoleForceStop
    rts
// HoleCleanup End
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// internal subroutine to update the hole_rect.  should be called whenever
// the sprites location in memory is updated
HoleUpdateRect:
{
    /////////// put hole sprite's rectangle, use the hitbox not full sprite
    nv_xfer16_mem_mem(blackhole.x_loc, hole_x_left)
    nv_adc16_8(hole_x_left, blackhole.hitbox_right, hole_x_right)
    nv_adc16_8(hole_x_left, blackhole.hitbox_left, hole_x_left)
    lda blackhole.y_loc     // 8 bit value so manually load MSB with $00
    sta hole_y_top
    lda #$00
    sta hole_y_top+1
    nv_adc16_8(hole_y_top, blackhole.hitbox_bottom, hole_y_bottom)
    nv_adc16_8(hole_y_top, blackhole.hitbox_top, hole_y_top)
    rts
}
// HoleUpdateRect - end
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// Namespace with everything related to asteroid 5
.namespace blackhole
{
        .var info = nv_sprite_info_struct("black_hole", 6,
                                          200, 100, -1, 0, // init x, y, VelX, VelY 
                                          sprite_hole_0, 
                                          sprite_extra, 
                                          1, 0, 1, 0, // bounce on top, left, bottom, right  
                                          0, 0, 0, 0, // min/max top, left, bottom, right
                                          0,            // sprite enabled 
                                          0, 0, 24, 21) // hitbox left, top, right, bottom

        .label x_loc = info.base_addr + NV_SPRITE_X_OFFSET
        .label y_loc = info.base_addr + NV_SPRITE_Y_OFFSET
        .label x_vel = info.base_addr + NV_SPRITE_VEL_X_OFFSET
        .label y_vel = info.base_addr + NV_SPRITE_VEL_Y_OFFSET
        .label data_ptr = info.base_addr + NV_SPRITE_DATA_PTR_OFFSET
        .label sprite_num = info.base_addr + NV_SPRITE_NUM_OFFSET
        .label hitbox_left = info.base_addr + NV_SPRITE_HITBOX_LEFT_OFFSET
        .label hitbox_top = info.base_addr + NV_SPRITE_HITBOX_TOP_OFFSET
        .label hitbox_right = info.base_addr + NV_SPRITE_HITBOX_RIGHT_OFFSET
        .label hitbox_bottom = info.base_addr + NV_SPRITE_HITBOX_BOTTOM_OFFSET

// sprite extra data
sprite_extra:
        nv_sprite_extra_data(info)

LoadExtraPtrToRegs:
    lda #>info.base_addr
    ldx #<info.base_addr
    rts


// subroutine to set sprites location in sprite registers based on the extra data
SetLocationFromExtraData:
        lda #>info.base_addr
        ldx #<info.base_addr
        jsr NvSpriteSetLocationFromExtra
        rts

// setup sprite so that it ready to be enabled and displayed
Setup:
        lda #>info.base_addr
        ldx #<info.base_addr
        jsr NvSpriteSetupFromExtra
        rts

// move the sprite x and y location in the extra data only, not in the sprite registers
// to move in the sprite registsers (and have screen reflect it) call the 
// SetLocationFromExtraData subroutine.
MoveInExtraData:
        //lda #>info.base_addr
        //ldx #<info.base_addr
        //jsr NvSpriteMoveInExtra
        //rts
        nv_sprite_move_any_direction_sr(info)

Enable:
        lda #>info.base_addr
        ldx #<info.base_addr
        nv_sprite_extra_enable_sr()

Disable:
        lda #>info.base_addr
        ldx #<info.base_addr
        nv_sprite_extra_disable_sr()

LoadEnabledToA:
        lda info.base_addr + NV_SPRITE_ENABLED_OFFSET
        rts


SetBounceAllOn:
        nv_sprite_set_all_actions_sr(info, NV_SPRITE_ACTION_BOUNCE)

SetWrapAllOn:
        nv_sprite_set_all_actions_sr(info, NV_SPRITE_ACTION_WRAP)

// Accum must have MSB of new data_ptr
// X Reg must have LSB of new data_ptr
SetDataPtr:
    stx data_ptr
    sta data_ptr+1

    //   Accum: MSB of address of nv_sprite_extra_data
    //   X Reg: LSB of address of the nv_sprite_extra_data
    lda #>info.base_addr
    ldx #<info.base_addr
    jsr NvSpriteSetDataPtrFromExtra
    rts
}

