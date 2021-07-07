GSM Player
==========
In mid-2004, I ported the GSM RPE-LTP (also called GSM Full Rate)
audio codec, which has been used in mobile phones, to the Game Boy
Advance.  Now you can use your GBA as a portable music player, with
up to 150 minutes of Good Sounding Music on a 256 Mbit flash cart. 

From mid-2004 to mid-2019, [GSM Player for GBA] went unmaintained,
and changes to popular GBA homebrew toolchains rendered it
unbuildable.  This repository ports the application to a more
recent version of devkitARM.

[GSM Player for GBA]: https://pineight.com/gba/gsm/


Building a ROM
--------------
1. If building from source:

       make build/allnewgsm-bare_mb.gba
       padbin 256 build/allnewgsm-bare_mb.gba

2. Convert audio files to GSM at 18157 Hz (a nonstandard rate; see
   `docs/lying_to_sox.txt` for how to force this in SoX and FFmpeg)
3. Pack them into a single GBFS file using `gbfs` included with
   devkitARM tools: `gbfs gsmsongs.gbfs *.gsm`
4. Concatenate the player and the songs.
    - On Windows: `copy /b build\allnewgsm-bare_mb.gba+gsmsongs.gbfs allnewgsm.gba`
    - On UNIX: `cat build/allnewgsm-bare_mb.gba gsmsongs.gbfs > allnewgsm.gba`

Controls
--------
To control the player:

- Left: Previous track
- Right: Next track
- L: Seek backward
- R: Seek forward
- Select: Lock other keys
- Start: Pause or resume


Copyright 2004, 2019 Damian Yerrick
