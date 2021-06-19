#importonce


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


