//////////////////////////////////////////////////////////////////////////////
// astro_ship_death_data.asm 
//////////////////////////////////////////////////////////////////////////////
// contains the data that is needed by astro_ship_death_code.asm
// This includes some variables that can be tested by the main engine
// to determine what to do.
// 
//////////////////////////////////////////////////////////////////////////////
#importonce

//////////////////////////////////////////////////////////////////////////////
// Constants

// number of frames the death lingers on
.const SHIP_DEATH_FRAMES = 250

// this is furthest left the ship will retreat
.const SHIP_DEATH_MIN_LEFT = $0019

// Constants end
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// internal variables

ship_death_pushed_left_min: .byte 0

// internal variables end
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// exposed variables, for engine to get state of ship death

// Will be zero when ship death effect is not active or 
// the number of frames remaining in the effect if it is active
ship_death_count: .byte 0

// exposed variables end
//////////////////////////////////////////////////////////////////////////////
