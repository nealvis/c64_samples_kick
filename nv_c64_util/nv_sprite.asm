// nv_c64_util
// sprite releated stuff

#importonce

#import "nv_color.asm"

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

// constants for left, top, right and bottom of screen.  sprites will go behind the borders so will cut them off
// off at these pixel locations.  These coordinates are where the upper left corner of the sprite is when its
// can be considered off screen.  Note these positions result in the sprites going mostly through the borders.
// so would not be good for bouncing
.const NV_SPRITE_LEFT_MIN = 2
.const NV_SPRITE_RIGHT_MAX = 83  // note this is value of low byte x loc, high bit must also be set
.const NV_SPRITE_TOP_MIN = 32
.const NV_SPRITE_BOTTOM_MAX = 249

// constants for screen edges for bouncing.  These are the values at which the sprite should bounce
.const NV_SPRITE_LEFT_BOUNCE = 23
.const NV_SPRITE_RIGHT_BOUNCE = 65
.const NV_SPRITE_TOP_BOUNCE = 50
.const NV_SPRITE_BOTTOM_BOUNCE = 234

// struct that provides info for a sprite.  this is a construct of the assembler
// it just provides an easy way to reference all these different compile time values.
// No actual memory is created when an instance of the struct is created.
.struct nv_sprite_info_struct{name, num, init_x, init_y, init_x_vel, init_y_vel, data_addr, 
                              base_addr, bounce_top, bounce_left, bounce_bottom, bounce_right}


//////////////////////////////////////////////////////////////////////////////
// macro that creates a block of memory to hold all the extra data for a 
// sprite such as its velocity and an in memory x and y location.
// macro parameter:
//   spt_info: is an instance of the nv_sprite_info_struct.  This contains
//             all the compile time info needed/known about the strite.
.macro nv_sprite_extra_data(spt_info)
{
    *=spt_info.base_addr                                 // tell assembler where to put this stuff
    sprite_base_addr:                                    // the address of the first byte
    sprite_num_addr: .byte spt_info.num                  // the sprite number (0-7 only)
    sprite_x_addr: .word spt_info.init_x                 // the sprite's x loc
    sprite_y_addr: .byte spt_info.init_y                 // the sprite's y loc
    sprite_vel_x_addr: .byte spt_info.init_x_vel         // the sprite's x velocity in pixels
    sprite_vel_y_addr: .byte spt_info.init_y_vel         // the sprite's y velocity in pixels
    sprite_data_block_addr_ptr: .byte spt_info.data_addr // mult by 64 to get the real 16bit addr
    sprite_bounce_top: .byte spt_info.bounce_top   // set to 1 to bounce bottom or 0 not to
    sprite_bounce_left: .byte spt_info.bounce_left   // set to 1 to bounce bottom or 0 not to
    sprite_bounce_bottom: .byte spt_info.bounce_bottom   // set to 1 to bounce bottom or 0 not to
    sprite_bounce_right: .byte spt_info.bounce_right   // set to 1 to bounce bottom or 0 not to
}

//////////////////////////////////////////////////////////////////////////////
// offsets to use to get to the different fields within the nv_sprite block
.const NV_SPRITE_NUM_OFFSET = 0
.const NV_SPRITE_X_OFFSET = 1
.const NV_SPRITE_Y_OFFSET = 3
.const NV_SPRITE_VEL_X_OFFSET = 4
.const NV_SPRITE_VEL_Y_OFFSET = 5
.const NV_SPRITE_DATA_BLOCK_OFFSET = 6
.const NV_SPRITE_BOUNCE_TOP_OFFSET = 7
.const NV_SPRITE_BOUNCE_LEFT_OFFSET = 8
.const NV_SPRITE_BOUNCE_BOTTOM_OFFSET = 9
.const NV_SPRITE_BOUNCE_RIGHT_OFFSET = 10


