// This sample shows how to handle interupts on the C64

// import all nv_c64_util macros and data.  The data
// will go in default place
#import "../nv_c64_util/nv_c64_util_macs_and_data.asm"


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

title_str: .text @"INTERUPTS\$00"          // null terminated string to print
irq_str: .text @"HANDLER\$00"          // null terminated string to print
one_char_str: .text @"=\$00"

save_accum: .byte 0
save_x: .byte 0
save_y: .byte 0

// our assembly code will goto this address
*=$1000 "Main Start"

    // clear the screen just to have an empty canvas
    nv_screen_clear()
    nv_screen_plot_cursor(0, 16)
    nv_screen_print_str(title_str)

    //jmp MainStart


    // disable all interupts
    sei 

    // turn off CIA timer interupt and NMI interupt
    lda #$7f
    sta $dc0d 
    sta $dd0d

    // set the value for the scanline on which we want an interupt to occur
    // we write the scanline to $D011 and $D012 since there are more than 
    // 255 scanlines the high bit for the scanline is in $D011 (bit 7)
    // and $D012 contains bits 0-7 of the scanline.  The value we write to
    // these locations is saved as the scanline on which the irq will be 
    // called.  We'll set scanline for irq to be 251 so we clear bit 7 in
    // $D011 and set $D012 to hold 251
    lda #$7f        // mask to clear high bit of scan line
    and $d011       // And to get D011 with clear high bit.  
    sta $d011       // store cleared high bit for the scanline to interupt on.

    lda #251        // scanline 251 is ours, its the top of bottom border
    sta $d012       // store it back so that we get irq on this scanline

    lda #<raster_scan_interupt
    sta $0314       // LSB of raster irq handler goes in $0314
    lda #>raster_scan_interupt
    sta $0315       // MSB of raster irq handler goes in $0315

    // now enable raster irq
    lda #$01
    sta $d01a 

    // now enable all interupts
    cli

// main program here
MainStart:
    dec $0286

Loop:
    inc $0286
    ldy #0  // col
    ldx #3  // row
Loaded:
    sty save_y 
    stx save_x 
    sta save_accum
    clc                                     // clear carry to specify setting position
    jsr NV_SCREEN_PLOT_CURSOR_KERNAL_ADDR   // call kernal function to plot cursor
    nv_screen_print_str(one_char_str)
    lda save_accum 
    ldx save_x 
    ldy save_y 
    iny
    cpy #40
    beq NextRow 
NextCol:
    jmp Loaded

NextRow:
    ldy #0
    inx
    cpx #20
    beq Loop 

    jmp Loaded

    // return to caller
    rts



//////////////////////////////////////////////////////////////////////////////
// Interupt handler for raster interupt
raster_scan_interupt:
// this is the interupt handling code that will be called for scanline

    // set first bit to 1 to acknowlege the interupt is getting handled
    inc $d019 

    // change border color
    inc $d020   

    // loop with an inner and outer loop to kill some time
    ldx #3
IrqLoop:
    ldy #100
IrqInnerLoop:
    dey
    bne IrqInnerLoop
    dex
    bne IrqLoop

    // fell through loop, set the border color back
    dec $d020

    // instead of rts, we jmp to this routine which restores
    // registers and flags and then jumps back from whence we came
    jmp $ea81
