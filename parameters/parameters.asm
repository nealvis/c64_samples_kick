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
// paramater block for PrintCharFuncParamBlock and some 
// constants to go with it.  This is the function defined
// param block which is global in that every call to 
// PrintCharFuncParamBlock must set values in this one 
// block of memory
func_param_block: 
.byte $00       // X (col) position for character, offset 0
.byte $00       // Y (row) position for character, offset 1
.byte $00       // character to print,             offset 2
// consts to go with the func param block
.const func_param_block_offset_x = 0
.const func_param_block_offset_y = 1
.const func_param_block_offset_char = 2
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
// caller defined parameter block the address of which 
// can be passed to the PrintCharCallParamBlock function.
// multiple of similar blocks could be created and passed 
// in different calls to PrintCharCallParamBlock.  The
// subroutine doesn't care were the actual parameter block is
// it indirectly accesses the fields via the address of 
// the block which is passed into the routine  
call_param_block: 
.byte $00       // X (col) position for character, offset 0
.byte $00       // Y (row) position for character, offset 1
.byte $00       // character to print,             offset 2
// consts for caller defined param block. offsets could apply to
// any similar param block but the addr's are only for this 
// specific param block
.const call_param_block_offset_x = 0
.const call_param_block_offset_y = 1
.const call_param_block_offset_char = 2
.const call_param_block_x_addr = call_param_block + call_param_block_offset_x
.const call_param_block_y_addr = call_param_block + call_param_block_offset_y
.const call_param_block_char_addr = call_param_block + call_param_block_offset_char
////////////////////////////////////////////////////////////


// Temp zero page locations to use for indirection.  These two
// zero page bytes are unused for normal C64 normal operation 
// including during BASIC which is why they were selected.  
// We'll treat these as a scratch zero page address whenever 
// we need one.  When doing this need to beware of contention 
// between routines.  To be safe each routine that uses
// these could save and restore the values upon entry and exit.
.const ZERO_PAGE_LO = $FB
.const ZERO_PAGE_HI = $FC

*=$08F8


temp_rts_lsb:
        .byte $00

temp_rts_msb:
        .byte $00

.const SCREEN_START_ADDR = $0400       // The start of c64 screen memory
.const SCREEN_COLS = 40                // chars across
.const SCREEN_ROWS = 25                // chars down

.const CLEAR_SCREEN_KERNAL_ADDR = $E544     // Kernal routine to clear screen

// our assembly code will goto this address
*=$1000 "Main Start"
{
        // clear screeen leave cursor upper left
        jsr CLEAR_SCREEN_KERNAL_ADDR 


        //// Registers only for parameter passing
        lda #20    // x (col)
        ldy #05    // y (row)  
        ldx #01    // character 'A'
        jsr PrintCharRegistersOnly
        //


        //// function defined param block for parameter passing
        lda #20
        sta func_param_block_x_addr
        lda #2
        sta func_param_block_y_addr
        lda #2                                  // character 'B'
        sta func_param_block_char_addr
        jsr PrintCharFuncParamBlock
        //


        //// Code modification method for parameter passing
        lda #22
        sta code_modification_x_addr
        lda #2
        sta code_modification_y_addr
        lda #3                                  // character 'C'
        sta code_modification_char_addr
        jsr PrintCharCodeModification
        //

        //// caller defined parameter block for parameter passing
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

        // Stack preserving method of parameter passing
        lda #5                                  // Character 'E'
        pha
        lda #7                                  // X location (col)
        pha
        lda #3                                  // Y location (row)
        pha
        jsr PrintCharStackPreserving

        rts
}



//////////////////////////////////////////////////////////////////////////////
// Stack Preserving method of passing parameters to print a char 
// somewhere on first 5 lines.  To call this subroutine the following
// byte values must be pushed to the stack in this order prior 
// to calling jsr. 
//   character to print
//   x location (column)
//   y location (row)
//   
// After pushing those 3 bytes then call JSR to this routine
// Pros:
//   - registers are left free 
//   - fairly easy to setup.
//   - not limited by number of registers
// Cons:
//   - Stack space is limited to 256 bytes. Nested calls can exhaust this
//   - Always need to setup every parameter for every call
//   - Some "extra" work required to maintain the return address on the stack
//     before calling rts inside the routine
PrintCharStackPreserving:
{
        // first need to pop off the return address (minus 1) that 
        // JSR pushed on to the stack.  Our Parameters were pushed
        // on befor this addr.  We'll save ret addr so we can get back
        pla                     // pop and save the LSB of the return 
        sta temp_rts_lsb        // address (minus 1) into temp_rts_lsb
        pla                     // pop and save the MSB of the return
        sta temp_rts_msb        // address (minus 1) into temp_rts_msb

        pla                     // pop off the y loc (row) param to accum
        tay                     // put the y location into Y register

        pla                     // pop off the x loc (col) param to accum

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
        pla                             // pop char to print from stack to the accum
        sta SCREEN_START_ADDR,y         // store the char to print to screen start + offset   
        
        // now need to replace the return address (minus 1) to the stack
        // so that rts works as expected

        lda temp_rts_msb                // put msb of saved ret addr -1 into accum
        pha                             // push accum (msb) onto stack
        
        lda temp_rts_lsb                // put lsb of saved ret addr -1 into accum
        pha                             // push accum (lsb) onto stack

        rts
}


