//////////////////////////////////////////////////////////////
#import "../nv_c64_util/nv_c64_util_macs_and_data.asm"


*=$8000 "astro sound"

SoundLoadAddr:
.import binary "astro_sound.bin"

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
.label PrivateSoundFx = SoundLoadAddr + 6

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

////////////////////////////////////////////////////////////////
// Call once every raster interupt to play sounds
.macro SoundDoStep()
{
    jsr PrivateSoundStep
}

/*
.macro SoundDoVolUp()
{
    jsr VolumeUp
}

.macro SoundDoVolDown()
{
    jsr VolumeDown
}
*/