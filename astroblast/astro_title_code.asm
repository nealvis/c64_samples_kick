//////////////////////////////////////////////////////////////////////////////
// astro_title_code.asm
//////////////////////////////////////////////////////////////////////////////
// The following subroutines should be called from the main engine
// as follows
// TitleStart: call to show title screen
//////////////////////////////////////////////////////////////////////////////

#importonce 
#import "../nv_c64_util/nv_c64_util_macs_and_data.asm"
#import "astro_vars_data.asm"

/*
#import "../nv_c64_util/nv_screen_macs.asm"
#import "../nv_c64_util/nv_screen_rect_macs.asm"
#import "../nv_c64_util/nv_pointer_macs.asm"
#import "../nv_c64_util/nv_debug_macs.asm"
#import "../nv_c64_util/nv_math16_macs.asm"
*/
#import "astro_starfield_code.asm"
#import "astro_keyboard_macs.asm"
#import "astro_sound.asm"
#import "astro_stream_processor_code.asm"
#import "astro_ships_code.asm"

//#import "../nv_c64_util/nv_debug_code.asm"
astro_title_str:     .text @"     astroblast \$00"

title_quit_str:        .text @" q key .. quit\$00"
title_play_str:        .text @" space .. play\$00"
title_vol_up_str:      .text @" < key .. vol down\$00"
title_vol_down_str:    .text @" > key .. vol up\$00"
title_easy_mode_str:   .text @" 1 key .. easy\$00"
title_med_mode_str:    .text @" 2 key .. med\$00"
title_hard_mode_str:   .text @" 3 key .. hard\$00"
title_time_based_str:  .text @" t key .. len=time\$00"
title_score_based_str: .text @" s key .. len=score\$00"
title_plus_str:     .text @" \$40 key .. longer\$00"
title_minus_str:    .text @" \$5b key .. shorter\$00"
title_game_len_str:    .text @" len   ..\$00"
title_blank4_str:      .text @"    "


play_flag: .byte $00

.const TITLE_KEY_COOL_DURATION = $08
.const TITLE_RECT_WIDTH = 20
.const TITLE_RECT_HEIGHT = 19
.const TITLE_ROW_START = 3
.const TITLE_COL_START = NV_SCREEN_CHARS_PER_ROW/2 -(TITLE_RECT_WIDTH/2) 

.const TRS = TITLE_ROW_START
.const TCS = TITLE_COL_START
.const TCPR = NV_SCREEN_CHARS_PER_ROW
.const TITLE_RECT_TOP_CHAR = 82

.const TITLE_MIN_GAME_LEN = $0010
.const TITLE_MAX_GAME_LEN = $0200
.const TITLE_GAME_LEN_INC_DEC = $0010

.const TITLE_INDICATOR_CHAR = 65

.var index

title_rect_top_char_addr_list:
    .for (index = 0; index < TITLE_RECT_WIDTH; index = index+1)
    {
        .word nv_screen_char_addr_from_yx((TRS + 0), TCS + index)
    }
    .word $FFFF

title_rect_bottom_char_addr_list:
    .for (index = 0; index < TITLE_RECT_WIDTH; index = index+1)
    {
        .word nv_screen_char_addr_from_yx((TRS + TITLE_RECT_HEIGHT-1), TCS + index)
    }
    .word $FFFF

.const TITLE_RECT_COLOR_FIRST = nv_screen_color_addr_from_yx((TRS + 0), TCS + 0)
.const TITLE_RECT_COLOR_LAST = nv_screen_color_addr_from_yx((TRS + TITLE_RECT_HEIGHT), TCS + TITLE_RECT_WIDTH)

