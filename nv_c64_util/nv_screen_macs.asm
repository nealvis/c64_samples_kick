// nv_screen_macs.asm
// inline macros for screen releated functions
// importing this file will not generate any code or data directly

#importonce

#if !NV_C64_UTIL_DATA
.error "Error - nv_screen_macs.asm: NV_C64_UTIL_DATA not defined.  Import nv_c64_util_data.asm"
#endif

// the #if above doesn't seem to always work so..
// if data hasn't been imported yet, import it into default location
#importif !NV_C64_UTIL_DATA "nv_c64_util_default_data.asm"


// Basic routine to print text
.const NV_SCREEN_PRINT_STRING_BASIC_ADDR = $AB1E    

// Kernal clear screen addr
.const NV_SCREEN_CLEAR_KERNAL_ADDR = $E544   

// current cursor row
.const NV_SCREEN_CURSOR_ROW_ADDR = 214 

// current cursor col
.const NV_SCREEN_CURSOR_COL_ADDR = 211              

// kernal jmp table routine to read/write cursor locaction.
// jumps to $E50A where real routine is.
.const NV_SCREEN_PLOT_CURSOR_KERNAL_ADDR = $FFF0    

// The start of c64 screen memory.  its 1000 bytes long
.const SCREEN_START = $0400

// the start of character color memory
.const SCREEN_COLOR_START = $D800

// a somewhat random location in screen memory to write to directly
.const SCREEN_DIRECT_START = SCREEN_START + $0100 

.const NV_SCREEN_BORDER_COLOR_REG_ADDR = $D020
.const NV_SCREEN_BACKGROUND_COLOR_REG_ADDR = $D021


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

//////////////////////////////////////////////////////////////////////////////
// inline macro to print a null terminated string to the current 
// cursor location.  Uses BASIC routine to do it.
.macro nv_screen_print_str(str_to_print_addr)
{
    lda #<str_to_print_addr                 // LSB of addr of string to print to A
    ldy #>str_to_print_addr                 // MSB of addr of str to print to Y
    jsr NV_SCREEN_PRINT_STRING_BASIC_ADDR   // call kernal routine to print the string
}


//////////////////////////////////////////////////////////////////////////
// inline macro to print a hex number that is in the accumulator
//   include_dollar: pass true to print a '$' before the number
.macro nv_screen_print_hex_byte_a(include_dollar)
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
    nv_screen_print_str(temp_hex_str) 
}

