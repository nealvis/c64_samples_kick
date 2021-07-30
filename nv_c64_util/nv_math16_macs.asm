#importonce

#if !NV_C64_UTIL_DATA
.error "Error - nv_math16_macs.asm: NV_C64_UTIL_DATA not defined.  Import nv_c64_util_data.asm"
#endif

// the #if above doesn't seem to always work so..
// if data hasn't been imported yet, import it into default location
#importif !NV_C64_UTIL_DATA "nv_c64_util_default_data.asm"

#import "nv_branch16_macs.asm"

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
// Note: X and Y Regs are not used
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
// inline macro to multiply one 16 bit value by an 8 bit immediate value
// and store the result in another 16bit value.  
// carry bit will be set if carry occured
// params:
//   addr1 is the address of the LSB of 16 bit value in memory
//   num is the immeidate 8 bit number to multiply addr1 by 
//   result_addr is the address of the LSB of the 16 bit memory location 
//               to store the result.
.macro nv_mul16_immediate8(addr1, num8, result_addr)
{
    .if (num8 > 255)
    {
        .error "ERROR - nv_mul16_immediate8: num8 too large"
    }
    ldx #num8
    nv_mul16_x(addr1, result_addr)
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to multiply one 16 bit value by an 8 bit value in x reg
// and store the result in another 16bit value.  
// carry bit will be set if carry occured
// macro params:
//   addr1 is the address of the LSB of 16 bit value in memory
//   result_addr is the address of the LSB of the 16 bit memory location 
//               to store the result.
// params:
//   x reg should be set to the 8 bit number to multiply by prior to 
//         this macro
.macro nv_mul16_x(addr1, result_addr)
{
    cpx #$00
    beq MultByZero
    lda addr1
    beq MultByZero
    nv_store16_immediate(scratch_word, $0000)
LoopTop:
    nv_adc16(addr1, scratch_word, scratch_word)
    dex
    bne LoopTop
 
    nv_xfer16_mem_mem(scratch_word, result_addr)
    jmp Done

MultByZero:
    nv_store16_immediate(result_addr, $0000)
Done:    
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to multiply one 16 bit value by an 8 bit value in y reg
// and store the result in another 16bit value.  
// carry bit will be set if carry occured
// macro params:
//   addr1 is the address of the LSB of 16 bit value in memory
//   result_addr is the address of the LSB of the 16 bit memory location 
//               to store the result.
// params:
//   y reg should be set to the 8 bit number to multiply by prior to 
//         this macro
.macro nv_mul16_y(addr1, result_addr)
{
    cpy #$00
    beq MultByZero
    lda addr1
    beq MultByZero
    nv_store16_immediate(scratch_word, $0000)
LoopTop:
    nv_adc16(addr1, scratch_word, scratch_word)
    dey
    bne LoopTop
 
    nv_xfer16_mem_mem(scratch_word, result_addr)
    jmp Done

MultByZero:
    nv_store16_immediate(result_addr, $0000)
Done:    
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

//////////////////////////////////////////////////////////////////////////////
// inline macro to negate a 16 bit number at addr specified
.macro negate16(addr16, result_addr16)
{
    lda addr16
    eor #$FF
    sta result_addr16

    lda addr16+1
    eor #$FF
    sta result_addr16+1
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to do twos compliment on a 16 but number in memory
// and place result in specified memory location.
.macro nv_twos_comp_16(addr16, result_addr16)
{
    negate16(addr16, result_addr16)
    nv_adc16_immediate(result_addr16, 1, result_addr16)
}

//////////////////////////////////////////////////////////////////////////////
// inline mcaro to 
// subtract contents at addr2 from those at addr1
.macro nv_sbc16(addr1, addr2, result_addr)
{
    sec
    lda addr1
    sbc addr2
    sta result_addr
    lda addr1+1
    sbc addr2+1
    sta result_addr+1
}


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

//////////////////////////////////////////////////////////////////////////////
// inline macro to add two 16 bit BCD values and store the result in another
// 16bit BCD value.  carry bit will be set if carry occured
// params:
//   addr1 is the address of the LSB of op1
//   addr2 is the address of the LSB of op2
//   result_addr is the address to store the result.
// Note: clears decimal mode after the addition is done 
.macro nv_bcd_adc16(addr1, addr2, result_addr)
{
    sed
    lda addr1
    clc
    adc addr2
    sta result_addr
    lda addr1+1
    adc addr2+1
    sta result_addr+1
    cld
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to add one 16 bit value in memory to an immediate value
// and store the result in another 16 bit value in memory.  
// carry bit will be set if carry occured
// params:
//   addr1 is the address of the LSB of 16 bit value in memory
//   num: is the immeidate number to add.  it must be a valid BCD 
//        number which is hex values with no letters in any digit.
//   result_addr is the address of the LSB of the 16 bit memory location 
//               to store the result.
.macro nv_bcd_adc16_immediate(addr1, num, result_addr)
{
    sed
    lda addr1
    clc
    adc #(num & $00FF)
    sta result_addr
    lda addr1+1
    adc #((num >> 8) & $00FF)
    sta result_addr+1
    cld
}


//////////////////////////////////////////////////////////////////////////////
// macro routine to test if one rectangle overlaps another
// This routine will work on rectangles of any size.
// If its known that one rectangle can completely fit inside the other one
// than another then the macro nv_util_check_small_rect_in_big_rect
// rect1_addr: address of a rectangle.  A rectangle is defined by 
//             8 bytes, which are interpreted as two 16 bit xy pairs 
//             as such:
//               x_left: .word 
//               y_top: .word
//               x_right: .word
//               y_bottom: .word
// rect2_addr: address of another rectangle
// load accum to 1 if they overlap or 0 if they do not overlap
.macro nv_check_rect_overlap16(rect1_addr, rect2_addr)
{
    .label r1_left = rect1_addr
    .label r1_top = rect1_addr + 2
    .label r1_right = rect1_addr + 4
    .label r1_bottom = rect1_addr + 6

    .label r2_left = rect2_addr
    .label r2_top = rect2_addr + 2
    .label r2_right = rect2_addr + 4
    .label r2_bottom = rect2_addr + 6

// if ((r2.left is between r1.left and r1.right)  or 
//     (r2.right is between r1.left and r1.right)) and
//    ((r2.bottom is below r1.top) and (r2.top is above r1.bottom)))
// then 
// {
//    rects overlap
// }
// else
// {
//    do same comparison with reverse (use r1 for r2 and r2 for r1 in above if)
// }
    nv_check_range16(r2_left, r1_left, r1_right, false)
    bne OneVertSideBetween
    nv_check_range16(r2_right, r1_left, r1_right, false)
    bne OneVertSideBetween
    jmp TryReverse
OneVertSideBetween:
    nv_blt16(r2_bottom, r1_top, TryReverse)
    nv_bgt16(r2_top, r1_bottom, TryReverse)
    jmp RectOverlap

TryReverse:
    nv_check_range16(r1_left, r2_left, r2_right, false)
    bne OneVertSideBetween2
    nv_check_range16(r1_right, r2_left, r2_right, false)
    bne OneVertSideBetween2
    jmp NoRectOverlap

OneVertSideBetween2:
    nv_blt16(r1_bottom, r2_top, NoRectOverlap)
    nv_bgt16(r1_top, r2_bottom, NoRectOverlap)
    // jmp RectOverlap

RectOverlap:
    lda #1
    jmp AccumLoaded
NoRectOverlap:
    lda #0

AccumLoaded:

}

/*
//////////////////////////////////////////////////////////////////////////////
// macro routine to test if one rectangle overlaps another
// This routine will work on rectangles of any size.
// If its known that one rectangle can completely fit inside the other one
// than another then the macro nv_util_check_small_rect_in_big_rect
// rect1_addr: address of a rectangle.  A rectangle is defined by 
//             8 bytes, which are interpreted as two 16 bit xy pairs 
//             as such:
//               x_left: .word 
//               y_top: .word
//               x_right: .word
//               y_bottom: .word
// rect2_addr: address of another rectangle
// load accum to 1 if they overlap or 0 if they do not overlap
.macro nv_util_check_rects_overlap_old(rect1_addr, rect2_addr)
{
    .label r1_left = rect1_addr
    .label r1_top = rect1_addr + 2
    .label r1_right = rect1_addr + 4
    .label r1_bottom = rect1_addr + 6

    .label r2_left = rect2_addr
    .label r2_top = rect2_addr + 2
    .label r2_right = rect2_addr + 4
    .label r2_bottom = rect2_addr + 6

    nv_util_check_point_in_rect(r1_left, r1_top, rect2_addr)
    bne RectOverlap
    nv_util_check_point_in_rect(r1_left, r1_bottom, rect2_addr)
    bne RectOverlap
    nv_util_check_point_in_rect(r1_right, r1_top, rect2_addr)
    bne RectOverlap
    nv_util_check_point_in_rect(r1_right, r1_bottom, rect2_addr)
    bne RectOverlap
    nv_util_check_point_in_rect(r2_left, r2_top, rect1_addr)
    bne RectOverlap

RectOverlap:
    lda #1
    jmp AccumLoaded
NoRectOverlap:
    lda #0

AccumLoaded:

}
*/


// set the accum to 1 if test num is between num low and num high
.macro nv_check_range16(test_num_addr, num_low_addr, num_high_addr, inclusive)
{
.if (inclusive)
{
    nv_blt16(test_num_addr, num_low_addr, ResultFalse)
    nv_bgt16(test_num_addr, num_high_addr, ResultFalse)
}
else
{
    nv_ble16(test_num_addr, num_low_addr, ResultFalse)
    nv_bge16(test_num_addr, num_high_addr, ResultFalse)
}

ResultTrue:
    lda #1
    jmp AccumLoaded

ResultFalse:
    lda #0

AccumLoaded:
}


// set the accum to 1 if point is in rect or to 0 if its not in rect
.macro nv_check_in_rect16(p1_x, p1_y, rect_addr)
{
    .label r1_left = rect_addr
    .label r1_top = rect_addr + 2
    .label r1_right = rect_addr + 4
    .label r1_bottom = rect_addr + 6

    nv_blt16(p1_x, r1_left, PointNotInRect)
    nv_bgt16(p1_x, r1_right, PointNotInRect)
    nv_blt16(p1_y, r1_top, PointNotInRect)
    nv_bgt16(p1_y, r1_bottom, PointNotInRect)

PointInRect:
    lda #1
    jmp AccumLoaded

PointNotInRect:
    lda #0

AccumLoaded:

}