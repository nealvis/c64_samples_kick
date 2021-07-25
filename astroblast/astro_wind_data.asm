// astro_wind_data
#importonce
#import "../nv_c64_util/nv_color_macs.asm"

wind_glimmer_count: .byte $FF

wind_step0_point_list_with_color_char: .byte NV_COLOR_WHITE // white color
wind_step0_point_list_with_char:       .byte $3A            // colon char
wind_step0_point_list_addr: .byte 37, 1     // x, y ie col, row
                            .byte 38, 3
                            .byte 36, 5
                            .byte 38, 7
                            .byte 39, 9
                            .byte 38, 11
                            .byte 37, 12
                            .byte 35, 15
                            .byte 37, 18
                            .byte 38, 21
                            .byte 36, 24
                            .byte $FF

wind_step1_point_list_with_color_char: .byte NV_COLOR_WHITE // white color
wind_step1_point_list_with_char:       .byte $46            // line lowest char
wind_step1_point_list_addr: .byte 33, 1
                            .byte 31, 3
                            .byte 32, 5
                            .byte 34, 9
                            .byte 32, 12
                            .byte 30, 14
                            .byte 32, 18
                            .byte 33, 21
                            .byte 31, 23
                            .byte $FF

wind_step2_point_list_with_color_char: .byte NV_COLOR_WHITE // white color
wind_step2_point_list_with_char:       .byte $43            // line low char
wind_step2_point_list_addr: .byte 28, 3
                            .byte 26, 5
                            .byte 29, 9
                            .byte 26, 12
                            .byte 25, 14
                            .byte 27, 18
                            .byte 27, 21
                            .byte 26, 22
                            .byte $FF

wind_step3_point_list_with_color_char: .byte NV_COLOR_WHITE // white color
wind_step3_point_list_with_char:       .byte $2D // $44            // line mid char
wind_step3_point_list_addr: .byte 24, 3
                            .byte 22, 5
                            .byte 24, 9
                            .byte 20, 12
                            .byte 21, 14
                            .byte 24, 18
                            .byte 23, 21
                            .byte 20, 21
                            .byte $FF

wind_step4_point_list_with_color_char: .byte NV_COLOR_WHITE // white color
wind_step4_point_list_with_char:       .byte $2D //$45            // line high char
wind_step4_point_list_addr: .byte 19, 3
                            .byte 18, 9
                            .byte 15, 12
                            .byte 16, 14
                            .byte 19, 20
                            .byte 16, 22
                            .byte $FF
wind_step5_point_list_with_color_char: .byte NV_COLOR_WHITE // white color
wind_step5_point_list_with_char:       .byte $2E            // dash lowest char
wind_step5_point_list_addr: .byte 13, 3
                            .byte 12, 9
                            .byte 10, 12
                            .byte 11, 14
                            .byte 13, 21
                            .byte 12, 23
                            .byte $FF
