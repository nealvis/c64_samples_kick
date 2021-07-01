// sprite test program

// import some macros 
#import "../nv_c64_util/nv_c64_util.asm"


*=$0801 "BASIC Start"  // location to put a 1 line basic program so we can just
        // type run to execute the assembled program.
        // will just call assembled program at correct location
        //    10 SYS (4096)

        // These bytes are a one line basic program that will 
        // do a sys call to assembly language portion of
        // of the program which will be at $1000 or 4096 decimal
        // basic line is: 
        // 10 SYS (4096)
        .byte $0E, $08           // Forward address to next basic line
        .byte $0A, $00           // this will be line 10 ($0A)
        .byte $9E                // basic token for SYS
        .byte $20, $28, $34, $30, $39, $36, $29 // ASCII for " (4096)"
        .byte $00, $00, $00      // end of basic program (addr $080E from above)

*=$0820 "Vars"

// min and max speed for all sprites
.const MAX_SPEED = 6
.const MIN_SPEED = -6
.const FPS = 60

// some loop indices
frame_counter: .word 0
second_counter: .word 0
second_partial_counter: .word 0


cycling_color: .byte NV_COLOR_FIRST
change_up_flag: .byte 0

// set the address for our sprite, sprite_0 aka sprite_ship.  It must be evenly divisible by 64
// since code starts at $1000 there is room for 4 sprites between $0900 and $1000
*=$0900 "SpriteData"

        // Byte 64 of each sprite contains the following:
        //   high nibble: high bit set (8) if multi color, or cleared (0) if single color/high res
        //   low nibble: this sprite's color in it 0-F
        sprite_ship:
        // saved from spritemate
        // sprite 0 / multicolor / color: $04
        sprite_0:
        .byte $00,$00,$00,$00,$00,$00,$00,$00
        .byte $00,$40,$00,$00,$13,$c0,$00,$5e
        .byte $b0,$00,$5e,$ac,$00,$12,$ab,$00
        .byte $43,$aa,$c0,$03,$aa,$b0,$00,$aa
        .byte $ac,$03,$aa,$b0,$43,$aa,$c0,$12
        .byte $ab,$00,$5e,$ac,$00,$5e,$b0,$00
        .byte $13,$c0,$00,$40,$00,$00,$00,$00
        .byte $00,$00,$00,$00,$00,$00,$00,$84

        sprite_asteroid_1:
        // saved from spritemate:
        // sprite 1 / singlecolor / color: $0f
        sprite_1:
        .byte $00,$3f,$00,$00,$7f,$80,$00,$ff
        .byte $c0,$00,$ff,$c0,$1f,$ff,$c0,$3f
        .byte $ff,$e0,$7f,$ff,$fc,$7f,$ff,$fe
        .byte $7f,$ff,$fe,$7f,$ff,$fe,$3f,$ff
        .byte $fe,$1f,$ff,$fe,$1f,$ff,$fc,$1f
        .byte $ff,$fc,$1f,$ff,$f8,$1f,$ff,$f8
        .byte $1f,$ff,$f0,$0f,$f1,$c0,$0f,$e0
        .byte $80,$03,$c0,$00,$00,$00,$00,$0f

        sprite_asteroid_2:
        // saved from spritemate:
        // sprite 2 / singlecolor / color: $0f
        sprite_2:
        .byte $00,$3f,$00,$00,$7f,$80,$00,$ff
        .byte $c0,$00,$ff,$c0,$1f,$ff,$c0,$3f
        .byte $ff,$e0,$7f,$ff,$fc,$7f,$ff,$fe
        .byte $7f,$ff,$fe,$7f,$ff,$fe,$3f,$ff
        .byte $fe,$1f,$ff,$fe,$1f,$ff,$fc,$1f
        .byte $ff,$fc,$1f,$ff,$f8,$1f,$ff,$f8
        .byte $1f,$ff,$f0,$0f,$f1,$c0,$0f,$e0
        .byte $80,$03,$c0,$00,$00,$00,$00,$0d

       sprite_asteroid_3:
        // saved from spritemate:
        // sprite 3 / singlecolor / color: $0f
        sprite_3:
        .byte $00,$3f,$00,$00,$7f,$80,$00,$ff
        .byte $c0,$00,$ff,$c0,$1f,$ff,$c0,$3f
        .byte $ff,$e0,$7f,$ff,$fc,$7f,$ff,$fe
        .byte $7f,$ff,$fe,$7f,$ff,$fe,$3f,$ff
        .byte $fe,$1f,$ff,$fe,$1f,$ff,$fc,$1f
        .byte $ff,$fc,$1f,$ff,$f8,$1f,$ff,$f8
        .byte $1f,$ff,$f0,$0f,$f1,$c0,$0f,$e0
        .byte $80,$03,$c0,$00,$00,$00,$00,$0c

        sprite_asteroid_4:
        // saved from spritemate:
        // sprite 3 / singlecolor / color: $0f
        sprite_4:
        .byte $00,$3f,$00,$00,$7f,$80,$00,$ff
        .byte $c0,$00,$ff,$c0,$1f,$ff,$c0,$3f
        .byte $ff,$e0,$7f,$ff,$fc,$7f,$ff,$fe
        .byte $7f,$ff,$fe,$7f,$ff,$fe,$3f,$ff
        .byte $fe,$1f,$ff,$fe,$1f,$ff,$fc,$1f
        .byte $ff,$fc,$1f,$ff,$f8,$1f,$ff,$f8
        .byte $1f,$ff,$f0,$0f,$f1,$c0,$0f,$e0
        .byte $80,$03,$c0,$00,$00,$00,$00,$0e

        sprite_asteroid_5:
        // saved from spritemate:
        // sprite 3 / singlecolor / color: $0f
        sprite_5:
        .byte $00,$3f,$00,$00,$7f,$80,$00,$ff
        .byte $c0,$00,$ff,$c0,$1f,$ff,$c0,$3f
        .byte $ff,$e0,$7f,$ff,$fc,$7f,$ff,$fe
        .byte $7f,$ff,$fe,$7f,$ff,$fe,$3f,$ff
        .byte $fe,$1f,$ff,$fe,$1f,$ff,$fc,$1f
        .byte $ff,$fc,$1f,$ff,$f8,$1f,$ff,$f8
        .byte $1f,$ff,$f0,$0f,$f1,$c0,$0f,$e0
        .byte $80,$03,$c0,$00,$00,$00,$00,$0e


