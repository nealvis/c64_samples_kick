// nv_c64_util
// sprite releated stuff

#importonce

#import "nv_util_data.asm"
#import "nv_color.asm"
#import "nv_math16.asm"
#import "nv_math8.asm"
#import "nv_branch16.asm"
#import "nv_sprite_extra.asm"
#import "nv_debug.asm"       // for debugging

.const NV_SPRITE_ENABLE_REG_ADDR = $d015 // each bit turns on one of the sprites lsb is sprite 0, msb is sprite 7
.const NV_SPRITE_COLOR_1_ADDR = $D025 // address of color for sprite bits that are binary 01
.const NV_SPRITE_COLOR_2_ADDR = $D026 // address of color for sprite bits that are binary 11

.const NV_SPRITE_0_DATA_PTR_ADDR = $07F8  // address of the pointer to sprite_0's data its only 8 bits 
                                        // so its implied that this value will be multipled by 64 
.const NV_SPRITE_0_X_ADDR = $D000
.const NV_SPRITE_0_Y_ADDR = $D001

.const NV_SPRITE_1_DATA_PTR_ADDR = $07F9  // address of the pointer to sprite_0's data its only 8 bits 
                                        // so its implied that this value will be multipled by 64 
.const NV_SPRITE_1_X_ADDR = $D002
.const NV_SPRITE_1_Y_ADDR = $D003

// register with one bit for each sprite to indicate high res (one color)
// or multi color.  Bit 0 (lsb) corresponds to sprite 0
// set bit to 1 for multi color, or 0 for high res (one color mode)
.const NV_SPRITE_MODE_REG_ADDR = $D01C 

// since there are more than 255 x locations across the screen
// the high bit for each sprite's X location is gathered in the 
// byte here.  sprite_0's ninth bit is bit 0 of the byte at this addr.
.const NV_SPRITE_ALL_X_HIGH_BIT_ADDR = $D010

// the low 4 bits (0-3) contain the color for sprite 0
// the hi 4 bits don't seem to be writable
.const NV_SPRITE_0_COLOR_REG_ADDR = $d027

// the low 4 bits (0-3) contain the color for sprite 1
// the hi 4 bits don't seem to be writable
.const NV_SPRITE_1_COLOR_REG_ADDR = $d028

// contains a bit for each sprite indicating if it
// has been in a collisin with another sprite
.const NV_SPRITE_COLLISION_SPRITE_REG_ADDR = $d01e

// contains a bit for each sprite indicating if it
// has been in a collisin with a text or bitmap graphics
.const NV_SPRITE_COLLISION_DATA_REG_ADDR = $d01f


//////////////////////////////////////////////////////////////////////////////
// inline macro to read the sprite/sprite collision register
.macro nv_sprite_raw_get_sprite_collisions_in_a()
{
    lda NV_SPRITE_COLLISION_SPRITE_REG_ADDR
} 

//////////////////////////////////////////////////////////////////////////////
// inline macro to read the sprite/data collision register
.macro nv_sprite_raw_get_data_collisions_in_a()
{
    lda NV_SPRITE_COLLISION_DATA_REG_ADDR
} 

//////////////////////////////////////////////////////////////////////////////
// inline macro to set the shared colors for multi colored sprites
.macro nv_sprite_raw_set_multicolors(color1, color2) 
{
    lda #color1 // multicolor sprites global color 1
    sta NV_SPRITE_COLOR_1_ADDR   // can also get this from spritemate
    lda #color2      // multicolor sprites global color 2
    sta NV_SPRITE_COLOR_2_ADDR
}


