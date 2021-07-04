#importonce

#if !NV_C64_UTIL_DATA
.error "Error - nv_debug_code.asm: NV_C64_UTIL_DATA not defined.  Import nv_c64_util_data.asm"
#endif

#import "nv_screen_macs.asm"
#import "nv_math16_macs.asm"

//////////////////////////////////////////////////////////////////////////////
// subroutine macro to poke chars for a string to screen memory
// parameters
//   nv_a8: row position on screen to print at
//   nv_b8: col position on screen to print at
//   nv_a16: the address of the first char of string.
//           this string must be zero terminated.
.macro nv_screen_poke_string_sr()
{
    // two zero page bytes to use as a pointer
    .const ZERO_PAGE_LO = $FB
    .const ZERO_PAGE_HI = $FC
    
    // save the zero page bytes that we use
    lda ZERO_PAGE_LO 
    sta save_zero_lo
    lda ZERO_PAGE_HI
    sta save_zero_hi

    //.var screen_poke_start = SCREEN_START + (40*row) + col 
    nv_store16_immediate(screen_poke_start, SCREEN_START)
    lda nv_a8
    sta row_counter  // counter starts with row number
    beq DoneAddingRows
RowLoop:
    nv_adc16_immediate(screen_poke_start, 40, screen_poke_start)
    dec row_counter
    bne RowLoop
DoneAddingRows:

    // now add the column
    nv_adc16_8unsigned(screen_poke_start, nv_b8, screen_poke_start)

    // now screen_poke_start contains addr of the first screen
    // char to poke

    ldy #0                  // use x reg as loop index start at 0
DirectLoop:
    // load pointer to string base
    lda nv_a16 
    sta ZERO_PAGE_LO
    lda nv_a16+1
    sta ZERO_PAGE_HI

    // load byte from string
    //lda nv_a16,x            // put a byte from string into accum
    lda (ZERO_PAGE_LO),y

    beq Done                // if the byte was 0 then we're done

    // load zero page pointer to point to first char to write
    ldx screen_poke_start 
    stx ZERO_PAGE_LO
    ldx screen_poke_start+1
    stx ZERO_PAGE_HI

    // store byte to screen memory
    //sta screen_poke_start,x // Store the byte to screen
    sta (ZERO_PAGE_LO),y

    iny                     // inc to next byte and next screen location 
    jmp DirectLoop          // Go back for next byte
Done:
    // restore the zero page bytes that we used 
    lda save_zero_hi
    sta ZERO_PAGE_HI
    lda save_zero_lo
    sta ZERO_PAGE_LO
    rts

screen_poke_start:    
    .word 0
row_counter: 
    .word 0
save_zero_lo:
    .byte 0
save_zero_hi:
    .byte 0
}


//////////////////////////////////////////////////////////////////////////////
// Subroutine macro to print the hex value of a byte in memory to the screen.
// Subroutine Parameters
//   nv_a8: row position on screen to print at
//   nv_b8: col position on screen to print at
//   nv_c8: the byte to print should be loaded here
//   nv_d8: set to 1 to include dollar sign
.macro nv_screen_poke_hex_byte_sr()
{
    ldx #0
    lda nv_d8
    beq NoDollar 
YesDollar:
    lda #$24                // dollar sign
    sta temp_hex_str, x
    inx
NoDollar:
    stx nv_g8

    lda nv_c8
    tay
    ror 
    ror 
    ror 
    ror  
    and #$0f
    tax
    lda hex_digit_lookup_poke, x  // load Accum with char to print
    ldx nv_g8
    sta temp_hex_str, x           // copy char to temp str
    inc nv_g8
    tya
    and #$0f
    tax
    lda hex_digit_lookup_poke, x
    ldx nv_g8
    sta temp_hex_str, x
    lda #0
    inx
    sta temp_hex_str, x

    //   nv_a8: row position, already loaded
    //   nv_b8: col position, already loaded
    //   nv_a16: copy addr of temp_hex_str to nv_a16.
    lda #<temp_hex_str
    sta nv_a16 
    lda #>temp_hex_str
    sta nv_a16+1

    jsr NvScreenPokeString

    rts
}

//////////////////////////////////////////////////////////////////////////////
// Instantiations of macros from above go below here
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
//   nv_a8: row position on screen to print at
//   nv_b8: col position on screen to print at
//   nv_a16: the address of the first char of string.
//           this string must be zero terminated.
NvScreenPokeString:
    nv_screen_poke_string_sr()


//////////////////////////////////////////////////////////////////////////////
// Subroutine to print the hex value of a byte in specific memory location
// to the screen.
// Subroutine Parameters
//   nv_a8: row position on screen to print at
//   nv_b8: col position on screen to print at
//   nv_c8: the byte to print should be loaded here
//   nv_d8: set to 1 to include dollar sign
NvScreenPokeHexByte:
    nv_screen_poke_hex_byte_sr()
