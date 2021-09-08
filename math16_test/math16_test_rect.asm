//////////////////////////////////////////////////////////////////////////////
// math16_test_rect.asm
// Copyright(c) 2021 Neal Smith.
// License: MIT. See LICENSE file in root directory.
//////////////////////////////////////////////////////////////////////////////
// This program tests the bcd math operations in nv_math16_*.asm
//////////////////////////////////////////////////////////////////////////////

// import all nv_c64_util macros and data.  The data
// will go in default place
#import "../../nv_c64_util/nv_c64_util_macs_and_data.asm"

#import "../../nv_c64_util/nv_math16_macs.asm"

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
carry_str: .text @"(C) \$00"
carry_and_overflow_str:  .text @"(CV) \$00"
overflow_str:  .text @"(V) \$00"
plus_str: .text @"+\$00"
minus_str: .text @"-\$00"
equal_str: .text@"=\$00"
lsr_str: .text@">>\$00"

title_str: .text @"MATH16 RECT\$00"      // null terminated string to print
                                        // via the BASIC routine
title_check_range16_str: .text @"TEST CHECK RANGE \$00"
title_check_in_rect16_str: .text @"TEST CHK IN RECT\$00"
title_check_rect_overlap16_str: .text @"TEST RECT OVERLAP\$00"
comma_str: .text @",\$00"
overlap_str: .text @"OVERLAP\$00"
not_overlap_str: .text @"NO OVERLAP\$00"
left_str:   .text @"LEFT, \$00"
top_str:    .text @"TOP   \$00"
right_str:  .text @"RIGHT, \$00"
bottom_str: .text @"BOTTOM\$00"




hit_anykey_str: .text @"HIT ANY KEY \$00"
is_in_range_str: .text @" IN RANGE \$00"
is_not_in_range_str: .text @" NOT IN RANGE \$00"
space_str: .text @"  \$00"
dots_str: .text @"..\$00"

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
op_8001: .word $8001 // high bit only set
op_FFFF: .word $FFFF // all bits
op_0000: .word $0000 // all bits
op_0001: .word $0001 // all bits
op_0002: .word $0002 // all bits
op_0009: .word $0009
op_00FF: .word $00FF 
op_0100: .word $0100
op_0200: .word $0200
op_0300: .word $0300
op_9999: .word $9999
op_9000: .word $9000
op_0090: .word $0090
op_0099: .word $0099
op_0020: .word $0020
op_0999: .word $0999
op_0101: .word $0101
op_01FF: .word $01FF


op_2222: .word $2222
op_FFFD: .word $FFFD // -3

op_00: .byte $00
op_01: .byte $01

op8_7F: .byte $7F
op8_FF: .byte $FF
op8_0F: .byte $0F
op8_F0: .byte $F0
op8_80: .byte $80  // -128
op8_81: .byte $81  // -127

op_02: .byte $02
op_08: .byte $08
op_09: .byte $09
op_80: .byte $80
op_81: .byte $81
op_7F: .byte $7F
op_FF: .byte $FF
op_10: .byte $10
op_0F: .byte $0F
op_FD: .byte $FD
op_33: .byte $33
op_22: .byte $22
op_FE: .byte $FE

rect1: .word $0002, $0002  // (left, top)
       .word $0007, $0007  // (right, bottom)

rect2: .word $0010, $0010  // (left, top)
       .word $0030, $0030  // (right, bottom)

rect3: .word $0050, $0050  // (left, top)
       .word $0200, $0200  // (right, bottom)

rect4: .word $0100, $0080  // (left, top)
       .word $0160, $0100  // (right, bottom)

rect5: .word $0002, $0002  // (left, top)
       .word $0010, $0010  // (right, bottom)

rect6: .word $0005, $0005  // (left, top)
       .word $0030, $0008  // (right, bottom)

rect7: .word $0020, $0020  // (left, top)
       .word $0070, $0070  // (right, bottom)

rect8: .word $0060, $0060  // (left, top)
       .word $0300, $0300  // (right, bottom)

rect9: .word $0020, $0020  // (left, top)
       .word $0070, $0070  // (right, bottom)

rect10: .word $0030, $0010  // (left, top)
        .word $0040, $0030  // (right, bottom)


rect11: .word $0200, $0200  // (left, top)
        .word $0700, $0700  // (right, bottom)

rect12: .word $1000, $1000  // (left, top)
        .word $3000, $3000  // (right, bottom)

rect13: .word $0050, $0050  // (left, top)
        .word $0060, $0060  // (right, bottom)

rect14: .word $0010, $0010  // (left, top)
        .word $FFFF, $EEEE  // (right, bottom)

rect15: .word $2000, $2000  // (left, top)
        .word $5000, $4000  // (right, bottom)

rect16: .word $0005, $0005  // (left, top)
        .word $0030, $0008  // (right, bottom)

rect17: .word $0020, $0020  // (left, top)
        .word $0070, $0201  // (right, bottom)

rect18: .word $0010, $0200  // (left, top)
        .word $0100, $0300  // (right, bottom)

rect19: .word $0020, $0020  // (left, top)
        .word $0070, $0070  // (right, bottom)

rect20: .word $0010, $0200  // (left, top)
        .word $0100, $0300  // (right, bottom)



