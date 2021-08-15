//////////////////////////////////////////////////////////////////////////////
// astro_title_code.asm
//////////////////////////////////////////////////////////////////////////////
// The following subroutines should be called from the main engine
// as follows
// TitleStart: call to show title screen
//////////////////////////////////////////////////////////////////////////////

#importonce 
#import "astro_vars_data.asm"
#import "../nv_c64_util/nv_screen_macs.asm"
#import "../nv_c64_util/nv_screen_rect_macs.asm"
#import "../nv_c64_util/nv_pointer_macs.asm"
#import "../nv_c64_util/nv_stream_processor_macs.asm"
#import "../nv_c64_util/nv_debug_macs.asm"
#import "astro_stream_processor_macs.asm"
#import "astro_stream_processor_code.asm"
#import "../nv_c64_util/nv_math16_macs.asm"

#import "astro_starfield_code.asm"

//#import "../nv_c64_util/nv_debug_code.asm"
astro_title_str:     .text @" astroblast \$00"
hit_anykey_str: .text @"hit any key to continue \$00"

//////////////////////////////////////////////////////////////////////////////
// call once to initialize starfield variables and stuff
TitleStart:
{
    .const TITLE_ROW_START = 5
    .const TITLE_COL_START = 9
    nv_screen_clear()

    jsr StarInit
    jsr StarStart
    jsr StarStep
    
    nv_screen_poke_str(TITLE_ROW_START, TITLE_COL_START + 6, astro_title_str)
    nv_screen_poke_str(TITLE_ROW_START+4, TITLE_COL_START, hit_anykey_str)
    nv_key_wait_any_key()

    jsr StarCleanup
    lda #$01
    rts
}
// TitleStart end
//////////////////////////////////////////////////////////////////////////////

