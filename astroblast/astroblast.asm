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

    jsr DoPreTitleInit

DoTitle:
    jsr TitleStart              // show title screen
    bne RunGame                 // make sure non zero in accum and run game
    jmp ProgramDone             // if zero in accum then user quit

RunGame:

    // standard initialization
    jsr DoPostTitleInit

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
    bmi NoCollisionShip1            // if no collisions so check minus
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
    nv_blt16(ship_1.score, astro_score_to_win, NoWinShip1)
    // if we get here then ship1 won
    jsr ScoreToScreen
    jsr DoWinner
    jmp DoTitle
NoWinShip1:
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
    nv_blt16(ship_2.score, astro_score_to_win, NoWinShip2)
    // if we get here then ship2 won
    jsr ScoreToScreen
    jsr DoWinner
    jmp DoTitle

NoWinShip2:
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

    jsr AllSpritesDisable

    nv_key_done()
    nv_rand_done()

    nv_screen_custom_charset_done()

    nv_screen_plot_cursor(5, 24)
    nv_screen_clear()
    rts   // program done, return
// end main program
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// subroutine to initialize the things that must be initialized before
// screen is started
DoPreTitleInit:
{
    nv_screen_custom_charset_init(6, false)
    nv_screen_set_border_color_mem(border_color)
    nv_screen_set_background_color_mem(background_color)

    // initialize random numbers, needs to be before soundstarts
    nv_rand_init(true)          // do before SoundInit

    // initialized keyboard routine so user can use keyboard  
    // in title screen for changing options etc.
    nv_key_init()

    // initialize song 0 so we can hear music during title 
    // so user can adjust volume
    jsr SoundInit

    // start at volumen 2
    lda #$02
    jsr SoundVolumeSet

    // clear quit flag since it can be set in title screen
    lda #$00
    sta quit_flag

    // start out in easy mode, user can adjust in title screen
    lda #ASTRO_DIFF_EASY
    sta astro_diff_mode

    // set the global sprite multi colors        
    nv_sprite_raw_set_multicolors(NV_COLOR_LITE_GREEN, NV_COLOR_WHITE)

    // setup the score required to win to default value
    nv_store16_immediate(astro_score_to_win, ASTRO_DEFAULT_SCORE_TO_WIN)

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
    
    rts
}
// DoPreTitleInit - end
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// subroutine to initialize the things that must be initialized after the
// title screen is started
DoPostTitleInit:
{
    nv_store16_immediate(second_counter, $0000)
    nv_store16_immediate(second_partial_counter, $0000)
    nv_store16_immediate(frame_counter, $0000)
    nv_store16_immediate(ship_1.score, $0000)
    nv_store16_immediate(ship_2.score, $0000)

    lda #$00
    sta sprite_collision_reg_value

    // initialize based on difficulty (must be after standard init)
    jsr AstroSetDiffParams

    // clear the screen just to have an empty canvas
    nv_screen_clear()

    jsr StarInit
    jsr WindInit
    jsr TurretInit
    jsr TurretArmInit
    jsr TurretArmStart
    jsr ShipDeathInit
    jsr JoyInit

    // initialize sprite locations to locations to start game 
    .const SHIP1_INIT_X_LOC = 22
    .const SHIP1_INIT_Y_LOC = 50
    .const SHIP1_INIT_X_VEL = 1
    .const SHIP1_INIT_Y_VEL = 1

    .const SHIP2_INIT_X_LOC = 22
    .const SHIP2_INIT_Y_LOC = 210
    .const SHIP2_INIT_X_VEL = 1
    .const SHIP2_INIT_Y_VEL = 1

    // init ship 1
    nv_store16_immediate(ship_1.x_loc, SHIP1_INIT_X_LOC) 
    lda #SHIP1_INIT_Y_LOC
    sta ship_1.y_loc
    lda #SHIP1_INIT_X_VEL
    sta ship_1.x_vel
    lda #SHIP1_INIT_Y_VEL
    sta ship_1.y_vel
    jsr ship_1.SetLocationFromExtraData
    jsr ship_2.SetColorAlive


    // init ship 2
    nv_store16_immediate(ship_2.x_loc, 0) 
    lda #SHIP2_INIT_Y_LOC
    sta ship_2.y_loc
    lda #SHIP2_INIT_X_VEL
    sta ship_2.x_vel
    lda #SHIP2_INIT_Y_VEL
    sta ship_2.y_vel
    jsr ship_2.SetLocationFromExtraData

    // set color for ship 2 
    jsr ship_2.SetColorAlive


    jsr asteroid_1.SetLocationFromExtraData
    jsr asteroid_2.SetLocationFromExtraData
    jsr asteroid_3.SetLocationFromExtraData
    jsr asteroid_4.SetLocationFromExtraData
    jsr asteroid_5.SetLocationFromExtraData


    jsr AllSpritesEnable

    // update astro_score_to_win when its modifiable in the title screen

    // position sprites here


    rts
}
// DoPostInit - end
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// subroutine to enable all sprites
AllSpritesEnable:
{
    // enable sprites
    jsr ship_1.Enable
    jsr ship_2.Enable
    jsr asteroid_1.Enable
    jsr asteroid_2.Enable
    jsr asteroid_3.Enable
    jsr asteroid_4.Enable
    jsr asteroid_5.Enable

    rts
}
// AllSpritesEnable
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// subroutine to disable all sprites
AllSpritesDisable:
{
    // enable sprites
    jsr ship_1.Disable
    jsr ship_2.Disable
    jsr asteroid_1.Disable
    jsr asteroid_2.Disable
    jsr asteroid_3.Disable
    jsr asteroid_4.Disable
    jsr asteroid_5.Disable

    rts
}
// AllSpritesDisable
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// subroutine to call when there is a winner detected
DoWinner:
{
    .const WINNER_SHIP_X_LOC = 69
    .const WINNER_SHIP_Y_LOC = 123
    jsr SoundMuteOn

    jsr AllSpritesDisable

    nv_screen_clear()

    nv_screen_poke_str(10, 10, winner_str)


    nv_bge16(ship_1.score, ship_2.score, WinnerShip1)

WinnerShip2:
    nv_store16_immediate(ship_2.x_loc, WINNER_SHIP_X_LOC)
    lda #WINNER_SHIP_Y_LOC
    sta ship_2.y_loc
    jsr ship_2.SetLocationFromExtraData
    jsr ship_2.Enable
    jmp WinnerWaitForKey

WinnerShip1:
    nv_store16_immediate(ship_1.x_loc, WINNER_SHIP_X_LOC)
    lda #WINNER_SHIP_Y_LOC
    sta ship_1.y_loc
    jsr ship_1.SetLocationFromExtraData

    jsr ship_1.Enable
    // fall through

WinnerWaitForKey:
    nv_key_wait_any_key()
    jsr SoundMuteOff

    jsr AllSpritesDisable

    // clear collsions so replaying won't use value from last 
    // frame of this game
    lda #$00
    sta sprite_collision_reg_value
    rts

    winner_str: .text @"winner!\$00"
    //winner_ship2_str: .text @"ship2 won\$00"
}
// DoWinner End
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
        cmp #SHIP_MAX_SPEED+1   // compare new spead with max +1
        bne SkipAsteroidMin     // if we haven't reached max + 1 then skip setting to min
        lda #SHIP_MIN_SPEED     // else, we have reached max+1 so need to reset it back min
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

