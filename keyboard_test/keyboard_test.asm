//////////////////////////////////////////////////////////////////////////////
// This program tests the nv_keyboard_*.asm code
//////////////////////////////////////////////////////////////////////////////

// import all nv_c64_util macros and data.  The data
// will go in default place
#import "../nv_c64_util/nv_c64_util_macs_and_data.asm"


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

// program variables
title_str: .text @"KEYBOARD TEST\$00"          // null terminated string to print
                                               // via the BASIC routine
hit_anykey1_str: .text @"HIT ANY KEY AND LOOK\$00"
hit_anykey2_str: .text @" IN TOP LEFT CORNER\$00"
hit_anykey3_str: .text @"  PRESS Q  TO QUIT\$00"
hit_anykey_to_start_str: .text @"HIT ANY KEY TO START\$00"


*=$1000 "Main Start"
    nv_key_init()

    nv_screen_clear()
    nv_screen_plot_cursor(0, 27)
    nv_screen_print_str(title_str)

    nv_screen_plot_cursor(10, 10)
    nv_screen_print_str(hit_anykey_to_start_str)
    nv_key_wait_anykey()
    nv_screen_clear()
    nv_screen_plot_cursor(0, 27)
    nv_screen_print_str(title_str)

    nv_screen_plot_cursor(10, 10)
    nv_screen_print_str(hit_anykey1_str)
    nv_screen_plot_cursor(11, 10)
    nv_screen_print_str(hit_anykey2_str)
    nv_screen_plot_cursor(12, 10)
    nv_screen_print_str(hit_anykey3_str)


TopLoop:
    lda #NV_COLOR_LITE_BLUE                // change border color back to
    sta $D020                              // visualize timing

    nv_sprite_wait_last_scanline()

    lda #NV_COLOR_GREEN                    // change border color back to
    sta $D020                              // visualize timing

    nv_key_scan()
    nv_key_get_last_pressed_a(true)
    nv_screen_poke_char_a(0, 0)
    cmp #NV_KEY_Q
    beq Done
    jmp TopLoop

Done:
    lda #NV_COLOR_LITE_BLUE                // change border color back to
    sta $D020                              // visualize timing

    nv_key_done()
    rts