// our assembly code will goto this address
*=$1000 "Main Start"

        // clear the screen just to have an empty canvas
        nv_screen_clear()

        // set the global sprite multi colors        
        nv_sprite_raw_set_multicolors(NV_COLOR_LITE_GREEN, NV_COLOR_WHITE)

        // setup everything for the sprite_ship so its ready to enable
        jsr ship_1.Setup

        // setup everything for the sprite_asteroid so its ready to enable
        jsr asteroid_1.Setup
        jsr asteroid_2.Setup
        jsr asteroid_3.Setup
        jsr asteroid_4.Setup
        jsr asteroid_5.Setup


        // initialize sprite locations from their extra data blocks 
        jsr ship_1.SetLocationFromExtraData
        jsr asteroid_1.SetLocationFromExtraData
        jsr asteroid_2.SetLocationFromExtraData
        jsr asteroid_3.SetLocationFromExtraData
        jsr asteroid_4.SetLocationFromExtraData
        jsr asteroid_5.SetLocationFromExtraData
        
        // enable sprites
        jsr ship_1.Enable
        jsr asteroid_1.Enable
        jsr asteroid_2.Enable
        jsr asteroid_3.Enable
        jsr asteroid_4.Enable
        jsr asteroid_5.Enable



MainLoop:

        nv_adc16_immediate(frame_counter, 1, frame_counter)
        nv_adc16_immediate(second_partial_counter, 1, second_partial_counter)
        nv_ble16_immediate(second_partial_counter, FPS, PartialSecond1)
        jmp FullSecond
