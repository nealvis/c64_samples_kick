#importonce

#import "nv_util_data.asm"

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
// inline macro to add an 8 bit value in memory to a 16 bit value in memory
// and store the result in another 16bit value.  
// carry bit will be set if carry occured
// params:
//   addr16 is the address of the low byte of 16 bit operand
//   addr8 is the address of the 8 bit operand
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

.macro nv_adc16_8(addr16, addr8, result_addr)
{
    nv_adc16_8unsigned(addr16, addr8, result_addr)
}
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