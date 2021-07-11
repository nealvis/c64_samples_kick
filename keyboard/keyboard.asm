// This sample shows reading from the keyboard
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

last_key: .byte 0
one_char_str: .byte 0, 0


// For all the colX_tables below when there is no reasonable 
// value to poke to the screen (or when i haven't looked up
// the right value yet) for the corresponding key, 
// the table byte will be $66 which is just a grid pattern

// table of chars to report for col0 keys:  
//                <del>, <return>, <cur LR>,  F7, F1,   F3,  F5, <cur UD>
col0_table: .byte $66,   $66,      $66,      $66, $66, $66, $66, $66

// table of chars to report for col1 keys:  
//                 3,   W,   A,   4,   Z,   S,   E,  <LSHIFT>
col1_table: .byte $33, $17, $01, $34, $1A, $13, $05, $66

// table of chars to report for col2 keys:
//                 5,   R,   D,   6,   C,   F,   T,   X
col2_table: .byte $35, $12, $04, $36, $03, $06, $14, $18

// table of chars to report for col3 keys:
//                 7,   Y,   G,   8,   B,   H,   U,   V
col3_table: .byte $37, $19, $07, $38, $02, $08, $15, $16

// table of chars to report for col4 keys:
//                 9,   I,   J,   0,   M,   K,   O,   N
col4_table: .byte $39, $09, $0A, $30, $0D, $0B, $0F, $0E

// table of chars to report for col5 keys:
//                 +,   P,   L,   -,   .,   :,   @,   .
col5_table: .byte $66, $10, $0C, $66, $66, $66, $66, $66


// table of chars to report for col6 keys:
//                <lb>, *,   ;,  <CLR HOME>, <RShift>, =,   <up arrow>, /
col6_table: .byte $66, $66, $66, $66,        $66,      $66, $66,        $66

// table of chars to report for col7 keys:
//                 1,  <lf arrow>, <ctrl>, 2,  <space>, <cmodor>, Q,  <run st>
col7_table: .byte $31, $66,        $66,   $32, $66,     $66,     $11, $66


// our assembly code will goto this address
*=$1000 "Main Start"
MainStart:

    // could turn off all interupts here or just the timer
    // that handles reading the keyboard.

    //sei             // disable interrupts

    // write a 0 to bit 0 at $DC0E to turn off timer A
    // which is how keyboard is handled.
    lda #$FE
    and $DC0E
    sta $DC0E

    nv_screen_clear()

    .const PORT_REG_A  =  $dc00            // CIA#1 (Port Register A)
    .const DATA_DIR_REG_A =  $dc02            // CIA#1 (Data Direction Register A)

    .const PORT_REG_B  =  $dc01            // CIA#1 (Port Register B)
    .const DATA_DIR_REG_B =  $dc03            // CIA#1 (Data Direction Register B)

    lda #$FF        // CIA#1 port A = outputs 
    sta DATA_DIR_REG_A             

    lda #$00        // CIA#1 port B = inputs
    sta DATA_DIR_REG_B             


    ldx #$FF
    stx last_key
Loop:

    nv_sprite_wait_last_scanline()
    nv_screen_poke_hex_byte_mem(0, 0, last_key, true)

CheckCol0:
    lda #$FE        // testing column 0 (COL0) of the matrix
    sta PORT_REG_A

    lda PORT_REG_B
    cmp #$FF
    beq CheckCol1
HaveCol0:
    sta last_key
    test_for_char_via_table(col0_table)

CheckCol1:
    lda #$FD        // testing column 1 (COL1) of the matrix
    sta PORT_REG_A

    lda PORT_REG_B
    cmp #$FF
    beq CheckCol2
HaveCol1:
    sta last_key
    test_for_char_via_table(col1_table)

CheckCol2:
    lda #$FB        // testing column 2 (COL2) of the matrix
    sta PORT_REG_A

    lda PORT_REG_B
    cmp #$FF
    beq CheckCol3
HaveCol2:
    sta last_key
    test_for_char_via_table(col2_table)

CheckCol3:
    lda #$F7        // testing column 3 (COL3) of the matrix
    sta PORT_REG_A

    lda PORT_REG_B
    cmp #$FF
    beq CheckCol4
HaveCol3:
    sta last_key
    test_for_char_via_table(col3_table)

CheckCol4:
    lda #$EF        // testing column 4 (COL4) of the matrix
    sta PORT_REG_A

    lda PORT_REG_B
    cmp #$FF
    beq CheckCol5