PartialSecond1:
        jmp PartialSecond2
FullSecond:
        lda #0 
        sta second_partial_counter
        sta second_partial_counter+1
        nv_adc16_immediate(second_counter, 1, second_counter)
        lda #$03
        and second_counter  //set flag every 4 secs when bits 0 and 1 clear
        bne NoSetFlag
        lda #1
        sta change_up_flag
NoSetFlag:
        //nv_screen_plot_cursor(0, 7)
        //nv_screen_print_hex_word(second_counter, true)
PartialSecond2:
        //nv_screen_plot_cursor(0, 0)
        //nv_screen_print_hex_word(frame_counter, true)


        //// call function to move sprites around based on X and Y velocity
        // but only modify the position in their extra data block not on screen
        lda #NV_COLOR_LITE_GREEN                      // change border color back to
        sta $D020                                     // visualize timing
        jsr ship_1.MoveInExtraData
        jsr asteroid_1.MoveInExtraData
        jsr asteroid_2.MoveInExtraData
        jsr asteroid_3.MoveInExtraData
        jsr asteroid_4.MoveInExtraData
        jsr asteroid_5.MoveInExtraData

        lda #1 
        bit change_up_flag
        beq NoChangeUp
YesChangeUp:
        // every few seconds change up some sprite properties
        jsr ChangeUp 
        lda #0 
        sta change_up_flag
NoChangeUp:


        // not changing this frame, 
        lda #NV_COLOR_LITE_BLUE                // change border color back to
        sta $D020                              // visualize timing
        nv_sprite_wait_last_scanline()         // wait for particular scanline.
        lda #NV_COLOR_GREEN                    // change border color to  
        sta $D020                              // visualize timing

        jsr ship_1.SetLocationFromExtraData
        jsr asteroid_1.SetLocationFromExtraData
        jsr asteroid_2.SetLocationFromExtraData
        jsr asteroid_3.SetLocationFromExtraData
        jsr asteroid_4.SetLocationFromExtraData
        jsr asteroid_5.SetLocationFromExtraData

        //// call routine to update sprite x and y positions on screen
        jsr CheckCollisions
        lda closest_sprite
        beq IgnoreCollision
HandleCollision:
        nv_sprite_raw_disable_from_mem(closest_sprite)

        //nv_screen_plot_cursor(0, 15)
        //nv_screen_print_hex_byte_at_addr(closest_sprite, true)
        //nv_screen_wait_anykey()

IgnoreCollision:
        jmp MainLoop

ProgramDone:
        // Done moving sprites, move cursor out of the way 
        // and return, but leave the sprites on the screen
        // also set border color to normal
        lda #NV_COLOR_LITE_BLUE
        sta $D020

        nv_screen_plot_cursor(5, 24)
        rts   // program done, return


//////////////////////////////////////////////////////////////////////////////
// subroutine to cycle the color of a sprite just to show how
// the nv_sprite_set_color_from_memory macro works.
ChangeUp:
        ldx cycling_color
        inx
        cpx #NV_COLOR_BLUE // blue is default backgroumd, so skip that one
        bne NotBlue
        inx
NotBlue:
        cpx #NV_COLOR_LAST + 1
        bne SetColor
        ldx #NV_COLOR_FIRST
        stx cycling_color
SetColor:
        stx cycling_color
        nv_sprite_raw_set_color_from_memory(1, cycling_color)

        // change some speeds
        dec ship_1.x_vel          // decrement ship speed
        bne SkipShipMax         // if its not zero yet then skip setting to max
        lda #MAX_SPEED          // if it is zero then set it back to the max speed
        sta ship_1.x_vel          // save the new ship speed (max speed)

SkipShipMax:                   
        inc asteroid_1.y_vel    // increment asteroid Y velocity 
        lda asteroid_1.y_vel    // load new speed just incremented
        cmp #MAX_SPEED+1        // compare new spead with max +1
        bne SkipAsteroidMin     // if we haven't reached max + 1 then skip setting to min
        lda #MIN_SPEED          // else, we have reached max+1 so need to reset it back min
        sta asteroid_1.y_vel

