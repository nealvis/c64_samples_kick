// sprite test program

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
.const MIN_SPEED = -6

// some loop indices
loop_index_1: .byte 0
loop_index_2: .byte 0

cycling_color: .byte NV_COLOR_FIRST


// set the address for our sprite, sprite_0 aka sprite_ship.  It must be evenly divisible by 64
// since code starts at $1000 there is room for 4 sprites between $0900 and $1000
*=$0900 "SpriteData"

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

        sprite_asteroid_1:
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

        sprite_asteroid_2:
        // saved from spritemate:
        // sprite 2 / singlecolor / color: $0f
        sprite_2:
        .byte $00,$3f,$00,$00,$7f,$80,$00,$ff
        .byte $c0,$00,$ff,$c0,$1f,$ff,$c0,$3f
        .byte $ff,$e0,$7f,$ff,$fc,$7f,$ff,$fe
        .byte $7f,$ff,$fe,$7f,$ff,$fe,$3f,$ff
        .byte $fe,$1f,$ff,$fe,$1f,$ff,$fc,$1f
        .byte $ff,$fc,$1f,$ff,$f8,$1f,$ff,$f8
        .byte $1f,$ff,$f0,$0f,$f1,$c0,$0f,$e0
        .byte $80,$03,$c0,$00,$00,$00,$00,$0d

       sprite_asteroid_3:
        // saved from spritemate:
        // sprite 3 / singlecolor / color: $0f
        sprite_3:
        .byte $00,$3f,$00,$00,$7f,$80,$00,$ff
        .byte $c0,$00,$ff,$c0,$1f,$ff,$c0,$3f
        .byte $ff,$e0,$7f,$ff,$fc,$7f,$ff,$fe
        .byte $7f,$ff,$fe,$7f,$ff,$fe,$3f,$ff
        .byte $fe,$1f,$ff,$fe,$1f,$ff,$fc,$1f
        .byte $ff,$fc,$1f,$ff,$f8,$1f,$ff,$f8
        .byte $1f,$ff,$f0,$0f,$f1,$c0,$0f,$e0
        .byte $80,$03,$c0,$00,$00,$00,$00,$0c

        sprite_asteroid_4:
        // saved from spritemate:
        // sprite 3 / singlecolor / color: $0f
        sprite_4:
        .byte $00,$3f,$00,$00,$7f,$80,$00,$ff
        .byte $c0,$00,$ff,$c0,$1f,$ff,$c0,$3f
        .byte $ff,$e0,$7f,$ff,$fc,$7f,$ff,$fe
        .byte $7f,$ff,$fe,$7f,$ff,$fe,$3f,$ff
        .byte $fe,$1f,$ff,$fe,$1f,$ff,$fc,$1f
        .byte $ff,$fc,$1f,$ff,$f8,$1f,$ff,$f8
        .byte $1f,$ff,$f0,$0f,$f1,$c0,$0f,$e0
        .byte $80,$03,$c0,$00,$00,$00,$00,$0e

        sprite_asteroid_5:
        // saved from spritemate:
        // sprite 3 / singlecolor / color: $0f
        sprite_5:
        .byte $00,$3f,$00,$00,$7f,$80,$00,$ff
        .byte $c0,$00,$ff,$c0,$1f,$ff,$c0,$3f
        .byte $ff,$e0,$7f,$ff,$fc,$7f,$ff,$fe
        .byte $7f,$ff,$fe,$7f,$ff,$fe,$3f,$ff
        .byte $fe,$1f,$ff,$fe,$1f,$ff,$fc,$1f
        .byte $ff,$fc,$1f,$ff,$f8,$1f,$ff,$f8
        .byte $1f,$ff,$f0,$0f,$f1,$c0,$0f,$e0
        .byte $80,$03,$c0,$00,$00,$00,$00,$0e


