// astro_turret_data
#importonce

#import "../nv_c64_util/nv_color_macs.asm"
#import "../nv_c64_util/nv_screen_rect_macs.asm"
#import "astro_turret_1_data.asm"
#import "astro_turret_2_data.asm"
#import "astro_turret_3_data.asm"
#import "astro_turret_4_data.asm"


/////////////////
// turret IDs to pass when subroutines require an ID
.const TURRET_1_ID = $01
.const TURRET_2_ID = $02
.const TURRET_3_ID = $04
.const TURRET_4_ID = $08
.const TURRET_ALL_ID = $FF






