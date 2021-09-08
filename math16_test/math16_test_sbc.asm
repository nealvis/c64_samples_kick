//////////////////////////////////////////////////////////////////////////////
// math16_test.asm
// Copyright(c) 2021 Neal Smith.
// License: MIT. See LICENSE file in root directory.
//////////////////////////////////////////////////////////////////////////////
// This program tests the 16bit subtraction operations in nv_math16_macs.asm
//////////////////////////////////////////////////////////////////////////////

// import all nv_c64_util macros and data.  The data
// will go in default place
#import "../../nv_c64_util/nv_c64_util_macs_and_data.asm"

*=$0800 "BASIC Start"
.byte 0 // first byte should be 0
        // location to put a 1 line basic program so we can just
        // type run to execute the assembled program.
        // will just call assembled program at correct location
        //    10 SYS (4096)

        // These bytes are a one line basic program that will 
        // do a sys call to assembly language portion of
        // of the program which will be at $1000 or 4096 decimal
        // basic line is: 
        // 10 SYS (4096)
        .byte $0E, $08           // Forward address to next basic line
        .byte $0A, $00           // this will be line 10 ($0A)
        .byte $9E                // basic token for SYS
        .byte $20, $28, $34, $30, $39, $36, $29 // ASCII for " (4096)"
        .byte $00, $00, $00      // end of basic program (addr $080E from above)

*=$0820 "Vars"

.const dollar_sign = $24

// program variables
carry_str: .text @"(C) \$00"
carry_and_overflow_str:  .text @"(CV) \$00"
overflow_str:  .text @"(V) \$00"
plus_str: .text @"+\$00"
minus_str: .text @"-\$00"
equal_str: .text@"=\$00"
lsr_str: .text@">>\$00"

title_str: .text @"MATH16\$00"          // null terminated string to print
                                        // via the BASIC routine
title_adc16_str: .text @"TEST ADC16 \$00"
title_adc16_8u_str: .text @"TEST ADC16 8U \$00"
title_adc16_8s_str: .text @"TEST ADC16 8S \$00"
title_adc16_immediate_str: .text @"TEST ADC16 IMMED\$00"
title_lsr16_str: .text @"TEST LSR16 \$00"
title_sbc16_str: .text @"TEST SBC16 \$00"

hit_anykey_str: .text @"HIT ANY KEY ...\$00"

word_to_print: .word $DEAD
another_word:  .word $BEEF

counter: .byte 0

op1: .word $FFFF
op2: .word $FFFF
result: .word $0000

opSmall: .word $0005
opBig:   .word $747E

op1Beef: .word $beef
op2Beef: .word $beef

opZero: .word $0000
opMax: .word $ffff
opOne: .word $0001
opTwo: .word $0002

opHighOnes: .word $FF00
opLowOnes: .word $00FF
op_7FFF: .word $7FFF
op_FFFE: .word $FFFE
op_0080: .word $0080 // 128
op_0081: .word $0081 // 129
op_8000: .word $8000 // high bit only set
op_8001: .word $8001 // high bit only set
op_FFFF: .word $FFFF // all bits
op_0000: .word $0000 // all bits
op_0001: .word $0001 // all bits
op_0002: .word $0002 // all bits
op_00FF: .word $00FF 
op_0100: .word $0100
op_0200: .word $0200
op_0300: .word $0300
op_3333: .word $3333
op_2222: .word $2222
op_FFFD: .word $FFFD // -3

op_00: .byte $00
op_01: .byte $01

op8_7F: .byte $7F
op8_FF: .byte $FF
op8_0F: .byte $0F
op8_F0: .byte $F0
op8_80: .byte $80  // -128
op8_81: .byte $81  // -127

op_02: .byte $02
op_08: .byte $08
op_09: .byte $09
op_80: .byte $80
op_81: .byte $81
op_7F: .byte $7F
op_FF: .byte $FF
op_10: .byte $10
op_0F: .byte $0F
op_FD: .byte $FD
op_33: .byte $33
op_22: .byte $22
op_FE: .byte $FE


*=$1000 "Main Start"

.var row = 0

    nv_screen_clear()
    nv_screen_plot_cursor(row++, 33)
    nv_screen_print_str(title_str)

    test_sbc16(0)

    rts