//////////////////////////////////////////////////////////////////////////////
// Inline macro to set the sprite mode for specified sprite.
// macro params:
//  sprite_num: the sprite number, 0-7 are valid values
//  sprite_data_addr: the address of the 64 bytes of sprite
//                    data.  The last byte contains the mode
//                    in its high nibble.  if any of the four
//                    bits in the high nibble are set then 
//                    the sprite is multi color (low res).  If
//                    no bits in the high nibble are set then
//                    its hi res (single color)
.macro nv_sprite_raw_set_mode(sprite_num, sprite_data_addr)
{
    .var sprite_mask = $01 << sprite_num
    .var not_sprite_mask = ~sprite_mask

    lda NV_SPRITE_MODE_REG_ADDR   // load sprite mode reg
    and #not_sprite_mask          // clear bit 0 for sprite 0
    sta NV_SPRITE_MODE_REG_ADDR   // store it back to sprite mode reg

    lda #$F0                      // load mask in A, checking for any ones in high nibble
    bit sprite_data_addr + 63     // set Zero flag if the masked bits are all 0s
                                  // if any masked bits in the last byte of sprite_0 are set 
                                  // then its a multi colored sprite
    beq skip_multicolor           // if its zero then, ie no masked bits were set, then branch
                                  // to skip multi color mode.

    // If we didn't skip the multi color, then set sprite 0 to muli color mode
    lda NV_SPRITE_MODE_REG_ADDR   // load current contents of sprite mode reg
    ora #sprite_mask             // set bit for sprite 0 (bit 0) to 1 for multi color
    sta NV_SPRITE_MODE_REG_ADDR   // leave other bits untouched for sprites 1-7 
skip_multicolor:
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to set the pixel data pointer for the sprite.  
// macro parameters:
//   sprite_num: is the sprite number, 0-7 are valid values
//   sprite_data_addr: is the address where the 64 bytes of data for the
//                     sprite are stored.  This is the real address it will
//                     be divided by 64 prior to setting in the sprite register.
.macro nv_sprite_raw_set_data_ptr(sprite_num, sprite_data_addr)
{
    lda #(sprite_data_addr / 64)            // implied this is multiplied by 64
    ldx #sprite_num
    sta NV_SPRITE_0_DATA_PTR_ADDR,x         // store in ptr for this sprite
} 


//////////////////////////////////////////////////////////////////////////////
// inline Macro to set the sprite's one color
//   sprite_num: is the sprite number (0-7 are valid values)
//   sprite_data_addr: is the address where the 64 bytes of data for the
//                     sprite are stored.  The last byte contains the sprite 
//                     color in the low nibble.
.macro nv_sprite_raw_set_color_from_data(sprite_num, sprite_data_addr)
{
    lda sprite_data_addr + 63       // The color is the low nibble of the
                                    // last byte of sprite. We'll just 
                                    // write the whole byte because the
                                    // only lo 4 bits of reg are writable
    ldx #sprite_num
    sta NV_SPRITE_0_COLOR_REG_ADDR,x   // store in color reg for this sprite  
}


//////////////////////////////////////////////////////////////////////////////
// set sprite's color to the color to the immediate value specified
// macro params:
//   sprite_num: the c64 sprite number (0-7 are valid)
//   new_color:  a number 0-7 specifying which c64 color to set
.macro nv_sprite_set_raw_color_immediate(sprite_num, new_color)
{
    lda #new_color                  // The color is the low nibble of the
                                    // byte.  We'll just write the whole 
                                    // byte because only low 4 bits of 
                                    // the register are writable
    ldx #sprite_num
    sta NV_SPRITE_0_COLOR_REG_ADDR,x   // store in color reg for this sprite  
}


//////////////////////////////////////////////////////////////////////////////
// set sprite's color to the c64 color value stored at an address
// macro params:
//   sprite_num:     the c64 sprite number (0-7 are valid)
//   new_color_addr: The 16bit address of a location that contains a 
//                   number 0-7 specifying which c64 color to set
.macro nv_sprite_raw_set_color_from_memory(sprite_num, new_color_addr)
{
    lda new_color_addr              // The color is the low nibble of the
                                    // byte.  We'll just write the whole 
                                    // byte because only low 4 bits of 
                                    // the register are writable
    ldx #sprite_num
    sta NV_SPRITE_0_COLOR_REG_ADDR,x   // store in color reg for this sprite  
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to enable the specified sprite.  If a sprite is not enabled 
// it won't be visible on the screen.  
// macro parameters:
//   sprite_num is the sprite number to enable (value must be 0-7)
.macro nv_sprite_raw_enable(sprite_num)
{
    .var sprite_mask = $01 << sprite_num

    lda NV_SPRITE_ENABLE_REG_ADDR      // load A with sprite enabled reg
    ora #sprite_mask                   // set the bit for sprite 0, 
                                       // Leaving other bits untouched
    sta NV_SPRITE_ENABLE_REG_ADDR      // store to sprite enable register 
                                       // one bit for each sprite.
}


//////////////////////////////////////////////////////////////////////////////
// subroutine macro to enable the specified sprite.  if the sprite is not 
// enabled it won't be visible on the screen
// macro parameters:
//   sprite_num is the sprite number to enable (value must be 0-7)
.macro nv_sprite_raw_enable_sr(sprite_num)
{
    nv_sprite_raw_enable(sprite_num)
    rts
}


//////////////////////////////////////////////////////////////////////////////
//
.macro nv_sprite_raw_enable_from_mem(spt_num_addr)
{
    nv_mask_from_bit_num_mem(spt_num_addr, false)
    // mask is now in Accum
    ora NV_SPRITE_ENABLE_REG_ADDR
    sta NV_SPRITE_ENABLE_REG_ADDR
}


//////////////////////////////////////////////////////////////////////////////
// Disable the sprite specified (0-7) in the sprite hw register
// Macro parameters:
//   spt_num_addr: is the address of the byte that contains the 
//                 sprite number (0-7) that will be disabled
.macro nv_sprite_raw_disable_from_mem(spt_num_addr)
{
    nv_mask_from_bit_num_mem(spt_num_addr, true)
    // negated mask now in accum
    and NV_SPRITE_ENABLE_REG_ADDR
    sta NV_SPRITE_ENABLE_REG_ADDR
}


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
// Inline macro (no rts) to setup everything for a sprite so its ready to 
// be enabled and moved.
.macro nv_sprite_raw_setup(sprite_num, sprite_data_addr)
{
    nv_sprite_raw_set_mode(sprite_num, sprite_data_addr)
    nv_sprite_raw_set_data_ptr(sprite_num, sprite_data_addr)
    nv_sprite_raw_set_color_from_data(sprite_num, sprite_data_addr)
}


//////////////////////////////////////////////////////////////////////////////
// inline macro for subroutine (with rts) to setup everything for a sprite such 
// that its ready to be enabled and moved
.macro nv_sprite_raw_setup_sr(sprite_num, sprite_data_addr)
{
    nv_sprite_raw_setup(sprite_num, sprite_data_addr)
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
// Inline macro to set the x and y location of specified sprite
// based on macro parameters known at assemble time
// This routine directly updates the sprite registers for the sprite and is
// not connected to any sprite struct
// macro params:
//   sprite_num: the sprite number (0-7 are valid)
//   sprite_x: the sprite x location (this can be larger than 255)
//   sprite_y: the sprite y location this is only 0-255
.macro nv_sprite_raw_set_loc(sprite_num, sprite_x, sprite_y)
{
    ldx #sprite_num * 2         // sprite number times 2 since location
                                // regs are in pairs, x loc and y loc
                                // for each sprite.

    lda #sprite_x               // load LSB for x location 
    sta NV_SPRITE_0_X_ADDR,x    // store in right sprite's x loc

    lda #sprite_y
    sta NV_SPRITE_0_Y_ADDR,x    // store in right sprites y loc

    .var sprite_mask = $01 << sprite_num
    .if (sprite_x > 255)
    {
        lda NV_SPRITE_ALL_X_HIGH_BIT_ADDR
        ora #sprite_mask
        sta NV_SPRITE_ALL_X_HIGH_BIT_ADDR
    }
    .if (sprite_x <= 255)
    {
        .var not_sprite_mask = ~sprite_mask
        lda NV_SPRITE_ALL_X_HIGH_BIT_ADDR
        and #not_sprite_mask
        sta NV_SPRITE_ALL_X_HIGH_BIT_ADDR 
    }
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to get the specified sprite's x and y position.
// macro parameters:
//   sprite_num: must be set to the number of the sprite 0-7
//   sprite_x_addr: is the address of the LSB of a 16 bit word to get x pos
//   sprite_y_addr: is the address of the byte to get the y position
.macro nv_sprite_raw_get_location(sprite_num, sprite_x_addr, sprite_y_addr)
{
    ldx #(sprite_num*2) // load x with offset to sprite location for this sprite
             
    lda NV_SPRITE_0_X_ADDR,x    // load in right sprite's x loc low 8 bits
    sta sprite_x_addr           // store in the memory addr

    lda NV_SPRITE_0_Y_ADDR,x    // load in right sprites y loc
    sta sprite_y_addr

    .var sprite_mask = $01 << sprite_num

    lda #0
    sta sprite_x_addr+1

    lda #sprite_mask
    bit NV_SPRITE_ALL_X_HIGH_BIT_ADDR
    beq StayClear
    inc sprite_x_addr+1
StayClear:
}

.macro nv_sprite_raw_get_location_sr(sprite_num, sprite_x_addr, sprite_y_addr)
{
    nv_sprite_raw_get_location(sprite_num, sprite_x_addr, sprite_y_addr)
    rts
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to get the location of a sprite and put it in memory
// subroutine parameters:
//   Y Reg: must contain the sprite number (0-7) of the sprite who's
//          location will be retrieved
// macro parameters:
//   sprite_x_addr: is the address of the LSB of a word into which the
//                  sprite's x position will be placed  
//   sprite_y_addr: is the address of the LSB of a word into which the
//                  sprite's y position will be placed  
.macro nv_sprite_raw_get_loc_reg(sprite_x_addr, sprite_y_addr)
{
    // multiply sprite num by 2 since two byte for each sprite (x and y)
    // load x with offset to sprite location for this sprite
    tya
    asl 
    tax  

    lda NV_SPRITE_0_X_ADDR,x    // load in right sprite's x loc low 8 bits
    sta sprite_x_addr           // store in the memory addr

    lda NV_SPRITE_0_Y_ADDR,x    // load in right sprites y loc
    sta sprite_y_addr

    lda #0                      // clear the high bit in mem
    sta sprite_x_addr+1         // if it needs to be set, do that below

    tya                                     // sprite number in Accum
    nv_mask_from_bit_num_a(false)           // bitmask for sprite num in Accum
    bit NV_SPRITE_ALL_X_HIGH_BIT_ADDR       // check sprite's high bit
    beq StayClear                           // if hi bit 0 then done
    inc sprite_x_addr+1                     // if hi bit 1 then set it in mem
StayClear:
}

//////////////////////////////////////////////////////////////////////////////
// subroutine macro to set sprite's location in the sprite registers based on
// the values in the sprite_x_addr and sprite_y_addr.
// macro parmaeters:
//   sprite_num: the sprite number (0-7 are valid sprite numbers)
//   sprite_x_addr:  the address of the LSB of the word that holds the 16 bit
//                   value which is the sprites x location
//   sprite_y_addr: the address of the byte that holds the sprite's 8 bit 
//                  y location
.macro nv_sprite_raw_set_location_from_memory_sr(sprite_num, sprite_x_addr, sprite_y_addr)
{
    ldx #(sprite_num*2) // load x with offset to sprite location for this sprite

    lda sprite_x_addr               
    sta NV_SPRITE_0_X_ADDR,x    // store in right sprite's x loc

    lda sprite_y_addr
    sta NV_SPRITE_0_Y_ADDR,x    // store in right sprites y loc

    .var sprite_mask = $01 << sprite_num

    lda sprite_x_addr+1
    bne SetBit                            // high byte was non zero, so set bit
    // clear bit
    .var not_sprite_mask = ~sprite_mask
    lda NV_SPRITE_ALL_X_HIGH_BIT_ADDR
    and #not_sprite_mask
    sta NV_SPRITE_ALL_X_HIGH_BIT_ADDR 
    rts
    
 SetBit:   
    lda NV_SPRITE_ALL_X_HIGH_BIT_ADDR
    ora #sprite_mask
    sta NV_SPRITE_ALL_X_HIGH_BIT_ADDR  
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
