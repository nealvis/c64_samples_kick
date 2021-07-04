#importonce

#if !NV_C64_UTIL_DATA
.error "Error - nv_debug_code.asm: NV_C64_UTIL_DATA not defined.  Import nv_c64_util_data.asm"
#endif

#import "nv_debug_macs.asm"
#import "nv_screen_macs.asm"
#import "nv_screen_code.asm"

/*
here_str: .text @"HERE \$00"
clear_here_str: .text @"     \$00"

here1_str: .text @"HERE 1 \$00"
here2_str: .text @"HERE 2 \$00"
here3_str: .text @"HERE 3 \$00"
here4_str: .text @"HERE 4 \$00"
here5_str: .text @"HERE 5 \$00"
here6_str: .text @"HERE 6 \$00"
here7_str: .text @"HERE 7 \$00"


//////////////////////////////////////////////////////////////////////////////
//
.macro nv_debug_print_here(row, col, wait)
{
    nv_debug_save_state()

    nv_screen_plot_cursor(row, col)
    nv_screen_print_string_basic(here_str)
    .if (wait != false)
    {
            nv_screen_wait_anykey()
    }
    nv_screen_plot_cursor(row, col)
    nv_screen_print_string_basic(clear_here_str)

    nv_debug_restore_state()
}


//////////////////////////////////////////////////////////////////////////////
//
.macro nv_debug_print_here_immediate(row, col, immed_value)
{
    nv_debug_save_state()

    nv_screen_plot_cursor(row, col)
    nv_screen_print_string_basic(here_str)
    nv_screen_print_hex_word_immediate(immed_value, true)
    nv_screen_wait_anykey()
    nv_debug_restore_state()
}
*/

//////////////////////////////////////////////////////////////////////////////
// subroutine macro to print labeled value of a byte from memory 
// on the screen at a specified position.  Will look like this on screen: 
// LABEL: $03
// macro params:
//   nv_a8: row position on screen to print at
//   nv_b8: col position on screen to print at
//   nv_a16: the address of the first char of label string.
//           this string must be zero terminated.
//   nv_e8: pass true to wait for a key after printing
.macro nv_debug_print_str_sr()
{
    nv_debug_save_state()

    // note that parameters are already set as follows
    //   nv_a8: row position on screen to print at
    //   nv_b8: col position on screen to print at
    //   nv_a16: the address of the first char of string.
    //           this string must be zero terminated.
    jsr NvScreenPokeString

    lda nv_e8
    beq NoWait
Wait:
    nv_screen_wait_anykey()

NoWait:
    nv_debug_restore_state()
    rts
}


//////////////////////////////////////////////////////////////////////////////
// Subroutine macro to print the hex value of a byte in a particular 
// memory location to the screen.
// Subroutine Parameters
//   nv_a8: row position on screen to print at
//   nv_b8: col position on screen to print at
//   nv_c8: the byte  to print.
//   nv_d8: set to 1 to include dollar sign
//   nv_e8: pass true to wait for a key after printing
.macro nv_debug_print_hex_byte_sr()
{
    nv_debug_save_state()

    //   nv_a8: row position on screen to print at
    //   nv_b8: col position on screen to print at
    //   nv_c8: the byte to print should be loaded here
    //   nv_d8: set to 1 to include dollar sign
    jsr NvScreenPokeHexByte

    lda nv_e8
    beq NoWait
Wait:
    nv_screen_wait_anykey()

NoWait:
    nv_debug_restore_state()

    rts
}


//////////////////////////////////////////////////////////////////////////////
// Subroutine macro to print the hex value of a byte in a particular 
// memory location to the screen.
// Subroutine Parameters
//   nv_a8: row position on screen to print at
//   nv_b8: col position on screen to print at
//   nv_c16: the word  to print.
//   nv_d8: set to 1 to include dollar sign
//   nv_e8: pass true to wait for a key after printing
.macro nv_debug_print_hex_word_sr()
{
    nv_debug_save_state()

    //   nv_a8: row position on screen to print at
    //   nv_b8: col position on screen to print at
    //   nv_c16: the word to print should be loaded here
    //   nv_d8: set to 1 to include dollar sign
    jsr NvScreenPokeHexWord

    lda nv_e8
    beq NoWait
Wait:
    nv_screen_wait_anykey()

NoWait:
    nv_debug_restore_state()

    rts
}


