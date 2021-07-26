// astro_wind_data
#importonce
#import "../nv_c64_util/nv_color_macs.asm"

.const CHAR_COLON = $3A
.const CHAR_LOWEST_LINE = $46
.const CHAR_LOW_LINE = $43
.const CHAR_MED_LINE = $44
.const CHAR_HIGH_LINE = $45
.const CHAR_DASH = $2D
.const CHAR_PERIOD = $2E

.const CHAR_CUSTOM_FULL = $1B // 27
.const CHAR_CUSTOM_SPARSE = $1C // 28
.const CHAR_CUSTOM_FULL_LINES = $1D // 29
.const CHAR_CUSTOM_MEDIUM = $1E   // 30


wind_glimmer_count: .byte $FF

wind_step0_point_list_with_color_char: .byte NV_COLOR_WHITE // color to poke
wind_step0_point_list_with_char:       .byte CHAR_CUSTOM_FULL     // char to poke
wind_step0_point_list_addr: .byte 37, 1     // x, y ie col, row
                            .byte 38, 3
                            .byte 37, 4
                            .byte 36, 5
                            .byte 39, 6
                            .byte 38, 7
                            .byte 39, 9
                            .byte 38, 11
                            .byte 37, 12
                            .byte 35, 15
                            .byte 36, 17
                            .byte 37, 18
                            .byte 36, 19
                            .byte 38, 21
                            .byte 36, 24
                            
                            .byte $FF

wind_step1_point_list_with_color_char: .byte NV_COLOR_WHITE // poke color
wind_step1_point_list_with_char:       .byte CHAR_CUSTOM_FULL // poke char
wind_step1_point_list_addr: .byte 33, 1
                            .byte 31, 3
                            .byte 32, 4
                            .byte 32, 5
                            .byte 33, 6
                            .byte 34, 9
                            .byte 32, 12
                            .byte 30, 14
                            .byte 32, 18
                            .byte 33, 21
                            .byte 31, 23
                            .byte $FF

wind_step2_point_list_with_color_char: .byte NV_COLOR_WHITE // poke color
wind_step2_point_list_with_char:       .byte CHAR_CUSTOM_MEDIUM  // poke char
wind_step2_point_list_addr: .byte 28, 3
                            .byte 26, 5
                            .byte 29, 9
                            .byte 26, 12
                            .byte 25, 14
                            .byte 27, 18
                            .byte 27, 21
                            .byte 26, 22
                            .byte $FF

wind_step3_point_list_with_color_char: .byte NV_COLOR_WHITE // poke color
wind_step3_point_list_with_char:       .byte CHAR_CUSTOM_SPARSE      // poke char
wind_step3_point_list_addr: .byte 24, 3
                            .byte 22, 5
                            .byte 24, 9
                            .byte 20, 12
                            .byte 21, 14
                            .byte 24, 18
                            .byte 23, 21
                            .byte 20, 21
                            .byte $FF

wind_step4_point_list_with_color_char: .byte NV_COLOR_WHITE // Poke color
wind_step4_point_list_with_char:       .byte CHAR_CUSTOM_SPARSE      // Poke char
wind_step4_point_list_addr: .byte 19, 3
                            .byte 18, 9
                            .byte 15, 12
                            .byte 16, 14
                            .byte 19, 20
                            .byte 16, 22
                            .byte $FF

wind_step5_point_list_with_color_char: .byte NV_COLOR_WHITE // poke color
wind_step5_point_list_with_char:       .byte CHAR_COLON    // poke char
wind_step5_point_list_addr: .byte 13, 3
                            .byte 12, 9
                            .byte 10, 12
                            .byte 11, 14
                            .byte 13, 21
                            .byte 12, 23
                            .byte $FF
