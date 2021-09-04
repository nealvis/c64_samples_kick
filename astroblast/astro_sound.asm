#importonce

//////////////////////////////////////////////////////////////
#import "../nv_c64_util/nv_c64_util_macs_and_data.asm"


*=$8000 "astro sound"

SoundLoadAddr:
.import binary "astro_sound.bin"

///////////////////////
// sound effects
// higher memory addresses for an effect are higher priority
// lower addresses effects don't interupt higher address effects
SoundFxShip1HitAsteroidPrivate:
SoundFxShip2HitAsteroidPrivate:
.import binary "ship_hit_asteroid_sound_fx.bin"

//SoundFxShip2HitAsteroid:
//.import binary "ship_hit_asteroid_sound_fx.bin"

SoundFxTurretFirePrivate:
.import binary "turret_fire_sound_fx.bin"

 SoundFxShipHitByTurretPrivate:
.import binary "ship_hit_by_turret_sound_fx.bin"

SoundFxHolePrivate:
.import binary "hole_sound_fx.bin"

SoundFxSilencePrivate:
.import binary "silent_sound_fx.bin"

sound_master_volume: .byte 7
sound_mute: .byte 0

.const MAX_VOLUME = $0F
.const MIN_VOLUME = $00

//////////////////////////////////////////////////////////////
// Subroutine to initialize Sound. 
// to call 
//   LDA #0  (for song zero)
//   JSR SoundInit
.label PrivateSoundInit = SoundLoadAddr

//////////////////////////////////////////////////////////////
// Subroutine to call every raster interupt to step the sound. 
// To call:
//   JSR PrivateSoundStep
.label PrivateSoundStep = SoundLoadAddr + 3

//////////////////////////////////////////////////////////////
// to play sound fx:
//LDA #<effect        ;Start address of sound effect data
//        LDY #>effect
//        LDX #channel        ;0, 7 or 14 for channels 1-3
//        JSR startaddress+6
.label PrivateSoundPlayFx = SoundLoadAddr + 6

//////////////////////////////////////////////////////////////
// subroutine to set the volume
// LDA volume (0-15)
// JSR startaddress + 9
.label PrivateSoundVolumeSet = SoundLoadAddr + 9


//////////////////////////////////////////////////////////////
//  Public subroutines and macros below
//  the private routines above should be used internally
//  to this file only.
//////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////
// Subroutine to initialize Sound for song 0
// to call 
//   JSR SoundInit
SoundInit:
    lda #$00
    jsr PrivateSoundInit
    rts

//////////////////////////////////////////////////////////////
// Subroutine to call when done playing sounds
//   JSR SoundDone
SoundDone:
    lda #$00
    jsr PrivateSoundInit
    rts


//////////////////////////////////////////////////////////////
// To turn volume Up 
// JSR VolumeUp
SoundVolumeUp:
    lda sound_master_volume
    cmp #MAX_VOLUME
    beq AtMaxVol
    inc sound_master_volume
    lda sound_master_volume
    jsr PrivateSoundVolumeSet
AtMaxVol:
    rts


//////////////////////////////////////////////////////////////
// To turn volume down 
// JSR VolumeDown
SoundVolumeDown:
    lda sound_master_volume
    cmp #MIN_VOLUME
    beq AtMinVol
    dec sound_master_volume
    lda sound_master_volume
    jsr PrivateSoundVolumeSet
AtMinVol:
    rts

//////////////////////////////////////////////////////////////
// To turn volume down 
// LDA #vol       (0-15 level of vol to set)
// JSR VolumeDown
SoundVolumeSet:
    and #$0F
    sta sound_master_volume
    jsr PrivateSoundVolumeSet
    rts

//////////////////////////////////////////////////////////////
// subroutine to set mute on
//  JSR SoundMuteOn
SoundMuteOn:
    lda #$01
    sta sound_mute
    lda #$00
    jsr PrivateSoundVolumeSet
    SoundDoStep()               // step sound once to apply volume
    rts

