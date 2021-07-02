//////////////////////////////////////////////////////////////////////////////
// nv_sprite_raw_macs.asm contains macros for sprites at the HW level
// there is no dependency on the sprite_info struct or the sprite
// extra data block in this file.
// Also there is no actual code that will be placed in memory 
// by importing this file.  The only time code is generated is
// when one of the macros are expanded/instantiated in some other file.

//////////////////////////////////////////////////////////////////////////////
// Import other modules as needed here
#importonce
#import "nv_math8.asm"


// HW reg/address that 
// contains a bit for each sprite indicating if it
// has been in a collisin with another sprite
.const NV_SPRITE_COLLISION_SPRITE_REG_ADDR = $d01e

// HW reg/address that
// contains a bit for each sprite indicating if it
// has been in a collisin with a text or bitmap graphics
.const NV_SPRITE_COLLISION_DATA_REG_ADDR = $d01f

// HW reg/address of color for sprite bits that are binary 01
.const NV_SPRITE_COLOR_1_REG_ADDR = $D025 

// HW reg/address of color for sprite bits that are binary 11
.const NV_SPRITE_COLOR_2_REG_ADDR = $D026 

// register with one bit for each sprite to indicate high res (one color)
// or multi color.  Bit 0 (lsb) corresponds to sprite 0
// set bit to 1 for multi color, or 0 for high res (one color mode)
.const NV_SPRITE_MODE_REG_ADDR = $D01C 

// HW Reg/address of the pointer to sprite 0's shape data. Its only 8 bits
// so its implied that this value will be multipled by 64 to find the actual
// address in memory.
// Note the HW Reg/address of the pointer to sprite 1-7 shape data follow 
// NV_SPRITE_0_DATA_PTR_ADDR in the next 7 bytes.  each "pointer" is only 
// 8 bits so one byte per pointer.  For example sprite 1's shape data pointer
// is in NV_SPRITE_0_DATA_PTR_ADDR+1 which is $07F9.  These are usually
// accessed relative to the ptr for sprite 0 so no need for more consts
.const NV_SPRITE_0_DATA_PTR_REG_ADDR = $07F8  

// if we wanted consts for each sprite they would continue here as such
// .const NV_SPRITE_1_DATA_PTR_ADDR = $07F9  

                                         
// HW Reg/address the low 4 bits (0-3) contain the color for sprite 0
// the hi 4 bits don't seem to be writable
.const NV_SPRITE_0_COLOR_REG_ADDR = $d027

// each bit enables/disables one of the sprites.  the least significant bit
// is sprite 0, msb is sprite 7 etc.
.const NV_SPRITE_ENABLE_REG_ADDR = $d015 

// HW Reg/addresses for the the X and Y positions for sprite 0.  For the 
// X location this address only contains the lower 8 bits.  There is one 
// high bit for each sprite's x location that is gathered in 
// NV_SPRITE_ALL_X_HIGH_BIT_ADDR. The Y locations are only 8 bit values 
// so they are all in one byte.
// Note that sprite num 1-7 X and Y positions follow sprite 0 within 
// memory/HW regs so sprite 1 locations are here, and sprite 2 locations
// follow these, etc. We only really need sprite 0 location since sprite
// locations are usually accessed relative to sprite 0.
.const NV_SPRITE_0_X_REG_ADDR = $D000
.const NV_SPRITE_0_Y_REG_ADDR = $D001

// If we wanted consts for X and Y for sprites 1-7 they would continue
// here as such
//.const NV_SPRITE_1_X_ADDR = $D002
//.const NV_SPRITE_1_Y_ADDR = $D003

// since there are more than 255 x locations across the screen
// the high bit for each sprite's X location is gathered in the 
// byte here.  sprite_0's ninth bit is bit 0 of the byte at this addr.
.const NV_SPRITE_ALL_X_HIGH_BIT_REG_ADDR = $D010

