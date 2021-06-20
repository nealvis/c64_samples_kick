// nv_c64_util
// screen releated stuff

#importonce

#import "nv_util_data.asm"

.const NV_SCREEN_PRINT_STRING_BASIC_ADDR = $AB1E    // Basic routine to print text
.const NV_SCREEN_CLEAR_KERNAL_ADDR = $E544   // Kernal clear screen addr
.const NV_SCREEN_CURSOR_ROW_ADDR = 214              // current cursor row
.const NV_SCREEN_CURSOR_COL_ADDR = 211              // current cursor col
.const NV_SCREEN_PLOT_CURSOR_KERNAL_ADDR = $FFF0    // kernal jmp table routine to 
                                             // read/write cursor locaction.
                                             // jumps to $E50A where real routine is.



// clear screen and leave cursor in upper left
.macro nv_screen_clear()
{
    // call Kernal routine to clear screeen leave cursor upper left
    jsr NV_SCREEN_CLEAR_KERNAL_ADDR     
}


// move cursor to specified row
.macro nv_screen_plot_cursor_row(new_row)
{
    sec                                     // set carry to get current position
    jsr NV_SCREEN_PLOT_CURSOR_KERNAL_ADDR   // call to get cur pos in x and y regs
    ldx #new_row                            // set x reg to new row
    clc                                     // clear carry to set new location
    jsr NV_SCREEN_PLOT_CURSOR_KERNAL_ADDR   // call to set the cur position with x/y regs
}


// move cursor to specified row
.macro nv_screen_plot_cursor_col(new_col)
{
    sec                                     // set carry to get current position
    jsr NV_SCREEN_PLOT_CURSOR_KERNAL_ADDR   // call to get cur position in x and y reg
    ldy #new_col                            // set new col in y reg
    clc                                     // clear carry to set new location
    jsr NV_SCREEN_PLOT_CURSOR_KERNAL_ADDR          // call to set the cur position with x/y regs
}


// move cursor to specified srow and col
.macro nv_screen_plot_cursor(new_row, new_col)
{
    clc                                     // clear carry to specify setting position
    ldx #new_row                            // load X reg with new row position
    ldy #new_col                            // load Y reg with new col position
    jsr NV_SCREEN_PLOT_CURSOR_KERNAL_ADDR   // call kernal function to plot cursor
} 


// print a null terminated string to the current cursor location
.macro nv_screen_print_string_basic(str_to_print_addr)
{
    lda #<str_to_print_addr                 // LSB of addr of string to print to A
    ldy #>str_to_print_addr                 // MSB of addr of str to print to Y
    jsr NV_SCREEN_PRINT_STRING_BASIC_ADDR   // call kernal routine to print the string
}


//////////////////////////////////////////////////////////////////////////
// inline macro to print a hex number that is in the accumulator
//   include_dollar: pass true to print a '$' before the number
.macro nv_screen_print_hex_byte(include_dollar)
{
    .var offset = 0
    .if (include_dollar)
    {
        .eval offset++
        ldy #$24            // dollar sign
        sty temp_hex_str
    }
    tay
    ror 
    ror 
    ror 
    ror  
    and #$0f
    tax
    lda hex_digit_lookup, x
    sta temp_hex_str+offset
    tya
    and #$0f
    tax
    lda hex_digit_lookup, x
    sta temp_hex_str+1+offset
    lda #0
    sta temp_hex_str + 2 + offset
    nv_screen_print_string_basic(temp_hex_str) 
}

.macro nv_screen_print_hex_byte_at_addr(addr, include_dollar)
{
    lda addr
    nv_screen_print_hex_byte(include_dollar)
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to print the word value at the address of the low byte given
.macro nv_screen_print_hex_word(word_low_byte_addr, include_dollar)
{
    .if (include_dollar)
    {
        lda #$24                // the $ sign
        sta temp_hex_str
        lda #0
        sta temp_hex_str+1
        nv_screen_print_string_basic(temp_hex_str)
    }
    lda word_low_byte_addr+1
    nv_screen_print_hex_byte(false)
    lda word_low_byte_addr
    nv_screen_print_hex_byte(false)
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to print the word value at the address of the low byte given
.macro nv_screen_print_hex_word_immediate(num, include_dollar)
{
    .if (include_dollar)
    {
        lda #$24                // the $ sign
        sta temp_hex_str
        lda #0
        sta temp_hex_str+1
        nv_screen_print_string_basic(temp_hex_str)
    }
    lda #((num >> 8) & $00ff)
    nv_screen_print_hex_byte(false)
    lda #(num & $00ff)
    nv_screen_print_hex_byte(false)
}


//////////////////////////////////////////////////////////////////////////////
// wait for a key to be pressed.
// The Accum and X reg will be modified 
.macro nv_screen_wait_anykey()
{
OuterLoop:
    ldx #20         // wait for the specific scanline this many times

InnerLoop:

ScanLoop:
    lda $D012
    cmp #$fa
    bne ScanLoop

    dex
    bne InnerLoop

    lda 203
    cmp #64
    beq OuterLoop
}