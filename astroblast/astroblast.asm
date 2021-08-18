//////////////////////////////////////////////////////////////////////////////
// astroblast.asm
// AstroBlaster Main program
//////////////////////////////////////////////////////////////////////////////

#import "../nv_c64_util/nv_c64_util_macs_and_data.asm"

*=$0800 "BASIC Start"  // location to put a 1 line basic program so we can just
        // type run to execute the assembled program.
        // will just call assembled program at correct location
        //    10 SYS (4096)

        // These bytes are a one line basic program that will 
        // do a sys call to assembly language portion of
        // of the program which will be at $1000 or 4096 decimal
        // basic line is: 
        // 10 SYS (4096)
        .byte $00                // first byte of basic area should be 0
        .byte $0E, $08           // Forward address to next basic line
        .byte $0A, $00           // this will be line 10 ($0A)
        .byte $9E                // basic token for SYS
        .byte $20, $28, $34, $30, $39, $36, $29 // ASCII for " (4096)"
        .byte $00, $00, $00      // end of basic program (addr $080E from above)

*=$0820 "Main Program Vars"
#import "astro_keyboard_macs.asm"
#import "astro_vars_data.asm"
#import "astro_wind_data.asm"
#import "astro_ship_death_data.asm"


// min and max speed for all sprites during the changeup
.const MAX_SPEED = 6
.const MIN_SPEED = -6

.const KEY_COOL_DURATION = $08

ship1_collision_sprite_label: .text @"ship1 coll sprite: \$00"
nv_b8_label: .text @"nv b8 coll sprite: \$00"


// the data for the sprites. 
// the file specifies where it assembles to ($0900)
#import "astro_sprite_data.asm"

// our assembly code will goto this address
// it will go from $1000-$2FFF
*=$1000 "Main Start"

    jmp RealStart
#import "astro_wind_code.asm"
#import "../nv_c64_util/nv_screen_code.asm"
#import "../nv_c64_util/nv_sprite_raw_collisions_code.asm"
#import "../nv_c64_util/nv_sprite_raw_code.asm"
#import "../nv_c64_util/nv_sprite_extra_code.asm"
#import "astro_ships_code.asm"
#import "astro_ship_death_code.asm"
#import "astro_starfield_code.asm"
#import "astro_turret_armer_code.asm"
#import "../nv_c64_util/nv_joystick_code.asm"

//////////////////////////////////////////////////////////////////////////////
// charset is expected to be at $3000
*=$3000 "charset start"
.import binary "astro_charset.bin"
// end charset
//////////////////////////////////////////////////////////////////////////////

#import "astro_turret_code.asm"

RealStart:
    nv_screen_custom_charset_init(6, false)
    nv_screen_set_border_color_mem(border_color)
    nv_screen_set_background_color_mem(background_color)
    nv_rand_init(true)          // do before SoundInit
    nv_key_init()

    // initialize song 0
    jsr SoundInit

    lda #$02
    jsr SoundVolumeSet

    lda #$00
    sta quit_flag

    lda #ASTRO_DIFF_EASY
    sta astro_diff_mode

    jsr TitleStart              // show title screen
    bne RunGame                 // make sure non zero in accum and run game
    jmp ProgramDone             // if zero in accum then user quit

RunGame:

    // standard initialization
    nv_store16_immediate(second_counter, $0000)
    nv_store16_immediate(second_partial_counter, $0000)
    nv_store16_immediate(frame_counter, $0000)
    nv_store16_immediate(ship_1.score, $0000)
    nv_store16_immediate(ship_2.score, $0000)


    // initialize based on difficulty (must be after standard init)
    jsr AstroSetDiffParams

    // clear the screen just to have an empty canvas
    nv_screen_clear()

    // set the global sprite multi colors        
    nv_sprite_raw_set_multicolors(NV_COLOR_LITE_GREEN, NV_COLOR_WHITE)

    jsr StarInit
    jsr WindInit
    jsr TurretInit
    jsr TurretArmInit
    jsr TurretArmStart
    jsr ShipDeathInit
    jsr JoyInit

    // setup everything for the sprite_ship so its ready to enable
    jsr ship_1.Setup
    //nv_store16_immediate(ship_1.score, $0000)

    jsr ship_2.Setup
    //nv_store16_immediate(ship_2.score, $0000)

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
        

    jsr StarStart

