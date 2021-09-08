//////////////////////////////////////////////////////////////////////////////
// math16_test_bcd.asm
// Copyright(c) 2021 Neal Smith.
// License: MIT. See LICENSE file in root directory.
//////////////////////////////////////////////////////////////////////////////
// This program tests the bcd math operations in nv_math16.asm
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

title_str: .text @"MATH16 BCD\$00"      // null terminated string to print
                                        // via the BASIC routine
title_bcd_adc16_str: .text @"TEST BCD ADC16 \$00"
title_bcd_adc16_immediate_str: .text @"TEST BCD ADC16 IMMED\$00"

hit_anykey_str: .text @"HIT ANY KEY ...\$00"

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
op_0009: .word $0009
op_00FF: .word $00FF 
op_0100: .word $0100
op_0200: .word $0200
op_0300: .word $0300
op_9999: .word $9999
op_9000: .word $9000
op_0090: .word $0090
op_0099: .word $0099
op_0020: .word $0020
op_0999: .word $0999


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
    nv_screen_plot_cursor(row++, 30)
    nv_screen_print_str(title_str)

    test_bcd_adc16_immediate(0)
    test_bcd_adc16(0)

    rts

//////////////////////////////////////////////////////////////////////////////
//
.macro test_bcd_adc16_immediate(init_row)
{
    .var row = init_row
    
    //////////////////////////////////////////////////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_str(title_bcd_adc16_immediate_str)
    //////////////////////////////////////////////////////////////////////////
    .eval row++

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bcd_adc16_immediate(op_0000, $0001, result)


    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bcd_adc16_immediate(op_0009, $0001, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bcd_adc16_immediate(op_0009, $0020, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bcd_adc16_immediate(op_0099, $0001, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bcd_adc16_immediate(op_0099, $0002, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bcd_adc16_immediate(op_0999, $9000, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bcd_adc16_immediate(op_9999, $0001, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bcd_adc16_immediate(op_9999, $0099, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bcd_adc16_immediate(op_9999, $9999, result)


    wait_and_clear_at_row(row)
}


//////////////////////////////////////////////////////////////////////////////
//
.macro test_bcd_adc16(init_row)
{
    .var row = init_row
    
    //////////////////////////////////////////////////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_str(title_bcd_adc16_str)
    //////////////////////////////////////////////////////////////////////////
    .eval row++

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bcd_adc16(op_0000, op_0001, result)


    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bcd_adc16(op_0009, op_0001, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bcd_adc16(op_0009, op_0020, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bcd_adc16(op_0099, op_0001, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bcd_adc16(op_0099, op_0002, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bcd_adc16(op_0999, op_9000, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bcd_adc16(op_9999, op_0001, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bcd_adc16(op_9999, op_0099, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bcd_adc16(op_9999, op_9999, result)


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
    nv_screen_plot_cursor(row++, 30)
    nv_screen_print_str(title_str)
}


//////////////////////////////////////////////////////////////////////////////
//                          Print macros 
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// inline macro to print the specified addition at the current curor location
// nv_bcd_adc16 is used to do the addition.
// C, will show up to indicate the carry  

// Will look like this when carry set but no overflow
//    9999 + 0001 = (C) 0000
// Will look like this when no carry and no overflow
//    0001 - 0002 = 0003
.macro print_bcd_adc16(op1, op2, result)
{
    nv_screen_print_bcd_word_mem(op1)
    nv_screen_print_str(plus_str)
    nv_screen_print_bcd_word_mem(op2)
    nv_screen_print_str(equal_str)

    nv_bcd_adc16(op1, op2, result)
    PrintCarryAndOverflow()

    nv_screen_print_bcd_word_mem(result)
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to print the specified addition at the current curor location
// nv_bcd_adc16 is used to do the addition.
// C, will show up to indicate the carry  

// Will look like this when carry set but no overflow
//    9999 + 0001 = (C) 0000
// Will look like this when no carry and no overflow
//    0001 - 0002 = 0003
.macro print_bcd_adc16_immediate(op1, num, result)
{
    nv_screen_print_bcd_word_mem(op1)
    nv_screen_print_str(plus_str)
    nv_screen_print_bcd_word_immed(num)
    nv_screen_print_str(equal_str)

    nv_bcd_adc16_immediate(op1, num, result)
    PrintCarryAndOverflow()

PrintResult:
    nv_screen_print_bcd_word_mem(result)
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
