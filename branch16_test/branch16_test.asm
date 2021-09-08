//////////////////////////////////////////////////////////////////////////////
// branch16_test.asm
// Copyright(c) 2021 Neal Smith.
// License: MIT. See LICENSE file in root directory.
//////////////////////////////////////////////////////////////////////////////
// This program demonstrates and tests the 16bit branch operations 
// in nv_branch16_macs.asm

// import all nv_c64_util macros and data.  The data
// will go in default place
#import "../../nv_c64_util/nv_c64_util_macs_and_data.asm"

//#import "../../nv_c64_util/nv_screen_macs.asm"
//#import "../../nv_c64_util/nv_keyboard_macs.asm"

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

title_str: .text @"BRANCH16\$00"          // null terminated string to print
                                        // via the BASIC routine
title_cmp16_str: .text @"TEST CMP16 \$00"
title_beq16_str: .text @"TEST BEQ16 \$00"
title_bne16_str: .text @"TEST BNE16 \$00"
title_blt16_str: .text @"TEST BLT16 \$00"
title_ble16_str: .text @"TEST BLE16 \$00"
title_bgt16_str: .text @"TEST BGT16 \$00"
title_bge16_str: .text @"TEST BGE16 \$00"

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
    nv_screen_plot_cursor(row++, 31)
    nv_screen_print_str(title_str)

    test_cmp16(0)
    test_beq16(0)
    test_blt16(0)
    test_ble16(0)
    test_bgt16(0)
    test_bge16(0)

    rts


//////////////////////////////////////////////////////////////////////////////
// Test the cmp_16 macro
.macro test_cmp16(init_row)
{
    .var row = init_row

    //////////////////////////////////////////////////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_str(title_cmp16_str)
    //////////////////////////////////////////////////////////////////////////
    .eval row++

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_cmp16(op1Beef, op2Beef)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_cmp16(opSmall, opBig)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_cmp16(opBig, opSmall)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_cmp16(opSmall, opSmall)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_cmp16(opBig, opSmall)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_cmp16(opTwo, opOne)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_cmp16(opOne, opZero)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_cmp16(opOne, opMax)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_cmp16(opZero, opMax)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_cmp16(opZero, opOne)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_cmp16(opMax, opOne)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_cmp16(opMax, opZero)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_cmp16(opMax, opMax)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_cmp16(opOne, opOne)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_cmp16(opZero, opZero)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_cmp16(opHighOnes, opLowOnes)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_cmp16(opLowOnes, opHighOnes)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_cmp16(opHighOnes, opHighOnes)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_cmp16(opLowOnes, opLowOnes)


    wait_and_clear_at_row(row)
}


//////////////////////////////////////////////////////////////////////////////
//
.macro test_beq16(init_row)
{
    .var row = init_row

    //////////////////////////////////////////////////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_str(title_beq16_str)
    //////////////////////////////////////////////////////////////////////////
    .eval row++

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_beq16(op1Beef, op2Beef)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_beq16(opSmall, opBig)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_beq16(opBig, opSmall)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_beq16(opSmall, opSmall)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_beq16(opBig, opSmall)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_beq16(opTwo, opOne)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_beq16(opOne, opZero)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_beq16(opOne, opMax)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_beq16(opZero, opMax)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_beq16(opZero, opOne)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_beq16(opMax, opOne)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_beq16(opMax, opZero)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_beq16(opMax, opMax)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_beq16(opOne, opOne)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_beq16(opZero, opZero)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_beq16(opHighOnes, opLowOnes)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_beq16(opLowOnes, opHighOnes)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_beq16(opHighOnes, opHighOnes)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_beq16(opLowOnes, opLowOnes)

    wait_and_clear_at_row(row)
}


