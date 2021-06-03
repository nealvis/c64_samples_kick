// This sample shows two ways to print to the screen
// 1 Calling a routine in BASIC
// 2 Writing direct to screen memory

// import some macros 
#import "../nv_c64_util/nv_c64_util.asm"


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
ship_x_loc:
        .word 22
ship_y_loc: 
        .byte 50

asteroid_x_loc: 
        .word 265
asteroid_y_loc: 
        .byte 50

*=$08F8
TempRtsLsb:
        .byte $00

TempRtsMsb:
        .byte $00


// set the address for our sprite, sprite_0 aka sprite_ship.  It must be evenly divisible by 64
// since code starts at $1000 there is room for 4 sprites between $0900 and $1000
*=$0900 "Sprites"

        // Byte 64 of each sprite contains the following:
        //   high nibble: high bit set (8) if multi color, or cleared (0) if single color/high res
        //   low nibble: this sprite's color in it 0-F
        sprite_ship:
        // saved from spritemate
        // sprite 0 / multicolor / color: $04
        sprite_0:
        .byte $00,$00,$00,$00,$00,$00,$00,$00
        .byte $00,$40,$00,$00,$13,$c0,$00,$5e
        .byte $b0,$00,$5e,$ac,$00,$12,$ab,$00
        .byte $43,$aa,$c0,$03,$aa,$b0,$00,$aa
        .byte $ac,$03,$aa,$b0,$43,$aa,$c0,$12
        .byte $ab,$00,$5e,$ac,$00,$5e,$b0,$00
        .byte $13,$c0,$00,$40,$00,$00,$00,$00
        .byte $00,$00,$00,$00,$00,$00,$00,$84

        sprite_asteroid:
        // saved from spritemate:
        // sprite 1 / singlecolor / color: $0f
        sprite_1:
        .byte $00,$3f,$00,$00,$7f,$80,$00,$ff
        .byte $c0,$00,$ff,$c0,$1f,$ff,$c0,$3f
        .byte $ff,$e0,$7f,$ff,$fc,$7f,$ff,$fe
        .byte $7f,$ff,$fe,$7f,$ff,$fe,$3f,$ff
        .byte $fe,$1f,$ff,$fe,$1f,$ff,$fc,$1f
        .byte $ff,$fc,$1f,$ff,$f8,$1f,$ff,$f8
        .byte $1f,$ff,$f0,$0f,$f1,$c0,$0f,$e0
        .byte $80,$03,$c0,$00,$00,$00,$00,$0f



// our assembly code will goto this address
*=$1000 "Main Start"

        // clear the screen just to have an empty canvas
        nv_screen_clear()

        // set the global sprite multi colors        
        nv_sprite_set_multicolors(NV_COLOR_LITE_GREEN, NV_COLOR_WHITE)

        // setup everything for the sprite_ship so its ready to enable
        nv_sprite_setup($00, sprite_ship)

        // setup everything for the sprite_asteroid so its ready to enable
        nv_sprite_setup($01, sprite_asteroid)

        // set locations for both sprites
        .var ship_x = 22
        .var ship_y = 50
        .var asteroid_x = 265
        .var asteroid_y = 50
        //nv_sprite_set_loc($00, ship_x, ship_y)
        //nv_sprite_set_loc($01, asteroid_x, asteroid_y)

        jsr SetShipLocFromMem 
        jsr SetAsteroidLocFromMem

        // enable both sprites
        nv_sprite_enable($00)
        nv_sprite_enable($01)

        ldy #150

LoopStart:
        nv_sprite_wait_scan()
        lda #4
        pha
        jsr MoveShipX
        dey
        bne LoopStart

/*
        .for(var index=0;index<150;index++)
        {
                nv_sprite_wait_scan()
                //.print "Number " + index
                .var new_x = ship_x + 1 * index
                nv_sprite_set_loc($00, new_x, ship_y)
                nv_sprite_set_loc($01, asteroid_x, asteroid_y)
        }
*/
        // move cursor out of the way before returning
        nv_screen_plot_cursor(5, 24)
        rts   // program done, return

////////////////////////////////////////////////////////////
// subroutine to increment ship's x position by the 
// number of pixels in accumulator
MoveShipX:
{
        pla             // pull LSB of return address
        sta TempRtsLsb  // store in Temp memory
        pla             // pull MSB of return address
        sta TempRtsMsb  // save other byte in temp memory
        inc TempRtsLsb  // since JSR stores ret addr minus 1 must add 1
        bne SkipIncMsb  // if didn't roll over to zero then skip MSB inc
        inc TempRtsMsb  // did roll over to zero so inc MSB too
SkipIncMsb:

        pla             // now pull param1, num pixels to move
        clc
        //lda #2
        adc ship_x_loc
        bcs IncByte2                    // accum (old x loc) > new x loc so inc high byte 
        jmp SkipByte2 
IncByte2:
        sta ship_x_loc
        inc ship_x_loc+1
SkipByte2:
        sta ship_x_loc
        lda ship_x_loc+1
        beq UpdateRegisterLoc           // high byte is zero so don't bother testing right border
        lda ship_x_loc
        cmp #$20
        bcs ResetX                      // accum greater than or equal to memory loc
        jmp UpdateRegisterLoc
ResetX: 
        lda #$00
        sta ship_x_loc
        sta ship_x_loc + 1
UpdateRegisterLoc:        
        jsr SetShipLocFromMem
FinishedUpdate:        
        jmp (TempRtsLsb)                // already popped the return address, jump back now
}

SetShipLocFromMem:
nv_sprite_set_location_from_memory(0, ship_x_loc, ship_y_loc)

SetAsteroidLocFromMem:
nv_sprite_set_location_from_memory(1, asteroid_x_loc, asteroid_y_loc)

