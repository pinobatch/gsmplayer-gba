GSM Player
==========
This is a port of [GSM Player for GBA] to devkitARM as of 2019.
(It was originally designed for devkitARM as of 2004, and several
things ended up broken with linker script changes since then.)

[GSM Player for GBA]: https://pineight.com/gba/gsm/


Building a ROM
--------------
1. If building from source, `make allnewgsm-bare.gba` and pad
   `allnewgsm-bare.gba` to a 256-byte boundary
2. Convert audio files to GSM at 18157 Hz (a nonstandard rate; see
   `docs/lying_to_sox.txt` for how to force this in SoX and FFmpeg)
3. Pack them into a single GBFS file using `gbfs` included with
   devkitARM tools: `gbfs gsmsongs.gbfs *.gsm`
4. Concatenate the player and the songs.
    - On Windows: `copy /b allnewgsm-bare.gba+gsmsongs.gbfs allnewgsm.gba`
    - On UNIX: `cat allnewgsm-bare.gba gsmsongs.gbfs > allnewgsm.gba`

Controls
--------
To control the player:

- Left: Previous track
- Right: Next tracks
- L: Seek backward
- R: Seek forward
- Select: Lock other keys
- Start: Pause or resume


Copyright 2004, 2019 Damian Yerrick