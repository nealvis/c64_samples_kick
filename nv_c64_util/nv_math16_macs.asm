#importonce

#if !NV_C64_UTIL_DATA
.error "Error - nv_math16_macs.asm: NV_C64_UTIL_DATA not defined.  Import nv_c64_util_data.asm"
#endif

//////////////////////////////////////////////////////////////////////////////
// inline macro to add two 16 bit values and store the result in another
// 16bit value.  carry bit will be set if carry occured
// params:
//   addr1 is the address of the low byte of op1
//   addr2 is the address of the low byte of op2
//   result_addr is the address to store the result.
.macro nv_adc16(addr1, addr2, result_addr)
{
    lda addr1
    clc
    adc addr2
    sta result_addr
    lda addr1+1
    adc addr2+1
    sta result_addr+1
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to add a signed 8 bit value in memory to a 16 bit value 
// in memory and store the result in another 16bit value.  
// carry bit will be set if carry occured
// params:
//   addr16 is the address of the low byte of 16 bit operand
//   addr8 is the address of the signed 8 bit operand.  As an 8 bit
//         signed number, if the sign bit is 1 then it will be 
//         extended to create a 16bit value that will be added to the
//         value at addr16.  The created 16 bit value will have all 8 high
//         bits set to match the sign bit from the original 8 bit value.
//         For example,  if the 8 bit value at addr8 is $FF (-1)  then
//         instead of adding $00FF to the 16 bit number we'll be adding 
//         $FFFF which is -1 so that the result will be as expected.   
//   result_addr is the address to store the result.
.macro nv_adc16_8signed(addr16, addr8, result_addr)
{
    ldx #0
    lda addr8
    bpl Op2Positive
    ldx #$ff
Op2Positive:
    stx scratch_byte
    clc
    adc addr16
    sta result_addr
    lda addr16+1
    adc scratch_byte
    sta result_addr+1
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to add an unsigned 8 bit value in memory to a 16 bit value 
// This is just shorthand for nv_adc16_8_unsigned
.macro nv_adc16_8(addr16, addr8, result_addr)
{
    nv_adc16_8unsigned(addr16, addr8, result_addr)
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to add an unsigned 8 bit value in memory to a 16 bit value 
// in memory and store the result in another 16 bit value.  
// carry bit will be set if carry occured
// params:
//   addr16 is the address of the LSB of 16 bit operand
//   addr8 is the address of the unsigned 8 bit operand.  Since this is
//         unsigned, when the value is $FF, the result won't be to
//         adding a negative 1 but will be adding 255 to the 16 bit value.    
//   result_addr is the address to store the result.
.macro nv_adc16_8unsigned(addr16, addr8, result_addr)
{
    lda addr16
    clc
    adc addr8
    sta result_addr
    lda addr16+1
    adc #0
    sta result_addr+1
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to add one 16 bit values in memory to an immediate value
// and store the result in another 16bit value.  
// carry bit will be set if carry occured
// params:
//   addr1 is the address of the LSB of 16 bit value in memory
//   num is the immeidate number to add
//   result_addr is the address of the LSB of the 16 bit memory location 
//               to store the result.
.macro nv_adc16_immediate(addr1, num, result_addr)
{
    lda addr1
    clc
    adc #(num & $00FF)
    sta result_addr
    lda addr1+1
    adc #((num >> 8) & $00FF)
    sta result_addr+1
}

//////////////////////////////////////////////////////////////////////////////
// rotate bits right in a 16 bit location in memory
// addr is the address of the lo byte and addr+1 is the MSB
// num is the nubmer of rotations to do.
// zeros will be rotated in to the high bits
// the carry flag will be set if the last rotation rotated off
// a one from the low bit 
.macro nv_lsr16(addr, num)
{
    ldy #num
Loop:
    clc
    lsr addr+1
    ror addr
    dey
    bne Loop
}


.macro negate16(addr16, result_addr16)
{
    lda addr16
    eor #$FF
    sta result_addr16

    lda addr16+1
    eor #$FF
    sta result_addr16+1
}

.macro nv_twos_comp_16(addr16, result_addr16)
{
    negate16(addr16, result_addr16)
    nv_adc16_immediate(result_addr16, 1, result_addr16)
}

// subtract contents at addr2 from those at addr1
.macro nv_sbc16(addr1, addr2, result_addr)
{
    // nps todo: look at the sbc instruction, might be better
    // to use that than to take 2s comp and add.
    nv_twos_comp_16(addr2, nv_g16)
    nv_adc16(addr1, nv_g16, result_addr)
}
//sbc16_temp16: .word 0

//////////////////////////////////////////////////////////////////////////////
// inlne macro to store 16 bit immediate value into the word with LSB 
// at lsb_addr
.macro nv_store16_immediate(lsb_addr, value)
{
    lda #(value & $00FF)
    sta lsb_addr
    lda #(value >> 8)
    sta lsb_addr+1
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to move one 16 bit word in memory to another location
// in memory.
// Macro Params:
//   lsb_src_addr: LSB of the source for the copy
//   lsb_dest_addr: LSB of the destination for the copy
// Accum will be modified
.macro nv_xfer16_mem_mem(lsb_src_addr, lsb_dest_addr)
{
    lda lsb_src_addr
    sta lsb_dest_addr
    lda lsb_src_addr+1
    sta lsb_dest_addr+1
}
