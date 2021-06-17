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
str_to_print: .text @"MATH16\$00"  // null terminated string to print
                                            // via the BASIC routine

str_to_poke: .text  @"hello direct\$00"  // null terminated string to print
                                         // via copy direct to screen memory
temp_hex_str: .byte 0,0,0,0,0
// our assembly code will goto this address

word_to_print: .word $BEEF

*=$1000 "Main Start"

    nv_screen_clear()
    nv_screen_plot_cursor(0, 16)
    nv_screen_print_string_basic(str_to_print)

    nv_screen_plot_cursor(4, 0)
    lda #$6d
    print_hex_byte()
    lda #$3e
    print_hex_byte()

    nv_screen_plot_cursor(6, 0)
    print_hex_word(word_to_print)

    nv_screen_plot_cursor($10, 0)

    rts

hex_digit_lookup:
    .byte $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $41, $42, $43, $44, $45, $46


//////////////////////////////////////////////////////////////////////////
// print a hex number that is in the accum
.macro print_hex_byte()
{
    tay
    ror 
    ror 
    ror 
    ror  
    and #$0f
    tax
    lda hex_digit_lookup, x
    sta temp_hex_str
    tya
    and #$0f
    tax
    lda hex_digit_lookup, x
    sta temp_hex_str+1
    lda #0
    sta temp_hex_str + 2
    nv_screen_print_string_basic(temp_hex_str) 
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to print the word value at the address of the low byte given
.macro print_hex_word(word_low_byte_addr)
{
    lda word_low_byte_addr+1
    print_hex_byte()
    lda word_low_byte_addr
    print_hex_byte()
}


