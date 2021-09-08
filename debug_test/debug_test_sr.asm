//////////////////////////////////////////////////////////////////////////////
// debug_test_sr.asm
// Copyright(c) 2021 Neal Smith.
// License: MIT. See LICENSE file in root directory.
//////////////////////////////////////////////////////////////////////////////
// This program tests the debug subroutines in nv_debug_code.asm
//

// import all nv_c64_util macros and data.  The data
// will go in default place
#import "../../nv_c64_util/nv_c64_util_macs_and_data.asm"
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

title_str: .text @"DEBUG SR\$00"          // null terminated string to print
                                       // via the BASIC routine
title_debug_print_byte_str: .text @"TEST DBG PRINT BYTE SR\$00"
title_debug_print_word_str: .text @"TEST DBG PRINT WORD SR\$00"
title_debug_print_str_str: .text @"TEST DBG PRINT STR SR\$00"
title_debug_print_labeled_byte_str: .text @"TEST DBG PRINT LABEL BYTE SR\$00"
title_debug_print_labeled_word_str: .text @"TEST DBG PRINT LABEL WORD SR\$00"


direct0_str: .text  @"abc\$00"  // null terminated string to print
direct1_str: .text  @"nps123\$00"  // null terminated string to print
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

op_7FFF_label_str: .text  @"op16 7fff:\$00"
op_FFFE_label_str: .text  @"op16 7ffe:\$00"
op_0080_label_str: .text  @"op16 0080:\$00"
op_0081_label_str: .text  @"op16 0081:\$00"
op_8000_label_str: .text  @"op16 8000:\$00"
op_FFFF_label_str: .text  @"op16 ffff:\$00"



op8_7F_label_str: .text  @"op8 7f:\$00"
op8_FF_label_str: .text  @"op8 ff:\$00"
op8_0F_label_str: .text  @"op8 0f:\$00"
op8_F0_label_str: .text  @"op8 f0:\$00"
op8_80_label_str: .text  @"op8 80:\$00"
op8_81_label_str: .text  @"op8 81:\$00"


op8_7F: .byte $7F
op8_FF: .byte $FF
op8_0F: .byte $0F
op8_F0: .byte $F0
op8_80: .byte $80  // -128
op8_81: .byte $81  // -127

op_00_label_str: .text  @"op 00:\$00"  // null terminated string to print
op_01_label_str: .text  @"op 01:\$00"  // null terminated string to print
op_02_label_str: .text  @"op 02:\$00"  // null terminated string to print
op_03_label_str: .text  @"op 03:\$00"  // null terminated string to print
op_04_label_str: .text  @"op 04:\$00"  // null terminated string to print
op_05_label_str: .text  @"op 05:\$00"  // null terminated string to print
op_06_label_str: .text  @"op 06:\$00"  // null terminated string to print
op_07_label_str: .text  @"op 07:\$00"  // null terminated string to print

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

    nv_screen_plot_cursor(row++, 32)
    nv_screen_print_str(title_str)

    test_debug_print_str(0)
    test_debug_print_byte(0)
    test_debug_print_word(0)
    test_debug_print_labeled_byte(0)
    test_debug_print_labeled_word(0)
    
    nv_screen_clear()
    rts