MainLoop:

    nv_adc16_immediate(frame_counter, 1, frame_counter)
    nv_adc16_immediate(second_partial_counter, 1, second_partial_counter)
    nv_ble16_immediate(second_partial_counter, ASTRO_FPS, PartialSecond1)
    jmp FullSecond
PartialSecond1:
    jmp PartialSecond2
FullSecond:
    jsr WindCheck
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

    //// call function to move sprites around based on X and Y velocity
    // but only modify the position in their extra data block not on screen
    .if (showTiming)
    {
        nv_screen_set_border_color_immed(NV_COLOR_LITE_GREEN)
    }

    // read keyboard and take action before other effects incase
    // other effects will override keyboard action
    jsr DoKeyboard
    jsr DoJoystick

    // step through the effects
    jsr StarStep
    jsr WindStep
    jsr TurretStep
    jsr TurretArmStep
    jsr ShipDeathStep

    // fire the turret automatically if its time.
    jsr TurretAutoStart

    // move the sprites based on velocities set above.
    jsr ship_1.MoveInExtraData
    jsr ship_2.MoveInExtraData
    jsr asteroid_1.MoveInExtraData
    jsr asteroid_2.MoveInExtraData
    jsr asteroid_3.MoveInExtraData
    jsr asteroid_4.MoveInExtraData
    jsr asteroid_5.MoveInExtraData

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
    lda ship_1_death_count        // if ship1 is dead then ignore collisions
    bne NoCollisionShip1
    // get extra pointer for the sprite that ship1 collided with loaded
    // so that we can then disable it
    ldy ship_1.collision_sprite
    jsr AstroSpriteExtraPtrToRegs 
    jsr NvSpriteExtraDisable
    jsr SoundPlayShip1AsteroidFX
    nv_bcd_adc16_immediate(ship_1.score, $0001, ship_1.score)

NoCollisionShip1:

    //////////////////////////////////////////////////////////////////////
    //// check for ship2 collisions
    jsr ship_2.CheckShipCollision
    lda ship_2.collision_sprite     // closest_sprite, will be $FF
    bmi NoCollisionShip2        // if no collisions so check minus
HandleCollisionShip2:
    lda ship_2_death_count        // if ship2 is dead then ignore collisions
    bne NoCollisionShip2
    // get extra pointer for the sprite that ship1 collided with loaded
    // so that we can then disable it
    ldy ship_2.collision_sprite
    jsr AstroSpriteExtraPtrToRegs 
    jsr NvSpriteExtraDisable
    jsr SoundPlayShip2AsteroidFX
    nv_bcd_adc16_immediate(ship_2.score, $0001, ship_2.score)

NoCollisionShip2:

    jsr TurretHitCheck

    jsr ScoreToScreen
    jmp MainLoop


ProgramDone:
    // Done moving sprites, move cursor out of the way 
    // and return, but leave the sprites on the screen
    // also set border color to normal
    nv_screen_set_border_color_immed(NV_COLOR_LITE_BLUE)
    nv_screen_set_background_color_immed(NV_COLOR_BLUE)

    jsr StarCleanup
    jsr TurretArmCleanup
    jsr TurretCleanup
    jsr WindCleanup
    jsr ShipDeathCleanup
    jsr JoyCleanup

    jsr SoundMuteOn
    jsr SoundDone

    nv_key_done()
    nv_rand_done()

    nv_screen_custom_charset_done()

    nv_screen_plot_cursor(5, 24)
    nv_screen_clear()
    rts   // program done, return
