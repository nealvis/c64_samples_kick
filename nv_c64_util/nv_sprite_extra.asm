//////////////////////////////////////////////////////////////////////////////
// macros to access the sprite extra data block
// including read/write to/from the extra data block
//////////////////////////////////////////////////////////////////////////////

#importonce
#import "nv_util_data.asm"
//#import "nv_sprite.asm"

// zero page pointer to use whenever a zero page pointer is needed
// usually used to store and load to and from the sprite extra pointer
.const ZERO_PAGE_LO = $FB
.const ZERO_PAGE_HI = $FC

// constants for screen edges for bouncing.  These are the values at which the sprite should bounce
.const NV_SPRITE_LEFT_BOUNCE_DEFAULT = 23
.const NV_SPRITE_RIGHT_BOUNCE_DEFAULT = 320
.const NV_SPRITE_TOP_BOUNCE_DEFAULT = 50
.const NV_SPRITE_BOTTOM_BOUNCE_DEFAULT = 234

.const NV_SPRITE_LEFT_WRAP_DEFAULT = 2
.const NV_SPRITE_RIGHT_WRAP_DEFAULT = 339 
.const NV_SPRITE_TOP_WRAP_DEFAULT = 32
.const NV_SPRITE_BOTTOM_WRAP_DEFAULT = 249

.const NV_SPRITE_ACTION_WRAP = 0
.const NV_SPRITE_ACTION_BOUNCE = 1


// struct that provides info for a sprite.  this is a construct of the assembler
// it just provides an easy way to reference all these different compile time values.
// No actual memory is created when an instance of the struct is created.
.struct nv_sprite_info_struct{name, num, init_x, init_y, init_x_vel, init_y_vel, data_ptr, 
                              base_addr, bounce_top, bounce_left, bounce_bottom, bounce_right,
                              top_min, left_min, bottom_max, right_max}


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
    sprite_data_ptr_addr: .word spt_info.data_ptr       // 16 bit addr of sprite data
    sprite_bounce_top: .byte spt_info.bounce_top         // set to 1 to bounce bottom or 0 not to
    sprite_bounce_left: .byte spt_info.bounce_left       // set to 1 to bounce bottom or 0 not to
    sprite_bounce_bottom: .byte spt_info.bounce_bottom   // set to 1 to bounce bottom or 0 not to
    sprite_bounce_right: .byte spt_info.bounce_right     // set to 1 to bounce bottom or 0 not to

    // top boundry for the sprite
    sprite_top_min_addr: .byte spt_info.top_min == 0 ? (spt_info.bounce_top == 1 ? NV_SPRITE_TOP_BOUNCE_DEFAULT : NV_SPRITE_TOP_WRAP_DEFAULT) : spt_info.top_min
    
    // left boundry for the sprite
    sprite_left_min_addr: .word spt_info.left_min == 0 ? (spt_info.bounce_left == 1 ? NV_SPRITE_LEFT_BOUNCE_DEFAULT : NV_SPRITE_LEFT_WRAP_DEFAULT) :spt_info.left_min 

   // bottom boundry for the sprite
    sprite_bottom_max_addr: .byte spt_info.bottom_max == 0 ? (spt_info.bounce_bottom == 1 ? NV_SPRITE_BOTTOM_BOUNCE_DEFAULT : NV_SPRITE_BOTTOM_WRAP_DEFAULT) :spt_info.bottom_max

    // right boundry for the sprite
    sprite_right_max_addr: .word spt_info.right_max == 0 ? (spt_info.bounce_right == 1 ? NV_SPRITE_RIGHT_BOUNCE_DEFAULT : NV_SPRITE_RIGHT_WRAP_DEFAULT) : spt_info.right_max

    // some scratch memory for each sprite     
    sprite_scratch1: .word 0
    sprite_scratch2: .word 0
}

//////////////////////////////////////////////////////////////////////////////
// offsets to use to get to the different fields within the nv_sprite block
.const NV_SPRITE_NUM_OFFSET = 0
.const NV_SPRITE_X_OFFSET = 1
.const NV_SPRITE_Y_OFFSET = 3
.const NV_SPRITE_VEL_X_OFFSET = 4
.const NV_SPRITE_VEL_Y_OFFSET = 5
.const NV_SPRITE_DATA_PTR_OFFSET = 6
.const NV_SPRITE_BOUNCE_TOP_OFFSET = 8
.const NV_SPRITE_BOUNCE_LEFT_OFFSET = 9
.const NV_SPRITE_BOUNCE_BOTTOM_OFFSET = 10
.const NV_SPRITE_BOUNCE_RIGHT_OFFSET = 11

