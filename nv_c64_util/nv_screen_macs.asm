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

// 40 chars per row in default screen mode.
.const NV_SCREEN_CHARS_PER_ROW = 40


//////////////////////////////////////////////////////////////////////////////
// function that returns the address in screen memory of the character
// at the specified row and col
// function params:
//   char_col: the column of the character for which the address will
//             be returned.  valid values depend on mode but default
//             mode is 0-39
//   char_row: the row of the character for which the address will be 
//             returned.  Valid values depend on screen mode but default
//             mode is 0-24
// returns: the address within screen memory of the specified character
.function nv_screen_char_addr_from_xy(char_col, char_row)
{
    .return SCREEN_START + (NV_SCREEN_CHARS_PER_ROW*char_row) + char_col
}

//////////////////////////////////////////////////////////////////////////////
// function that returns the address in color memory for the color of 
// the char at the specified row and col
// function params:
//   char_col: the column of the character for which the color addr  will
//             be returned.  valid values depend on mode but default
//             mode is 0-39
//   char_row: the row of the character for which the color addr will be 
//             returned.  Valid values depend on screen mode but default
//             mode is 0-24
// returns: the address within color memory of the specified character
.function nv_screen_color_addr_from_xy(char_col, char_row)
{
    .return SCREEN_COLOR_START + (NV_SCREEN_CHARS_PER_ROW*char_row) + char_col
}


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
// inline macro to print the immediate BCD value
.macro nv_screen_print_bcd_word_immed(num)
{
    nv_screen_print_hex_word_immed(num, false)
}

