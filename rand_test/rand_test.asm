//////////////////////////////////////////////////////////////////////////////
// rand_test.asm
// Copyright(c) 2021 Neal Smith.
// License: MIT. See LICENSE file in root directory.
/////////////////////////////////////////////////////////////////////////////
// This program tests the code in the file nv_rand_macs.asm in the 
// nv_c64_util repository.  The tests need to be manually verified 
// by looking at the output.

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

title_str: .text @"RANDOM\$00"          // null terminated string to print
                                        // via the BASIC routine
title_rand_byte_a_str: .text @"TEST RANDOM BYTE A\$00"
title_rand_color_a_str: .text @"TEST RANDOM COLOR A\$00"
hit_anykey_str: .text @"HIT ANY KEY ...\$00"
rand_byte_label_str: .text @"RANDOM BYTE: \$00"
rand_color_label_str: .text @"RANDOM COLOR: \$00"



*=$1000 "Main Start"

    .var row = 0

    nv_rand_init(true)

    nv_screen_clear()
    nv_screen_plot_cursor(row++, 33)
    nv_screen_print_str(title_str)

    test_random_byte_a(0)
    test_random_color_a(0)

    nv_rand_done()

    rts


//////////////////////////////////////////////////////////////////////////////
//
.macro test_random_byte_a(init_row)
{
    .var row = init_row
    
    //////////////////////////////////////////////////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_str(title_rand_byte_a_str)
    //////////////////////////////////////////////////////////////////////////
    .eval row++

    /////////////////////////////
    nv_screen_plot_cursor(row, 0)
    print_rand_byte_a(row++)

    /////////////////////////////
    nv_screen_plot_cursor(row, 0)
    print_rand_byte_a(row++)

    /////////////////////////////
    nv_screen_plot_cursor(row, 0)
    print_rand_byte_a(row++)

    /////////////////////////////
    nv_screen_plot_cursor(row, 0)
    print_rand_byte_a(row++)

    /////////////////////////////
    nv_screen_plot_cursor(row, 0)
    print_rand_byte_a(row++)

    /////////////////////////////
    nv_screen_plot_cursor(row, 0)
    print_rand_byte_a(row++)

    /////////////////////////////
    nv_screen_plot_cursor(row, 0)
    print_rand_byte_a(row++)

    /////////////////////////////
    nv_screen_plot_cursor(row, 0)
    print_rand_byte_a(row++)

    /////////////////////////////
    nv_screen_plot_cursor(row, 0)
    print_rand_byte_a(row++)

    /////////////////////////////
    nv_screen_plot_cursor(row, 0)
    print_rand_byte_a(row++)

    /////////////////////////////
    nv_screen_plot_cursor(row, 0)
    print_rand_byte_a(row++)



    wait_and_clear_at_row(row)
}

//////////////////////////////////////////////////////////////////////////////
//
.macro test_random_color_a(init_row)
{
    .var row = init_row
    
    //////////////////////////////////////////////////////////////////////////
    nv_screen_plot_cursor(row++, 0)
    nv_screen_print_str(title_rand_color_a_str)
    //////////////////////////////////////////////////////////////////////////
    .eval row++

    /////////////////////////////
    nv_screen_plot_cursor(row, 0)
    print_rand_color_a(row++)

    /////////////////////////////
    nv_screen_plot_cursor(row, 0)
    print_rand_color_a(row++)

    /////////////////////////////
    nv_screen_plot_cursor(row, 0)
    print_rand_color_a(row++)

    /////////////////////////////
    nv_screen_plot_cursor(row, 0)
    print_rand_color_a(row++)

    /////////////////////////////
    nv_screen_plot_cursor(row, 0)
    print_rand_color_a(row++)

    /////////////////////////////
    nv_screen_plot_cursor(row, 0)
    print_rand_color_a(row++)

    /////////////////////////////
    nv_screen_plot_cursor(row, 0)
    print_rand_color_a(row++)

    /////////////////////////////
    nv_screen_plot_cursor(row, 0)
    print_rand_color_a(row++)

    /////////////////////////////
    nv_screen_plot_cursor(row, 0)
    print_rand_color_a(row++)

    /////////////////////////////
    nv_screen_plot_cursor(row, 0)
    print_rand_color_a(row++)

    /////////////////////////////
    nv_screen_plot_cursor(row, 0)
    print_rand_color_a(row++)

    /////////////////////////////
    nv_screen_plot_cursor(row, 0)
    print_rand_color_a(row++)

    /////////////////////////////
    nv_screen_plot_cursor(row, 0)
    print_rand_color_a(row++)

    /////////////////////////////
    nv_screen_plot_cursor(row, 0)
    print_rand_color_a(row++)

    /////////////////////////////
    nv_screen_plot_cursor(row, 0)
    print_rand_color_a(row++)

    /////////////////////////////
    nv_screen_plot_cursor(row, 0)
    print_rand_color_a(row++)

    /////////////////////////////
    nv_screen_plot_cursor(row, 0)
    print_rand_color_a(row++)

    /////////////////////////////
    nv_screen_plot_cursor(row, 0)
    print_rand_color_a(row++)

    /////////////////////////////
    nv_screen_plot_cursor(row, 0)
    print_rand_color_a(row++)


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
    nv_screen_plot_cursor(row++, 33)
    nv_screen_print_str(title_str)
}


//////////////////////////////////////////////////////////////////////////////
//                          Print macros 
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// inline macro to print the random number generated
.macro print_rand_byte_a(row)
{
    nv_screen_print_str(rand_byte_label_str)
    nv_screen_plot_cursor_col(15)
    nv_rand_byte_a(true)
    nv_screen_print_hex_byte_a(true)
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to print the random number generated
.macro print_rand_color_a(row)
{
    nv_screen_print_str(rand_color_label_str)
    nv_screen_plot_cursor_col(15)
    nv_rand_color_a(true)
    sta scratch_byte
    nv_screen_print_hex_byte_a(true)
    ldx scratch_byte
    lda #224
    nv_screen_poke_color_char_xa(row, 20)
    nv_screen_poke_color_char_xa(row, 21)
    nv_screen_poke_color_char_xa(row, 22)
    nv_screen_poke_color_char_xa(row, 23)
    nv_screen_poke_color_char_xa(row, 24)
}