//////////////////////////////////////////////////////////////////////////////
//
.macro test_blt16(init_row)
{
    .var row = init_row
        
    //////////////////////////////////////////////////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_str(title_blt16_str)
    //////////////////////////////////////////////////////////////////////////
    .eval row++

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_blt16(op1Beef, op2Beef)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_blt16(opSmall, opBig)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_blt16(opBig, opSmall)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_blt16(opSmall, opSmall)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_blt16(opBig, opSmall)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_blt16(opTwo, opOne)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_blt16(opOne, opZero)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_blt16(opOne, opMax)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_blt16(opZero, opMax)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_blt16(opZero, opOne)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_blt16(opMax, opOne)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_blt16(opMax, opZero)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_blt16(opMax, opMax)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_blt16(opOne, opOne)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_blt16(opZero, opZero)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_blt16(opHighOnes, opLowOnes)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_blt16(opLowOnes, opHighOnes)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_blt16(opHighOnes, opHighOnes)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_blt16(opLowOnes, opLowOnes)

    wait_and_clear_at_row(row)
}


.macro test_ble16(init_row)
{
    .var row = init_row

    //////////////////////////////////////////////////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_str(title_ble16_str)
    //////////////////////////////////////////////////////////////////////////
    .eval row++

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_ble16(op1Beef, op2Beef)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_ble16(opSmall, opBig)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_ble16(opBig, opSmall)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_ble16(opSmall, opSmall)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_ble16(opBig, opSmall)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_ble16(opTwo, opOne)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_ble16(opOne, opZero)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_ble16(opOne, opMax)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_ble16(opZero, opMax)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_ble16(opZero, opOne)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_ble16(opMax, opOne)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_ble16(opMax, opZero)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_ble16(opMax, opMax)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_ble16(opOne, opOne)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_ble16(opZero, opZero)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_ble16(opHighOnes, opLowOnes)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_ble16(opLowOnes, opHighOnes)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_ble16(opHighOnes, opHighOnes)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_ble16(opLowOnes, opLowOnes)

    wait_and_clear_at_row(row)
}


//////////////////////////////////////////////////////////////////////////////
//
.macro test_bgt16(init_row)
{
    .var row = init_row

    //////////////////////////////////////////////////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_str(title_bgt16_str)
    //////////////////////////////////////////////////////////////////////////
    .eval row++

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bgt16(op1Beef, op2Beef)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bgt16(opSmall, opBig)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bgt16(opBig, opSmall)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bgt16(opSmall, opSmall)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bgt16(opBig, opSmall)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bgt16(opTwo, opOne)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bgt16(opOne, opZero)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bgt16(opOne, opMax)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bgt16(opZero, opMax)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bgt16(opZero, opOne)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bgt16(opMax, opOne)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bgt16(opMax, opZero)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bgt16(opMax, opMax)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bgt16(opOne, opOne)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bgt16(opZero, opZero)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bgt16(opHighOnes, opLowOnes)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bgt16(opLowOnes, opHighOnes)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bgt16(opHighOnes, opHighOnes)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bgt16(opLowOnes, opLowOnes)

    wait_and_clear_at_row(row)
}


//////////////////////////////////////////////////////////////////////////////
//
.macro test_bge16(init_row)
{
    .var row = init_row

    //////////////////////////////////////////////////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_str(title_bge16_str)
    //////////////////////////////////////////////////////////////////////////
    .eval row++

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bge16(op1Beef, op2Beef)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bge16(opSmall, opBig)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bge16(opBig, opSmall)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bge16(opSmall, opSmall)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bge16(opBig, opSmall)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bge16(opTwo, opOne)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bge16(opOne, opZero)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bge16(opOne, opMax)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bge16(opZero, opMax)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bge16(opZero, opOne)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bge16(opMax, opOne)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bge16(opMax, opZero)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bge16(opMax, opMax)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bge16(opOne, opOne)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bge16(opZero, opZero)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bge16(opHighOnes, opLowOnes)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bge16(opLowOnes, opHighOnes)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bge16(opHighOnes, opHighOnes)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_bge16(opLowOnes, opLowOnes)

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
    nv_screen_plot_cursor(row++, 31)
    nv_screen_print_str(title_str)
}


