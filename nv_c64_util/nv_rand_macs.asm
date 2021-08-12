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
.const VOICE_3_WAVE_OUTPUT = $D41B


.macro nv_rand_init(pre_calc)
{
    lda #$FF                        // load accum with max freq value
    sta VOICE_3_FREQ_REG_ADDR       // low byte
    sta VOICE_3_FREQ_REG_ADDR+1     // high byte
    lda #$80                        // value for noise waveform and gate off
    sta VOICE_3_CONTROL_REG_ADDR    // store vals to voice 3 control reg
    lda #$00
    sta nv_rand_index
    .if (pre_calc)
    {
        ldy #1
    OuterLoop:
        ldx #0
    Loop:
        lda VOICE_3_WAVE_OUTPUT
        sta nv_rand_bytes, x
        inx
        bne Loop
        dey
        beq OuterLoop
    }
}

// load accum with random byte
.macro nv_rand_byte_a(pre_calc)
{
    .if (pre_calc)
    {
        inc nv_rand_index
        ldx nv_rand_index
        lda nv_rand_bytes, x
    }
    else
    {
        lda VOICE_3_WAVE_OUTPUT
    }
}

// load accum with random byte
.macro nv_rand_color_a(pre_calc)
{
    nv_rand_byte_a(pre_calc)
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