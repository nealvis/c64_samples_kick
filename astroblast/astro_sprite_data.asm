//////////////////////////////////////////////////////////////////////////////
// astro_sprite_data.asm
// File with the actual sprite data
#importonce

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
    .byte $00,$0a,$00,$00,$2a,$80,$00,$aa
    .byte $80,$00,$aa,$80,$0e,$aa,$a0,$3a
    .byte $aa,$a0,$2a,$aa,$a0,$2a,$aa,$a8
    .byte $2a,$aa,$a8,$2a,$aa,$a8,$2a,$aa
    .byte $b8,$0a,$aa,$a8,$0a,$aa,$e8,$0a
    .byte $aa,$ac,$0a,$ae,$a0,$02,$ba,$b0
    .byte $02,$aa,$80,$02,$a0,$c0,$00,$c0
    .byte $00,$00,$00,$00,$00,$00,$00,$82
/*    
    .byte $00,$3f,$00,$00,$7f,$80,$00,$ff
    .byte $c0,$00,$ff,$c0,$1f,$ff,$c0,$3f
    .byte $ff,$e0,$7f,$ff,$fc,$7f,$ff,$fe
    .byte $7f,$ff,$fe,$7f,$ff,$fe,$3f,$ff
    .byte $fe,$1f,$ff,$fe,$1f,$ff,$fc,$1f
    .byte $ff,$fc,$1f,$ff,$f8,$1f,$ff,$f8
    .byte $1f,$ff,$f0,$0f,$f1,$c0,$0f,$e0
    .byte $80,$03,$c0,$00,$00,$00,$00,$0f
*/
sprite_asteroid_2:
    // saved from spritemate:
    // sprite 2 / singlecolor / color: $0f
sprite_2:
    .byte $00,$0a,$00,$00,$2a,$80,$00,$aa
    .byte $80,$00,$aa,$80,$0e,$aa,$a0,$3a
    .byte $aa,$a0,$2a,$aa,$a0,$2a,$aa,$a8
    .byte $2a,$aa,$a8,$2a,$aa,$a8,$2a,$aa
    .byte $b8,$0a,$aa,$a8,$0a,$aa,$e8,$0a
    .byte $aa,$ac,$0a,$ae,$a0,$02,$ba,$b0
    .byte $02,$aa,$80,$02,$a0,$c0,$00,$c0
    .byte $00,$00,$00,$00,$00,$00,$00,$89
/*
    .byte $00,$3f,$00,$00,$7f,$80,$00,$ff
    .byte $c0,$00,$ff,$c0,$1f,$ff,$c0,$3f
    .byte $ff,$e0,$7f,$ff,$fc,$7f,$ff,$fe
    .byte $7f,$ff,$fe,$7f,$ff,$fe,$3f,$ff
    .byte $fe,$1f,$ff,$fe,$1f,$ff,$fc,$1f
    .byte $ff,$fc,$1f,$ff,$f8,$1f,$ff,$f8
    .byte $1f,$ff,$f0,$0f,$f1,$c0,$0f,$e0
    .byte $80,$03,$c0,$00,$00,$00,$00,$0d
*/
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