title_rect_stream:
    // set top rect char
    .word $FFFF
    .byte $01, TITLE_RECT_TOP_CHAR

    // poke the rect top chars
    .word $FFFF
    .byte $03                   // destination list
    .word title_rect_top_char_addr_list

    // poke the rect bottom chars
    .word $FFFF
    .byte $03                   // destination list
    .word title_rect_bottom_char_addr_list

    // poke the colors of the rect
    .word $FFFF
    .byte $01, NV_COLOR_WHITE

    //.word $FFFF
    //.byte $04                               // destination block command
    //.word TITLE_RECT_COLOR_FIRST
    //.word TITLE_RECT_COLOR_FIRST + TITLE_RECT_WIDTH
    
    .word $FFFF
    .byte $04                               // destination block command
    .word TITLE_RECT_COLOR_FIRST+(NV_SCREEN_CHARS_PER_ROW * 0)
    .word TITLE_RECT_COLOR_FIRST+(NV_SCREEN_CHARS_PER_ROW * 0) + TITLE_RECT_WIDTH

    .word $FFFF
    .byte $04                               // destination block command
    .word TITLE_RECT_COLOR_FIRST+(NV_SCREEN_CHARS_PER_ROW * (TITLE_RECT_HEIGHT-1))
    .word TITLE_RECT_COLOR_FIRST+(NV_SCREEN_CHARS_PER_ROW * (TITLE_RECT_HEIGHT-1)) + TITLE_RECT_WIDTH


    // stream done
    .word $FFFF
    .byte $FF

