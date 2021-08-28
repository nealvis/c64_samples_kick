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
    .byte $02,$28,$80,$08,$b3,$20,$23,$08
    .byte $c8,$08,$00,$20,$30,$00,$0c,$80
    .byte $be,$02,$22,$ff,$80,$c3,$ff,$e3
    .byte $0b,$ff,$e0,$8f,$d7,$f2,$0b,$c3
    .byte $e0,$cf,$d7,$f3,$0b,$ff,$e0,$8b
    .byte $ff,$e2,$02,$ff,$80,$c0,$be,$03
    .byte $20,$00,$08,$0c,$00,$30,$22,$08
    .byte $88,$08,$33,$20,$02,$88,$80,$8c

/*
    .byte $00,$aa,$00,$02,$00,$80,$08,$00
    .byte $20,$20,$00,$08,$00,$aa,$00,$82
    .byte $00,$82,$08,$28,$20,$20,$be,$08
    .byte $02,$ff,$80,$23,$ff,$c8,$22,$d7
    .byte $88,$23,$ff,$c8,$02,$ff,$80,$20
    .byte $be,$08,$08,$28,$20,$82,$00,$82
    .byte $00,$aa,$00,$20,$00,$08,$08,$00
    .byte $20,$02,$00,$80,$00,$aa,$00,$8b
*/
