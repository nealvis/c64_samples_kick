//////////////////////////////////////////////////////////////////////////////
// nv_screen_rect_macs.asm
// contains inline macros for 8 bit math related functions.
// importing this file will not allocate any memory for data or code.
//////////////////////////////////////////////////////////////////////////////

#importonce

#if !NV_C64_UTIL_DATA
.error "Error - nv_math8_macs.asm: NV_C64_UTIL_DATA not defined.  Import nv_c64_util_data.asm"
#endif

// the #if above doesn't seem to always work so..
// if data hasn't been imported yet, import it into default location
#importif !NV_C64_UTIL_DATA "nv_c64_util_default_data.asm"

#import "nv_math16_macs.asm"

.const CHAR_PIXEL_WIDTH = $0008
.const CHAR_PIXEL_HEIGHT = $0008


//////////////////////////////////////////////////////////////////////////////
// inline macro to convert the character x, y location on screen
// to screen pixel coordinates
// Params: 
//   X Reg: character's X loc on screen
//   Y Reg: character's Y loc on screen
// macro params:
//   rect_addr: the address to an 8 byte struct that holds 4
//              16bit values that will be filled with values 
//              that are the screen coords for the screen 
//              char location.  the 16 bit values' order will be
//              left, top, right, bottom
.macro nv_screen_rect_char_coord_to_screen_pixels(rect_addr)
{
    .label r_left = rect_addr
    .label r_top = rect_addr + 2
    .label r_right = rect_addr + 4
    .label r_bottom = rect_addr + 6

    .const LEFT_OFFSET = 26
    .const TOP_OFFSET = 53

    /////// put char's rectangle in rect
    
    // LEFT
    // (col * CHAR_PIXEL_WIDTH) + LEFT_OFFSET
    nv_store16_immediate(r_left, CHAR_PIXEL_WIDTH)
    nv_mul16_x(r_left, r_left)
    nv_adc16_immediate(r_left, LEFT_OFFSET, r_left)
    
    // TOP
    // (row * CHAR_PIXEL_HEIGHT) + TOP_OFFSET
    nv_store16_immediate(r_top, CHAR_PIXEL_HEIGHT)
    nv_mul16_y(r_top, r_top)
    nv_adc16_immediate(r_top, TOP_OFFSET, r_top)

    // RIGHT
    // add width to the left to get right
    nv_adc16_immediate(r_left, CHAR_PIXEL_WIDTH, r_right)

    // BOTTOM
    // add height to the top to get the bottom
    nv_adc16_immediate(r_top, CHAR_PIXEL_HEIGHT, r_bottom)
}



