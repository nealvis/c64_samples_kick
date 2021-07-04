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

