//////////////////////////////////////////////////////////////////////////////
// hello.asm
// Copyright(c) 2021 Neal Smith.
// License: MIT. See LICENSE file in root directory.
//////////////////////////////////////////////////////////////////////////////
// This sample shows two ways to print to the screen
// 1 Calling a routine in BASIC
// 2 Writing direct to screen memory


*=$0800 "BASIC Start"  
        // location to put a 1 line basic program so we can just
        // type run to execute the assembled program.
        
        // will just call assembled program at correct location
        //    10 SYS (4096)

        // These bytes are a one line basic program that will 
        // do a sys call to assembly language portion of
        // of the program which will be at $1000 or 4096 decimal
        // basic line is: 
        // 10 SYS (4096)
        .byte $00                // first byte of basic should be a zero
        .byte $0E, $08           // Forward address to next basic line
        .byte $0A, $00           // this will be line 10 ($0A)
        .byte $9E                // basic token for SYS
        .byte $20, $28, $34, $30, $39, $36, $29 // ASCII for " (4096)"
        .byte $00, $00, $00      // end of basic program (addr $080E from above)


        // assembler constants for special memory locations
        .const CLEAR_SCREEN_KERNAL_ADDR = $E544     // Kernal routine to clear screen
        .const PRINT_STRING_BASIC_ADDR = $AB1E      // Basic routine to print text
        .const SCREEN_START = $0400                 // The start of c64 screen memory

        // a somewhat random location in screen memory to write to directly
        .const SCREEN_DIRECT_START = SCREEN_START + $0100 

// program variables
str_to_print: .text @"HELLO VIA BASIC\$00"  // null terminated string to print
                                            // via the BASIC routine

str_to_poke: .text  @"hello direct\$00"  // null terminated string to print
                                         // via copy direct to screen memory

// our assembly code will goto this address
*=$1000 "Main Start"

        // clear screeen leave cursor upper left
        jsr CLEAR_SCREEN_KERNAL_ADDR 
        
        // method 1 call basic routine since we cleared screen 
        // above the string will start in upper left
        lda #<str_to_print           // LSB of addr of string to print to A
        ldy #>str_to_print           // MSB of addr of str to print to Y
        jsr PRINT_STRING_BASIC_ADDR  // call kernal routine to print the string

        // method 2 write direct to screen memory
        ldx #0                  // use x reg as loop index start at 0
DirectLoop:
        lda str_to_poke,x         // put a byte from string into accum
        beq Done                // if the byte was 0 then we're done 
        sta SCREEN_DIRECT_START,x // Store the byte to screen
        inx                     // inc to next byte and next screen location 
        jmp DirectLoop          // Go back for next byte
Done:
        
        rts                     // program done, return

