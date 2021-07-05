//////////////////////////////////////////////////////////////////////////////
// nv_sprite_raw_code.asm 
// contains instantiations of macros into actual code
// like subroutines etc. for sprites at the HW level.
// There is no dependency on the sprite_info struct or the sprite
// extra data block in this file.

//////////////////////////////////////////////////////////////////////////////
// Import other modules as needed here
#importonce

#if !NV_C64_UTIL_DATA
.error "Error - nv_sprite_raw_code.asm: NV_C64_UTIL_DATA not defined.  Import nv_c64_util_data.asm"
#endif

// the #if above doesn't seem to always work so..
// if data hasn't been imported yet, import it into default location
#importif !NV_C64_UTIL_DATA "nv_c64_util_default_data.asm"

#import "nv_sprite_raw_macs.asm"
#import "nv_math8_macs.asm"
#import "nv_math16_macs.asm"




//////////////////////////////////////////////////////////////////////////////
// subroutine disable a specified sprite
// Subroutine params:
//   Accum: set to the sprite number for the sprite to be dissabled
NvSpriteRawDisableFromReg:
    nv_sprite_raw_disable_from_reg()
    rts