//////////////////////////////////////////////////////////////////////////////
//                          Print macros 
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// Print a comparison of two 16bit values at two locations in memory. 
// Prints at the current cursor location via a basic call
.macro print_cmp16(addr1, addr2)
{
    nv_screen_print_hex_word_mem(addr1, true)
    nv_cmp16(addr1, addr2)
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
    nv_screen_print_hex_word_mem(addr2, true)

}


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
// for the relationship of the two word in memorys.  Use beq16 to do it.
//   addr1: is the address of LSB of one word (addr1+1 is MSB)
//   addr2: is the address of LSB of the other word (addr2+1 is MSB)
.macro print_beq16(addr1, addr2)
{
    nv_screen_print_hex_word_mem(addr1, true)
    nv_beq16(addr1, addr2, Same)
    nv_screen_print_str(not_equal_str)
    jmp Done
Same:
    nv_screen_print_str(equal_str)

Done:
    nv_screen_print_hex_word_mem(addr2, true)
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
// Print to current screen location the expression (either < or >= ) 
// for the relationship of the two word in memorys.  Use blt16 to do it.
//   addr1: is the address of LSB of word1 (addr1+1 is MSB)
//   addr2: is the address of LSB of word2 (addr2+1 is MSB)
.macro print_blt16(addr1, addr2)
{
    nv_screen_print_hex_word_mem(addr1, true)
    nv_blt16(addr1, addr2, LessThan)
    nv_screen_print_str(greater_equal_str)
    jmp Done
LessThan:
    nv_screen_print_str(less_than_str)

Done:
    nv_screen_print_hex_word_mem(addr2, true)
}



//////////////////////////////////////////////////////////////////////////////
// Print to current screen location the expression (either <= or >)
// for the relationship of the two word in memorys.  Use ble16 to do it.
//   addr1: is the address of LSB of word1 (addr1+1 is MSB)
//   addr2: is the address of LSB of word2 (addr2+1 is MSB)
.macro print_ble16(addr1, addr2)
{
    nv_screen_print_hex_word_mem(addr1, true)
    nv_ble16(addr1, addr2, LessThanEqual)
    nv_screen_print_str(greater_than_str)
    jmp Done
LessThanEqual:
    nv_screen_print_str(less_equal_str)

Done:
    nv_screen_print_hex_word_mem(addr2, true)
}


//////////////////////////////////////////////////////////////////////////////
// Print to current screen location the expression (either > or <= ) 
// for the relationship of the two word in memorys.  Use bgt16 to do it.
//   addr1: is the address of LSB of word1 (addr1+1 is MSB)
//   addr2: is the address of LSB of word2 (addr2+1 is MSB)
.macro print_bgt16(addr1, addr2)
{
    nv_screen_print_hex_word_mem(addr1, true)
    nv_bgt16(addr1, addr2, GreaterThan)
    nv_screen_print_str(less_equal_str)
    jmp Done
GreaterThan:
    nv_screen_print_str(greater_than_str)

Done:
    nv_screen_print_hex_word_mem(addr2, true)
}


//////////////////////////////////////////////////////////////////////////////
// Print to current screen location the expression (either >= or <)
// for the relationship of the two word in memorys.  Use bge16 to do it.
//   addr1: is the address of LSB of word1 (addr1+1 is MSB)
//   addr2: is the address of LSB of word2 (addr2+1 is MSB)
.macro print_bge16(addr1, addr2)
{
    nv_screen_print_hex_word_mem(addr1, true)
    nv_bge16(addr1, addr2, GreaterThanEqual)
    nv_screen_print_str(less_than_str)
    jmp Done
GreaterThanEqual:
    nv_screen_print_str(greater_equal_str)

Done:
    nv_screen_print_hex_word_mem(addr2, true)
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
