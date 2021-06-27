// nv_c64_util
// sprite releated stuff

#importonce

#import "nv_color.asm"
#import "nv_math16.asm"
#import "nv_branch16.asm"
#import "nv_sprite_extra.asm"

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
// iline macro to enable the specified sprite.  If a sprite is not enabled it won't
// be visible on the screen.  
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
// Inline macro (no rts) to setup everything for a sprite so its ready to 
// be enabled and moved.
.macro nv_sprite_setup(info)
{
    nv_sprite_raw_set_mode(info.num, info.data_ptr)
    nv_sprite_raw_set_data_ptr(info.num, info.data_ptr)
    nv_sprite_raw_set_color_from_data(info.num, info.data_ptr)
}

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
