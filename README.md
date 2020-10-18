# utoboot
A general purpose boot system so games or utilities can be distributed in SD card format for ESXDOS+DivMMC/IDE (ZX Spectrum)

##How it works

Using DivMMC or DivIDE with ESXDOS is a great experience, but so far there was no way to distribute games in physical format using ESXDOS,
mainly because ESXDOS relays in it's own core, which is installed inside the DivMMC/DivIDE flash, and externar files such as ESXDOS.SYS, 
that should be in the SD card. Also, the core and the ESXDOS.SYS file should match in version number, so a developer cannot create a SD
card which would work on every DivMMC/IDE, as the developer doesn't know which version of ESXDOS is installed in target DivMMCs.

In latest versions of ESXDOS, the autoboot feature was implemented, and AUTOXEC.BAS can run any game in the SD card, but again, not if 
you don't know the ESXDOS version of the user.

##So what we found?

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