HaveCol4:
    sta last_key
    test_for_char_via_table(col4_table)

CheckCol5:
    lda #$DF        // testing column 5 (COL5) of the matrix
    sta PORT_REG_A

    lda PORT_REG_B
    cmp #$FF
    beq CheckCol6
HaveCol5:
    sta last_key
    test_for_char_via_table(col5_table)

CheckCol6:
    lda #$BF        // testing column 6 (COL6) of the matrix
    sta PORT_REG_A

    lda PORT_REG_B
    cmp #$FF
    beq CheckCol7
HaveCol6:
    sta last_key
    test_for_char_via_table(col6_table)

CheckCol7:
    lda #$7F        // testing column 7 (COL7) of the matrix
    sta PORT_REG_A

    lda PORT_REG_B
    cmp #$FF
    beq Bottom
HaveCol7:
    sta last_key
    test_for_char_via_table(col7_table)
    
Bottom:
    lda last_key
    and #$A0            // masking row 5 (ROW5) 
    beq ExitLoop        // if shift-s then exit 

jmp Loop

ExitLoop:
    // if we disabled interupts above then should enable them here
    //cli           // enable interrupts 

    // if we just turned off the timer A
    // which take care of keyboard then just turn it back on here
    lda #$01
    ora $DC0E
    sta $DC0E

    rts             // back to BASIC
    

//////////////////////////////////////////////////////////////////////////////
// inline macro that pokes a char based on the bits in the accum
// which are assumed to be read from one of the rows of the keyboard 
// matrix. basically for each 0 bit in the accume a char (the corresponding
// macro parameter) is poked to the screen 
// macro params:
//   table_addr: the address of a table with 8 bytes.  Each byte 
//               in the table corresponds to a bit in the accum.
//               when that bit is 0 the corresponding number in
//               the table is poked to the screen
//               for example if table_addr holds these 8 values:
//                 1, 2, 3, 4, 5, 6, 7, 8
//               and accum has $FB  then a 6 will be poked to the screen
.macro test_for_char_via_table(table_addr)
{
    ldx #0
TryBit:
    ror
    bcs TryNextBit              // this key not hit
    ldy table_addr, x           // get value to poke to screen from table
    nv_screen_poke_char_y(2, 0) // poke to screen.  
TryNextBit:
    inx
    cpx #$08
    beq Done
    jmp TryBit
Done: 
}


//////////////////////////////////////////////////////////////////////////////
// inline macro that pokes a char based on the bits in the accum
// which are assumed to be read from one of the rows of the keyboard 
// matrix. basically for each 0 bit in the accume a char (the corresponding
// macro parameter) is poked to the screen 
// macro params:
//   char0: number to poke to screen if bit 0 in accum is clear
//   char1: number to poke to screen if bit 1 in accum is clear
//   ...
//   charN: number to poke to screen if bit N in accum is clear
//   Accum: should be set to the bit pattern scanned from keyboard
.macro test_for_char(char0, char1, char2, char3, char4, char5, char6, char7)
{
TryBit0:
    ror
    bcs TryBit1 
    ldy #char0            // 3 key
    sty one_char_str
    pha
    nv_screen_poke_str(2, 0, one_char_str)
    pla
TryBit1:
    ror
    bcs TryBit2
    ldy #char1            // W key
    sty one_char_str
    pha
    nv_screen_poke_str(2, 0, one_char_str)
    pla
TryBit2:
    ror
    bcs TryBit3
    ldy #char2            // A key
    sty one_char_str
    pha
    nv_screen_poke_str(2, 0, one_char_str)
    pla

TryBit3:
    ror
    bcs TryBit4
    ldy #char3            // 4 key
    sty one_char_str
    pha
    nv_screen_poke_str(2, 0, one_char_str)
    pla

TryBit4:    
    ror
    bcs TryBit5
    ldy #char4            // Z key
    sty one_char_str
    pha
    nv_screen_poke_str(2, 0, one_char_str)
    pla

TryBit5:
    ror
    bcs TryBit6
    ldy #char5            // S key
    sty one_char_str
    pha
    nv_screen_poke_str(2, 0, one_char_str)
    pla

TryBit6:
    ror
    bcs TryBit7
    ldy #char6            // E key
    sty one_char_str
    pha
    nv_screen_poke_str(2, 0, one_char_str)
    pla

TryBit7:
    ror
    bcs Done
    ldy #char7            // left shift key was hit just any shape here
    sty one_char_str
    pha
    nv_screen_poke_str(2, 0, one_char_str)
    pla
Done:
}