SkipAsteroidMin:
        rts

//////////////////////////////////////////////////////////////////////////////
//
CheckCollisions: 
        lda #$FF
        sta closest_rel_dist
        lda #$00
        sta closest_sprite
        lda #$8F 
        sta closest_rel_dist + 1

        nv_sprite_raw_get_sprite_collisions_in_a()

        sta collision_bit
        ror collision_bit        // rotate bit for sprite 0 (ship) bit to carry
        bcs SkipJump 
        jmp ClosestSpriteSet
SkipJump:

        // carry is set here
        ror collision_bit        // rotate bit for sprite 1 bit to carry
        bcc CheckSprite2
WasSprite1:
        jsr GetDistance_0_1
        nv_bge16(temp_rel_dist, closest_rel_dist, CheckSprite2)
        lda temp_rel_dist
        sta closest_rel_dist
        lda temp_rel_dist+1
        sta closest_rel_dist+1
        lda #1
        sta closest_sprite
        jmp CheckSprite2

CheckSprite2:
        ror collision_bit        // rotate bit for sprite 2 bit to carry
        bcc CheckSprite3

WasSprite2:
        jsr GetDistance_0_2
        nv_bge16(temp_rel_dist, closest_rel_dist, CheckSprite3)
        lda temp_rel_dist
        sta closest_rel_dist
        lda temp_rel_dist+1
        sta closest_rel_dist+1
        lda #2
        sta closest_sprite
        jmp CheckSprite3

CheckSprite3:
        ror collision_bit        // rotate bit for sprite 3 bit to carry
        bcc CheckSprite4

WasSprite3:
        jsr GetDistance_0_3
        nv_bge16(temp_rel_dist, closest_rel_dist, CheckSprite4)
        lda temp_rel_dist
        sta closest_rel_dist
        lda temp_rel_dist+1
        sta closest_rel_dist+1
        lda #3
        sta closest_sprite
        jmp CheckSprite4

CheckSprite4:
        ror collision_bit        // rotate bit for sprite 4 bit to carry
        bcc CheckSprite5

WasSprite4:
        jsr GetDistance_0_4
        nv_bge16(temp_rel_dist, closest_rel_dist, CheckSprite5)
        lda temp_rel_dist
        sta closest_rel_dist
        lda temp_rel_dist+1
        sta closest_rel_dist+1
        lda #4
        sta closest_sprite
        jmp CheckSprite5

CheckSprite5:
        ror collision_bit        // rotate bit for sprite 5 bit to carry
        bcc CheckSprite6

WasSprite5:
        jsr GetDistance_0_5
        nv_bge16(temp_rel_dist, closest_rel_dist, CheckSprite6)
        lda temp_rel_dist
        sta closest_rel_dist
        lda temp_rel_dist+1
        sta closest_rel_dist+1
        lda #5
        sta closest_sprite
        jmp CheckSprite6

CheckSprite6:
        ror collision_bit        // rotate bit for sprite 6 bit to carry
        ror collision_bit        // rotate bit for sprite 7 bit to carry
        ror collision_bit        // rotate bit for sprite 8 bit to carry

ClosestSpriteSet: 
        rts

collision_bit: .byte 0
closest_sprite: .byte 0
closest_rel_dist: .word 0
temp_rel_dist: .word 0

//save_collisions: .byte 0



