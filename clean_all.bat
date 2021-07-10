
@echo off
for /f %%f in ('dir /AD /b .\') do if EXIST "%%f\clean.bat" (cd %%f & clean.bat & cd ..)