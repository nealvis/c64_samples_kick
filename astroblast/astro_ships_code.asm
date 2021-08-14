//////////////////////////////////////////////////////////////////////////////
// astro_ships_code.asm

#importonce
#import "../nv_c64_util/nv_c64_util_macs_and_data.asm"

#import "astro_sprite_data.asm"
#import "../nv_c64_util/nv_sprite_extra_code.asm"
#import "astro_vars_data.asm"
#import "../nv_c64_util/nv_sprite_raw_collisions_code.asm"

// max and min speed for ships when inc/dec speed
.const SHIP_MAX_SPEED = 5
.const SHIP_MIN_SPEED = -5

//////////////////////////////////////////////////////////////////////////////
// namespace with everything related to ship sprite
.namespace ship_1
{
        .var info = nv_sprite_info_struct("ship_1", 0,
                                          22, 50, 3, 1,  // init x, y, VelX, VelY 
                                          sprite_ship, 
                                          sprite_extra, 
                                          1, 0, 1, 0,   // bounce on top, left, bottom, right  
                                          0, 0, 75, 0,  // min/max top, left, bottom, right
                                          0,            // sprite enabled 
                                          6, 4, 19, 16) // hitbox left, top, right, bottom

        .var sprite_num = info.num
        .label x_loc = info.base_addr + NV_SPRITE_X_OFFSET
        .label y_loc = info.base_addr + NV_SPRITE_Y_OFFSET
        .label x_vel = info.base_addr + NV_SPRITE_VEL_X_OFFSET
        .label y_vel = info.base_addr + NV_SPRITE_VEL_Y_OFFSET
        .label base_addr = info.base_addr

// the extra data that goes with the sprite
sprite_extra:
        nv_sprite_extra_data(info)

// will be $FF (no collision) or sprite number of sprite colliding with
collision_sprite: .byte 0 

// score for this ship in BCD
score: .word 0

LoadExtraPtrToRegs:
    lda #>info.base_addr
    ldx #<info.base_addr
    rts

// subroutine to set the sprites location based on its address in extra block 
SetLocationFromExtraData:
        lda #>info.base_addr
        ldx #<info.base_addr
        jsr NvSpriteSetLocationFromExtra
        rts

// subroutine to setup the sprite so that its ready to be enabled and displayed
Setup:
        lda #>info.base_addr
        ldx #<info.base_addr
        jsr NvSpriteSetupFromExtra
        rts

// subroutine to move the sprite in memory only (the extra data)
// this will not update the sprite registers to actually move the sprite, but
// to do that just call SetShipeLocFromMem
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

LoadEnabledToA:
        lda info.base_addr + NV_SPRITE_ENABLED_OFFSET
        rts

SetBounceAllOn:
        nv_sprite_set_all_actions_sr(info, NV_SPRITE_ACTION_BOUNCE)

SetWrapAllOn:
        nv_sprite_set_all_actions_sr(info, NV_SPRITE_ACTION_WRAP)

//////////////////////////////////////////////////////////////////////////////
// subroutine to check for collisions with the ship (sprite 0)
CheckShipCollision:
    lda sprite_collision_reg_value
    //nv_debug_print_labeled_byte_mem(0, 0, temp_label, 10, sprite_collision_reg_value, true, false)
    sta nv_a8
    nv_sprite_raw_check_collision(info.num)
    lda nv_b8
    sta ship_1.collision_sprite
    //jsr DebugShipCollisionSprite
    rts
temp_label: .text @"coll reg: \$00"

DecVelX:
{
    //nv_debug_print_labeled_byte_mem(10, 0, label_vel_x_str, 7, ship_1.x_vel, true, false)
    dec ship_1.x_vel        // decrement ship speed
    bpl DoneDecVelX         // if its not zero yet then skip setting to max
    inc ship_1.x_vel
DoneDecVelX:
    rts
}


IncVelX:
{
    //nv_debug_print_labeled_byte_mem(10, 0, label_vel_x_str, 7, ship_1.x_vel, true, false)
    lda ship_1.x_vel        // decrement ship speed
    cmp #SHIP_MAX_SPEED         // if its not zero yet then skip setting to max
    beq DoneIncVelX
    inc ship_1.x_vel
DoneIncVelX:
    rts
}
//////////////////////////////////////////////////////////////////////////////
// x and y reg have x and y screen loc for the char to check the sprite 
// location against.  it doesn't matter what character is at the location
// this just checks the location for overlap with sprite location
CheckOverlapChar:
    nv_sprite_check_overlap_char(info, rect2)
    rts

SetColorDead:
    nv_sprite_set_raw_color_immediate(sprite_num, NV_COLOR_GREY)
    rts

SetColorAlive:
    lda #>info.base_addr
    ldx #<info.base_addr
    nv_sprite_set_color_from_extra_sr()

    
label_vel_x_str: .text @"vel x: \$00"
rect1: .word $0000, $0000  // (left, top)
       .word $0000, $0000  // (right, bottom)

rect2: .word $0000, $0000  // (left, top)
       .word $0000, $0000  // (right, bottom)

}

