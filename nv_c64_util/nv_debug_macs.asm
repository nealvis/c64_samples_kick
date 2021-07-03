#importonce

#if !NV_C64_UTIL_DATA
.error "Error - nv_debug_macs.asm: NV_C64_UTIL_DATA not defined.  Import nv_c64_util_data.asm"
#endif

#import "nv_screen_macs.asm"

//////////////////////////////////////////////////////////////////////////////
// inline macro to print a byte in memory at a specified position
// on the screen
// macro params:
//   row: row position on screen to print at
//   col: col position on screen to print at
//   addr: address of the byte to print
//   include_dollar: pass true for preceding '$'
//   wait: pass true to wait for a key after printing
.macro nv_debug_print_byte_basic(row, col, addr, include_dollar, wait)
{
    nv_debug_save_state()

    nv_screen_plot_cursor(row, col)
    nv_screen_print_hex_byte_at_addr(addr, include_dollar)

    .if (wait != false)
    {
            nv_screen_wait_anykey()
    }

    nv_debug_restore_state()
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to print a byte in memory at a specified position
// on the screen
// macro params:
//   row: row position on screen to print at
//   col: col position on screen to print at
//   addr: address of the byte to print
//   include_dollar: pass true for preceding '$'
//   wait: pass true to wait for a key after printing
.macro nv_debug_print_byte(row, col, addr, include_dollar, wait)
{
    nv_debug_save_state()

    nv_screen_plot_cursor(row, col)
    nv_screen_print_hex_byte_at_addr(addr, include_dollar)

    .if (wait != false)
    {
            nv_screen_wait_anykey()
    }

    nv_debug_restore_state()
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to print a byte in accum at a specified position
// on the screen
// macro params:
//   row: row position on screen to print at
//   col: col position on screen to print at
//   include_dollar: pass true for preceding '$'
//   wait: pass true to wait for a key after printing
// Reg params:
//   Accum must have the byte to print
.macro nv_debug_print_byte_a(row, col, include_dollar, wait)
{
    nv_debug_save_state()

    nv_screen_plot_cursor(row, col)
    nv_screen_print_hex_byte(include_dollar)
    .if (wait != false)
    {
            nv_screen_wait_anykey()
    }

    nv_debug_restore_state()
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to print an immediate byte value at a specified position
// on the screen
// macro params:
//   row: row position on screen to print at
//   col: col position on screen to print at
//   immed_value: The 8 bit value to print
//   include_dollar: pass true for preceding '$'
//   wait: pass true to wait for a key after printing
.macro nv_debug_print_byte_immediate(row, col, immed_value, include_dollar, wait)
{
    nv_debug_save_state()

    nv_screen_plot_cursor(row, col)
    nv_screen_print_hex_word_immediate(immed_value, include_dollar)
    .if (wait != false)
    {
            nv_screen_wait_anykey()
    }

    nv_debug_restore_state()
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
    nv_debug_save_state()

    nv_screen_poke(row, col, str)

    .if (wait != false)
    {
            nv_screen_wait_anykey()
    }

    nv_debug_restore_state()
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to save state to stack
.macro nv_debug_save_state()
{
    php     // push processor status flags
    pha     // push Accum
    txa     
    pha     // push X reg
    tya
    pha     // push Y reg
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

