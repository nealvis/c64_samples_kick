# c64_samples_kick
Commodore 64 sample programs using the Kick Assembler



# c64_samples_kick
This is a repository of Commodore 64 sample programs that are built using the Kick Assmebler.  Each directory usually contains a small example program demonstrating just one or a few concepts.  The programs can be executed/tested on the VICE C64 emulator running on Windows or loaded onto to a real Commodore 64.

# Setup
To setup a development environment to build and run these sampes follow the following steps

- Install Kick Assembler.  This is an assembler specifically for C64 code.
  - Download the latest released version here: http://theweb.dk/KickAssembler
  - I used version: V5.20  

- Install the VICE C64 emulator 
  - Download the latest version here: https://vice-emu.sourceforge.io/
  - I used version 3.5

- Select a code editor, I used VS Code
  - Download from here: https://code.visualstudio.com/
  - I used version 1.56.2

- Install the Kick Assembler IDE Extension for VS Code Named "Kick Assembler (C64) for Visual Studio Code" by Paul Hocker
  - Start up VS Code
  - Search for Extension (ctrl-shift-x) 
  - type in Kick Assembler (C64)
  - Install
  - configure the extension in VS Code, specifically find and set the settings that point where to find
    - Kick assembler jar file
    - VICE C64 emulator
    
- Now you should be ready to try the samples in this repository.

- Clone the repository, VS Code, open one of the directories like hello, open the assembly file like hello.asm in the editor.  Then go to the command palette with ctrl-shift-p and select or type in "Kick Assembler: Build and Run" if configured correctly the program will run in VICE.
