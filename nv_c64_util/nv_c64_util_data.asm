#importonce

// This is the default location for the data needed by all the 
// macros and subroutines in the nv_util directory.  Its up to 
// the user to make sure this doesn't conflict with their 
// program or move it if it does.  The end of basic is 
// usually $A000 so $9F00 is the 256 bytes before there
// to place this data there, put this line right before importing
// this file.
//*=$9F00 "nv_util_data"   

// define this so that other nv_c64_util *_macs.asm files can 
// verify that the data has been imported into the program 
// somewhere else without doing it from the _macs.asm files
#define NV_C64_UTIL_DATA

//#import "nv_c64_util_macs.asm"
#import "nv_keyboard_const.asm"

nv_c64_util_data_start_addr: 
//////////////////////////////////////////////////////////////////////////////
//                    all data must be below this
//////////////////////////////////////////////////////////////////////////////

temp_hex_str: .byte 0,0,0,0,0,0         // enough bytes for dollor sign, 4 
                                        // hex digits and a trailing null
hex_digit_lookup:
    .byte $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $41, $42, $43, $44, $45, $46

hex_digit_lookup_poke:
    .byte $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $01, $02, $03, $04, $05, $06 


wait_counter: .byte 0

scratch_byte: .byte 0

scratch_word: .word 0

// some pseudo registers to be used throughout nv_c64_util
nv_a16: .word 0
nv_b16: .word 0
nv_c16: .word 0
nv_d16: .word 0
nv_e16: .word 0
nv_f16: .word 0
nv_g16: .word 0

nv_a8: .byte 0
nv_b8: .byte 0
nv_c8: .byte 0
nv_d8: .byte 0
nv_e8: .byte 0
nv_f8: .byte 0
nv_g8: .byte 0

//////////////////////////////////////////////////////////////////////////////
// data for sprite collision finding in nv_sprite_raw_check_collision
    
// current HW sprite collisions register value
collision_bit: .byte 0

// return this which is the closest colliding sprite number or 
// it will be $FF if no colliding sprite
closest_sprite: .byte $FF

// as we check all colliding sprites, we'll keep this as the
// closest so far and update it with as closer ones are found
closest_rel_dist: .word $7FFF

//////////////////////////////////////////////////////////////////////////////
// data for nv_keyboard_*.asm


nv_key_last_pressed: .byte NV_KEY_UNINITIALIZED
nv_key_prev_pressed: .byte NV_KEY_NO_KEY

// table of chars to report for col0 keys:  
nv_key_col0_table: 
.byte NOKEY, NOKEY,   NOKEY,     NOKEY, NOKEY, NOKEY, NOKEY, NOKEY
//    <del>, <return>,<cur L/R>, F7,    F1,    F3,    F5,    <cur UD>

// table of chars to report for col1 keys:  
nv_key_col1_table: 
.byte NV_KEY_3, NV_KEY_W, NV_KEY_A, NV_KEY_4, NV_KEY_Z, NV_KEY_S, NV_KEY_E, NOKEY
//    3,        W,        A,        4,        Z,        S,        E,       <LSHIFT>

// table of chars to report for col2 keys:
nv_key_col2_table: 
.byte NV_KEY_5, NV_KEY_R, NV_KEY_D, NV_KEY_6, NV_KEY_C, NV_KEY_F, NV_KEY_T, NV_KEY_X
//    5,        R,        D,        6,        C,        F,        T,        X

// table of chars to report for col3 keys:
nv_key_col3_table: 
.byte NV_KEY_7, NV_KEY_Y, NV_KEY_G, NV_KEY_8, NV_KEY_B, NV_KEY_H, NV_KEY_U, NV_KEY_V
//    7,        Y,        G,        8,        B,        H,        U,        V

// table of chars to report for col4 keys:
nv_key_col4_table: 
.byte NV_KEY_9, NV_KEY_I, NV_KEY_J, NV_KEY_0, NV_KEY_M, NV_KEY_K, NV_KEY_0, NV_KEY_N
//    9,        I,        J,        0,        M,        K,        O,        N

// table of chars to report for col5 keys:
nv_key_col5_table: 
.byte $2B, NV_KEY_P, NV_KEY_L, $2D, NV_KEY_PERIOD, $3A, $0, NV_KEY_COMMA
//     +,  P,        L,          -,  <period>,     :,    @, <comma>

// table of chars to report for col6 keys:
nv_key_col6_table: 
.byte $1C, $2A, $3B, NOKEY,      NOKEY,   $3D, $1E,        $2F
//    <lb>, *,   ;,  <CLR HOME>, <RShift>, =,  <up arrow>, /

// table of chars to report for col7 keys:
nv_key_col7_table: 
.byte NV_KEY_1, $1F,        NOKEY,  NV_KEY_2, $20,     NOKEY,    NV_KEY_Q, NOKEY
//    1,        <lf arrow>, <ctrl>, 2,        <space>, <cmodor>, Q,        <run st>

// End keyboard data
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// nv_debug data

// used to save accum in nv_debug macros
nv_debug_save_a: .byte $BE // give an arbitrary value

// end nv_debug data
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// nv_rand data

// used to save accum in nv_debug macros
nv_rand_index: .byte $00   // give an arbitrary value

nv_rand_bytes:             // 256 bytes of 0s to get filled in by nv_rand_init
.fill 256, 0 

// end nv_debug data
//////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////////////////
//                    all data must be above this
//////////////////////////////////////////////////////////////////////////////
nv_c64_util_data_end_addr:

// do some checking in case the data grows to the point that 
// it extends beyond the end of BASIC
.var nv_c64_util_data_size = nv_c64_util_data_end_addr - nv_c64_util_data_start_addr
.print "nv_c64_util_data: " + nv_c64_util_data_start_addr + " - " + nv_c64_util_data_end_addr
.print "nv_c64_util_data_size is " + nv_c64_util_data_size
.print "BASIC end is: " + $9FFF
.if (nv_c64_util_data_end_addr > $9FFF)
{
    .error "Error - nv_c64_util_data.asm: data beyond end of BASIC!"
}

