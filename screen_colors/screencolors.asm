// 10 SYS (4096)

*=$0801 "BASIC"

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


.var CLEAR_SCREEN_KERNAL = $E544     // Kernal routine to clear screen

.var PRINT_STRING_BASIC = $AB1E      // Basic routine to print text

// inner loop index/counter
inner_counter: .byte 0

// outer loop index/counter
outer_counter: .byte 0


*=$1000 "Main"
.var border_color_addr = $D020
.var background_color_addr = $D021

      
Main:
        jsr CLEAR_SCREEN_KERNAL // clear screeen leave cursor upper left
        //jsr PrintHello


CrazyBorder:
CrazyBorderLoop:

// Total iterations will be inner_max * outer_max
.var _inner_max = $FF        // number of iterations of inner loop
.var _outer_max = $B0        // number of iterations of outer loop

        // go to next boarder and background color
        inc border_color_addr      // inc val at border color addr
        inc background_color_addr  // inc val at bkgrd color addr

        // inc inner counter and if hasn't reached max then 
        // back to top of loop
        inc inner_counter          
        lda #_inner_max
        cmp inner_counter
        bne CrazyBorderLoop 

        // inner loop finished, reset inner_counter
        // to zero to prepare for next time through
        lda #00
        sta inner_counter
       
        // now inc and check outer loop counter
        // if we've completed all the outer loops then done
        inc outer_counter
        lda #_outer_max
        cmp outer_counter
        beq Done

        // still more to do, back to top of inner loop
        jmp CrazyBorderLoop
Done:
        rts




HelloStr: .text @"PRINTING HELLO 2\$00"    // string to print


PrintHello:
        lda #<HelloStr        // lsB of addr of string to print to A
        ldy #>HelloStr        // msB of addr of str to print to Y
        jsr PRINT_STRING_BASIC  // call kernal routine to print the string
        rts