Joy1TryFire:
    ldx #JOY_PORT_1_ID
    jsr JoyIsFiring
    beq Joy2TryFire
Joy1IsFiring:
    jsr TurretLdaSmartFireBottomID
    jsr TurretStartIfArmed          // slow down the ship X
    // fall through

Joy2TryFire:
    ldx #JOY_PORT_2_ID
    jsr JoyIsFiring
    beq Joy1TryLeft
Joy2IsFiring:
    jsr TurretLdaSmartFireTopID
    jsr TurretStartIfArmed          // slow down the ship X
    // fall through

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

.const SMART_FIRE_ZONE_1_MAX = nv_screen_rect_char_to_screen_pixel_left(25, 0)
.const SMART_FIRE_ZONE_2_MAX = nv_screen_rect_char_to_screen_pixel_left(35, 0)
.const SMART_FIRE_ZONE_3_MAX = nv_screen_rect_char_to_screen_pixel_left(39, 0)

//////////////////////////////////////////////////////////////////////////////
// subroutine to load accum with the Turret ID to smartly choose
// to shoot the top ship, based on the top ship's x position
// the accum will have the ID in it upon return.
TurretLdaSmartFireTopID:
{

TurretSmartTopTryShip1Zone1:    
    nv_bgt16_immediate(ship_1.x_loc, SMART_FIRE_ZONE_1_MAX, TurretSmartTopTryShip1Zone2)
    lda #TURRET_3_ID
    rts

TurretSmartTopTryShip1Zone2:
    nv_bgt16_immediate(ship_1.x_loc, SMART_FIRE_ZONE_2_MAX, TurretSmartTopTryShip1Zone3)
    lda #TURRET_2_ID
    rts
    
TurretSmartTopTryShip1Zone3:
    lda #TURRET_1_ID
    rts
}
// TurretLdaSmartFireTopID - end
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// subroutine to load accum with the Turret ID to smartly choose
// to shoot the bottom ship, based on the bottom ship's x position
// accum will have the ID in it upon return.
TurretLdaSmartFireBottomID:
{
TurretAutoTryShip2Zone1:    
    nv_bgt16_immediate(ship_2.x_loc, SMART_FIRE_ZONE_1_MAX, TurretSmartBottomTryShip2Zone2)
    lda #TURRET_6_ID
    rts
    
TurretSmartBottomTryShip2Zone2:
    nv_bgt16_immediate(ship_2.x_loc, SMART_FIRE_ZONE_2_MAX, TurretSmartBottomTryShip2Zone3)
    lda #TURRET_5_ID
    rts

TurretSmartBottomTryShip2Zone3:
    lda #TURRET_4_ID
    rts
}

