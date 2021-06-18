// This sample shows how to do 16bit operations such as add, subtract, and compare


#import "../nv_c64_util/nv_c64_util.asm"

*=$0801 "BASIC Start"  // location to put a 1 line basic program so we can just
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
not_equal_str: .text@" != \$00"
greater_equal_str: .text@" >= \$00" 
less_than_str: .text@" < \$00"
greater_than_str: .text@" > \$00"
less_equal_str: .text@" <= \$00" 

title_str: .text @"MATH16\$00"          // null terminated string to print
                                        // via the BASIC routine
temp_hex_str: .byte 0,0,0,0,0,0         // enough bytes for dollor sign, 4 
                                        // hex digits and a trailing null

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


*=$1000 "Main Start"

.var row = 0

    nv_screen_clear()
    nv_screen_plot_cursor(row++, 16)
    nv_screen_print_string_basic(title_str)

    nv_screen_plot_cursor(row++, 0)
    print_hex_word_immediate($ABCD, true)


    //////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_hex_word(word_to_print, true)
    print_hex_word(another_word, false)

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
    print_cmp16(op1Beef, op2Beef)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_cmp16(opSmall, opBig)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_cmp16(opSmall, opSmall)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_cmp16(opBig, opSmall)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_beq16(opBig, op2Beef)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_beq16(opBig, opBig)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_beq16_immediate(opSmall, $BEEF)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_beq16_immediate(op1Beef, $BEEF)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_blt16(opSmall, opBig)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_blt16(opTwo, opOne)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_blt16(op1Beef, op2Beef)
    
    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_ble16(opSmall, opBig)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_ble16(opBig, opSmall)

    ////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_ble16(op1Beef, op2Beef)

    nv_screen_plot_cursor(row++, 0)


    rts

hex_digit_lookup:
    .byte $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $41, $42, $43, $44, $45, $46



