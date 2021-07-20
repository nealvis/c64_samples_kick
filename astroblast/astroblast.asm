//////////////////////////////////////////////////////////////////////////////
// astroblast.asm
// AstroBlaster Main program
//////////////////////////////////////////////////////////////////////////////

#import "../nv_c64_util/nv_c64_util_macs_and_data.asm"

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

*=$0820 "Main Program Vars"

// min and max speed for all sprites
.const MAX_SPEED = 6
.const MIN_SPEED = -6
.const FPS = 60
.const KEY_COOL_DURATION = $08

// These are the keys that do something in the game
.const KEY_SHIP1_SLOW_X = NV_KEY_A
.const KEY_SHIP1_FAST_X = NV_KEY_D
.const KEY_QUIT = NV_KEY_Q
.const KEY_PAUSE = NV_KEY_P
.const KEY_INC_BORDER_COLOR = NV_KEY_0
.const KEY_DEC_BORDER_COLOR = NV_KEY_9
.const KEY_INC_BACKGROUND_COLOR = NV_KEY_8
.const KEY_DEC_BACKGROUND_COLOR = NV_KEY_7
.const KEY_INC_VOLUME = NV_KEY_PERIOD
.const KEY_DEC_VOLUME = NV_KEY_COMMA


// some loop indices
frame_counter: .word 0
second_counter: .word 0
change_up_counter: .word 0
second_partial_counter: .word 0
key_cool_counter: .byte 0
quit_flag: .byte 0                  // set to non zero to quit
sprite_collision_reg_value: .byte 0 // updated each frame with sprite coll

cycling_color: .byte NV_COLOR_FIRST
change_up_flag: .byte 0

ship1_collision_sprite_label: .text @"ship1 coll sprite: \$00"
nv_b8_label: .text @"nv b8 coll sprite: \$00"

border_color: .byte NV_COLOR_BLUE
background_color: .byte NV_COLOR_BLACK

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
// it will go from $1000-$2FFF
*=$1000 "Main Start"

    // clear the screen just to have an empty canvas
    nv_screen_clear()
    jsr CreateField

    nv_screen_set_border_color_mem(border_color)
    nv_screen_set_background_color_mem(background_color)

    // set the global sprite multi colors        
    nv_sprite_raw_set_multicolors(NV_COLOR_LITE_GREEN, NV_COLOR_WHITE)

    lda #$00
    sta quit_flag

    // setup everything for the sprite_ship so its ready to enable
    jsr ship_1.Setup
    jsr ship_2.Setup

    // setup everything for the sprite_asteroid so its ready to enable
    jsr asteroid_1.Setup
    jsr asteroid_2.Setup
    jsr asteroid_3.Setup
    jsr asteroid_4.Setup
    jsr asteroid_5.Setup


    // initialize sprite locations from their extra data blocks 
    jsr ship_1.SetLocationFromExtraData
    jsr ship_2.SetLocationFromExtraData
    jsr asteroid_1.SetLocationFromExtraData
    jsr asteroid_2.SetLocationFromExtraData
    jsr asteroid_3.SetLocationFromExtraData
    jsr asteroid_4.SetLocationFromExtraData
    jsr asteroid_5.SetLocationFromExtraData
    
    nv_sprite_set_raw_color_immediate(7, NV_COLOR_BROWN)

    // enable sprites
    jsr ship_1.Enable
    jsr ship_2.Enable
    jsr asteroid_1.Enable
    jsr asteroid_2.Enable
    jsr asteroid_3.Enable
    jsr asteroid_4.Enable
    jsr asteroid_5.Enable

    .var showTiming = false
    .var showFrameCounters = false
        
    nv_key_init()
    nv_rand_init(true)

    // initialize song 0
    jsr SoundInit

    lda #$02
    jsr SoundVolumeSet
        
MainLoop:

    nv_adc16_immediate(frame_counter, 1, frame_counter)
    nv_adc16_immediate(second_partial_counter, 1, second_partial_counter)
    nv_ble16_immediate(second_partial_counter, FPS, PartialSecond1)
    jmp FullSecond
PartialSecond1:
    jmp PartialSecond2
FullSecond:
    lda quit_flag
    beq NotQuitting
    jmp ProgramDone
NotQuitting:
    lda #0 
    sta second_partial_counter
    sta second_partial_counter+1
    nv_adc16_immediate(second_counter, 1, second_counter)
    lda #$03
    and second_counter  //set flag every 4 secs when bits 0 and 1 clear
    bne NoSetFlag
    lda #1
    sta change_up_flag
    nv_adc16_immediate(change_up_counter, 1, change_up_counter)
    .if (showFrameCounters)
    {
        nv_screen_poke_hex_word_mem(0, 14, change_up_counter, true)
    }
   
NoSetFlag:
    .if (showFrameCounters)
    {
        nv_screen_poke_hex_word_mem(0, 7, second_counter, true)
    }
