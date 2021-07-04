// This sample shows how to do 16bit operations such as add, subtract, and compare

// import all nv_c64_util macros and data.  The data
// will go in default place
#import "../nv_c64_util/nv_c64_util_macs_and_data.asm"

//#import "../nv_c64_util/nv_c64_util_macs.asm"
//#import "../nv_c64_util/nv_debug_macs.asm"

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
//bit_str: .text @" BIT \$00"
//negated_str: .text @" NEGATED \$00"
equal_str: .text@" = \$00"

title_str: .text @"DEBUG\$00"          // null terminated string to print
                                       // via the BASIC routine
title_debug_print_byte_str: .text @"TEST DEBUG PRINT BYTE\$00"
title_debug_print_str_str: .text @"TEST DEBUG PRINT STR\$00"
title_debug_print_byte_a_str: .text @"TEST DEBUG PRINT BYTE_A\$00"
title_debug_print_byte_immediate_str: .text @"TEST DEBUG PRINT BYTE IMMED\$00"

direct1_str: .text  @"nps0123\$00"  // null terminated string to print
direct2_str: .text  @"abc 123\$00"  // null terminated string to print
direct3_str: .text  @"123 =+-<>\$00"  // null terminated string to print

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
op_FFFF: .word $FFFF // all bits

op8_7F: .byte $7F
op8_FF: .byte $FF
op8_0F: .byte $0F
op8_F0: .byte $F0
op8_80: .byte $80  // -128
op8_81: .byte $81  // -127

op_00: .byte $00
op_01: .byte $01
op_02: .byte $02
op_03: .byte $03
op_04: .byte $04
op_05: .byte $05
op_06: .byte $06
op_07: .byte $07


*=$1000 "Main Start"

.var row = 0

    nv_screen_clear()
    nv_screen_plot_cursor(row++, 33)
    nv_screen_print_string_basic(title_str)

    test_debug_print_str(0)
    test_debug_print_byte(0)
    //test_debug_print_byte_a(0)
    //test_debug_print_byte_immediate(0)

    nv_screen_clear()
    rts



//////////////////////////////////////////////////////////////////////////////
//
.macro test_debug_print_str(init_row)
{
    .var row = init_row
    
    //////////////////////////////////////////////////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_string_basic(title_debug_print_str_str)
    //////////////////////////////////////////////////////////////////////////
    .eval row++

    /////////////////////////////
    print_debug_print_str(direct1_str, row++)

    /////////////////////////////
    print_debug_print_str(direct2_str, row++)

    /////////////////////////////
    print_debug_print_str(direct3_str, row++)

    nv_screen_plot_cursor(row, 0)
    
    wait_and_clear_at_row(row)

}

//////////////////////////////////////////////////////////////////////////////
//
.macro test_debug_print_byte(init_row)
{
    .var row = init_row
    
    //////////////////////////////////////////////////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_string_basic(title_debug_print_byte_str)
    //////////////////////////////////////////////////////////////////////////
    .eval row++

    /////////////////////////////
    nv_screen_plot_cursor(row, 0)
    print_debug_print_byte(op_00, row++)

    /////////////////////////////
    nv_screen_plot_cursor(row, 0)
    print_debug_print_byte(op1Beef, row++)

    /////////////////////////////
    nv_screen_plot_cursor(row, 0)
    print_debug_print_byte(op8_7F, row++)

    /////////////////////////////
    nv_screen_plot_cursor(row, 0)
    print_debug_print_byte(op8_FF, row++)

    /////////////////////////////
    nv_screen_plot_cursor(row, 0)
    print_debug_print_byte(op_01, row++)

    /////////////////////////////
    nv_screen_plot_cursor(row, 0)
    print_debug_print_byte(op8_80, row++)


    wait_and_clear_at_row(row)
}
/*
//////////////////////////////////////////////////////////////////////////////
//
.macro test_mask_from_bit_num_a(init_row)
{
    .var row = init_row
    
    //////////////////////////////////////////////////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_string_basic(title_mask_from_bit_num_a_str)
    //////////////////////////////////////////////////////////////////////////
    .eval row++

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_mask_from_bit_num_mem(op_00)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_mask_from_bit_num_mem(op_01)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_mask_from_bit_num_mem(op_02)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_mask_from_bit_num_mem(op_03)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_mask_from_bit_num_mem(op_04)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_mask_from_bit_num_mem(op_05)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_mask_from_bit_num_mem(op_06)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_mask_from_bit_num_mem(op_07)

    wait_and_clear_at_row(row)
}
*/


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
// inline macro to print the a string to the screen via 
// nv_debug_print_str macro
// 
// 
.macro print_debug_print_str(str, row)
{
    nv_screen_poke_string(row, 0, str)
    //nv_screen_print_string_basic(equal_str)
    nv_debug_print_str(row, 20, str, true)
    //nv_debug_print_byte(row, 6, op1, true, true)
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to print the byte value and then use the debug
// function to print the same value 
// 
.macro print_debug_print_byte(op1, row)
{
    nv_screen_print_hex_byte_at_addr(op1, true)
    nv_screen_print_string_basic(equal_str)

    nv_debug_print_byte(row, 6, op1, true, true)
}

/*
//////////////////////////////////////////////////////////////////////////////
// inline macro to print the specified mask from bit number operation
// at the current cursor location
// nv_mask_from_bit_num is used to do the operation.  
// it will look like this
//    BIT $00 = MASK $01
//    BIT $01 = MASK $02
.macro print_mask_from_bit_num_a(op1)
{
    nv_screen_print_string_basic(bit_str)
    nv_screen_print_hex_byte_at_addr(op1, true)
    nv_screen_print_string_basic(equal_str)
    //nv_screen_print_string_basic(mask_str)
    lda op1
    nv_mask_from_bit_num_a(false)
    nv_screen_print_hex_byte(true)

    nv_screen_print_string_basic(negated_str)
    lda op1
    nv_mask_from_bit_num_a(true)
    nv_screen_print_hex_byte(true)

}

*/