temp_x_dist: .word 0
temp_y_dist: .word 0
temp_x_a: .word 0
temp_y_a: .word 0
temp_x_b: .word 0
temp_y_b: .word 0
blank_str: .text @"                                       \$00"
//////////////////////////////////////////////////////////////////////////////
// macro to get relative distance between two sprites
// the word (16 bit) whose LSB is at rel_dist_addr will return the distance
// between the two sprites
.macro nv_sprite_raw_get_relative_distance(spt_num_a, spt_num_b, rel_dist_addr)
{
    // clear the MSB of our temps
    lda #0 
    sta temp_y_a+1
    sta temp_y_b+1

    nv_sprite_raw_get_location(spt_num_a, temp_x_a, temp_y_a)

    //nv_screen_plot_cursor(24, 0)
    //nv_screen_print_string_basic(blank_str)

    nv_sprite_raw_get_location(spt_num_a, temp_x_a, temp_y_a)
    nv_sprite_raw_get_location(spt_num_b, temp_x_b, temp_y_b)

    nv_bge16(temp_x_a, temp_x_b, BiggerAX)
BiggerBX:
    nv_sbc16(temp_x_b, temp_x_a, temp_x_dist)
    jmp FindDistY
BiggerAX:
    nv_sbc16(temp_x_a, temp_x_b, temp_x_dist)

FindDistY:
    nv_bge16(temp_y_a, temp_y_b, BiggerAY)
BiggerBY:
    nv_adc16(temp_x_dist, temp_y_b, rel_dist_addr)
    nv_sbc16(rel_dist_addr, temp_y_a, rel_dist_addr)
    jmp DebugPrint
BiggerAY:
    nv_adc16(temp_x_dist, temp_y_a, rel_dist_addr)
    nv_sbc16(rel_dist_addr, temp_y_b, rel_dist_addr)

DebugPrint:
/*
    nv_screen_plot_cursor(24, 0)
    lda #spt_num_b
    nv_screen_print_hex_byte(true)
    nv_screen_plot_cursor(24, 5)
    nv_screen_print_hex_word(temp_x_b, true)
    nv_screen_plot_cursor(24, 12)
    nv_screen_print_hex_byte_at_addr(temp_y_b, true)
    //nv_screen_plot_cursor(24,28)
    //nv_screen_print_hex_word(temp_x_dist, true)
    nv_screen_plot_cursor(24,34)
    nv_screen_print_hex_word(rel_dist_addr, true)

    nv_screen_wait_anykey()
*/
}

.macro nv_sprite_raw_get_relative_distance_sr(spt_num_a, spt_num_b, rel_dist)
{
    nv_sprite_raw_get_relative_distance(spt_num_a, spt_num_b, rel_dist)
    rts
}

GetDistance_0_1:
    nv_sprite_raw_get_relative_distance_sr(0, 1, temp_rel_dist)

GetDistance_0_2:
    nv_sprite_raw_get_relative_distance_sr(0, 2, temp_rel_dist)

GetDistance_0_3:
    nv_sprite_raw_get_relative_distance_sr(0, 3, temp_rel_dist)

GetDistance_0_4:
    nv_sprite_raw_get_relative_distance_sr(0, 4, temp_rel_dist)

GetDistance_0_5:
    nv_sprite_raw_get_relative_distance_sr(0, 5, temp_rel_dist)

//////////////////////////////////////////////////////////////////////////////
// Namespace with everything related to asteroid 1
.namespace asteroid_1
{
        .var info = nv_sprite_info_struct("asteroid_1", 1, 
                                          30, 180, -1, 0,     // init x, y, VelX, VelY
                                          sprite_asteroid_1, 
                                          sprite_extra, 
                                          1, 1, 1, 1, // bounce on top, left, bottom, right  
                                          0, 0, 0, 0) // min/max top, left, bottom, right

        .label x_loc = info.base_addr + NV_SPRITE_X_OFFSET
        .label y_loc = info.base_addr + NV_SPRITE_Y_OFFSET
        .label x_vel = info.base_addr + NV_SPRITE_VEL_X_OFFSET
        .label y_vel = info.base_addr + NV_SPRITE_VEL_Y_OFFSET

// sprite extra data
sprite_extra:
        nv_sprite_extra_data(info)

// subroutine to set sprites location in sprite registers based on the extra data
SetLocationFromExtraData:
        lda #>info.base_addr
        ldx #<info.base_addr
        jsr NvSpriteSetLocationFromExtra
        rts
        //nv_sprite_set_location_from_memory_sr(info.num, info.base_addr+NV_SPRITE_X_OFFSET, info.base_addr+NV_SPRITE_Y_OFFSET)

// setup sprite so that it ready to be enabled and displayed
Setup:
        lda #>info.base_addr
        ldx #<info.base_addr
        jsr NvSpriteSetupFromExtra
        rts

// move the sprite x and y location in the extra data only, not in the sprite registers
// to move in the sprite registsers (and have screen reflect it) call the 
// SetLocationFromExtraData subroutine.
MoveInExtraData:
        //lda #>info.base_addr
        //ldx #<info.base_addr
        //jsr NvSpriteMoveInExtra
        //rts
        nv_sprite_move_any_direction_sr(info)

Enable:
        nv_sprite_raw_enable_sr(info.num)
        
SetBounceAllOn:
        nv_sprite_set_all_actions_sr(info, NV_SPRITE_ACTION_BOUNCE)

SetWrapAllOn:
        nv_sprite_set_all_actions_sr(info, NV_SPRITE_ACTION_WRAP)
}

