// nv_c64_util
// sprite releated stuff

#importonce


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