//////////////////////////////////////////////////////////////////////////////
// inline macro to convert the character x, y location on character screen
// to rectangle of screen pixel coordinates.  This macro only updates the 
// left and top part of the rectangle though.  The right bottom will remain
// unchanged.  To create the full rectangle this should be paired with 
// the nv_screen_rect_char_coord_to_screen_pixels_right_bottom or the 
// nv_screen_rect_char_coord_to_screen_pixels_expand_right_bottom macro
// Params: 
//   X Reg: character's X loc on screen
//   Y Reg: character's Y loc on screen
// macro params:
//   rect_addr: the address to an 8 byte struct that holds 4
//              16bit values that will be filled with values 
//              that are the screen coords for the left top
//              for specified char location.  
//              the 16 bit values' order within the rect are be
//              left, top, right, bottom
.macro nv_screen_rect_char_coord_to_screen_pixels_left_top(rect_addr)
{
    .label r_left = rect_addr
    .label r_top = rect_addr + 2
    .label r_right = rect_addr + 4
    .label r_bottom = rect_addr + 6

    .const LEFT_OFFSET = 26
    .const TOP_OFFSET = 53
    .const CHAR_PIXEL_WIDTH = $0008
    .const CHAR_PIXEL_HEIGHT = $0008

    /////// put char's rectangle in rect
    
    // LEFT
    // (col * CHAR_PIXEL_WIDTH) + LEFT_OFFSET
    nv_store16_immediate(r_left, CHAR_PIXEL_WIDTH)
    nv_mul16_x(r_left, r_left)
    nv_adc16_immediate(r_left, LEFT_OFFSET, r_left)
    
    // TOP
    // (row * CHAR_PIXEL_HEIGHT) + TOP_OFFSET
    nv_store16_immediate(r_top, CHAR_PIXEL_HEIGHT)
    nv_mul16_y(r_top, r_top)
    nv_adc16_immediate(r_top, TOP_OFFSET, r_top)
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to convert the character x, y location on character screen
// to rectangle of screen pixel coordinates.  This macro only updates the 
// right and bottom part of the rectangle though.  The left top will remain
// unchanged.  To create the full rectangle this should be paired with 
// the nv_screen_rect_char_coord_to_screen_pixels_left_top or the 
// nv_screen_rect_char_coord_to_screen_pixels_expand_left_top macro
// Params: 
//   X Reg: character's X loc on screen
//   Y Reg: character's Y loc on screen
// macro params:
//   rect_addr: the address to an 8 byte struct that holds 4
//              16bit values that will be filled with values 
//              that are the screen coords for the right bottom
//              for specified char location.  
//              the 16 bit values' order within the rect are be
//              left, top, right, bottom
.macro nv_screen_rect_char_coord_to_screen_pixels_right_bottom(rect_addr)
{
    //.label r_left = rect_addr
    //.label r_top = rect_addr + 2
    .label r_right = rect_addr + 4
    .label r_bottom = rect_addr + 6

    .const LEFT_OFFSET = 26
    .const TOP_OFFSET = 53
    .const CHAR_PIXEL_WIDTH = $0008
    .const CHAR_PIXEL_HEIGHT = $0008

    /////// put char's right and bottom coords in rect

    // RIGHT
    // Set the right pixel coord value for char.  First need to set it to 
    // the left coord and then add the pixel width to get to the right
    nv_store16_immediate(r_right, CHAR_PIXEL_WIDTH)
    nv_mul16_x(r_right, r_right)
    nv_adc16_immediate(r_right, LEFT_OFFSET, r_right)
    // above code sets r_right to the left pixel position for char
    // now add char pixel width to it and it will be the right pixel position
    // for the char
    nv_adc16_immediate(r_right, CHAR_PIXEL_WIDTH, r_right)

    // BOTTOM
    // Set the bottom pixel coord value for char.  First need to set it to 
    // the top coord and then add the pixel height to get to the bottom
    nv_store16_immediate(r_bottom, CHAR_PIXEL_HEIGHT)
    nv_mul16_y(r_bottom, r_bottom)
    nv_adc16_immediate(r_bottom, TOP_OFFSET, r_bottom)
    // above code sets r_bottom to the top pixel position for char
    // now add char pixel height to it and it will be the bottom pixel position
    // for the char
    nv_adc16_immediate(r_bottom, CHAR_PIXEL_HEIGHT, r_bottom)
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to expand a rect some number of characters in the 
// x and y directions. before this macro code is executed the rect
// must already have the left, top coordinates filled in to be valid
// pixel values.  This macro will add to those values to get the
// right, bottom pixel locations and fill those in the rect.
// Params: 
//   X Reg: the number of characters to expand in the X direction
//          if pass zero then the resulting rectangle will be the width
//          of one character
//   Y Reg: the number of characters to expand the rect in the Y direction
//          If pass zero then the resulting rectangle will be one char high
// macro params:
//   rect_addr: the address to an 8 byte struct that holds 4
//              16bit values that will be filled with values 
//              that are the screen coords for the screen 
//              char location.  the 16 bit values' order will be
//              left, top, right, bottom
//              before executing macro the left, top values must be 
//              filled in with valid screen/pixel coordinates
.macro nv_screen_rect_char_coord_to_screen_pixels_expand_right_bottom(rect_addr)
{
    .label r_left = rect_addr
    .label r_top = rect_addr + 2
    .label r_right = rect_addr + 4
    .label r_bottom = rect_addr + 6

    .const LEFT_OFFSET = 26
    .const TOP_OFFSET = 53
    .const CHAR_PIXEL_WIDTH = $0008
    .const CHAR_PIXEL_HEIGHT = $0008


    /////// put char's rectangle in rect
    
    // RIGHT
    nv_store16_immediate(r_right, CHAR_PIXEL_WIDTH)       // start width
    nv_mul16_x(r_right, r_right)                          // mul by X for inc
    nv_adc16(r_left, r_right, r_right)
    nv_adc16_immediate(r_right, CHAR_PIXEL_WIDTH, r_right)

    // BOTTOM
    // add height to the top to get the bottom
    nv_store16_immediate(r_bottom, CHAR_PIXEL_HEIGHT)       // start width
    nv_mul16_y(r_bottom, r_bottom)                          // mul by Y for inc
    nv_adc16(r_top, r_bottom, r_bottom)
    nv_adc16_immediate(r_bottom, CHAR_PIXEL_HEIGHT, r_bottom)
}


//////////////////////////////////////////////////////////////////////////////
// function that returns the pixel X location for the left edge of the 
// character at the specified character row and col
// function params:
//   char_x: the column of the character for which the left edge will be
//           returned
//   char_y: the row of the character for which the left edge will be 
//             returned.  Valid values depend on screen mode but default
//             mode is 0-24
// returns: the screen pixel x location of the left edge of the char
//          at (char_x, char_y) on the screen
.function nv_screen_rect_char_to_screen_pixel_left(char_x, char_y)
{
    .var r_left
    .var r_top
    .var r_right
    .var r_bottom

    .const LEFT_OFFSET = 26
    .const TOP_OFFSET = 53
   
    // LEFT
    // (col * CHAR_PIXEL_WIDTH) + LEFT_OFFSET
    .eval r_left = CHAR_PIXEL_WIDTH
    .eval r_left = r_left * char_x
    .eval r_left = r_left + LEFT_OFFSET
    
    // TOP
    // (row * CHAR_PIXEL_HEIGHT) + TOP_OFFSET
    .eval r_top = CHAR_PIXEL_HEIGHT
    .eval r_top = r_top * char_y
    .eval r_top = r_top + TOP_OFFSET

    // RIGHT
    // add width to the left to get right
    .eval r_right =  r_left + CHAR_PIXEL_WIDTH

    // BOTTOM
    // add height to the top to get the bottom
    .eval r_bottom = r_top + CHAR_PIXEL_HEIGHT

    .return r_left
}


//////////////////////////////////////////////////////////////////////////////
// function that returns the pixel Y location for the top edge of the 
// character at the specified character row and col
// function params:
//   char_x: the column of the character for which the top edge will be
//           returned
//   char_y: the row of the character for which the top edge will be 
//             returned.  Valid values depend on screen mode but default
//             mode is 0-24
// returns: the screen pixel x location of the top edge of the char
//          at (char_x, char_y) on the screen
.function nv_screen_rect_char_to_screen_pixel_top(char_x, char_y)
{
    .var r_left
    .var r_top
    .var r_right
    .var r_bottom

    .const LEFT_OFFSET = 26
    .const TOP_OFFSET = 53
   
    // LEFT
    // (col * CHAR_PIXEL_WIDTH) + LEFT_OFFSET
    .eval r_left = CHAR_PIXEL_WIDTH
    .eval r_left = r_left * char_x
    .eval r_left = r_left + LEFT_OFFSET
    
    // TOP
    // (row * CHAR_PIXEL_HEIGHT) + TOP_OFFSET
    .eval r_top = CHAR_PIXEL_HEIGHT
    .eval r_top = r_top * char_y
    .eval r_top = r_top + TOP_OFFSET

    // RIGHT
    // add width to the left to get right
    .eval r_right =  r_left + CHAR_PIXEL_WIDTH

    // BOTTOM
    // add height to the top to get the bottom
    .eval r_bottom = r_top + CHAR_PIXEL_HEIGHT

    .return r_top
}

//////////////////////////////////////////////////////////////////////////////
// function that returns the pixel X location for the right edge of the 
// character at the specified character row and col
// function params:
//   char_x: the column of the character for which the right edge will be
//           returned
//   char_y: the row of the character for which the right edge will be 
//             returned.  Valid values depend on screen mode but default
//             mode is 0-24
// returns: the screen pixel x location of the right edge of the char
//          at (char_x, char_y) on the screen
.function nv_screen_rect_char_to_screen_pixel_right(char_x, char_y)
{
    .var r_left
    .var r_top
    .var r_right
    .var r_bottom

    .const LEFT_OFFSET = 26
    .const TOP_OFFSET = 53
   
    // LEFT
    // (col * CHAR_PIXEL_WIDTH) + LEFT_OFFSET
    .eval r_left = CHAR_PIXEL_WIDTH
    .eval r_left = r_left * char_x
    .eval r_left = r_left + LEFT_OFFSET
    
    // TOP
    // (row * CHAR_PIXEL_HEIGHT) + TOP_OFFSET
    .eval r_top = CHAR_PIXEL_HEIGHT
    .eval r_top = r_top * char_y
    .eval r_top = r_top + TOP_OFFSET

    // RIGHT
    // add width to the left to get right
    .eval r_right =  r_left + CHAR_PIXEL_WIDTH

    // BOTTOM
    // add height to the top to get the bottom
    .eval r_bottom = r_top + CHAR_PIXEL_HEIGHT

    .return r_right
}

//////////////////////////////////////////////////////////////////////////////
// function that returns the pixel X location for the bottom edge of the 
// character at the specified character row and col
// function params:
//   char_x: the column of the character for which the bottom edge will be
//           returned
//   char_y: the row of the character for which the bottom edge will be 
//             returned.  Valid values depend on screen mode but default
//             mode is 0-24
// returns: the screen pixel x location of the bottom edge of the char
//          at (char_x, char_y) on the screen
.function nv_screen_rect_char_to_screen_pixel_bottom(char_x, char_y)
{
    .var r_left
    .var r_top
    .var r_right
    .var r_bottom

    .const LEFT_OFFSET = 26
    .const TOP_OFFSET = 53
   
    // LEFT
    // (col * CHAR_PIXEL_WIDTH) + LEFT_OFFSET
    .eval r_left = CHAR_PIXEL_WIDTH
    .eval r_left = r_left * char_x
    .eval r_left = r_left + LEFT_OFFSET
    
    // TOP
    // (row * CHAR_PIXEL_HEIGHT) + TOP_OFFSET
    .eval r_top = CHAR_PIXEL_HEIGHT
    .eval r_top = r_top * char_y
    .eval r_top = r_top + TOP_OFFSET

    // RIGHT
    // add width to the left to get right
    .eval r_right =  r_left + CHAR_PIXEL_WIDTH

    // BOTTOM
    // add height to the top to get the bottom
    .eval r_bottom = r_top + CHAR_PIXEL_HEIGHT

    .return r_bottom
}

