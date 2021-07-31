// astro_wind_data
#importonce

//////////////////
// wind variables and consts

// when ship x location increases into higher zones the x velocity is
// adjusted by a bigger number.  these are the start each zone
.const WIND_X_ZONE_2 = 200
.const WIND_X_ZONE_3 = 240

// the left most position for a ship.  if it reaches this position 
// then it will bounce to the right and be done with that wind
.const WIND_SHIP_MIN_LEFT = $0019

// cap the negative x velocity at this 
.const WIND_MAX_X_NEG_VEL = $FE // -2


// flags that are set to 0 upon wind start and 
// set to nonzero when a ship is done with that gust of wind
// Probably because of bouncing from the left edge
wind_ship_1_done: .byte 0
wind_ship_2_done: .byte 0

// reduce velocity while count greater than 0
wind_count: .byte 0


//////////////////////////////////////////////////////////////////////////////
// Data that will be modified via this wind effect and the main program can 
// take actions upon

// amount to decrement velocity for ship 1.  temp
// just needed during WindStep
wind_ship1_dec_value: .byte 0
wind_ship2_dec_value: .byte 0

