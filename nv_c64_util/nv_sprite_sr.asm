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
// Sets a sprites color from the last byte in the sprite data
// the sprite data is found by getting the address of the first byte
// of it from the sprite's extra data.
// To call subroutine setup the following then JSR
// Accum: MSB of address of nv_sprite_extra_data
// X Reg: LSB of address of the nv_sprite_extra_data
.macro nv_sprite_set_color_from_extra_sr()
{
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

    rts
}

//////////////////////////////////////////////////////////////////////////////
// To call this subroutine setup the following then JSR
// Accum: MSB of address of nv_sprite_extra_data
// X Reg: LSB of address of the nv_sprite_extra_data
.macro nv_sprite_set_mode_from_extra_sr()
{
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
    rts
    
SingleColor:
    // for single color mode we need to clear the bit in the 
    // sprite mode register that corresponds to our sprite
    pla                           // pop the sprite mask to the accum
    eor #$ff                      // negate the mask
    and NV_SPRITE_MODE_REG_ADDR   // clear bit for this sprite 
    sta NV_SPRITE_MODE_REG_ADDR   // store updated sprite reg back
    rts
}


//////////////////////////////////////////////////////////////////////////////
// To call subroutine setup the following then JSR
// Accum: MSB of address of nv_sprite_extra_data
// X Reg: LSB of address of the nv_sprite_extra_data
.macro nv_sprite_set_data_ptr_from_extra_sr()
{
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

    rts
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