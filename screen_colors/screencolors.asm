//////////////////////////////////////////////////////////////////////////////
// screencolors.asm
// Copyright(c) 2021 Neal Smith.
// License: MIT. See LICENSE file in root directory.
//////////////////////////////////////////////////////////////////////////////
// Sample c64 program that shows how to cycle through the screen and border
// colors with no regard for syncing with scan lines


// 10 SYS (4096)
*=$0800 "BASIC Start"
        .byte $00               // first byte of basic should be zero
        // These bytes are a one line basic program that will 
        // do a sys call to assembly language portion of
        // of the program which will be at $1000 or 4096 decimal
        // basic line is: 
        // 10 SYS (4096)
        .byte $0E, $08           // Forward address to next basic line
        .byte $0A, $00           // this will be line 10 ($0A)
        .byte $9E                // basic token for SYS
        .byte $20, $28,  $34, $30, $39, $36, $29 // ASCII for " (4096)"
        .byte $00, $00, $00      // end of basic program (addr $080E from above)

// program var for inner loop index/counter
inner_counter: .byte 0

// program var for outer loop index/counter
outer_counter: .byte 0


*=$1000 "Main Start"
Main:
        // assembler constants for special addresses
        .const BORDER_COLOR_ADDR = $D020         // c64 addr scrn border color
        .const BACKGROUND_COLOR_ADDR = $D021     // c64 addr bkgrd color
        .const CLEAR_SCREEN_KERNAL_ADDR = $E544  // addr Kernal clear screen

        // Assembler variables for loops. 
        // Total iterations will be _inner_max * _outer_max
        .const INNER_MAX = $FF        // number of iterations of inner loop
        .const OUTER_MAX = $B0        // number of iterations of outer loop
       

        // call kernal clear screen routine leave cursor upper left
        jsr CLEAR_SCREEN_KERNAL_ADDR

CrazyBorderLoop:

        // next boarder and background color
        inc BORDER_COLOR_ADDR      // inc val at border color addr
        inc BACKGROUND_COLOR_ADDR  // inc val at bkgrd color addr

        // inc inner counter and if hasn't reached max then 
        // back to top of loop
        inc inner_counter          
        lda #INNER_MAX
        cmp inner_counter
        bne CrazyBorderLoop 

        // inner loop finished, reset inner_counter
        // to zero to prepare for next time through
        lda #00
        sta inner_counter
       
        // now inc and check outer loop counter
        // if we've completed all the outer loops then done
        inc outer_counter
        lda #OUTER_MAX
        cmp outer_counter
        beq Done

        // still more to do, back to top of inner loop
        jmp CrazyBorderLoop
Done:
        rts



