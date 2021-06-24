//////////////////////////////////////////////////////////////////////////////
// this file contains subroutines that operate on sprites.  Usually the 
// address of the extra data for a sprite is required to perform some
// operation.  

#importonce

#import "nv_sprite.asm"
#import "nv_util_data.asm"
#import "nv_math16.asm"

// zero page pointer to use whenever a zero page pointer is needed
// usually used to store and load to and from the sprite extra pointer
.const ZERO_PAGE_LO = $FB
.const ZERO_PAGE_HI = $FC

.macro nv_sprite_load_extra_ptr()
{
    // load the address of the caller's param block to a pointer in 
    // zero page (first 256 bytes of memory.)  we need a zero page 
    // location to store the address of the caller's nv_sprite_extra_data
    // so that we can later use indirect index addressing into the 
    // extra data for the individual fields (sprit num, x loc, y loc, etc)
    stx ZERO_PAGE_LO   // store lo byte of addr of caller's param block
    sta ZERO_PAGE_HI   // store hi byte of addr of caller's param block 
}

//////////////////////////////////////////////////////////////////////////////
// move the sprite's data pointer to the zero page for some indirection
// assume that when this macro is used that the address of the sprite's 
// extra data is in ZERO_PAGE_LO and ZERO_PAGE_HI already.
// after this macro is executed the ZERO_PAGE_LO and ZERO_PAGE_HI 
// will contain the address of the sprite's data (the 64 bytes that
// define the sprite's shape and color)
.macro nv_sprite_data_ptr_to_zero_page()
{
    // use indirect addressing to get the sprite number
    ldy #NV_SPRITE_NUM_OFFSET       // load Y reg with offset to sprite number
    lda (ZERO_PAGE_LO),y            // indirect indexed load sprite num to accum
    tax                             // keep sprite number in X reg
    
    ldy #NV_SPRITE_DATA_PTR_OFFSET
    lda (ZERO_PAGE_LO), y           // get low byte of data ptr in accum
    sta scratch_word                // store in LSB of scratch_word

    iny                             // inc y for high byte of data ptr
    lda (ZERO_PAGE_LO), y           // get MSB of data ptr in accum
    sta scratch_word+1              // store in MSB of scratch_word
    
    //scratch_word now has the data ptr in it

    // store sprite data pointer in scratch word
    lda scratch_word
    sta ZERO_PAGE_LO

    lda scratch_word+1
    sta ZERO_PAGE_HI

}