//////////////////////////////////////////////////////////////////////////////
// Namespace with everything related to asteroid 2
.namespace asteroid_2
{
        .var info = nv_sprite_info_struct("asteroid_2", 2, 
                                          80, 150, 1, 2, // init x, y, VelX, VelY
                                          sprite_asteroid_2, 
                                          sprite_extra, 
                                          1, 1, 1, 1, // bounce on top, left, bottom, right  
                                          0, 0, 0, 0) // min/max top, left, bottom, right

        .label x_loc = info.base_addr + NV_SPRITE_X_OFFSET
        .label y_loc = info.base_addr + NV_SPRITE_Y_OFFSET
        .label x_vel = info.base_addr + NV_SPRITE_VEL_X_OFFSET
        .label y_vel = info.base_addr + NV_SPRITE_VEL_Y_OFFSET

// sprite extra data
sprite_extra:
        nv_sprite_extra_data(info)

// subroutine to set sprites location in sprite registers based on the extra data
SetLocationFromExtraData:
        lda #>info.base_addr
        ldx #<info.base_addr
        jsr NvSpriteSetLocationFromExtra
        rts
        //nv_sprite_set_location_from_memory_sr(info.num, info.base_addr+NV_SPRITE_X_OFFSET, info.base_addr+NV_SPRITE_Y_OFFSET)

// setup sprite so that it ready to be enabled and displayed
Setup:
        lda #>info.base_addr
        ldx #<info.base_addr
        jsr NvSpriteSetupFromExtra
        rts

// move the sprite x and y location in the extra data only, not in the sprite registers
// to move in the sprite registsers (and have screen reflect it) call the 
// SetLocationFromExtraData subroutine.
MoveInExtraData:
        //lda #>info.base_addr
        //ldx #<info.base_addr
        //jsr NvSpriteMoveInExtra
        //rts
        nv_sprite_move_any_direction_sr(info)

Enable:
        nv_sprite_raw_enable_sr(info.num)
        
SetBounceAllOn:
        nv_sprite_set_all_actions_sr(info, NV_SPRITE_ACTION_BOUNCE)

SetWrapAllOn:
        nv_sprite_set_all_actions_sr(info, NV_SPRITE_ACTION_WRAP)
       
}