//////////////////////////////////////////////////////////////
// subroutine to set mute off
//  JSR SoundMuteOff
SoundMuteOff:
    lda #$00
    sta sound_mute
    lda sound_master_volume
    jsr PrivateSoundVolumeSet
    SoundDoStep()               // step sound once to apply volume
    rts


//////////////////////////////////////////////////////////////
// subroutine to toggle mute 
//  JSR SoundMuteOff
SoundMuteToggle:
    lda sound_mute
    beq MuteCurrentlyOff
MuteCurrentlyOn:
    jsr SoundMuteOff
    rts
MuteCurrentlyOff:
    jsr SoundMuteOn
    rts


////////////////////////////////////////////////////////////////
// Call once every raster interupt to play sounds
.macro SoundDoStep()
{
    jsr PrivateSoundStep
}


//////////////////////////////////////////////////////////////////////////////
// play a sound effect
// Before calling the private sound effect routine we'll need to 
//        LDA #<effect        ;Start address of sound effect data
//        LDY #>effect
//        LDX #channel        ;0, 7 or 14 for channels 1-3
//        JSR startaddress+6
SoundPlayShip1AsteroidFX:
    lda #<SoundFxShip1HitAsteroidPrivate
    ldy #>SoundFxShip1HitAsteroidPrivate
    ldx #14
    jsr PrivateSoundPlayFx
    rts 

//////////////////////////////////////////////////////////////////////////////
// play a sound effect
// Before calling the private sound effect routine we'll need to:
//        LDA #<effect        ;Start address of sound effect data
//        LDY #>effect
//        LDX #channel        ;0, 7 or 14 for channels 1-3
//        JSR startaddress+6
SoundPlayShip2AsteroidFX:
    lda #<SoundFxShip2HitAsteroidPrivate
    ldy #>SoundFxShip2HitAsteroidPrivate
    ldx #14
    jsr PrivateSoundPlayFx
    rts    


//////////////////////////////////////////////////////////////////////////////
// play turret firing sound effect
// Before calling the private sound effect routine we'll need to:
//        LDA #<effect        ;Start address of sound effect data
//        LDY #>effect
//        LDX #channel        ;0, 7 or 14 for channels 1-3
//        JSR startaddress+6
SoundPlayTurretFireFX:
    lda #<SoundFxTurretFirePrivate
    ldy #>SoundFxTurretFirePrivate
    ldx #14
    jsr PrivateSoundPlayFx
    rts    


    
//////////////////////////////////////////////////////////////////////////////
// play turret firing sound effect
// Before calling the private sound effect routine we'll need to:
//        LDA #<effect        ;Start address of sound effect data
//        LDY #>effect
//        LDX #channel        ;0, 7 or 14 for channels 1-3
//        JSR startaddress+6
SoundPlayShipHitByTurretFX:
    lda #<SoundFxShipHitByTurretPrivate
    ldy #>SoundFxShipHitByTurretPrivate
    ldx #14
    jsr PrivateSoundPlayFx
    rts    


//////////////////////////////////////////////////////////////////////////////
// play turret firing sound effect
// Before calling the private sound effect routine we'll need to:
//        LDA #<effect        ;Start address of sound effect data
//        LDY #>effect
//        LDX #channel        ;0, 7 or 14 for channels 1-3
//        JSR startaddress+6
SoundPlayHoleFX:
    lda #<SoundFxHolePrivate
    ldy #>SoundFxHolePrivate
    //lda #<SoundFxTurretFirePrivate
    //ldy #>SoundFxTurretFirePrivate

    ldx #14
    jsr PrivateSoundPlayFx
    rts

//////////////////////////////////////////////////////////////////////////////
// Stops all the effect sounds
// Before calling the private sound effect routine we'll need to:
//        LDA #<effect        ;Start address of sound effect data
//        LDY #>effect
//        LDX #channel        ;0, 7 or 14 for channels 1-3
//        JSR startaddress+6
SoundPlaySilenceFX:
{
    lda #<SoundFxSilencePrivate
    ldy #>SoundFxSilencePrivate
    ldx #14
    jsr PrivateSoundPlayFx
Done:
    rts    
}
