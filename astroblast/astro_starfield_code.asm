//////////////////////////////////////////////////////////////////////////////
// astro_turret_code.asm
//////////////////////////////////////////////////////////////////////////////
// The following subroutines should be called from the main engine
// as follows
// TurretInit: Call once before main loop and before other routines
// TurretStep: Call once every raster frame through the main loop
// TurretStart: Call to start the effect See subroutine header for params
// TurretActive: Call to determine if a turret active
// TurretForceStop: Call to force effect to stop if it is active
// TurretCleanup: Call at end of program after main loop to clean up
//////////////////////////////////////////////////////////////////////////////

#importonce 
#import "astro_vars_data.asm"
#import "astro_starfield_data.asm"
#import "../nv_c64_util/nv_screen_macs.asm"
#import "../nv_c64_util/nv_screen_rect_macs.asm"
#import "../nv_c64_util/nv_pointer_macs.asm"
#import "../nv_c64_util/nv_stream_processor_macs.asm"
#import "../nv_c64_util/nv_debug_macs.asm"
#import "astro_stream_processor_macs.asm"
#import "astro_stream_processor_code.asm"
//#import "../nv_c64_util/nv_debug_code.asm"

//////////////////////////////////////////////////////////////////////////////
// call once to initialize starfield variables and stuff
StarInit:
{
    lda #$00
    sta star_count
    rts
}
// TurretInit end
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// subroutine to start starfield animation.  
StarStart:
{
    lda #STAR_FRAMES
    sta star_count
    rts
}

// StarStart subroutine end
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// subroutine to determine if a starfield is currently active
// Return:
//   Accum: will be zero if not active or non zero if is active
StarLdaActive:
{
    lda star_count
    rts
}
// StarLdaActive subroutine end
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// subroutine to force starfield effect to stop if it is active. if not 
// active then should do nothing
// 
StarForceStop:
{
    lda #$00
    sta star_count
    rts
}
// StarForceStop end
//////////////////////////////////////////////////////////////////////////////    


//////////////////////////////////////////////////////////////////////////////
// subroutine to call at end of program when done with all other wind
// data and routines.
StarCleanup:
{
    jsr StarForceStop
    rts
}
// StarCleanup End
//////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////////////////
// call once per frame to have turret shoot 
StarStep:
{
    astro_effect_step_sr(AstroStreamProcessor, star_count, 
                         STAR_FRAMES, StarStreamAddrTable)
}
// StarStep subroutine end
//////////////////////////////////////////////////////////////////////////////

