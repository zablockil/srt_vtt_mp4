* [Subtitling with GPAC](https://github.com/gpac/gpac/wiki/Subtitling-with-GPAC)
* [TTML in MP4 and MPEG-DASH guidelines](https://github.com/rbouqueau/TTML_in_MP4_DASH_statement)

## `tx3g.mp4` (text/tx3g, sbtl/tx3g, text/text)

muxing:
```
time_mp4="$(date +"%d/%m/%Y-%H:%M:%S")" && mp4box.exe -time "${time_mp4}" -mtime "${time_mp4}" -keep-utc -add "QSVEncC.264#video:name=" -add "qaac64_track1.aac#audio:group=1:name=" -add "SubRip.srt:hdlr=text:stype=tx3g:group=2:disable:name=(text/tx3g)" -add "SubRip.srt:hdlr=sbtl:stype=tx3g:group=2:disable:name=(sbtl/tx3g)" -add "SubRip.srt:hdlr=text:stype=text:group=2:disable:name=(text/text)" -itags reset -tmp tmp -new tx3g.mp4
```

AtomicParsley dump:
```
AtomicParsley.exe tx3g.mp4 -T 1 > tx3g.mp4.AtomicParsley.txt
```

demuxing:
```
mp4box.exe -srt 3 tx3g.mp4
mp4box.exe -srt 4 tx3g.mp4
mp4box.exe -srt 5 tx3g.mp4
```

## `wvtt.mp4` (text/wvtt)

muxing:
```
time_mp4="$(date +"%d/%m/%Y-%H:%M:%S")" && mp4box.exe -time "${time_mp4}" -mtime "${time_mp4}" -keep-utc -add "QSVEncC.264#video:name=" -add "qaac64_track1.aac#audio:group=1:name=" -add "WebVTT.vtt:hdlr=text:stype=wvtt:group=2:disable:name=(text/wvtt)" -itags reset -tmp tmp -new wvtt.mp4
```

AtomicParsley dump:
```
AtomicParsley.exe wvtt.mp4 -T 1 > wvtt.mp4.AtomicParsley.txt
```

demuxing:
```
mp4box.exe -raw 3 -webvtt-hours wvtt.mp4
mp4box.exe -raws 3 -webvtt-hours wvtt.mp4
```

## `ttml.mp4` (subt/stpp)

muxing:
```
time_mp4="$(date +"%d/%m/%Y-%H:%M:%S")" && mp4box.exe -time "${time_mp4}" -mtime "${time_mp4}" -keep-utc -add "QSVEncC.264#video:name=" -add "qaac64_track1.aac#audio:group=1:name=" -add "TimedTextMarkupLanguage.ttml:hdlr=subt:stype=stpp:group=2:disable:name=(subt/stpp)" -itags reset -tmp tmp -new ttml.mp4
```

AtomicParsley dump:
```
AtomicParsley.exe ttml.mp4 -T 1 > ttml.mp4.AtomicParsley.txt
```

demuxing:
```
mp4box.exe -raw 3 ttml.mp4
mp4box.exe -raws 3 ttml.mp4
```
