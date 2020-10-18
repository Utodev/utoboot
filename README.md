# utoboot
A general purpose boot system so games or utilities can be distributed in SD card format for ESXDOS+DivMMC/IDE (ZX Spectrum)

## Purpose

Using DivMMC or DivIDE with ESXDOS is a great experience, but so far there was no way to distribute games in physical format using ESXDOS,
mainly because ESXDOS relays in it's own core, which is installed inside the DivMMC/DivIDE flash, and externar files such as ESXDOS.SYS, 
that should be in the SD card. Also, the core and the ESXDOS.SYS file should match in version number, so a developer cannot create a SD
card which would work on every DivMMC/IDE, as the developer doesn't know which version of ESXDOS is installed in target DivMMCs.

In latest versions of ESXDOS, the autoboot feature was implemented, and AUTOXEC.BAS can run any game in the SD card, but again, not if 
you don't know the ESXDOS version of the user.

## What we found?

After some testing, based in a first try by @mcleod_ideafix, and with a lot of help from Andrew Owen and Antonio Villena, I managed to find
the BETADISK.SYS file is executed when loaded. Thus, you can make any code run at that point, for instace to load some other file (the game)
and execute it.

But to get to BETADISK.SYS you have go trough loading ESXDOS.SYS first, and that was the main problem. Well, we found ESXDOS.SYS can be 
replaced by an empty file, and then no version check is made. That has some side effects, cause some of the functions ESXDOS provides
are in the SYS file, not in the core, so some ESXDOS functions doesn't work with this solution. On the other hand, we found the ones
most needed for games (load and save files) work flawlessly at least in the last versions of ESXDOS since 0.8.5.

In latest versions 0.8.7 and 0.8.8, we found the core itself was calling some of the new functions, which should be in the SYS file, we 
believe it is the built in autoboot feature. To avoid that, we finally replaced ESXDOS.SYS, with a 4K file plenty of RETs, which, in case of
the core calling function, just return. This works for latest versions and we hope it works with future versions too.

## So how it works?

At the moment, there you only need to include in a SD card the content of the SYS folder in this project (ESXDOS.SYS and BETADISK.SYS), together
with a AUTOEXEC.BIN file that you should place in the root folder of the SD card. That AUTOEXEC.BIN should be a binary loaded at 8000h, and 
executed at 8000h, cause the loader will loaded it there and then jump to 8000h.

Please notice the ROM will not be initialised, so don't expect the system variables to be there. The loaded changes interrupto mode to IM1 and
enables interrupts before jumping to your game, so that's quite similar to normal situation, and it also cleans the RAM (by setting all addresses
to zero), but don't expect other initializations to be there, such as system variables, UDGs, etc.

Also, have in mind that when your game starts, the stack it's at 8000h, so first value stacked will go to $7FFF and $7FFE

If you use the AUTOEXEC.BIN file included in this project, together with the SYS folder, you will have a SD card with an autoexecutable copy of 
Manic Miner.

## What if my game does not start at 8000h

Ok, that's why the source is available. You have this section in the source code:

define      LOAD_ADDRESS      32768 ; Address where to load AUTOEXEC.BIN file
define      LOAD_SIZE         32768 ; Size of the AUTOEXEC.BIN file (if size if larger than file, file is loaded anyway)
define      START_ADDRESS     32768 ; Start address to run the game

Just change load address, file size and start address and recompile utoboot.asm using sjasmplus, and you will have a new BETADISk.SYS file ready
for your game.

## Notes

- Despite you may think it would be a good idea to have a loading screen shown loaded by the utoboot loader, it is not. As said above, the ROM is
 not initialized, so you actually don't really have a FRAMES system variables, nor the IM 1 expected interrupts, and also the ESXDOS ROM is paged
 in, so you don't really have that usual ROM at full.

- Maybe it's not a bad idea to load a screen, then load your game code, and then, when your code starts, set your own interrupt handler, make a 
pause there so the loading screen is visible, and then continue with your game. If you want to do that, you can use the LoadFile function in the
source code, whose parameters are clearly defined there.

## DAAD Ready Loader

DAAD is a text adventure engine made by Infinite Imaginations, AKA Tim Gilberts, AKA Gilsoft, for the Spanish company Aventuras AD. DAAD has a 
ZX Spectrum interpreter, and DAAD Ready is a package to make adventures with DAAD, which includes ESXDOS targets (for normal Spectrum and also
for ZX-Uno, which uses graphics in Timex HiRes mode).

daadloader.asm contains a loader that has been implemented in DAAD Ready 3.0, so games can have autoboot. DAAD Ready contains everything that is
needed, but source code is better hosted in this project.
