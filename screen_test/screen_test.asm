//////////////////////////////////////////////////////////////////////////////
// screen_test.asm
// Copyright(c) 2021 Neal Smith.
// License: MIT. See LICENSE file in root directory.
//////////////////////////////////////////////////////////////////////////////
// This program tests the nv_screen_*.asm code in the nv_c64_util repo
//////////////////////////////////////////////////////////////////////////////

// import all nv_c64_util macros and data.  The data
// will go in default place
#import "../../nv_c64_util/nv_c64_util_macs_and_data.asm"

//#import "../nv_c64_util/nv_keyboard_macs.asm"

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

*=$1000 "Main Start"
jmp RealStart 

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
title_poke_coord_list_str: .text @"TEST POKE COORD LIST\$00"
title_custom_charset_str: .text @"TEST CUSTOM CHARSET\$00"
hit_anykey_str: .text @"HIT ANY KEY ...\$00"
pre_copy_str: .text @"ABOUT TO GO CUSTOM CHARSET.\$00"
post_copy_str: .text @"CUSTOM CHARSET IN PLACE AT: \$00"


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

coord_list1:
    .byte NV_COLOR_WHITE, $01 // red and 'A'
    .byte 0, 3                // col, row
    .byte 1, 4
    .byte 2, 5
    .byte 3, 6
    .byte 4, 7
    .byte 5, 8
    .byte 6, 9
    .byte 7, 10
    .byte 8, 11
    .byte 9, 12
    .byte 10, 13
    .byte 11, 14
    .byte 12, 15
    .byte 13, 16
    .byte 14, 17
    .byte 15, 18
    .byte 16, 19
    .byte 17, 20
    .byte 18, 21
    .byte 19, 22
    .byte 20, 23
    .byte 21, 24
    .byte $FF

coord_list2:
    .byte NV_COLOR_GREEN, $02 // green, 'B'
    .byte 39, 2              // col, row
    .byte 39, 3
    .byte 39, 0
    .byte 39, 1
    .byte 39, 4
    .byte 39, 5
    .byte 39, 6
    .byte 39, 7
    .byte 39, 8
    .byte 39, 9
    .byte 39, 10
    .byte 39, 11
    .byte 39, 12
    .byte 39, 13
    .byte 39, 14
    .byte 39, 15
    .byte 39, 16
    .byte 39, 17
    .byte 39, 18
    .byte 39, 19
    .byte 39, 20
    .byte 39, 21
    .byte 39, 22
    .byte 39, 23
    .byte 39, 24
    .byte $FF

coord_list3:
    .byte NV_COLOR_RED, $03 // red, 'C'
    .byte 0, 0              // col, row
    .byte 0, 1
    .byte 0, 2
    .byte 0, 3
    .byte 0, 4
    .byte 0, 5
    .byte 0, 6
    .byte 0, 7
    .byte 0, 8
    .byte 0, 9
    .byte 0, 10
    .byte 0, 11
    .byte 0, 12
    .byte 0, 13
    .byte 0, 14
    .byte 0, 15
    .byte 0, 16
    .byte 0, 17
    .byte 0, 18
    .byte 0, 19
    .byte 0, 20
    .byte 0, 21
    .byte 0, 22
    .byte 0, 23
    .byte 0, 24
    .byte $FF

coord_list4:
    .byte NV_COLOR_BROWN, $04 // brown, 'D'
    .byte 0, 6              // col, row
    .byte 1, 6
    .byte 2, 6
    .byte 3, 6
    .byte 4, 6
    .byte 5, 6
    .byte 6, 6
    .byte 7, 6
    .byte 8, 6
    .byte 9, 6
    .byte 10,6 
    .byte 11,6 
    .byte 12,6 
    .byte 13, 6
    .byte 14, 6
    .byte 15, 6
    .byte 16, 6
    .byte 17, 6
    .byte 18, 6
    .byte 19, 6
    .byte 20, 6
    .byte 21, 6
    .byte 22, 6
    .byte 23, 6
    .byte 24, 6
    .byte $FF

