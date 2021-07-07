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
// data for nv_keyboard_*.asm
nv_key_last_pressed: .byte $00


// For all the colX_tables below when there is no reasonable 
// value to poke to the screen (or when i haven't looked up
// the right value yet) for the corresponding key, 
// the table byte will be $66 which is just a grid pattern

.const NV_KEY_W = $17
.const NV_KEY_S = $13
.const NV_KEY_A = $01
.const NV_KEY_D = $04

// table of chars to report for col0 keys:  
nv_key_col0_table: 
.byte $66,   $66,      $66,       $66, $66, $66, $66, $66
//    <del>, <return>, <cur L/R>,  F7, F1,   F3,  F5, <cur UD>

// table of chars to report for col1 keys:  
nv_key_col1_table: 
.byte $33, $17, NV_KEY_A, $34, $1A, NV_KEY_S, $05, $66
//     3,   W,   A,         4,   Z, S,         E,  <LSHIFT>

// table of chars to report for col2 keys:
nv_key_col2_table: 
.byte $35, $12, NV_KEY_D, $36, $03, $06, $14, $18
//     5,   R,  D,        6,   C,   F,   T,   X

// table of chars to report for col3 keys:
nv_key_col3_table: 
.byte $37, $19, $07, $38, $02, $08, $15, $16
//     7,   Y,   G,   8,   B,   H,   U,   V

// table of chars to report for col4 keys:
nv_key_col4_table: 
.byte $39, $09, $0A, $30, $0D, $0B, $0F, $0E
//     9,   I,   J,   0,   M,   K,   O,   N

// table of chars to report for col5 keys:
nv_key_col5_table: 
.byte $2B, $10, $0C, $2D, $2E, $3A, $0, $2C
//     +,   P,   L,   -,   .,   :,   @,  <comma>

// table of chars to report for col6 keys:
nv_key_col6_table: 
.byte $1C, $2A, $3B, $66,        $66,     $3D, $1E,        $2F
//    <lb>, *,   ;,  <CLR HOME>, <RShift>, =,  <up arrow>, /

// table of chars to report for col7 keys:
nv_key_col7_table: 
.byte $31, $1F,        $66,   $32, $66,     $66,     $11, $66
//     1,  <lf arrow>, <ctrl>, 2,  <space>, <cmodor>, Q,  <run st>

// End keyboard data
//////////////////////////////////////////////////////////////////////////////



// used to save accum in nv_debug macros
nv_debug_save_a: .byte $BE // give an arbitrary value
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

