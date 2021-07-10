@echo off
echo Cleaning  %CD%
if EXIST *.dbg del *.dbg & echo del *.dbg
if EXIST *.prg del *.prg & echo del *.prg
if EXIST *.sym del *.sym & echo del *.sym
if EXIST *.vs del *.vs & echo del *.vs
if EXIST ByteDump.txt del ByteDump.txt & echo del ByteDump.txt
if EXIST .source.txt del .source.txt & echo del .source.txt