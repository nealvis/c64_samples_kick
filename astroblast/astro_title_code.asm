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
#import "../nv_c64_util/nv_screen_macs.asm"
#import "../nv_c64_util/nv_screen_rect_macs.asm"
#import "../nv_c64_util/nv_pointer_macs.asm"
#import "../nv_c64_util/nv_stream_processor_macs.asm"
#import "../nv_c64_util/nv_debug_macs.asm"
#import "astro_stream_processor_macs.asm"
#import "astro_stream_processor_code.asm"
#import "../nv_c64_util/nv_math16_macs.asm"

#import "astro_starfield_code.asm"
#import "astro_keyboard_macs.asm"
#import "astro_sound.asm"
#import "astro_stream_processor_code.asm"

//#import "../nv_c64_util/nv_debug_code.asm"
astro_title_str:     .text @"     astroblast \$00"

title_quit_str:      .text @" q key ... quit\$00"
title_play_str:      .text @" space ... play\$00"
title_vol_up_str:    .text @" < key ... vol down\$00"
title_vol_down_str:  .text @" > key ... vol up\$00"
title_rect_top_str:  .byte 104, 104, 104, 104, 0
play_flag: .byte $00

.const TITLE_KEY_COOL_DURATION = $08
.const TITLE_RECT_WIDTH = 20
.const TITLE_RECT_HEIGHT = 9
.const TITLE_ROW_START = 6
.const TITLE_COL_START = NV_SCREEN_CHARS_PER_ROW/2 -(TITLE_RECT_WIDTH/2) 

.const TRS = TITLE_ROW_START
.const TCS = TITLE_COL_START
.const TCPR = NV_SCREEN_CHARS_PER_ROW
.const TITLE_RECT_TOP_CHAR = 82


.var index
/*
.var col_index = 0
.var row_index = 0
title_rect_all_color_addr_list:
    .for (row_index = 0; row_index<6; row_index = row_index+1)
    {
        .for (col_index = 0; col_index < TITLE_RECT_WIDTH; col_index = col_index+1)
        {
            .word nv_screen_color_addr_from_yx((TRS + row_index), TCS + col_index)
        }
    }
    .word $FFFF
*/

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

    .var row_index = 0
    .for (row_index = 0; row_index<TITLE_RECT_HEIGHT; row_index = row_index + 1)
    {
        .word $FFFF
        .byte $04                               // destination block command
        .word TITLE_RECT_COLOR_FIRST+(NV_SCREEN_CHARS_PER_ROW * row_index)
        .word TITLE_RECT_COLOR_FIRST+(NV_SCREEN_CHARS_PER_ROW * row_index) + TITLE_RECT_WIDTH
    }

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


TitleLoop:
    nv_sprite_wait_last_scanline()         // wait for particular scanline.
    SoundDoStep()
    jsr StarStep

    ldx #<title_rect_stream
    ldy #>title_rect_stream
    jsr AstroStreamProcessor

    nv_screen_poke_str(TITLE_ROW_START+1, TITLE_COL_START, astro_title_str)
    nv_screen_poke_str(TITLE_ROW_START+4, TITLE_COL_START, title_play_str)
    nv_screen_poke_str(TITLE_ROW_START+5, TITLE_COL_START, title_quit_str)
    nv_screen_poke_str(TITLE_ROW_START+6, TITLE_COL_START, title_vol_up_str)
    nv_screen_poke_str(TITLE_ROW_START+7, TITLE_COL_START, title_vol_down_str)


    jsr TitleDoKeyboard
    lda quit_flag
    beq TitleNoQuit
    jmp TitleDone
TitleNoQuit:
    jmp TitleLoop

TitleDone:
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
    bne TryPlay                          
WasDecVolume:
    jsr SoundVolumeDown
    jmp TitleDoneKeys

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

TitleDoneKeys:
    rts
}
// TitleDoKeyboard - end
//////////////////////////////////////////////////////////////////////////////