//////////////////////////////////////////////////////////////////////////////
// subroutine macro to print labeled value of a byte from memory 
// on the screen at a specified position.  Will look like this on screen: 
// LABEL $03
// macro params:
//   nv_a8: row position on screen to print at
//   nv_b8: col position on screen to print at
//   nv_a16: the address of the first char of label string.
//           this string must be zero terminated.
//   nv_c8: The byte  to print
//   nv_d8: pass 1 for preceding '$'
//   nv_e8: pass true to wait for a key after printing
.macro nv_debug_print_labeled_byte_sr()
{
    nv_debug_save_state()

    lda nv_b8
    sta save_b8

    // gets the length of null terminated string pointed to by
    // nv_a16 and puts it in Y register
    jsr NvStringGetLen
    sty label_len

    // setup and call routine to print the label
    // note that parameters are already set as follows
    //   nv_a8: row position on screen to print at
    //   nv_b8: col position on screen to print at
    //   nv_a16: the address of the first char of string.
    //           this string must be zero terminated.
    jsr NvScreenPokeString

    // setup and call routine to print the byte value
    //   nv_a8: row position, already set
    //   nv_b8: col position, add label_len to it
    //   nv_c8: the byte to print, already set
    //   nv_d8: set to 1 to include dollar sign, already set
    lda label_len
    sec
    adc nv_b8
    sta nv_b8
    jsr NvScreenPokeHexByte

    lda nv_e8
    beq NoWait
Wait:
    nv_screen_wait_anykey()

NoWait:

    lda save_b8
    sta nv_b8
    nv_debug_restore_state()
    rts

    // subroutine variables
    label_len: .byte 0

    // save nv_b8
    save_b8: .byte 0
}

//////////////////////////////////////////////////////////////////////////////
// subroutine macro to print labeled value of a byte from memory 
// on the screen at a specified position.  Will look like this on screen: 
// LABEL $03
// macro params:
//   nv_a8: row position on screen to print at
//   nv_b8: col position on screen to print at
//   nv_a16: the address of the first char of label string.
//           this string must be zero terminated.
//   nv_c8: The byte  to print
//   nv_d8: pass 1 for preceding '$'
//   nv_e8: pass true to wait for a key after printing
.macro nv_debug_print_labeled_word_sr()
{
    nv_debug_save_state()

    // save col because we need to modify it
    lda nv_b8
    sta save_b8

    // gets the length of null terminated string pointed to by
    // nv_a16 and puts it in Y register
    jsr NvStringGetLen
    sty label_len

    // setup and call routine to print the label
    // note that parameters are already set as follows
    //   nv_a8: row position on screen to print at
    //   nv_b8: col position on screen to print at
    //   nv_a16: the address of the first char of string.
    //           this string must be zero terminated.
    jsr NvScreenPokeString

    // setup and call routine to print the byte value
    //   nv_a8: row position, already set
    //   nv_b8: col position, add label_len to it
    //   nv_c16: the word to print, already set
    //   nv_d8: set to 1 to include dollar sign, already set
    lda label_len
    sec
    adc nv_b8
    sta nv_b8
    jsr NvScreenPokeHexWord

    lda nv_e8
    beq NoWait
Wait:
    nv_screen_wait_anykey()

NoWait:

    lda save_b8
    sta nv_b8
    nv_debug_restore_state()
    rts

    // subroutine variables
    label_len: .byte 0

    // save nv_b8
    save_b8: .byte 0
}