// end main program
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// subroutine to set the program parameters based on the difficulty 
// option specified on title screen
AstroSetDiffParams:
{
    lda astro_diff_mode
TryEasy:
    cmp #ASTRO_DIFF_EASY
    bne TryMed
IsEasy:
    // Set easy mode params here
    nv_store16_immediate(astro_auto_turret_wait_frames, ASTRO_AUTO_TURRET_WAIT_FRAMES_EASY)
    jmp DoneDiffParams

TryMed:
    cmp #ASTRO_DIFF_MED
    bne TryHard
IsMed:
    // Set medium mode params here
    nv_store16_immediate(astro_auto_turret_wait_frames, ASTRO_AUTO_TURRET_WAIT_FRAMES_MED)
    jmp DoneDiffParams

TryHard:
    // if wasn't easy or medium, assume hard
    // set hard mode params here
    nv_store16_immediate(astro_auto_turret_wait_frames, ASTRO_AUTO_TURRET_WAIT_FRAMES_HARD)


    // fall through to done
DoneDiffParams:
    nv_adc16(frame_counter, astro_auto_turret_wait_frames, 
             astro_auto_turret_next_shot_frame)

    rts
}

//////////////////////////////////////////////////////////////////////////////
// subroutine to wait for no key currently pressed
WaitNoKey:
{
    nv_key_wait_no_key()
    rts
}


//////////////////////////////////////////////////////////////////////////////
// subroutine to put the score onto the screen
ScoreToScreen:
{
    nv_screen_poke_bcd_word_mem(0, 0, ship_1.score)
    nv_screen_poke_bcd_word_mem(24, 0, ship_2.score)
    rts
}

//////////////////////////////////////////////////////////////////////////////
// subroutine to cycle the color of a sprite just to show how
// the nv_sprite_set_color_from_memory macro works.
ChangeUp:
{
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
}


//////////////////////////////////////////////////////////////////////////////
// subroutine to Pause
DoPause:
{
    jsr SoundMuteOn
    nv_key_wait_any_key()
    jsr SoundMuteOff
    rts
}

