
//////////////////////////////////////////////////////////////////////////////
// astro_vars_data.asm
#import "../nv_c64_util/nv_color_macs.asm"

#importonce

.const ASTRO_FPS = 60


border_color: .byte NV_COLOR_BLUE
background_color: .byte NV_COLOR_BLACK

.const ASTRO_GAME_SECONDS_DEFAULT = $0060

// some loop indices
frame_counter: .word 0
second_counter: .word 0
astro_game_seconds: .word 0         // BCD game end seconds count down to zero
astro_end_on_seconds: .byte 0        // if zero then play until score reached, 
                                    // if non zero then play till seconds reached
change_up_counter: .word 0
second_partial_counter: .word 0
key_cool_counter: .byte 0
quit_flag: .byte 0                  // set to non zero to quit
sprite_collision_reg_value: .byte 0 // updated each frame with sprite coll

cycling_color: .byte NV_COLOR_FIRST
//change_up_flag: .byte 0

// mask to tell us when to start wind
wind_start_mask: .byte $03

// engine will set to 1 when turret hits ship 1
// set to 1 when hits ship.  This can move to main program
// the turret will just update the bullet's death rectangle
turret_hit_ship_1: .byte 0

// difficulty mode for the game.
// setup other vars based on this value
.const ASTRO_DIFF_EASY = 1
.const ASTRO_DIFF_MED = 2
.const ASTRO_DIFF_HARD = 3
astro_diff_mode: .byte ASTRO_DIFF_EASY // 1=easy, 2=med, 3=hard

// set this to the number of frames to wait before the auto turret fires
.const ASTRO_AUTO_TURRET_WAIT_FRAMES_EASY = ASTRO_FPS * 6
.const ASTRO_AUTO_TURRET_WAIT_FRAMES_MED = ASTRO_FPS * 4
.const ASTRO_AUTO_TURRET_WAIT_FRAMES_HARD = ASTRO_FPS * 2.3
astro_auto_turret_wait_frames: .word ASTRO_AUTO_TURRET_WAIT_FRAMES_EASY
astro_auto_turret_next_shot_frame: .word ASTRO_AUTO_TURRET_WAIT_FRAMES_EASY


// this is the score required to win the game it in BCD format
// the constant is the default value if not changed in title screen
.const ASTRO_DEFAULT_SCORE_TO_WIN = $0100
astro_score_to_win: .word ASTRO_DEFAULT_SCORE_TO_WIN

// when nonzero the game loop goes to slowmo mode.
astro_slow_motion: .byte 0

// this is the sprite multi color 1 color.  it toggles to 
// make the ship exhaust look like its flickering
astro_multi_color1: .byte NV_COLOR_LITE_GREEN

// one flag for each joystick.  For player to shoot turret it must be nonzero
// This forces players to unpress fire then repress it every time the turret
// is armed and prevents a player from just holding down the fire button.
astro_joy1_no_fire_flag: .byte 1
astro_joy2_no_fire_flag: .byte 1
