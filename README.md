# utoboot
A general purpose boot system so games or utilities can be distributed in SD card format for DivMMC/IDE with ESXDOS (ZX Spectrum)

## Purpose

Using DivMMC or DivIDE with ESXDOS is a great experience, but so far there was no way to distribute games in physical format using ESXDOS,
mainly because ESXDOS relays in it's own core, which is installed inside the DivMMC/DivIDE flash, and external files such as ESXDOS.SYS, 
that should be in the SD card. Also, the core and the ESXDOS.SYS file should match in version number, so a developer cannot create a SD
card which would work on every DivMMC/IDE, as the developer doesn't know which version of ESXDOS is installed in every target DivMMC.

In latest versions of ESXDOS, the autoboot feature was implemented, and AUTOXEC.BAS can run any game in the SD card, but again, not if 
you don't know the ESXDOS version of the user.

## What we found?

After some testing, based in a first try by @mcleod_ideafix, and with a lot of help from Andrew Owen and Antonio Villena, I managed to find
the BETADISK.SYS file is executed when loaded, al least in the very last versionos of ESXDOS (0.8.5 and above). Thus, you can make any code run 
at that point, for instace to load some other file (the game) and execute it.

But to get to BETADISK.SYS you have go trough loading ESXDOS.SYS first, and that was the main problem as it should match the version of the core
installed in the DivMMC. 

Well, we found ESXDOS.SYS can be replaced by an empty file, and then no version check is made. That has some side effects, cause some of the functions 
ESXDOS provides are in the SYS file, not in the core, so some ESXDOS functions doesn't work with this solution. On the other hand, we found the ones
most needed for games (load and save files) work flawlessly at least in the latest versions of ESXDOS.

There was still a challenge: in latest versions 0.8.7 and 0.8.8, we found the core itself was calling some of the new functions, which should be
in the SYS file. We believe it is the built in autoboot feature. To avoid that, we finally replaced ESXDOS.SYS, with a 4K file plenty of RETs,
which, in case of the core calling a function, it just returns. This works for latest versions and we hope it works with future versions too.

## So how it works?

At the moment, there you only need to include in a SD card the content of the SYS folder in this project (ESXDOS.SYS and BETADISK.SYS), together
with a AUTOEXEC.BIN file that you should place in the root folder of the SD card. That AUTOEXEC.BIN should be a binary loaded at 8000h, and 
executed at 8000h, cause the loader will loaded it there and then jump to 8000h.

Please notice the ROM will not be initialised, so don't expect the system variables to be there. On the other hand, the loader makes part of the ROM
initialization (clears the RAM, sets interrupt mode 1, enables interrupt, sets IY valuye to ERR-NO system variable address), but doesn't make other
things like initializae system variables, UDGs, etc. 

Also, have in mind that when your game starts, the stack it's at 8000h, so first value stacked will go to $7FFF and $7FFE

If you use the AUTOEXEC.BIN file included in this project, together with the SYS folder, you will have a SD card with an autoexecutable copy of 
Manic Miner. Thanks to Matthew Smith for creating this great game.

## What if my game does not start at 8000h

Ok, that's why the source is available. You have this section in the source code:

define      LOAD_ADDRESS      32768 ; Address where to load AUTOEXEC.BIN file
define      LOAD_SIZE         32768 ; Size of the AUTOEXEC.BIN file (if size if larger than file, file is loaded anyway)
define      START_ADDRESS     32768 ; Start address to run the game

Just change load address, file size and start address and recompile utoboot.asm using sjasmplus, and you will have a new BETADISk.SYS file ready
for your game.

## What if my game needs the system variables

We recommend getting a copy of the system variables memory block as a file, and load it from the loader, before calling your code.

## I see two [ERROR] messages when starting the game, cause NMI.SYS and RTC.SYS are not there

If that it's too annoying for you, just make copies of ESXDOS.SYS and put them as RTC.SYS and NMI.SYS in the SYS folder.

## NMI handler does not work

That's correct, it's a feature.

## Notes

- Despite you may think it would be a good idea to have a loading screen shown loaded by the utoboot loader, it is not. As said above, the ROM is
 not initialized, so you actually don't really have a FRAMES system variables, nor the IM 1 expected interrupts, and also the ESXDOS ROM is paged
 in, so you don't really have that usual ROM at full.

- Maybe it's not a bad idea to load a screen, then load your game code, and then, when your code starts, set your own interrupt handler, make a 
pause there so the loading screen is visible, and then continue with your game. If you want to do that, you can use the LoadFile function in the
source code, whose parameters are clearly defined there.

- Please notice the loader runs at address 2000h, which is the ESXDOS area for dot commands. If you use ESXDOS functions, consider it is like a
dot command, so use HL for the parameters instead of IX. 

- Many of the ESXDOS functions work, but some others may not work fine. We have tested loading and saving files, which are important for games 
(especially loading is great so you can make mulyiple areas with different sprites, loading beatiful background images, etc., but also saving
is great to save game progress). Other functions may not work.

## AGD Loader

MPAGD (Multi Plataform AGD) IDE can use the Export feature to obtain a binary file for your game, just make sure you create the TAP file, and the go to 
"Suite ZX\SjasmPlus" folder in the AGD directory and you will find the same file but with BIN extension. Put that file in the root folder of your SD
card, rename it to AUTOBOOT.AGD, and put ESXDOS.SYS and AGDBETADISK.SYS en your SYS folder. Finaly, rename AGDBETADISK.SYS as BETADISK.SYS.

If you have a game made with AGD 4.0 or above, MPAGD can also import it and then export it. If it importing TAP file doesn't work, try making a 
snapshot with an emulator and try to import SNA.

You have a sample game (Hero'es rescue) by Defecto Digital in the repository, so you can check. Thanks Javymetal for letting me use it as sample.

## DAAD Ready Loader

DAAD is a text adventure engine made by Infinite Imaginations, AKA Gilsoft, AKA Tim Gilberts,  for the Spanish company Aventuras AD. DAAD has a 
ZX Spectrum interpreter, and DAAD Ready is a package to make adventures with DAAD, which includes ESXDOS targets (for normal Spectrum and also
for ZX-Uno, which uses graphics in Timex HiRes mode).

daadloader.asm contains a loader that has been implemented in DAAD Ready 3.0, so games can have autoboot. DAAD Ready contains everything that is
needed, but source code is better hosted in this project. DAAD loader will be included by default in DAAD Ready.