PartialSecond2:
    .if (showFrameCounters)
    {
        nv_screen_poke_hex_word_mem(0, 0, frame_counter, true)
    }
    jsr UpdateField

    //// call function to move sprites around based on X and Y velocity
    // but only modify the position in their extra data block not on screen
    .if (showTiming)
    {
        nv_screen_set_border_color_immed(NV_COLOR_LITE_GREEN)
        //lda #NV_COLOR_LITE_GREEN                      // change border color back to
        //sta BORDER_COLOR_REG_ADDR                     // visualize timing
    }
    jsr ship_1.MoveInExtraData
    jsr ship_2.MoveInExtraData
    jsr asteroid_1.MoveInExtraData
    jsr asteroid_2.MoveInExtraData
    jsr asteroid_3.MoveInExtraData
    jsr asteroid_4.MoveInExtraData
    jsr asteroid_5.MoveInExtraData

    jsr DoKeyboard


    lda #1 
    bit change_up_flag
    beq NoChangeUp
YesChangeUp:
    // every few seconds change up some sprite properties
    jsr ChangeUp 
    lda #0 
    sta change_up_flag
NoChangeUp:
    // not changing this frame, 

    .if (showTiming)
    {
        //lda #NV_COLOR_LITE_BLUE                // change border color back to
        //sta BORDER_COLOR_REG_ADDR              // visualize timing
        nv_screen_set_border_color_mem(border_color)
    }
    nv_sprite_wait_last_scanline()         // wait for particular scanline.
    .if (showTiming)
    {
        nv_screen_set_border_color_immed(NV_COLOR_GREEN)

        //lda #NV_COLOR_GREEN                    // change border color to  
        //sta BORDER_COLOR_REG_ADDR              // visualize timing
    }

    SoundDoStep()

    //// call routine to update sprite x and y positions on screen
    jsr ship_1.SetLocationFromExtraData
    jsr ship_2.SetLocationFromExtraData
    jsr asteroid_1.SetLocationFromExtraData
    jsr asteroid_2.SetLocationFromExtraData
    jsr asteroid_3.SetLocationFromExtraData
    jsr asteroid_4.SetLocationFromExtraData
    jsr asteroid_5.SetLocationFromExtraData

    nv_sprite_raw_get_sprite_collisions_in_a()
    sta sprite_collision_reg_value

    //////////////////////////////////////////////////////////////////////
    //// check for ship1 collisions
    jsr ship_1.CheckShipCollision
    lda ship_1.collision_sprite     // closest_sprite, will be $FF 
    bmi NoCollisionShip1        // if no collisions so check minus
HandleCollisionShip1:
    // get extra pointer for the sprite that ship1 collided with loaded
    // so that we can then disable it
    ldy ship_1.collision_sprite
    jsr AstroSpriteExtraPtrToRegs 
    jsr NvSpriteExtraDisable
    jsr SoundPlayShip1AsteroidFX
NoCollisionShip1:

    //////////////////////////////////////////////////////////////////////
    //// check for ship2 collisions
    jsr ship_2.CheckShipCollision
    lda ship_2.collision_sprite     // closest_sprite, will be $FF
    bmi NoCollisionShip2        // if no collisions so check minus
HandleCollisionShip2:
    // get extra pointer for the sprite that ship1 collided with loaded
    // so that we can then disable it
    ldy ship_2.collision_sprite
    jsr AstroSpriteExtraPtrToRegs 
    jsr NvSpriteExtraDisable
    jsr SoundPlayShip2AsteroidFX

NoCollisionShip2:

    jmp MainLoop


ProgramDone:
        // Done moving sprites, move cursor out of the way 
        // and return, but leave the sprites on the screen
        // also set border color to normal
        nv_screen_set_border_color_immed(NV_COLOR_LITE_BLUE)
        nv_screen_set_background_color_immed(NV_COLOR_BLUE)

        jsr SoundDone

        nv_key_done()
        nv_rand_done()

        nv_screen_plot_cursor(5, 24)
        nv_screen_clear()
        rts   // program done, return


//////////////////////////////////////////////////////////////////////////////
// subroutine to Pause
DoPause:
    jsr SoundMuteOn
    nv_key_wait_any_key()
    jsr SoundMuteOff
    rts

//////////////////////////////////////////////////////////////////////////////
// subroutine to do all the keyboard stuff
DoKeyboard: 
    nv_key_scan()

    lda key_cool_counter
    beq NotInCoolDown       // not in keyboard cooldown, go scan
    dec key_cool_counter    // in keyboard cooldown, dec the cntr
    jmp DoneKeys            // and jmp to skip rest of routine
NotInCoolDown:

    nv_key_get_last_pressed_a()     // get key pressed in accum
    //nv_debug_print_char_a(5, 0)
    //nv_debug_print_byte_a(5, 5, 
    //                      true, false)
    cmp #NV_KEY_NO_KEY          // check if any key hit
    bne HaveKey 
    jmp DoneKeys                // no key hit, skip to end
HaveKey:
    ldy #KEY_COOL_DURATION      // had a key, start cooldown counter        
    sty key_cool_counter

TryShip1SlowX:
    cmp #KEY_SHIP1_SLOW_X       // check ship1 slow down X key
    bne TryShip1FastX           // wasn't A key, try D key
WasShip1SlowX:
    jsr ship_1.DecVelX          // slow down the ship X
    jmp DoneKeys                // and skip to bottom