// our assembly code will goto this address
*=$1000 "Main Start"

        // clear the screen just to have an empty canvas
        nv_screen_clear()

        // set the global sprite multi colors        
        nv_sprite_set_multicolors(NV_COLOR_LITE_GREEN, NV_COLOR_WHITE)

        // setup everything for the sprite_ship so its ready to enable
        jsr ship_1.Setup

        // setup everything for the sprite_asteroid so its ready to enable
        jsr asteroid_1.Setup
        jsr asteroid_2.Setup
        jsr asteroid_3.Setup
        jsr asteroid_4.Setup
        jsr asteroid_5.Setup


        // initialize sprite locations from their extra data blocks 
        jsr ship_1.SetLocationFromExtraData
        jsr asteroid_1.SetLocationFromExtraData
        jsr asteroid_2.SetLocationFromExtraData
        jsr asteroid_3.SetLocationFromExtraData
        jsr asteroid_4.SetLocationFromExtraData
        jsr asteroid_5.SetLocationFromExtraData
        
        // enable both sprites
        nv_sprite_enable(0)
        nv_sprite_enable(1)
        nv_sprite_enable(2)
        nv_sprite_enable(3)
        nv_sprite_enable(4)
        nv_sprite_enable(5)

        ldy #12                 // outer loops counts down from this number to 0 
        sty loop_index_2

OuterLoop:
        ldy #100                // inner loop counts down from this number to zero
        sty loop_index_1

InnerLoop:
        nv_sprite_wait_scan()   // update sprites after particular scan line or will be too fast to see.

        //// call function to move ship based on X and Y velocity
        jsr ship_1.MoveInExtraData
        jsr ship_1.SetLocationFromExtraData


        //// call routine to move asteroid based on x and y velocity
        jsr asteroid_1.MoveInExtraData
        jsr asteroid_1.SetLocationFromExtraData

        //// call routine to move asteroid 2 based on x and y velocity
        jsr asteroid_2.MoveInExtraData
        jsr asteroid_2.SetLocationFromExtraData

        //// call routine to move asteroid 3 based on x and y velocity
        jsr asteroid_3.MoveInExtraData
        jsr asteroid_3.SetLocationFromExtraData

        //// call routine to move asteroid 3 based on x and y velocity
        jsr asteroid_4.MoveInExtraData
        jsr asteroid_4.SetLocationFromExtraData

        //// call routine to move asteroid 3 based on x and y velocity
        jsr asteroid_5.MoveInExtraData
        jsr asteroid_5.SetLocationFromExtraData

        // loop back for inner loop if appropriate
        dec loop_index_1
        bne InnerLoop

        // inner loop finished change some colors and speeds

        // change some colors
        jsr cycle_colors

        // change some speeds
        dec ship_1.x_vel          // decrement ship speed
        bne SkipShipMax         // if its not zero yet then skip setting to max
        lda #MAX_SPEED          // if it is zero then set it back to the max speed
        sta ship_1.x_vel          // save the new ship speed (max speed)


SkipShipMax:                   
        inc asteroid_1.y_vel    // increment asteroid Y velocity 
        lda asteroid_1.y_vel    // load new speed just incremented
        cmp #MAX_SPEED+1        // compare new spead with max +1
        bne SkipAsteroidMin     // if we haven't reached max + 1 then skip setting to min
        lda #MIN_SPEED          // else, we have reached max+1 so need to reset it back min
        sta asteroid_1.y_vel

SkipAsteroidMin:
        // now we can loop back for outer loop if appropriate.
        dec loop_index_2
        bne OuterLoop

        // Done moving sprites, move cursor out of the way 
        // and return, but leave the sprites on the screen
        nv_screen_plot_cursor(5, 24)
        rts   // program done, return


//////////////////////////////////////////////////////////////////////////////
// subroutine to cycle the color of a sprite just to show how
// the nv_sprite_set_color_from_memory macro works.
cycle_colors:
        ldx cycling_color
        inx
        cpx #NV_COLOR_BLUE // blue is default backgroumd, so skip that one
        bne NotBlue
        inx
NotBlue:
        cpx #NV_COLOR_LAST + 1
        bne SetColor
        ldx #NV_COLOR_FIRST
        stx cycling_color
SetColor:
        stx cycling_color
        nv_sprite_set_color_from_memory(1, cycling_color)
        rts