//////////////////////////////////////////////////////////////////////////////
//
.macro test_debug_print_str(init_row)
{
    .var row = init_row
    
    //////////////////////////////////////////////////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_str(title_debug_print_str_str)
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
    nv_screen_print_str(title_debug_print_byte_str)
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

//////////////////////////////////////////////////////////////////////////////
//
.macro test_debug_print_word(init_row)
{
    .var row = init_row
    
    //////////////////////////////////////////////////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_str(title_debug_print_word_str)
    //////////////////////////////////////////////////////////////////////////
    .eval row++

    /////////////////////////////
    nv_screen_plot_cursor(row, 0)
    print_debug_print_word(op_0080, row++)
    
    /////////////////////////////
    nv_screen_plot_cursor(row, 0)
    print_debug_print_word(op_0081, row++)

    wait_and_clear_at_row(row)
}


//////////////////////////////////////////////////////////////////////////////
//
.macro test_debug_print_labeled_byte(init_row)
{
    .var row = init_row
    
    //////////////////////////////////////////////////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_str(title_debug_print_labeled_byte_str)
    //////////////////////////////////////////////////////////////////////////
    .eval row++

    /////////////////////////////
    print_debug_print_labeled_byte(op_00_label_str, op_00, row++)

    /////////////////////////////
    print_debug_print_labeled_byte(op_01_label_str, op_01, row++)

    /////////////////////////////
    print_debug_print_labeled_byte(op_02_label_str, op_02, row++)

    /////////////////////////////
    print_debug_print_labeled_byte(op_03_label_str, op_03, row++)

    /////////////////////////////
    print_debug_print_labeled_byte(op_04_label_str, op_04, row++)

    /////////////////////////////
    print_debug_print_labeled_byte(op_05_label_str, op_05, row++)

    /////////////////////////////
    print_debug_print_labeled_byte(op_06_label_str, op_06, row++)

    /////////////////////////////
    print_debug_print_labeled_byte(op_07_label_str, op_07, row++)

    /////////////////////////////
    print_debug_print_labeled_byte(op8_7F_label_str, op8_7F, row++)

    /////////////////////////////
    print_debug_print_labeled_byte(op8_FF_label_str, op8_FF, row++)

    /////////////////////////////
    print_debug_print_labeled_byte(op8_0F_label_str, op8_0F, row++)

    /////////////////////////////
    print_debug_print_labeled_byte(op8_F0_label_str, op8_F0, row++)

    /////////////////////////////
    print_debug_print_labeled_byte(op8_80_label_str, op8_80, row++)

    /////////////////////////////
    print_debug_print_labeled_byte(op8_81_label_str, op8_81, row++)


    wait_and_clear_at_row(row)
}

//////////////////////////////////////////////////////////////////////////////
//
.macro test_debug_print_labeled_word(init_row)
{
    .var row = init_row
    
    //////////////////////////////////////////////////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_str(title_debug_print_labeled_word_str)
    //////////////////////////////////////////////////////////////////////////
    .eval row++

/*
op_0080_label_str: .text  @"op8 0080\$00"
op_0081_label_str: .text  @"op8 0081\$00"
op_8000_label_str: .text  @"op8 8000\$00"
op_FFFF_label_str: .text  @"op8 ffff\$00"

*/

    /////////////////////////////
    print_debug_print_labeled_word(op_7FFF_label_str, op_7FFF, row++)

    /////////////////////////////
    print_debug_print_labeled_word(op_FFFE_label_str, op_FFFE, row++)

    /////////////////////////////
    print_debug_print_labeled_word(op_0080_label_str, op_0080, row++)

    /////////////////////////////
    print_debug_print_labeled_word(op_0081_label_str, op_0081, row++)

    /////////////////////////////
    print_debug_print_labeled_word(op_8000_label_str, op_8000, row++)

    /////////////////////////////
    print_debug_print_labeled_word(op_FFFF_label_str, op_FFFF, row++)


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
    nv_screen_plot_cursor(row++, 32)
    nv_screen_print_str(title_str)
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

    // print the string with macro version
    nv_screen_poke_str(row, 0, str)

    // setup the params for the subroutine version as follows:
    //   nv_a8: row position on screen to print at
    //   nv_b8: col position on screen to print at
    //   nv_a16: the address of the first char of label string.
    //           this string must be zero terminated.
    //   nv_e8: pass true to wait for a key after printing

    // put row param in nv_a8
    lda #row
    sta nv_a8

    // put col param in nv_b8 (print at col 20)
    lda #20 
    sta nv_b8

    // put pointer to string to print in nv_a16
    lda #<str
    sta nv_a16
    lda #>str 
    sta nv_a16+1

    // put wait param in nv_d8
    lda #0
    sta nv_e8 

    // call our routine
    jsr NvDebugPrintStr
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to print the byte value and then use the debug
// function to print the same value 
// 
.macro print_debug_print_byte(op1, row)
{
    nv_screen_print_hex_byte_mem(op1, true)
    nv_screen_print_str(equal_str)

    // setup the params for the subroutine version as follows:
    //   nv_a8: row position on screen to print at
    //   nv_b8: col position on screen to print at
    //   nv_c8: the byte in to print.
    //   nv_d8: set to 1 to include dollar sign
    //   nv_e8: pass true to wait for a key after printing

    // put row param in nv_a8
    lda #row
    sta nv_a8

    // put col param in nv_b8 (print at col 6)
    lda #6
    sta nv_b8

    // Byte to print in nv_c8
    lda op1
    sta nv_c8

    // put wait param in nv_d8
    lda #0
    sta nv_d8 

    // call our routine
    jsr NvDebugPrintByte
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to print the byte value and then use the debug
// function to print the same value 
// 
.macro print_debug_print_word(op1, row)
{
    nv_screen_print_hex_word_mem(op1, true)
    nv_screen_print_str(equal_str)

    // setup the params for the subroutine version as follows:
    //   nv_a8: row position on screen to print at
    //   nv_b8: col position on screen to print at
    //   nv_c16: the word in to print.
    //   nv_d8: set to 1 to include dollar sign
    //   nv_e8: pass true to wait for a key after printing

    // put row param in nv_a8
    lda #row
    sta nv_a8

    // put col param in nv_b8 (print at col 6)
    lda #8
    sta nv_b8

    // word to print in nv_c16
    lda op1
    sta nv_c16
    lda op1+1
    sta nv_c16+1

    // put wait param in nv_d8
    lda #1
    sta nv_d8 

    // call our routine
    jsr NvDebugPrintWord
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to print a label along with a byte value and use
// the nv_debug_print_labeled_byte macro to do it.
// 
.macro print_debug_print_labeled_byte(label_addr, value_addr, row)
{

    //   nv_a8: row position on screen to print at
    //   nv_b8: col position on screen to print at
    //   nv_a16: the address of the first char of label string.
    //           this string must be zero terminated.
    //   nv_c8: The byte to print
    //   nv_d8: pass 1 for preceding '$'
    //   nv_e8: pass true to wait for a key after printing


    // put row param in nv_a8
    lda #row
    sta nv_a8

    // put col param in nv_b8 (print at col 20)
    lda #0
    sta nv_b8

    // put byte to print in nv_c8
    lda value_addr
    sta nv_c8

    // put pointer to string to print in nv_a16
    lda #<label_addr
    sta nv_a16
    lda #>label_addr 
    sta nv_a16+1

    // put a preceding dollar sign
    lda #1 
    sta nv_d8

    // put a 1 to wait or 0 not to.
    lda #0
    sta nv_e8 

    // call our routine
    jsr NvDebugPrintLabeledByte

    //nv_debug_print_labeled_byte(row, 0, label_addr, value_addr, true, true)
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to print a label along with a word value and use
// the nv_debug_print_labeled_word macro to do it.
// 
.macro print_debug_print_labeled_word(label_addr, value_addr, row)
{

    //   nv_a8: row position on screen to print at
    //   nv_b8: col position on screen to print at
    //   nv_a16: the address of the first char of label string.
    //           this string must be zero terminated.
    //   nv_c16: The address of the byte that holds the value to print
    //   nv_d8: pass 1 for preceding '$'
    //   nv_e8: pass true to wait for a key after printing


    // put row param in nv_a8
    lda #row
    sta nv_a8

    // put col param in nv_b8 (print at col 20)
    lda #0
    sta nv_b8

    // put word to print in nv_c16
    lda value_addr
    sta nv_c16
    lda value_addr+1
    sta nv_c16+1

    // put pointer to string to print in nv_a16
    lda #<label_addr
    sta nv_a16
    lda #>label_addr 
    sta nv_a16+1

    // put a preceding dollar sign
    lda #1 
    sta nv_d8

    // put a 1 to wait or 0 not to.
    lda #0
    sta nv_e8 

    // call our routine
    jsr NvDebugPrintLabeledWord

    //nv_debug_print_labeled_byte(row, 0, label_addr, value_addr, true, true)
}


#import "../../nv_c64_util/nv_debug_code.asm"
