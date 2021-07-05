// This assembler file defines colors for the C64

#importonce

#if !NV_C64_UTIL_DATA
.error "Error - nv_color_macs.asm: NV_C64_UTIL_DATA not defined.  Import nv_c64_util_data.asm"
#endif

// the #if above doesn't seem to always work so..
// if data hasn't been imported yet, import it into default location
#importif !NV_C64_UTIL_DATA "nv_c64_util_default_data.asm"


// c64 colors
.const NV_COLOR_BLACK = $00
.const NV_COLOR_WHITE = $01
.const NV_COLOR_RED = $02
.const NV_COLOR_CYAN = $03
.const NV_COLOR_PURPLE = $04
.const NV_COLOR_GREEN = $05
.const NV_COLOR_BLUE = $06
.const NV_COLOR_YELLOW = $07
.const NV_COLOR_ORANGE = $08
.const NV_COLOR_BROWN = $09
.const NV_COLOR_LITE_RED = $0a
.const NV_COLOR_DARK_GREY = $0b
.const NV_COLOR_GREY = $0c
.const NV_COLOR_LITE_GREEN = $0d
.const NV_COLOR_LITE_BLUE = $0e
.const NV_COLOR_LITE_GREY = $0f
.const NV_COLOR_FIRST = NV_COLOR_BLACK
.const NV_COLOR_LAST = NV_COLOR_LITE_GREY