//////////////////////////////////////////////////////////////////////////
// inline macro to print a byte as a decimal number (BCD) that is 
// in the accumulator
.macro nv_screen_print_bcd_byte_a()
{
    nv_screen_print_hex_byte_a(false)
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to print a byte as a decimal number (BCD) that is in 
// a specified memory address. 
.macro nv_screen_print_bcd_byte_mem(addr)
{
    lda addr
    nv_screen_print_bcd_byte_a()
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to print a byte as a decimal number (BCD) that is in 
// a specified memory address. 
.macro nv_screen_print_bcd_word_mem(addr)
{
    nv_screen_print_hex_word_mem(addr, false)
}




//////////////////////////////////////////////////////////////////////////////
//                Below here is direct to screen
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// inline macro to poke chars for a string to screen memory
.macro nv_screen_poke_str(row, col, str_to_poke)
{
    .var screen_poke_start = SCREEN_START + (NV_SCREEN_CHARS_PER_ROW*row) + col 
    
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
    .var screen_poke_start = SCREEN_START + (NV_SCREEN_CHARS_PER_ROW*row) + col 
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
    .var screen_poke_start = SCREEN_START + (NV_SCREEN_CHARS_PER_ROW*row) + col 
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
    .var screen_poke_start = SCREEN_START + (NV_SCREEN_CHARS_PER_ROW*row) + col 
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
    .var screen_poke_start = SCREEN_COLOR_START + (NV_SCREEN_CHARS_PER_ROW*row) + col 
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
.macro nv_screen_poke_color_char_xa(row, col)
{
    .var screen_poke_start = SCREEN_START + (NV_SCREEN_CHARS_PER_ROW*row) + col 
    sta screen_poke_start

    .var screen_poke_color_start = SCREEN_COLOR_START + (NV_SCREEN_CHARS_PER_ROW*row) + col 
    stx screen_poke_color_start
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to poke a byte to a location based on col, row 
// position within a 40x25 coord system (ie screen or color memory)
// macro params:
//   dest_start: is a pointer to memory that should be considered
//               location col = 0, row = 0.  
//               To poke char to position on screen pass $0400
//               To poke color to position on screen pass $D800
// params:
//   X Reg: screen column
//   Y Reg: screen row
//   Accum: char to poke
.macro nv_screen_poke_byte_by_coords_xya(dest_start)
{
    // row 0 - 5, and row 6 when col < 16
    .var screen_poke_start0 = dest_start+(256*0)
    
    // row 6 col >= 16 through row 12 when col < 32
    .var screen_poke_start1 = dest_start+(256*1)

    // row 12 col 32, through row 19 col 7
    .var screen_poke_start2 = dest_start+(256*2)
    
    // row 19 col 8 and beyond to row 24 col 39
    .var screen_poke_start3 = dest_start+(256*3)
    
TryBank0:
    cpy #7
    bcs TryBank1    // greater than or equal to row 7 try next bank
    cpy #6           // if row 6 could still be bank 0
    bne UseBank0     // if not row 6 then its bank 0
    cpx #16          // row  = 6 and col >= 16 is beyond this bank 
    bcs TryBank1
UseBank0:
    nv_screen_poke_xya_from_base(screen_poke_start0, 0, 0)
    jmp Done

TryBank1:
    cpy #13
    bcs TryBank2     // greater than or equal to row 13 try next bank
    cpy #12          // if row 12 could still be this bank
    bne UseBank1     // if not row 12 then its this bank
    cpx #32          // row = 12 and col >= 32 is beyond bank 1
    bcs TryBank2
UseBank1:
    nv_screen_poke_xya_from_base(screen_poke_start1, 6, 16)
    jmp Done

TryBank2:
    cpy #20
    bcs UseBank3     // greater than or equal to row 20 then its last bank
    cpy #19          // if row = 19 could still be this bank
    bne UseBank2     // if not row 19 then its this bank
    cpx #8           // row = 19 and col >= 8 is beyond this bank
    bcs UseBank3

UseBank2:
    nv_screen_poke_xya_from_base(screen_poke_start2, 12, 32)
    jmp Done

UseBank3:
    nv_screen_poke_xya_from_base(screen_poke_start3, 19, 8)
    jmp Done

Done:
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to poke a color and char to coord(col, row) 
// position within a 40x25 coord system (ie screen or color memory)
// macro params:
//   col_row_color_char_addr is the address of a block of memory that
//                           contains 4 bytes in this order
//                           screen col, screen row, color, character
// params:
.macro nv_screen_poke_col_row_color_char(col_row_color_char_addr)
{
    // row 0 - 5, and row 6 when col < 16
    .var screen_poke_start0 = SCREEN_START+(256*0)
    .var color_poke_start0 = SCREEN_COLOR_START+(256*0)
    
    // row 6 col >= 16 through row 12 when col < 32
    .var screen_poke_start1 = SCREEN_START+(256*1)
    .var color_poke_start1 = SCREEN_COLOR_START+(256*1)

    // row 12 col 32, through row 19 col 7
    .var screen_poke_start2 = SCREEN_START+(256*2)
    .var color_poke_start2 = SCREEN_COLOR_START+(256*2)

    // row 19 col 8 and beyond to row 24 col 39
    .var screen_poke_start3 = SCREEN_START+(256*3)
    .var color_poke_start3 = SCREEN_COLOR_START+(256*3)
    
    ldx col_row_color_char_addr
    ldy col_row_color_char_addr+1

TryBank0:
    cpy #7
    bcs TryBank1    // greater than or equal to row 7 try next bank
    cpy #6           // if row 6 could still be bank 0
    bne UseBank0     // if not row 6 then its bank 0
    cpx #16          // row  = 6 and col >= 16 is beyond this bank 
    bcs TryBank1
UseBank0:
    nv_screen_poke_to_char_color_banks(screen_poke_start0, color_poke_start0,
                                       0, 0,    // first row, first col
                                       col_row_color_char_addr)
    //lda col_row_color_char_addr+3
    //nv_screen_poke_xya_from_base(screen_poke_start0, 0, 0)
    //lda col_row_color_char_addr+2
    //nv_screen_poke_xya_from_base(color_poke_start0, 0, 0)
    jmp Done

TryBank1:
    cpy #13
    bcs TryBank2     // greater than or equal to row 13 try next bank
    cpy #12          // if row 12 could still be this bank
    bne UseBank1     // if not row 12 then its this bank
    cpx #32          // row = 12 and col >= 32 is beyond bank 1
    bcs TryBank2
UseBank1:
    nv_screen_poke_to_char_color_banks(screen_poke_start1, color_poke_start1,
                                       6, 16,    // first row, first col
                                       col_row_color_char_addr)

    //lda col_row_color_char_addr+3
    //nv_screen_poke_xya_from_base(screen_poke_start1, 6, 16)
    //lda col_row_color_char_addr+2
    //nv_screen_poke_xya_from_base(color_poke_start1, 6, 16)
    jmp Done

TryBank2:
    cpy #20
    bcs UseBank3     // greater than or equal to row 20 then its last bank
    cpy #19          // if row = 19 could still be this bank
    bne UseBank2     // if not row 19 then its this bank
    cpx #8           // row = 19 and col >= 8 is beyond this bank
    bcs UseBank3

UseBank2:
    nv_screen_poke_to_char_color_banks(screen_poke_start2, color_poke_start2,
                                       12, 32,    // first row, first col
                                       col_row_color_char_addr)

    //lda col_row_color_char_addr+3
    //nv_screen_poke_xya_from_base(screen_poke_start2, 12, 32)
    //lda col_row_color_char_addr+2
    //nv_screen_poke_xya_from_base(color_poke_start2, 12, 32)
    jmp Done

UseBank3:
    nv_screen_poke_to_char_color_banks(screen_poke_start3, color_poke_start3,
                                       19, 8,    // first row, first col
                                       col_row_color_char_addr)

    //lda col_row_color_char_addr+3
    //nv_screen_poke_xya_from_base(screen_poke_start3, 19, 8)
    //lda col_row_color_char_addr+2
    //nv_screen_poke_xya_from_base(color_poke_start3, 19, 8)
    jmp Done

Done:
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to poke a char to a location on the screen
// params:
//   X Reg: screen column
//   Y Reg: screen row
//   Accum: char to poke
.macro nv_screen_poke_char_xya()
{
    nv_screen_poke_byte_by_coords_xya(SCREEN_START)
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to poke a color to a location on the screen
// params:
//   X Reg: screen column
//   Y Reg: screen row
//   Accum: color to poke
.macro nv_screen_poke_color_xya()
{
    nv_screen_poke_byte_by_coords_xya(SCREEN_COLOR_START)
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to poke a char to a list of screen coords
// macro params:
//   zero_page_lsb_addr: this is the LSB of a word in zero page
//                       that should be used for pointer indirection
//   zero_page_save_lsb_addr: this is the LSB of a word in memory
//                            that should be used to save the previous
//                            contents of the zero page word so it can 
//                            be restored.
//   dest_start: This is the address within memory for the byte
//               that is at col=0, row=0.  it is assumed 40 cols and 25 rows
//               For screen chars to be poked, pass $0400
//               For screen colors to be poked, pass $D800
// params:
//   X Reg, Y Reg: is the LSB/MSB of the list_addr which is 
//              the address of the list of coords for the macro.  
//              this address should point to pairs of bytes that
//              are (x, y) positions on the screen ie (col, row)
//              the end of list is marked by negative number ($FF)
//              typical list may look like this
//                list_addr: .byte 0, 0     // screen coord 0, 0
//                           .byte 1, 1     // screen coord 1, 1
//                           .byte $FF      // end of list.
//   accum: the byte to poke to the list of coords
.macro nv_screen_poke_byte_to_coord_list_axy(zero_page_lsb_addr, 
                                             zero_page_save_lsb_addr,
                                             dest_start)
{
    sta nv_b8       // save the char to poke
    
    // save current contents of zero page pointer we will use
    lda zero_page_lsb_addr 
    sta zero_page_save_lsb_addr
    lda zero_page_lsb_addr+1 
    sta zero_page_save_lsb_addr+1

    stx zero_page_lsb_addr
    sty zero_page_lsb_addr+1
    ldy #0

Loop:
    sty nv_a8           // save y index into list in a temp 
    lda (zero_page_lsb_addr),y  // get the col from the list in accum
    bpl Continue        // if its negative then done with list
    jmp Done            // wasn't positive so was negative, done looping
Continue:
    tax                 // put col in x reg
    iny                 // inc index to get the row from list
    lda (zero_page_lsb_addr),y   // get row from the list in Y reg
    tay                 // xfer row to y reg
    lda nv_b8           // load our char to poke into accum
    nv_screen_poke_byte_by_coords_xya(dest_start)
    ldy nv_a8           // restore x from memory temp
    iny                 // increment it twice to get next x, y pair
    iny
    jmp Loop            // jump back to top of loop
    
Done:
    // restore zero page memory pointer that we used
    lda zero_page_save_lsb_addr 
    sta zero_page_lsb_addr
    lda zero_page_save_lsb_addr+1 
    sta zero_page_lsb_addr+1
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to poke the same char and color to a list of screen coords
// macro params:
//   zero_page_lsb_addr: this is the LSB of a word in zero page
//                       that should be used for pointer indirection
//   mem_block_addr: the address of a 7 byte block that can be used
//                   internally to store these things throughout
//                   col, row, color, char, y index, zero page lsb, msb
// reg params:
//   X Reg/Y Reg: is the LSB/MSB of the list_addr which points to bytes 
//                in this structure:
//                list_addr: .byte <color>, <char> // color byte, char byte
//                           .byte 0, 0     // screen coord 0, 0
//                           .byte 1, 1     // screen coord 1, 1
//                           .byte $FF      // end of list.
.macro nv_screen_poke_coord_list(zero_page_lsb_addr, 
                                 mem_block_addr) 
{
    // save current contents of zero page pointer we will use
    lda zero_page_lsb_addr 
    sta mem_block_addr + 5         // zero_page_save_lsb_addr
    lda zero_page_lsb_addr+1 
    sta mem_block_addr + 6         // zero_page_save_lsb_addr+1

    stx zero_page_lsb_addr
    sty zero_page_lsb_addr+1
    ldy #0
    lda (zero_page_lsb_addr), y     // read color byte from list
    sta mem_block_addr +2           // store color in mem block
    iny
    lda (zero_page_lsb_addr), y     // read character byte from list
    sta mem_block_addr + 3          // store character in block    
    iny                             // move index to first coord
    
// now start looping through coords
Loop:
    sty mem_block_addr + 4      // save y index into list in a temp 
    lda (zero_page_lsb_addr),y  // get the col from the list in accum
    bpl Continue                // if its negative then done with list
    jmp Done                    // wasn't positive, was neg, exit loop
Continue:
    sta mem_block_addr+0        // put col in first byte of block
    iny                         // inc index to get the row from list
    lda (zero_page_lsb_addr),y  // get row from the list in Y reg
    sta mem_block_addr+1        // put row in second byte of mem block

    nv_screen_poke_col_row_color_char(mem_block_addr)

    ldy mem_block_addr + 4      // restore index from memory temp
    iny                         // increment it twice to get next x, y pair
    iny
    jmp Loop                    // jump back to top of loop
    
Done:
    // restore zero page memory pointer that we used
    lda mem_block_addr + 5        // zero_page_save_lsb_addr 
    sta zero_page_lsb_addr
    lda mem_block_addr + 6        // zero_page_save_lsb_addr+1 
    sta zero_page_lsb_addr+1
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to poke a char to a list of screen coords
// macro params:
//   list_addr: the address of the list of coords for the macro.  
//              this address should point to pairs of bytes that
//              are (x, y) positions on the screen ie (col, row)
//              the end of list is marked by negative number ($FF)
//              typical list may look like this
//                list_addr: .byte 0, 0     // screen coord 0, 0
//                           .byte 1, 1     // screen coord 1, 1
//                           .byte $FF      // end of list.
// accum: the byte to poke to the list of coords
.macro nv_screen_poke_char_to_coord_list(list_addr)
{
    sta nv_b8       // char to poke in b8
    ldx #0
Loop:
    stx nv_a8           // save x index into list in a temp 
    lda list_addr, x    // get x position from list into accum
    bpl Continue        // if its negative then done with list
    jmp Done            // wasn't positive so was negative, done looping
Continue:
    inx                 // inc index to y position
    ldy list_addr, x    // get y position in Y reg
    tax                 // xfer x position to x reg
    lda nv_b8           // load our char to poke into accum
    nv_screen_poke_char_xya()
    ldx nv_a8           // restore x from memory temp
    inx                 // increment it twice to get next x, y pair
    inx
    jmp Loop            // jump back to top of loop
    
Done:
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to poke a color to a list of screen coords
// macro params:
//   list_addr: the address of the list of coords for the macro.  
//              this address should point to pairs of bytes that
//              are (x, y) positions on the screen ie (col, row)
//              the end of list is marked by negative number ($FF)
//              typical list may look like this
//                list_addr: .byte 0, 0     // screen coord 0, 0
//                           .byte 1, 1     // screen coord 1, 1
//                           .byte $FF      // end of list.
// accum: the color byte to poke to each coord in the list of coords
// 
.macro nv_screen_poke_color_to_coord_list(list_addr)
{
    sta nv_b8       // char to poke in b8
    ldx #0
Loop:
    stx nv_a8           // save x index into list in a temp 
    lda list_addr, x    // get x position from list into accum
    bpl Continue        // if its negative then done with list
    jmp Done            // wasn't positive so was negative, done looping
Continue:
    inx                 // inc index to y position
    ldy list_addr, x    // get y position in Y reg
    tax                 // xfer x position to x reg
    lda nv_b8           // load our char to poke into accum
    nv_screen_poke_color_xya()
    ldx nv_a8           // restore x from memory temp
    inx                 // increment it twice to get next x, y pair
    inx
    jmp Loop            // jump back to top of loop
    
Done:
}


////////////////////////////////////////////////////////////////////////
// inline macro to poke byte in accum to x, y location on screen
// or a color in accum to x, y location on screen.  
// if the base address passed is in screen char memory then it will 
// be a char, if its in screen color memory then it will be a color
// macro params:
//   base_address: is the start of screen memory or color memor for
//                 this bank of 256 bytes
//   first_row: is the row of the first char in this bank
//   first_col: is the col of the first char in this bank.
// subroutine params:
//   Accum: pass the char to poke to the screen. value preserved
//   Y Reg: The row for the char to be poked at. value not preserved
//   X Reg: the col for the char to be poked at. value not preserved
.macro nv_screen_poke_xya_from_base(base_addr, first_row, first_col)
{
    // save byte to poke so that we can use accum for math
    pha

    // adjust the row (y reg) based on the first row
    tya
    sec
    sbc #first_row
    tay

    // adjust the col (x reg) base on first col
    txa
    sec
    sbc #first_col
    tax

    // after above adjustments x reg and y reg are both zero if
    // we are poking to the first byte in the bank.

    lda #0  // start accum at zero and add bytes per row for each row
            // beyond first row of the bank.

    cpy #0  // if zero then we've added enough for the rows
RowLoop0:
    beq DoneRowLoop0
    clc
    adc #NV_SCREEN_CHARS_PER_ROW 
    dey 
    jmp RowLoop0
DoneRowLoop0:

    stx scratch_byte
    clc
    adc scratch_byte
    tax
    pla
    sta base_addr,x
}

////////////////////////////////////////////////////////////////////////
// inline macro to poke byte in accum to x, y location on screen
// or a color in accum to x, y location on screen.  
// if the base address passed is in screen char memory then it will 
// be a char, if its in screen color memory then it will be a color
// macro params:
//   base_address: is the start of screen memory or color memor for
//                 this bank of 256 bytes
//   first_row: is the row of the first char in this bank
//   first_col: is the col of the first char in this bank.
// subroutine params:
//   Accum: pass the char to poke to the screen. value preserved
//   Y Reg: The row for the char to be poked at. value not preserved
//   X Reg: the col for the char to be poked at. value not preserved
.macro nv_screen_poke_to_char_color_banks(char_base_addr, color_base_addr,
                                          first_row, first_col,
                                          col_row_color_char_addr) // x, y, color_char
{
    // adjust the row (y reg) based on the first row
    tya
    sec
    sbc #first_row
    tay

    // adjust the col (x reg) base on first col
    txa
    sec
    sbc #first_col
    tax

    // after above adjustments x reg and y reg are both zero if
    // we are poking to the first byte in the bank.

    lda #0  // start accum at zero and add bytes per row for each row
            // beyond first row of the bank.

    cpy #0  // if zero then we've added enough for the rows
RowLoop0:
    beq DoneRowLoop0
    clc
    adc #NV_SCREEN_CHARS_PER_ROW 
    dey 
    jmp RowLoop0
DoneRowLoop0:

    stx scratch_byte
    clc
    adc scratch_byte
    tax
    
    // do the pokes.  X reg has the correct offset from the base addrs
    lda col_row_color_char_addr + 3
    sta char_base_addr,x
    lda col_row_color_char_addr + 2
    sta color_base_addr, x
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

//////////////////////////////////////////////////////////////////////////
// inline macro to poke chars to the screen that represent
// a decimal (BCD) number that is in the accumulator
//   row: the screen row 
//   col: the screen col
//   accum: the byte to poke to screen
.macro nv_screen_poke_bcd_byte_a(row, col)
{
    nv_screen_poke_hex_byte_a(row, col, false)
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
// string representation of the decimal (BCD) value of the byte at an address
.macro nv_screen_poke_bcd_byte_mem(row, col, addr)
{
    lda addr
    nv_screen_poke_bcd_byte_a(row, col)
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
// string representation of the decimal (BCD) value of the byte at an address
.macro nv_screen_poke_bcd_word_mem(row, col, addr)
{
    nv_screen_poke_hex_word_mem(row, col, addr, false)
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

//////////////////////////////////////////////////////////////////////////////
// macros for custom char sets below
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// initialize the system pointer to use a custom charset
// macro params: 
//   charset_bank: specifies address of the custom charset.
//                 the actual address will be determined by this 
//                 table  (only values 0-7 are valid) and a few
//                 of the values always get read from ROM
//                  0 : charset is at $0000
//                  1 : charset is at $0800
//                  2 : charset is at $1000  (Always read from ROM)
//                  3 : charset is at $1800  (Always read from ROM)
//                  4 : charset is at $2000
//                  5 : charset is at $2800
//                  6 : charset is at $3000
//                  7 : charset is at $3800
//  copy_rom_chars: pass true to copy the rom charset to the new location
//                  in ram
.macro nv_screen_custom_charset_init(charset_bank, copy_rom_chars)
{
    .if(charset_bank > 7)
    {
        .error("ERROR - nv_screen_init_custom_charset: invalid charset bank")
    }

    .var charset_location_mask = ((charset_bank << 1) & $0E)

    .var new_charset_addr = $0000
    .if (charset_bank == 1)
    {
        .eval new_charset_addr = $0800
    }
    else .if (charset_bank == 2)
    {
        .eval new_charset_addr = $1000
    }
    else .if (charset_bank == 3)
    {
        .eval new_charset_addr = $1800
    }
    else .if (charset_bank == 4)
    {
        .eval new_charset_addr = $2000
    }
    else .if (charset_bank == 5)
    {
        .eval new_charset_addr = $2800
    }
    else .if (charset_bank == 6)
    {
        .eval new_charset_addr = $3000
    }
    else .if (charset_bank == 7)
    {
        .eval new_charset_addr = $3800
    }
    else
    {
        .error("ERROR - nv_screen_init_custom_charset: invalid charset bank")
    }

    lda $D018                   // special memory location, the low 4 bits
                                // specify which bank of memory holds the 
                                // charset in use.  the lowest bit (bit 0)
                                // isn't used but the bits 1-3 will be set 
                                // to the charset_bank value passed in

    and #$F1                    // clear the 3 bits that we'll set to bank
    ora #charset_location_mask  // now set 3 bits to the charset_bank value
    sta $D018                   // write back to the special location
    
    .if (copy_rom_chars)
    {
        nv_screen_custom_charset_copy_from_rom(new_charset_addr)
    }
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to copy the ROM char set to a location in RAM
// the new location will get 2048 bytes copied to it
// macro params:
//   new_charset_addr: destination address to which charset will be copied
//   save_block_addr 
.macro nv_screen_custom_charset_copy_from_rom(new_charset_addr)
{
    sei                     // irqs off

    // Save byte at $01 which configures how ROMs are visible
    lda $0001
    pha

    // Set byte at $01 to value which allows ROMs to be visible 
    // to CPU at $D000
    lda #$33                // configure so ROMS visible to CPU
    sta $0001 

    // now copy ROMs to new charset

    // do it in 256 byte chunks since our index (x reg) is 
    // limited to 8 bits
.var offset
.for (offset = $0000; offset < $0800; offset = offset + 256)   
{ 
    ldx #0
Loop1:
    lda $D000+offset, x
    sta new_charset_addr+offset, x
    inx
    bne Loop1
}
    // restore byte at $01 so ROMS no longer visible to CPU
    pla
    sta $0001

    cli                     // irqs back on
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to replace the pointer to charset so that it points 
// to the ROM charset instead of custom char set in RAM.
// call this to undo the nv_screen_custom_charset_init() macro
.macro nv_screen_custom_charset_done()
{
    lda #$15        // this is the normal value for $D018
    sta $D018       // store it back so charset is in ROM again.
}