//////////////////////////////////////////////////////////////////////////////
// inline macro to set the shared colors for multi colored sprites
.macro nv_sprite_set_multicolors(color1, color2) 
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
.macro nv_sprite_set_mode(sprite_num, sprite_data_addr)
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
    beq skip_multicolor           // if Zero is set, ie no masked bits were set, then branch
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
.macro nv_sprite_set_data_ptr(sprite_num, sprite_data_addr)
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
.macro nv_sprite_set_color_from_data(sprite_num, sprite_data_addr)
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
.macro nv_sprite_set_color_immediate(sprite_num, new_color)
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
.macro nv_sprite_set_color_from_memory(sprite_num, new_color_addr)
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
.macro nv_sprite_enable(sprite_num)
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
.macro nv_sprite_setup(sprite_num, sprite_data_addr)
{
    nv_sprite_set_mode(sprite_num, sprite_data_addr)
    nv_sprite_set_data_ptr(sprite_num, sprite_data_addr)
    nv_sprite_set_color_from_data(sprite_num, sprite_data_addr)
}


//////////////////////////////////////////////////////////////////////////////
// inline macro for subroutine (with rts) to setup everything for a sprite such 
// that its ready to be enabled and moved
.macro nv_sprite_setup_sr(sprite_num, sprite_data_addr)
{
    nv_sprite_setup(sprite_num, sprite_data_addr)
    rts
}

//////////////////////////////////////////////////////////////////////////////
// inline macro (no rts) to wait for specific scanline.
.macro nv_sprite_wait_scan()
{
loop:
    lda $D012
    cmp #$fa
    bne loop
}