//////////////////////////////////////////////////////////////////////////////
// inline macro to get a byte from the sprite extra data bloc assuming
// that the pointer to the extra data block is already in ZERO_PAGE_LO
// and ZERO_PAGE_HI.  byte from the extra data will be put in Accumulator
// macro parameters:
//  offset: is the byte offset within the extra data block for the byte
//          to get. 
// Y will be changed,
// X not changed
// A will contain the bye from the extra data 
.macro nv_sprite_extra_byte_to_a(offset)
{
    // use indirect addressing to get the sprite number
    ldy #offset       // load Y reg with offset to sprite number
    lda (ZERO_PAGE_LO),y            // indirect indexed load sprite num to accum
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to get a byte from the sprite extra data bloc assuming
// that the pointer to the extra data block is already in ZERO_PAGE_LO
// and ZERO_PAGE_HI.  Byte from the extra data will be put in X register
// macro parameters:
//  offset: is the byte offset within the extra data block for the byte
//          to get.  
.macro nv_sprite_extra_byte_to_x(offset)
{
    nv_sprite_extra_byte_to_a(offset)
    tax
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to get a byte from the sprite extra data bloc assuming
// that the pointer to the extra data block is already in ZERO_PAGE_LO
// and ZERO_PAGE_HI.  Byte from the extra data will be put in Y register
// macro parameters:
//  offset: is the byte offset within the extra data block for the byte
//          to get.  
.macro nv_sprite_extra_byte_to_y(offset)
{
    nv_sprite_extra_byte_to_a(offset)
    tay
}


//////////////////////////////////////////////////////////////////////////////
// Sets a sprites color from the last byte in the sprite data
// the sprite data is found by getting the address of the first byte
// of it from the sprite's extra data.
// To call subroutine setup the following then JSR
// Accum: MSB of address of nv_sprite_extra_data
// X Reg: LSB of address of the nv_sprite_extra_data
.macro nv_sprite_set_color_from_extra_sr()
{
    nv_sprite_standard_save(SaveBlock)

    // load ZERO_PAGE_LO and ZERO_PAGE_HI with addr of sprite extra data
    nv_sprite_load_extra_ptr()

    // use indirect addressing to get the sprite number
    ldy #NV_SPRITE_NUM_OFFSET       // load Y reg with offset to sprite number
    lda (ZERO_PAGE_LO),y            // indirect indexed load sprite num to accum
    tax                             // keep sprite number in X reg
    
    ldy #NV_SPRITE_DATA_PTR_OFFSET
    lda (ZERO_PAGE_LO), y           // get low byte of data ptr in accum
    sta scratch_word                // store in LSB of scratch_word

    iny                             // inc y for high byte of data ptr
    lda (ZERO_PAGE_LO), y           // get MSB of data ptr in accum
    sta scratch_word+1              // store in MSB of scratch_word
    
    //scratch_word now has the data ptr in it

    // store sprite data pointer in scratch word
    lda scratch_word
    sta ZERO_PAGE_LO

    lda scratch_word+1
    sta ZERO_PAGE_HI

    // our zero page pointer now points to the sprite data
    // the 63rd byte of which contains the color data
    ldy #63
    lda (ZERO_PAGE_LO), y

    // now accum has the color data in the low nibble
    // and X has the sprite number
    // write the color data to the color data register for this
    // sprite number.  write the whole byte because only the 
    // low nibble is writable
    sta NV_SPRITE_0_COLOR_REG_ADDR,x   // store in color reg for this sprite  

    nv_sprite_standard_restore(SaveBlock)
    rts

SaveBlock:
    nv_sprite_standard_alloc()
}


//////////////////////////////////////////////////////////////////////////////
// To call this subroutine setup the following then JSR
// Accum: MSB of address of nv_sprite_extra_data
// X Reg: LSB of address of the nv_sprite_extra_data
.macro nv_sprite_set_mode_from_extra_sr()
{
    nv_sprite_standard_save(SaveBlock)

    // load ZERO_PAGE_LO and ZERO_PAGE_HI with addr of sprite extra data
    nv_sprite_load_extra_ptr()

    // use indirect addressing to get the sprite number
    ldy #NV_SPRITE_NUM_OFFSET       // load Y reg with offset to sprite number
    lda (ZERO_PAGE_LO),y            // indirect indexed load sprite num to accum
    tax
    lda #0
    sec
 Loop:
    rol                             // rotate until we get to our sprite's bit
    dex
    bpl Loop
    pha                             // keep mask on stack

    nv_sprite_data_ptr_to_zero_page()

    // our zero page pointer now points to the sprite data
    // the 64th byte of which contains the color data
    ldy #63
    lda (ZERO_PAGE_LO), y

    // accum now has the 64th byte of the sprite data
    // if any of the four bits in the high nibble are set then 
    // the sprite is multi color (low res).  If
    // no bits in the high nibble are set then
    // its hi res (single color)
    ldx #$F0
    stx scratch_byte
    bit scratch_byte
    beq SingleColor     // if none of the high 4 bits set then single color

MultiColor:
    // if fell through here then multi color mode
    // for multi color mode we need to set the bit for this sprite
    // in the sprite mode register
    pla                           // pop the sprite mask to the accumulator
    ora NV_SPRITE_MODE_REG_ADDR   // or the mask in accum with sprite register 
    sta NV_SPRITE_MODE_REG_ADDR   // store the updated value in sprite reg
    nv_sprite_standard_restore(SaveBlock)
    rts
    
SingleColor:
    // for single color mode we need to clear the bit in the 
    // sprite mode register that corresponds to our sprite
    pla                           // pop the sprite mask to the accum
    eor #$ff                      // negate the mask
    and NV_SPRITE_MODE_REG_ADDR   // clear bit for this sprite 
    sta NV_SPRITE_MODE_REG_ADDR   // store updated sprite reg back
    nv_sprite_standard_restore(SaveBlock)
    rts

SaveBlock:
    nv_sprite_standard_alloc()
}


//////////////////////////////////////////////////////////////////////////////
// To call subroutine setup the following then JSR
// Accum: MSB of address of nv_sprite_extra_data
// X Reg: LSB of address of the nv_sprite_extra_data
.macro nv_sprite_set_data_ptr_from_extra_sr()
{   
    nv_sprite_standard_save(SaveBlock)

    // load ZERO_PAGE_LO and ZERO_PAGE_HI with addr of sprite extra data
    nv_sprite_load_extra_ptr()

    ldy #NV_SPRITE_DATA_PTR_OFFSET
    lda (ZERO_PAGE_LO), y           // get low byte of data ptr in accum
    sta scratch_word                // store in LSB of scratch_word

    iny                             // inc y for high byte of data ptr
    lda (ZERO_PAGE_LO), y           // get MSB of data ptr in accum
    sta scratch_word+1              // store in MSB of scratch_word
    
    //scratch_word now has the data ptr in it
    nv_lsr16(scratch_word, 6)       // dividing by 64 (more or less)
                                    // the low byte of scratch_word now has
                                    // the sprite data block number
                                    // the posible remaining 2 high bits
                                    // are ignored.
 
     // use indirect addressing to get the sprite number
    ldy #NV_SPRITE_NUM_OFFSET       // load Y reg with offset to sprite number
    lda (ZERO_PAGE_LO),y            // indirect indexed load sprite num to accum
    tax                             // move sprite number to X reg

    lda scratch_word                // implied this is multiplied by 64 by system
    sta NV_SPRITE_0_DATA_PTR_ADDR,x         // store in ptr for this sprite

    nv_sprite_standard_restore(SaveBlock)
    rts

SaveBlock:
    nv_sprite_standard_alloc()
}


.macro nv_sprite_push_extra_ptr()
{
    // save A and X on stack
    pha  // push A (hi byte)
    tay  // save A (hi byte)
    txa  // lo byte
    pha  // save lo byte
    tax  // lo byte back to X
    tya  // hi byte back to A
}

.macro nv_sprite_pop_extra_ptr()
{
    // restore A and X
    pla  // pop low byte to A
    tax  // move lo byte to X
    pla  // pop hi byte to A
}

///////////////////////////////////////////////////////////////////////////////
// macro to save the Accum, the X and the values in the zero page
// locations that we use for indirection in most routines that need to 
// indirectly access the sprite's extra data block
// Subroutines that take the extra data address in Accum, and X 
// and then reference the fields with ZERO_PAGE_HI and ZERO_PAGE_LO
// can use this macro to save the state and then use 
// nv_sprite_standard_restore() macro to restore them befor returning.
// note that if used then the following labels need one byte each
// allocated 
//   save_a, save_x, save_zero_lo, save_zero_hi
// space can be allocated via including the nv_sprite_standard_alloc() macro
.macro nv_sprite_standard_save(save_block)
{
    sta save_block
    stx save_block+1
    ldy ZERO_PAGE_LO
    sty save_block+2
    ldy ZERO_PAGE_HI
    sty save_block+3 
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to allocate enough memory to save commonly used registers
// and memory contents such as:
//   Accumulator
//   X register
//   ZERO_PAGE_HI
//   ZERO_PAGE_LO
// use this macro to allocate the memory block passed to the 
// nv_sprite_standard_save() and nv_sprite_standard_restore() macros
.macro nv_sprite_standard_alloc()
{
    save_a: .byte 0
    save_x: .byte 0 
    save_zero_lo: .byte 0
    save_zero_hi: .byte 0
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to restore commonly used registers
// and memory contents such as:
//   Accumulator
//   X register
//   ZERO_PAGE_HI
//   ZERO_PAGE_LO
// use this macro to restore the registers and memory locations to the values
// that were saved from the nv_sprite_standard_save() macro to the same 
// block of memory.
.macro nv_sprite_standard_restore(save_block)
{
    lda save_block
    ldx save_block+1
    ldy save_block+2
    sty ZERO_PAGE_LO
    ldy save_block+3
    sty ZERO_PAGE_HI
}

//////////////////////////////////////////////////////////////////////////////
// setup a sprite based on its extra data
// To call subroutine setup the following then JSR
// Accum: MSB of address of nv_sprite_extra_data
// X Reg: LSB of address of the nv_sprite_extra_data
.macro nv_sprite_setup_from_extra_sr()
{
    sta save_hi
    stx save_lo
    //nv_sprite_push_extra_ptr()
    jsr NvSpriteSetModeFromExtra
    //nv_sprite_pop_extra_ptr()

    lda save_hi
    ldx save_lo
    //nv_sprite_push_extra_ptr()
    jsr NvSpriteSetDataPtrFromExtra
    //nv_sprite_pop_extra_ptr()
    
    lda save_hi
    ldx save_lo
    //nv_sprite_push_extra_ptr()
    jsr NvSpriteSetColorFromExtra
    //nv_sprite_pop_extra_ptr()

    rts

save_hi: .byte 0
save_lo: .byte 0 
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to create an 8 bit mask for the sprite number that is in
// the x register.  
//   X Reg: must contain sprite number (from 0 to 7)
//   Accum: will contain a mask for the sprite number if sprite number in X 
//          is 0 the mask will have the  0 bit set, ie: $01.  if the sprite
//          num in X is 1 then the 1 bit in mask will be set, ie: $02, etc. 
.macro nv_sprite_get_mask_in_a()
{
    // sprite number assumed to be in X register already

    lda #0      // load Accum with 0
    sec         // set carry flag so first rol will rotate in a 1
 Loop:
    rol         // rotate the 1 until we get to our sprite's bit
    dex         // dec X reg until beyond 0  when we can stop rotating
    bpl Loop    // when dex cause us to roll from 0 to FF then exit loop

    // now the accumulator has the sprite mask for sprite num
}


//////////////////////////////////////////////////////////////////////////////
// subroutine macro to set sprite's location in the sprite registers based on
// the appropriate values in the sprite extra data block  
// To call subroutine setup the following then JSR
// Accum: MSB of address of nv_sprite_extra_data
// X Reg: LSB of address of the nv_sprite_extra_data
.macro nv_sprite_set_location_from_extra_sr()
{
    nv_sprite_standard_save(SaveBlock)

    nv_sprite_load_extra_ptr()

    // get sprite number in accum
    nv_sprite_extra_byte_to_a(NV_SPRITE_NUM_OFFSET)
    pha     // push accum (sprite number 0-7)
    
    // multiply by 2 and put in x reg.  Need to multiply by 2 because
    // there x and y location together for each sprite.
    asl 
    tax
    
    // get sprite x location from extra data block to accum
    nv_sprite_extra_byte_to_a(NV_SPRITE_X_OFFSET)

    // store the x location to the correct sprite register
    sta NV_SPRITE_0_X_ADDR,x    // store in right sprite's x loc


    // get sprite y location from extra data block to accum
    nv_sprite_extra_byte_to_a(NV_SPRITE_Y_OFFSET)

    // store y position to correct sprite register
    sta NV_SPRITE_0_Y_ADDR,x    // store in right sprites y loc

    // load MSB of sprite X position to A 
    nv_sprite_extra_byte_to_a(NV_SPRITE_X_OFFSET + 1)
    bne SetBit                            // high byte was non zero, so set bit
    // clear bit

    // create a sprite mask for our sprite number in accumulator and negate it
    pla         // pop sprite number off stack to accum
    tax         // move sprite number to X reg
    nv_sprite_get_mask_in_a()
    eor #$ff    // negate mask so our bit is 0, other bits 1s

    // and with reg that holds all the sprite x hi bits
    // then store it back to the same register so our sprite's bit is clear
    and NV_SPRITE_ALL_X_HIGH_BIT_ADDR
    sta NV_SPRITE_ALL_X_HIGH_BIT_ADDR 
    
    nv_sprite_standard_restore(SaveBlock)
    rts
    
 SetBit: 
    // setting bit for the sprite
    pla                                 // pop sprite num to accum
    tax                                 // sprite num to x for get mask macro
    nv_sprite_get_mask_in_a()           // get a mask for our sprite num
    ora NV_SPRITE_ALL_X_HIGH_BIT_ADDR   // or with the reg of all hi X bits
    sta NV_SPRITE_ALL_X_HIGH_BIT_ADDR   // store back with our bit set

    nv_sprite_standard_restore(SaveBlock)
    rts

SaveBlock:
    nv_sprite_standard_alloc()
}



//////////////////////////////////////////////////////////////////////////////
// Instantiate macros that need to be instantiated below here
//////////////////////////////////////////////////////////////////////////////

NvSpriteSetColorFromExtra:
    nv_sprite_set_color_from_extra_sr()

NvSpriteSetupFromExtra:
    nv_sprite_setup_from_extra_sr()

NvSpriteSetModeFromExtra:
    nv_sprite_set_mode_from_extra_sr()

NvSpriteSetDataPtrFromExtra:
    nv_sprite_set_data_ptr_from_extra_sr()

NvSpriteSetLocationFromExtra:
    nv_sprite_set_location_from_extra_sr()