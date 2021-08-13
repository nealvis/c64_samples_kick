// astro_turret_data
#importonce

#import "../nv_c64_util/nv_color_macs.asm"
#import "../nv_c64_util/nv_screen_rect_macs.asm"
#import "../nv_c64_util/nv_screen_macs.asm"
#import "astro_turret_1_data.asm"
#import "astro_turret_2_data.asm"
#import "astro_turret_3_data.asm"
#import "astro_turret_4_data.asm"
#import "astro_turret_5_data.asm"
#import "astro_turret_6_data.asm"


/////////////////
// turret IDs to pass when subroutines require an ID
.const TURRET_1_ID = $01
.const TURRET_2_ID = $02
.const TURRET_3_ID = $04
.const TURRET_4_ID = $08
.const TURRET_5_ID = $10
.const TURRET_6_ID = $20
.const TURRET_ALL_ID = $FF

// the base column is the most right column
// the gun column is the col immediatelly to the left of that
.const TURRET_BASE_COLOR = NV_COLOR_RED
.const TURRET_GUN_COLOR = NV_COLOR_LITE_RED

.const TURRET_BASE_TOP_CHAR = 248
.const TURRET_BASE_BOTTOM_CHAR = 249
.const TURRET_BASE_MIDDLE_CHAR = 160
.const TURRET_GUN_TOP_CHAR = 254
.const TURRET_GUN_BOTTOM_CHAR = 251


turret_base_color_addr_list:
    .word nv_screen_color_addr_from_yx(9, 39)
    .word nv_screen_color_addr_from_yx(10, 39)
    .word nv_screen_color_addr_from_yx(11, 39)
    .word nv_screen_color_addr_from_yx(12, 39)
    .word nv_screen_color_addr_from_yx(13, 39)
    .word nv_screen_color_addr_from_yx(14, 39)
    .word nv_screen_color_addr_from_yx(15, 39)
    .word $FFFF

turret_gun_color_addr_list:
    .word nv_screen_color_addr_from_yx(10, 38)
    .word nv_screen_color_addr_from_yx(11, 38)
    .word nv_screen_color_addr_from_yx(13, 38)
    .word nv_screen_color_addr_from_yx(14, 38)
    .word $FFFF

turret_init_stream:
        // set the color of the chars for turret base
        .word $FFFF                     // stream command marker
        .byte $01, TURRET_BASE_COLOR    // new source byte is the bullet char
        .word $FFFF
        .byte $03
        .word turret_base_color_addr_list

        // set the color for the gun part of turret
        .word $FFFF
        .byte $01, TURRET_GUN_COLOR
        .word $FFFF
        .byte $03
        .word turret_gun_color_addr_list

        // char for the turret base top
        .word $FFFF
        .byte $01, TURRET_BASE_TOP_CHAR
        .word nv_screen_char_addr_from_yx(9, 39)

        // char for turret base bottom
        .word $FFFF
        .byte $01, TURRET_BASE_BOTTOM_CHAR
        .word nv_screen_char_addr_from_yx(15, 39)

        // chars for turret base middle section
        .word $FFFF
        .byte $01, TURRET_BASE_MIDDLE_CHAR
        .word nv_screen_char_addr_from_yx(10, 39)
        .word nv_screen_char_addr_from_yx(11, 39)
        .word nv_screen_char_addr_from_yx(12, 39)
        .word nv_screen_char_addr_from_yx(13, 39)
        .word nv_screen_char_addr_from_yx(14, 39)

        // chars for turret gun top halves
        .word $FFFF
        .byte $01, TURRET_GUN_TOP_CHAR
        .word nv_screen_char_addr_from_yx(13, 38)
        .word nv_screen_char_addr_from_yx(10, 38)

        // chars for turret gun bottom halves
        .word $FFFF
        .byte $01, TURRET_GUN_BOTTOM_CHAR
        .word nv_screen_char_addr_from_yx(14, 38)
        .word nv_screen_char_addr_from_yx(11, 38)

        .word $FFFF
        .byte $FF