////////////////////////////////////////////////////////////////////////////
// subroutine to wait for a specific scan line
.macro nv_sprite_wait_scan_sr()
{
    nv_sprite_wait_scan()
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
.macro nv_sprite_set_loc(sprite_num, sprite_x, sprite_y)
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
.macro nv_sprite_set_location_from_memory_sr(sprite_num, sprite_x_addr, sprite_y_addr)
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
// subroutine to move a sprite based on information in the sprite tracker 
// struct (info) that is passed into the macro.  The sprite x and y location
// in memory will be updated according to the x and y velocity.
// Note if the sprite goes off the edge it will be reset to the opposite side
// of the screen.
// Note that this only updates the location in memory, it doesn't update the
// sprite location in sprite registers.  To update sprite location in registers
// and on the screen, call nv_sprite_set_location_from_memory_sr after this.
.macro nv_sprite_move_any_direction_sr(info)
{
    ldx info.base_addr + NV_SPRITE_VEL_Y_OFFSET
    bpl PosVelY

NegVelY:
    nv_sprite_move_negative_y(info)
    jmp DoneY

PosVelY:
    nv_sprite_move_positive_y(info)
    
DoneY:
// Y location done, now on to X
    ldx info.base_addr + NV_SPRITE_VEL_X_OFFSET
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
    
    lda info.base_addr + NV_SPRITE_VEL_Y_OFFSET         // velocity in accum

    ldx info.base_addr + NV_SPRITE_BOUNCE_BOTTOM_OFFSET
    beq NoCheckBounce
    
// Do check bounce bottom flag set, must check for bounce
    clc
    adc info.base_addr + NV_SPRITE_Y_OFFSET          // add vel to location

    cmp #NV_SPRITE_BOTTOM_BOUNCE                     // check if past bounce loc
    bcc AccumHasNewY
    // reverse the y velocity here to do that we do bitwise not + 1 (twos comp)
    lda #$FF
    eor info.base_addr+NV_SPRITE_VEL_Y_OFFSET
    tax
    inx
    stx info.base_addr+NV_SPRITE_VEL_Y_OFFSET
    jmp DoneY                                       // don't actually update y
                                                    // when bouncing
    
// bounce bottom flag not set, Don't need to check for bounce
 NoCheckBounce:
    clc
    adc info.base_addr + NV_SPRITE_Y_OFFSET        // add velocity to location
    cmp #NV_SPRITE_BOTTOM_MAX                      // compare with the bottom of screen
    bcc AccumHasNewY                               // if not off bottome then just update

// wrap to top of screen
    lda #NV_SPRITE_TOP_MIN                         // off the bottom, so wrap to top of screen 

AccumHasNewY:
    sta info.base_addr + NV_SPRITE_Y_OFFSET
DoneY:
}


//////////////////////////////////////////////////////////////////////////////
//
.macro nv_sprite_move_negative_y(info)
{
    lda info.base_addr + NV_SPRITE_VEL_Y_OFFSET       // load y vel to accum

    ldx info.base_addr + NV_SPRITE_BOUNCE_TOP_OFFSET
    beq NoCheckBounce

// check bounce top
    clc
    adc info.base_addr + NV_SPRITE_Y_OFFSET
    cmp #NV_SPRITE_TOP_BOUNCE
    bcs AccumHasNewY
    // reverse the y velocity here to do that we do bitwise not + 1
    lda #$FF
    eor info.base_addr+NV_SPRITE_VEL_Y_OFFSET
    tax
    inx
    stx info.base_addr+NV_SPRITE_VEL_Y_OFFSET
    jmp DoneY                                        // don't update Y loc

NoCheckBounce:
    clc
    adc info.base_addr + NV_SPRITE_Y_OFFSET
    cmp #NV_SPRITE_TOP_MIN
    bcs AccumHasNewY              // branch if accum > min top

    // sprite is less than min top so need to move it to bottom
    lda #NV_SPRITE_BOTTOM_MAX     // went off top so set to bottom

AccumHasNewY:
    sta info.base_addr + NV_SPRITE_Y_OFFSET
DoneY:
}


//////////////////////////////////////////////////////////////////////////////
//
.macro nv_sprite_move_positive_x(info)
{
    ldy info.base_addr + NV_SPRITE_X_OFFSET + 1 
    lda info.base_addr + NV_SPRITE_VEL_X_OFFSET
    clc
    adc info.base_addr + NV_SPRITE_X_OFFSET
    bcc NoIncByte2                     // accum (old x loc) > new x loc so inc high byte 
    ldy #1
NoIncByte2:
    // now Y reg has potential new high byte
    // and accum has potential new low byte

    cpy #0
    beq ReadyWithNewX  // if high byte is zero then we won't check for bounc or pass through

    // now we know the new x location has high bit set.
    .if (info.bounce_right != 0)
    {   // bouncing
        cmp #NV_SPRITE_RIGHT_BOUNCE
        bcc ReadyWithNewX               // have not reached the bounc epoint yet
        // bounce of right side
        lda #$FF
        eor info.base_addr+NV_SPRITE_VEL_X_OFFSET
        tax
        inx
        stx info.base_addr+NV_SPRITE_VEL_X_OFFSET
        jmp FinishedUpdate              // don't move X when we bounce
    }
    else
    {  // not bouncing so check for pass through
        cmp #NV_SPRITE_RIGHT_MAX
        bcc ReadyWithNewX
        // pass through
        ldy #0
        lda #NV_SPRITE_LEFT_MIN
        // ReadyWithNewX now, but don't need to jmp because its right there
    }

ReadyWithNewX:                      // Y reg has high byte and Accum has low byte
    sty info.base_addr + NV_SPRITE_X_OFFSET + 1
    sta info.base_addr + NV_SPRITE_X_OFFSET

FinishedUpdate:
}


//////////////////////////////////////////////////////////////////////////////
//
.macro nv_sprite_move_negative_x(info)
{
    lda info.base_addr + NV_SPRITE_X_OFFSET+1
    bne HiByteNotZero

HiByteZero:
    lda info.base_addr + NV_SPRITE_VEL_X_OFFSET
    clc
    adc info.base_addr + NV_SPRITE_X_OFFSET
    .if (info.bounce_left != 0)
    {
        cmp #NV_SPRITE_LEFT_BOUNCE
        bcs AccumHasNewX

        // need to bounce it
        lda info.base_addr + NV_SPRITE_VEL_X_OFFSET
        eor #$FF
        tax
        inx
        stx info.base_addr + NV_SPRITE_VEL_X_OFFSET
        jmp DoneX
    }
    else
    {
        cmp #NV_SPRITE_LEFT_MIN
        bcs AccumHasNewX    /// still on screen good to go
        
        // need to pass through to right side
        ldy #1
        sty info.base_addr + NV_SPRITE_X_OFFSET+1
        lda #NV_SPRITE_RIGHT_MAX
        jmp AccumHasNewX
    }
HiByteNotZero:
    lda info.base_addr + NV_SPRITE_VEL_X_OFFSET
    clc
    adc info.base_addr + NV_SPRITE_X_OFFSET
    bpl AccumHasNewX    // Hi byte stays  non zero

    // need to set high byte to zero
    ldy #0
    sty info.base_addr + NV_SPRITE_X_OFFSET+1

AccumHasNewX:               // high byte of X set correctly above, set low byte
    sta info.base_addr + NV_SPRITE_X_OFFSET
DoneX:
}