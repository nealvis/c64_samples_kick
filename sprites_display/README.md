# sprites_display project

## Overview
Sample assembly language program that demonstates how to display a hardware sprite on a Commodore 64.  This program will display a spaceship and and astroid sprite.  The sprites don't move, but you can look for another project in this repository to see how to move them.  

When you run it you'll see a screen like this:
![displaysprites screen output](images/sprites_display_output.png)

## Setup
- VS Code, Kick Assembler, VICE as outlined in [main repository README.md](../README.md)
- To create the ship and astroid sprites the online spritemate web based tool was used: [http://spritemate.com](http://spritemate.com)

## File Descriptions
- **spritedisplay.asm:** The main (only) source code file for the project.
- **clean.bat:** A batch file to clean up the files created by assembler and VS Code
- **space_sprites.spm:** The spritemate file saved in its native format
- **space_sprites.txt:** The spritemate file saved as assembly code for Kick Assembler

## Description
To create this project first step was to create two sprites
- Ship sprite (multi color/lo res)
- Asteroid sprite (hi res/single color)

To do this you can point a web browser at spritemate.com and work on your sprites right in your browser.  This is what the UI looks like:
![spritemate screen](images/sprites_display_spritemate_screen.jpg)
Note that multiple sprites can be saved at once.

When done editing the sprites, just save the project.  Its best to save in the native spritemate format for editing later.  But also save as assembly code for Kick Assembler in order to get the sprites into the program.  The assembly code will look like this:

```
// 2 sprites generated with spritemate on 5/31/2021, 8:33:10 AM
// Byte 64 of each sprite contains multicolor (high nibble) & color (low nibble) information

LDA #$0d // sprite multicolor 1
STA $D025
LDA #$01 // sprite multicolor 2
STA $D026


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
```
The first part is comments and seting the global sprite colors for multi color sprites: 
```
// 2 sprites generated with spritemate on 5/31/2021, 8:33:10 AM
// Byte 64 of each sprite contains multicolor (high nibble) & color (low nibble) information

LDA #$0d // sprite multicolor 1
STA $D025
LDA #$01 // sprite multicolor 2
STA $D026
```
In sprites_display.asm this code isn't directly copy and pasted because it doesn't provide any clue as to what colors are being used.  Instead you'll see code like this which does the same thing but uses constants so that its a little more obvious what is going on.
```
        ////// step 1: Set the two global colors for multi color sprites /////
        // here setting colors using the color const, but spritemate
        // will save similar code using literal values 
        lda #C64_COLOR_LITE_GREEN // multicolor sprites global color 1
        sta SPRITE_COLOR_1_ADDR   // can also get this from spritemate
        lda #C64_COLOR_WHITE      // multicolor sprites global color 2
        sta SPRITE_COLOR_2_ADDR
        ////// step 1 done ///////////////////////////////////////////////////

```
The rest of space_sprites.txt file contains the data for the definition of the two sprites in two separate blocks of 64 bytes.  These blocks are pretty much copied directly in to the sprites_display.asm file.  A few things to note are:
- Each sprite must start on a 64 byte boundry.  This allows the address to the sprite to be stored in a single 8 bit value that is always multiplied by 64 to get the true start of the sprite data.
- The last byte of each sprite contains two pieces of information
  - the low nibble contains the unique color for the sprite.
  - the high nibble if zero indicates that the sprite is hi res/single color sprite, if not zero then its a multi color sprite.

## Other Resources 
check out other resources regarding C64 sprites:
- https://www.c64-wiki.com/wiki/Sprite
- PETSCII Editor: http://petscii.krissz.hu/