TryShip1FastX:
    cmp #KEY_SHIP1_FAST_X      // check ship1 speed up x key
    bne TryTransitionKeys               // not speed up x key, skip to bottom
WasShip1FastX:
    jsr ship_1.IncVelX          // inc the ship X velocity
    jmp DoneKeys                // and skip to bottom

//////
// no repeat key presses handled here, only transition keys below this line
// if its a repeat key press then we'll ignore it.
TryTransitionKeys:
    nv_key_get_prev_pressed_y() // previou key pressed to Y reg
    sty scratch_byte            // then to scratch reg to compare with accum
    cmp scratch_byte            // if prev key == last key then done with keys
    beq DoneKeys

TryPause:
    cmp #KEY_PAUSE             // check the pause key
    bne TryIncBorder                // not speed up x key, skip to bottom
WasPause:
    jsr DoPause                // jsr to the pause subroutine
    jmp DoneKeys                // and skip to bottom

TryIncBorder:
    cmp #KEY_INC_BORDER_COLOR             
    bne TryDecBorder                           
WasIncBorderColor:
    inc border_color
    nv_screen_set_border_color_mem(border_color)
    jmp DoneKeys                     // and skip to bottom
              
TryDecBorder:
    cmp #KEY_DEC_BORDER_COLOR             
    bne TryIncBackground                           
WasDecBorderColor:
    dec border_color
    nv_screen_set_border_color_mem(border_color)
    jmp DoneKeys                // and skip to bottom

TryIncBackground:
    cmp #KEY_INC_BACKGROUND_COLOR             
    bne TryDecBackground                           
WasIncBackgroundColor:
    inc background_color
    nv_screen_set_background_color_mem(background_color)
    jmp DoneKeys                     // and skip to bottom
              
TryDecBackground:
    cmp #KEY_DEC_BACKGROUND_COLOR             
    bne TryIncVolume                           
WasDecBackgroundColor:
    dec background_color
    nv_screen_set_background_color_mem(background_color)          
    jmp DoneKeys                // and skip to bottom

TryIncVolume:
    cmp #KEY_INC_VOLUME             
    bne TryDecVolume                           
WasIncVolume:
    jsr SoundVolumeUp
    jmp DoneKeys                // and skip to bottom

TryDecVolume:
    cmp #KEY_DEC_VOLUME             
    bne TryQuit                           
WasDecVolume:
    jsr SoundVolumeDown
    jmp DoneKeys

TryQuit:
    cmp #KEY_QUIT               // check quit key
    bne DoneKeys                // not quit key, skip to bottom
WasQuit:
    lda #1                      // set the quit flag
    sta quit_flag

DoneKeys:
    rts

//////////////////////////////////////////////////////////////////////////////
// subroutine to wait for no key currently pressed
WaitNoKey:
    nv_key_wait_no_key()
    rts

//////////////////////////////////////////////////////////////////////////////
// subroutine to cycle the color of a sprite just to show how
// the nv_sprite_set_color_from_memory macro works.
ChangeUp:
        ldx cycling_color
        inx
        cpx background_color // this is background color, so skip that one
        bne NotBG
        inx
NotBG:
        cpx #NV_COLOR_LAST + 1
        bne SetColor
        ldx #NV_COLOR_FIRST
        stx cycling_color
SetColor:
        stx cycling_color
        nv_sprite_raw_set_color_from_memory(1, cycling_color)

        // change some speeds
SkipShipMax:                   
        inc asteroid_1.y_vel    // increment asteroid Y velocity 
        lda asteroid_1.y_vel    // load new speed just incremented
        cmp #MAX_SPEED+1        // compare new spead with max +1
        bne SkipAsteroidMin     // if we haven't reached max + 1 then skip setting to min
        lda #MIN_SPEED          // else, we have reached max+1 so need to reset it back min
        sta asteroid_1.y_vel

SkipAsteroidMin:

CheckDisabled:
    jsr asteroid_1.LoadEnabledToA
    bne CheckAster2
    lda #130
    sta asteroid_1.y_loc
    jsr asteroid_1.Enable

CheckAster2:
    jsr asteroid_2.LoadEnabledToA
    bne CheckAster3
    lda #130
    sta asteroid_2.y_loc
    jsr asteroid_2.Enable

CheckAster3:
    jsr asteroid_3.LoadEnabledToA
    bne CheckAster4
    lda #130
    sta asteroid_3.y_loc
    jsr asteroid_3.Enable

CheckAster4:
    jsr asteroid_4.LoadEnabledToA
    bne CheckAster5
    lda #130
    sta asteroid_4.y_loc
    jsr asteroid_4.Enable

CheckAster5:
    jsr asteroid_5.LoadEnabledToA
    bne DoneCheckingDisabledAsteroids
    lda #130
    sta asteroid_5.y_loc
    jsr asteroid_5.Enable

DoneCheckingDisabledAsteroids:
    rts

