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


// set the address for our sprite, sprite_0 aka sprite_ship.  It must be evenly divisible by 64
*=$0900 "Sprite 0"

        // Byte 64 of each sprite contains the following:
        //   high nibble: high bit set (8) if multi color, or cleared (0) if single color/high res
        //   low nibble: this sprite's color in it 0-F
        sprite_0:
        sprite_ship:
        .byte $00,$00,$00,$00,$00,$00,$00,$00
        .byte $00,$40,$00,$00,$13,$c0,$00,$5e
        .byte $b0,$00,$5e,$ac,$00,$12,$ab,$00
        .byte $43,$aa,$c0,$03,$aa,$b0,$00,$aa
        .byte $ac,$03,$aa,$b0,$43,$aa,$c0,$12
        .byte $ab,$00,$5e,$ac,$00,$5e,$b0,$00
        .byte $13,$c0,$00,$40,$00,$00,$00,$00
        .byte $00,$00,$00,$00,$00,$00,$00,$84


// our assembly code will goto this address
*=$1000 "Main Start"

        // c64 colors
        .const C64_COLOR_BLACK = $00
        .const C64_COLOR_WHITE = $01
        .const C64_COLOR_RED = $02
        .const C64_COLOR_CYAN = $03
        .const C64_COLOR_PURPLE = $04
        .const C64_COLOR_GREEN = $05
        .const C64_COLOR_BLUE = $06
        .const C64_COLOR_YELLOW = $07
        .const C64_COLOR_ORANGE = $08
        .const C64_COLOR_BROWN = $09
        .const C64_COLOR_LITE_RED = $0a
        .const C64_COLOR_DARK_GREY = $0b
        .const C64_COLOR_GREY = $0c
        .const C64_COLOR_LITE_GREEN = $0d
        .const C64_COLOR_LITE_BLUE = $0e
        .const C64_COLOR_LITE_GREY = $0f

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

        // the low 4 bits (0-3) contain the color for sprite 0
        // the hi 4 bits don't seem to be writable
        .const SPRITE_0_COLOR_REG_ADDR = $d027


        //////////////////////////////////////////////////////////////////////
        // clear screeen leave cursor upper left
        jsr CLEAR_SCREEN_KERNAL_ADDR 
        
        //////////////////////////////////////////////////////////////////////
        // Setup the system for our sprite, sprite_0 aka sprite_ship
        // the steps are:
        // Step 1. set the sprite mode for the sprite to multi color or 
        //         high res (one color)
        // Step 2. set the global multi color sprite colors
        // Step 3. set the sprite data pointer for to the 64 bytes at sprite_ship label
        // Step 4. set the distinct color for sprite 3 


        ////// Step 1: set mode for sprite_0 /////////////////////////////////

        // set it to single color (high res) and override below if needed
        lda #$00
        sta SPRITE_MODE_REG_ADDR

        lda #$F0                // load mask in A, checking for any ones in high nibble
        bit sprite_0 + 63       // set Zero flag if the masked bits are all 0s
                                // if any masked bits in the last byte of sprite_0 are set 
                                // then its a multi colored sprite
        beq skip_multicolor     // if Zero is set, ie no masked bits were set, then branch
                                // to skip multi color mode.

        // If we didn't skip the multi color, then set sprite 0 to muli color mode
        lda #$01                // we are loading a 1 to set sprite_0 as multi color
        sta SPRITE_MODE_REG_ADDR // we are also clearing all the other bits for sprites 1-7 
skip_multicolor:
        ////// Step 1 done ///////////////////////////////////////////////////

        ////// step 2: Set the two global colors for multi color sprites /////
        lda #C64_COLOR_LITE_GREEN // multicolor sprites global color 1
        sta SPRITE_COLOR_1_ADDR
        lda #C64_COLOR_WHITE      // multicolor sprites global color 2
        sta SPRITE_COLOR_2_ADDR
        ////// step 2 done ///////////////////////////////////////////////////


        ////// Step 2 set sprite data pointer ////////////////////////////////
        lda #(sprite_0 / 64)            // implied this is multiplied by 64
        sta SPRITE_0_DATA_PTR_ADDR
        ////// step 2 done ///////////////////////////////////////////////////

        ////// step 3: set this sprites unique color /////////////////////////
        // set this sprite's color.  
        lda sprite_0 + 63               // The color is the low nibble of the
                                        // last byte of sprite. We'll just 
                                        // write the whole byte because the
                                        // only lo 4 bits of reg are writable
        sta SPRITE_0_COLOR_REG_ADDR     
        ////// step 3 done ///////////////////////////////////////////////////



        //////////////////////////////////////////////////////////////////////
        // Display the sprite, all the setup is done.  There are two 
        // steps to show the sprite on the screen
        // Step 1. Enable the sprite
        // Step 2. Set sprite's location

        ////// step 1: enable sprite /////////////////////////////////////////
        lda SPRITE_ENABLE_REG_ADDR      // load with sprite enabled reg
        ora #$01                        // set the bit for sprite 0, 
                                        // Leaving other bits untouched
        sta SPRITE_ENABLE_REG_ADDR      // store to sprite enable register 
                                        // one bit for each sprite.
        ////// step 1 done ///////////////////////////////////////////////////


        ////// step 2: Set Sprite Location ///////////////////////////////////
        // set sprite 0 x loc
        lda #22                 // picking X loc for left of screen
        sta SPRITE_0_X_ADDR

        // set sprite 0 y loc
        lda #50                 // picking Y loc for top of screen
        sta SPRITE_0_Y_ADDR
        ////// step 2 done ///////////////////////////////////////////////////

        rts                     // program done, return