//////////////////////////////////////////////////////////////////////////////
// Namespace with everything related to asteroid 1
.namespace asteroid_1
{
        .var info = nv_sprite_info_struct("asteroid_1", 1, 265, 40, 1, -1, sprite_asteroid_1, 
                                          sprite_extra, 1, 1, 1, 1)

        .label x_loc = info.base_addr + NV_SPRITE_X_OFFSET
        .label y_loc = info.base_addr + NV_SPRITE_Y_OFFSET
        .label x_vel = info.base_addr + NV_SPRITE_VEL_X_OFFSET
        .label y_vel = info.base_addr + NV_SPRITE_VEL_Y_OFFSET

// sprite extra data
sprite_extra:
        nv_sprite_extra_data(info)

// subroutine to set sprites location in sprite registers based on the extra data
SetLocationFromExtraData:
        nv_sprite_set_location_from_memory_sr(info.num, info.base_addr+NV_SPRITE_X_OFFSET, info.base_addr+NV_SPRITE_Y_OFFSET)

// setup sprite so that it ready to be enabled and displayed
Setup:
        nv_sprite_setup_sr(info.num, info.data_addr)

// move the sprite x and y location in the extra data only, not in the sprite registers
// to move in the sprite registsers (and have screen reflect it) call the 
// SetLocationFromExtraData subroutine.
MoveInExtraData:
        nv_sprite_move_any_direction_sr(info)
}

//////////////////////////////////////////////////////////////////////////////
// Namespace with everything related to asteroid 1
.namespace asteroid_2
{
        .var info = nv_sprite_info_struct("asteroid_2", 2, 150, 150, 2, 2, sprite_asteroid_2, 
                                          sprite_extra, 1, 1, 1, 0)

        .label x_loc = info.base_addr + NV_SPRITE_X_OFFSET
        .label y_loc = info.base_addr + NV_SPRITE_Y_OFFSET
        .label x_vel = info.base_addr + NV_SPRITE_VEL_X_OFFSET
        .label y_vel = info.base_addr + NV_SPRITE_VEL_Y_OFFSET

// sprite extra data
sprite_extra:
        nv_sprite_extra_data(info)

// subroutine to set sprites location in sprite registers based on the extra data
SetLocationFromExtraData:
        nv_sprite_set_location_from_memory_sr(info.num, info.base_addr+NV_SPRITE_X_OFFSET, info.base_addr+NV_SPRITE_Y_OFFSET)

// setup sprite so that it ready to be enabled and displayed
Setup:
        nv_sprite_setup_sr(info.num, info.data_addr)

// move the sprite x and y location in the extra data only, not in the sprite registers
// to move in the sprite registsers (and have screen reflect it) call the 
// SetLocationFromExtraData subroutine.
MoveInExtraData:
        nv_sprite_move_any_direction_sr(info)
}


//////////////////////////////////////////////////////////////////////////////
// Namespace with everything related to asteroid 1
.namespace asteroid_3
{
        .var info = nv_sprite_info_struct("asteroid_3", 3, 75, 75, 2, -3, sprite_asteroid_3, 
                                          sprite_extra, 1, 1, 0, 0)

        .label x_loc = info.base_addr + NV_SPRITE_X_OFFSET
        .label y_loc = info.base_addr + NV_SPRITE_Y_OFFSET
        .label x_vel = info.base_addr + NV_SPRITE_VEL_X_OFFSET
        .label y_vel = info.base_addr + NV_SPRITE_VEL_Y_OFFSET

// sprite extra data
sprite_extra:
        nv_sprite_extra_data(info)

// subroutine to set sprites location in sprite registers based on the extra data
SetLocationFromExtraData:
        nv_sprite_set_location_from_memory_sr(info.num, info.base_addr+NV_SPRITE_X_OFFSET, info.base_addr+NV_SPRITE_Y_OFFSET)

// setup sprite so that it ready to be enabled and displayed
Setup:
        nv_sprite_setup_sr(info.num, info.data_addr)

// move the sprite x and y location in the extra data only, not in the sprite registers
// to move in the sprite registsers (and have screen reflect it) call the 
// SetLocationFromExtraData subroutine.
MoveInExtraData:
        nv_sprite_move_any_direction_sr(info)
}


