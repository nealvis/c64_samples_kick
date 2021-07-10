#importonce

#if !NV_C64_UTIL_DATA
.error "Error - nv_sprite_raw_collisions_code.asm: NV_C64_UTIL_DATA not defined.  Import nv_c64_util_data.asm"
#endif

// the #if above doesn't seem to always work so..
// if data hasn't been imported yet, import it into default location
#importif !NV_C64_UTIL_DATA "nv_c64_util_default_data.asm"

#import "nv_math16_macs.asm"
#import "nv_math8_macs.asm"
#import "nv_branch16_macs.asm"
#import "nv_sprite_raw_macs.asm"
#import "nv_debug_macs.asm"

// Comment out to prevent debug messages on screen
//#define DEBUG_COLLISIONS


//////////////////////////////////////////////////////////////////////////////
// inline macro to check if there is currently a collision between 
// one sprite and any other sprites.
// macro parameters:
//   sprite_num_to_check: this is the sprite number (0-7) for the sprite
//   we are checking
// subroutine params:
//   nv_a8: should be set with current HW sprite collisions register 
//           by calling nv_sprite_raw_get_sprite_collisions_in_a or
//           similar methods.  it will be modified within though.
// return: (nv_b8) will contain $FF if no collision with sprite_num sprite
//         or it will have the sprite number for the colliding sprite
.macro nv_sprite_raw_check_collision(sprite_num)
{
    // this macro uses the following data variables from 
    // nv_c64_util_data.asm
    // collision_bit:
    // closest_sprite:
    // closest_rel_dist:

    // The subroutine NvSpriteRawGetRelDistReg will set nv_g16 with the
    // relative distance between two sprites.  we'll call it 
    // temp_rel_dist in this routine to try and stay sane.
    .label temp_rel_dist = nv_g16    


    // current HW sprite collisions register value must have
    // been placed in nv_a8 prior to calling
    lda nv_a8
    sta collision_bit

    .if (sprite_num > 7)
    {
        .error("Error - nv_sprite_raw_check_collision: sprite_num too big")
    }
    .var sprite_mask = $01 << sprite_num
    .var sprite_mask_negated = sprite_mask ^ $FF

    // initialize closest relative distance to largest positive number
    nv_store16_immediate(closest_rel_dist, $8FFF)

    // initialize closest sprite to $FF which is an invalid sprite
    // if its still this at the end, then no collision with sprite_num
    nv_store8_immediate(closest_sprite, $FF)

    lda collision_bit
    nv_debug_print_labeled_byte_mem_coll(10, 0, collision_bit_label1, 17, 
                                         collision_bit, true, false)    

    and #sprite_mask
    bne HaveCollisionWithSpriteNum
    jmp ClosestSpriteSet    

HaveCollisionWithSpriteNum: 
    //nv_debug_print_byte_mem(8, 0, collision_bit, true, false)


    // turn off the bit for sprite_num so we don't check for collision 
    // with ourself.
    lda #sprite_mask_negated
    and collision_bit
    sta collision_bit

    nv_debug_print_labeled_byte_mem_coll(11, 0, collision_bit_label2, 17, 
                                         collision_bit, true, false)    

CheckSprite0:
    ror collision_bit        // rotate bit for sprite 0 (ship) bit to carry
    bcs WasSprite0
    jmp CheckSprite1 
WasSprite0:
    ldx #sprite_num
    ldy #0
    jsr NvSpriteRawGetRelDistReg      // load temp_rel_dist with rel distance
    nv_debug_print_labeled_word_mem_coll(12, 0, spt_0_dist_label, 14, 
                                    temp_rel_dist, true, false)    

    
    nv_bge16(temp_rel_dist, closest_rel_dist, CheckSprite1)

    // save the new closest rel distance
    nv_xfer16_mem_mem(temp_rel_dist, closest_rel_dist)

    // save the new closest sprite
    nv_store8_immediate(closest_sprite, 0)
    

CheckSprite1:
    // carry is set here
    ror collision_bit        // rotate bit for sprite 1 bit to carry
    bcs WasSprite1
    jmp CheckSprite2
WasSprite1:
    ldx #sprite_num
    ldy #1
    jsr NvSpriteRawGetRelDistReg      // load temp_rel_dist with rel distance
    nv_debug_print_labeled_word_mem_coll(13, 0, spt_1_dist_label, 14, 
                                    temp_rel_dist, true, false)    

    nv_bge16(temp_rel_dist, closest_rel_dist, CheckSprite2)

    // save the new closest rel distance
    nv_xfer16_mem_mem(temp_rel_dist, closest_rel_dist)

    // save the new closest sprite
    nv_store8_immediate(closest_sprite, 1)

CheckSprite2:
    ror collision_bit        // rotate bit for sprite 2 bit to carry
    bcs WasSprite2
    jmp CheckSprite3

WasSprite2:
    ldx #sprite_num
    ldy #2
    jsr NvSpriteRawGetRelDistReg      // load temp_rel_dist with rel distance
    nv_debug_print_labeled_word_mem_coll(14, 0, spt_2_dist_label, 14, 
                                    temp_rel_dist, true, false)    

    nv_bge16(temp_rel_dist, closest_rel_dist, CheckSprite3)

    // save the new closest rel distance
    nv_xfer16_mem_mem(temp_rel_dist, closest_rel_dist)

    // save the new closest sprite
    nv_store8_immediate(closest_sprite, 2)


CheckSprite3:
    ror collision_bit        // rotate bit for sprite 3 bit to carry
    bcs WasSprite3
    jmp CheckSprite4

WasSprite3:
    ldx #sprite_num
    ldy #3
    jsr NvSpriteRawGetRelDistReg      // load temp_rel_dist with rel distance
    nv_debug_print_labeled_word_mem_coll(15, 0, spt_3_dist_label, 14, 
                                    temp_rel_dist, true, false)    

    nv_bge16(temp_rel_dist, closest_rel_dist, CheckSprite4)

    // save the new closest rel distance
    nv_xfer16_mem_mem(temp_rel_dist, closest_rel_dist)

    // save the new closest sprite
    nv_store8_immediate(closest_sprite, 3)

CheckSprite4:
    ror collision_bit        // rotate bit for sprite 4 bit to carry
    bcs WasSprite4
    jmp CheckSprite5

WasSprite4:
    ldx #sprite_num
    ldy #4
    jsr NvSpriteRawGetRelDistReg      // load temp_rel_dist with rel distance
    nv_debug_print_labeled_word_mem_coll(16, 0, spt_4_dist_label, 14, 
                                    temp_rel_dist, true, false)    

    nv_bge16(temp_rel_dist, closest_rel_dist, CheckSprite5)
    
    // save the new closest rel distance
    nv_xfer16_mem_mem(temp_rel_dist, closest_rel_dist)

    // save the new closest sprite
    nv_store8_immediate(closest_sprite, 4)


CheckSprite5:
    ror collision_bit        // rotate bit for sprite 5 bit to carry
    bcs WasSprite5
    jmp CheckSprite6

WasSprite5:
    ldx #sprite_num
    ldy #5
    jsr NvSpriteRawGetRelDistReg      // load temp_rel_dist with rel distance
    nv_debug_print_labeled_word_mem_coll(17, 21, nv_g16_label, 8, nv_g16, true, false)
    nv_debug_print_labeled_word_mem_coll(17, 0, spt_5_dist_label, 14, 
                                    temp_rel_dist, true, false)    

    nv_bge16(temp_rel_dist, closest_rel_dist, CheckSprite6)

     // save the new closest rel distance
    nv_xfer16_mem_mem(temp_rel_dist, closest_rel_dist)

    // save the new closest sprite
    nv_store8_immediate(closest_sprite, 5)


CheckSprite6:
    ror collision_bit        // rotate bit for sprite 6 bit to carry
    bcs WasSprite6
    jmp CheckSprite7

WasSprite6:
    ldx #sprite_num
    ldy #6
    jsr NvSpriteRawGetRelDistReg      // load temp_rel_dist with rel distance
    nv_debug_print_labeled_word_mem_coll(18, 0, spt_6_dist_label, 14, 
                                    temp_rel_dist, true, false)    

    nv_bge16(temp_rel_dist, closest_rel_dist, CheckSprite7)
    
    // save the new closest rel distance
    nv_xfer16_mem_mem(temp_rel_dist, closest_rel_dist)

    // save the new closest sprite
    nv_store8_immediate(closest_sprite, 6)


CheckSprite7:
    ror collision_bit        // rotate bit for sprite 7 bit to carry
    bcs WasSprite7
    jmp DoneChecking

WasSprite7:
    ldx #sprite_num
    ldy #7
    jsr NvSpriteRawGetRelDistReg      // load temp_rel_dist with rel distance
    nv_debug_print_labeled_word_mem_coll(19, 0, spt_7_dist_label, 14, 
                                    temp_rel_dist, true, false)    
    nv_bge16(temp_rel_dist, closest_rel_dist, DoneChecking)
    
    // save the new closest rel distance
    nv_xfer16_mem_mem(temp_rel_dist, closest_rel_dist)

    // save the new closest sprite
    nv_store8_immediate(closest_sprite, 7)

DoneChecking:

ClosestSpriteSet: 
    lda closest_sprite
    sta nv_b8
}

// 
.macro nv_debug_print_labeled_byte_mem_coll(row, col, label_addr, 
                                            label_len, value_addr, 
                                            include_dollar, wait)
{
    #if DEBUG_COLLISIONS
        nv_debug_print_labeled_byte_mem(row, col, label_addr, 
                                        label_len, value_addr, 
                                        include_dollar, wait)
    #endif
}

.macro nv_debug_print_labeled_word_mem_coll(row, col, label_addr, 
                                            label_len, value_addr, 
                                            include_dollar, wait)
{
    #if DEBUG_COLLISIONS
        nv_debug_print_labeled_word_mem(row, col, label_addr, label_len, 
                                        value_addr, include_dollar, wait)
    #endif
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

/*
DebugRelDist:
    // closest
    nv_debug_print_labeled_word_mem_coll(6, 0, closest_label_str, 12, nv_a16, true, false)
    // temp
    nv_debug_print_labeled_word_mem_coll(7, 0, temp_label_str, 12, nv_g16, true, false)

    //nv_screen_wait_anykey()
    rts
closest_label_str: .text  @"closest\$00"
temp_label_str:  .text  @"temp\$00"
*/