//////////////////////////////////////////////////////////////////////////////
// CreateField subroutine
CreateField:
    lda #46
    ldx #NV_COLOR_DARK_GREY
    nv_screen_poke_color_char_xa(3, 12)
    nv_screen_poke_color_char_xa(10, 35)
    nv_screen_poke_color_char_xa(4, 20)
    nv_screen_poke_color_char_xa(15, 25)
    nv_screen_poke_color_char_xa(20, 37)
    nv_screen_poke_color_char_xa(23, 27)
    nv_screen_poke_color_char_xa(7, 15)
    nv_screen_poke_color_char_xa(22, 38)
    nv_screen_poke_color_char_xa(6, 4)
    nv_screen_poke_color_char_xa(24, 5)
    nv_screen_poke_color_char_xa(12, 28)
    nv_screen_poke_color_char_xa(6, 17)

    lda #81
    nv_screen_poke_color_char_xa(14, 22)
    nv_screen_poke_color_char_xa(07, 9)
    nv_screen_poke_color_char_xa(21, 14)

/*
    ldx #NV_COLOR_GREY
    lda #$7C    // commet head
    nv_screen_poke_color_char_xa(17, 6)

    ldx #NV_COLOR_LITE_GREY
    lda #$4E   // commet trail
    nv_screen_poke_color_char_xa(16, 7)
*/

    rts


//////////////////////////////////////////////////////////////////////////////
//
UpdateField:
    nv_rand_color_a(true)
    nv_screen_poke_color_a(3, 12)
    //nv_screen_poke_color_a(10, 35)
    nv_screen_poke_color_a(4, 20)
    nv_rand_color_a(true)
    nv_screen_poke_color_a(15, 25)
    //nv_screen_poke_color_a(20, 37)
    //nv_screen_poke_color_a(23, 27)
    nv_screen_poke_color_a(7, 15)
    nv_rand_color_a(true)
    nv_screen_poke_color_a(22, 38)
    nv_screen_poke_color_a(6, 4)
    nv_rand_color_a(true)
    nv_screen_poke_color_a(24, 5)
    //nv_screen_poke_color_a(12, 28)
    nv_screen_poke_color_a(6, 17)

    //nv_screen_poke_color_a(14, 22)
    //nv_rand_color_a(true)
    //nv_screen_poke_color_a(07, 9)
    //nv_screen_poke_color_a(21, 14)
   
    rts

//////////////////////////////////////////////////////////////////////////////
// Subroutine to set all character colors for the whole screen to the color
// in the accumulator
// subroutine params:
//   Accum: the color (0-15) to put in screen color memory for all locations 
SetAllCharColorA:
    nv_screen_poke_all_color_a()
    rts

SetAllCharA:
    nv_screen_poke_all_char_a()
    rts

//////////////////////////////////////////////////////////////////////////////
// Namespace with everything related to asteroid 1
.namespace asteroid_1
{
        .var info = nv_sprite_info_struct("asteroid_1", 1, 
                                          30, 180, -1, 0,     // init x, y, VelX, VelY
                                          sprite_asteroid_1, 
                                          sprite_extra, 
                                          1, 1, 1, 1, // bounce on top, left, bottom, right  
                                          0, 0, 0, 0, // min/max top, left, bottom, right
                                          0)          // sprite enabled
        .label x_loc = info.base_addr + NV_SPRITE_X_OFFSET
        .label y_loc = info.base_addr + NV_SPRITE_Y_OFFSET
        .label x_vel = info.base_addr + NV_SPRITE_VEL_X_OFFSET
        .label y_vel = info.base_addr + NV_SPRITE_VEL_Y_OFFSET
        

// sprite extra data
sprite_extra: 
        nv_sprite_extra_data(info)

LoadExtraPtrToRegs:
    lda #>info.base_addr
    ldx #<info.base_addr
    rts

// subroutine to set sprites location in sprite registers based on the extra data
SetLocationFromExtraData:
        lda #>info.base_addr
        ldx #<info.base_addr
        jsr NvSpriteSetLocationFromExtra
        rts
        //nv_sprite_set_location_from_memory_sr(info.num, info.base_addr+NV_SPRITE_X_OFFSET, info.base_addr+NV_SPRITE_Y_OFFSET)

// setup sprite so that it ready to be enabled and displayed
Setup:
        lda #>info.base_addr
        ldx #<info.base_addr
        jsr NvSpriteSetupFromExtra
        rts

// move the sprite x and y location in the extra data only, not in the sprite registers
// to move in the sprite registsers (and have screen reflect it) call the 
// SetLocationFromExtraData subroutine.
MoveInExtraData:
        //lda #>info.base_addr
        //ldx #<info.base_addr
        //jsr NvSpriteMoveInExtra
        //rts
        nv_sprite_move_any_direction_sr(info)

Enable:
        lda #>info.base_addr
        ldx #<info.base_addr
        nv_sprite_extra_enable_sr()

LoadEnabledToA:
        lda info.base_addr + NV_SPRITE_ENABLED_OFFSET
        rts

SetBounceAllOn:
        nv_sprite_set_all_actions_sr(info, NV_SPRITE_ACTION_BOUNCE)

SetWrapAllOn:
        nv_sprite_set_all_actions_sr(info, NV_SPRITE_ACTION_WRAP)
}

