//////////////////////////////////////////////////////////////////////////////
// astro_ship_death.asm 
//////////////////////////////////////////////////////////////////////////////
// The following subroutines should be called from the main engine
// as follows
// ShipDeathInit: Call once before main loop
// ShipDeathStep: Call once every raster frame through the main loop
// ShipDeathStart: Call to start the effect
// ShipDeathForceStop: Call to force effect to stop if it is active
// ShipDeathCleanup: Call at end of program after main loop to clean up
//////////////////////////////////////////////////////////////////////////////
#importonce

#import "astro_ship_death_data.asm"
#import "astro_ships_code.asm"

//////////////////////////////////////////////////////////////////////////////
// Call once before main loop
ShipDeathInit: 
    lda #$00
    sta ship_death_count
    sta ship_death_pushed_left_min
    rts
// ShipDeathInit end
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// Call once every raster frame through the main loop
ShipDeathStep: 
    lda ship_death_count
    bne ShipDeathFramesStart
    rts

ShipDeathFramesStart:

    // if pushing ship off left of screen, then just set its velocity to 1
    nv_bgt16_immediate(ship_1.x_loc, SHIP_DEATH_MIN_LEFT, ShipDeathTrySetRetreatVel)
    lda #$01
    sta ship_1.x_vel
    lda #$01
    sta ship_death_pushed_left_min

ShipDeathTrySetRetreatVel:
    lda ship_death_pushed_left_min
    bne ShipDeathDecCount              // if already pushed max, don't control vel
    // set ship velocity to -1
    lda #$FF
    sta ship_1.x_vel

ShipDeathDecCount:
    dec ship_death_count
    bne ShipDeathCountContinues
    jsr ship_1.SetColorAlive
ShipDeathCountContinues:
    rts
// ShipDeathStep end   
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// Call to start the effect
ShipDeathStart: 
    lda #SHIP_DEATH_FRAMES
    sta ship_death_count
    lda #$00
    sta ship_death_pushed_left_min

    jsr ship_1.SetColorDead
    rts

// ShipDeathStart end subroutine
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// Call to force effect to stop if it is active
ShipDeathForceStop: 
    lda #$00
    sta ship_death_count
    rts
// ShipDeathForceStop end
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// Call at end of program after main loop to clean up
ShipDeathCleanup: 
    rts
// ShipDeathCleanup end
//////////////////////////////////////////////////////////////////////////////