// astro_wind_glimmer_code.asm 
#importonce 

#import "../nv_c64_util/nv_c64_util_macs_and_data.asm"
#import "astro_wind_glimmer_data.asm"
#import "../nv_c64_util/nv_screen_code.asm"
#import "astro_vars_data.asm"
#import "astro_stream_processor_macs.asm"
#import "astro_stream_processor_code.asm"

.const WIND_GLIMMER_DARKEN_COLOR = NV_COLOR_GREY

//////////////////////////////////////////////////////////////////////////////
// subroutine to call once before using wind glimmer
WindGlimmerInit:
    lda #0
    sta wind_glimmer_count
    rts

//////////////////////////////////////////////////////////////////////////////
// subroutine to call to start the glimmering
WindGlimmerStart:
    lda #WIND_GLIMMER_FRAMES
    sta wind_glimmer_count
    rts


//////////////////////////////////////////////////////////////////////////////
// subroutine to call once before using wind glimmer
WindGlimmerForceStop:
    lda #0
    sta wind_glimmer_count
    rts
// WindGlimmerForceStop - end
///////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// subroutine to call to step glimmer effect
WindGlimmerStep:
    astro_effect_step_sr(AstroStreamProcessor, wind_glimmer_count, 
                         WIND_GLIMMER_FRAMES, WindGlimmerStreamAddrTable)

