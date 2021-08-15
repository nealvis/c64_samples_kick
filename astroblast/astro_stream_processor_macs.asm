//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
#importonce

#import "../nv_c64_util/nv_c64_util_macs.asm"


//////////////////////////////////////////////////////////////////////////////
// TODO: add comments
.macro astro_effect_step(stream_proc_addr, effect_count_addr, 
                         effect_frames, effect_table_addr)
{
    // sanity check that count isn't already zero
    lda effect_count_addr
    beq Done                        // if count has hit zero then done
    
    lda #effect_frames              // load total num frames
    sec                             // set carry for to prep for subtraction
    sbc effect_count_addr           // sub cur count value to get zero based
                                    // frame count into accum
    asl                             // multiply by two since table is 16 bit addrs
    tay                             // put result in y its index to stream LSB
    lda effect_table_addr, y        // load stream LSB in Accm
    tax                             // move LSB of stream start to x
    iny                             // inc index point to MSB of addr in table
    lda effect_table_addr, y        // load accum with MSB of stream start
    tay                             // move MSB of stream start to Y addr
    jsr stream_proc_addr            // x, and y set for this frame's stream
                                    // so jsr to stream processor

    dec effect_count_addr            // dec count
Done:
    
}


//////////////////////////////////////////////////////////////////////////////
// TODO: add comments
.macro astro_effect_step_sr(stream_proc_addr, effect_count_addr, 
                            effect_frames, effect_table_addr)
{
    astro_effect_step(stream_proc_addr, effect_count_addr, 
                      effect_frames, effect_table_addr)
    rts
}