/*
The throbbing hole attempt

sprite_hole_0:
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$28,$00,$00,$be,$00,$00,$d7
    .byte $00,$00,$be,$00,$00,$28,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$8b

sprite_hole_1:
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$28,$00,$00,$82,$00
    .byte $02,$28,$80,$00,$be,$00,$02,$d7
    .byte $80,$00,$be,$00,$02,$28,$80,$00
    .byte $82,$00,$00,$28,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$8b

sprite_hole_2:
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$28,$00,$00,$82,$00
    .byte $02,$3c,$80,$00,$ff,$00,$02,$d7
    .byte $80,$00,$ff,$00,$02,$3c,$80,$00
    .byte $82,$00,$00,$28,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$8b

sprite_hole_3:
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$2a,$00,$02,$bb,$80,$0b
    .byte $00,$a0,$28,$28,$38,$30,$be,$08
    .byte $82,$ff,$82,$23,$ff,$cc,$b2,$d7
    .byte $8a,$23,$ff,$cc,$82,$ff,$82,$30
    .byte $be,$08,$28,$28,$38,$0b,$00,$a0
    .byte $02,$bb,$80,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$8c

sprite_hole_4:
    .byte $00,$08,$00,$80,$2e,$00,$3c,$3e
    .byte $02,$0f,$2e,$aa,$0f,$bb,$be,$0b
    .byte $ff,$fc,$0a,$ee,$ec,$0d,$bb,$78
    .byte $2e,$7d,$f0,$bb,$eb,$b0,$fe,$41
    .byte $e8,$bb,$eb,$be,$2e,$7d,$ee,$0d
    .byte $bb,$7f,$0b,$ee,$f0,$0b,$ba,$f0
    .byte $2f,$fe,$f0,$3c,$b8,$b8,$b0,$b8
    .byte $38,$80,$20,$0a,$00,$20,$02,$8c
*/


/*  
the spidery galaxy attempt

// sprite 2 / multicolor / color: $0b
sprite_galaxy_0:
.byte $00,$00,$00,$00,$e0,$00,$02,$38
.byte $00,$00,$0e,$00,$00,$03,$80,$0b
.byte $c0,$c0,$2c,$b0,$c0,$30,$20,$20
.byte $a0,$28,$30,$80,$aa,$b2,$80,$82
.byte $02,$0e,$aa,$03,$0c,$28,$02,$08
.byte $08,$0e,$0b,$0e,$38,$03,$03,$a0
.byte $02,$e0,$c0,$00,$38,$00,$00,$0e
.byte $00,$00,$02,$00,$00,$00,$00,$8c

// sprite 3 / multicolor / color: $0b
sprite_galaxy_1:
.byte $00,$00,$00,$00,$0a,$00,$00,$02
.byte $80,$00,$00,$20,$00,$b8,$30,$03
.byte $ce,$20,$0b,$0f,$30,$2c,$03,$20
.byte $b0,$ea,$30,$83,$ea,$20,$0b,$82
.byte $c0,$0c,$ab,$02,$00,$ab,$08,$0c
.byte $c0,$2c,$0c,$3a,$b0,$0c,$0f,$c0
.byte $02,$80,$20,$00,$c2,$a0,$00,$ab
.byte $00,$00,$0c,$00,$00,$00,$00,$8c

// sprite 4 / multicolor / color: $0b
sprite_galaxy_2:
.byte $00,$08,$00,$00,$02,$00,$00,$03
.byte $80,$00,$00,$80,$02,$b0,$20,$0b
.byte $cc,$20,$2c,$03,$08,$a0,$f0,$c0
.byte $c3,$28,$cc,$0c,$a2,$08,$20,$8a
.byte $0a,$33,$a8,$32,$a2,$28,$c3,$c3
.byte $0f,$0a,$82,$c0,$2c,$02,$b0,$e0
.byte $00,$af,$a0,$00,$2a,$80,$00,$0a
.byte $00,$00,$00,$00,$00,$00,$00,$8c

// sprite 5 / multicolor / color: $0b
sprite_galaxy_3:
.byte $08,$00,$00,$00,$80,$00,$00,$0c
.byte $00,$00,$08,$00,$00,$0e,$00,$03
.byte $c3,$82,$0e,$b0,$e0,$28,$2c,$e2
.byte $b0,$28,$30,$e3,$aa,$32,$ce,$82
.byte $32,$8a,$ab,$e3,$0e,$2b,$82,$8c
.byte $30,$0e,$0a,$30,$38,$8e,$2c,$e0
.byte $0b,$0f,$80,$02,$82,$00,$00,$e0
.byte $20,$00,$3b,$00,$00,$0c,$00,$8c
*/

