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
not_equal_str: .text@" NOT EQUAL \$00"
greater_equal_str: .text@" >= \$00" 
less_than_str: .text@" < \$00"
greater_than_str: .text@" > \$00"
str_to_print: .text @"MATH16\$00"  // null terminated string to print
                                            // via the BASIC routine

str_to_poke: .text  @"hello direct\$00" // null terminated string to print
                                        // via copy direct to screen memory
temp_hex_str: .byte 0,0,0,0,0,0         // enough bytes for dollor sign, 4 
                                        // hex digits and a trailing null
// our assembly code will goto this address

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

*=$1000 "Main Start"

    nv_screen_clear()
    nv_screen_plot_cursor(0, 16)
    nv_screen_print_string_basic(str_to_print)

    nv_screen_plot_cursor(1, 0)
    lda #$6d
    print_hex_byte(true)
    lda #$3e
    print_hex_byte(true)

    nv_screen_plot_cursor(5, 0)
/*
    lda #0
    sta counter
loop:
    print_hex_byte(true)
    inc counter
    lda counter
    bne loop
*/

    //////////////////////////////
    nv_screen_plot_cursor(2, 0)
    print_hex_word(word_to_print, true)
    print_hex_word(another_word, false)

    /////////////////////////////
    nv_screen_plot_cursor(3, 0)
    print_hex_word(op1, true)

    nv_screen_print_string_basic(plus_str)

    print_hex_word(op2, true)
    //nv_screen_plot_cursor(3, 14)
    nv_screen_print_string_basic(equal_str)

    adc16(op1, op2, result)
    bcc NoCarry
    nv_screen_print_string_basic(carry_str)
NoCarry:
    print_hex_word(result, true)

    /////////////////////////////
    nv_screen_plot_cursor($4, 0)
    print_cmp16(op1Beef, op2Beef)

    /////////////////////////////
    nv_screen_plot_cursor($5, 0)
    print_cmp16(opSmall, opBig)

    /////////////////////////////
    nv_screen_plot_cursor($6, 0)
    print_cmp16(opSmall, opSmall)

    /////////////////////////////
    nv_screen_plot_cursor($7, 0)
    print_cmp16(opBig, opSmall)


    nv_screen_plot_cursor($10, 0)


    rts

hex_digit_lookup:
    .byte $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $41, $42, $43, $44, $45, $46



//////////////////////////////////////////////////////////////////////////
// print a hex number that is in the accum
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