//////////////////////////////////////////////////////////////////////////////
// Caller defined parameter block method used to print a char somewhere 
// on first 5 lines by passing the character, the x (col), and y (row) in 
// a caller defined parameter block.  The block must be setup with the 
// following layout
//   .byte : X location for char to print
//   .byte : Y location for char to print (only pass 0-5)
//   .byte : The char to print
// The address of the caller's parameter block must be passed to this
// subroutine as follows:
//   Accum    : LSB of caller's parameter block address
//   Y Reg    : MSB of caller's parameter block address
// Then you can JSR to this routine
//
// Pros:
//   - can keep separate parameter blocks and pass in the address to 
//     whichever one you'd like this routine to operate on 
//   - Most versitile.
//   - Don't need to worry about the stack, jsr and rts used as designed  
// Cons:
//   - Requires a zero page pointer which is scarce resource so could conflict
//     with other subroutines that want to use that location.  Could  
//     save and restore values in the zero page pointer to prevent that though.
////////////////////////////////////////////////////////////////////////////////
PrintCharCallParamBlock:
{
        // load the address of the caller's param block to a pointer in 
        // zero page (first 256 bytes of memory.)  we need a zero page 
        // location to store the address of the caller's parameter block
        // so that we can later use indirect index addressing into the block
        // for the individual fields (x loc, y loc, char to print)
        sta ZERO_PAGE_LO   // store lo byte of addr of caller's param block
        sty ZERO_PAGE_HI   // store hi byte of addr of caller's param block 

        // get the Y location parameter from caller's param block into accum
        // and then transfer to X register/  For this we'll be 
        // using indirect indexed addressing where we pass a zero page 
        // address that contains the low byte of an address (the address of 
        // caller's param block) and then the Y register (in our case that
        // is the offset within the param block to the y location) is added 
        // to that address to form the actual address of the memory to be loaded
        // into the accum with the lda 
        ldy #call_param_block_offset_y  // load Y reg with offset to y loc
        lda (ZERO_PAGE_LO),y            // indirect indexed load y loc to accum
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
// Code modification method of parameter passing to print a char somewhere 
// on first 5 lines.  Be for calling, the caller must specify the 
// character, x location (col), and y location (row) by overwriting
// the subroutine code at the following locations
// code_modification_x_addr      offset 1 from subroutine label
// code_modification_y_addr      offset 3 from subroutine label
// code_modification_char_addr   offset 17 from subroutine label
// In the future if the code is changed and that results in moving these
// locations instructions then these addresses will need to be updated.
// Setup by writing byte values to the following locations before calling:
//   code_modification_x_addr: X (col) location for char to print 
//   code_modification_y_addr: Y (row) location for char to print (0-5 only)
//   code_modification_char_addr: Char to print
//   JSR to this routine
// Pros:
//   - All registers free for use within routine
//   - JSR and RTS work as designed.
//   - param values persist between calls
//   - could be tedius to call when lots of parameters
//   - code simple to write and understand
// Cons:
//   - Hard to maintain because code changes could move the locations that
//   - callers need to overwrite 
//   - much like function defined param block all parameters have to be set
//     every call can't maintain them in separate blocks   
//   
////////////////////////////////////////////////////////////////////////////////
PrintCharCodeModification:
{
        lda #0               // load accum with X location (col) 
                             // the #0 is at offset = 1 and must be 
                             // overwritten before calling
        ldy #0               // load Y reg with Y location (row).  The 
                             // #0 is at offset = 3 and must be overwritten
                             // before calling

        beq DoneY            // when Y is 0 then we've added enough 
LoopY:
        clc
        adc #SCREEN_COLS
        dey
        beq DoneY                  // if Y still not 0 then loop up and add again
        jmp LoopY
DoneY:
        tay                        // move just calculated offest to Y reg
        lda #0                     // move char to print to the accum.  the #0 is at
                                   // offset = 17.  this must be overwritten with
                                   // the char to print before calling
        sta SCREEN_START_ADDR,y    // store the char to print to screen start + offset   
        
        rts
}



//////////////////////////////////////////////////////////////////////////////
// Function defined parameter block method of parameter passing to print 
// a char somewhere on first 5 lines by passing the:
// x locatoin (column), y location (row), and char to print in a 
// function defined parameter block.
// Setup data in the following addresses with the parameters befor calling 
//   func_param_block_x_addr    : X (col) location for char in Accumulator 
//   func_param_block_x_addr    : Y (row) location for char in Y reg (0 - 5)
//   func_param_block_char_addr : Char to print
//  After setup above then JSR to this routine
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
// x location (column), y location (row) in registers
// Setup registers as follows before calling:
//   Accum: X location (col) for char in Accumulator 
//   Y Reg: Y location (Row) for char in Y reg.  only values 0 to 5
//   X Reg: Character to print
//   JSR to this routine
// Pros:
//   - easy to setup.
//   - JSR and RTS work as designed.
// Cons:
//   - Can only pass 3 bytes of information this way.  if more info needed
//     then need another strategy.
//   - likely need to set all parameters before each call because likely
//     that all registers will have changed between calls.
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






