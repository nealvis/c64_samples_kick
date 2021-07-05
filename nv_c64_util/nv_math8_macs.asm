//////////////////////////////////////////////////////////////////////////////
// nv_math8_macs.asm
// contains inline macros for 8 bit math related functions.
// importing this file will not allocate any memory for data or code.
//////////////////////////////////////////////////////////////////////////////

#importonce

#if !NV_C64_UTIL_DATA
.error "Error - nv_math8_macs.asm: NV_C64_UTIL_DATA not defined.  Import nv_c64_util_data.asm"
#endif

// the #if above doesn't seem to always work so..
// if data hasn't been imported yet, import it into default location
#importif !NV_C64_UTIL_DATA "nv_c64_util_default_data.asm"


//////////////////////////////////////////////////////////////////////////////
// inline macro to create a bit mask for a bit number between 0 and 7.
//   macro parameters:
//     bit_num_addr: is the address of a byte that contains the bit
//                   number for which a bit mask will be created. 
//     negate: is boolean that specifies if the bit mask should be
//             negated.  Normally the mask for bit number 3 would be
//             $08 but if negate is true then the mask will be $F7 
// The bitmask created will be left in accumulator
.macro nv_mask_from_bit_num_mem(bit_num_addr, negate)
{
    lda #$01
    ldx bit_num_addr
    beq MaskDone
    clc 
Loop:
    rol 
    dex
    bne Loop

MaskDone:
    .if (negate == true)
    {
        eor #$FF
    }
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to create a bit mask for a bit number between 0 and 7.
// Macro params
//   negate: is boolean that specifies if the bit mask should be
//           negated.  Normally the mask for bit number 3 would be
//           $08 but if negate is true then the mask will be $F7 
//   accum: must have the bit number for which the mask will be created 
//          upon start and will contain the bitmask upon finish
// The bitmask created will overwrite the bit number in accumulator
.macro nv_mask_from_bit_num_a(negate)
{
    tax
    lda #$01
    cpx #$00 
    beq MaskDone
    clc 
Loop:
    rol 
    dex
    bne Loop

MaskDone:
    .if (negate == true)
    {
        eor #$FF
    }

}

//////////////////////////////////////////////////////////////////////////////
// inline macro to store an immediate 8 bit value in a byte in memory
// macro parameters
//   addr: the address in which to store the immediate value
//   immed_value: is the value to store ($00 - $FF)
.macro nv_store8_immediate(addr, immed_value)
{
    .if (immed_value > $00FF)
    {
        .error("Error - nv_store8_immediate: immed_value, was larger than 8 bits")
    }
    lda #immed_value
    sta addr
}