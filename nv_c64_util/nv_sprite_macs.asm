//////////////////////////////////////////////////////////////////////////////
// nv_sprite_macs.asm
// Contains inline macros for sprite releated stuff
// Importing this file will not generate any code or data when assembled
//////////////////////////////////////////////////////////////////////////////

#importonce

#if !NV_C64_UTIL_DATA
.error "Error - nv_sprite_macs.asm: NV_C64_UTIL_DATA not defined.  Import nv_c64_util_data.asm"
#endif
// the #if above doesn't seem to always work so..
// if data hasn't been imported yet, import it into default location
#importif !NV_C64_UTIL_DATA "nv_c64_util_default_data.asm"

#import "nv_sprite_raw_macs.asm"
#import "nv_sprite_extra_macs.asm"
#import "nv_sprite_raw_collisions_macs.asm"

//////////////////////////////////////////////////////////////////////////////
// inline macro (no rts) to wait for the a specific scanline  
.macro nv_sprite_wait_specific_scanline(line)
{

// for scanline <= 255 decimal
loop:
    // first wiat for bits 0-7 to match our scan line bits 0-7
    lda $D012   // current scan line low bits 0-7 in $D012
    cmp #(line & $00FF)     // scan line to wait for LSB
    bne loop    // if not equal zero then keep looping

    // low bits matched so check the hi bit in $D011
    lda $D011
    .if (line < 255)
    {
        bmi loop    // If bit 7 is 1 then keep looping
    } 
    else
    {
        bpl loop   // if bit 7 is 0 then keep looping
    }
}


//////////////////////////////////////////////////////////////////////////////
// inline macro (no rts) to wait for the last scanline drawing last row 
// of screen before bottom border starts
.macro nv_sprite_wait_last_scanline()
{
    nv_sprite_wait_specific_scanline(250)
}


////////////////////////////////////////////////////////////////////////////
// subroutine to wait for a specific scan line
.macro nv_sprite_wait_last_scanline_sr()
{
    nv_sprite_wait_last_scanline()
    rts
}

