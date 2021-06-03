// This sample shows multiple ways to pass parameters to subroutines in
// 6502 assembly code




*=$0801 "BASIC Start"  // location to put a 1 line basic program so we can just
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

///////////////////////////////////////////////////////////
// paramater block for PrintCharFuncParamBlock
.const func_param_block_offset_x = 0
.const func_param_block_offset_y = 1
.const func_param_block_offset_char = 2
func_param_block: 
.byte $07       // X (col) position for character, offset 0
.byte $03       // Y (row) position for character, offset 1
.byte $05       // character to print,             offset 2
////////////////////////////////////////////////////////////


*=$08F8
TempRtsLsb:
        .byte $00

TempRtsMsb:
        .byte $00

str_to_print: .text  @"hello direct\$00"  // null terminated string to print

.const SCREEN_START_ADDR = $0400       // The start of c64 screen memory
.const SCREEN_COLS = 40                // chars across
.const SCREEN_ROWS = 25                // chars down

// predefined location in screen memory where the string will be printed
.const PREDEFINED_PRINT_LOC = SCREEN_START_ADDR + $0100 

.const CLEAR_SCREEN_KERNAL_ADDR = $E544     // Kernal routine to clear screen

// our assembly code will goto this address
*=$1000 "Main Start"
{
        // clear screeen leave cursor upper left
        jsr CLEAR_SCREEN_KERNAL_ADDR 

        // setup and call using registers only for params
        lda #20    // x (col)
        ldy #05    // y (row)  
        ldx #01    // character 'A'
        jsr PrintCharRegistersOnly
        //


        // setup and call using a function param block
        ldx #func_param_block_offset_x  // set x reg with offset into param block to X
        lda #15                         // load accum with the X position for char
        sta func_param_block,x          // store the X position into param block
        ldx #func_param_block_offset_y  // set x reg with offset into param block to y
        lda #3                          // load accum with the y position
        sta func_param_block,x          // store the Y position into param block
        ldx #func_param_block_offset_char  // set x reg with offset into param block to char
        lda #2                             // load accum with the char
        sta func_param_block,x             // store the char into param block
        jsr PrintCharFuncParamBlock        // call subroutine
        //


        rts
}


//////////////////////////////////////////////////////////////////////////////
// Print a char somewhere on first 5 lines by passing the 
// character, x (column), and y() row) in registers
// Setup registers to call it:
//   Accum: X (col) location for char in Accumulator 
//   Y Reg: Y (row) location for char in Y reg - must be between 0 and 5
//   X Reg: Char to print
//   JSR to this routine
// Pros:
//   all registers free for use within routine
//   JSR and RTS work as designed.
//   param values persist between calls
//   can pass unlimited data using one or more param blocks 
// Cons:
//   setup is more complicated than setting registers
//   a single block for all calls could caller maintaining multiple blocks and 
//     overwriting the function param block ever call
//   
////////////////////////////////////////////////////////////////////////////////
PrintCharFuncParamBlock:
{
        ldx #func_param_block_offset_x
        lda func_param_block,x               // x loc in accum
        ldx #func_param_block_offset_y
        ldy func_param_block,x             // y loc in Y reg

        cpy #$00
        beq DoneY                          // when Y is 0 then we've added enough 
LoopY:
        clc
        adc #SCREEN_COLS
        dey
        beq DoneY                          // if Y still not 0 then loop up and add again
        jmp LoopY
DoneY:
        tay                                // move just calculated offest to Y reg
        ldx #func_param_block_offset_char
        lda func_param_block,x             // move char to print to the accum
        sta SCREEN_START_ADDR,y            // store the char to print to screen start + offset   
        
        rts
}



//////////////////////////////////////////////////////////////////////////////
// Print a char somewhere on first 5 lines by passing the 
// character, x (column), and y() row) in registers
// Setup registers to call it:
//   Accum: X (col) location for char in Accumulator 
//   Y Reg: Y (row) location for char in Y reg - must be between 0 and 5
//   X Reg: Char to print
//   JSR to this routine
// Pros:
//   easy to setup.
//   JSR and RTS work as designed.
// Cons:
//   Can only pass 3 bytes of information this way
PrintCharRegistersOnly:
{
        cpy #$00
        beq DoneY                       // when Y is 0 then we've added enough 
LoopY:
        clc
        adc #SCREEN_COLS
        dey
        beq DoneY                       // if Y still not 0 then loop up and add again
        jmp LoopY
DoneY:
        tay                             // move just calculated offest to Y reg
        txa                             // move char to print to the accum
        sta SCREEN_START_ADDR,y         // store the char to print to screen start + offset   
        
        rts
}




/*
////////////////////////////////////////////////////////////
// Print the string by passing string addresss in registers
// To call:
//   Put LSB of string to print in X reg
//   put MSB of string to print in A reg
//   put number of times to print in Y
//   JSR to this routine
// Pros:
//   easy to setup.
//   JSR and RTS work as designed.
// Cons:
PrintStringRegistersOnly:

        // use a temp word in memory to store the string address 
        // so that we can use the address +x in the inner loop below
        // this isn't convienent but there are no 16 bit registers that
        // can be used to point to our input string
        stx registers_only_temp
        sta registers_only_temp+1

OuterLoop:
        //cpy #$00
        //beq DoneOuter
        //ldx #$00                     // use x reg as inner loop index, start at 0
InnerLoop:
        lda (registers_only_temp,x)    // put a byte from string into accum
        beq DoneInner                // if the byte was 0 then we're done 
        sta PREDEFINED_PRINT_LOC,x   // Store the byte to screen
        inx                          // inc to next byte and next screen location 
        jmp InnerLoop                // Go back for next byte
DoneInner: 
        //dey
        //jmp OuterLoop

DoneOuter:
        rts
registers_only_temp: .word $0000
*/


/*
//////////////////////////////////////////////////////////////////////////////
// Print a char somewhere on first 5 lines by passing the 
// character, x (column), and y() row) in registers
// To call:
//   Put X location for char in X reg
//   put Y location for char in Y reg - must be between 0 and 5
//   put the character to print in the Accumulator
//   JSR to this routine
// Pros:
//   easy to setup.
//   JSR and RTS work as designed.
// Cons:
//   Caller has to preserve any registers needed to persist
//   Can only pass 3 bytes of information this way
PrintCharRegistersOnly:
        sta temp_register_only_a        // store the byte to print so we can
                                        // use the accumulator
        stx temp_register_only_x
        sty temp_register_only_y 

        txa                             // need to set x as the offset from screen start
        cpy #$00
        beq DoneY
LoopY:
        clc
        adc #SCREEN_COLS
        dey
        beq DoneY
        jmp LoopY
DoneY:
        tax
        lda temp_register_only_a
        sta SCREEN_START_ADDR,x           
        
        rts

temp_register_only_a:
        .byte $00
temp_register_only_x:
        .byte $00
temp_register_only_y:
        .byte $00

*/