//////////////////////////////////////////////////////////////////////////////
// subroutine macro to get number of chars in zero terminated string
// params: 
//   nv_a16: the address of the first char of label string.
//           this string must be zero terminated.
//   Y Reg: will hold the length of the string upon return.
.macro nv_string_get_len_sr()
{
    // two zero page bytes to use as a pointer
    .const ZERO_PAGE_LO = $FB
    .const ZERO_PAGE_HI = $FC
    
    // save the zero page bytes that we use
    lda ZERO_PAGE_LO 
    sta save_zero_lo
    lda ZERO_PAGE_HI
    sta save_zero_hi

    // load pointer to string base
    lda nv_a16 
    sta ZERO_PAGE_LO
    lda nv_a16+1
    sta ZERO_PAGE_HI


    ldy #0
Loop:
    lda (ZERO_PAGE_LO),y
    beq Done
    iny
    jmp Loop
Done:

    // restore the zero page bytes that we used 
    lda save_zero_hi
    sta ZERO_PAGE_HI
    lda save_zero_lo
    sta ZERO_PAGE_LO

    rts
    // routine variables
    save_zero_lo: .byte 0
    save_zero_hi: .byte 0
}

//////////////////////////////////////////////////////////////////////////////
// instantiated subroutines below here
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
//   nv_a16: the address of the first char of label string.
//           this string must be zero terminated.
//   Y Reg: will hold the length of the string upon return.
NvStringGetLen:
    nv_string_get_len_sr()



//////////////////////////////////////////////////////////////////////////////
//   nv_a8: row position on screen to print at
//   nv_b8: col position on screen to print at
//   nv_a16: the address of the first char of label string.
//           this string must be zero terminated.
//   nv_c8: The byte to print
//   nv_d8: pass 1 for preceding '$'
//   nv_e8: pass true to wait for a key after printing
NvDebugPrintLabeledByte:
    nv_debug_print_labeled_byte_sr()

//////////////////////////////////////////////////////////////////////////////
//   nv_a8: row position on screen to print at
//   nv_b8: col position on screen to print at
//   nv_a16: the address of the first char of label string.
//           this string must be zero terminated.
//   nv_c16: The LSB of the word to print
//   nv_d8: pass 1 for preceding '$'
//   nv_e8: pass true to wait for a key after printing
NvDebugPrintLabeledWord:
    nv_debug_print_labeled_word_sr()


//////////////////////////////////////////////////////////////////////////////
//   nv_a8: row position on screen to print at
//   nv_b8: col position on screen to print at
//   nv_a16: the address of the first char of label string.
//           this string must be zero terminated.
//   nv_e8: pass true to wait for a key after printing
NvDebugPrintStr:
    nv_debug_print_str_sr()


//////////////////////////////////////////////////////////////////////////////
// Subroutine to print the hex value of a byte in memory to the screen
//   nv_a8: row position on screen to print at
//   nv_b8: col position on screen to print at
//   nv_c8: the byte in memory to print.
//   nv_d8: set to 1 to include dollar sign
//   nv_e8: pass true to wait for a key after printing
NvDebugPrintHexByte:
    nv_debug_print_hex_byte_sr()

//////////////////////////////////////////////////////////////////////////////
// Subroutine to print the hex value of a byte in memory to the screen
//   nv_a8: row position on screen to print at
//   nv_b8: col position on screen to print at
//   nv_c16: the word in memory to print.
//   nv_d8: set to 1 to include dollar sign
//   nv_e8: pass true to wait for a key after printing
NvDebugPrintHexWord:
    nv_debug_print_hex_word_sr()

//////////////////////////////////////////////////////////////////////////////
//NvDebugPrintHere:
//    nv_debug_print_here(0, 0, true)
//    rts

//////////////////////////////////////////////////////////////////////////////
//NvDebugPrintByte:
//    nv_debug_print_byte_a(0, 0, true, true)
//    rts

/*
NvDebugPrintHere1:
    nv_debug_print_here_immediate(0, 0, 1)
    rts    

NvDebugPrintHere2:
    nv_debug_print_here_immediate(0, 0, 2)
    rts    

NvDebugPrintHere3:
    nv_debug_print_here_immediate(0, 0, 3)
    rts    

NvDebugPrintHere4:
    nv_debug_print_here_immediate(0, 0, 4)
    rts    

NvDebugPrintHere5:
    nv_debug_print_here_immediate(0, 0, 5)
    rts    

NvDebugPrintHere6:
    nv_debug_print_here_immediate(0, 0, 6)
    rts    

NvDebugPrintHere7:
    nv_debug_print_here_immediate(0, 0, 7)
    rts    
*/