//////////////////////////////////////////////////////////////////////////////
// subroutine to start shooting automatically and aim at each ship based
// on its x location on the screen.  if turret not armed then does nothing 
TurretAutoStart:
{

    jsr TurretCurrentlyArmedLda
    bne TurretAutoStartIsArmed
    jmp TurretAutoStartDone

TurretAutoStartIsArmed:
    // turret is armed, now see if its time to fire
    nv_bgt16(frame_counter, astro_auto_turret_next_shot_frame, TurretAutoWaitOver)
    // not done waiting for autostart
    jmp TurretAutoStartDone

TurretAutoWaitOver:
    // Turret is armed and the autostart wait time passed
    // time to fire

    jsr TurretLdaSmartFireTopID      // get the ID to use for top
    sta turret_auto_top_id        // store that ID

    jsr TurretLdaSmartFireBottomID   // get the ID to use for bottom
    ora turret_auto_top_id        // or it into the stored top ID
    // now Accum has a smartly selected turret ID from top and bottom
    // combinined via bitwise OR

TurretAutoStartDoIt:
    // load all the turret IDs and fire turret
    //lda turret_auto_start_ids
    jsr TurretStartIfArmed

TurretAutoStartDone:
    rts
turret_auto_top_id: .byte $00
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

Disable:
        lda #>info.base_addr
        ldx #<info.base_addr
        nv_sprite_extra_disable_sr()

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

Disable:
        lda #>info.base_addr
        ldx #<info.base_addr
        nv_sprite_extra_disable_sr()

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

Disable:
        lda #>info.base_addr
        ldx #<info.base_addr
        nv_sprite_extra_disable_sr()

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

Disable:
        lda #>info.base_addr
        ldx #<info.base_addr
        nv_sprite_extra_disable_sr()

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

Disable:
        lda #>info.base_addr
        ldx #<info.base_addr
        nv_sprite_extra_disable_sr()

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
