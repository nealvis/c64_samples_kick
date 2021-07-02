#importonce

// This is the default location for the data needed by all the 
// macros and subroutines in the nv_util directory.  Its up to 
// the user to make sure this doesn't conflict with their 
// program or move it if it does.  The end of basic is 
// usually $A000 so $9F00 is the 256 bytes before there
//*=$9F00 "nv_util_data"   

temp_hex_str: .byte 0,0,0,0,0,0         // enough bytes for dollor sign, 4 
                                        // hex digits and a trailing null
hex_digit_lookup:
    .byte $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $41, $42, $43, $44, $45, $46

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
