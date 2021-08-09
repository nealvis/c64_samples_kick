#importonce

#import "astro_vars_data.asm"

#import "../nv_c64_util/nv_stream_processor_macs.asm"


//////////////////////////////////////////////////////////////////////////////
//   Accum: will change, Input: should hold the byte that will be stored 
//   X Reg: will change, Input: LSB of stream data's addr.  
//   Y Reg: will change, Input: MSB of Stream data's addr 
AstroStreamProcessor:
    nv_stream_proc_sr(nv_sp_temp_word, nv_sp_save_block, background_color)

nv_sp_temp_word: .word $0000
nv_sp_save_block: .word $0000
                  .word $0000