//////////////////////////////////////////////////////////////////////////////
.macro nv_screen_print_hex_byte_mem(addr, include_dollar)
{
    lda addr
    nv_screen_print_hex_byte_a(include_dollar)
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to print the word value at the address of the low byte given
.macro nv_screen_print_hex_word_mem(word_low_byte_addr, include_dollar)
{
    .if (include_dollar)
    {
        lda #$24                // the $ sign
        sta temp_hex_str
        lda #0
        sta temp_hex_str+1
        nv_screen_print_str(temp_hex_str)
    }
    lda word_low_byte_addr+1
    nv_screen_print_hex_byte_a(false)
    lda word_low_byte_addr
    nv_screen_print_hex_byte_a(false)
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to print the word value at the address of the low byte given
.macro nv_screen_print_hex_word_immed(num, include_dollar)
{
    .if (include_dollar)
    {
        lda #$24                // the $ sign
        sta temp_hex_str
        lda #0
        sta temp_hex_str+1
        nv_screen_print_str(temp_hex_str)
    }
    lda #((num >> 8) & $00ff)
    nv_screen_print_hex_byte_a(false)
    lda #(num & $00ff)
    nv_screen_print_hex_byte_a(false)
}


//////////////////////////////////////////////////////////////////////////////
//                Below here is direct to screen
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// inline macro to poke chars for a string to screen memory
.macro nv_screen_poke_str(row, col, str_to_poke)
{
    .var screen_poke_start = SCREEN_START + (40*row) + col 
    
    ldx #0                  // use x reg as loop index start at 0
DirectLoop:
    lda str_to_poke,x       // put a byte from string into accum
    beq Done                // if the byte was 0 then we're done 
    sta screen_poke_start,x  // Store the byte to screen
    inx                     // inc to next byte and next screen location 
    jmp DirectLoop          // Go back for next byte
Done:
}


//////////////////////////////////////////////////////////////////////////
// inline macro to poke a single char to the screen at row/col
// does not change any registers
// macro params:
//   row: screen row (0-24)
//   col: screen col (0-39)
//   Accum: the char to poke
.macro nv_screen_poke_char_a(row, col)
{
    .var screen_poke_start = SCREEN_START + (40*row) + col 
    sta screen_poke_start
}

//////////////////////////////////////////////////////////////////////////
// inline macro to poke a single char to the screen at row/col
// does not change any registers
// macro params:
//   row: screen row (0-24)
//   col: screen col (0-39)
//   Y Reg: the char to poke
.macro nv_screen_poke_char_y(row, col)
{
    .var screen_poke_start = SCREEN_START + (40*row) + col 
    sty screen_poke_start
}

//////////////////////////////////////////////////////////////////////////
// inline macro to poke a single char to the screen at row/col
// does not change any registers
// macro params:
//   row: screen row (0-24)
//   col: screen col (0-39)
//   X Reg: the char to poke
.macro nv_screen_poke_char_x(row, col)
{
    .var screen_poke_start = SCREEN_START + (40*row) + col 
    stx screen_poke_start
}


//////////////////////////////////////////////////////////////////////////
// inline macro to poke a the foreground color for a char to the 
// screen at row/col
// does not change any registers
// macro params:
//   row: screen row (0-24)
//   col: screen col (0-39)
//   Accum: the char to poke
.macro nv_screen_poke_color_a(row, col)
{
    .var screen_poke_start = SCREEN_COLOR_START + (40*row) + col 
    sta screen_poke_start
}

//////////////////////////////////////////////////////////////////////////
// inline macro to poke a character and a color to the screen 
// at row/col
// does not change any registers
// macro params:
//   row: screen row (0-24)
//   col: screen col (0-39)
//   Accum: the char to poke
//   X Reg: the color to poke
.macro nv_screen_poke_color_char_ax(row, col)
{
    .var screen_poke_start = SCREEN_START + (40*row) + col 
    sta screen_poke_start

    .var screen_poke_color_start = SCREEN_COLOR_START + (40*row) + col 
    stx screen_poke_color_start
}


//////////////////////////////////////////////////////////////////////////////
//
.macro nv_screen_poke_all_color_a()
{
    .var screen_poke_color_start0 = SCREEN_COLOR_START+(256*0)
    .var screen_poke_color_start1 = SCREEN_COLOR_START+(256*1)
    .var screen_poke_color_start2 = SCREEN_COLOR_START+(256*2)
    .var screen_poke_color_start3 = SCREEN_COLOR_START+(256*3)

    ldx #0
Loop0:
    sta screen_poke_color_start0,x
    inx
    cpx #0  
    bne Loop0
Loop1:
    sta screen_poke_color_start1,x
    inx
    cpx #0  
    bne Loop1
Loop2:
    sta screen_poke_color_start2,x
    inx
    cpx #0  
    bne Loop2

Loop3:
    sta screen_poke_color_start3,x
    inx
    cpx #232
    bne Loop3
}

//////////////////////////////////////////////////////////////////////////////
//
.macro nv_screen_poke_all_char_a()
{
    .var screen_poke_start0 = SCREEN_START+(256*0)
    .var screen_poke_start1 = SCREEN_START+(256*1)
    .var screen_poke_start2 = SCREEN_START+(256*2)
    .var screen_poke_start3 = SCREEN_START+(256*3)

    ldx #0
Loop0:
    sta screen_poke_start0,x
    inx
    cpx #0  
    bne Loop0
Loop1:
    sta screen_poke_start1,x
    inx
    cpx #0  
    bne Loop1
Loop2:
    sta screen_poke_start2,x
    inx
    cpx #0  
    bne Loop2

Loop3:
    sta screen_poke_start3,x
    inx
    cpx #232
    bne Loop3
}


//////////////////////////////////////////////////////////////////////////
// inline macro to poke chars to the screen that represent
// a hex number that is in the accumulator
//   row: the screen row 
//   col: the screen col
//   include_dollar: pass true to print a '$' before the number
//   accum: the byte to poke to screen
.macro nv_screen_poke_hex_byte_a(row, col, include_dollar)
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
    lda hex_digit_lookup_poke, x
    sta temp_hex_str+offset
    tya
    and #$0f
    tax
    lda hex_digit_lookup_poke, x
    sta temp_hex_str+1+offset
    lda #0
    sta temp_hex_str + 2 + offset

    nv_screen_poke_str(row, col, temp_hex_str) 
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to poke chars to the screen that are the 
// string representation of the hex value of the byte at an address
.macro nv_screen_poke_hex_byte_mem(row, col, addr, include_dollar)
{
    lda addr
    nv_screen_poke_hex_byte_a(row, col, include_dollar)
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to poke chars to the screen that are the 
// string representation of the hex value of the byte at an address
.macro nv_screen_poke_hex_word_mem(row, col, addr, include_dollar)
{
    lda addr+1
    nv_screen_poke_hex_byte_a(row, col, include_dollar)
    .if (include_dollar)
    {
        lda addr
        nv_screen_poke_hex_byte_a(row, col+3, false)
    }
    else
    {
        lda addr
        nv_screen_poke_hex_byte_a(row, col+2, false)
    }
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to poke chars to the screen that are the 
// string representation of the immediate hex value passed
.macro nv_screen_poke_hex_byte_immed(row, col, immed_value, include_dollar)
{
    lda #immed_value
    nv_screen_poke_hex_byte_a(row, col, include_dollar)
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to poke chars to the screen that are the 
// string representation of the immediate hex value passed
.macro nv_screen_poke_hex_word_immed(row, col, immed_value, include_dollar)
{
    .var lsb = immed_value & $00FF
    .var msb = (immed_value >> 8) & $00FF
    .var second_col = col+2
    .if (include_dollar)
    {
        .eval second_col = col + 3
    }
    lda #msb
    nv_screen_poke_hex_byte_a(row, col, include_dollar)
    lda #lsb
    nv_screen_poke_hex_byte_a(row, second_col, false)
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to set the screen border color to the immediate color
// passed in.  
// macro params:
//   new_color should be one of the 16 supported color see nv_color.asm
.macro nv_screen_set_border_color_immed(new_color) 
{
    lda #new_color                
    sta NV_SCREEN_BORDER_COLOR_REG_ADDR
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to set the screen border color to the color in a memory
// address passed in.  
// macro params:
//   new_color_addr: the address of a byte that holds one 16 supported 
//                   C64 colors. see nv_color.asm
.macro nv_screen_set_border_color_mem(new_color_addr) 
{
    lda new_color_addr                
    sta NV_SCREEN_BORDER_COLOR_REG_ADDR
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to increment the screen border color to the next 
// color.    
.macro nv_screen_inc_border_color()
{
    inc NV_SCREEN_BORDER_COLOR_REG_ADDR
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to decrement the screen border color to the next 
// color.    
.macro nv_screen_dec_border_color()
{
    dec NV_SCREEN_BORDER_COLOR_REG_ADDR
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to set the screen background color to the immediate color
// passed in.  
// macro params:
//   new_color should be one of the 16 supported color see nv_color.asm
.macro nv_screen_set_background_color_immed(new_color) 
{
    lda #new_color                
    sta NV_SCREEN_BACKGROUND_COLOR_REG_ADDR
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to set the screen background color in a memory address
// passed in.  
// macro params:
//   new_color_addr: address of a byte that should hold a value that is
//                   one of the 16 supported colors. see nv_color.asm
.macro nv_screen_set_background_color_mem(new_color_addr) 
{
    lda new_color_addr                
    sta NV_SCREEN_BACKGROUND_COLOR_REG_ADDR
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to increment the screen background color to the next 
// color.    
.macro nv_screen_inc_background_color()
{
    inc NV_SCREEN_BACKGROUND_COLOR_REG_ADDR
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to decrement the screen background color to the next 
// color.    
.macro nv_screen_dec_background_color()
{
    dec NV_SCREEN_BACKGROUND_COLOR_REG_ADDR
}