// basic program to call the ML program
BasicProgram:
    .byte $00                // first byte start of basic should be 0
    .byte $0E, $08           // Forward address to next basic line
    .byte $0A, $00           // this will be line 10 ($0A)
    .byte $9E                // basic token for SYS
    .byte $20, $28, $34, $30, $39, $36, $29 // ASCII for " (4096)"
    .byte $00, $00, $00      // end of basic program (addr $080E from above)
    .byte $FF                // marker to end copying will be ok as long as 
                             // no $FF in the actual program above

*=$3000 "charset start"
.import binary "charset.bin"


*=$4001 "RealStart"
RealStart:


.var row = 0

    nv_screen_clear()
    nv_screen_plot_cursor(row++, 31)
    nv_screen_print_str(title_str)

    test_custom_charset(0)
    test_poke_coord_list(0)
    test_poke_bcd_byte(0)
    test_poke_bcd_word(0)
    test_print_bcd_byte(0)
    test_print_bcd_word(0)

    test_hex_word(0)
    test_hex_word_immediate(0)

    // copy the 1 line basic program back to basic memory
    ldx 0
CopyBasicProgramLoop:
    lda BasicProgram, x
    cmp #$FF
    beq Done
    sta $0800, x
    inx
    jmp CopyBasicProgramLoop
Done:

    nv_screen_custom_charset_done()

    rts

//////////////////////////////////////////////////////////////////////////////
// test pokeing a color and char to a list of screen coordinates
.macro test_custom_charset(init_row)
{
    nv_screen_set_background_color_immed(NV_COLOR_BLACK)
    lda #1
    nv_screen_poke_all_color_a()
    
    
    .var row = init_row
    //////////////////////////////////////////////////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_str(title_custom_charset_str)
    //////////////////////////////////////////////////////////////////////////
    .eval row++

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_str(pre_copy_str)

    nv_screen_custom_charset_init(6, false)

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_str(post_copy_str)
    nv_screen_print_hex_word_immed($3000, true)

    .eval row = row+1
    .var char
    .var col = 0
    .for(char = 0; char<255; char++)
    {
        ldy #char
        nv_screen_poke_char_y(row, col++)
        
        .if (char == 40)
        {
            .eval col = 0
            .eval row = row + 1
        }
    }

    nv_screen_plot_cursor(23, 5)
    wait_and_clear_at_row(23)
}


//////////////////////////////////////////////////////////////////////////////
// test pokeing a color and char to a list of screen coordinates
.macro test_poke_coord_list(init_row)
{
    .var row = init_row
    //////////////////////////////////////////////////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_str(title_poke_coord_list_str)
    //////////////////////////////////////////////////////////////////////////
    .eval row++

    ldx #<coord_list1
    ldy #>coord_list1
    jsr NvScreenPokeCoordList

    ldx #<coord_list2
    ldy #>coord_list2
    jsr NvScreenPokeCoordList

    ldx #<coord_list3
    ldy #>coord_list3
    jsr NvScreenPokeCoordList

    ldx #<coord_list4
    ldy #>coord_list4
    jsr NvScreenPokeCoordList


    nv_screen_plot_cursor(23, 5)
    wait_and_clear_at_row(23)

}

//////////////////////////////////////////////////////////////////////////////
// inline macro to poke the same char and color to a list of screen coords
// macro params:
//   zero_page_lsb_addr: this is the LSB of a word in zero page
//                       that should be used for pointer indirection
//   mem_block_addr: the address of a 7 byte block that can be used
//                   internally to store these things throughout
//                   col, row, color, char, y index, zero page lsb, msb
// reg params:
//   X Reg/Y Reg: is the LSB/MSB of the list_addr which points to bytes 
//                in this structure:
//                list_addr: .byte <color>, <char> // color byte, char byte
//                           .byte 0, 0     // screen coord 0, 0
//                           .byte 1, 1     // screen coord 1, 1
//                           .byte $FF      // end of list.
NvScreenPokeCoordList:
    nv_screen_poke_coord_list(ZERO_PAGE_LO, my_mem_block)
    rts

// 7 byte block for nv_screen_poke_coord_list per comments
my_mem_block: .byte 0, 0, 0, 0, 0, 0, 0   // x, y, color, char

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


