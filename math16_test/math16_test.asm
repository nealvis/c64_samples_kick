// This sample shows how to do 16bit operations such as add, subtract, and compare


#import "../nv_c64_util/nv_c64_util.asm"

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
plus_str: .text @" + \$00"
equal_str: .text@" = \$00"

title_str: .text @"MATH16\$00"          // null terminated string to print
                                        // via the BASIC routine
title_adc16_str: .text @"TEST ADC16 \$00"
title_adc16_8_str: .text @"TEST ADC16 8 \$00"
title_adc16_immediate_str: .text @"TEST ADC16 IMMED\$00"

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

op8_7F: .byte $7F
op8_FF: .byte $FF
op8_0F: .byte $0F
op8_F0: .byte $F0

*=$1000 "Main Start"

.var row = 0

    nv_screen_clear()
    nv_screen_plot_cursor(row++, 33)
    nv_screen_print_string_basic(title_str)

    test_adc16(0)
    test_adc16_immediate(0)
    test_adc16_8(0)

    rts


//////////////////////////////////////////////////////////////////////////////
//
.macro test_adc16(init_row)
{
    .var row = init_row
    
    //////////////////////////////////////////////////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_string_basic(title_adc16_str)
    //////////////////////////////////////////////////////////////////////////
    .eval row++

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_adc16(op1, op2, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_adc16(opOne, opTwo, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_adc16(opOne, opMax, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_adc16(opMax, opZero, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_adc16(opOne, opMax, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_adc16(opLowOnes, opOne, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_adc16(opLowOnes, opHighOnes, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_adc16(opHighOnes, opLowOnes, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_adc16(op_7FFF, opMax, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_adc16(op_7FFF, opOne, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_adc16(op_7FFF, opTwo, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_adc16(op_FFFE, opTwo, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_adc16(op_FFFE, opOne, result)

    wait_and_clear_at_row(row)
}


//////////////////////////////////////////////////////////////////////////////
//
.macro test_adc16_8(init_row)
{
    .var row = init_row
    
    //////////////////////////////////////////////////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_string_basic(title_adc16_8_str)
    //////////////////////////////////////////////////////////////////////////
    .eval row++

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_adc16_8(op1, op2, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_adc16_8(opOne, opTwo, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_adc16_8(opOne, opMax, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_adc16_8(opMax, opZero, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_adc16_8(opOne, opMax, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_adc16_8(opLowOnes, opOne, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_adc16_8(opLowOnes, op8_7F, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_adc16_8(opHighOnes, opMax, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_adc16_8(op_7FFF, opOne, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_adc16_8(op1Beef, op8_0F, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_adc16_8(op1Beef, op8_F0, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_adc16_8(opMax, op8_F0, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_adc16_8(opMax, op8_FF, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_adc16_8(op_7FFF, op8_FF, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_adc16_8(op_7FFF, opOne, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_adc16_8(op_7FFF, opTwo, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_adc16_8(op_FFFE, opTwo, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_adc16_8(op_FFFE, opOne, result)

    wait_and_clear_at_row(row)
}


//////////////////////////////////////////////////////////////////////////////
//
.macro test_adc16_immediate(init_row)
{
    .var row = init_row
    
    //////////////////////////////////////////////////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_string_basic(title_adc16_immediate_str)
    //////////////////////////////////////////////////////////////////////////
    .eval row++

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_adc16_immediate(op1, $36B1, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_adc16_immediate(opOne, $0002, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_adc16_immediate(opOne, $FFFF, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_adc16_immediate(opMax, $0000, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_adc16_immediate(opOne, $FFFF, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_adc16_immediate(opLowOnes, $0001, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_adc16_immediate(opLowOnes, $FF00, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_adc16_immediate(opHighOnes, $00FF, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_adc16_immediate(op_7FFF, $FFFF, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_adc16_immediate(op_7FFF, $0001, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_adc16_immediate(op_7FFF, $0002, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_adc16_immediate(op_FFFE, $0002, result)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_adc16_immediate(op_FFFE, $0001, result)

    wait_and_clear_at_row(row)
}



/////////////////////////////////////////////////////////////////////////////
// wait for key then clear screen when its detected
.macro wait_and_clear_at_row(init_row)
{
    .var row = init_row
    .eval row++
    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_string_basic(hit_anykey_str)

    nv_screen_wait_anykey()

    nv_screen_clear()
    .eval row=0
    nv_screen_plot_cursor(row++, 33)
    nv_screen_print_string_basic(title_str)
}


//////////////////////////////////////////////////////////////////////////////
//                          Print macros 
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// inline macro to print the specified addition at the current curor location
// nv_adc16 us used to do the addition.  
// it will look like this with no carry:
//    $2222 + $3333 = $5555
// or look like this if there is a carry:
//    $FFFF + $0001 = (C) $0000
.macro print_adc16(op1, op2, result)
{
    nv_screen_print_hex_word(op1, true)
    nv_screen_print_string_basic(plus_str)
    nv_screen_print_hex_word(op2, true)
    nv_screen_print_string_basic(equal_str)

    nv_adc16(op1, op2, result)
    bcc NoCarry
    nv_screen_print_string_basic(carry_str)
NoCarry:
    nv_screen_print_hex_word(result, true)
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to print the specified addition at the current curor location
// nv_adc16 us used to do the addition.  
// it will look like this with no carry:
//    $2222 + $3333 = $5555
// or look like this if there is a carry:
//    $FFFF + $0001 = (C) $0000
.macro print_adc16_8(op16, op8, result)
{
    nv_screen_print_hex_word(op16, true)
    nv_screen_print_string_basic(plus_str)
    nv_screen_print_hex_byte_at_addr(op8, true)
    nv_screen_print_string_basic(equal_str)

    nv_adc16_8(op16, op8, result)
    bcc NoCarry
    nv_screen_print_string_basic(carry_str)
NoCarry:
    nv_screen_print_hex_word(result, true)
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to print the specified addition at the current curor location
// nv_adc16_immediate us used to do the addition.  
// it will look like this with no carry:
//    $2222 + $3333 = $5555
// or look like this if there is a carry:
//    $FFFF + $0001 = (C) $0000
.macro print_adc16_immediate(op1, num, result)
{
    nv_screen_print_hex_word(op1, true)
    nv_screen_print_string_basic(plus_str)
    nv_screen_print_hex_word_immediate(num, true)
    nv_screen_print_string_basic(equal_str)

    nv_adc16_immediate(op1, num, result)
    bcc NoCarry
    nv_screen_print_string_basic(carry_str)
NoCarry:
    nv_screen_print_hex_word(result, true)
}

