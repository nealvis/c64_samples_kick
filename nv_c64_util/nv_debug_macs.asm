#importonce

#if !NV_C64_UTIL_DATA
.error "Error - nv_debug_macs.asm: NV_C64_UTIL_DATA not defined.  Import nv_c64_util_data.asm"
#endif

#import "nv_screen_macs.asm"

//////////////////////////////////////////////////////////////////////////////
//
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
//
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
//
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
//
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
//
.macro nv_debug_restore_state()
{
    pla     // pull Y 
    tay 
    pla     // pull X
    tax
    pla     // pull accum
    plp     // pull processor status flags
}