//////////////////////////////////////////////////////////////////////////
// inline macro to print a hex number that is in the accumulator
//   include_dollar: pass true to print a '$' before the number
.macro print_hex_byte(include_dollar)
{
    .var offset = 0
    .if (include_dollar)
    {
        .eval offset++
        ldy #$24            // dollar sign
        sty temp_hex_str
    }
    tay
    ror 
    ror 
    ror 
    ror  
    and #$0f
    tax
    lda hex_digit_lookup, x
    sta temp_hex_str+offset
    tya
    and #$0f
    tax
    lda hex_digit_lookup, x
    sta temp_hex_str+1+offset
    lda #0
    sta temp_hex_str + 2 + offset
    nv_screen_print_string_basic(temp_hex_str) 
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to print the word value at the address of the low byte given
.macro print_hex_word(word_low_byte_addr, include_dollar)
{
    .if (include_dollar)
    {
        lda #$24                // the $ sign
        sta temp_hex_str
        lda #0
        sta temp_hex_str+1
        nv_screen_print_string_basic(temp_hex_str)
    }
    lda word_low_byte_addr+1
    print_hex_byte(false)
    lda word_low_byte_addr
    print_hex_byte(false)
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to print the word value at the address of the low byte given
.macro print_hex_word_immediate(num, include_dollar)
{
    .if (include_dollar)
    {
        lda #$24                // the $ sign
        sta temp_hex_str
        lda #0
        sta temp_hex_str+1
        nv_screen_print_string_basic(temp_hex_str)
    }
    lda #((num >> 8) & $00ff)
    print_hex_byte(false)
    lda #(num & $00ff)
    print_hex_byte(false)
}



//////////////////////////////////////////////////////////////////////////////
// inline macro to add two 16 bit values and store the result in another
// 16bit value.  carry bit will be set if carry occured
// params:
//   addr1 is the address of the low byte of op1
//   addr2 is the address of the low byte of op2
//   result_addr is the address to store the result.
.macro adc16(addr1, addr2, result_addr)
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
.macro print_adc16(op1, op2, result)
{
    print_hex_word(op1, true)
    nv_screen_print_string_basic(plus_str)
    print_hex_word(op2, true)
    nv_screen_print_string_basic(equal_str)

    adc16(op1, op2, result)
    bcc NoCarry
    nv_screen_print_string_basic(carry_str)
NoCarry:
    print_hex_word(result, true)
}


//////////////////////////////////////////////////////////////////////////////
// compare the contents of two 16 bit words and set flags accordingly.
// params are:
//   addr1: 16 bit address of op1
//   addr2: 16 bit address of op2
// Carry Flag	Set if addr1 >= addr2
// Zero Flag	Set if addr1 == addr2
// Negative Flag is undefined
.macro cmp16(addr1, addr2)
{
    // first compare the MSBs
    lda addr1+1
    cmp addr2+1
    beq Done

    // MSBs are equal so need to compare LSBs
    lda addr1
    cmp addr2

Done:
}

//////////////////////////////////////////////////////////////////////////////
// compare the contents of two 16 bit words and set flags accordingly.
// params are:
//   addr1: 16 bit address of op1
//   addr2: 16 bit address of op2
// Carry Flag	Set if addr1 >= addr2
// Zero Flag	Set if addr1 == addr2
// Negative Flag is undefined
.macro cmp16_immediate(addr1, num)
{
    // first compare the MSBs
    lda addr1+1
    cmp #((num >> 8) & $00FF)
    beq Done

    // MSBs are equal so need to compare LSBs
    lda addr1
    cmp #(num & $00FF)

Done:
}


//////////////////////////////////////////////////////////////////////////////
// Print a comparison of two 16bit values at two locations in memory. 
// Prints at the current cursor location via a basic call
.macro print_cmp16(addr1, addr2)
{
    print_hex_word(addr1, true)
    cmp16(addr1, addr2)
    bne NotEq
// Equal here
    nv_screen_print_string_basic(equal_str)
    jmp PrintOp2

NotEq:
    bcs GreaterOrEqual
// less than here
    nv_screen_print_string_basic(less_than_str)
    jmp PrintOp2

// Greater here
GreaterOrEqual:
    nv_screen_print_string_basic(greater_than_str)

PrintOp2:
    print_hex_word(addr2, true)

}

//////////////////////////////////////////////////////////////////////////////
// branch if two words in memory have the same contents
//   addr1: is the address of LSB of one word (addr1+1 is MSB)
//   addr2: is the address of LSB of the other word (addr2+1 is MSB)
//   label: is the label to branch to
.macro beq16(addr1, addr2, label)
{
    cmp16(addr1, addr2)
    beq label
}

//////////////////////////////////////////////////////////////////////////////
// Print to current screen location the expression (either = or != ) 
// for the relationship of the two word in memorys.  Use beq16 to do it.
//   addr1: is the address of LSB of one word (addr1+1 is MSB)
//   addr2: is the address of LSB of the other word (addr2+1 is MSB)
.macro print_beq16(addr1, addr2)
{
    print_hex_word(addr1, true)
    beq16(addr1, addr2, Same)
    nv_screen_print_string_basic(not_equal_str)
    jmp Done
Same:
    nv_screen_print_string_basic(equal_str)

Done:
    print_hex_word(addr2, true)
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if one word in memory has the same content as 
// an immediate 16 bit value
//   addr1: is the address of LSB of one word (addr1+1 is MSB)
//   num: is the immediate 16 bit value to compare with the contents of addr1
//   label: is the label to branch to
.macro beq16_immediate(addr1, num, label)
{
    cmp16_immediate(addr1, num)
    beq label
}


//////////////////////////////////////////////////////////////////////////////
// Print to current screen location the expression (either = or != ) 
// for the relationship of one word in memory with an immediate 16 bit value
// Also use beq16 to do it.
//   addr1: is the address of LSB of one word (addr1+1 is MSB)
//   num: is the immediate value
.macro print_beq16_immediate(addr1, num)
{
    print_hex_word(addr1, true)
    beq16_immediate(addr1, num, Same)
    nv_screen_print_string_basic(not_equal_str)
    jmp Done
Same:
    nv_screen_print_string_basic(equal_str)

Done:
    print_hex_word_immediate(num, true)
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a word at one memory location  
// are less than the contents in another memory location 
//   addr1: the address of the LSB of the word1
//   addr2: the address of the LSB of the word2 
//   label: the label to branch to if word1 < word2
.macro blt16(addr1, addr2, label)
{
    cmp16(addr1, addr2)
    bcc label
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to branch if the contents of a word at one memory location  
// are less than or equal to the contents in another memory location 
//   addr1: the address of the LSB of the word1
//   addr2: the address of the LSB of the word2 
//   label: the label to branch to if word1 < word2
.macro ble16(addr1, addr2, label)
{
    cmp16(addr1, addr2)
    bcc label
    beq label
}

//////////////////////////////////////////////////////////////////////////////
// Print to current screen location the expression (either < or >= ) 
// for the relationship of the two word in memorys.  Use blt16 to do it.
//   addr1: is the address of LSB of word1 (addr1+1 is MSB)
//   addr2: is the address of LSB of word2 (addr2+1 is MSB)
.macro print_blt16(addr1, addr2)
{
    print_hex_word(addr1, true)
    blt16(addr1, addr2, LessThan)
    nv_screen_print_string_basic(greater_equal_str)
    jmp Done
LessThan:
    nv_screen_print_string_basic(less_than_str)

Done:
    print_hex_word(addr2, true)
}



//////////////////////////////////////////////////////////////////////////////
// Print to current screen location the expression (either <= or >)
// for the relationship of the two word in memorys.  Use ble16 to do it.
//   addr1: is the address of LSB of word1 (addr1+1 is MSB)
//   addr2: is the address of LSB of word2 (addr2+1 is MSB)
.macro print_ble16(addr1, addr2)
{
    print_hex_word(addr1, true)
    ble16(addr1, addr2, LessThanEqual)
    nv_screen_print_string_basic(greater_than_str)
    jmp Done
LessThanEqual:
    nv_screen_print_string_basic(less_equal_str)

Done:
    print_hex_word(addr2, true)
}
