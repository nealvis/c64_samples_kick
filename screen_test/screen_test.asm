//////////////////////////////////////////////////////////////////////////////
// This sample shows how to do 16bit operations such as add, subtract, 
// and compare
//////////////////////////////////////////////////////////////////////////////

// import all nv_c64_util macros and data.  The data
// will go in default place
#import "../nv_c64_util/nv_c64_util_macs_and_data.asm"

#import "../nv_c64_util/nv_keyboard_macs.asm"

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
title_bcd_byte_str: .text @"TEST PRINT BCD BYTE...\$00"
title_bcd_word_str: .text @"TEST PRINT DCD WORD...\$00"
title_poke_bcd_word_str: .text @"TEST POKE BCD WORD MEM\$00"
title_poke_bcd_byte_str: .text @"TEST POKE BCD BYTE MEM\$00"

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

dec_00: .byte $00
dec_01: .byte $01
dec_02: .byte $02
dec_09: .byte $09
dec_10: .byte $10
dec_11: .byte $11
dec_12: .byte $12
dec_19: .byte $19
dec_20: .byte $20
dec_21: .byte $21
dec_22: .byte $22
dec_99: .byte $99

dec_0000: .word $0000
dec_0001: .word $0001
dec_0002: .word $0002
dec_0009: .word $0009
dec_0010: .word $0010
dec_0011: .word $0011
dec_0012: .word $0012
dec_0098: .word $0098
dec_0099: .word $0099
dec_0100: .word $0100
dec_0101: .word $0101
dec_9999: .word $9999


*=$1000 "Main Start"

.var row = 0

    nv_screen_clear()
    nv_screen_plot_cursor(row++, 31)
    nv_screen_print_str(title_str)

    test_poke_bcd_byte(0)
    test_poke_bcd_word(0)
    test_print_bcd_byte(0)
    test_print_bcd_word(0)

    test_hex_word(0)
    test_hex_word_immediate(0)

    rts


//////////////////////////////////////////////////////////////////////////////
// test converting word to hex
.macro test_poke_bcd_word(init_row)
{
    .var row = init_row
    //////////////////////////////////////////////////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_str(title_poke_bcd_word_str)
    //////////////////////////////////////////////////////////////////////////
    .eval row++

    nv_screen_poke_bcd_word_mem(row++, 0, dec_0000)

    nv_screen_poke_bcd_word_mem(row++, 0, dec_0001)

    nv_screen_poke_bcd_word_mem(row++, 0, dec_0002)

    nv_screen_poke_bcd_word_mem(row++, 0, dec_0009)

    nv_screen_poke_bcd_word_mem(row++, 0, dec_0010)

    nv_screen_poke_bcd_word_mem(row++, 0, dec_0011)

    nv_screen_poke_bcd_word_mem(row++, 0, dec_0012)

    nv_screen_poke_bcd_word_mem(row++, 0, dec_0098)

    nv_screen_poke_bcd_word_mem(row++, 0, dec_0099)

    nv_screen_poke_bcd_word_mem(row++, 0, dec_0100)

    nv_screen_poke_bcd_word_mem(row++, 0, dec_0101)

    nv_screen_poke_bcd_word_mem(row++, 0, dec_9999)

    wait_and_clear_at_row(row)
}



//////////////////////////////////////////////////////////////////////////////
// test converting word to hex
.macro test_print_bcd_word(init_row)
{
    .var row = init_row
    //////////////////////////////////////////////////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_str(title_bcd_word_str)
    //////////////////////////////////////////////////////////////////////////
    .eval row++

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_bcd_word_mem(dec_0000)

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_bcd_word_mem(dec_0001)

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_bcd_word_mem(dec_0002)

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_bcd_word_mem(dec_0009)

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_bcd_word_mem(dec_0010)

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_bcd_word_mem(dec_0011)

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_bcd_word_mem(dec_0012)

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_bcd_word_mem(dec_0098)

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_bcd_word_mem(dec_0099)

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_bcd_word_mem(dec_0100)

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_bcd_word_mem(dec_0101)

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_bcd_word_mem(dec_9999)

    wait_and_clear_at_row(row)
}


//////////////////////////////////////////////////////////////////////////////
// test converting word to hex
.macro test_print_bcd_byte(init_row)
{
    .var row = init_row
    //////////////////////////////////////////////////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_str(title_bcd_byte_str)
    //////////////////////////////////////////////////////////////////////////
    .eval row++

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_bcd_byte_mem(dec_00)

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_bcd_byte_mem(dec_01)

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_bcd_byte_mem(dec_02)

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_bcd_byte_mem(dec_09)

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_bcd_byte_mem(dec_10)

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_bcd_byte_mem(dec_11)

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_bcd_byte_mem(dec_12)

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_bcd_byte_mem(dec_19)

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_bcd_byte_mem(dec_20)

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_bcd_byte_mem(dec_21)

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_bcd_byte_mem(dec_22)

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_bcd_byte_mem(dec_99)

    wait_and_clear_at_row(row)
}

//////////////////////////////////////////////////////////////////////////////
// test converting word to hex
.macro test_poke_bcd_byte(init_row)
{
    .var row = init_row
    //////////////////////////////////////////////////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_str(title_poke_bcd_byte_str)
    //////////////////////////////////////////////////////////////////////////
    .eval row++

    nv_screen_poke_bcd_byte_mem(row++, 0, dec_00)

    nv_screen_poke_bcd_byte_mem(row++, 0, dec_01)

    nv_screen_poke_bcd_byte_mem(row++, 0, dec_02)

    nv_screen_poke_bcd_byte_mem(row++, 0, dec_09)

    nv_screen_poke_bcd_byte_mem(row++, 0, dec_10)

    nv_screen_poke_bcd_byte_mem(row++, 0, dec_11)

    nv_screen_poke_bcd_byte_mem(row++, 0, dec_12)

    nv_screen_poke_bcd_byte_mem(row++, 0, dec_19)

    nv_screen_poke_bcd_byte_mem(row++, 0, dec_20)

    nv_screen_poke_bcd_byte_mem(row++, 0, dec_21)

    nv_screen_poke_bcd_byte_mem(row++, 0, dec_22)

    nv_screen_poke_bcd_byte_mem(row++, 0, dec_99)

    wait_and_clear_at_row(row)
}


//////////////////////////////////////////////////////////////////////////////
// test converting word to hex
.macro test_hex_word(init_row)
{
    .var row = init_row
    //////////////////////////////////////////////////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_str(title_hex_word_str)
    //////////////////////////////////////////////////////////////////////////
    .eval row++
    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_hex_word_mem(word_to_print, true)

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_hex_word_mem(another_word, false)

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_hex_word_mem(op1Beef, true)

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_hex_word_mem(opSmall, true)

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_hex_word_mem(opBig, true)

    wait_and_clear_at_row(row)
}


//////////////////////////////////////////////////////////////////////////////
.macro test_hex_word_immediate(init_row)
{
    .var row = init_row

    //////////////////////////////////////////////////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_str(title_hex_word_immediate_str)
    //////////////////////////////////////////////////////////////////////////

    .eval row++
    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_hex_word_immed($ABCD, true)

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_hex_word_immed($FFFF, true)

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_hex_word_immed($0000, true)

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_hex_word_immed($DEAD, true)

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_hex_word_immed($BEEF, true)

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_hex_word_immed($fedc, true)

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_hex_word_immed($1234, true)

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_hex_word_immed($0001, true)

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


