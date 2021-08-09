//////////////////////////////////////////////////////////////////////////////
// astro_wind.asm 
//////////////////////////////////////////////////////////////////////////////
// The following subroutines should be called from the main engine
// as follows
// WindInit: Call once before main loop
// WindStep: Call once every raster frame through the main loop
// WindStart: Call to start the wind effect
// WindForceStop: Call to force wind effect to stop if it is active
// WindCleanup: Call at end of program after main loop to clean up
//////////////////////////////////////////////////////////////////////////////
#importonce 

#import "../nv_c64_util/nv_c64_util_macs_and_data.asm"
#import "astro_wind_glimmer_data.asm"
#import "../nv_c64_util/nv_screen_code.asm"
#import "astro_vars_data.asm"
#import "astro_wind_data.asm"
#import "astro_wind_glimmer_code.asm"

#import "astro_ships_code.asm"

//////////////////////////////////////////////////////////////////////////////
// subroutine to start the initialize wind, call once before main loop
WindInit:
    // reduce velocity while count greater than 0
    lda #$00
    sta wind_count
    sta wind_ship_1_done
    sta wind_ship_2_done
    jsr WindGlimmerInit
    rts


//////////////////////////////////////////////////////////////////////////////
// subroutine to start the wind effect
.const WIND_FRAMES = 5
WindStart:
    lda wind_count
    bne WindAlreadyStarted
    lda #$00
    sta wind_ship_1_done
    sta wind_ship_2_done
    lda #WIND_FRAMES
    sta wind_count
    jsr WindGlimmerStart
WindAlreadyStarted:
    rts


//////////////////////////////////////////////////////////////////////////////
// subroutine to call once per raster frame while wind is happening
// if wind_count is zero and wind_glimmer_count is zero then this routine
// will do nothing. continually calling the routine will eventually get to 
// the state of wind_count = 0 and wind_glimmer_count = 0 so its safe
// to call this once every raster frame regardless of if wind is active
// or not.  It is possible for wind_count to get to zero before 
// wind_glimmer_count is zero so its not sufficient to just check wind_count
WindStep:
    lda ship_1.x_vel
    bpl WindCheckLeftShip2

WindCheckLeftShip1:
    // if pushing ship off left of screen, then just set its velocity to 1
    nv_bgt16_immediate(ship_1.x_loc, WIND_SHIP_MIN_LEFT, WindCheckLeftShip2)
    lda #$01
    sta ship_1.x_vel
    lda #$01
    sta wind_ship_1_done

WindCheckLeftShip2:
    // if pushing ship off left of screen, then just set its velocity to 1
    nv_bgt16_immediate(ship_2.x_loc, WIND_SHIP_MIN_LEFT, CheckGlimmerFrame)
    lda #$01
    sta ship_2.x_vel
    lda #$01
    sta wind_ship_2_done

CheckGlimmerFrame:
    // step the wind glimmer effect only when frame counter last 2 bits
    // are zero (#$03 is every forth frame)
    lda #$03
    bit frame_counter
    bne CheckShipEffectFrame 
    jsr WindGlimmerStep 

    lda wind_count 
    bne CheckShipEffectFrame
    jmp WindDoneStep

CheckShipEffectFrame:
    // effect the ship only when last 3 bits of frame counter
    // are zero (#$07 is every 8th frame)
    lda #$07 
    bit frame_counter
    bne CheckWindCount
    jmp WindDoneStep      // if not LSB of 00 then don't do anything

CheckWindCount:
    // check if we've stepped enough times
    lda wind_count
    beq WindDoneStep            // done stepping
    dec wind_count

    lda #$FF                    // start decrement value at -1 
    sta wind_ship1_dec_value
    sta wind_ship2_dec_value

    lda wind_ship_1_done        // check if done with ship 1 already
    bne WindSetDecShip2

    nv_blt16_immediate(ship_1.x_loc, WIND_X_ZONE_2, WindAdjustVelShip1)
    dec wind_ship1_dec_value    // decrement value to -2

    nv_blt16_immediate(ship_1.x_loc, WIND_X_ZONE_3, WindAdjustVelShip1)
    dec wind_ship1_dec_value    // decrement value to -3

WindAdjustVelShip1:
    clc
    lda wind_ship1_dec_value // load the value to decrement by -1, -2 or -3
    adc ship_1.x_vel         // add the negative number to decremnt 
    bpl WindSetVelShip1      // if velocity still positive then ok to set
    cmp #WIND_MAX_X_NEG_VEL  // velocity max neg value
    bcs WindSetVelShip1      // if we are setting to -2 or -1 its ok
    lda #WIND_MAX_X_NEG_VEL  // cap max neg velocity
WindSetVelShip1:
    sta ship_1.x_vel         // store back into ship velocity


WindSetDecShip2:
    lda wind_ship_2_done
    bne WindDoneVelShip2
    nv_blt16_immediate(ship_2.x_loc, WIND_X_ZONE_2, WindAdjustVelShip2)
    dec wind_ship2_dec_value    // decrement value to -2

    nv_blt16_immediate(ship_2.x_loc, WIND_X_ZONE_3, WindAdjustVelShip2)
    dec wind_ship2_dec_value    // decrement value to -3

WindAdjustVelShip2:
    clc
    lda wind_ship2_dec_value // load the value to decrement by -1, -2 or -3
    adc ship_2.x_vel         // add the negative number to decremnt 
    bpl WindSetVelShip2      // if velocity still positive then ok to set
    cmp #WIND_MAX_X_NEG_VEL  // velocity max neg value
    bcs WindSetVelShip2      // if we are setting to -2 or -1 its ok
    lda #WIND_MAX_X_NEG_VEL  // cap max neg velocity at
WindSetVelShip2:
    sta ship_2.x_vel         // store back into ship velocity

WindDoneVelShip2:
WindDoneStep:
    rts
// WindStep End.    
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// subroutine to call to force the wind to stop if it is active. if not 
// active then should have no effect
WindForceStop:
    lda #$00
    sta wind_count
    sta wind_ship_1_done
    sta wind_ship_2_done
    jsr WindGlimmerForceStop
    rts
// WindForceStop End
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// subroutine to call at end of program when done with all other wind
// data and routines.
WindCleanup:
    jsr WindForceStop
    rts
// WindCleanup End
//////////////////////////////////////////////////////////////////////////////

