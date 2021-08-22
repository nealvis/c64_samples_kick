//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
#importonce

#import "../nv_c64_util/nv_c64_util_macs.asm"


//////////////////////////////////////////////////////////////////////////////
// macro for astroblaster that generates code that reads from
// a list of streams, and based on a frame counter will run the appropriate
// stream (all commands) in the list every time its called.  
// So if an entire effect can be done by processing a differnt stream each
// frame, the user can create the list of stream addresses and just call this
// subroutine once per frame.
// macro params:
//   stream_proc_addr: Address of the stream processor subroutine  
//                     that will be called to process streams.  
//   effect_count_addr: Address of the frame counter for the effect 
//                      it counts down to zero typically.  When an
//                      effect is started the byte at this addr should be set
//                      to effect_frames.  End each time this is code 
//                      executes that byte will be decremented.  
//                      If the byte at this address is zero then this
//                      code does nothing.
//   effect_frames: This is the total number of frames in the effect.
//                  the byte at effect_count_addr is subracted from this
//                  in order to get the zero based frame/step for the effect
//                  that is the index into the effect table addr.
//   effect_table_addr: the addres of a list of words that contain 16 bit
//                      addresses of the streams that will be called.
//                      there must be effect_frames number of words/addrs
//                      at this location.
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
// macro that creates a subroutine for the astro_effect_step macro.
// when expanded at a label you can jsr to the label to run the code
// See astro_effect_step for details of what the code does and what
// macro parameters are.  
.macro astro_effect_step_sr(stream_proc_addr, effect_count_addr, 
                            effect_frames, effect_table_addr)
{
    astro_effect_step(stream_proc_addr, effect_count_addr, 
                      effect_frames, effect_table_addr)
    rts
}

