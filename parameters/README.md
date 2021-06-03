# Parameter Passing Strategies
This directory contains examples of several parameter passing strategies for 6502 assembler programmging.  

This is a topic becase JSR puts the return address (minus 1) on to the stack before setting the program counter to the called routine, so any parameters that are pushed on to the stack before JSR need to consider this because when RTS is called it expects the return address (minus 1) to be at the top of the stack.

## Overview
All the assembler code in this directory is written for Kick Assembler and in general the setup outlined in the [main repository README.md](../README.md)

## Strategies Considered
To show the different parameter passing strategies, the parameters.asm file includes a function that needs three parameters in order to do its job of printing a character some where in first 5 rows of the screen.
1. The row at which the char will appear (only 0-5)
2. The col at which the char will appear (0-39) 
3. The character to print on the screen

This function is reproduced a number of times, each time with a different way to pass the parameters to it.  The following different strategies for this function are:
- Registers only
- Function defined parameter block
- Caller modidfication of routine code (yes self modifying code)
- Caller defined parameter block
- Routine stack perserving
- Routine JMP back
- Caller Push Caller Pop