//////////////////////////////////////////////////////////////////////////////
// Namespace with everything related to asteroid 2
.namespace asteroid_2
{
        .var info = nv_sprite_info_struct("asteroid_2", 2, 
                                          80, 150, 1, 2, // init x, y, VelX, VelY
                                          sprite_asteroid_2, 
                                          sprite_extra, 
                                          1, 1, 1, 1, // bounce on top, left, bottom, right  
                                          0, 0, 0, 0, // min/max top, left, bottom, right
                                          0)          // sprite enabled
        .label x_loc = info.base_addr + NV_SPRITE_X_OFFSET
        .label y_loc = info.base_addr + NV_SPRITE_Y_OFFSET
        .label x_vel = info.base_addr + NV_SPRITE_VEL_X_OFFSET
        .label y_vel = info.base_addr + NV_SPRITE_VEL_Y_OFFSET

// sprite extra data
sprite_extra:
        nv_sprite_extra_data(info)

LoadExtraPtrToRegs:
    lda #>info.base_addr
    ldx #<info.base_addr
    rts

// subroutine to set sprites location in sprite registers based on the extra data
SetLocationFromExtraData:
        lda #>info.base_addr
        ldx #<info.base_addr
        jsr NvSpriteSetLocationFromExtra
        rts
        //nv_sprite_set_location_from_memory_sr(info.num, info.base_addr+NV_SPRITE_X_OFFSET, info.base_addr+NV_SPRITE_Y_OFFSET)

// setup sprite so that it ready to be enabled and displayed
Setup:
        lda #>info.base_addr
        ldx #<info.base_addr
        jsr NvSpriteSetupFromExtra
        rts

// move the sprite x and y location in the extra data only, not in the sprite registers
// to move in the sprite registsers (and have screen reflect it) call the 
// SetLocationFromExtraData subroutine.
MoveInExtraData:
        //lda #>info.base_addr
        //ldx #<info.base_addr
        //jsr NvSpriteMoveInExtra
        //rts
        nv_sprite_move_any_direction_sr(info)

Enable:
        lda #>info.base_addr
        ldx #<info.base_addr
        nv_sprite_extra_enable_sr()

LoadEnabledToA:
        lda info.base_addr + NV_SPRITE_ENABLED_OFFSET
        rts
        
SetBounceAllOn:
        nv_sprite_set_all_actions_sr(info, NV_SPRITE_ACTION_BOUNCE)

SetWrapAllOn:
        nv_sprite_set_all_actions_sr(info, NV_SPRITE_ACTION_WRAP)
       
}


//////////////////////////////////////////////////////////////////////////////
// Namespace with everything related to asteroid 3
.namespace asteroid_3
{
        .var info = nv_sprite_info_struct("asteroid_3", 3, 
                                          75, 200, 2, -3,  // init x, y, VelX, VelY
                                          sprite_asteroid_3, 
                                          sprite_extra, 
                                          1, 1, 1, 1, // bounce on top, left, bottom, right  
                                          0, 0, 0, 0, // min/max top, left, bottom, right
                                          0)          // sprite enabled

        .label x_loc = info.base_addr + NV_SPRITE_X_OFFSET
        .label y_loc = info.base_addr + NV_SPRITE_Y_OFFSET
        .label x_vel = info.base_addr + NV_SPRITE_VEL_X_OFFSET
        .label y_vel = info.base_addr + NV_SPRITE_VEL_Y_OFFSET

// sprite extra data
sprite_extra:
        nv_sprite_extra_data(info)

LoadExtraPtrToRegs:
    lda #>info.base_addr
    ldx #<info.base_addr
    rts


// subroutine to set sprites location in sprite registers based on the extra data
SetLocationFromExtraData:
        lda #>info.base_addr
        ldx #<info.base_addr
        jsr NvSpriteSetLocationFromExtra
        rts
        //nv_sprite_set_location_from_memory_sr(info.num, info.base_addr+NV_SPRITE_X_OFFSET, info.base_addr+NV_SPRITE_Y_OFFSET)

// setup sprite so that it ready to be enabled and displayed
Setup:
        lda #>info.base_addr
        ldx #<info.base_addr
        jsr NvSpriteSetupFromExtra
        rts

// move the sprite x and y location in the extra data only, not in the sprite registers
// to move in the sprite registsers (and have screen reflect it) call the 
// SetLocationFromExtraData subroutine.
MoveInExtraData:
        //lda #>info.base_addr
        //ldx #<info.base_addr
        //jsr NvSpriteMoveInExtra
        //rts
        nv_sprite_move_any_direction_sr(info)

Enable:
        lda #>info.base_addr
        ldx #<info.base_addr
        nv_sprite_extra_enable_sr()

LoadEnabledToA:
        lda info.base_addr + NV_SPRITE_ENABLED_OFFSET
        rts

SetBounceAllOn:
        nv_sprite_set_all_actions_sr(info, NV_SPRITE_ACTION_BOUNCE)

SetWrapAllOn:
        nv_sprite_set_all_actions_sr(info, NV_SPRITE_ACTION_WRAP)
}


