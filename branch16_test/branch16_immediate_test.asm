//////////////////////////////////////////////////////////////////////////////
// branch16_immediate_test.asm
// Copyright(c) 2021 Neal Smith.
// License: MIT. See LICENSE file in root directory.
//////////////////////////////////////////////////////////////////////////////
// This program demonstrates and tests the 16 bit conditional macros 
// with immediate values in the nv_branch16_macs.asm

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
equal_str: .text@" = \$00"
not_equal_str: .text@" != \$00"
greater_equal_str: .text@" >= \$00" 
less_than_str: .text@" < \$00"
greater_than_str: .text@" > \$00"
less_equal_str: .text@" <= \$00" 

title_str: .text @"BRANCH16 IMMED\$00"          // null terminated string to print
                                        // via the BASIC routine
title_cmp16_immediate_str: .text @"TEST CMP16 IMMED\$00"
title_beq16_immediate_str: .text @"TEST BEQ16 IMMED\$00"
title_bne16_immediate_str: .text @"TEST BNE16 IMMED\$00"
title_blt16_immediate_str: .text @"TEST BLT16 IMMED\$00"
title_ble16_immediate_str: .text @"TEST BLE16 IMMED\$00"
title_bgt16_immediate_str: .text @"TEST BGT16 IMMED\$00"
title_bge16_immediate_str: .text @"TEST BGE16 IMMED\$00"

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


*=$1000 "Main Start"

.var row = 0

    nv_screen_clear()
    nv_screen_plot_cursor(row++, 25)
    nv_screen_print_str(title_str)

    test_cmp16_immediate(0)
    test_beq16_immediate(0)
    test_blt16_immediate(0)
    test_ble16_immediate(0)
    test_bgt16_immediate(0)
    test_bge16_immediate(0)

    rts


//////////////////////////////////////////////////////////////////////////////
// Test the cmp_16 macro
.macro test_cmp16_immediate(init_row)
{
    .var row = init_row

    //////////////////////////////////////////////////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_str(title_cmp16_immediate_str)
    //////////////////////////////////////////////////////////////////////////
    .eval row++

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_cmp16_immediate(op1Beef, $BEEF)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_cmp16_immediate(opSmall, $D3B0)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_cmp16_immediate(opZero, $0000)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_cmp16_immediate(opMax, $FFFF)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_cmp16_immediate(opTwo, $0001)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_cmp16_immediate(opTwo, $0002)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_cmp16_immediate(opOne, $0002)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_cmp16_immediate(opOne, $0001)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_cmp16_immediate(opMax, $0000)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_cmp16_immediate(opMax, $FFFE)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_cmp16_immediate(opHighOnes, $FFFF)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_cmp16_immediate(opHighOnes, $FF00)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_cmp16_immediate(opHighOnes, $FF01)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_cmp16_immediate(opLowOnes, $FF01)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_cmp16_immediate(opLowOnes, $01FF)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_cmp16_immediate(opLowOnes, $FF00)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_cmp16_immediate(opLowOnes, $FE)

    wait_and_clear_at_row(row)
}


//////////////////////////////////////////////////////////////////////////////
//
.macro test_beq16_immediate(init_row)
{
    .var row = init_row

    //////////////////////////////////////////////////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_str(title_beq16_immediate_str)
    //////////////////////////////////////////////////////////////////////////
    .eval row++

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_beq16_immediate(opSmall, $BEEF)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_beq16_immediate(op1Beef, $BEEF)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_beq16_immediate(op1Beef, $BEEF)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_beq16_immediate(opSmall, $D3B0)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_beq16_immediate(opZero, $0000)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_beq16_immediate(opMax, $FFFF)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_beq16_immediate(opTwo, $0001)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_beq16_immediate(opTwo, $0002)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_beq16_immediate(opOne, $0002)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_beq16_immediate(opOne, $0001)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_beq16_immediate(opMax, $0000)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_beq16_immediate(opMax, $FFFE)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_beq16_immediate(opHighOnes, $FFFF)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_beq16_immediate(opHighOnes, $FF00)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_beq16_immediate(opHighOnes, $FF01)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_beq16_immediate(opLowOnes, $FF01)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_beq16_immediate(opLowOnes, $01FF)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_beq16_immediate(opLowOnes, $FF00)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_beq16_immediate(opLowOnes, $FE)


    wait_and_clear_at_row(row)
}


