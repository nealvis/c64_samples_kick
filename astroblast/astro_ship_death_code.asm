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
    sta ship_1_death_count
    sta ship_1_death_pushed_left_min
    sta ship_2_death_count
    sta ship_2_death_pushed_left_min
    rts
// ShipDeathInit end
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// Call once every raster frame through the main loop
// params:
//   accum: set to 1 or 2 for ship 1 or ship 2
ShipDeathStep: 
{
ShipDeathStepTryShip1:    
    cmp #1
    bne ShipDeathStepTryShip2
    jsr Ship1DeathStep
    rts
    
 ShipDeathStepTryShip2:   
    cmp #2
    bne ShipDeathStepDone
    jsr Ship2DeathStep

ShipDeathStepDone:
    rts

}
// end - ShipDeathStep 
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
//
Ship1DeathStep:
{
    lda ship_1_death_count
    bne ShipDeathFramesStart
    rts

ShipDeathFramesStart:
    // if pushing ship off left of screen, then just set its velocity to 1
    nv_bgt16_immediate(ship_1.x_loc, SHIP_DEATH_MIN_LEFT, ShipDeathTrySetRetreatVel)
    lda #$01
    sta ship_1.x_vel
    
    lda #$01
    sta ship_1_death_pushed_left_min

ShipDeathTrySetRetreatVel:
    lda ship_1_death_pushed_left_min
    bne ShipDeathDecCount              // if already pushed max, don't control vel
    // set ship velocity to -1
    lda #$FF
    sta ship_1.x_vel
    // y vel to 0
    lda #0
    sta ship_1.y_vel

ShipDeathDecCount:
    dec ship_1_death_count
    bne ShipDeathCountContinues
    jsr ship_1.SetColorAlive
    
    lda #1
    sta ship_1.y_vel

ShipDeathCountContinues:
    rts
}
// Ship1DeathStep end   
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
//
Ship2DeathStep:
{
    lda ship_2_death_count
    bne Ship2DeathFramesStart
    rts

Ship2DeathFramesStart:
    // if pushing ship off left of screen, then just set its velocity to 1
    nv_bgt16_immediate(ship_2.x_loc, SHIP_DEATH_MIN_LEFT, Ship2DeathTrySetRetreatVel)
    lda #$01
    sta ship_2.x_vel
    
    lda #$01
    sta ship_2_death_pushed_left_min

Ship2DeathTrySetRetreatVel:
    lda ship_2_death_pushed_left_min
    bne Ship2DeathDecCount              // if already pushed max, don't control vel
    // set ship velocity to -1
    lda #$FF
    sta ship_2.x_vel
    // y vel to 0
    lda #0
    sta ship_2.y_vel

Ship2DeathDecCount:
    dec ship_2_death_count
    bne Ship2DeathCountContinues
    jsr ship_2.SetColorAlive
    
    lda #1
    sta ship_2.y_vel

Ship2DeathCountContinues:
    rts
}
// Ship2DeathStep end   
//////////////////////////////////////////////////////////////////////////////




//////////////////////////////////////////////////////////////////////////////
// Call to start the effect
// params:
//   accum: set to 1 or 2 for ship 1 or ship 2
ShipDeathStart: 
{
ShipDeathStartTryShip1:
    cmp #1
    bne ShipDeathStartTryShip2
    lda #SHIP_DEATH_FRAMES
    sta ship_1_death_count
    lda #$00
    sta ship_1_death_pushed_left_min
    jsr ship_1.SetColorDead
    rts

ShipDeathStartTryShip2:
    cmp #2
    bne ShipDeathStartDone
    lda #SHIP_DEATH_FRAMES
    sta ship_2_death_count
    lda #$00
    sta ship_2_death_pushed_left_min
    jsr ship_2.SetColorDead
ShipDeathStartDone:
    rts
}
// ShipDeathStart end subroutine
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// Call to force effect to stop if it is active
ShipDeathForceStop: 
    lda #$00
    sta ship_1_death_count
    sta ship_2_death_count
    rts
// ShipDeathForceStop end
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// Call at end of program after main loop to clean up
ShipDeathCleanup: 
    rts
// ShipDeathCleanup end
//////////////////////////////////////////////////////////////////////////////