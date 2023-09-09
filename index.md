# Welcome

This patch is meant to fix a recurring bug affecting save files visibility in [Air](https://en.wikipedia.org/wiki/Air_(video_game)).

## Who is this patch for?

This patch can be applied on any translation of Air:

- Original translation
- Gao Gao Translation
- Winter Confetti translation

Its main purpose is to fix the save files that are no longer visible ingame, although it can be used on any save file and translation to make it compatible with all others.

## How to run the patch?

Download the `.exe` on the [releases page](https://github.com/mashedmonk/pasta/releases/)

There *might* be a false positive triggered by your antivirus software.
If so, you can try **one** of the methods below:

- Download the `.ps1` script and `clickme` shortcut. Put them in the same folder and launch `clickme`
- Download only the `.ps1` script and run it in a PowerShell console. You need to first set your security settings to allow execution. To do so, launch a PowerShell console in administrator mode and run `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned`

## When and where the save bug happens?

When those factors come together:

- Gao Gao translation is used; Not sure if Winter Confetti is impacted
- Game is run on Windows 10 or newer
- Some time passes
- Or save files are restored on a different computer

Then the save files are no longer seen by the game, although the files are still present.

## Why the save bug happens?

The name of the game is set in `GAMEEXE.INI` and can be freely changed.
For example, Gao Gao translation has `#CAPTION="Air "`.

The value is used to display the text in the title bar.
It is also stored in the save files to help the game identify this is not a save file from another VN using RealLive engine.

It should be noted that this behavior prevents switching translations because each use a different title.

But what is tricky is the game does not just use the raw value stored in the `GAMEEXE.INI`, it is interpreted in some way before being shown in the title bar.

Gao Gao translation has a bug that alters this raw value when it is displayed in the title bar. Some characters are replaced by random ones. Depending on the length of the title, those characters can be invisible, especially if the title length is a multiple of 4. Other lengths tend to produce more obvious garbled text.

The resulting title is random across time and from computer to computer. So if it changes someday, the save files are not visible anymore by the game installation it was played on.

## How to prevent this from happening again and make the old save files visible again?

The title seems to be encoded on 128 bytes.
The randomness affects all bytes, even if the title is shorter than 127 characters, which is always true.

The trick here is to put as much whitespaces as needed to fill in the 127 bytes.

So we set a 127 characters length title in `GAMEEXE.INI`:

```ini
#CAPTION="Air                                                                                                                            "
```

Future save files will no longer be impacted.

To restore the visibility of the old save files, each file must be modified to correspond to the new title.

For each file we replace the 128 bytes from offset `0x18`: `Air` followed by 124 whitespaces and a `NULL` to make a 128 bytes length.
We put a NULL at the end because the game seems to frequently do so. It is also a good visual cue to separate the title from the following data.

The first offsets of a successfully patched save file looks like this:

```
           00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F

00000000   38 02 00 00 12 27 00 00 E2 07 0C 00 06 00 0F 00  8....'..â.......
00000010   0F 00 07 00 15 00 6A 00 41 69 72 20 20 20 20 20  ......j.Air
00000020   20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20
00000030   20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20
00000040   20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20
00000050   20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20
00000060   20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20
00000070   20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20
00000080   20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20
00000090   20 20 20 20 20 20 20 00 31 38 74 68 20 4A 75 6C         .18th Jul
000000A0   79 20 28 54 75 65 73 29 20 00 72 01 6C 00 02 00  y (Tues) .r.l...
```

The title is also stored in `read.sav`. The value is updated each time a save is loaded.
So no need to alter this value, the game already takes care of this.

## Technology used

PowerShell + AutoHotKey for wrapping the script in `.exe` format.

## Credits

Script made by [@mashedmonk](https://github.com/mashedmonk) with help from [@Sep7em](https://github.com/Sep7em)

Please be free to come talk about the game or series at [https://discord.gg/N8wTXEK](https://discord.gg/N8wTXEK)

<a href="https://discord.gg/N8wTXEK" target="_blank">
<img src="https://discordapp.com/api/guilds/474442450836914188/widget.png?style=banner3" alt="Bannière Discord"/>
</a>