//////////////////////////////////////////////////////////////////////////////
// Namespace with everything related to asteroid 4
.namespace asteroid_4
{
        .var info = nv_sprite_info_struct("asteroid_4", 4, 
                                          255, 155, 1, 1, // init x, y, VelX, VelY 
                                          sprite_asteroid_4, 
                                          sprite_extra, 
                                          0, 0, 0, 0, // bounce on top, left, bottom, right  
                                          0, 0, 0, 0, // min/max top, left, bottom, right
                                          0)          // sprite enabled

        .label x_loc = info.base_addr + NV_SPRITE_X_OFFSET
        .label y_loc = info.base_addr + NV_SPRITE_Y_OFFSET
        .label x_vel = info.base_addr + NV_SPRITE_VEL_X_OFFSET
        .label y_vel = info.base_addr + NV_SPRITE_VEL_Y_OFFSET

// sprite extra data
sprite_extra:
        nv_sprite_extra_data(info)

LoadExtraPtrToRegs:
    lda #>info.base_addr
    ldx #<info.base_addr
    rts


// subroutine to set sprites location in sprite registers based on the extra data
SetLocationFromExtraData:
        lda #>info.base_addr
        ldx #<info.base_addr
        jsr NvSpriteSetLocationFromExtra
        rts
        //nv_sprite_set_location_from_memory_sr(info.num, info.base_addr+NV_SPRITE_X_OFFSET, info.base_addr+NV_SPRITE_Y_OFFSET)

// setup sprite so that it ready to be enabled and displayed
Setup:
        lda #>info.base_addr
        ldx #<info.base_addr
        jsr NvSpriteSetupFromExtra
        rts

// move the sprite x and y location in the extra data only, not in the sprite registers
// to move in the sprite registsers (and have screen reflect it) call the 
// SetLocationFromExtraData subroutine.
MoveInExtraData:
        //lda #>info.base_addr
        //ldx #<info.base_addr
        //jsr NvSpriteMoveInExtra
        //rts
        nv_sprite_move_any_direction_sr(info)

Enable:
        lda #>info.base_addr
        ldx #<info.base_addr
        nv_sprite_extra_enable_sr()

LoadEnabledToA:
        lda info.base_addr + NV_SPRITE_ENABLED_OFFSET
        rts

SetBounceAllOn:
        nv_sprite_set_all_actions_sr(info, NV_SPRITE_ACTION_BOUNCE)

SetWrapAllOn:
        nv_sprite_set_all_actions_sr(info, NV_SPRITE_ACTION_WRAP)
}


//////////////////////////////////////////////////////////////////////////////
// Namespace with everything related to asteroid 5
.namespace asteroid_5
{
        .var info = nv_sprite_info_struct("asteroid_5", 5,
                                          85, 76, -2, -1, // init x, y, VelX, VelY 
                                          sprite_asteroid_5, 
                                          sprite_extra, 
                                          0, 0, 0, 0, // bounce on top, left, bottom, right  
                                          0, 0, 0, 0, // min/max top, left, bottom, right
                                          0)          // sprite enabled

        .label x_loc = info.base_addr + NV_SPRITE_X_OFFSET
        .label y_loc = info.base_addr + NV_SPRITE_Y_OFFSET
        .label x_vel = info.base_addr + NV_SPRITE_VEL_X_OFFSET
        .label y_vel = info.base_addr + NV_SPRITE_VEL_Y_OFFSET

// sprite extra data
sprite_extra:
        nv_sprite_extra_data(info)

LoadExtraPtrToRegs:
    lda #>info.base_addr
    ldx #<info.base_addr
    rts


// subroutine to set sprites location in sprite registers based on the extra data
SetLocationFromExtraData:
        lda #>info.base_addr
        ldx #<info.base_addr
        jsr NvSpriteSetLocationFromExtra
        rts
        //nv_sprite_set_location_from_memory_sr(info.num, info.base_addr+NV_SPRITE_X_OFFSET, info.base_addr+NV_SPRITE_Y_OFFSET)

// setup sprite so that it ready to be enabled and displayed
Setup:
        lda #>info.base_addr
        ldx #<info.base_addr
        jsr NvSpriteSetupFromExtra
        rts

// move the sprite x and y location in the extra data only, not in the sprite registers
// to move in the sprite registsers (and have screen reflect it) call the 
// SetLocationFromExtraData subroutine.
MoveInExtraData:
        //lda #>info.base_addr
        //ldx #<info.base_addr
        //jsr NvSpriteMoveInExtra
        //rts
        nv_sprite_move_any_direction_sr(info)

Enable:
        lda #>info.base_addr
        ldx #<info.base_addr
        nv_sprite_extra_enable_sr()

LoadEnabledToA:
        lda info.base_addr + NV_SPRITE_ENABLED_OFFSET
        rts


SetBounceAllOn:
        nv_sprite_set_all_actions_sr(info, NV_SPRITE_ACTION_BOUNCE)

SetWrapAllOn:
        nv_sprite_set_all_actions_sr(info, NV_SPRITE_ACTION_WRAP)
}


