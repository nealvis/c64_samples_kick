// astro_wind_glimmer_code.asm 
#importonce 

#import "../nv_c64_util/nv_c64_util_macs_and_data.asm"
#import "astro_wind_glimmer_data.asm"
#import "../nv_c64_util/nv_screen_code.asm"
#import "astro_vars_data.asm"

.const WIND_GLIMMER_DARKEN_COLOR = NV_COLOR_LITE_GREY

//////////////////////////////////////////////////////////////////////////////
// subroutine to call once before using wind glimmer
WindGlimmerInit:
    // don't start with wind glimmer.  neg value means not active
    lda #$FF
    sta wind_glimmer_count
    rts

//////////////////////////////////////////////////////////////////////////////
// subroutine to call to start the glimmering
WindGlimmerStart:
    lda #0
    sta wind_glimmer_count
    rts

//////////////////////////////////////////////////////////////////////////////
// subroutine to call once every time the glimmer effect should be advanced
// call it more often for faster effect or less often for slower
WindGlimmerStep:
    lda wind_glimmer_count 
    bpl WindGlimmerActive
    jmp WindGlimmerReturn
WindGlimmerActive:
    bne WindGlimmerStep1Check
    jmp WindGlimmerDoStep0

WindGlimmerStep1Check:
    cmp #1 
    bne WindGlimmerStep2Check
    jmp WindGlimmerDoStep1

WindGlimmerStep2Check:
    cmp #2 
    bne WindGlimmerStep3Check
    jmp WindGlimmerDoStep2

WindGlimmerStep3Check:
    cmp #3 
    bne WindGlimmerStep4Check
    jmp WindGlimmerDoStep3

WindGlimmerStep4Check:
    cmp #4 
    bne WindGlimmerStep5Check
    jmp WindGlimmerDoStep4


WindGlimmerStep5Check:
    cmp #5 
    bne WindGlimmerStep6Check
    jmp WindGlimmerDoStep5

WindGlimmerStep6Check:
    cmp #6
    bne WindGlimmerStep7Check
    jmp WindGlimmerDoStep6

WindGlimmerStep7Check:
    lda #$FF
    sta wind_glimmer_count
    jmp WindGlimmerReturn

WindGlimmerDoStep0:
    ldx #<wind_step0_point_list_with_color_char
    ldy #>wind_step0_point_list_with_color_char
    jsr NvScreenPokeCoordList
    jmp WindGlimmerDone

WindGlimmerDoStep1:
    // first darken out the step 0 chars
    lda #WIND_GLIMMER_DARKEN_COLOR
    ldx #<wind_step0_point_list_addr
    ldy #>wind_step0_point_list_addr
    jsr NvScreenPokeColorToCoordList_axy

    // poke step 1 chars and colors
    ldx #<wind_step1_point_list_with_color_char
    ldy #>wind_step1_point_list_with_color_char
    jsr NvScreenPokeCoordList
    jmp WindGlimmerDone

WindGlimmerDoStep2:
    // first blackout out the step 0 chars
    lda background_color
    ldx #<wind_step0_point_list_addr
    ldy #>wind_step0_point_list_addr
    jsr NvScreenPokeColorToCoordList_axy

    // darken the step 1 chars
    lda #WIND_GLIMMER_DARKEN_COLOR
    ldx #<wind_step1_point_list_addr
    ldy #>wind_step1_point_list_addr
    jsr NvScreenPokeColorToCoordList_axy

    // poke step 2 chars and colors
    ldx #<wind_step2_point_list_with_color_char
    ldy #>wind_step2_point_list_with_color_char
    jsr NvScreenPokeCoordList
    jmp WindGlimmerDone

WindGlimmerDoStep3:

    // blackout the step 1 chars
    lda background_color
    ldx #<wind_step1_point_list_addr
    ldy #>wind_step1_point_list_addr
    jsr NvScreenPokeColorToCoordList_axy

    // darken the step 2 chars
    lda #WIND_GLIMMER_DARKEN_COLOR
    ldx #<wind_step2_point_list_addr
    ldy #>wind_step2_point_list_addr
    jsr NvScreenPokeColorToCoordList_axy

    // poke step 3 chars and colors
    ldx #<wind_step3_point_list_with_color_char
    ldy #>wind_step3_point_list_with_color_char
    jsr NvScreenPokeCoordList
    jmp WindGlimmerDone

WindGlimmerDoStep4:
    // blackout the step 2 chars
    lda background_color
    ldx #<wind_step2_point_list_addr
    ldy #>wind_step2_point_list_addr
    jsr NvScreenPokeColorToCoordList_axy

    // darken the step 3 chars
    lda #WIND_GLIMMER_DARKEN_COLOR
    ldx #<wind_step3_point_list_addr
    ldy #>wind_step3_point_list_addr
    jsr NvScreenPokeColorToCoordList_axy

    // poke step 4 chars and colors
    ldx #<wind_step4_point_list_with_color_char
    ldy #>wind_step4_point_list_with_color_char
    jsr NvScreenPokeCoordList
    jmp WindGlimmerDone

WindGlimmerDoStep5:
    // blackout the step 3 chars
    lda background_color
    ldx #<wind_step3_point_list_addr
    ldy #>wind_step3_point_list_addr
    jsr NvScreenPokeColorToCoordList_axy

    // darken the step 4 chars
    lda #WIND_GLIMMER_DARKEN_COLOR
    ldx #<wind_step4_point_list_addr
    ldy #>wind_step4_point_list_addr
    jsr NvScreenPokeColorToCoordList_axy

    // poke step 5 chars and colors
    ldx #<wind_step5_point_list_with_color_char
    ldy #>wind_step5_point_list_with_color_char
    jsr NvScreenPokeCoordList
    jmp WindGlimmerDone

WindGlimmerDoStep6:
    // blackout the step 4 chars
    lda background_color
    ldx #<wind_step4_point_list_addr
    ldy #>wind_step4_point_list_addr
    jsr NvScreenPokeColorToCoordList_axy

    // blank out step 5 list
    lda background_color
    ldx #<wind_step5_point_list_addr
    ldy #>wind_step5_point_list_addr
    jsr NvScreenPokeColorToCoordList_axy
    jmp WindGlimmerDone


WindGlimmerDone:
    inc wind_glimmer_count
WindGlimmerReturn:
    rts

//////////////////////////////////////////////////////////////////////////////
// subroutine to call once before using wind glimmer
WindGlimmerForceStop:
    // don't start with wind glimmer.  neg value means not active
    lda #$FF
    sta wind_glimmer_count
    rts