////////////////////////
// sprite_hole_x are the animated sprites to use for the 
// blackhole effect.  the first two sprites show the hole
// growing and the last 3 sprites are full sized hole rotating.
// the last three sprites should continue to loop for the
// lifetime of the hole.  the sequence is:
// sprite_hole_0
// sprite_hole_1
// sprite_hole_2
// sprite_hole_3
// sprite_hole_4
// sprite_hole_2
// sprite_hole_3
// sprite_hole_4
// sprite_hole_2
// etc

// multicolor / color: $0c
sprite_hole_0:
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$0c,$00,$08,$08,$20,$0e
.byte $2e,$b0,$0b,$ae,$e0,$03,$fb,$e0
.byte $0b,$ff,$a0,$0b,$d7,$80,$2f,$41
.byte $80,$0b,$d7,$e0,$0e,$ff,$f8,$03
.byte $bb,$80,$03,$ee,$e0,$0b,$ba,$c0
.byte $0f,$fe,$c0,$20,$b8,$b0,$00,$20
.byte $20,$00,$00,$00,$00,$00,$00,$8c

// multicolor / color: $0c
sprite_hole_1:
.byte $00,$00,$00,$00,$0a,$00,$2c,$2e
.byte $00,$2f,$2e,$00,$0f,$bb,$28,$0b
.byte $ff,$fc,$0a,$ee,$e8,$03,$bb,$f0
.byte $0f,$7d,$f0,$2a,$eb,$b0,$3e,$41
.byte $e0,$2b,$eb,$b0,$0e,$7d,$f8,$03
.byte $bb,$b8,$0b,$ee,$e0,$0b,$ba,$c0
.byte $0f,$fe,$f0,$2c,$b8,$b0,$20,$30
.byte $08,$00,$00,$00,$00,$00,$00,$8c

// multicolor / color: $0c
sprite_hole_2:
.byte $00,$08,$00,$80,$2e,$00,$3c,$3e
.byte $02,$0f,$2e,$aa,$0f,$bb,$be,$0b
.byte $ff,$fc,$0a,$ee,$ec,$0d,$bb,$78
.byte $2e,$7d,$f0,$bb,$eb,$b0,$fe,$41
.byte $e8,$bb,$eb,$be,$2e,$7d,$ee,$0d
.byte $bb,$7f,$0b,$ee,$f0,$0b,$ba,$f0
.byte $2f,$fe,$f0,$3c,$b8,$b8,$b0,$b8
.byte $38,$80,$20,$0a,$00,$20,$02,$8c

// multicolor / color: $0c
sprite_hole_3:
.byte $2c,$03,$c0,$0e,$0b,$00,$0e,$0f
.byte $00,$0f,$0e,$80,$0f,$bb,$8b,$0b
.byte $ff,$fe,$0a,$ee,$f8,$ee,$7b,$f8
.byte $fe,$7d,$70,$bb,$eb,$f8,$2e,$41
.byte $e0,$0b,$eb,$b0,$01,$7d,$f8,$0e
.byte $b9,$fa,$0b,$ee,$fe,$2f,$ba,$c3
.byte $bf,$fe,$e0,$e0,$a2,$e0,$80,$a2
.byte $f0,$00,$c0,$b0,$02,$c0,$b0,$8c

// multicolor / color: $0c
sprite_hole_4:
.byte $00,$f0,$28,$02,$c0,$bc,$82,$c2
.byte $f0,$e3,$e2,$a0,$bb,$fb,$80,$3b
.byte $ff,$c0,$0a,$ee,$ee,$2e,$db,$ff
.byte $0e,$7d,$f8,$0b,$eb,$70,$0e,$41
.byte $e8,$09,$eb,$b0,$c3,$7d,$f8,$fe
.byte $b7,$b0,$bf,$ee,$f8,$2f,$ba,$fc
.byte $0b,$fe,$ee,$0f,$82,$ce,$0e,$83
.byte $cb,$2c,$03,$80,$2c,$03,$00,$8c