// the low 4 bits (0-3) contain the color for sprite 1
// the hi 4 bits don't seem to be writable
.const NV_SPRITE_1_COLOR_REG_ADDR = $d028


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
// inline macro to enable a sprite specified by the sprite number found
// in a byte in memory.
// Macro params:
//   spt_num_addr: is the addres of a byte in memory that contains the
//                 number of the sprite to enable.  It must be 0-7 only.
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
    sta NV_SPRITE_COLOR_1_REG_ADDR   // can also get this from spritemate
    lda #color2      // multicolor sprites global color 2
    sta NV_SPRITE_COLOR_2_REG_ADDR
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
    sta NV_SPRITE_0_DATA_PTR_REG_ADDR,x         // store in ptr for this sprite
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
    sta NV_SPRITE_0_X_REG_ADDR,x    // store in right sprite's x loc

    lda #sprite_y
    sta NV_SPRITE_0_Y_REG_ADDR,x    // store in right sprites y loc

    .var sprite_mask = $01 << sprite_num
    .if (sprite_x > 255)
    {
        lda NV_SPRITE_ALL_X_HIGH_BIT_REG_ADDR
        ora #sprite_mask
        sta NV_SPRITE_ALL_X_HIGH_BIT_REG_ADDR
    }
    .if (sprite_x <= 255)
    {
        .var not_sprite_mask = ~sprite_mask
        lda NV_SPRITE_ALL_X_HIGH_BIT_REG_ADDR
        and #not_sprite_mask
        sta NV_SPRITE_ALL_X_HIGH_BIT_REG_ADDR 
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
             
    lda NV_SPRITE_0_X_REG_ADDR,x    // load in right sprite's x loc low 8 bits
    sta sprite_x_addr           // store in the memory addr

    lda NV_SPRITE_0_Y_REG_ADDR,x    // load in right sprites y loc
    sta sprite_y_addr

    .var sprite_mask = $01 << sprite_num

    lda #0
    sta sprite_x_addr+1

    lda #sprite_mask
    bit NV_SPRITE_ALL_X_HIGH_BIT_REG_ADDR
    beq StayClear
    inc sprite_x_addr+1
StayClear:
}


//////////////////////////////////////////////////////////////////////////////
// subroutine macro to get the location of specified sprite and 
// putting it in the memory locations specified
// macro parameters
//   sprite_num: must be set to the number of the sprite 0-7
//   sprite_x_addr: is the address of the LSB of a 16 bit word to get x pos
//   sprite_y_addr: is the address of the byte to get the y position
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

    lda NV_SPRITE_0_X_REG_ADDR,x    // load in right sprite's x loc low 8 bits
    sta sprite_x_addr           // store in the memory addr

    lda NV_SPRITE_0_Y_REG_ADDR,x    // load in right sprites y loc
    sta sprite_y_addr

    lda #0                      // clear the high bit in mem
    sta sprite_x_addr+1         // if it needs to be set, do that below

    tya                                     // sprite number in Accum
    nv_mask_from_bit_num_a(false)           // bitmask for sprite num in Accum
    bit NV_SPRITE_ALL_X_HIGH_BIT_REG_ADDR       // check sprite's high bit
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
    sta NV_SPRITE_0_X_REG_ADDR,x    // store in right sprite's x loc

    lda sprite_y_addr
    sta NV_SPRITE_0_Y_REG_ADDR,x    // store in right sprites y loc

    .var sprite_mask = $01 << sprite_num

    lda sprite_x_addr+1
    bne SetBit                            // high byte was non zero, so set bit
    // clear bit
    .var not_sprite_mask = ~sprite_mask
    lda NV_SPRITE_ALL_X_HIGH_BIT_REG_ADDR
    and #not_sprite_mask
    sta NV_SPRITE_ALL_X_HIGH_BIT_REG_ADDR 
    rts
    
 SetBit:   
    lda NV_SPRITE_ALL_X_HIGH_BIT_REG_ADDR
    ora #sprite_mask
    sta NV_SPRITE_ALL_X_HIGH_BIT_REG_ADDR  
    rts
}

