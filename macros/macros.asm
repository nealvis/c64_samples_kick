//////////////////////////////////////////////////////////////////////////////
// This sample shows how to create and call macros.
// Two macros are created to print to the screen in two ways


*=$0801 "BASIC Start"
        // location to put 1 line basic program so we can just
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


// macro with no parameters to clear screen and 
// leave cursor in upper left
.macro clear_screen_mac() 
{
        // address of the Kernal routine to clear the screen
        .const CLEAR_SCREEN_KERNAL_ADDR = $E544

        jsr CLEAR_SCREEN_KERNAL_ADDR
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// macro to print a null terminated string via basic routine at 
// current cursor location
// str_addr: is the address of the first char of null terminated string to print
.macro print_string_basic_mac (str_addr)
{
        // Address of BASIC routine to print a string at 
        // current cursor location
        .const PRINT_STRING_BASIC_ADDR = $AB1E      

        lda #<str_addr                   // LSB of addr of string to print to A
        ldy #>str_addr                   // MSB of addr of str to print to Y
        jsr PRINT_STRING_BASIC_ADDR  // call kernal routine to print the string
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// macro to print a string by writing directly to screen memory
// screen_x: is the screen x coord (character not pixel) for first
//   character of string
// screen_y: is the screen y coord of the first char of string to print
.macro print_string_direct_mac (screen_x, screen_y, str_addr)
{
        // Some constants for screen 
        .const SCREEN_START_ADDR = $0400       // The start of c64 screen memory
        .const SCREEN_COLS = 40                // chars across
        .const SCREEN_ROWS = 25                // chars down

        .var screen_addr = SCREEN_START_ADDR + (screen_y * SCREEN_COLS) + screen_x

        ldx #0          // use x reg as loop index start at 0
DirectLoop:
        lda str_addr,x        // put a byte from string into accum
        beq Done       // if the byte was 0 then we're done 
        sta screen_addr,x        // Store the byte to screen
        inx             // inc X to next byte and next screen location 
        jmp DirectLoop // Loop back to write next byte
Done:
}         


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// some program data.  This data will go to memory directly after
// the sys(4096) BASIC program but before the start of 
// the assembly program below

// program variables
str_hello_basic: .text @"HELLO VIA BASIC   \$00"  // null terminated string to print
                                                  // via the BASIC routine
str_goodbye_basic: .text @"GOODBYE VIA BASIC\$00"  // null terminated string to print
                                                   // via the BASIC routine


str_hello_direct: .text  @"hello direct\$00"  // null terminated string to print
                                              // via copy direct to screen memory
str_goodbye_direct: .text  @"goodbye direct\$00"  // null terminated string to print
                                                  // via copy direct to screen memory



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// our assembly code will start at this address
*=$1000 "Main Start"
        
Main:

        // clear screeen leave cursor upper left
        clear_screen_mac()
        
        // print a string via basic routine
        print_string_basic_mac(str_hello_basic)

        // print a string starting at x=5, y=5 
        // by writing to screen memory
        print_string_direct_mac(5, 5, str_hello_direct)

        // print a string via basic routine
        print_string_basic_mac(str_goodbye_basic)

        // print a string starting at to x=6, y=6 
        // by writing to screen memory
        print_string_direct_mac(6, 6, str_goodbye_direct)
Done:
        // program done, return
        rts                     



        
