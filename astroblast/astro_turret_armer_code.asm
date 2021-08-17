//////////////////////////////////////////////////////////////////////////////
// astro_turret_armer_code.asm
//////////////////////////////////////////////////////////////////////////////
// The following subroutines should be called from the main engine
// as follows
// TurretArmInit: Call once before main loop and before other routines
// TurretArmStep: Call once every raster frame through the main loop
// TurretArmStart: Call to start the effect See subroutine header for params
// TurretArmActive: Call to determine if a turret active
// TurretArmForceStop: Call to force effect to stop if it is active
// TurretArmCleanup: Call at end of program after main loop to clean up
//////////////////////////////////////////////////////////////////////////////

#importonce 
#import "../nv_c64_util/nv_c64_util_macs_and_data.asm"

#import "astro_vars_data.asm"
#import "astro_turret_armer_data.asm"
//#import "../nv_c64_util/nv_screen_macs.asm"
//#import "../nv_c64_util/nv_screen_rect_macs.asm"
//#import "../nv_c64_util/nv_pointer_macs.asm"
//#import "../nv_c64_util/nv_stream_processor_macs.asm"
//#import "../nv_c64_util/nv_debug_macs.asm"
//#import "astro_stream_processor_macs.asm"
#import "astro_stream_processor_code.asm"
//#import "../nv_c64_util/nv_math16_macs.asm"
//#import "../nv_c64_util/nv_debug_code.asm"

//////////////////////////////////////////////////////////////////////////////
// call once to initialize starfield variables and stuff
TurretArmInit:
{
    lda #$00
    sta turret_arm_count
    sta turret_currently_armed
    sta turret_second_counter
    sta turret_second_saved_value
    sta turret_arm_frame_counter

    rts
}
// TurretArmInit end
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// subroutine to start starfield animation.  
TurretArmStart:
{
    lda #TURRET_ARM_FRAMES
    sta turret_arm_count

    lda #TURRET_FRAMES_BETWEEN_STEPS        // reset counter for next step
    sta turret_arm_frame_counter

    lda #$00
    sta turret_currently_armed
    sta turret_second_counter

    // save LSB of the second value
    lda second_counter
    sta turret_second_saved_value  
    rts
}

// TurretArmStart subroutine end
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// subroutine to determine if a starfield is currently active
// Return:
//   Accum: will be zero if not active or non zero if is active
TurretArmLdaActive:
{
    lda turret_arm_count
    rts
}
// TurretArmLdaActive subroutine end
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// subroutine to determine if a starfield is currently armed and read to fire
// Return:
//   Accum: will be zero if not armed or non zero if is armed
TurretCurrentlyArmedLda:
{
    lda turret_currently_armed
    rts
}
// TurretCurrentlyArmedLda subroutine end
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// subroutine to force starfield effect to stop if it is active. if not 
// active then should do nothing
// 
TurretArmForceStop:
{
    lda #$00
    sta turret_arm_count
    sta turret_currently_armed
    sta turret_arm_frame_counter

    rts
}
// TurretArmForceStop end
//////////////////////////////////////////////////////////////////////////////    


//////////////////////////////////////////////////////////////////////////////
// subroutine to call at end of program when done with all other wind
// data and routines.
TurretArmCleanup:
{
    jsr TurretArmForceStop
    rts
}
// TurretArmCleanup End
//////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////////////////
// call once per frame to have turret shoot 
TurretArmStep:
{
    //nv_screen_poke_hex_byte_mem(3, 0, turret_arm_frame_counter, true)
    lda turret_arm_count
    bne TurretArmStepContinue
    rts
TurretArmStepContinue:

    lda turret_currently_armed
    bne TurretSkipArming                // already armed 

    lda second_counter
    cmp turret_second_saved_value
    beq TurretSkipArming

TurretNewSecond:
    sta turret_second_saved_value
    inc turret_second_counter
    //nv_screen_poke_hex_byte_mem(8, 30, turret_second_counter, true)
    lda #TURRET_SECONDS_TO_ARM
    cmp turret_second_counter 
    bne TurretSkipArming
TurretDoArming:
    lda #$01
    sta turret_currently_armed

TurretSkipArming:
    // arming seconds taken care of above, now run the step if
    // appropriate.

    dec turret_arm_frame_counter
    bne TurretNoStepThisFrame

TurretIsStepThisFrame:
    lda #TURRET_FRAMES_BETWEEN_STEPS        // reset counter for next step
    sta turret_arm_frame_counter
    astro_effect_step(AstroStreamProcessor, turret_arm_count, 
                      TURRET_ARM_FRAMES, TurretArmStreamAddrTable)
    lda turret_arm_count
    bne TurretArmStepDone
    inc turret_currently_armed
/*
    lda turret_arm_count
    bne TurretArmStepDone
    lda #1                   // if we've stepped to zero just stay at the last step
    sta turret_arm_count     // 
*/
TurretNoStepThisFrame:

TurretArmStepDone:
    rts
}
// TurretArmStep subroutine end
//////////////////////////////////////////////////////////////////////////////