//////////////////////////////////////////////////////////////////////////////
// call once to initialize starfield variables and stuff
// must call the following before calling this
//   nv_key_init
//   SoundInit
TitleStart:
{
    nv_screen_clear()

    lda #$00
    sta play_flag

    jsr StarInit
    jsr StarStart

    // set up ship 1 to rotate around the top of the screen
    nv_store16_immediate(ship_1.x_loc, 50)
    lda #52
    sta ship_1.y_loc
    lda #0
    sta ship_1.y_vel
    lda #2 
    sta ship_1.x_vel
    jsr ship_1.Enable

    // set up ship 2 to rotate around the bottom of the screen
    nv_store16_immediate(ship_2.x_loc, 50)
    lda #226
    sta ship_2.y_loc
    lda #0
    sta ship_2.y_vel
    lda #2 
    sta ship_2.x_vel
    jsr ship_2.SetColorAlive
    jsr ship_2.Enable



TitleLoop:
    nv_sprite_wait_last_scanline()         // wait for particular scanline.
    SoundDoStep()
    jsr ship_1.SetLocationFromExtraData
    jsr ship_2.SetLocationFromExtraData
    jsr StarStep

    ldx #<title_rect_stream
    ldy #>title_rect_stream
    jsr AstroStreamProcessor

    .var poke_row = TITLE_ROW_START + 1
    nv_screen_poke_color_str(poke_row++, TITLE_COL_START, NV_COLOR_WHITE, astro_title_str)
    .eval poke_row = poke_row + 1
    nv_screen_poke_color_str(poke_row++, TITLE_COL_START, NV_COLOR_WHITE, title_play_str)
    nv_screen_poke_color_str(poke_row++, TITLE_COL_START, NV_COLOR_WHITE, title_quit_str)
    nv_screen_poke_color_str(poke_row++, TITLE_COL_START, NV_COLOR_WHITE, title_vol_up_str)
    nv_screen_poke_color_str(poke_row++, TITLE_COL_START, NV_COLOR_WHITE, title_vol_down_str)
    .eval poke_row++
    .var easy_mode_row = poke_row
    nv_screen_poke_color_str(poke_row++, TITLE_COL_START, NV_COLOR_WHITE, title_easy_mode_str)
    nv_screen_poke_color_str(poke_row++, TITLE_COL_START, NV_COLOR_WHITE, title_med_mode_str)
    nv_screen_poke_color_str(poke_row++, TITLE_COL_START, NV_COLOR_WHITE, title_hard_mode_str)

    lda #TITLE_INDICATOR_CHAR
    ldx background_color
    nv_screen_poke_color_char_xa(easy_mode_row, TITLE_COL_START)
    nv_screen_poke_color_char_xa(easy_mode_row+1, TITLE_COL_START)
    nv_screen_poke_color_char_xa(easy_mode_row+2, TITLE_COL_START)

    lda #NV_COLOR_YELLOW
    ldy astro_diff_mode
TryAstroEasyMode:
    cpy #ASTRO_DIFF_EASY
    bne TryAstroMedMode
IsAstroEasyMode:
    nv_screen_poke_color_a(easy_mode_row, TITLE_COL_START)
    jmp DoneAstroDiffMode

TryAstroMedMode:
    cpy #ASTRO_DIFF_MED
    bne TryAstroHardMode
IsAstroMedMode:
    nv_screen_poke_color_a(easy_mode_row+1, TITLE_COL_START)
    jmp DoneAstroDiffMode

TryAstroHardMode:
    // assume its hard mode if get here
IsAstroHardMode:
        nv_screen_poke_color_a(easy_mode_row+2, TITLE_COL_START)


DoneAstroDiffMode:
    .eval poke_row++
    nv_screen_poke_color_str(poke_row++, TITLE_COL_START, NV_COLOR_WHITE, title_game_len_str)
    nv_screen_poke_color_str((poke_row-1), TITLE_COL_START+10, NV_COLOR_CYAN, title_blank4_str)

    // game length
    nv_screen_poke_hex_word_mem((poke_row-1), TITLE_COL_START+10, astro_score_to_win, false)

    // timed or score based
    .var score_based_row = poke_row
    nv_screen_poke_color_str(poke_row++, TITLE_COL_START, NV_COLOR_WHITE, title_score_based_str)
    .var timer_based_row = poke_row
    nv_screen_poke_color_str(poke_row++, TITLE_COL_START, NV_COLOR_WHITE, title_time_based_str)

    // poke indicator for timed or score based
    lda #TITLE_INDICATOR_CHAR
    ldx background_color
    nv_screen_poke_color_char_xa(score_based_row, TITLE_COL_START)
    nv_screen_poke_color_char_xa(timer_based_row, TITLE_COL_START)
    lda #NV_COLOR_YELLOW
    ldy astro_end_on_seconds
    beq TitleScoreBasedGame
TitleTimerBasedGame:
    nv_screen_poke_color_a(timer_based_row, TITLE_COL_START)
    jmp TitleTimerScoreBasedDone
TitleScoreBasedGame:
    nv_screen_poke_color_a(score_based_row, TITLE_COL_START)

TitleTimerScoreBasedDone:

    // inc/dec game len
    nv_screen_poke_color_str(poke_row++, TITLE_COL_START, NV_COLOR_WHITE, title_plus_str)
    nv_screen_poke_color_str(poke_row++, TITLE_COL_START, NV_COLOR_WHITE, title_minus_str)

    jsr ship_1.MoveInExtraData
    jsr ship_2.MoveInExtraData

    jsr TitleDoKeyboard
    lda quit_flag
    beq TitleNoQuit
    jmp TitleDone
TitleNoQuit:
    jmp TitleLoop

TitleDone:
    nv_xfer16_mem_mem(astro_score_to_win, astro_game_seconds)
    jsr StarCleanup
    lda play_flag
    beq QuitGame
PlayGame:
    lda #$00
    sta quit_flag
    lda #$01
    rts
QuitGame:
    lda #$00
    rts
}
// TitleStart end
//////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////////////////
// subroutine to do all the keyboard stuff
TitleDoKeyboard: 
{
    nv_key_scan()

    lda key_cool_counter
    beq TitleNotInCoolDown       // not in keyboard cooldown, go scan
    dec key_cool_counter    // in keyboard cooldown, dec the cntr
    jmp TitleDoneKeys            // and jmp to skip rest of routine
TitleNotInCoolDown:

    nv_key_get_last_pressed_a()     // get key pressed in accum

    cmp #NV_KEY_NO_KEY          // check if any key hit
    bne TitleHaveKey 
    jmp TitleDoneKeys                // no key hit, skip to end
TitleHaveKey:
    ldy #TITLE_KEY_COOL_DURATION      // had a key, start cooldown counter        
    sty key_cool_counter


//////
// no repeat key presses handled here, only transition keys below this line
// if its a repeat key press then we'll ignore it.
TryTransitionKeys:
    nv_key_get_prev_pressed_y() // previous key pressed to Y reg
    sty scratch_byte            // then to scratch reg to compare with accum
    cmp scratch_byte            // if prev key == last key then done with keys
    bne TitleNotDoneKeys
    jmp TitleDoneKeys 

TitleNotDoneKeys:

TryIncVolume:
    cmp #KEY_INC_VOLUME             
    bne TryDecVolume                           
WasIncVolume:
    jsr SoundVolumeUp
    jmp TitleDoneKeys                // and skip to bottom

TryDecVolume:
    cmp #KEY_DEC_VOLUME             
    bne TryDiffEasy                          
WasDecVolume:
    jsr SoundVolumeDown
    jmp TitleDoneKeys

TryDiffEasy:
    cmp #NV_KEY_1            
    bne TryDiffMed                          
WasDiffEasy:
    lda #ASTRO_DIFF_EASY
    sta astro_diff_mode
    jmp TitleDoneKeys                // and skip to bottom

TryDiffMed:
    cmp #NV_KEY_2
    bne TryDiffHard
WasDiffMed:
    lda #ASTRO_DIFF_MED
    sta astro_diff_mode
    jmp TitleDoneKeys                // and skip to bottom

TryDiffHard:
    cmp #NV_KEY_3
    bne TryPlus
WasDiffHard:
    lda #ASTRO_DIFF_HARD
    sta astro_diff_mode
    jmp TitleDoneKeys                // and skip to bottom

TryPlus:
    cmp #NV_KEY_PLUS
    bne TryMinus
WasPlus:
    nv_bge16_immediate(astro_score_to_win, TITLE_MAX_GAME_LEN-TITLE_GAME_LEN_INC_DEC, TitleGameLenSkipAdd)
    nv_bcd_adc16_immediate(astro_score_to_win, TITLE_GAME_LEN_INC_DEC, astro_score_to_win)
TitleGameLenSkipAdd:
    jmp TitleDoneKeys                // and skip to bottom

TryMinus:
    cmp #NV_KEY_MINUS
    bne TryTimedGame
WasMinus:
    nv_blt16_immediate(astro_score_to_win, TITLE_MIN_GAME_LEN+TITLE_GAME_LEN_INC_DEC, TitleGameLenSkipAdd)
    nv_bcd_sbc16_immediate(astro_score_to_win, TITLE_GAME_LEN_INC_DEC, astro_score_to_win)
TitleGameLenSkipSub:
    jmp TitleDoneKeys                // and skip to bottom

TryTimedGame:
    cmp #NV_KEY_T
    bne TryScoredGame
WasTimedGame:
    lda #1
    sta astro_end_on_seconds
    jmp TitleDoneKeys                // and skip to bottom

TryScoredGame:
    cmp #NV_KEY_S
    bne TryPlay
WasScoredGame:
    lda #0
    sta astro_end_on_seconds
    jmp TitleDoneKeys                // and skip to bottom

TryPlay:
    cmp #KEY_PLAY               
    bne TryQuit                 
WasPlay:
    lda #1                      
    sta play_flag
    sta quit_flag
    jmp TitleDoneKeys

TryQuit:
    cmp #KEY_QUIT               
    bne TitleDoneKeys           
WasQuit:
    lda #1                      
    sta quit_flag
    // fall throught to TitleDoneKeys

TitleDoneKeys:
    rts
}
// TitleDoKeyboard - end
//////////////////////////////////////////////////////////////////////////////
