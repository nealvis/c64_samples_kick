// nv_c64_util
// screen releated stuff

#importonce

.const NV_PRINT_STRING_BASIC_ADDR = $AB1E    // Basic routine to print text
.const NV_CLEAR_SCREEN_KERNAL_ADDR = $E544   // Kernal clear screen addr
.const NV_CURSOR_ROW_ADDR = 214              // current cursor row
.const NV_CURSOR_COL_ADDR = 211              // current cursor col
.const NV_PLOT_CURSOR_KERNAL_ADDR = $FFF0    // kernal jmp table routine to 
                                             // read/write cursor locaction.
                                             // jumps to $E50A where real routine is.


// clear screen and leave cursor in upper left
.macro nv_clear_screen()
{
    // call Kernal routine to clear screeen leave cursor upper left
    jsr NV_CLEAR_SCREEN_KERNAL_ADDR     
}


// move cursor to specified row
.macro nv_plot_cursor_row(new_row)
{
    sec                             // set carry to get current position
    jsr NV_PLOT_CURSOR_KERNAL_ADDR  // call to get cur pos in x and y regs
    ldx #new_row                    // set x reg to new row
    clc                             // clear carry to set new location
    jsr NV_PLOT_CURSOR_KERNAL_ADDR  // call to set the cur position with x/y regs
}


// move cursor to specified row
.macro nv_plot_cursor_col(new_col)
{
    sec                             // set carry to get current position
    jsr NV_PLOT_CURSOR_KERNAL_ADDR  // call to get cur position in x and y reg
    ldy #new_col                    // set new col in y reg
    clc                             // clear carry to set new location
    jsr NV_PLOT_CURSOR_KERNAL_ADDR  // call to set the cur position with x/y regs
}


// move cursor to specified srow and col
.macro nv_plot_cursor(new_row, new_col)
{
    clc                             // clear carry to specify setting position
    ldx #new_row                    // load X reg with new row position
    ldy #new_col                    // load Y reg with new col position
    jsr NV_PLOT_CURSOR_KERNAL_ADDR  // call kernal function to plot cursor
} 


// print a null terminated string to the current cursor location
.macro nv_print_string_basic(str_to_print_addr)
{
    lda #<str_to_print_addr           // LSB of addr of string to print to A
    ldy #>str_to_print_addr           // MSB of addr of str to print to Y
    jsr NV_PRINT_STRING_BASIC_ADDR    // call kernal routine to print the string
}