//////////////////////////////////////////////////////////////////////////////
// subroutine to do all the keyboard stuff
DoKeyboard:
{
    // Check for joystick activity.
    // if there is any then we won't check keyboard.  
    // need this because joystick and keyboard seem to interfere
    // with each other and joystick activity can be misinterpreted 
    // as keyboard key presses
    jsr JoyIsAnyActivity
    beq NoJoy
IsJoy:  // Is joystick activity so just return
    rts
NoJoy:  // is no joystick activity so check keyboard

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
    bne TryTransitionKeys      // not speed up x key, skip to bottom
WasShip1FastX:
    ldx wind_count
    bne CantIncBecuaseWind
    jsr ship_1.IncVelX          // inc the ship X velocity
CantIncBecuaseWind:   
    jmp DoneKeys                // and skip to bottom

//////
// no repeat key presses handled here, only transition keys below this line
// if its a repeat key press then we'll ignore it.
TryTransitionKeys:
    nv_key_get_prev_pressed_y() // previou key pressed to Y reg
    sty scratch_byte            // then to scratch reg to compare with accum
    cmp scratch_byte            // if prev key == last key then done with keys
    bne NotDoneKeys
    jmp DoneKeys 

NotDoneKeys:
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
    bne TryExperimental02                           
WasDecVolume:
    jsr SoundVolumeDown
    jmp DoneKeys

TryExperimental02:
    cmp #KEY_EXPERIMENTAL_02             
    bne TryExperimental03                           
WasExperimental02:
    lda #TURRET_3_ID
    ora #TURRET_6_ID
    jsr TurretStartIfArmed
    jmp DoneKeys

TryExperimental03:
    cmp #KEY_EXPERIMENTAL_03             
    bne TryExperimental04                           
WasExperimental03:
    lda #TURRET_2_ID
    ora #TURRET_5_ID
    jsr TurretStartIfArmed
    jmp DoneKeys

TryExperimental04:
    cmp #KEY_EXPERIMENTAL_04             
    bne TryExperimental01                           
WasExperimental04:
    lda #TURRET_4_ID
    ora #TURRET_1_ID
    jsr TurretStartIfArmed
    jmp DoneKeys

TryExperimental01:
    cmp #KEY_EXPERIMENTAL_01             
    bne TryQuit                           
WasExperimental01:
    jsr WindStart
    jmp DoneKeys

TryQuit:
    cmp #KEY_QUIT               // check quit key
    bne DoneKeys                // not quit key, skip to bottom
WasQuit:
    lda #1                      // set the quit flag
    sta quit_flag

DoneKeys:
    rts
}
// DoKeyboard - end
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// subroutine to process joystick input
DoJoystick:
{
    jsr JoyScan

Joy1TryLeft:
    ldx #JOY_PORT_1_ID
    jsr JoyIsLeft
    beq Joy1TryRight
Joy1IsLeft:
    jsr ship_1.DecVelX          // slow down the ship X
    jmp Joy1Done                // was left, can't be right too

Joy1TryRight:
    ldx #JOY_PORT_1_ID
    jsr JoyIsRight
    beq Joy1Done
Joy1IsRight:
    ldx wind_count
    bne Joy1CantIncBecuaseWind
    jsr ship_1.IncVelX          // inc the ship X velocity
Joy1CantIncBecuaseWind:   

Joy1Done:

Joy2TryLeft:
    ldx #JOY_PORT_2_ID
    jsr JoyIsLeft
    beq Joy2TryRight
Joy2IsLeft:
    jsr ship_2.DecVelX          // slow down the ship X
    jmp Joy2Done                // was left cant be right too

Joy2TryRight:
    ldx #JOY_PORT_2_ID
    jsr JoyIsRight
    beq Joy2Done
Joy2IsRight:
    ldx wind_count
    bne Joy2CantIncBecuaseWind
    jsr ship_2.IncVelX          // inc the ship X velocity
Joy2CantIncBecuaseWind:   

Joy2Done:

JoyDone:
    rts
}
// DoJoystick - end
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// call to determine if its time to start a wind gust.  if it is time then
// the wind will be started
// This is the number of bits to consider when comparing
// second counter to determine if its time for wind
.const WIND_SECONDS_MASK = $0F
WindCheck:
{   
    lda second_counter      // load LSB of second counter
    and #WIND_SECONDS_MASK  // zero out all but low few bits
    eor wind_start_mask     // exclusive or with start mask
    beq WindCheckIsTimeToStart
    jmp WindCheckDone       // if bits dont match mask bits then done

WindCheckIsTimeToStart:     // bits did match with mask, so start wind
    nv_rand_byte_a(true)    // get new random byte for mask
    and #WIND_SECONDS_MASK  // clear all but low few bits
    sta wind_start_mask     // save new mask
    jsr WindStart           // start wind

WindCheckDone:
    rts
}
// WindCheck end
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// subroutine to start shooting turret if its currently armed.  if not armed
// then the turret will not be started
// accum: must have turret ID or IDs to start.  
// 
TurretStartIfArmed:
{
    tay                             // save turret ID in y reg
    jsr TurretCurrentlyArmedLda     // check if turret is armed
    beq TurretNotArmedCantStart     // not armed, so can't shoot
TurretIsArmedCanStart:
    tya                             // get turret ID back in accum
    jsr TurretStart                 // start the turret with ID/s

    // now set the clock for when the next auto start can happen
    nv_adc16(frame_counter, astro_auto_turret_wait_frames, 
             astro_auto_turret_next_shot_frame)
    // in the unlikely event that next frame number is beyond the 
    // 16 bit limit it rolls around to some small number but so does
    // the frame counter so that should be fine.

    jsr TurretArmStart              // start arming the turret again
TurretNotArmedCantStart:
    rts
}
// TurretStartIfArmed - end
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// subroutine to start shooting automatically and aim at each ship based
// on its x location on the screen.  if turret not armed then does nothing 
TurretAutoStart:
{
    .const ZONE_1_MAX = nv_screen_rect_char_to_screen_pixel_left(25, 0)
    .const ZONE_2_MAX = nv_screen_rect_char_to_screen_pixel_left(35, 0)
    .const ZONE_3_MAX = nv_screen_rect_char_to_screen_pixel_left(39, 0)

    jsr TurretCurrentlyArmedLda
    bne TurretAutoStartIsArmed
    jmp TurretAutoStartDone

TurretAutoStartIsArmed:
    // turret is armed, now see if its time to fire
    nv_bgt16(frame_counter, astro_auto_turret_next_shot_frame, TurretAutoWaitOver)
    // not done waiting for autostart
    jmp TurretAutoStartDone

TurretAutoWaitOver:
TurretAutoTryShip1Zone1:    
    nv_bgt16_immediate(ship_1.x_loc, ZONE_1_MAX, TurretAutoTryShip1Zone2)
    lda #TURRET_3_ID
    sta turret_auto_start_ids
    jmp TurretAutoTryShip2

TurretAutoTryShip1Zone2:
    nv_bgt16_immediate(ship_1.x_loc, ZONE_2_MAX, TurretAutoTryShip1Zone3)
    lda #TURRET_2_ID
    sta turret_auto_start_ids
    jmp TurretAutoTryShip2

TurretAutoTryShip1Zone3:
    lda #TURRET_1_ID
    sta turret_auto_start_ids

TurretAutoTryShip2:    
TurretAutoTryShip2Zone1:    
    nv_bgt16_immediate(ship_2.x_loc, ZONE_1_MAX, TurretAutoTryShip2Zone2)
    lda #TURRET_6_ID
    ora turret_auto_start_ids
    sta turret_auto_start_ids
    jmp TurretAutoStartDoIt

TurretAutoTryShip2Zone2:
    nv_bgt16_immediate(ship_2.x_loc, ZONE_2_MAX, TurretAutoTryShip2Zone3)
    lda #TURRET_5_ID
    ora turret_auto_start_ids
    sta turret_auto_start_ids
    jmp TurretAutoStartDoIt

TurretAutoTryShip2Zone3:
    lda #TURRET_4_ID
    ora turret_auto_start_ids
    sta turret_auto_start_ids

TurretAutoStartDoIt:
    // load all the turret IDs and fire turret
    lda turret_auto_start_ids
    jsr TurretStartIfArmed

TurretAutoStartDone:
    rts
turret_auto_start_ids: .byte $00

}
// TurretAutoStart - end
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
CheckSpriteHitTurretBullet1:
    nv_sprite_check_overlap_rect_sr(turret_1_bullet_rect)