*=$1000 "Main Start"

.var row = 0

    nv_screen_clear()
    nv_screen_plot_cursor(row++, 29)
    nv_screen_print_str(title_str)

    //test_in_rect16(0)
    test_rect_overlap16(0)
    test_more_rect_overlap16(0)
    test_in_range16(0)


    rts

//////////////////////////////////////////////////////////////////////////////
//
.macro test_in_range16(init_row)
{
    .var row = init_row
    
    //////////////////////////////////////////////////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_str(title_check_range16_str)
    //////////////////////////////////////////////////////////////////////////
    .eval row++

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_check_range16(op_0002, op_0100, op_0300)


    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_check_range16(op_0100, op_0002, op_0300)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_check_range16(op_0300, op_0100, op_0200)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_check_range16(op_0100, op_0100, op_0200)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_check_range16(op_0200, op_0100, op_0200)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_check_range16(op_0101, op_0100, op_0200)

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_check_range16(op_01FF, op_0100, op_0200)

    wait_and_clear_at_row(row)
}

//////////////////////////////////////////////////////////////////////////////
//
.macro test_rect_overlap16(init_row)
{
    .var row = init_row
    
    //////////////////////////////////////////////////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_str(title_check_rect_overlap16_str)
    //////////////////////////////////////////////////////////////////////////

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_str(left_str)
    nv_screen_print_str(top_str)
    nv_screen_print_str(right_str)
    nv_screen_print_str(bottom_str)

    .eval row++

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_check_rect_overlap16(rect1, rect2, row)
    .eval row=row+3

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_check_rect_overlap16(rect3, rect4, row)
    .eval row=row+3

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_check_rect_overlap16(rect5, rect6, row)
    .eval row=row+3

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_check_rect_overlap16(rect7, rect8, row)
    .eval row=row+3

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_check_rect_overlap16(rect9, rect10, row)
    .eval row=row+3

    wait_and_clear_at_row(row)
}


//////////////////////////////////////////////////////////////////////////////
//
.macro test_more_rect_overlap16(init_row)
{
    .var row = init_row
    
    //////////////////////////////////////////////////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_str(title_check_rect_overlap16_str)
    //////////////////////////////////////////////////////////////////////////

    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_str(left_str)
    nv_screen_print_str(top_str)
    nv_screen_print_str(right_str)
    nv_screen_print_str(bottom_str)

    .eval row++

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_check_rect_overlap16(rect11, rect12, row)
    .eval row=row+3

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_check_rect_overlap16(rect13, rect14, row)
    .eval row=row+3

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_check_rect_overlap16(rect15, rect16, row)
    .eval row=row+3

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_check_rect_overlap16(rect17, rect18, row)
    .eval row=row+3

    /////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    print_check_rect_overlap16(rect19, rect20, row)
    .eval row=row+3

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
    nv_screen_plot_cursor(row++, 29)
    nv_screen_print_str(title_str)
}


//////////////////////////////////////////////////////////////////////////////
//                          Print macros 
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
.macro print_check_rect_overlap16(rect1_addr, rect2_addr, row)
{
    .label r1_left = rect1_addr
    .label r1_top = rect1_addr + 2
    .label r1_right = rect1_addr + 4
    .label r1_bottom = rect1_addr + 6

    .label r2_left = rect2_addr
    .label r2_top = rect2_addr + 2
    .label r2_right = rect2_addr + 4
    .label r2_bottom = rect2_addr + 6

    nv_screen_print_hex_word_mem(r1_left, true)
    nv_screen_print_str(comma_str)
    nv_screen_print_hex_word_mem(r1_top, true)
    nv_screen_print_str(space_str)
    nv_screen_print_hex_word_mem(r1_right, true)
    nv_screen_print_str(comma_str)
    nv_screen_print_hex_word_mem(r1_bottom, true)
 
    nv_screen_plot_cursor(row, 0)
    nv_screen_print_hex_word_mem(r2_left, true)
    nv_screen_print_str(comma_str)
    nv_screen_print_hex_word_mem(r2_top, true)
    nv_screen_print_str(space_str)
    nv_screen_print_hex_word_mem(r2_right, true)
    nv_screen_print_str(comma_str)
    nv_screen_print_hex_word_mem(r2_bottom, true)
    nv_screen_plot_cursor(row+1, 0)
    nv_check_rect_overlap16(rect1_addr, rect2_addr)
    bne True
False:
    nv_screen_print_str(not_overlap_str)
    jmp Done
True:
    nv_screen_print_str(overlap_str)
Done:
}


//////////////////////////////////////////////////////////////////////////////
.macro print_check_range16(test_num, lo_num, hi_num)
{
    nv_screen_print_hex_word_mem(test_num, true)
    nv_screen_print_str(space_str)
    nv_screen_print_hex_word_mem(lo_num, true)
    nv_screen_print_str(dots_str)
    nv_screen_print_hex_word_mem(hi_num, true)

    nv_check_range16(test_num, lo_num, hi_num, false)
    bne True
False:
    nv_screen_print_str(is_not_in_range_str)
    jmp Done
True:
    nv_screen_print_str(is_in_range_str)
Done:
}


