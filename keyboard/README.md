# keyboard.asm
Program that shows how to read the keyboard without the BASIC timer handler running.

This program runs in a loop until you press <Left Shift>+S

While its running the upper left corner of the screen will show the value read
from the port for each column in the keyboard matrix as its read.  If there
is no key pressed this will be $FF for every column. 

When a key is pressed, that column as read from the port will have a 
0 in the bits that correspond to the key that was pressed and 1s in the other
bits.  A character that represents the key that was pressed will be
poked to the screen at (2, 0) whenever a key is pressed.

So the logic is this:
- Loop until <left shift>-S
- Col0 Read keyboard matrix value for Col0 port
- if value read is $FF then no key in this column pressed, skip this col
-   else convert the value read to a char to poke on screen and poke it
- Col1 Read keybord matrix value for Col1
- if value read is $FF then no key in this column pressed, skip this col
-   else convert the value read to a char to poke on screen and poke it
- ... do same for cols 2-7...
- goto loop