#importonce

#if !NV_C64_UTIL_DATA
.error "Error - nv_keyboard_macs.asm: NV_C64_UTIL_DATA not defined.  Import nv_c64_util_data.asm"
#endif

// the #if above doesn't seem to always work so..
// if data hasn't been imported yet, import it into default location
#importif !NV_C64_UTIL_DATA "nv_c64_util_default_data.asm"

.const PRA  =  $dc00            // CIA#1 (Port Register A)
.const DDRA =  $dc02            // CIA#1 (Data Direction Register A)

.const PRB  =  $dc01            // CIA#1 (Port Register B)
.const DDRB =  $dc03            // CIA#1 (Data Direction Register B)

//////////////////////////////////////////////////////////////////////////////
// kernal keyboard constants. 

// address of the current key being pressed
.const KERNAL_CUR_KEY_PRESS_ADDR = $00CB

// value when no key is being pressed.  when its a valid key its 
// between $00-$3F
.const KERNAL_NO_KEY = $40

//////////////////////////////////////////////////////////////////////////////

#import "nv_screen_macs.asm"
#import "nv_debug_macs.asm"

//////////////////////////////////////////////////////////////////////////////
// init everything we need to capture keys.
// call once before using any nv_key_* macros/subroutines/data
.macro nv_key_init()
{
    //sei             // disable interrupts

    // write a 0 to bit 0 at $DC0E to turn off timer A
    // which is how keyboard is handled.
    lda #$FE
    and $DC0E
    sta $DC0E

    lda #$FF        // CIA#1 port A = outputs 
    sta DDRA             

    lda #$00        // CIA#1 port B = inputs
    sta DDRB             

    // start out with last pressed as 0
    ldx #NV_KEY_NO_KEY
    stx nv_key_last_pressed
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to stop capturing keys
.macro nv_key_done()
{
    // if we disabled interupts above then should enable them here
    //cli           // enable interrupts 

    // if we just turned off the timer A
    // which take care of keyboard then just turn it back on here
    lda #$01
    ora $DC0E
    sta $DC0E

    lda #NV_KEY_UNINITIALIZED
    sta nv_key_last_pressed
}

//////////////////////////////////////////////////////////////////////////////
// macro to be executed repeatedly within program main loop.  This must 
// called repeatedly in order get any keyboard info
.macro nv_key_scan()
{
CheckCol0:
    lda #$FE        // testing column 0 (COL0) of the matrix
    sta PRA

    lda PRB
    cmp #$FF
    beq CheckCol1
HaveCol0:
    //sta nv_g8
    test_for_char_with_table(nv_key_col0_table)

CheckCol1:
    lda #$FD        // testing column 1 (COL1) of the matrix
    sta PRA

    lda PRB
    cmp #$FF
    beq CheckCol2
HaveCol1:
    //sta nv_g8
    test_for_char_with_table(nv_key_col1_table)

CheckCol2:
    lda #$FB        // testing column 2 (COL2) of the matrix
    sta PRA

    lda PRB
    cmp #$FF
    beq CheckCol3
HaveCol2:
    //sta nv_g8
    test_for_char_with_table(nv_key_col2_table)

CheckCol3:
    lda #$F7        // testing column 3 (COL3) of the matrix
    sta PRA

    lda PRB
    cmp #$FF
    beq CheckCol4
HaveCol3:
    //sta nv_g8
    test_for_char_with_table(nv_key_col3_table)

CheckCol4:
    lda #$EF        // testing column 4 (COL4) of the matrix
    sta PRA

    lda PRB
    cmp #$FF
    beq CheckCol5
HaveCol4:
    //sta nv_g8
    test_for_char_with_table(nv_key_col4_table)

CheckCol5:
    lda #$DF        // testing column 5 (COL5) of the matrix
    sta PRA

    lda PRB
    cmp #$FF
    beq CheckCol6
HaveCol5:
    //sta nv_g8
    test_for_char_with_table(nv_key_col5_table)

CheckCol6:
    lda #$BF        // testing column 6 (COL6) of the matrix
    sta PRA

    lda PRB
    cmp #$FF
    beq CheckCol7
HaveCol6:
    //sta nv_g8
    test_for_char_with_table(nv_key_col6_table)

CheckCol7:
    lda #$7F        // testing column 7 (COL7) of the matrix
    sta PRA

    lda PRB
    cmp #$FF
    beq Bottom
HaveCol7:
    //sta nv_g8
    test_for_char_with_table(nv_key_col7_table)
    
Bottom:
    //nv_screen_poke_hex_byte_mem(2, 0, nv_g8, true)
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to copy last pressed key into memory
// macro params:
//   addr_for_last: is the memory location to copy the code for last
//                  pressed key
//   clear: set to true to clear the last key, or false to leave it
//          for the next call.  Clearing means until another key
//          is pressed, calls to this will return NV_KEY_NO_KEY
.macro nv_key_get_last_pressed(addr_for_last, clear)
{
    nv_key_get_last_pressed_a(clear)
    sta addr_for_last
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to copy last pressed key into accumulator
// macro params:
//   clear: set to true to clear the last key, or false to leave it
//          for the next call.  Clearing means until another key
//          is pressed, calls to this will return NV_KEY_NO_KEY
.macro nv_key_get_last_pressed_a(clear)
{
    lda nv_key_last_pressed
    .if (clear)
    {
        ldy #NV_KEY_NO_KEY
        sty nv_key_last_pressed
    }
}


//////////////////////////////////////////////////////////////////////////////
// inline macro that pokes a char based on the bits in the accum
// which are assumed to be read from one of the rows of the keyboard 
// matrix. basically for each 0 bit in the accume a char (the corresponding
// macro parameter) is poked to the screen 
// macro params:
//   table_addr: the address of a table with 8 bytes.  Each byte 
//               in the table corresponds to a bit in the accum.
//               when that bit is 0 the corresponding number in
//               the table is poked to the screen
//               for example if table_addr holds these 8 values:
//                 1, 2, 3, 4, 5, 6, 7, 8
//               and accum has $FB  then a 6 will be poked to the screen
.macro test_for_char_with_table(table_addr)
{
    ldx #0
TryBit:
    ror
    bcs TryNextBit              // this key not hit
    ldy table_addr, x           // get value to poke to screen from table
    sty nv_key_last_pressed
    //nv_screen_poke_char_y(2, 0) // poke to screen.  
TryNextBit:
    inx
    cpx #$08
    beq Done
    jmp TryBit
Done: 
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to wait for any key to be pressed.
// Note: this macro will first wait for no key to be pressed
//       then wait for any key, and then wait for no key again.
// Also note: if nv_keyboard hasn't been initialized then it will be
//            assumed kernal is handling keyboard but will still wait for
//            any key based on that assumption. 
.macro nv_key_wait_any_key()
{
    
    lda nv_key_last_pressed
    cmp #NV_KEY_UNINITIALIZED
    bne IsInitialized
NotInitialized:  
    // not initialized yet use kernal routine
    nv_key_wait_any_key_kernal()
    jmp Done 

IsInitialized:
    nv_key_wait_no_key()
Loop:
    nv_key_scan()
    nv_key_get_last_pressed_a(true)
    cmp #NV_KEY_NO_KEY
    bne Done 
    jmp Loop
Done:
    nv_key_wait_no_key()
}


//////////////////////////////////////////////////////////////////////////////
// wait for no key to be pressed
.macro nv_key_wait_no_key()
{
Loop:
    nv_key_scan()
    nv_key_get_last_pressed_a(true)
    cmp #NV_KEY_NO_KEY
    beq Done 
    jmp Loop
Done:

}

//////////////////////////////////////////////////////////////////////////////
// wait for no key to be pressed using kernal keyboard routines
// Note, this macro will first wait for no key to be pressed
// then wait for any key, and then wait for no key again.
.macro nv_key_wait_any_key_kernal()
{
    nv_key_wait_no_key_kernal()

WaitAnyKey:
    lda KERNAL_CUR_KEY_PRESS_ADDR
    cmp #KERNAL_NO_KEY
    beq WaitAnyKey

    nv_key_wait_no_key_kernal()
}


//////////////////////////////////////////////////////////////////////////////
// wait for no key to be pressed using kernal keyboard routines
.macro nv_key_wait_no_key_kernal()
{
WaitNoKey:    
    lda KERNAL_CUR_KEY_PRESS_ADDR
    cmp #KERNAL_NO_KEY
    bne WaitNoKey
}


