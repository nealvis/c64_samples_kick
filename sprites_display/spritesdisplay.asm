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


        ////////////////////////////////////////////////////////////////////////////
        // clear screeen leave cursor upper left
        jsr CLEAR_SCREEN_KERNAL_ADDR 
        
        ////////////////////////////////////////////////////////////////////////////
        // setup the system for our sprite, sprite_0 aka sprite_ship
        // the steps are:
        // Step 1. set the sprite mode for the sprite to multi color or high res (one color)
        // Step 2. set the sprite data pointer for to the 64 bytes at sprite_ship label
        // Step 3. set the distinct color for sprite 3 
        // Step 4. set the global multi color sprite colors
        // Step 5. Enable the sprite
        // Step 6. Set sprite's location

        ////// Step 1. //////

        // assume single color (high res) and override below if needed
        lda #$00
        sta SPRITE_MODE_REG_ADDR

        lda #$F0                // load mask in A 
        bit sprite_0 + 63       // set Zero flag if the masked bits are all 0s
                                // if any masked bits in the sprite + 63 were set then
                                // assume its a multi colored sprite
        beq skip_multicolor     // if Zero is set, ie no masked bits were set, then branch
                                // to skip multi color mode.
        // set sprite 0 to muli color mode and all other sprites to high res
        lda #$01
        sta SPRITE_MODE_REG_ADDR
skip_multicolor:
        ////// Step 1 done //////

        ////// Step 2 //////
        lda #(sprite_0 / 64)
        sta SPRITE_0_DATA_PTR_ADDR
        ////// step 2 done //////

        ////// step 3 //////
        // set this sprite's color
        lda sprite_0 + 63
        sta SPRITE_0_COLOR_REG_ADDR
        ////// step 3 done //////

        ////// step 4 //////
        lda #$0d // multicolor sprites global color 1
        sta SPRITE_COLOR_1_ADDR
        lda #$01 // multicolor sprites global color 2
        sta SPRITE_COLOR_2_ADDR
        ////// step 4 done //////

        ////// step 5 //////
        lda #$01                        // set the bit for sprite 0, note we are clearing other bits
        sta SPRITE_ENABLE_REG_ADDR      // store to sprite enable register one bit for each sprite.
        ////// step 5 done //////

        ////// step 6 //////
        // set sprite 0 x loc
        lda #22
        sta SPRITE_0_X_ADDR

        // set sprite 0 y loc
        lda #50
        sta SPRITE_0_Y_ADDR
        ////// step 6 done //////
        
        rts                     // program done, return

