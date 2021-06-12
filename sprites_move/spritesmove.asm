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

// min and max speed for all sprites
.const MAX_SPEED = 6
.const MIN_SPEED = 1

// ship variables
ship_x_loc:
        .word 22
ship_y_loc: 
        .byte 50
ship_speed: 
        .byte 4

// asteroid variables
asteroid_x_loc: 
        .word 265
asteroid_y_loc: 
        .byte 50
asteroid_speed: 
        .byte 1

// some loop indices
loop_index_1: .byte 0
loop_index_2: .byte 0


*=$08F8

// two bytes to store the return address from the stack temporarily while 
// popping other parameters from the stack 
temp_rts_lsb:
        .byte $00
temp_rts_msb:
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

        lda #MAX_SPEED
        sta ship_speed

        lda #MIN_SPEED
        sta asteroid_speed

        
        ldy #12                 // outer loops counts down from this number to 0 
        sty loop_index_2

OuterLoop:
        ldy #100                // inner loop counts down from this number to zero
        sty loop_index_1

InnerLoop:
        nv_sprite_wait_scan()   // update sprites after particular scan line or will be too fast to see.
        
        //// call function to move sprite in x direction
        lda ship_speed          // push the number of pixels to move it.
        pha                     // the subroutine will pop this off
        jsr MoveShipX           
        
        //// call routine to move asteroid in y direction
        lda asteroid_speed      // push the number of pixels to move it 
        pha                     // the subroutine will pop this off
        jsr MoveAsteroidY

        // loop back for inner loop if appropriate
        dec loop_index_1
        bne InnerLoop

        // inner loop finished change speed of sprites before checking outer loop
        dec ship_speed          // decrement ship speed
        bne SkipShipMax         // if its not zero yet then skip setting to max
        lda #MAX_SPEED          // if it is zero then set it back to the max speed
        sta ship_speed          // save the new ship speed (max speed)

 SkipShipMax:                   
        inc asteroid_speed      // increment asteroid speed 
        lda asteroid_speed      // load new speed just incremented
        cmp #MAX_SPEED+1        // compare new spead with max +1
        bne SkipAsteroidMin     // if we haven't reached max + 1 then skip settin to min
        lda #MIN_SPEED          // else, we have reached max+1 so need to reset it back min
        sta asteroid_speed

SkipAsteroidMin:
        // now we can loop back for outer loop if appropriate.
        dec loop_index_2
        bne OuterLoop

        // Done moving sprites, move cursor out of the way 
        // and return, but leave the sprites on the screen
        nv_screen_plot_cursor(5, 24)
        rts   // program done, return



////////////////////////////////////////////////////////////
// subroutine to increment ship's x position by the 
// number of pixels pushed on the stack before JSR was called
// Note if the sprite goes off the right edge it will be 
// reset to the left edge
MoveShipX:
{
        pla               // pull LSB of return address
        sta temp_rts_lsb  // store in Temp memory
        pla               // pull MSB of return address
        sta temp_rts_msb  // save other byte in temp memory

        pla               // now pull param1, num pixels to move
        clc
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
        cmp #78                         // if x location reaches this AND MSB of x loc isn't zero, then
        bcs ResetX                      // carry will be set and need to reset X loc to left side
        jmp UpdateRegisterLoc           // if we didn't branch above the we can update actual 
                                        // sprite register
ResetX: 
        lda #22                         // set sprite x to this location
        sta ship_x_loc
        lda #0                          // also clear the high bit of the x location
        sta ship_x_loc + 1

UpdateRegisterLoc:        
        jsr SetShipLocFromMem           // Actually update sprite from the x and y loc in memory

FinishedUpdate:
        lda temp_rts_msb                // restore the return addr (minus 1) so we can call rts.
        pha
        lda temp_rts_lsb
        pha
        rts                // already popped the return address, jump back now
}



////////////////////////////////////////////////////////////
// subroutine to increment ship's x position by the 
// number of pixels pushed on the stack before JSR was called
// Note if the sprite goes off the bottom edge it will be 
// reset to the top
MoveAsteroidY:
{
        pla               // pull LSB of return address
        sta temp_rts_lsb  // store in Temp memory
        pla               // pull MSB of return address
        sta temp_rts_msb  // save other byte in temp memory

        pla               // now pull param1, num pixels to move
        clc
        adc asteroid_y_loc // add the number of pixels to move down
        cmp #250           // check if off bottom of screen
        bcs ResetY         // accum is >= to compare value, so set y back to 0
        sta asteroid_y_loc // if didn't branch above then update the y loca
        jmp UpdateRegisterLoc  // and jump to actually update the sprite location

ResetY: 
        lda #10             // reset the y location back near the top of screen
        sta asteroid_y_loc  // store it in our memory location    

UpdateRegisterLoc:        
        jsr SetAsteroidLocFromMem  // now actually set the sprite register with new y loc 

FinishedUpdate:
        lda temp_rts_msb    // restore the return address (minus -1) so can call rts.
        pha
        lda temp_rts_lsb
        pha
        rts
}

// pull in macro routine that sets sprite 0 location from memory locations
// this routine won't do any checking as far as if the sprite is being put 
// to a valid location.  it will blindly put it wherever specified.
SetShipLocFromMem:
nv_sprite_set_location_from_memory_sr(0, ship_x_loc, ship_y_loc)

// pull in macro routine that sets sprite 1 location from memory locations
// this routine won't do any checking as far as if the sprite is being put 
// to a valid location.  it will blindly put it wherever specified.
SetAsteroidLocFromMem:
nv_sprite_set_location_from_memory_sr(1, asteroid_x_loc, asteroid_y_loc)
