// nv_c64_util
// sprite releated stuff

#importonce

#import "nv_util_data.asm"
#import "nv_color.asm"
#import "nv_math16.asm"
#import "nv_math8.asm"
#import "nv_branch16.asm"
#import "nv_sprite_extra.asm"
#import "nv_sprite_raw_macs.asm"
#import "nv_debug.asm"               // for debugging

//////////////////////////////////////////////////////////////////////////////
// Inline macro (no rts) to setup everything for a sprite so its ready to 
// be enabled and moved.
.macro nv_sprite_setup(info)
{
    nv_sprite_raw_set_mode(info.num, info.data_ptr)
    nv_sprite_raw_set_data_ptr(info.num, info.data_ptr)
    nv_sprite_raw_set_color_from_data(info.num, info.data_ptr)
}

//////////////////////////////////////////////////////////////////////////////
// subroutine macro to setup the sprite so that its ready to be enabled 
// and moved.  
.macro nv_sprite_setup_sr(info)
{
    nv_sprite_setup(info)
    rts
}


//////////////////////////////////////////////////////////////////////////////
// inline macro (no rts) to wait for the a specific scanline  
.macro nv_sprite_wait_specific_scanline(line)
{

// for scanline <= 255 decimal
loop:
    // first wiat for bits 0-7 to match our scan line bits 0-7
    lda $D012   // current scan line low bits 0-7 in $D012
    cmp #(line & $00FF)     // scan line to wait for LSB
    bne loop    // if not equal zero then keep looping

    // low bits matched so check the hi bit in $D011
    lda $D011
    .if (line < 255)
    {
        bmi loop    // If bit 7 is 1 then keep looping
    } 
    else
    {
        bpl loop   // if bit 7 is 0 then keep looping
    }
}




//////////////////////////////////////////////////////////////////////////////
// inline macro (no rts) to wait for the last scanline drawing last row 
// of screen before bottom border starts
.macro nv_sprite_wait_last_scanline()
{
    nv_sprite_wait_specific_scanline(250)
}


////////////////////////////////////////////////////////////////////////////
// subroutine to wait for a specific scan line
.macro nv_sprite_wait_last_scanline_sr()
{
    nv_sprite_wait_last_scanline()
    rts
}


//////////////////////////////////////////////////////////////////////////////
// subroutine to move a sprite based on information in the sprite extra 
// struct (info) that is passed into the macro.  The sprite x and y location
// in memory will be updated according to the x and y velocity.
// Note if the sprite goes off the edge it will be reset to the opposite side
// of the screen or bounce based on sprite extra data
// Note that this only updates the location in memory, it doesn't update the
// sprite location in sprite registers.  To update sprite location in registers
// and on the screen, call nv_sprite_set_location_from_memory_sr after this.
.macro nv_sprite_move_any_direction_sr(info)
{
    ldx nv_sprite_vel_y_addr(info)
    bpl PosVelY

NegVelY:
    nv_sprite_move_negative_y(info)
    jmp DoneY

PosVelY:
    nv_sprite_move_positive_y(info)
    
DoneY:
// Y location done, now on to X
    ldx nv_sprite_vel_x_addr(info)
    bmi NegVelX

PosVelX:
// moving right (positive X velocity)
    nv_sprite_move_positive_x(info)
    jmp FinishedUpdate

NegVelX:
// moving left (negative X velocity)
    nv_sprite_move_negative_x(info)

FinishedUpdate:
    rts                // already popped the return address, jump back now
}

//////////////////////////////////////////////////////////////////////////////
//
.macro nv_sprite_move_positive_y(info)
{
    
    lda nv_sprite_vel_y_addr(info)

    ldx nv_sprite_bottom_action_addr(info)
    beq DoWrap                                          // 0 = wrap, 1 = bounce

DoBounce:   
    clc
    adc nv_sprite_y_addr(info)

    cmp nv_sprite_bottom_max_addr(info)
    bcc AccumHasNewY
    // reverse the y velocity here to do that we do bitwise not + 1 (twos comp)
    lda #$FF
    eor nv_sprite_vel_y_addr(info)
    tax
    inx
    stx nv_sprite_vel_y_addr(info)
    jmp DoneY                                       // don't actually update y
                                                    // when bouncing
    
// bounce bottom flag not set, Don't need to check for bounce
DoWrap:
    clc
    adc nv_sprite_y_addr(info)
    cmp nv_sprite_bottom_max_addr(info)
    bcc AccumHasNewY                                  // if not off bottome then just update

// wrap to top of screen
    lda nv_sprite_top_min_addr(info)
AccumHasNewY:
    sta nv_sprite_y_addr(info)
DoneY:
}


