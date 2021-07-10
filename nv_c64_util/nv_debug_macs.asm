#importonce

#if !NV_C64_UTIL_DATA
.error "Error - nv_debug_macs.asm: NV_C64_UTIL_DATA not defined.  Import nv_c64_util_data.asm"
#endif

// the #if above doesn't seem to always work so..
// if data hasn't been imported yet, import it into default location
#importif !NV_C64_UTIL_DATA "nv_c64_util_default_data.asm"


#import "nv_screen_macs.asm"

//#define DEBUG_ON
.var DEBUG_ON = true

//////////////////////////////////////////////////////////////////////////////
// inline macro to print hex val of  byte in memory at a specified position
// on the screen.  Uses BASIC routine rather than poking to screen
// macro params:
//   row: row position on screen to print at
//   col: col position on screen to print at
//   addr: address of the byte to print
//   include_dollar: pass true for preceding '$'
//   wait: pass true to wait for a key after printing
.macro nv_debug_print_byte_mem_basic(row, col, addr, include_dollar, wait)
{
    .if (DEBUG_ON)
    {
        nv_debug_save_state()

        nv_screen_plot_cursor(row, col)
        nv_screen_print_hex_byte_mem(addr, include_dollar)

        .if (wait != false)
        {
                nv_screen_wait_anykey()
        }

        nv_debug_restore_state()
    }
    //#endif
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to print hex val of immediate byte value at a specified pos
// on the screen.  Uses BASIC routine rather than poking to screen
// macro params:
//   row: row position on screen to print at
//   col: col position on screen to print at
//   immed_value: The 8 bit value to print
//   include_dollar: pass true for preceding '$'
//   wait: pass true to wait for a key after printing
.macro nv_debug_print_byte_immed_basic(row, col, immed_value, include_dollar, wait)
{
    .if (DEBUG_ON)
    {
        nv_debug_save_state()

        nv_screen_plot_cursor(row, col)
        nv_screen_print_hex_word_immed(immed_value, include_dollar)

        .if (wait)
        {
                nv_screen_wait_anykey()
        }

        nv_debug_restore_state()
    }
    //#endif
}



//////////////////////////////////////////////////////////////////////////////
// Below here are screen poke debug routines
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// inline macro to print hex val of byte in memory at a specified position
// on the screen.  Pokes directly to screen
// macro params:
//   row: row position on screen to print at
//   col: col position on screen to print at
//   addr: address of the byte to print
//   include_dollar: pass true for preceding '$'
//   wait: pass true to wait for a key after printing
.macro nv_debug_print_byte_mem(row, col, addr, include_dollar, wait)
{
    .if (DEBUG_ON)
    {
        nv_debug_save_state()

        nv_screen_poke_hex_byte_mem(row, col, addr, include_dollar)

        .if (wait != false)
        {
            nv_screen_wait_anykey()
        }

        nv_debug_restore_state()
    }
    //#endif
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to print hex val of byte in memory at a specified position
// on the screen.  Pokes directly to screen
// macro params:
//   row: row position on screen to print at
//   col: col position on screen to print at
//   addr: address of the LSB of word to print
//   include_dollar: pass true for preceding '$'
//   wait: pass true to wait for a key after printing
.macro nv_debug_print_word_mem(row, col, addr, include_dollar, wait)
{
    .if (DEBUG_ON)
    {
        nv_debug_save_state()

        .var col2 = col
        .if (include_dollar)
        {
            .eval col2 = col2 + 3
        }
        else
        {
            .eval col2 = col2 + 2
        }

        nv_screen_poke_hex_byte_mem(row, col, addr+1, include_dollar)
        nv_screen_poke_hex_byte_mem(row, col2, addr, false)

        .if (wait != false)
        {
            nv_screen_wait_anykey()
        }

        nv_debug_restore_state()
    }
    //#endif
}



//////////////////////////////////////////////////////////////////////////////
// inline macro to print hex value of byte in accum at a specified position
// on the screen.  Pokes directly to screen memory to print
// macro params:
//   row: row position on screen to print at
//   col: col position on screen to print at
//   include_dollar: pass true for preceding '$'
//   wait: pass true to wait for a key after printing
// Reg params:
//   Accum must have the byte to print
.macro nv_debug_print_byte_a(row, col, include_dollar, wait)
{
    .if (DEBUG_ON)
    {
        nv_debug_save_state()

        nv_screen_poke_hex_byte_a(row, col, include_dollar)
        
        .if (wait != false)
        {
                nv_screen_wait_anykey()
        }

        nv_debug_restore_state()
    }
    //#endif
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to print a null terminated string to the 
// screen for debugging.
//   row: row position on screen to print at
//   col: col position on screen to print at
//   str: The address of the 0 terminated string to print
//   wait: pass true to wait for a key after printing
.macro nv_debug_print_str(row, col, str, wait)
{
    .if (DEBUG_ON)
    {
        nv_debug_save_state()

        nv_screen_poke_str(row, col, str)

        .if (wait != false)
        {
            nv_screen_wait_anykey()
        }

        nv_debug_restore_state()
    }
    //#endif
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to print an immediate 8 bit value at a specified position
// on the screen in hex.
// macro params:
//   row: row position on screen to print at
//   col: col position on screen to print at
//   immed_value: The 8 bit value to print
//   include_dollar: pass true for preceding '$'
//   wait: pass true to wait for a key after printing
.macro nv_debug_print_byte_immed(row, col, immed_value, include_dollar, wait)
{
    .if (DEBUG_ON)
    {
        nv_debug_save_state()

        nv_screen_poke_hex_byte_immed(row, col, immed_value, include_dollar)

        .if (wait)
        {
            nv_screen_wait_anykey()
        }

        nv_debug_restore_state()
    }
    //#endif
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to print an immediate 16 bit value at a specified position
// on the screen in hex
// macro params:
//   row: row position on screen to print at
//   col: col position on screen to print at
//   immed_value: The 16 bit value to print
//   include_dollar: pass true for preceding '$'
//   wait: pass true to wait for a key after printing
.macro nv_debug_print_word_immed(row, col, immed_value, include_dollar, wait)
{
    .if (DEBUG_ON)
    {
        nv_debug_save_state()

        nv_screen_poke_hex_word_immed(row, col, immed_value, include_dollar)

        .if (wait)
        {
                nv_screen_wait_anykey()
        }

        nv_debug_restore_state()
    }
    //#endif
}

//////////////////////////////////////////////////////////////////////////////
// get number of chars in zero terminated string
// macro params: 
//   str_addr: the address in memory of the first char of the string
// X Reg: will hold the length of the string upon return.
.macro nv_string_get_len(str_addr)
{
    ldx #0
Loop:
    lda str_addr, x
    beq Done
    inx
    jmp Loop
Done:
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to print a labeled byte from memory on the screen.
// at a specified position.  Will look like this on screen: 
// LABEL: $03
// macro params:
//   row: row position on screen to print at
//   col: col position on screen to print at
//   label_addr: the address of the first char of label string.
//               this string must be zero terminated.
//   value_addr: The address of the byte that holds the value to print
//   include_dollar: pass true for preceding '$'
//   wait: pass true to wait for a key after printing
.macro nv_debug_print_labeled_byte_mem(row, col, label_addr, label_len, value_addr, 
                                       include_dollar, wait)
{
    .if (DEBUG_ON)
    {
        nv_debug_save_state()

        //nv_string_get_len(label_addr)

        nv_screen_poke_str(row, col, label_addr)
        nv_screen_poke_hex_byte_mem(row, col+label_len+1, value_addr, include_dollar)

        .if (wait)
        {
            nv_screen_wait_anykey()
        }

        nv_debug_restore_state()
    }
    //#endif
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to print a labeled byte from memory on the screen.
// at a specified position.  Will look like this on screen: 
// LABEL: $0332
// macro params:
//   row: row position on screen to print at
//   col: col position on screen to print at
//   label_addr: the address of the first char of label string.
//               this string must be zero terminated.
//   label_len: the lenght of the label passed in chars
//   value_addr: The address of the byte that holds the value to print
//   include_dollar: pass true for preceding '$'
//   wait: pass true to wait for a key after printing
.macro nv_debug_print_labeled_word_mem(row, col, label_addr, 
                                       label_len, value_addr, 
                                       include_dollar, wait)
{
    .if (DEBUG_ON)
    {
        nv_debug_save_state()

        .var offset = 2
        .if (include_dollar)
        {
            .eval offset = offset +1
        }

        nv_screen_poke_str(row, col, label_addr)
        nv_screen_poke_hex_byte_mem(row, col+label_len+1, value_addr+1, include_dollar)
        nv_screen_poke_hex_byte_mem(row, col+label_len+1+offset, value_addr, false)

        .if (wait)
        {
            nv_screen_wait_anykey()
        }

        nv_debug_restore_state()
    }
    //#endif
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to print a single char to the screen at specified location.
.macro nv_debug_print_char_a(row, col)
{
    .if (DEBUG_ON)
    {
        nv_debug_save_state()

        nv_screen_poke_char_a(row, col)

        nv_debug_restore_state()
    }
    //#endif
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to save state to stack
.macro nv_debug_save_state()
{
    php     // push processor status flags
    pha     // push Accum
    sta nv_debug_save_a // save a
    txa     
    pha     // push X reg
    tya
    pha     // push Y reg
    lda nv_debug_save_a // restore a
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to restore state of stack after calling
// nv_debug_save_state
.macro nv_debug_restore_state()
{
    pla     // pull Y 
    tay 
    pla     // pull X
    tax
    pla     // pull accum
    plp     // pull processor status flags
}

