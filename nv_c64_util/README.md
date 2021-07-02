# Nealvis' C64 Utilities
This directory holds nv_c64_util which is just a collection of C64 utility routines and macros 

## Overview
All the assembler code in this directory is written for Kick Assembler and in general the setup outlined in the [main repository README.md](../README.md)

## Conventions
- Files that do not generate any code by themself when assembled have a filename ending in \_macs (for macros)
- Files that do generate code or data when assembled have a filename ending in \_code or \_data
- In general all identifiers to be used outside of the file will start with NV_ or nv_
- Labels in the code are: PascalCase
- Macro names are: lower_case_with_underscores
- Macro parameters are: lower_case_with_underscores
- Constants are: UPPER_CASE_WITH_UNDERSCORES
- Macros that are intended to be instantiated in conjunction with a label to be called via jsr have "\_sr" at the end (for **S**ub**R**outine).  For example to use nv_sprite_wait_scan_sr you should instantiate the macro along with a label similar to this.
```  
  WaitScanSubroutine:
    nv_sprite_wait_last_scanline_sr()
```
Then when you want to call call the subroutine you should use jsr like this.
```
jsr WaitScanSubroutine
```
- Macros that are just intended to be used for inline code generation do not have \_sr or anything else at the end.  For example if you just want your code to include the assembly code to wait for scan you can just place the nv_sprite_wait_scan macro directly in your code like this:
```
nv_sprite_wait_last_scanline()
```