//////////////////////////////////////////////////////////////////////////////
//
.macro nv_sprite_move_negative_y(info)
{
    lda nv_sprite_vel_y_addr(info)                    // load y vel to accum

    ldx nv_sprite_top_action_addr(info)               // load x with top action
    beq DoWrap                                        // 0 = wrap, 1 = bounce

DoBounce:
    clc
    adc nv_sprite_y_addr(info)
    cmp nv_sprite_top_min_addr(info)
    bcs AccumHasNewY
    // reverse the y velocity here to do that we do bitwise not + 1
    lda #$FF
    eor nv_sprite_vel_y_addr(info)
    tax
    inx
    stx nv_sprite_vel_y_addr(info)
    jmp DoneY                                        // don't update Y loc

DoWrap:

    // wrap to other side of screen
    clc
    adc nv_sprite_y_addr(info)
    cmp nv_sprite_top_min_addr(info)
    bcs AccumHasNewY              // branch if accum > min top

    // sprite is less than min top so need to move it to bottom
    lda nv_sprite_bottom_max_addr(info)

AccumHasNewY:
    sta nv_sprite_y_addr(info)
DoneY:
}


//////////////////////////////////////////////////////////////////////////////
//
.macro nv_sprite_move_positive_x(info)
{
    // add x offset + x velocity and put in scratch1
    nv_adc16_8((nv_sprite_x_addr(info)), 
               (nv_sprite_vel_x_addr(info)), 
               (nv_sprite_scratch1_word_addr(info)))


    // scratch1 now has potential new X location
    nv_ble16(nv_sprite_scratch1_word_lsb_addr(info), nv_sprite_right_max_lsb_addr(info), NewLocInScratch1)

    // New X is too far since didn't branch above
    ldx nv_sprite_right_action_addr(info)
    beq DoWrap                                              // 0 = wrap, 1 = bounce

DoBounce:
    // bounce off right side by changing vel to 2's compliment of vel
    lda #$FF
    eor nv_sprite_vel_x_addr(info)
    tax
    inx
    stx nv_sprite_vel_x_addr(info)
    jmp Done

DoWrap:
    // this sprite not set to bounce, so wrap it around
    lda nv_sprite_left_min_lsb_addr(info)
    sta nv_sprite_x_lsb_addr(info)
    lda nv_sprite_left_min_msb_addr(info)
    sta nv_sprite_x_msb_addr(info)
    jmp Done

NewLocInScratch1:
    lda nv_sprite_scratch1_word_lsb_addr(info)
    sta nv_sprite_x_lsb_addr(info)
    lda nv_sprite_scratch1_word_msb_addr(info)
    sta nv_sprite_x_msb_addr(info)
Done:
}