//////////////////////////////////////////////////////////////////////////////
// namespace with everything related to ship sprite
.namespace ship_2
{
    .var info = nv_sprite_info_struct("ship_2", 7,  // sprite name, number
                                        22, 210, 3, 1,  // init x, y, VelX, VelY 
                                        sprite_ship, 
                                        sprite_extra, 
                                        1, 0, 1, 0,   // bounce on top, left, bottom, right  
                                        200, 0, 0, 0, // min/max top, left, bottom, right
                                        0,            // sprite enabled 
                                        6, 4, 19, 16) // hitbox left, top, right, bottom

    .var sprite_num = info.num
    .label x_loc = info.base_addr + NV_SPRITE_X_OFFSET
    .label y_loc = info.base_addr + NV_SPRITE_Y_OFFSET
    .label x_vel = info.base_addr + NV_SPRITE_VEL_X_OFFSET
    .label y_vel = info.base_addr + NV_SPRITE_VEL_Y_OFFSET
    .label base_addr = info.base_addr


// the extra data that goes with the sprite
sprite_extra:
        nv_sprite_extra_data(info)



// will be $FF (no collision) or sprite number of sprite colliding with
collision_sprite: .byte 0

// score for this ship in BCD
score: .word 0

LoadExtraPtrToRegs:
    lda #>info.base_addr
    ldx #<info.base_addr
    rts


// subroutine to set the sprites location based on its address in extra block 
SetLocationFromExtraData:
        lda #>info.base_addr
        ldx #<info.base_addr
        jsr NvSpriteSetLocationFromExtra
        rts

// subroutine to setup the sprite so that its ready to be enabled and displayed
Setup:
        lda #>info.base_addr
        ldx #<info.base_addr
        jsr NvSpriteSetupFromExtra
        rts

// subroutine to move the sprite in memory only (the extra data)
// this will not update the sprite registers to actually move the sprite, but
// to do that just call SetShipeLocFromMem
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

LoadEnabledToA:
        lda info.base_addr + NV_SPRITE_ENABLED_OFFSET
        rts

SetBounceAllOn:
        nv_sprite_set_all_actions_sr(info, NV_SPRITE_ACTION_BOUNCE)

SetWrapAllOn:
        nv_sprite_set_all_actions_sr(info, NV_SPRITE_ACTION_WRAP)

//////////////////////////////////////////////////////////////////////////////
// subroutine to check for collisions with the ship (sprite 0)
CheckShipCollision:
    lda sprite_collision_reg_value
    //nv_debug_print_labeled_byte_mem(0, 0, temp_label, 10, sprite_collision_reg_value, true, false)
    sta nv_a8
    nv_sprite_raw_check_collision(info.num)
    lda nv_b8
    sta ship_2.collision_sprite
    rts


DecVelX:
{
    //nv_debug_print_labeled_byte_mem(10, 0, label_vel_x_str, 7, ship_2.x_vel, true, false)
    dec ship_2.x_vel        // decrement ship speed
    bpl DoneShip2DecVelX         // if its not zero yet then skip setting to max
    inc ship_2.x_vel
DoneShip2DecVelX:
    rts
}

IncVelX:
{
    //nv_debug_print_labeled_byte_mem(10, 0, label_vel_x_str, 7, ship_2.x_vel, true, false)
    lda ship_2.x_vel        // decrement ship speed
    cmp #SHIP_MAX_SPEED         // if its not zero yet then skip setting to max
    beq DoneShip2IncVelX
    inc ship_2.x_vel
DoneShip2IncVelX:
    rts
}


SetColorDead:
    nv_sprite_set_raw_color_immediate(sprite_num, NV_COLOR_GREY)
    rts

SetColorAlive:
    //lda #>info.base_addr
    //ldx #<info.base_addr
    //nv_sprite_set_color_from_extra_sr()
    nv_sprite_set_raw_color_immediate(sprite_num, NV_COLOR_BROWN)
    rts



label_vel_x_str: .text @"vel x: \$00"

}