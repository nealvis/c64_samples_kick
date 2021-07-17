//////////////////////////////////////////////////////////////////////////////
// nv_rand_macs.asm
// contains inline macros random numbers
// importing this file will not allocate any memory for data or code.
//////////////////////////////////////////////////////////////////////////////

#importonce

#if !NV_C64_UTIL_DATA
.error "Error - nv_rand_macs.asm: NV_C64_UTIL_DATA not defined.  Import nv_c64_util_data.asm"
#endif

// the #if above doesn't seem to always work so..
// if data hasn't been imported yet, import it into default location
#importif !NV_C64_UTIL_DATA "nv_c64_util_default_data.asm"

.const VOICE_3_FREQ_REG_ADDR = $D40E
.const VOICE_3_CONTROL_REG_ADDR = $D412


.macro nv_rand_init()
{
    lda #$FF                        // load accum with max freq value
    sta VOICE_3_FREQ_REG_ADDR       // low byte
    sta VOICE_3_FREQ_REG_ADDR+1     // high byte
    lda #$80                        // value for noise waveform and gate off
    sta VOICE_3_CONTROL_REG_ADDR    // store vals to voice 3 control reg
}

// load accum with random byte
.macro nv_rand_byte_a()
{
    .const VOICE_3_WAVE_OUTPUT = $D41B
    lda VOICE_3_WAVE_OUTPUT
}

// load accum with random byte
.macro nv_rand_color_a()
{
    nv_rand_byte_a()
    and #$0F
}

.macro nv_rand_done()
{
/*
    lda #$00                        // back to 0 for these locations
    sta VOICE_3_FREQ_REG_ADDR       
    sta VOICE_3_FREQ_REG_ADDR+1     
    sta VOICE_3_CONTROL_REG_ADDR    
*/
}