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

