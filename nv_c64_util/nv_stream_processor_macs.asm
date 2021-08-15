// nv_stream_processor_macs.asm
// inline macros for a stream procesor that accepts a command stream 
// (a list of bytes less than 256 total)
// and does things like store bytes to list of memory pointers
// based on whats in the stream

#importonce

#if !NV_C64_UTIL_DATA
.error "Error - nv_stream_processor_macs.asm: NV_C64_UTIL_DATA not defined.  Import nv_c64_util_data.asm"
#endif

// the #if above doesn't seem to always work so..
// if data hasn't been imported yet, import it into default location
#importif !NV_C64_UTIL_DATA "nv_c64_util_default_data.asm"

#import "nv_screen_macs.asm"
#import "nv_color_macs.asm"
#import "nv_math16_macs.asm"

// inline macro to process a stream of bytes that consist of
// memory addresses, commands, or command opperands.  The default
// command is copy the byte in the accum to following memory addresses
// 
// macro params:
//   stream_addr: is the addres that contains the stream of commands.  
//                The stream consists of memory addresses for the most
//                part but there is a special command marker that 
//                can change behavior.  the command marker is $FFFF
//                after reading the command marker bytes the next byte
//                in the stream is interpreted as a command.  the following
//                commands are valid:
//                    $01: the next byte in stream is the new source byte
//                         that gets copied to memory addresses that follow
//                    $FF: End of stream command 
//                here is an example stream with comments
//                    .word $D800      // store accum to $D800
//                    .word $D801      // store accum to $D801
//                    .word $FFFF      // command marker
//                    .byte $01        // LoadCopySrc command
//                    .byte $05        // the new copy source is $05
//                    .word $D802      // store $05 to $D802
//                    .word $FFFF      // command marker
//                    .byte $00        // No Operation command
//                    .word $D803      // store $05 to $D803
//                    .word $FFFF      // command marker
//                    .byte $FF        // Quit command
//   save_block: is the address to a two byte block of memory that can
//               be used to save some zero page values that are used
//               for indirection.  they will be restored after the 
//               store operation is done.
//   Accum: may change, initially should hold the byte that will be stored 
//   X Reg: will change
//   Y Reg: will change
/*
.macro nv_stream_proc(stream_addr, save_block)
{
    .const CMD_NO_OP = $00
    .const CMD_LOAD_SRC = $01
    .const CMD_QUIT = $FF

    // zero page pointer to use whenever a zero page pointer is needed
    // usually used to store and load to and from the sprite extra pointer
    .const ZERO_PAGE_LO = $FB
    .const ZERO_PAGE_HI = $FC

    // save our zero page pointer
    ldy ZERO_PAGE_LO
    sty save_block
    ldy ZERO_PAGE_HI
    sty save_block+1

    ldx #0
LoopTop:

    // load zero page ptr with our pointer
    ldy stream_addr,x
    sty ZERO_PAGE_LO
    ldy stream_addr+1, x
    sty ZERO_PAGE_HI
    
    ldy #$FF
    cpy ZERO_PAGE_LO
    bne NotCommandWord
    cpy ZERO_PAGE_HI
    bne NotCommandWord
    // was command marker word, so inc past the command marker and
    // read the next byte to determine what to do
    inx
    inx
    ldy stream_addr, x
    // now y has the command in it

TryCmdLoadSrc:
    cpy #CMD_LOAD_SRC
    bne TryCmdNop
IsCmdLoadSrc:
    // cmd $01 means to the next byte in stream is what we should
    // start copying to memory addresses
    lda stream_addr+1, x
    // now inc x reg twice so pointing to right place in 
    // the stream and continue processing as normal
    jmp Inc2AndLoop

TryCmdNop:
    cpy #CMD_NO_OP
    bne TryCmdQuit
IsCmdNop:
    // cmd $00 means nothing to do (no operation)
    // just inc the index one byte past the command and loop back up
    jmp Inc1AndLoop

TryCmdQuit:
    cpy #CMD_QUIT 
    bne InvalidCommand
IsCmdQuit:
    // cmd $FF means to quit processing, no need to read stream
    // for any more bytes
    jmp HitQuitCommand

InvalidCommand:
    // was a command we don't know about so turn background red 
    // and treat it like quit command.  Hopefully red background 
    // will be noticed and it will get debugged.
    ldy #NV_COLOR_RED
    sty NV_SCREEN_BACKGROUND_COLOR_REG_ADDR
    jmp HitQuitCommand

NotCommandWord:
    // word read from stream was an address and we need to copy a byte there
    // the source byte is in the accum dest addr is in zero_page_lo/hi 
    ldy #$00              // load Y reg 0 to use ptr address with no offset
    sta (ZERO_PAGE_LO),y  // indirect indexed store accum to pointed to addr

Inc2AndLoop:    
    inx
Inc1AndLoop:
    inx
    jmp LoopTop

HitQuitCommand:
    // restore our zero page pointer
    ldy save_block
    sty ZERO_PAGE_LO
    ldy save_block+1
    sty ZERO_PAGE_HI
}
*/