//////////////////////////////////////////////////////////////////////////////
// Namespace with everything related to asteroid 1
.namespace asteroid_4
{
        .var info = nv_sprite_info_struct("asteroid_4", 4, 255, 75, 1, 0, sprite_asteroid_4, 
                                          sprite_extra, 0, 0, 0, 0)

        .label x_loc = info.base_addr + NV_SPRITE_X_OFFSET
        .label y_loc = info.base_addr + NV_SPRITE_Y_OFFSET
        .label x_vel = info.base_addr + NV_SPRITE_VEL_X_OFFSET
        .label y_vel = info.base_addr + NV_SPRITE_VEL_Y_OFFSET

// sprite extra data
sprite_extra:
        nv_sprite_extra_data(info)

// subroutine to set sprites location in sprite registers based on the extra data
SetLocationFromExtraData:
        nv_sprite_set_location_from_memory_sr(info.num, info.base_addr+NV_SPRITE_X_OFFSET, info.base_addr+NV_SPRITE_Y_OFFSET)

// setup sprite so that it ready to be enabled and displayed
Setup:
        nv_sprite_setup_sr(info.num, info.data_addr)

// move the sprite x and y location in the extra data only, not in the sprite registers
// to move in the sprite registsers (and have screen reflect it) call the 
// SetLocationFromExtraData subroutine.
MoveInExtraData:
        nv_sprite_move_any_direction_sr(info)
}


//////////////////////////////////////////////////////////////////////////////
// Namespace with everything related to asteroid 1
.namespace asteroid_5
{
        .var info = nv_sprite_info_struct("asteroid_5", 5, 85, 76, 2, -1, sprite_asteroid_5, 
                                          sprite_extra, 0, 0, 0, 0)

        .label x_loc = info.base_addr + NV_SPRITE_X_OFFSET
        .label y_loc = info.base_addr + NV_SPRITE_Y_OFFSET
        .label x_vel = info.base_addr + NV_SPRITE_VEL_X_OFFSET
        .label y_vel = info.base_addr + NV_SPRITE_VEL_Y_OFFSET

// sprite extra data
sprite_extra:
        nv_sprite_extra_data(info)

// subroutine to set sprites location in sprite registers based on the extra data
SetLocationFromExtraData:
        nv_sprite_set_location_from_memory_sr(info.num, info.base_addr+NV_SPRITE_X_OFFSET, info.base_addr+NV_SPRITE_Y_OFFSET)

// setup sprite so that it ready to be enabled and displayed
Setup:
        nv_sprite_setup_sr(info.num, info.data_addr)

// move the sprite x and y location in the extra data only, not in the sprite registers
// to move in the sprite registsers (and have screen reflect it) call the 
// SetLocationFromExtraData subroutine.
MoveInExtraData:
        nv_sprite_move_any_direction_sr(info)
}


//////////////////////////////////////////////////////////////////////////////
// namespace with everything related to ship sprite
.namespace ship_1
{
        .var info = nv_sprite_info_struct("ship_1", 0, 22, 50, 4, 1, sprite_ship, sprite_extra, 0, 0, 0, 0)

        .label x_loc = info.base_addr + NV_SPRITE_X_OFFSET
        .label y_loc = info.base_addr + NV_SPRITE_Y_OFFSET
        .label x_vel = info.base_addr + NV_SPRITE_VEL_X_OFFSET
        .label y_vel = info.base_addr + NV_SPRITE_VEL_Y_OFFSET

// the extra data that goes with the sprite
sprite_extra:
        nv_sprite_extra_data(info)

// subroutine to set the sprites location based on its address in extra block 
SetLocationFromExtraData:
        nv_sprite_set_location_from_memory_sr(info.num, info.base_addr+NV_SPRITE_X_OFFSET, info.base_addr+NV_SPRITE_Y_OFFSET)

// subroutine to setup the sprite so that its ready to be enabled and displayed
Setup:
        nv_sprite_setup_sr(info.num, info.data_addr)

// subroutine to move the sprite in memory only (the extra data)
// this will not update the sprite registers to actually move the sprite, but
// to do that just call SetShipeLocFromMem
MoveInExtraData:
        nv_sprite_move_any_direction_sr(info)
}