//////////////////////////////////////////////////////////////////////////////
//
.macro test_blt16_immediate(init_row)
{
    .var row = init_row

    //////////////////////////////////////////////////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_str(title_blt16_immediate_str)
    //////////////////////////////////////////////////////////////////////////
    .eval row++

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_blt16_immediate(opSmall, $BEEF)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_blt16_immediate(op1Beef, $BEEF)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_blt16_immediate(op1Beef, $BEEF)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_blt16_immediate(opSmall, $D3B0)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_blt16_immediate(opZero, $0000)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_blt16_immediate(opMax, $FFFF)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_blt16_immediate(opTwo, $0001)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_blt16_immediate(opTwo, $0002)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_blt16_immediate(opOne, $0002)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_blt16_immediate(opOne, $0001)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_blt16_immediate(opMax, $0000)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_blt16_immediate(opMax, $FFFE)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_blt16_immediate(opHighOnes, $FFFF)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_blt16_immediate(opHighOnes, $FF00)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_blt16_immediate(opHighOnes, $FF01)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_blt16_immediate(opLowOnes, $FF01)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_blt16_immediate(opLowOnes, $01FF)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_blt16_immediate(opLowOnes, $FF00)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_blt16_immediate(opLowOnes, $FE)


    wait_and_clear_at_row(row)
}


//////////////////////////////////////////////////////////////////////////////
//
.macro test_ble16_immediate(init_row)
{
    .var row = init_row

    //////////////////////////////////////////////////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_str(title_ble16_immediate_str)
    //////////////////////////////////////////////////////////////////////////
    .eval row++

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_ble16_immediate(opSmall, $BEEF)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_ble16_immediate(op1Beef, $BEEF)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_ble16_immediate(op1Beef, $BEEF)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_ble16_immediate(opSmall, $D3B0)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_ble16_immediate(opZero, $0000)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_ble16_immediate(opMax, $FFFF)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_ble16_immediate(opTwo, $0001)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_ble16_immediate(opTwo, $0002)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_ble16_immediate(opOne, $0002)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_ble16_immediate(opOne, $0001)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_ble16_immediate(opMax, $0000)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_ble16_immediate(opMax, $FFFE)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_ble16_immediate(opHighOnes, $FFFF)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_ble16_immediate(opHighOnes, $FF00)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_ble16_immediate(opHighOnes, $FF01)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_ble16_immediate(opLowOnes, $FF01)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_ble16_immediate(opLowOnes, $01FF)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_ble16_immediate(opLowOnes, $FF00)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_ble16_immediate(opLowOnes, $FE)


    wait_and_clear_at_row(row)
}


//////////////////////////////////////////////////////////////////////////////
//
.macro test_bgt16_immediate(init_row)
{
    .var row = init_row

    //////////////////////////////////////////////////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_str(title_bgt16_immediate_str)
    //////////////////////////////////////////////////////////////////////////
    .eval row++

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bgt16_immediate(opSmall, $BEEF)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bgt16_immediate(op1Beef, $BEEF)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bgt16_immediate(op1Beef, $BEEF)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bgt16_immediate(opSmall, $D3B0)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bgt16_immediate(opZero, $0000)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bgt16_immediate(opMax, $FFFF)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bgt16_immediate(opTwo, $0001)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bgt16_immediate(opTwo, $0002)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bgt16_immediate(opOne, $0002)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bgt16_immediate(opOne, $0001)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bgt16_immediate(opMax, $0000)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bgt16_immediate(opMax, $FFFE)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bgt16_immediate(opHighOnes, $FFFF)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bgt16_immediate(opHighOnes, $FF00)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bgt16_immediate(opHighOnes, $FF01)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bgt16_immediate(opLowOnes, $FF01)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bgt16_immediate(opLowOnes, $01FF)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bgt16_immediate(opLowOnes, $FF00)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bgt16_immediate(opLowOnes, $FE)

    wait_and_clear_at_row(row)
}


