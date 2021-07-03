//////////////////////////////////////////////////////////////////////////////
// This sample shows how to do 16bit operations such as add, subtract, 
// and compare
//////////////////////////////////////////////////////////////////////////////


// import the nv_util_data at the very top of memory.
// it can go anywhere but this is out of the way
*=$9F00 "nv_util_data"   
#import "../nv_c64_util/nv_c64_util_data.asm"

// import macros, these don't generate any code
#import "../nv_c64_util/nv_c64_util_macs.asm"

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
title_str: .text @"SCREEN\$00"          // null terminated string to print
                                        // via the BASIC routine
title_hex_word_str: .text @"TEST PRINT HEX WORD...\$00"
title_hex_word_immediate_str: .text @"TEST PRINT HEX WORD IMMED\$00"

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


*=$1000 "Main Start"

.var row = 0

    nv_screen_clear()
    nv_screen_plot_cursor(row++, 31)
    nv_screen_print_string_basic(title_str)

    test_hex_word(0)
    test_hex_word_immediate(0)

    rts


//////////////////////////////////////////////////////////////////////////////
// test converting word to hex
.macro test_hex_word(init_row)
{
    .var row = init_row
    //////////////////////////////////////////////////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_string_basic(title_hex_word_str)
    //////////////////////////////////////////////////////////////////////////
    .eval row++
    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_hex_word(word_to_print, true)

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_hex_word(another_word, false)

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_hex_word(op1Beef, true)

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_hex_word(opSmall, true)

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_hex_word(opBig, true)

    wait_and_clear_at_row(row)
}


//////////////////////////////////////////////////////////////////////////////
.macro test_hex_word_immediate(init_row)
{
    .var row = init_row

    //////////////////////////////////////////////////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_string_basic(title_hex_word_immediate_str)
    //////////////////////////////////////////////////////////////////////////

    .eval row++
    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_hex_word_immediate($ABCD, true)

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_hex_word_immediate($FFFF, true)

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_hex_word_immediate($0000, true)

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_hex_word_immediate($DEAD, true)

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_hex_word_immediate($BEEF, true)

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_hex_word_immediate($fedc, true)

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_hex_word_immediate($1234, true)

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_hex_word_immediate($0001, true)

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
    nv_screen_plot_cursor(row++, 31)
    nv_screen_print_string_basic(title_str)
}