//////////////////////////////////////////////////////////////////////////////
// Namespace with everything related to asteroid 3
.namespace asteroid_3
{
        .var info = nv_sprite_info_struct("asteroid_3", 3, 
                                          75, 200, 2, -3,  // init x, y, VelX, VelY
                                          sprite_asteroid_3, 
                                          sprite_extra, 
                                          1, 1, 1, 1, // bounce on top, left, bottom, right  
                                          0, 0, 0, 0) // min/max top, left, bottom, right

        .label x_loc = info.base_addr + NV_SPRITE_X_OFFSET
        .label y_loc = info.base_addr + NV_SPRITE_Y_OFFSET
        .label x_vel = info.base_addr + NV_SPRITE_VEL_X_OFFSET
        .label y_vel = info.base_addr + NV_SPRITE_VEL_Y_OFFSET

// sprite extra data
sprite_extra:
        nv_sprite_extra_data(info)

// subroutine to set sprites location in sprite registers based on the extra data
SetLocationFromExtraData:
        lda #>info.base_addr
        ldx #<info.base_addr
        jsr NvSpriteSetLocationFromExtra
        rts
        //nv_sprite_set_location_from_memory_sr(info.num, info.base_addr+NV_SPRITE_X_OFFSET, info.base_addr+NV_SPRITE_Y_OFFSET)

// setup sprite so that it ready to be enabled and displayed
Setup:
        lda #>info.base_addr
        ldx #<info.base_addr
        jsr NvSpriteSetupFromExtra
        rts

// move the sprite x and y location in the extra data only, not in the sprite registers
// to move in the sprite registsers (and have screen reflect it) call the 
// SetLocationFromExtraData subroutine.
MoveInExtraData:
        //lda #>info.base_addr
        //ldx #<info.base_addr
        //jsr NvSpriteMoveInExtra
        //rts
        nv_sprite_move_any_direction_sr(info)

Enable:
        nv_sprite_raw_enable_sr(info.num)

SetBounceAllOn:
        nv_sprite_set_all_actions_sr(info, NV_SPRITE_ACTION_BOUNCE)

SetWrapAllOn:
        nv_sprite_set_all_actions_sr(info, NV_SPRITE_ACTION_WRAP)
}


//////////////////////////////////////////////////////////////////////////////
// Namespace with everything related to asteroid 4
.namespace asteroid_4
{
        .var info = nv_sprite_info_struct("asteroid_4", 4, 
                                          255, 155, 1, 1, // init x, y, VelX, VelY 
                                          sprite_asteroid_4, 
                                          sprite_extra, 
                                          0, 0, 0, 0, // bounce on top, left, bottom, right  
                                          0, 0, 0, 0) // min/max top, left, bottom, right

        .label x_loc = info.base_addr + NV_SPRITE_X_OFFSET
        .label y_loc = info.base_addr + NV_SPRITE_Y_OFFSET
        .label x_vel = info.base_addr + NV_SPRITE_VEL_X_OFFSET
        .label y_vel = info.base_addr + NV_SPRITE_VEL_Y_OFFSET

// sprite extra data
sprite_extra:
        nv_sprite_extra_data(info)

// subroutine to set sprites location in sprite registers based on the extra data
SetLocationFromExtraData:
        lda #>info.base_addr
        ldx #<info.base_addr
        jsr NvSpriteSetLocationFromExtra
        rts
        //nv_sprite_set_location_from_memory_sr(info.num, info.base_addr+NV_SPRITE_X_OFFSET, info.base_addr+NV_SPRITE_Y_OFFSET)

// setup sprite so that it ready to be enabled and displayed
Setup:
        lda #>info.base_addr
        ldx #<info.base_addr
        jsr NvSpriteSetupFromExtra
        rts

// move the sprite x and y location in the extra data only, not in the sprite registers
// to move in the sprite registsers (and have screen reflect it) call the 
// SetLocationFromExtraData subroutine.
MoveInExtraData:
        //lda #>info.base_addr
        //ldx #<info.base_addr
        //jsr NvSpriteMoveInExtra
        //rts
        nv_sprite_move_any_direction_sr(info)

Enable:
        nv_sprite_raw_enable_sr(info.num)

SetBounceAllOn:
        nv_sprite_set_all_actions_sr(info, NV_SPRITE_ACTION_BOUNCE)

SetWrapAllOn:
        nv_sprite_set_all_actions_sr(info, NV_SPRITE_ACTION_WRAP)
}


