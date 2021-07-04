#importonce

#if !NV_C64_UTIL_DATA
.error "Error - nv_sprite_raw_collisions_code.asm: NV_C64_UTIL_DATA not defined.  Import nv_c64_util_data.asm"
#endif

#import "nv_math16_macs.asm"
#import "nv_math8_macs.asm"
#import "nv_branch16_macs.asm"
#import "nv_sprite_raw_macs.asm"

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
// subroutine to get relative distance between two sprites.
// subroutine params:
//   X Reg: sprite number for one sprite
//   Y Reg: sprite number for other sprite
// Return: (in nv_g16) is a 16bit value that is the relative distance
//         between the two sprites
NvSpriteRawGetRelDistReg:
    nv_sprite_raw_get_rel_dist_reg(nv_g16)
    rts

