1. Video tutorial: https://youtu.be/b7SUjPzmgfM

2. Place audio files in mp3, wav, ogg format in the TCBoombox and TCVinylplayer folders.

3. (optional) Place vinyl cover photos in TCVinylplayer folder in jpg format. They should be named the same as the music track file. Each music file can have its own cover.
For example, the file with the track is called "AC DC - Highway To Hell (1979).mp3", the file with the cover should be called "AC DC - Highway To Hell (1979).jpg".
The easiest way to find the cover is when you google it: "AC DC - Highway To Hell vinyl cover".

4. Run AddYourMusicToTheMod.exe. Depending on which folder the files is placed in, either a cassette or vinyl will be generated. When adding new music, you can re-run this file. 

5. In the file mod.info change the ID to your own.

6. To ensure that your mod does not conflict with other True Music addons, you need to rename the files:
media\lua\server\Items\TCGLoadingTCBoombox.lua
media\lua\server\Items\TCGLoadingTCVinylplayer.lua
media\lua\shared\TCGMusicDefenitionsTCBombox.lua
media\lua\shared\TCGMusicDefenitionsTCVinylplayer.lua
media\scripts\TCGMusicScriptTCBoombox.txt
media\scripts\TCTCGMusicScriptTCVinylplayer.txt
media\scripts\TCGSoundsTCBombox.txt
media\scripts\TCGSoundsTCVinylplayer.txt

For example, add your mod Workshop ID to their names:
media\lua\server\Items\TCGLoadingTCBoombox2722332157.lua
media\lua\server\Items\TCGLoadingTCVinylplayer2722332157.lua
media\lua\shared\TCGMusicDefenitionsTCBombox2722332157.lua
media\lua\shared\TCGMusicDefenitionsTCVinylplayer2722332157.lua
media\scripts\TCGMusicScriptTCBoombox2722332157.txt
media\scripts\TCTCGMusicScriptTCVinylplayer2722332157.txt
media\scripts\TCGSoundsTCBoombox2722332157.txt
media\scripts\TCGSoundsTCVinylplayer2722332157.txt

7. Send the mod to all users of the server (we allow to publish a mod created from the template)

8. If you want to upload your work to Workshop, you will need to delete folders and files:
\media\yourMusic\audioConverter
\media\yourMusic\pictureConverter
\media\yourMusic\AddYourMusicToTheMod.exe
\media\yourMusic\DeleteYourMusicFromTheMod.exe

-----------------

P.S. If you have concerns about running the exe-file, you can study its source code (files AddYourMusicToTheMod.cs, DeleteYourMusicFromTheMod.cs) and compile it yourself with a standard Microsoft .NET Framework compiler (csc.exe).