//////////////////////////////////////////////////////////////////////////////
// Namespace with everything related to asteroid 5
.namespace asteroid_5
{
        .var info = nv_sprite_info_struct("asteroid_5", 5,
                                          85, 76, -2, -1, // init x, y, VelX, VelY 
                                          sprite_asteroid_5, 
                                          sprite_extra, 
                                          0, 0, 0, 0, // bounce on top, left, bottom, right  
                                          0, 0, 0, 0) // min/max top, left, bottom, right

        .label x_loc = info.base_addr + NV_SPRITE_X_OFFSET
        .label y_loc = info.base_addr + NV_SPRITE_Y_OFFSET
        .label x_vel = info.base_addr + NV_SPRITE_VEL_X_OFFSET
        .label y_vel = info.base_addr + NV_SPRITE_VEL_Y_OFFSET

// sprite extra data
sprite_extra:
        nv_sprite_extra_data(info)

// subroutine to set sprites location in sprite registers based on the extra data
SetLocationFromExtraData:
        lda #>info.base_addr
        ldx #<info.base_addr
        jsr NvSpriteSetLocationFromExtra
        rts
        //nv_sprite_set_location_from_memory_sr(info.num, info.base_addr+NV_SPRITE_X_OFFSET, info.base_addr+NV_SPRITE_Y_OFFSET)

// setup sprite so that it ready to be enabled and displayed
Setup:
        lda #>info.base_addr
        ldx #<info.base_addr
        jsr NvSpriteSetupFromExtra
        rts

// move the sprite x and y location in the extra data only, not in the sprite registers
// to move in the sprite registsers (and have screen reflect it) call the 
// SetLocationFromExtraData subroutine.
MoveInExtraData:
        //lda #>info.base_addr
        //ldx #<info.base_addr
        //jsr NvSpriteMoveInExtra
        //rts
        nv_sprite_move_any_direction_sr(info)

Enable:
        nv_sprite_raw_enable_sr(info.num)
        
SetBounceAllOn:
        nv_sprite_set_all_actions_sr(info, NV_SPRITE_ACTION_BOUNCE)

SetWrapAllOn:
        nv_sprite_set_all_actions_sr(info, NV_SPRITE_ACTION_WRAP)
}


//////////////////////////////////////////////////////////////////////////////
// namespace with everything related to ship sprite
.namespace ship_1
{
        .var info = nv_sprite_info_struct("ship_1", 0,
                                          22, 50, 4, 1,  // init x, y, VelX, VelY 
                                          sprite_ship, 
                                          sprite_extra, 
                                          1, 0, 1, 0, // bounce on top, left, bottom, right  
                                          0, 0, 75, 0) // min/max top, left, bottom, right

        .label x_loc = info.base_addr + NV_SPRITE_X_OFFSET
        .label y_loc = info.base_addr + NV_SPRITE_Y_OFFSET
        .label x_vel = info.base_addr + NV_SPRITE_VEL_X_OFFSET
        .label y_vel = info.base_addr + NV_SPRITE_VEL_Y_OFFSET
        .label base_addr = info.base_addr

// the extra data that goes with the sprite
sprite_extra:
        nv_sprite_extra_data(info)

// subroutine to set the sprites location based on its address in extra block 
SetLocationFromExtraData:
        lda #>info.base_addr
        ldx #<info.base_addr
        jsr NvSpriteSetLocationFromExtra
        rts

// subroutine to setup the sprite so that its ready to be enabled and displayed
Setup:
        lda #>info.base_addr
        ldx #<info.base_addr
        jsr NvSpriteSetupFromExtra
        rts

// subroutine to move the sprite in memory only (the extra data)
// this will not update the sprite registers to actually move the sprite, but
// to do that just call SetShipeLocFromMem
MoveInExtraData:
        //lda #>info.base_addr
        //ldx #<info.base_addr
        //jsr NvSpriteMoveInExtra
        //rts
        nv_sprite_move_any_direction_sr(info)

Enable:
        nv_sprite_raw_enable_sr(info.num)

SetBounceAllOn:
        nv_sprite_set_all_actions_sr(info, NV_SPRITE_ACTION_BOUNCE)

SetWrapAllOn:
        nv_sprite_set_all_actions_sr(info, NV_SPRITE_ACTION_WRAP)

}

// put the actual sprite subroutines here
#import "../nv_c64_util/nv_sprite_sr.asm"