// macros params
//   temp_word: is a temp word used internally
//   save_block: is a block of 4 bytes to save contents of 
//               zero page memory while we are using it for 
//               indirection
//   background_color_addr: is the address that holds background color
//                          used in the CMD_BKG_SRC command
// subroutine params:
//   Accum: will change, Input: should hold the byte that will be stored 
//   X Reg: will change, Input: LSB of stream data's addr.  
//   Y Reg: will change, Input: MSB of Stream data's addr 
.macro nv_stream_proc_sr(temp_word, save_block, background_color_addr)
{
    // Normal commands (that require no special info from
    // the main program start from 0 and go up
    .const CMD_NO_OP = $00      // does nothing, no arg
    
    .const CMD_LOAD_SRC = $01   // 1 byte arg, the new src data to copy
    
    .const CMD_BLK_CPY = $02    // 1 byte arg, num bytes to copy
                                // first word is the target base addr
                                // the src bytes follow, must match arg
                                // the first byte is copied to target base
                                // addr, the next byte in to target base 
                                // addr + 1, etc. until num bytes to copy
                                // have been copied.

    .const CMD_DEST_LIST = $03   // two byte arg which is the 16 bit 
                                 // address of and address list that 
                                 // should be used asthe destination 
                                 // addresses.  An address list is zero
                                 // or more 16 bit addrs in succession
                                 // in memory followed by terminating $FFFF

    .const CMD_DEST_BLOCK = $04  // 4 bytes of arg
                                 // 16 bit first dest addr, 
                                 // 16 bit last dest addr
                                 // copy current src byte to every dest addr
                                 // between start and end address inclusive
    
    .const CMD_QUIT = $FF       // quit is normal but out of order

    // special commands that require info from the 
    // main program start at $FE and go down
    .const CMD_BKG_SRC = $FE

    // zero page pointer to use whenever a zero page pointer is needed
    // usually used to store and load to and from the sprite extra pointer
    .const ZERO_PAGE_LO = $FB
    .const ZERO_PAGE_HI = $FC
    .const Z2_LO = $FD
    .const Z2_HI = $FE

    stx temp_word
    sty temp_word+1

    // save our zero page pointer
    ldy ZERO_PAGE_LO
    sty save_block
    ldy ZERO_PAGE_HI
    sty save_block+1
    ldy Z2_LO
    sty save_block+2
    ldy Z2_HI
    sty save_block+3

    // setup zero page to point to the stream
    ldx temp_word
    stx Z2_LO
    ldy temp_word+1
    sty Z2_HI
    // now Z2_LO/Z2_HI points to the first  
    // byte of the stream data which itself may be a pointer
    // to a memory location

    // done with temp_word above, now it holds the 
    // current byte that will be written.
    sta temp_word

    ldy #$00
    sty blk_cpy_num_bytes
    sty dest_block_end_addr
    sty dest_block_end_addr+1
    sty dest_block_start_addr
    sty dest_block_start_addr+1
LoopTop:

    // load zero page ptr with pointer from stream (assuming
    // it is a pointer, it could be a command)
    lda (Z2_LO), y      // read byte from stream
    sta ZERO_PAGE_LO    // store byte in other zero page pointer
    iny                 // next byte in stream
    lda (Z2_LO), y      // read next byte in stream
    sta ZERO_PAGE_HI
    iny                 // get ready to read next byte in stream
    // now ZERO_PAGE_LO/HI points has the first pointer from stream
    // assuming it is a pointer, it could also be command marker
    
    lda #$FF
    cmp ZERO_PAGE_LO
    bne NotCommandWord
    cmp ZERO_PAGE_HI
    bne NotCommandWord
    // was command marker word, so read the next byte to 
    // determine what to do
    lda (Z2_LO), y                  // read command byte from stream
    iny
    // now accum has the command in it

TryCmdLoadSrc:
    cmp #CMD_LOAD_SRC
    bne TryCmdBackgroundSrc
IsCmdLoadSrc:
    // cmd $01 means to the next byte in stream is what we should
    // start copying to memory addresses
    lda (Z2_LO), y                  // read next byte in stream
    iny
    sta temp_word
    jmp LoopTop

TryCmdBackgroundSrc:
    cmp #CMD_BKG_SRC
    bne TryCmdBlockCopy
IsCmdBackgroundSrc:
    // cmd $FE means new copy source byte should be the background color
    lda background_color_addr       
    sta temp_word
    jmp LoopTop

TryCmdBlockCopy:
    cmp #CMD_BLK_CPY
    bne TryCmdDestList
IsCmdBlockCopy:
    // cmd $02 means size of block is next byte
    // followed by a 16 bit destination address 
    // followed by that many number of new source bytes for the dest 
    jsr DoBlkCpy
    jmp LoopTop

TryCmdDestList:
    // cmd $03 means the next 2 bytes comprise the address of a
    // list of addresses that should be used as the destination 
    // address for the byte that is currently getting copied.  The
    // list of addresses must be terminated by $FFFF
    cmp #CMD_DEST_LIST
    bne TryCmdDestBlock
IsCmdDestList:
    jsr DoDestList
    jmp LoopTop

TryCmdDestBlock:
    cmp #CMD_DEST_BLOCK
    bne TryCmdNop
IsCmdDestBlock:
    jsr DoDestBlock
    jmp LoopTop

TryCmdNop:
    cmp #CMD_NO_OP
    bne TryCmdQuit
IsCmdNop:
    // cmd $00 means nothing to do (no operation)
    // just loop back up
    jmp LoopTop

TryCmdQuit:
    cmp #CMD_QUIT 
    bne InvalidCommand
IsCmdQuit:
    // cmd $FF means to quit processing, no need to read stream
    // for any more bytes
    jmp HitQuitCommand

InvalidCommand:
    // was a command we don't know about so turn background red 
    // and treat it like quit command.  Hopefully red background 
    // will be noticed and it will get debugged.
    ldy #NV_COLOR_RED
    sty NV_SCREEN_BACKGROUND_COLOR_REG_ADDR
    jmp HitQuitCommand

NotCommandWord:
    // word read from stream was an address and we need to copy a byte there
    // the source byte is in temp_ptr, dest addr is in zero_page_lo/hi 
    lda temp_word
    ldx #$00              // load x reg with 0 / no offset
                          // TODO: can this be outside loop?
    sta (ZERO_PAGE_LO,x)  // store accum to pointed to addr
    jmp LoopTop

HitQuitCommand:
    // restore our zero page pointer
    ldy save_block
    sty ZERO_PAGE_LO
    ldy save_block+1
    sty ZERO_PAGE_HI
    ldy save_block+2
    sty Z2_LO
    ldy save_block+3
    sty Z2_HI

    rts

//////////////////////////////////////////////////////////////////////////////
// subroutine to copy src byte to block of memory defined by start and end
// estination addresses
dest_block_start_addr: .word $0000
dest_block_end_addr: .word $0000
DoDestBlock:
{
    lda (Z2_LO), y                  // read next byte in stream
    iny                             // its LSB of Start addr
    sta ZERO_PAGE_LO                // store in ZERO_PAGE_LO
    lda (Z2_LO), y                  // read next byte in stream
    iny                             // its the MS of start addr
    sta ZERO_PAGE_HI                // store in ZERO_PAGE_HI

    lda (Z2_LO), y                  // read next byte in stream
    iny
    sta dest_block_end_addr
    lda (Z2_LO), y                  // read next byte in stream
    iny
    sta dest_block_end_addr+1

DestBlockLoop:
    lda temp_word         // temp_word LSB is the src byte
    ldx #$00              // load x reg with 0 / no offset
    sta (ZERO_PAGE_LO,x)  // store accum to pointed to dest addr
    nv_adc16_immediate(ZERO_PAGE_LO, 1, ZERO_PAGE_LO)            // inc the dest addr
    nv_ble16(ZERO_PAGE_LO, dest_block_end_addr, DestBlockLoop)   // loop if not done
    
DestBlockDone:
    rts
}

//////////////////////////////////////////////////////////////////////////////
// subroutine to copy src byte to destination list
DoDestList:
{
    // read the address of the list from the stream
    lda (Z2_LO), y                  // first byte is LSB of addr of list start
    iny                             // advance to next byte of the stream
    sta ZERO_PAGE_LO

    lda (Z2_LO), y                  // next byte is MSB of addr of list start
    iny                             // advance to next byte of the stream
    sta ZERO_PAGE_HI
    // now ZERO_PAGE_LO/HI points to the address list

    // save current stream position
    sty dest_list_save_y
    ldy Z2_LO
    sty dest_list_save_z2_lo
    ldy Z2_HI
    sty dest_list_save_z2_hi

    // read an address from the list
    ldx #$00
    ldy #$00

LoopReadDestList:
    lda (ZERO_PAGE_LO),y            // read LSB of addr in list
    iny                             // inc to next byte in list
    sta Z2_LO                       // store LSB in z2_LO

    lda (ZERO_PAGE_LO),y            // read MSB of addr in list
    iny                             // inc to next byte in list
    sta Z2_HI                       // store MSB in z2_HI

    lda #$FF
    cmp Z2_LO
    bne NotDestListEnd
    cmp Z2_HI
    bne NotDestListEnd

IsDestListEnd:
    // was list end, restore stream state and return
    lda dest_list_save_z2_hi
    sta Z2_HI
    lda dest_list_save_z2_lo
    sta Z2_LO
    ldy dest_list_save_y
    rts

NotDestListEnd:
    // Not end of list so Z2_LO and Z2_HI point to a destination addr
    // so copy a byte to that address
    lda temp_word         // temp_word LSB is the src byte
    ldx #$00              // load x reg with 0 / no offset
    sta (Z2_LO,x)         // store accum to pointed to addr
    jmp LoopReadDestList

    //dest_list_addr: .word $0000
    dest_list_save_y: .byte $00
    dest_list_save_z2_lo: .byte $00
    dest_list_save_z2_hi: .byte $00
}
// DoDestList - end
//////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////
// DoBlkCopy subroutine to copy diff src byte to block of bytes in stream
// to successive locations in memory.  The src byte is read from stream 
// for every successive destination address.
blk_cpy_num_bytes: .byte 0
DoBlkCpy:
{
    // read number of bytes to copy first
    lda (Z2_LO), y                  // read next byte in stream
    iny
    sta blk_cpy_num_bytes

    // grab the pointer to destination from stream
    lda (Z2_LO), y       // read next byte in stream
    iny
    sta ZERO_PAGE_LO
    lda (Z2_LO), y       // read next byte in stream
    iny
    sta ZERO_PAGE_HI

    // check if number bytes to copy is zero
    // if so then we are done.
    lda #$00
    cmp blk_cpy_num_bytes
    beq NotDoingBlockCopy

    ldx #$00
BlockCopyLoopTop:
    lda (Z2_LO), y       // read next byte in stream
    iny
    sta (ZERO_PAGE_LO,x)  // store accum to pointed to addr
    nv_adc16_immediate(ZERO_PAGE_LO, 1, ZERO_PAGE_LO)
    dec blk_cpy_num_bytes
    bne BlockCopyLoopTop

BlockCopyDone:
NotDoingBlockCopy:
    rts
}
// DoBlkCopy - end
//////////////////////////////////////////////////////////////////////////////

}