//////////////////////////////////////////////////////////////////////////////
// namespace with everything related to ship sprite
.namespace ship_1
{
        .var info = nv_sprite_info_struct("ship_1", 0,
                                          22, 50, 3, 1,  // init x, y, VelX, VelY 
                                          sprite_ship, 
                                          sprite_extra, 
                                          1, 0, 1, 0, // bounce on top, left, bottom, right  
                                          0, 0, 75, 0, // min/max top, left, bottom, right
                                          0)          // sprite enabled

        .var sprite_num = info.num
        .label x_loc = info.base_addr + NV_SPRITE_X_OFFSET
        .label y_loc = info.base_addr + NV_SPRITE_Y_OFFSET
        .label x_vel = info.base_addr + NV_SPRITE_VEL_X_OFFSET
        .label y_vel = info.base_addr + NV_SPRITE_VEL_Y_OFFSET
        .label base_addr = info.base_addr

// the extra data that goes with the sprite
sprite_extra:
        nv_sprite_extra_data(info)

// will be $FF (no collision) or sprite number of sprite colliding with
collision_sprite: .byte 0 

LoadExtraPtrToRegs:
    lda #>info.base_addr
    ldx #<info.base_addr
    rts

// subroutine to set the sprites location based on its address in extra block 
SetLocationFromExtraData:
        lda #>info.base_addr
        ldx #<info.base_addr
        jsr NvSpriteSetLocationFromExtra
        rts

// subroutine to setup the sprite so that its ready to be enabled and displayed
Setup:
        lda #>info.base_addr
        ldx #<info.base_addr
        jsr NvSpriteSetupFromExtra
        rts

// subroutine to move the sprite in memory only (the extra data)
// this will not update the sprite registers to actually move the sprite, but
// to do that just call SetShipeLocFromMem
MoveInExtraData:
        //lda #>info.base_addr
        //ldx #<info.base_addr
        //jsr NvSpriteMoveInExtra
        //rts
        nv_sprite_move_any_direction_sr(info)

Enable:
        lda #>info.base_addr
        ldx #<info.base_addr
        nv_sprite_extra_enable_sr()

LoadEnabledToA:
        lda info.base_addr + NV_SPRITE_ENABLED_OFFSET
        rts

SetBounceAllOn:
        nv_sprite_set_all_actions_sr(info, NV_SPRITE_ACTION_BOUNCE)

SetWrapAllOn:
        nv_sprite_set_all_actions_sr(info, NV_SPRITE_ACTION_WRAP)

//////////////////////////////////////////////////////////////////////////////
// subroutine to check for collisions with the ship (sprite 0)
CheckShipCollision:
    lda sprite_collision_reg_value
    //nv_debug_print_labeled_byte_mem(0, 0, temp_label, 10, sprite_collision_reg_value, true, false)
    sta nv_a8
    nv_sprite_raw_check_collision(info.num)
    lda nv_b8
    sta ship_1.collision_sprite
    //jsr DebugShipCollisionSprite
    rts
temp_label: .text @"coll reg: \$00"

DecVelX:
    //nv_debug_print_labeled_byte_mem(10, 0, label_vel_x_str, 7, ship_1.x_vel, true, false)
    dec ship_1.x_vel        // decrement ship speed
    bpl DoneDecVelX         // if its not zero yet then skip setting to max
    inc ship_1.x_vel
DoneDecVelX:
    rts

IncVelX:
    //nv_debug_print_labeled_byte_mem(10, 0, label_vel_x_str, 7, ship_1.x_vel, true, false)
    lda ship_1.x_vel        // decrement ship speed
    cmp #MAX_SPEED         // if its not zero yet then skip setting to max
    beq DoneIncVelX
    inc ship_1.x_vel
DoneIncVelX:
    rts

label_vel_x_str: .text @"vel x: \$00"

}