//////////////////////////////////////////////////////////////////////////////
CheckSpriteHitTurretBullet2:
    nv_sprite_check_overlap_rect_sr(turret_2_bullet_rect)

//////////////////////////////////////////////////////////////////////////////
CheckSpriteHitTurretBullet3:
    nv_sprite_check_overlap_rect_sr(turret_3_bullet_rect)

//////////////////////////////////////////////////////////////////////////////
CheckSpriteHitTurretBullet4:
    nv_sprite_check_overlap_rect_sr(turret_4_bullet_rect)

//////////////////////////////////////////////////////////////////////////////
CheckSpriteHitTurretBullet5:
    nv_sprite_check_overlap_rect_sr(turret_5_bullet_rect)

//////////////////////////////////////////////////////////////////////////////
CheckSpriteHitTurretBullet6:
    nv_sprite_check_overlap_rect_sr(turret_6_bullet_rect)

//////////////////////////////////////////////////////////////////////////////
// x and y reg have x and y screen loc for the char to check the sprite 
// location against
TurretHitCheck:
{
Turret1HitCheck:
    lda #TURRET_1_ID
    jsr TurretLdaActive
    bne Turret1ActiveTimeToCheckRect
    // turret not active, try next turret
    jmp Turret2HitCheck
    
Turret1ActiveTimeToCheckRect:  
    lda #>ship_1.base_addr
    ldx #<ship_1.base_addr
    jsr CheckSpriteHitTurretBullet1
    // now accum is 1 if hit or 0 if didn't
    //sta turret_hit_ship_1
    beq Turret2HitCheck

Turret1DidHit:
    lda #1
    jsr ShipDeathStart
    lda #TURRET_1_ID
    jsr TurretForceStop

Turret2HitCheck:
    lda #TURRET_2_ID
    jsr TurretLdaActive
    bne Turret2ActiveTimeToCheckRect
    // turret not active, try next turret
    jmp Turret3HitCheck

Turret2ActiveTimeToCheckRect:  
    lda #>ship_1.base_addr
    ldx #<ship_1.base_addr
    jsr CheckSpriteHitTurretBullet2
    // now accum is 1 if hit or 0 if didn't
    //sta turret_hit_ship_1
    beq Turret3HitCheck

Turret2DidHit:
    lda #1
    jsr ShipDeathStart
    lda #TURRET_2_ID
    jsr TurretForceStop

Turret3HitCheck:
    lda #TURRET_3_ID
    jsr TurretLdaActive
    bne Turret3ActiveTimeToCheckRect
    // turret not active, try next turret
    jmp Turret4HitCheck

Turret3ActiveTimeToCheckRect:  
    lda #>ship_1.base_addr
    ldx #<ship_1.base_addr
    jsr CheckSpriteHitTurretBullet3
    // now accum is 1 if hit or 0 if didn't
    beq Turret4HitCheck

Turret3DidHit:
    lda #1
    jsr ShipDeathStart
    lda #TURRET_3_ID
    jsr TurretForceStop


Turret4HitCheck:
    lda #TURRET_4_ID
    jsr TurretLdaActive
    bne Turret4ActiveTimeToCheckRect
    // turret not active, try next turret
    jmp Turret5HitCheck
    
Turret4ActiveTimeToCheckRect:  
    lda #>ship_2.base_addr
    ldx #<ship_2.base_addr
    jsr CheckSpriteHitTurretBullet4
    // now accum is 1 if hit or 0 if didn't
    //sta turret_hit_ship_1
    beq Turret5HitCheck

Turret4DidHit:
    lda #2
    jsr ShipDeathStart
    lda #TURRET_4_ID
    jsr TurretForceStop

Turret5HitCheck:
    lda #TURRET_5_ID
    jsr TurretLdaActive
    bne Turret5ActiveTimeToCheckRect
    // turret not active, try next turret
    jmp Turret6HitCheck
    
Turret5ActiveTimeToCheckRect:  
    lda #>ship_2.base_addr
    ldx #<ship_2.base_addr
    jsr CheckSpriteHitTurretBullet5
    // now accum is 1 if hit or 0 if didn't
    //sta turret_hit_ship_1
    beq Turret6HitCheck

Turret5DidHit:
    lda #2
    jsr ShipDeathStart
    lda #TURRET_5_ID
    jsr TurretForceStop


Turret6HitCheck:
    lda #TURRET_6_ID
    jsr TurretLdaActive
    bne Turret6ActiveTimeToCheckRect
    // turret not active, try next turret
    jmp TurretHitCheckDone
    
Turret6ActiveTimeToCheckRect:  
    lda #>ship_2.base_addr
    ldx #<ship_2.base_addr
    jsr CheckSpriteHitTurretBullet6
    // now accum is 1 if hit or 0 if didn't
    beq TurretHitCheckDone

Turret6DidHit:
    lda #2
    jsr ShipDeathStart
    lda #TURRET_6_ID
    jsr TurretForceStop

TurretHitCheckDone:
    rts
}
// TurretHitCheck End
//////////////////////////////////////////////////////////////////////////////


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
                                          0,            // sprite enabled 
                                          0, 0, 24, 21) // hitbox left, top, right, bottom
                                          
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
.break
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
                                          0,            // sprite enabled 
                                          0, 0, 24, 21) // hitbox left, top, right, bottom

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
                                          0,            // sprite enabled 
                                          0, 0, 24, 21) // hitbox left, top, right, bottom

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
                                          0,            // sprite enabled 
                                          0, 0, 24, 21) // hitbox left, top, right, bottom

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
                                          0,            // sprite enabled 
                                          0, 0, 24, 21) // hitbox left, top, right, bottom

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
    nop
SpriteExtraPtrLoaded:
    rts

#import "astro_title_code.asm"


// our sprite routines will goto this address
//*=$6000 "Sprite Code"

// put the actual sprite subroutines here


//#import "../nv_c64_util/nv_screen_code.asm"
//#import "../nv_c64_util/nv_sprite_raw_code.asm"
/*
ship_collision_label_str: .text  @"ship collision sprite:\$00"
DebugShipCollisionSprite:
    nv_debug_print_labeled_byte_mem(0, 0, ship_collision_label_str, 22, nv_b8, true, false)
    rts
*/
#import "astro_sound.asm"
