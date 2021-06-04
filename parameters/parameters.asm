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
.const func_param_block_x_addr = func_param_block + func_param_block_offset_x
.const func_param_block_y_addr = func_param_block + func_param_block_offset_y
.const func_param_block_char_addr = func_param_block + func_param_block_offset_char
////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////
// offsets into PrintCharCodeModification for params
.const code_modification_offset_x = 1
.const code_modification_offset_y = 3
.const code_modification_offset_char = 17
.const code_modification_x_addr = PrintCharCodeModification + code_modification_offset_x
.const code_modification_y_addr = PrintCharCodeModification + code_modification_offset_y
.const code_modification_char_addr = PrintCharCodeModification + code_modification_offset_char
////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////
// paramater block for PrintCharFuncParamBlock
.const call_param_block_offset_x = 0
.const call_param_block_offset_y = 1
.const call_param_block_offset_char = 2
call_param_block: 
.byte $00       // X (col) position for character, offset 0
.byte $00       // Y (row) position for character, offset 1
.byte $00       // character to print,             offset 2
.const call_param_block_x_addr = call_param_block + call_param_block_offset_x
.const call_param_block_y_addr = call_param_block + call_param_block_offset_y
.const call_param_block_char_addr = call_param_block + call_param_block_offset_char
////////////////////////////////////////////////////////////


// Temp zero page locations to use for indirection
.const ZERO_PAGE_LO = $FB
.const ZERO_PAGE_HI = $FC


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


        //// setup and call using registers only for params
        lda #20    // x (col)
        ldy #05    // y (row)  
        ldx #01    // character 'A'
        jsr PrintCharRegistersOnly
        //


        //// setup and call using function defined param block
        lda #20
        sta func_param_block_x_addr
        lda #2
        sta func_param_block_y_addr
        lda #2                                  // character 'B'
        sta func_param_block_char_addr
        jsr PrintCharFuncParamBlock
        //


        //// setup and call using code modification method
        lda #22
        sta code_modification_x_addr
        lda #2
        sta code_modification_y_addr
        lda #3                                  // character 'C'
        sta code_modification_char_addr
        jsr PrintCharCodeModification
        //

        //// setup and call using caller's parameter block
        lda #35                                 // X = 35
        sta call_param_block_x_addr
        lda #1                                  // Y = 1
        sta call_param_block_y_addr
        lda #4                                  // Character 'D'
        sta call_param_block_char_addr          
        lda #<call_param_block
        ldy #>call_param_block
        jsr PrintCharCallParamBlock
        //


        rts
}

//////////////////////////////////////////////////////////////////////////////
// Print a char somewhere on first 5 lines by passing the 
// character, x (column), and y() row) in a caller defined parameter
// block.
// A caller's parameter block must be setup with the following layout
//   .byte : X location for char to print
//   .byte : Y location for char to print (only pass 0-5)
//   .byte : The char to print
// Before calling the address of the caller's parameter block should be
// set as follows:
//   Accum    : LSB of caller's parameter block address
//   Y Reg    : MSB of caller's parameter block address
// Then you can JSR to this routine
//
// Pros:
//   can keep separate parameter blocks and pass in whichever 
//   
// Cons:
//   Requires a zero page pointer which is scarce resource so could conflict
//     with other subroutines that want to use that location.  or else need to 
//     save and restore values in the zero page pointer.
////////////////////////////////////////////////////////////////////////////////
PrintCharCallParamBlock:
{
        // load the address of the caller's param block to a pointer in 
        // zero page (first 256 bytes of memory)
        sta ZERO_PAGE_LO   // store lo byte of addr of caller's param block
        sty ZERO_PAGE_HI   // store hi byte of addr of caller's param block 

        // get the Y location from caller's param block into Y register
        ldy #call_param_block_offset_y  // load Y reg with offset to y loc
        lda (ZERO_PAGE_LO),y                     // indirectly load y loc to accum
        tax                             // copy y loc from accum to x reg
 
        // get the x location from caller's param block into the accum
        ldy #call_param_block_offset_x  // load Y reg with offset to x loc
        lda (ZERO_PAGE_LO),y                     // indirectly load x loc into accum
        
        cpx #$00
        beq DoneY                       // when X reg is 0 then we've added enough 
LoopY:
        clc
        adc #SCREEN_COLS
        dex
        beq DoneY                       // if X reg still not 0 then loop up and add again
        jmp LoopY
DoneY:
        tax                             // move the just calculated offest to X reg
        
        // get the char to print from the caller's param block to the accum
        ldy #call_param_block_offset_char
        lda (ZERO_PAGE_LO),y

        sta SCREEN_START_ADDR,x         // store the char to print to screen start + offset   
        
        rts
}


//////////////////////////////////////////////////////////////////////////////
// Print a char somewhere on first 5 lines.  caller must specify the 
// character, x (column), and y() row) in registers by overwriting
// the subroutine code at the following locations
// code_modification_x_addr      offset 1 from subroutine label
// code_modification_y_addr      offset 3 from subroutine label
// code_modification_char_addr   offset 17 from subroutine label

// Setup registers to call it:
//   Accum: X (col) location for char in Accumulator 
//   Y Reg: Y (row) location for char in Y reg - must be between 0 and 5
//   X Reg: Char to print
//   JSR to this routine
// Pros:
//   All registers free for use within routine
//   JSR and RTS work as designed.
//   param values persist between calls
//   could be tedius to call when lots of parameters
//   code simple to write and understand
// Cons:
//   Hard to maintain because code changes could move the locations to overwrite 
//   can't maintain more than one set of parameters.  
//   
////////////////////////////////////////////////////////////////////////////////
PrintCharCodeModification:
{
        lda #30              // load accum with X location offset = 1
        ldy #3               // load Y reg with Y location offset = 3
        beq DoneY            // when Y is 0 then we've added enough 
LoopY:
        clc
        adc #SCREEN_COLS
        dey
        beq DoneY                  // if Y still not 0 then loop up and add again
        jmp LoopY
DoneY:
        tay                        // move just calculated offest to Y reg
        lda #10                    // move char to print to the accum offset = 17
        sta SCREEN_START_ADDR,y    // store the char to print to screen start + offset   
        
        rts
}



//////////////////////////////////////////////////////////////////////////////
// Print a char somewhere on first 5 lines by passing the 
// character, x (column), and y() row) in a function defined paramete
// block.
// Setup data in the following addresses to call function 
//   func_param_block_x_addr    : X (col) location for char in Accumulator 
//   func_param_block_x_addr    : Y (row) location for char in Y reg - must be between 0 and 5
//   func_param_block_char_addr : Char to print
//   JSR to this routine
// Pros:
//   all registers free for use within routine
//   JSR and RTS work as designed.
//   param values persist between calls
//   can pass unlimited data using one or more param blocks 
// Cons:
//   maintaining multiple sets of parameters will require constant overwriting
//      of the whole function param block
//   
////////////////////////////////////////////////////////////////////////////////
PrintCharFuncParamBlock:
{
        lda func_param_block_x_addr     // put x location in accum
        ldy func_param_block_y_addr     // put y location in Y register

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
        lda func_param_block_char_addr  // put char to print in accum
        sta SCREEN_START_ADDR,y         // store the char to print to screen start + offset   
        
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


