
//////////////////////////////////////////////////////////////////////////////
// nv_sprite_raw_code.asm contains instantiations of macros into actual code
// like subroutines etc. for sprites at the HW level.
// There is no dependency on the sprite_info struct or the sprite
// extra data block in this file.

//////////////////////////////////////////////////////////////////////////////
// Import other modules as needed here
#importonce
#import "nv_sprite_raw_macs.asm"
#import "nv_math8.asm"
#import "nv_math16.asm"
#import "nv_util_data.asm"




//////////////////////////////////////////////////////////////////////////////
// subroutine disable a specified sprite
// Subroutine params:
//   Accum: set to the sprite number for the sprite to be dissabled
NvSpriteRawDisableFromReg:
    nv_sprite_raw_disable_from_reg()
    rts



