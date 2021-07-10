//////////////////////////////////////////////////////////////////////////////
// nv_state_saver_macs.asm
// some macros to save and restore state
//////////////////////////////////////////////////////////////////////////////

#importonce

#if !NV_C64_UTIL_DATA
.error "Error - nv_math8_macs.asm: NV_C64_UTIL_DATA not defined.  Import nv_c64_util_data.asm"
#endif

// the #if above doesn't seem to always work so..
// if data hasn't been imported yet, import it into default location
#importif !NV_C64_UTIL_DATA "nv_c64_util_default_data.asm"


//////////////////////////////////////////////////////////////////////////////
// inline macro to the values in two memory locations on the stack
// macro params:
//   one: a memory location that's value will be saved on the stack
//   two: a memory location that's value will be saved on the stack
// To restore the memory locations their values saved, use the macro
// restore_two(one, two) 
// with params in same order as this macro
.macro save_two(one, two)
{
    lda one
    pha 
    lda two
    pha
}

//////////////////////////////////////////////////////////////////////////////
// inline macro to the values in four memory locations on the stack
// macro params:
//   one: a memory location that's value will be saved on the stack
//   two: a memory location that's value will be saved on the stack
//   three: a memory location that's value will be saved on the stack
//   four: a memory location that's value will be saved on the stack
// To restore the memory locations their values saved, use the macro
// restore_four(one, two, three, four) 
// with params in same order as this macro
.macro save_four(one, two, three, four)
{
    lda one
    pha 

    lda two
    pha

    lda three
    pha 

    lda four
    pha
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to restore values in two memory locations from the stack.
// the memory locations must have been saved with save_two(one, two)
// macro params:
//   one: a memory location that's value will be restored from the stack
//   two: a memory location that's value will be restored from the stack
.macro restore_two(one, two)
{
    pla
    sta two
    pla
    sta one
}


//////////////////////////////////////////////////////////////////////////////
// inline macro to restore values in four memory locations from the stack.
// the memory locations must have been saved with 
//   save_four(one, two, three, four)
// macro params:
//   one: a memory location that's value will be restored from the stack
//   two: a memory location that's value will be restored from the stack
//   three: a memory location that's value will be restored from the stack
//   four: a memory location that's value will be restored from the stack
.macro restore_four(one, two, three, four)
{
    pla
    sta four

    pla
    sta three

    pla
    sta two
    
    pla
    sta one
}



