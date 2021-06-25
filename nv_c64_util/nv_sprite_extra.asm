//////////////////////////////////////////////////////////////////////////////
// macros to access the sprite extra data block
// including read/write to/from the extra data block
//////////////////////////////////////////////////////////////////////////////

#importonce

#import "nv_sprite.asm"


//////////////////////////////////////////////////////////////////////////////
// move the sprite's data pointer to the zero page for some indirection
// assume that when this macro is used that the address of the sprite's 
// extra data is in ZERO_PAGE_LO and ZERO_PAGE_HI already.
// after this macro is executed the ZERO_PAGE_LO and ZERO_PAGE_HI 
// will contain the address of the sprite's data (the 64 bytes that
// define the sprite's shape and color)
.macro nv_sprite_data_ptr_to_zero_page()
{
   
    nv_sprite_extra_word_to_mem(NV_SPRITE_DATA_PTR_OFFSET, scratch_word)
    
    // store sprite data pointer in scratch word to zero page.
    // note this over writes the pointer to extra data in zero page
    // which many of the macros in this file rely on as a pre condition.
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
    ldy #offset             // load Y reg with offset to sprite number
    lda (ZERO_PAGE_LO),y    // indirect indexed load sprite num to accum
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
// inline macro to get a byte from the sprite extra data block assuming
// that the pointer to the extra data block is already in ZERO_PAGE_LO
// and ZERO_PAGE_HI.  Byte from the extra data will be put in the specified
// memory location.
// macro parameters:
//  offset: is the byte offset within the extra data block for the byte
//          to get.  
//  mem: is the memory location in which to copy the byte
.macro nv_sprite_extra_byte_to_mem(offset, mem)
{
    nv_sprite_extra_byte_to_a(offset)
    sta mem
}


//////////////////////////////////////////////////////////////////////////////
// copy a byte from memory to an offset within sprite extra block.
// Assumes that the pointer to the extra data block is
// already in ZERO_PAGE_LO and ZERO_PAGE_HI
// macro parameters:
//   mem: the source memory location from which to copy the byte
//   offset: the offset within the extra block (destination) to write 
//           the byte
// Y changes
// A changes
// X unchanged
.macro nv_sprite_mem_byte_to_extra(mem, offset)
{
    lda mem
    nv_sprite_a_to_extra(offset)
}

//////////////////////////////////////////////////////////////////////////////
// copy a 16 bit word from offset within sprite extra memory to somewhere
// else in memory.  Assumes that the pointer to the extra data block is
// already in ZERO_PAGE_LO and ZERO_PAGE_HI
// macro parameters:
//   offset: the offset within the sprite extra block of low byte of word
//   mem_lo: the low byte of detination memory location
// Y changes
// A changes
// X unchanged
.macro nv_sprite_extra_word_to_mem(offset, mem_lo)
{
    nv_sprite_extra_byte_to_a(offset)
    sta mem_lo
    nv_sprite_extra_byte_to_a(offset+1)
    sta mem_lo+1
}


//////////////////////////////////////////////////////////////////////////////
// copy a 16 bit word from memory to an offset within sprite extra block.
// Assumes that the pointer to the extra data block is
// already in ZERO_PAGE_LO and ZERO_PAGE_HI
// macro parameters:
//   mem_lo: the LSB of source memory location to copy to the extra block
//   offset: the offset of LSB to of the destination word to write within 
//           the sprite extra block 
// Y changes
// A changes
// X unchanged
.macro nv_sprite_mem_word_to_extra(mem_lo, offset)
{
    lda mem_lo
    nv_sprite_a_to_extra(offset)
    lda mem_lo+1
    nv_sprite_a_to_extra(offset+1)
}


//////////////////////////////////////////////////////////////////////////////
// store accum contents to the specified offset within the extra data block
// pointed to by ZERO_PAGE_LO and ZERO_PAGE_HI
// Y Reg: will be changed
// Accum: will not be changed, 
//        but must be set to value to be written before using macro
// X Reg: will not be changed
.macro nv_sprite_a_to_extra(offset)
{
    // use indirect addressing to get the sprite number
    ldy #offset       // load Y reg with offset to sprite number
    sta (ZERO_PAGE_LO),y            // indirect indexed load sprite num to accum
}

//////////////////////////////////////////////////////////////////////////////
// store x reg contents to the specified offset within the extra data block
// pointed to by ZERO_PAGE_LO and ZERO_PAGE_HI
// Y Reg: will be changed
// Accum: will be changed  
// X Reg: set to value to be written before using macro
.macro nv_sprite_x_to_extra(offset)
{
    txa
    nv_sprite_a_to_extra(offset)
}