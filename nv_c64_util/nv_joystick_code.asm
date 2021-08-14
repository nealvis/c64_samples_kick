//////////////////////////////////////////////////////////////////////////////
// nv_joystick_code.asm
//////////////////////////////////////////////////////////////////////////////
// The following subroutines should be called from the main engine
// as follows
// JoyInit: Call once before main loop and before other routines
// JoyScan: Call once every raster frame through the main loop
// JoyCleanup: Call at end of program after main loop to clean up
//////////////////////////////////////////////////////////////////////////////


#importonce

#if !NV_C64_UTIL_DATA
.error "Error - nv_joystick_code.asm: NV_C64_UTIL_DATA not defined.  Import nv_c64_util_data.asm"
#endif
// the #if above doesn't seem to always work so..
// if data hasn't been imported yet, import it into default location
#importif !NV_C64_UTIL_DATA "nv_c64_util_default_data.asm"

#import "nv_joystick_macs.asm"
#import "nv_screen_macs.asm"

.const JOY_PORT1_ADDR = $DC01  // 56321
.const JOY_PORT2_ADDR = $DC00  // 56320
.const JOY_UP_MASK = $01
.const JOY_DOWN_MASK = $02
.const JOY_LEFT_MASK = $04
.const JOY_RIGHT_MASK = $08
.const JOY_FIRE_MASK = $10

.const JOY_PORT_1_ID = $00
.const JOY_PORT_2_ID = $01

////////////////////
// some joystick variables
nv_joy_port1_state: .byte $00
nv_joy_port2_state: .byte $00

//////////////////////////////////////////////////////////////////////////////
// JoyInit
// initialize everything needed for joystick reading
JoyInit:
{
    lda #$00
    sta nv_joy_port1_state
    sta nv_joy_port2_state
    rts
}
// JoyInit - End
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// JoyScan
// initialize everything needed for joystick reading
JoyScan:
{
    lda JOY_PORT1_ADDR
    eor #$FF
    sta nv_joy_port1_state
    //nv_screen_poke_hex_byte_a(5, 0, true)


    lda JOY_PORT2_ADDR
    eor #$FF
    sta nv_joy_port2_state
    //nv_screen_poke_hex_byte_a(7, 0, true)


    rts
}
// JoyScan - End
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// subroutine to put the current state of joysticks into x, y regs
// x gets port 1 state and y gets port 2 state.
// note this routine assumes that JoyScan is being called regularly
JoyCurStateXY:
{
    ldx nv_joy_port1_state
    ldy nv_joy_port2_state
    rts
}
// JoyCurStateXY end
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// subroutine to determine if the joystick is in up state for a particular
// joystick port.  
// params:
//   x reg: the ID for joystick port for which the state is wanted
//   accum: upon return will be 0 if its not in up state or non zero if is
// accum: changes
// x reg: unchanged
// y reg: unchanged
JoyIsUp:
{
    lda #JOY_UP_MASK
    and nv_joy_port1_state, x 
    rts
}
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// subroutine to determine if the joystick is in down state for a particular
// joystick port.  
// params:
//   x reg: the ID for joystick port for which the state is wanted
//   accum: upon return will be 0 if its not in down state or nonzero if is
// accum: changes
// x reg: unchanged
// y reg: unchanged
JoyIsDown:
{
    lda #JOY_DOWN_MASK
    and nv_joy_port1_state, x 
    rts
}
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// subroutine to determine if the joystick is in left state for a particular
// joystick port.  
// params:
//   x reg: the ID for joystick port for which the state is wanted
//   accum: upon return will be 0 if its not in left state or nonzero if is
// accum: changes
// x reg: unchanged
// y reg: unchanged
JoyIsLeft:
{
    lda #JOY_LEFT_MASK
    and nv_joy_port1_state, x 
    rts
}
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// subroutine to determine if the joystick is in right state for a particular
// joystick port.  
// params:
//   x reg: the ID for joystick port for which the state is wanted
//   accum: upon return will be 0 if its not in right state or nonzero if is
// accum: changes
// x reg: unchanged
// y reg: unchanged
JoyIsRight:
{
    lda #JOY_RIGHT_MASK
    and nv_joy_port1_state, x 
    rts
}
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// subroutine to determine if the joystick fire button is pressed for a 
// particular joystick port.  
// params:
//   x reg: the ID for joystick port for which the state is wanted
//   accum: upon return will be 0 if its not firing or nonzero if is
// accum: changes
// x reg: unchanged
// y reg: unchanged
JoyIsFiring:
{
    lda #JOY_FIRE_MASK
    and nv_joy_port1_state, x 
    rts
}
//
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// JoyCleanup
// cleans up everything needed for joystick reading
JoyCleanup:
{
    lda #$00
    sta nv_joy_port1_state
    sta nv_joy_port2_state

    rts
}
// JoyCleanup - End
//////////////////////////////////////////////////////////////////////////////