//////////////////////////////////////////////////////////////////////////////
//
.macro nv_sprite_move_negative_x(info)
{
    nv_adc16_8signed((nv_sprite_x_addr(info)), 
                     (nv_sprite_vel_x_addr(info)), 
                     (nv_sprite_scratch1_word_lsb_addr(info)))

    // scratch1 now has potential new X location
    nv_bgt16(nv_sprite_scratch1_word_lsb_addr(info), nv_sprite_left_min_lsb_addr(info), NewLocInScratch1)

    // moved too far left, either bounce or wrap
    ldx nv_sprite_left_action_addr(info)
    beq DoWrap

DoBounce:
// Bounce here, went off left side.  Change vel to 2's compliment of vel
    lda #$FF
    eor nv_sprite_vel_x_addr(info)
    tax
    inx
    stx nv_sprite_vel_x_addr(info)
    jmp Done    // don't update location this frame, just change vel

DoWrap: 
// Wrap from left edge to right edge
    lda nv_sprite_right_max_lsb_addr(info)
    sta nv_sprite_x_lsb_addr(info)
    lda nv_sprite_right_max_msb_addr(info)
    sta nv_sprite_x_msb_addr(info)
    jmp Done

NewLocInScratch1:
    lda nv_sprite_scratch1_word_lsb_addr(info)
    sta nv_sprite_x_lsb_addr(info)
    lda nv_sprite_scratch1_word_msb_addr(info)
    sta nv_sprite_x_msb_addr(info)
Done:
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to set the action for the scenario when the sprite is 
// attempting to move past its left min position.
// macro parameters:
//   info: one of the nv_sprite_info_struct structs
//   value: the action to set, one of the NV_SPRITE_ACTION_XXX values
//          NV_SPRITE_ACTION_BOUNCE,
//          NV_SPRITE_ACTION_WRAP
.macro nv_sprite_set_left_action(info, value)
{
    .if (value != NV_SPRITE_ACTION_BOUNCE && value != NV_SPRITE_ACTION_WRAP)
    {
        .error("ERROR: Invalid action")
    }
    ldx #value
    stx nv_sprite_left_action_addr(info)
}

//////////////////////////////////////////////////////////////////////////////
// inline macro set the action for the scenario when the sprite is 
// attempting to move past its right max position.
// macro parameters:
//   info: one of the nv_sprite_info_struct structs
//   value: the action to set, one of the NV_SPRITE_ACTION_XXX values
//          NV_SPRITE_ACTION_BOUNCE,
//          NV_SPRITE_ACTION_WRAP
.macro nv_sprite_set_right_action(info, value)
{
    .if (value != NV_SPRITE_ACTION_BOUNCE && value != NV_SPRITE_ACTION_WRAP)
    {
        .error("ERROR: Invalid action")
    }
    ldx #value
    stx nv_sprite_right_action_addr(info)
}

//////////////////////////////////////////////////////////////////////////////
// inline macro set the action for the scenario when the sprite is 
// attempting to move past its top min position.
// macro parameters:
//   info: one of the nv_sprite_info_struct structs
//   value: the action to set, one of the NV_SPRITE_ACTION_XXX values
//          NV_SPRITE_ACTION_BOUNCE,
//          NV_SPRITE_ACTION_WRAP
.macro nv_sprite_set_top_action(info, value)
{
    .if (value != NV_SPRITE_ACTION_BOUNCE && value != NV_SPRITE_ACTION_WRAP)
    {
        .error("ERROR: Invalid action")
    }
    ldx #value
    stx nv_sprite_top_action_addr(info)
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to set the action for the scenario when the sprite is 
// attempting to move past its bottom max position.
// macro parameters:
//   info: one of the nv_sprite_info_struct structs
//   value: the action to set, one of the NV_SPRITE_ACTION_XXX values
//          NV_SPRITE_ACTION_BOUNCE,
//          NV_SPRITE_ACTION_WRAP
.macro nv_sprite_set_bottom_action(info, value)
{
    .if (value != NV_SPRITE_ACTION_BOUNCE && value != NV_SPRITE_ACTION_WRAP)
    {
        .error("ERROR: Invalid action")
    }
    ldx #value
    stx nv_sprite_bottom_action_addr(info)
}

//////////////////////////////////////////////////////////////////////////////
// in line macro set the action for the scenario when the sprite is 
// attempting to move past any max or min position.
// macro parameters:
//   info: one of the nv_sprite_info_struct structs
//   value: the action to set, one of the NV_SPRITE_ACTION_XXX values
//          NV_SPRITE_ACTION_BOUNCE,
//          NV_SPRITE_ACTION_WRAP
.macro nv_sprite_set_all_actions(info, value)
{
    ldx #value
    stx nv_sprite_left_action_addr(info)
    stx nv_sprite_top_action_addr(info)
    stx nv_sprite_right_action_addr(info)
    stx nv_sprite_bottom_action_addr(info)
}

//////////////////////////////////////////////////////////////////////////////
// subroutine macro to set the action for the scenario when the sprite is 
// attempting to move past its min or max position in any direction.
// macro parameters:
//   info: one of the nv_sprite_info_struct structs
//   value: the action to set, one of the NV_SPRITE_ACTION_XXX values
//          NV_SPRITE_ACTION_BOUNCE,
//          NV_SPRITE_ACTION_WRAP
.macro nv_sprite_set_all_actions_sr(info, value)
{
    nv_sprite_set_all_actions(info, value)
    rts
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to check if there is currently a collision between 
// one sprite and any other sprites.
// macro parameters:
//  sprite_num_to_check: this is the sprite number (0-7) for the sprite
//  we are checking.  
// return: (nv_b8) will contain $FF if no collision with sprite_num sprite
//         or it will have the sprite number for the colliding sprite
.macro nv_sprite_raw_check_collision(sprite_num)
{
    .label collision_bit = nv_a8
    .label closest_sprite = nv_b8
    .label closest_rel_dist = nv_a16
    .label temp_rel_dist = nv_g16    // this is the distance returned from sr
    .label temp_x_dist = nv_c16
    .label temp_y_dist = nv_d16 

    .if (sprite_num > 7)
    {
        .error("Error - nv_sprite_raw_check_collision: sprite_num too big")
    }
    .var sprite_mask = $01 << sprite_num
    .var sprite_mask_negated = sprite_mask ^ $FF

    // set relative distance to largest positive number
    nv_store16_immediate(closest_rel_dist, $8FFF)

    // set closest sprite to $FF which is an invalid sprite
    // if its still this at the end, then no collision with sprite_num
    nv_store8_immediate(closest_sprite, $FF)

    // read the raw collision data from the HW register to accum
    nv_sprite_raw_get_sprite_collisions_in_a()
    sta collision_bit

    and #sprite_mask
    bne HaveCollisionWithSpriteNum
    jmp ClosestSpriteSet    

HaveCollisionWithSpriteNum: 
    // turn off the bit for sprite_num so we don't check for collision 
    // with ourself.
    lda #sprite_mask_negated
    and collision_bit
    sta collision_bit

CheckSprite0:
    ror collision_bit        // rotate bit for sprite 0 (ship) bit to carry
    bcc CheckSprite1 
WasSprite0:
    ldx #sprite_num
    ldy #0
    jsr NvSpriteRawGetRelDistReg      // load temp_rel_dist with rel distance
    nv_bge16(temp_rel_dist, closest_rel_dist, CheckSprite1)

    // save the new closest rel distance
    nv_xfer16_mem_mem(temp_rel_dist, closest_rel_dist)

    // save the new closest sprite
    nv_store8_immediate(closest_sprite, 0)
    

CheckSprite1:
    // carry is set here
    ror collision_bit        // rotate bit for sprite 1 bit to carry
    bcc CheckSprite2
WasSprite1:
    ldx #sprite_num
    ldy #1
    jsr NvSpriteRawGetRelDistReg      // load temp_rel_dist with rel distance
    nv_bge16(temp_rel_dist, closest_rel_dist, CheckSprite2)

    // save the new closest rel distance
    nv_xfer16_mem_mem(temp_rel_dist, closest_rel_dist)

    // save the new closest sprite
    nv_store8_immediate(closest_sprite, 1)

CheckSprite2:
    ror collision_bit        // rotate bit for sprite 2 bit to carry
    bcc CheckSprite3

WasSprite2:
    ldx #sprite_num
    ldy #2
    jsr NvSpriteRawGetRelDistReg      // load temp_rel_dist with rel distance
    nv_bge16(temp_rel_dist, closest_rel_dist, CheckSprite3)

    // save the new closest rel distance
    nv_xfer16_mem_mem(temp_rel_dist, closest_rel_dist)

    // save the new closest sprite
    nv_store8_immediate(closest_sprite, 2)


CheckSprite3:
    ror collision_bit        // rotate bit for sprite 3 bit to carry
    bcc CheckSprite4

WasSprite3:
    ldx #sprite_num
    ldy #3
    jsr NvSpriteRawGetRelDistReg      // load temp_rel_dist with rel distance
    nv_bge16(temp_rel_dist, closest_rel_dist, CheckSprite4)

    // save the new closest rel distance
    nv_xfer16_mem_mem(temp_rel_dist, closest_rel_dist)

    // save the new closest sprite
    nv_store8_immediate(closest_sprite, 3)

CheckSprite4:
    ror collision_bit        // rotate bit for sprite 4 bit to carry
    bcc CheckSprite5

WasSprite4:
    ldx #sprite_num
    ldy #4
    jsr NvSpriteRawGetRelDistReg      // load temp_rel_dist with rel distance
    nv_bge16(temp_rel_dist, closest_rel_dist, CheckSprite5)
    
    // save the new closest rel distance
    nv_xfer16_mem_mem(temp_rel_dist, closest_rel_dist)

    // save the new closest sprite
    nv_store8_immediate(closest_sprite, 4)


CheckSprite5:
    ror collision_bit        // rotate bit for sprite 5 bit to carry
    bcc CheckSprite6

WasSprite5:
    ldx #sprite_num
    ldy #5
    jsr NvSpriteRawGetRelDistReg      // load temp_rel_dist with rel distance
    nv_bge16(temp_rel_dist, closest_rel_dist, CheckSprite6)
    
    // save the new closest rel distance
    nv_xfer16_mem_mem(temp_rel_dist, closest_rel_dist)

    // save the new closest sprite
    nv_store8_immediate(closest_sprite, 5)


CheckSprite6:
    ror collision_bit        // rotate bit for sprite 6 bit to carry
    bcc CheckSprite7

WasSprite6:
    ldx #sprite_num
    ldy #6
    jsr NvSpriteRawGetRelDistReg      // load temp_rel_dist with rel distance
    nv_bge16(temp_rel_dist, closest_rel_dist, CheckSprite7)
    
    // save the new closest rel distance
    nv_xfer16_mem_mem(temp_rel_dist, closest_rel_dist)

    // save the new closest sprite
    nv_store8_immediate(closest_sprite, 6)


CheckSprite7:
    ror collision_bit        // rotate bit for sprite 7 bit to carry
    bcc DoneChecking

WasSprite7:
    ldx #sprite_num
    ldy #7
    jsr NvSpriteRawGetRelDistReg      // load temp_rel_dist with rel distance
    nv_bge16(temp_rel_dist, closest_rel_dist, DoneChecking)
    
    // save the new closest rel distance
    nv_xfer16_mem_mem(temp_rel_dist, closest_rel_dist)

    // save the new closest sprite
    nv_store8_immediate(closest_sprite, 7)

DoneChecking:
    //ror collision_bit        // rotate one more time to get back to beginning 

ClosestSpriteSet: 

}


//////////////////////////////////////////////////////////////////////////////
// macro to get relative distance between two sprites
// the word (16 bit) whose LSB is at rel_dist_addr will return the distance
// between the two sprites
.macro nv_sprite_raw_get_relative_distance(spt_num_a, spt_num_b, rel_dist_addr)
{

    .label temp_x_dist = nv_a16
    .label temp_y_dist = nv_b16
    .label temp_x_a = nv_c16
    .label temp_y_a = nv_d16
    .label temp_x_b = nv_e16
    .label temp_y_b = nv_f16

    // clear the MSB of our temps
    lda #0 
    sta temp_y_a+1
    sta temp_y_b+1

    //nv_sprite_raw_get_location(spt_num_a, temp_x_a, temp_y_a)

    //nv_screen_plot_cursor(24, 0)
    //nv_screen_print_string_basic(blank_str)

    nv_sprite_raw_get_location(spt_num_a, temp_x_a, temp_y_a)
    nv_sprite_raw_get_location(spt_num_b, temp_x_b, temp_y_b)

    nv_bge16(temp_x_a, temp_x_b, BiggerAX)
BiggerBX:
    nv_sbc16(temp_x_b, temp_x_a, temp_x_dist)
    jmp FindDistY
BiggerAX:
    nv_sbc16(temp_x_a, temp_x_b, temp_x_dist)

FindDistY:
    nv_bge16(temp_y_a, temp_y_b, BiggerAY)
BiggerBY:
    nv_adc16(temp_x_dist, temp_y_b, rel_dist_addr)
    nv_sbc16(rel_dist_addr, temp_y_a, rel_dist_addr)
    jmp DebugPrint
BiggerAY:
    nv_adc16(temp_x_dist, temp_y_a, rel_dist_addr)
    nv_sbc16(rel_dist_addr, temp_y_b, rel_dist_addr)

DebugPrint:
/*
    nv_screen_plot_cursor(24, 0)
    lda #spt_num_b
    nv_screen_print_hex_byte(true)
    nv_screen_plot_cursor(24, 5)
    nv_screen_print_hex_word(temp_x_b, true)
    nv_screen_plot_cursor(24, 12)
    nv_screen_print_hex_byte_at_addr(temp_y_b, true)
    //nv_screen_plot_cursor(24,28)
    //nv_screen_print_hex_word(temp_x_dist, true)
    nv_screen_plot_cursor(24,34)
    nv_screen_print_hex_word(rel_dist_addr, true)

    nv_screen_wait_anykey()
*/
}

//////////////////////////////////////////////////////////////////////////////
// subroutine macro to get relative distance between two sprites
// the word (16 bit) whose LSB is at rel_dist_addr will return the distance
// between the two sprites
// subroutine params
//   X register contains the sprite num of one sprite
//   y register contains the sprite num of the other sprite
// macro params:
//   rel_dist_addr: is the 16 bit addr to a word in memory into which 
//                  the relative distance will be placed
temp_x_dist: .word 0
temp_y_dist: .word 0
temp_x_a: .word 0
temp_y_a: .word 0
temp_x_b: .word 0
temp_y_b: .word 0
hold_spt_num_a: .word 0
hold_spt_num_b: .word 0

.macro nv_sprite_raw_get_rel_dist_reg(rel_dist_addr)
{
/*
    .label temp_x_dist = nv_a16
    .label temp_y_dist = nv_b16
    .label temp_x_a = nv_c16
    .label temp_y_a = nv_d16
    .label temp_x_b = nv_e16
    .label temp_y_b = nv_f16
    .label hold_spt_num_a = nv_a8
    .label hold_spt_num_b = nv_b8
*/
    stx hold_spt_num_a
    sty hold_spt_num_b

    // clear the MSB of our temps
    lda #0 
    sta temp_y_a+1
    sta temp_y_b+1

    ldy hold_spt_num_a
    nv_sprite_raw_get_loc_reg(temp_x_a, temp_y_a)

    ldy hold_spt_num_b
    nv_sprite_raw_get_loc_reg(temp_x_b, temp_y_b)

    nv_bge16(temp_x_a, temp_x_b, BiggerAX)
BiggerBX:
    nv_sbc16(temp_x_b, temp_x_a, temp_x_dist)
    jmp FindDistY
BiggerAX:
    nv_sbc16(temp_x_a, temp_x_b, temp_x_dist)

FindDistY:
    nv_bge16(temp_y_a, temp_y_b, BiggerAY)
BiggerBY:
    nv_adc16(temp_x_dist, temp_y_b, rel_dist_addr)
    nv_sbc16(rel_dist_addr, temp_y_a, rel_dist_addr)
    jmp DebugPrint
BiggerAY:
    nv_adc16(temp_x_dist, temp_y_a, rel_dist_addr)
    nv_sbc16(rel_dist_addr, temp_y_b, rel_dist_addr)

DebugPrint:
/*
    nv_screen_plot_cursor(24, 0)
    lda #spt_num_b
    nv_screen_print_hex_byte(true)
    nv_screen_plot_cursor(24, 5)
    nv_screen_print_hex_word(temp_x_b, true)
    nv_screen_plot_cursor(24, 12)
    nv_screen_print_hex_byte_at_addr(temp_y_b, true)
    //nv_screen_plot_cursor(24,28)
    //nv_screen_print_hex_word(temp_x_dist, true)
    nv_screen_plot_cursor(24,34)
    nv_screen_print_hex_word(rel_dist_addr, true)

    nv_screen_wait_anykey()
*/
}


//////////////////////////////////////////////////////////////////////////////
// subroutine to get relative distance between two sprites.
// subroutine params:
//   X Reg: sprite number for one sprite
//   Y Reg: sprite number for other sprite
// Return: (in nv_g16) is a 16bit value that is the relative distance
//         between the two sprites
NvSpriteRawGetRelDistReg:
    nv_sprite_raw_get_rel_dist_reg(nv_g16)
    rts
