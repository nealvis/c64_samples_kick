// This sample shows two ways to print to the screen
// 1 Calling a routine in BASIC
// 2 Writing direct to screen memory


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


        // assembler constants for special memory locations
        .const CLEAR_SCREEN_KERNAL_ADDR = $E544     // Kernal routine to clear screen


// set the address for sprite 0 it must be evenly divisible by 64
// sprite 0 / multicolor / color: $01
*=$0900 "Sprite 0"

        // Byte 64 of each sprite contains multicolor (high nibble) & color (low nibble) information
        sprite_0:
        .byte $00,$00,$00,$00,$00,$00,$00,$00
        .byte $00,$00,$00,$00,$12,$80,$00,$1b
        .byte $e0,$00,$1b,$f8,$00,$13,$fe,$00
        .byte $02,$ff,$80,$00,$ff,$e0,$00,$bf
        .byte $f8,$00,$ff,$e0,$02,$ff,$80,$13
        .byte $fe,$00,$1b,$f8,$00,$1b,$e0,$00
        .byte $12,$80,$00,$00,$00,$00,$00,$00
        .byte $00,$00,$00,$00,$00,$00,$00,$81


// our assembly code will goto this address
*=$1000 "Main Start"

        .const SPRITE_ENABLE_REG_ADDR = $d015 // each bit turns on one of the sprites lsb is sprite 0, msb is sprite 7
        .const SPRITE_COLOR_1_ADDR = $D025 // address of color for sprite bits that are binary 01
        .const SPRITE_COLOR_2_ADDR = $D026 // address of color for sprite bits that are binary 11
        .const SPRITE_0_DATA_PTR_ADDR = $07F8  // address of the pointer to sprite_0's data its only 8 bits 
                                        // so its implied that this value will be multipled by 64 
        .const SPRITE_0_X_ADDR = $D000
        .const SPRITE_0_Y_ADDR = $D001

        // register with one bit for each sprite to indicate high res (one color)
        // or multi color.  Bit 0 (lsb) corresponds to sprite 0
        // set bit to 1 for multi color, or 0 for high res (one color mode)
        .const SPRITE_MODE_REG_ADDR = $D01C 

        // since there are more than 255 x locations across the screen
        // the high bit for each sprite's X location is gathered in the 
        // byte here.  sprite_0's ninth bit is bit 0 of the byte at this addr.
        .const ALL_SPRITE_X_HIGH_BIT_ADDR = $D010

        // clear screeen leave cursor upper left
        jsr CLEAR_SCREEN_KERNAL_ADDR 
        
        // set sprite 0 to muli color mode and all other sprites to high res
        lda #$01
        sta SPRITE_MODE_REG_ADDR

        lda #(sprite_0 / 64)
        sta SPRITE_0_DATA_PTR_ADDR

        lda #$07 // sprite multicolor 1
        sta $D025
        lda #$08 // sprite multicolor 2
        sta $D026

        // turn on sprit 0?
        lda #$01
        sta $d015

        // set sprite 0 x loc
        lda #22
        sta SPRITE_0_X_ADDR

        // set sprite 0 y loc
        lda #50
        sta SPRITE_0_Y_ADDR

        rts                     // program done, return