//////////////////////////////////////////////////////////////////////////////
//
.macro test_bge16_immediate(init_row)
{
    .var row = init_row

    //////////////////////////////////////////////////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_str(title_bge16_immediate_str)
    //////////////////////////////////////////////////////////////////////////
    .eval row++

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bge16_immediate(opSmall, $BEEF)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bge16_immediate(op1Beef, $BEEF)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bge16_immediate(op1Beef, $BEEF)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bge16_immediate(opSmall, $D3B0)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bge16_immediate(opZero, $0000)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bge16_immediate(opMax, $FFFF)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bge16_immediate(opTwo, $0001)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bge16_immediate(opTwo, $0002)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bge16_immediate(opOne, $0002)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bge16_immediate(opOne, $0001)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bge16_immediate(opMax, $0000)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bge16_immediate(opMax, $FFFE)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bge16_immediate(opHighOnes, $FFFF)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bge16_immediate(opHighOnes, $FF00)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bge16_immediate(opHighOnes, $FF01)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bge16_immediate(opLowOnes, $FF01)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bge16_immediate(opLowOnes, $01FF)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bge16_immediate(opLowOnes, $FF00)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bge16_immediate(opLowOnes, $FE)

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
    nv_screen_plot_cursor(row++, 25)
    nv_screen_print_str(title_str)
}


//////////////////////////////////////////////////////////////////////////////
//                          Print macros 
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// Print a comparison of a 16bit value in memory and an immediate value. 
// Prints at the current cursor location via a basic call
.macro print_cmp16_immediate(addr1, num)
{
    nv_screen_print_hex_word_mem(addr1, true)
    nv_cmp16_immediate(addr1, num)
    bne NotEq
// Equal here
    nv_screen_print_str(equal_str)
    jmp PrintOp2

NotEq:
    bcs GreaterOrEqual
// less than here
    nv_screen_print_str(less_than_str)
    jmp PrintOp2

// Greater here
GreaterOrEqual:
    nv_screen_print_str(greater_than_str)

PrintOp2:
    nv_screen_print_hex_word_immed(num, true)

}


//////////////////////////////////////////////////////////////////////////////
// Print to current screen location the expression (either = or != ) 
// for the relationship of one word in memory with an immediate 16 bit value
// Also use beq16 to do it.
//   addr1: is the address of LSB of one word (addr1+1 is MSB)
//   num: is the immediate value
.macro print_beq16_immediate(addr1, num)
{
    nv_screen_print_hex_word_mem(addr1, true)
    nv_beq16_immediate(addr1, num, Same)
    nv_screen_print_str(not_equal_str)
    jmp Done
Same:
    nv_screen_print_str(equal_str)

Done:
    nv_screen_print_hex_word_immed(num, true)
}



//////////////////////////////////////////////////////////////////////////////
.macro print_blt16_immediate(addr1, num)
{
    nv_screen_print_hex_word_mem(addr1, true)
    nv_blt16_immediate(addr1, num, LessThan)
    nv_screen_print_str(greater_equal_str)
    jmp Done
LessThan:
    nv_screen_print_str(less_than_str)

Done:
    nv_screen_print_hex_word_immed(num, true)

}


//////////////////////////////////////////////////////////////////////////////
.macro print_ble16_immediate(addr1, num)
{
    nv_screen_print_hex_word_mem(addr1, true)
    nv_ble16_immediate(addr1, num, LessEqual)
    nv_screen_print_str(greater_than_str)
    jmp Done
LessEqual:
    nv_screen_print_str(less_equal_str)

Done:
    nv_screen_print_hex_word_immed(num, true)

}

//////////////////////////////////////////////////////////////////////////////
.macro print_bgt16_immediate(addr1, num)
{
    nv_screen_print_hex_word_mem(addr1, true)
    nv_bgt16_immediate(addr1, num, GreaterThan)
    nv_screen_print_str(less_equal_str)
    jmp Done
GreaterThan:
    nv_screen_print_str(greater_than_str)

Done:
    nv_screen_print_hex_word_immed(num, true)
}


//////////////////////////////////////////////////////////////////////////////
.macro print_bge16_immediate(addr1, num)
{
    nv_screen_print_hex_word_mem(addr1, true)
    nv_bge16_immediate(addr1, num, GreaterEqual)
    nv_screen_print_str(less_than_str)
    jmp Done
GreaterEqual:
    nv_screen_print_str(greater_equal_str)

Done:
    nv_screen_print_hex_word_immed(num, true)
}