//////////////////////////////////////////////////////////////////////////////
// namespace with everything related to ship sprite
.namespace ship_2
{
    .var info = nv_sprite_info_struct("ship_2", 7,  // sprite name, number
                                        22, 210, 3, 1,  // init x, y, VelX, VelY 
                                        sprite_ship, 
                                        sprite_extra, 
                                        1, 0, 1, 0,   // bounce on top, left, bottom, right  
                                        200, 0, 0, 0, // min/max top, left, bottom, right
                                        0)            // sprite enabled

    .var sprite_num = info.num
    .label x_loc = info.base_addr + NV_SPRITE_X_OFFSET
    .label y_loc = info.base_addr + NV_SPRITE_Y_OFFSET
    .label x_vel = info.base_addr + NV_SPRITE_VEL_X_OFFSET
    .label y_vel = info.base_addr + NV_SPRITE_VEL_Y_OFFSET
    .label base_addr = info.base_addr


// the extra data that goes with the sprite
sprite_extra:
        nv_sprite_extra_data(info)



// will be $FF (no collision) or sprite number of sprite colliding with
collision_sprite: .byte 0

LoadExtraPtrToRegs:
    lda #>info.base_addr
    ldx #<info.base_addr
    rts


// subroutine to set the sprites location based on its address in extra block 
SetLocationFromExtraData:
        lda #>info.base_addr
        ldx #<info.base_addr
        jsr NvSpriteSetLocationFromExtra
        rts

// subroutine to setup the sprite so that its ready to be enabled and displayed
Setup:
        lda #>info.base_addr
        ldx #<info.base_addr
        jsr NvSpriteSetupFromExtra
        rts

// subroutine to move the sprite in memory only (the extra data)
// this will not update the sprite registers to actually move the sprite, but
// to do that just call SetShipeLocFromMem
MoveInExtraData:
        //lda #>info.base_addr
        //ldx #<info.base_addr
        //jsr NvSpriteMoveInExtra
        //rts
        nv_sprite_move_any_direction_sr(info)

Enable:
        lda #>info.base_addr
        ldx #<info.base_addr
        nv_sprite_extra_enable_sr()

LoadEnabledToA:
        lda info.base_addr + NV_SPRITE_ENABLED_OFFSET
        rts

SetBounceAllOn:
        nv_sprite_set_all_actions_sr(info, NV_SPRITE_ACTION_BOUNCE)

SetWrapAllOn:
        nv_sprite_set_all_actions_sr(info, NV_SPRITE_ACTION_WRAP)

//////////////////////////////////////////////////////////////////////////////
// subroutine to check for collisions with the ship (sprite 0)
CheckShipCollision:
    lda sprite_collision_reg_value
    //nv_debug_print_labeled_byte_mem(0, 0, temp_label, 10, sprite_collision_reg_value, true, false)
    sta nv_a8
    nv_sprite_raw_check_collision(info.num)
    lda nv_b8
    sta ship_2.collision_sprite
    rts


DecVelX:
    //nv_debug_print_labeled_byte_mem(10, 0, label_vel_x_str, 7, ship_1.x_vel, true, false)
    dec ship_1.x_vel        // decrement ship speed
    bpl DoneDecVelX         // if its not zero yet then skip setting to max
    inc ship_1.x_vel
DoneDecVelX:
    rts

IncVelX:
    //nv_debug_print_labeled_byte_mem(10, 0, label_vel_x_str, 7, ship_1.x_vel, true, false)
    lda ship_1.x_vel        // decrement ship speed
    cmp #MAX_SPEED         // if its not zero yet then skip setting to max
    beq DoneIncVelX
    inc ship_1.x_vel
DoneIncVelX:
    rts

label_vel_x_str: .text @"vel x: \$00"

}

//////////////////////////////////////////////////////////////////////////////
// subroutine to load registers with a pointer to the sprite extra data 
// for the sprite number that is in the Y register
// Input Params:
//   Y Reg: the sprite number who's extra pointer should be loaded
//          this must be a number from 0 to 7
// Output:
//   Accum: MSB of the extra pointer for the sprite
//   X Reg: LSB of the extra pointer for the sprite
AstroSpriteExtraPtrToRegs:
    
TrySprite0:
    cpy #$00
    bne TrySprite1
IsSprite0:
    jsr ship_1.LoadExtraPtrToRegs
    jmp SpriteExtraPtrLoaded

TrySprite1:
    cpy #$01
    bne TrySprite2
IsSprite1:
    jsr asteroid_1.LoadExtraPtrToRegs
    jmp SpriteExtraPtrLoaded

TrySprite2:
    cpy #$02
    bne TrySprite3
IsSprite2:
    jsr asteroid_2.LoadExtraPtrToRegs
    jmp SpriteExtraPtrLoaded

TrySprite3:
    cpy #$03
    bne TrySprite4
IsSprite3:
    jsr asteroid_3.LoadExtraPtrToRegs
    jmp SpriteExtraPtrLoaded

TrySprite4:
    cpy #$04
    bne TrySprite5
IsSprite4:
    jsr asteroid_4.LoadExtraPtrToRegs
    jmp SpriteExtraPtrLoaded

TrySprite5:
    cpy #$05
    bne TrySprite6
IsSprite5:
    jsr asteroid_5.LoadExtraPtrToRegs
    jmp SpriteExtraPtrLoaded

TrySprite6:
    cpy #$06
    bne TrySprite7
IsSprite6:
    jmp InvalidSpriteNumber

TrySprite7:
    cpy #$07
    bne InvalidSpriteNumber
IsSprite7:
    jsr ship_2.LoadExtraPtrToRegs
    jmp SpriteExtraPtrLoaded

InvalidSpriteNumber:
    // if we get here then an unexptected sprite number was set
    // prior to calling this subroutine.
.break
    nop
SpriteExtraPtrLoaded:
    rts


// our sprite routines will goto this address
*=$3000 "Sprite Code"

// put the actual sprite subroutines here
#import "../nv_c64_util/nv_sprite_extra_code.asm"
#import "../nv_c64_util/nv_sprite_raw_collisions_code.asm"
#import "../nv_c64_util/nv_sprite_raw_code.asm"
//#import "../nv_c64_util/nv_screen_code.asm"
//#import "../nv_c64_util/nv_sprite_raw_code.asm"
/*
ship_collision_label_str: .text  @"ship collision sprite:\$00"
DebugShipCollisionSprite:
    nv_debug_print_labeled_byte_mem(0, 0, ship_collision_label_str, 22, nv_b8, true, false)
    rts
*/

#import "astro_sound.asm"