.const NV_SPRITE_TOP_MIN_OFFSET = 12
.const NV_SPRITE_LEFT_MIN_OFFSET = 13
.const NV_SPRITE_BOTTOM_MAX_OFFSET = 15
.const NV_SPRITE_RIGHT_MAX_OFFSET = 16

.const NV_SPRITE_SCRATCH1_OFFSET = 18
.const NV_SPRITE_SCRATCH2_OFFSET = 20


.function nv_sprite_num_addr(info)
{
    .return info.base_addr + NV_SPRITE_NUM_OFFSET
}

.function nv_sprite_vel_y_addr(info) 
{
    .return info.base_addr + NV_SPRITE_VEL_Y_OFFSET
}

.function nv_sprite_vel_x_addr(info)
{
    .return nv_sprite_vel_x_lsb_addr(info)
}
.function nv_sprite_vel_x_lsb_addr(info)
{
    .return info.base_addr + NV_SPRITE_VEL_X_OFFSET
}
.function nv_sprite_vel_x_msb_addr(info)
{
    .return info.base_addr + NV_SPRITE_VEL_X_OFFSET+1
}
.function nv_sprite_x_addr(info)
{
    .return nv_sprite_x_lsb_addr(info)
}
.function nv_sprite_x_lsb_addr(info)
{
    .return info.base_addr + NV_SPRITE_X_OFFSET
}
.function nv_sprite_x_msb_addr(info)
{
    .return info.base_addr + NV_SPRITE_X_OFFSET+1
}



.function nv_sprite_y_addr(info)
{
    .return info.base_addr + NV_SPRITE_Y_OFFSET
}
.function nv_sprite_data_ptr_addr(info)
{
    .return nv_sprite_data_ptr_lsb_addr(info)
}
.function nv_sprite_data_ptr_lsb_addr(info)
{
    .return info.base_addr + NV_SPRITE_DATA_PTR_OFFSET
}
.function nv_sprite_data_ptr_msb_addr(info)
{
    .return info.base_addr + NV_SPRITE_DATA_PTR_OFFSET + 1
}

// 1 means bounce, 0  means wrap
.function nv_sprite_top_action_addr(info)
{
    .return info.base_addr + NV_SPRITE_BOUNCE_TOP_OFFSET
}

// 1 means bounce, 0  means wrap
.function nv_sprite_left_action_addr(info)
{
    .return info.base_addr + NV_SPRITE_BOUNCE_LEFT_OFFSET
}

// 1 means bounce, 0  means wrap
.function nv_sprite_bottom_action_addr(info)
{
    .return info.base_addr + NV_SPRITE_BOUNCE_BOTTOM_OFFSET
}

// 1 means bounce, 0  means wrap
.function nv_sprite_right_action_addr(info)
{
    .return info.base_addr + NV_SPRITE_BOUNCE_RIGHT_OFFSET
}

.function nv_sprite_top_min_addr(info)
{
    .return info.base_addr + NV_SPRITE_TOP_MIN_OFFSET
}

//.function nv_sprite_left_min_addr(info)
//{
//    .return info.base_addr + NV_SPRITE_LEFT_MIN_OFFSET
//}
.function nv_sprite_left_min_lsb_addr(info)
{
    .return info.base_addr + NV_SPRITE_LEFT_MIN_OFFSET
}
.function nv_sprite_left_min_msb_addr(info)
{
    .return info.base_addr + NV_SPRITE_LEFT_MIN_OFFSET+1
}
 
.function nv_sprite_bottom_max_addr(info)
{
    .return info.base_addr + NV_SPRITE_BOTTOM_MAX_OFFSET
}

.function nv_sprite_right_max_addr(info)
{
    .return nv_sprite_right_max_lsb_addr(info)
}
.function nv_sprite_right_max_lsb_addr(info)
{
    .return info.base_addr + NV_SPRITE_RIGHT_MAX_OFFSET
}
.function nv_sprite_right_max_msb_addr(info)
{
    .return info.base_addr + NV_SPRITE_RIGHT_MAX_OFFSET+1
}


.function nv_sprite_scratch1_word_addr(info)
{
    .return nv_sprite_scratch1_word_lsb_addr(info)
}
.function nv_sprite_scratch1_word_lsb_addr(info)
{
    .return info.base_addr + NV_SPRITE_SCRATCH1_OFFSET
}
.function nv_sprite_scratch1_word_msb_addr(info)
{
    .return info.base_addr + NV_SPRITE_SCRATCH1_OFFSET+1
}
.function nv_sprite_scratch2_word_addr(info)
{
    .return info.base_addr + NV_SPRITE_SCRATCH2_OFFSET
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