# PASTA - Patch AIR Saves and Title Anomaly

![pasta48](https://user-images.githubusercontent.com/79142547/108626949-2a8e2b80-7453-11eb-8124-89a4f9c7d1cf.png) This patch is meant to fix a recurring bug affecting save files visibility in [AIR](https://en.wikipedia.org/wiki/Air_(video_game)).

## Information for users of the previous version of the patch

Due to recent updates, the previous implementation of the patch does not work anymore on Windows 11. Windows 10 does not seem to be affected. A new fix has been found wich is based on the previous one.

## Who is this patch for?

This patch can be applied on any translation of AIR:

- Original translation
- Gao Gao Translation
- Winter Confetti translation

Its main purpose is to fix the save files that are no longer visible ingame, although it can be used on any save file and translation to make it compatible with all others.

## How to run the patch?

Download the `.exe` on the [releases page](https://github.com/mashedmonk/pasta/releases/)

Smart Screen or your antivirus software *might* block the program.

It is a **false positive**, the program is safe, you can check it on [VirusTotal](https://www.virustotal.com/gui/file/4eccee6e8cc522f8b127ea97166434082cf480757db23fd63dd1c2c262e87740?nocache=1) should you have any security concern.

You should use the `Patch` button. Should it not work as intended, you can also try the `Patch (alternate fix)` button to apply the previous version of the fix. 

## When and where the save bug happens?

When those factors come together:

- Gao Gao translation is used; As of today, there has been no report of Winter Confetti being impacted
- Game is running on Windows 10 or newer
- Some time passes
- Or save files are restored on a different computer

Then the save files are no longer seen by the game, although the files are still present.

If you used the previous version of the patch and game is running on Windows 11, the save files will be randomly visible from time to time (you should at least see it after 4 successive launches of the game).

## Why the save bug happens?

The name of the game is set in `GAMEEXE.INI` and can be freely changed.
For example, Gao Gao translation has `#CAPTION="Air "`.

The value is used to display the text in the title bar.
It is also stored in the save files to help the game identify this is not a save file from another VN using RealLive engine.

It should be noted that this behavior prevents switching translations because each use a different title.

But what is tricky is the game does not just use the raw value stored in the `GAMEEXE.INI`, it is interpreted in some way before being shown in the title bar.

Gao Gao translation has a bug that alters this raw value when it is displayed in the title bar. Some characters are replaced by random ones. Depending on the length of the title, those characters can be invisible, especially if the title length is a multiple of 4. Other lengths tend to produce more obvious garbled text.

The resulting title is random across time and from computer to computer. So if it changes someday, the save files are not visible anymore by the game installation it was played on.

The source of the bug in Gao Gao translation has been identified. It is due to a misconfiguration in the `GAMEEXE.INI`. The `#NAME_ENC` option is set to `2` instead of `0`. This option is intended to support non ASCII characters in the titlebar and should not have been set. One more side effect of this wrong parameter is that the date is not shown in title bar. Setting it to `0` fixes it, the date is shown as intended, as some other texts like `Main Menu`.

## How to prevent this from happening again and make the old save files visible again?

The trick here is to set `#NAME_ENC=0` in `GAMEEXE.INI` instead of `2` if it is present.

The title is also changed to `Air` in `GAMEEXE.INI` as to make it different to all other translations:

```ini
#CAPTION="Air"
```

Future save files will no longer be impacted.

To restore the visibility of the old save files, each file must be modified to correspond to the new title.

The title seems to be encoded on 128 bytes.
The randomness affects all bytes, even if the title is shorter than 127 characters, which is the case with the default titles of the different translations.

For each file we replace the 128 bytes from offset `0x18`: `Air` followed by 125 `NULL` to make a 128 bytes length.

The first offsets of a successfully patched save file looks like this:

```
           00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F

00000000   38 02 00 00 12 27 00 00 E2 07 0C 00 06 00 0F 00  8....'..â.......
00000010   0F 00 07 00 15 00 6A 00 41 69 72 00 00 00 00 00  ......j.Air.....
00000020   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000030   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000040   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000050   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000060   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000070   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000080   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000090   00 00 00 00 00 00 00 00 31 38 74 68 20 4A 75 6C  ........18th Jul
000000A0   79 20 28 54 75 65 73 29 20 00 72 01 6C 00 02 00  y (Tues) .r.l...
```

The title is also stored in `read.sav`. The value is updated each time a save is loaded.
So no need to alter this value, the game already takes care of this.

The old fix is also implemented in this new version of the patch. 
It functions in exactly the same way as before except that the `#NAME_ENC` option in `GAMEEXE.INI` is also modified as it is a misconfiguration.

Here are the differences :

Instead the trick is to put as much whitespaces as needed in the title to fill in the 127 bytes.

So we set a 127 characters length title in `GAMEEXE.INI`:

```ini
#CAPTION="Air                                                                                                                            "
```

For each file we replace the 128 bytes from offset `0x18`: `Air` followed by 124 whitespaces and a `NULL` to make a 128 bytes length.
We put a NULL at the end because the game seems to frequently do so. It is also a good visual cue to separate the title from the following data.

## Technology used

AutoHotKey v2.

## Credits

Program made by [@mashedmonk](https://github.com/mashedmonk) with help from [@Sep7em](https://github.com/Sep7em)

Please be free to come talk about the game or series at [https://discord.gg/N8wTXEK](https://discord.gg/N8wTXEK)

<a href="https://discord.gg/N8wTXEK" target="_blank">
<img src="https://discordapp.com/api/guilds/474442450836914188/widget.png?style=banner3" alt="Bannière Discord"/>
</a>
