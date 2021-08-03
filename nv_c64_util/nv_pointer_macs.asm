// nv_pointer_macs.asm
// inline macros for pointer releated functions
// importing this file will not generate any code or data directly

#importonce

#if !NV_C64_UTIL_DATA
.error "Error - nv_pointer_macs.asm: NV_C64_UTIL_DATA not defined.  Import nv_c64_util_data.asm"
#endif

// the #if above doesn't seem to always work so..
// if data hasn't been imported yet, import it into default location
#importif !NV_C64_UTIL_DATA "nv_c64_util_default_data.asm"

#import "nv_branch16_macs.asm"

//////////////////////////////////////////////////////////////////////////////
// inline macro to store the byte in accumulator to the address
// pointed to by a specified pointer
// macro params:
//   ptr_addr: is the addres that contains the pointer to destination
//   save_block: is the address to a two byte block of memory that can
//               be used to save some zero page values that are used
//               for indirection.  they will be restored after the 
//               store operation is done.
//   Accum: unchanged, holds the byte that will be stored 
//   X Reg: unchanged
//   Y Reg: will change
.macro nv_store_a_to_mem_ptr(ptr_addr, save_block)
{
    // zero page pointer to use whenever a zero page pointer is needed
    // usually used to store and load to and from the sprite extra pointer
    .const ZERO_PAGE_LO = $FB
    .const ZERO_PAGE_HI = $FC

    // save our zero page pointer
    ldy ZERO_PAGE_LO
    sty save_block
    ldy ZERO_PAGE_HI
    sty save_block+1

    // load zero page ptr with our pointer
    ldy ptr_addr
    sty ZERO_PAGE_LO
    ldy ptr_addr+1
    sty ZERO_PAGE_HI

    // story accum to the address in our pointer
    ldy #$00              // load Y reg 0 to use ptr address with no offset
    sta (ZERO_PAGE_LO),y  // indirect indexed store accum to pointed to addr

    // restore our zero page pointer
    ldy save_block
    sty ZERO_PAGE_LO
    ldy save_block+1
    sty ZERO_PAGE_HI
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to store the byte in y register to the address
// pointed to by a specified pointer
// macro params:
//   ptr_addr: is the addres that contains the pointer to destination
//   save_block: is the address to a two byte block of memory that can
//               be used to save some zero page values that are used
//               for indirection.  they will be restored after the 
//               store operation is done.
//   Accum: will change
//   X Reg: unchanged
//   Y Reg: will change, holds the byte that will be stored
.macro nv_store_y_to_mem_ptr(ptr_addr, save_block)
{
    // zero page pointer to use whenever a zero page pointer is needed
    // usually used to store and load to and from the sprite extra pointer
    .const ZERO_PAGE_LO = $FB
    .const ZERO_PAGE_HI = $FC

    // save our zero page pointer
    lda ZERO_PAGE_LO
    sta save_block
    lda ZERO_PAGE_HI
    sta save_block+1

    // load zero page ptr with our pointer
    lda ptr_addr
    sta ZERO_PAGE_LO
    lda ptr_addr+1
    sta ZERO_PAGE_HI

    // story accum to the address in our pointer
    tya                   // move y to a to prepare to store
    ldy #$00              // load Y reg 0 to use ptr address with no offset
    sta (ZERO_PAGE_LO),y  // indirect indexed store accum to pointed to addr

    // restore our zero page pointer
    lda save_block
    sta ZERO_PAGE_LO
    lda save_block+1
    sta ZERO_PAGE_HI
}



//////////////////////////////////////////////////////////////////////////////
// inline macro to store the byte in x register to the address
// pointed to by a specified pointer
// macro params:
//   ptr_addr: is the addres that contains the pointer to destination
//   save_block: is the address to a two byte block of memory that can
//               be used to save some zero page values that are used
//               for indirection.  they will be restored after the 
//               store operation is done.
//   Accum: will change
//   X Reg: unchanged, holds the byte to store
//   Y Reg: will change, 
.macro nv_store_x_to_mem_ptr(ptr_addr, save_block)
{
    // zero page pointer to use whenever a zero page pointer is needed
    // usually used to store and load to and from the sprite extra pointer
    .const ZERO_PAGE_LO = $FB
    .const ZERO_PAGE_HI = $FC

    // save our zero page pointer
    lda ZERO_PAGE_LO
    sta save_block
    lda ZERO_PAGE_HI
    sta save_block+1

    // load zero page ptr with our pointer
    lda ptr_addr
    sta ZERO_PAGE_LO
    lda ptr_addr+1
    sta ZERO_PAGE_HI

    // story accum to the address in our pointer
    txa                   // move y to a to prepare to store
    ldy #$00              // load Y reg 0 to use ptr address with no offset
    sta (ZERO_PAGE_LO),y  // indirect indexed store accum to pointed to addr

    // restore our zero page pointer
    lda save_block
    sta ZERO_PAGE_LO
    lda save_block+1
    sta ZERO_PAGE_HI
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to store the byte in accumulator to the list of addresses
// pointed to by a specified pointer
// macro params:
//   ptr_list_addr: is the addres that contains the pointer to the list 
//                  of destination addresses.  the list will be terminated
//                  with $FFFF value but can't be more than 256 total
//                  bytes including the $FFFF terminator 
//                  the list must have an even number of total bytes.
//   save_block: is the address to a two byte block of memory that can
//               be used to save some zero page values that are used
//               for indirection.  they will be restored after the 
//               store operation is done.
// Y Reg: changes
// Accum: does not change, holds byte to store
// X Reg: changes 
.macro nv_store_a_to_mem_ptr_list(ptr_list_addr, save_block)
{
    // zero page pointer to use whenever a zero page pointer is needed
    // usually used to store and load to and from the sprite extra pointer
    .const ZERO_PAGE_LO = $FB
    .const ZERO_PAGE_HI = $FC

    // save our zero page pointer
    ldy ZERO_PAGE_LO
    sty save_block
    ldy ZERO_PAGE_HI
    sty save_block+1

    ldx #0
LoopTop:

    // load zero page ptr with our pointer
    ldy ptr_list_addr,x
    sty ZERO_PAGE_LO
    ldy ptr_list_addr+1, x
    sty ZERO_PAGE_HI
    
    ldy #$FF
    cpy ZERO_PAGE_LO
    bne NotListTerminator
    cpy ZERO_PAGE_HI
    bne NotListTerminator
    // must be term
    jmp HitListTerminator
NotListTerminator:

    // story accum to the address in our pointer
    ldy #$00              // load Y reg 0 to use ptr address with no offset
    sta (ZERO_PAGE_LO),y  // indirect indexed store accum to pointed to addr
    inx
    inx
    jmp LoopTop

HitListTerminator:
    // restore our zero page pointer
    ldy save_block
    sty ZERO_PAGE_LO
    ldy save_block+1
    sty ZERO_PAGE_HI
}
