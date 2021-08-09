// astro_wind_glimmer_code.asm 
#importonce 

#import "../nv_c64_util/nv_c64_util_macs_and_data.asm"
#import "astro_wind_glimmer_data.asm"
#import "../nv_c64_util/nv_screen_code.asm"
#import "astro_vars_data.asm"
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
{
    // sanity check that count isn't already zero
    lda wind_glimmer_count
    beq Done                        // if count has hit zero then done
    
    lda #WIND_GLIMMER_FRAMES        // load total num frames
    sec                             // set carry for to prep for subtraction
    sbc wind_glimmer_count      // sub cur count value to get zero based
                                    // frame count into accum
    asl                             // multiply by two since table is 16 bit addrs
    tay                             // put result in y its index to stream LSB
    lda WindGlimmerStreamAddrTable, y   // load stream LSB in Accm
    tax                                 // move LSB of stream start to x
    iny                                 // inc index point to MSB of addr in table
    lda WindGlimmerStreamAddrTable, y   // load accum with MSB of stream start
    tay                                 // move MSB of stream start to Y addr
    jsr AstroStreamProcessor      // x, and y set for this frame's stream
                                        // so jsr to stream processor

    dec wind_glimmer_count      // dec count
Done:
    rts
}

/*
//////////////////////////////////////////////////////////////////////////////
//   Accum: will change, Input: should hold the byte that will be stored 
//   X Reg: will change, Input: LSB of stream data's addr.  
//   Y Reg: will change, Input: MSB of Stream data's addr 
WindGlimmerStreamProcessor:
    nv_stream_proc_sr(wg_temp_word, wg_save_block, background_color)

wg_temp_word: .word $0000
wg_save_block: .word $0000
               .word $0000
*/