//////////////////////////////////////////////////////////////////////////////
//
.macro test_sbc16(init_row)
{
    .var row = init_row
    
    //////////////////////////////////////////////////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_str(title_adc16_str)
    //////////////////////////////////////////////////////////////////////////
    .eval row++

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_sbc16_and_sbc8(op_0000, op_0001, op_00, op_01, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_sbc16_and_sbc8(op_0001, op_0000, op_01, op_00, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_sbc16_and_sbc8(op_0081, op_0080, op_09, op_08, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_sbc16_and_sbc8(opTwo, opOne, op_02, op_01, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_sbc16_and_sbc8(op_8000, op_8000, op_80, op_80, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_sbc16_and_sbc8(op_8000, op_8001, op_80, op_81, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_sbc16_and_sbc8(op_8000, op_7FFF, op_80, op_7F, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_sbc16_and_sbc8(op_8000, op_0001, op_80, op_01, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_sbc16_and_sbc8(op_0001, op_7FFF, op_01, op_7F, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_sbc16_and_sbc8(op_7FFF, op_7FFF, op_7F, op_7F, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_sbc16_and_sbc8(op_7FFF, op_0001, op_7F, op_01, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_sbc16_and_sbc8(op_7FFF, op_0002, op_7F, op_02, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_sbc16_and_sbc8(op_FFFF, op_FFFF, op_FF, op_FF, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_sbc16_and_sbc8(op_0100, op_00FF, op_10, op_0F, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_sbc16_and_sbc8(op_0002, op_FFFD, op_02, op_FD, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_sbc16_and_sbc8(op_0002, op_8000, op_02, op_80, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_sbc16_and_sbc8(op_3333, op_2222, op_33, op_22, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_sbc16_and_sbc8(op_0000, op_7FFF, op_00, op_7F, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_sbc16_and_sbc8(op_FFFE, op_7FFF, op_FE, op_7F, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_sbc16_and_sbc8(op_7FFF, op_8000, op_7F, op_80, result)

    wait_and_clear_at_row(row)
}




/////////////////////////////////////////////////////////////////////////////
// wait for key then clear screen when its detected
.macro wait_and_clear_at_row(init_row)
{
    .var row = init_row
    .eval row++
    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_str(hit_anykey_str)

    nv_key_wait_any_key()

    nv_screen_clear()
    .eval row=0
    nv_screen_plot_cursor(row++, 33)
    nv_screen_print_str(title_str)
}


//////////////////////////////////////////////////////////////////////////////
//                          Print macros 
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
// inline macro to print the specified addition at the current curor location
// nv_adc16 us used to do the addition.
// C, V or CV will show up to indicate the carry and overflow  
// Will look like this with no borrow needed (carry still set) and no overflow
//    $3333 - $2222 = (C) $1111
// Will look like this when borrow was required (Carry cleared)
//    $0001 - $0002 = $FFFF
// Will look like this when result couldn't result of signed 
// subtraction resulted in number with wrong sign but no borrow required
//    $8000 - $0001 = (CV)$7FFF
// with borrow needed it will look like this
//    $7FFF - $8000 = (V) $FFFF
.macro print_sbc16(op1, op2, result)
{
    nv_screen_print_hex_word_mem(op1, true)
    nv_screen_print_str(minus_str)
    nv_screen_print_hex_word_mem(op2, true)
    nv_screen_print_str(equal_str)

    nv_sbc16(op1, op2, result)
    bcc NoCarry
Carry:
    bvs CarryAndOverflow 
CarryNoOverflow:
    nv_screen_print_str(carry_str)
    jmp PrintResult
CarryAndOverflow:
    nv_screen_print_str(carry_and_overflow_str)
    jmp PrintResult
NoCarry: 
    bvc NoCarryNoOverflow
NoCarryButOverflow:
    nv_screen_print_str(overflow_str)
    jmp PrintResult
NoCarryNoOverflow:
    // print nothing here

PrintResult:
    nv_screen_print_hex_word_mem(result, true)
}

//////////////////////////////////////////////////////////////////////////////
//
.macro print_sbc16_and_sbc8(op16a, op16b, op8a, op8b, result)
{
    nv_screen_print_hex_word_mem(op16a, true)
    nv_screen_print_str(minus_str)
    nv_screen_print_hex_word_mem(op16b, true)
    nv_screen_print_str(equal_str)

    nv_sbc16(op16a, op16b, result)
    PrintCarryAndOverflow()

PrintResult16:
    nv_screen_print_hex_word_mem(result, true)

// now 8 bit
    nv_screen_plot_cursor_col(24)
    nv_screen_print_hex_byte_mem(op8a, true)
    nv_screen_print_str(minus_str)
    nv_screen_print_hex_byte_mem(op8b, true)
    nv_screen_print_str(equal_str)
    lda op8a
    sec
    sbc op8b
    sta scratch_byte
    PrintCarryAndOverflow()
PrintResult8:
    nv_screen_print_hex_byte_mem(scratch_byte, true)

}

/////////////////////////////////////////////////////////////////
//
.macro PrintCarryAndOverflow()
{
    bcc NoCarry
Carry:
    bvs CarryAndOverflow 
CarryNoOverflow:
    nv_screen_print_str(carry_str)
    jmp Done
CarryAndOverflow:
    nv_screen_print_str(carry_and_overflow_str)
    jmp Done
NoCarry: 
    bvc NoCarryNoOverflow
NoCarryButOverflow:
    nv_screen_print_str(overflow_str)
    jmp Done
NoCarryNoOverflow:
Done:
}
