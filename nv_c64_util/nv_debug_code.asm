#importonce

#if !NV_C64_UTIL_DATA
.error("Error - nv_debug_code.asm: NV_C64_UTIL_DATA not defined.  Import nv_c64_util_data.asm")
#endif

#import "nv_debug_macs.asm"
#import "nv_screen_macs.asm"

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

/*
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



NvDebugPrintHere:
    nv_debug_print_here(0, 0, true)
    rts

NvDebugPrintByte:
    nv_debug_print_byte_a(0, 0, true, true)
    rts

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
