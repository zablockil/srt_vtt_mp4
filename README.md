## Test files .srt/.vtt in .mp4 container

tools used:

* [Windows 10](https://en.wikipedia.org/wiki/Windows_10)
* [MSYS2](https://www.msys2.org/)
* [AviSynth+](https://github.com/AviSynth/AviSynthPlus/releases)
* [AvsPmod](https://github.com/gispos/AvsPmod/releases)
* [avs2pipemod](https://github.com/chikuzen/avs2pipemod/releases)
* [sox](https://sourceforge.net/projects/sox/files/sox/)
* [qaac](https://github.com/nu774/qaac/releases)
* [GPAC](https://gpac.io/downloads/gpac-nightly-builds/)
* [QSVEncC](https://github.com/rigaya/QSVEnc/releases)
* [AtomicParsley](https://github.com/wez/atomicparsley/releases)
* [srt-to-vtt-cl](https://github.com/nwoltman/srt-to-vtt-cl/releases)
* [vcredist_x86.exe](https://gist.github.com/ChuckMichael/7366c38f27e524add3c54f710678c98b)
* [UniExtract2](https://github.com/Bioruebe/UniExtract2/releases)

--

## steps to reproduce (UCRT64 MSYS2 Environment):

```
$ avs2pipemod64.exe -info 90s.avs

avisynth_version 2.600 / AviSynth+ 3.7.3 (r4003, 3.7, x86_64)
script_name      R:/90s.avs

v:width            720
v:height           404
v:image_type       framebased
v:field_order      not specified
v:pixel_type       YV12
v:bit_depth        8
v:number of planes 3
v:fps              25/1
v:frames           2250
v:duration[sec]    90.000

a:sample_rate    48000
a:format         float
a:bit_depth      32
a:channels       2
a:samples        4320000
a:duration[sec]  90.000
```

```
avs2pipemod64.exe -y4mp 90s.avs | QSVEncC64.exe --y4m -i - --codec h264 -o QSVEncC.264

avs2pipemod[info]: writing 2250 frames of 25/1 fps, 720x404,
                   sar 0:0, YUV-420-planar-8bit progressive video.
--------------------------------------------------------------------------------
QSVEncC.264
--------------------------------------------------------------------------------
QSVEncC (x64) 7.60 (r3254) by rigaya, Feb 16 2024 12:50:55 (VC 1937/Win)
...
Async Depth    3 frames
Buffer Memory  d3d11, 13 work buffer
Input Info     y4m(yv12)->nv12 [SSE2], 720x404, 25/1 fps
AVSync         cfr
Output         H.264/AVC(yuv420) High @ Level 3
               720x404p 1:1 25.000fps (25/1fps)
Target usage   4 - balanced
Encode Mode    ICQ (Intelligent Const. Quality)
ICQ Quality    23
QP Limit       min: none, max: none
Ref frames     2 frames
Bframes        3 frames, B-pyramid: off
Max GOP Length 250 frames
Ext. Features  PerMBRC RepeatPPS
avs2pipemod[info]: finished, wrote 2250 frames [100%].
avs2pipemod[info]: total elapsed time is 3.363 sec.

encoded 2250 frames, 844.91 fps, 8.24 kbps, 0.09 MB
encode time 0:00:02, CPULoad: 7.9%
frame type IDR    9
frame type I     18,  total size  0.02 MB
frame type P    567,  total size  0.02 MB
frame type B   1674,  total size  0.05 MB
```

```
avs2pipemod64.exe -extwav 90s.avs | sox.exe --ignore-length --type wav - --comment "" --rate 44100 --encoding floating-point sox.wav -V3 --temp tmp

avs2pipemod[info]: writing 90.000 seconds of 48000 Hz, 459561500674 channel audio.
sox.exe:      SoX v14.4.2
sox.exe INFO wav: EXTENSIBLE
sox.exe WARN wav: wave header missing extended part of fmt chunk

Input File     : '-' (wav)
Channels       : 2
Sample Rate    : 48000
Precision      : 25-bit
Sample Encoding: 32-bit Floating Point PCM
Endian Type    : little
Reverse Nibbles: no
Reverse Bits   : no


Output File    : 'sox.wav'
Channels       : 2
Sample Rate    : 44100
Precision      : 25-bit
Sample Encoding: 32-bit Floating Point PCM
Endian Type    : little
Reverse Nibbles: no
Reverse Bits   : no

sox.exe INFO sox: effects chain: input        48000Hz  2 channels
sox.exe INFO sox: effects chain: rate         44100Hz  2 channels
sox.exe INFO sox: effects chain: output       44100Hz  2 channels
avs2pipemod[info]: wrote 90.000 seconds [100%]avs2pipemod[info]: total elapsed time is 1.303 sec.
```

```
qaac64.exe --tvbr 82 --quality 2 --ignorelength --no-optimize --verbose --tmpdir tmp -o qaac64.m4a sox.wav

qaac 2.81, CoreAudioToolbox 7.10.9.0

qaac64.m4a
Format: float32 -> float32
Output layout: Stereo
AAC-LC Encoder, TVBR q82, Quality 96
[100.0%] 1:30.000/1:30.000 (69.4x), ETA 0:00.000
3969000/3969000 samples processed in 0:01.312
Overall bitrate: 14.8737kbps
```

```
mp4box.exe -raw 1 qaac64.m4a -out qaac64_track1.aac
Exporting MPEG-4 AAC Audio - SampleRate 44100 2 channels 16 bits per sample
```

Creating .mp4 file without subtitles:

```
time_mp4="$(date +"%d/%m/%Y-%H:%M:%S")" && mp4box.exe -time "${time_mp4}" -mtime "${time_mp4}" -keep-utc -add "QSVEncC.264#video:name=" -add "qaac64_track1.aac#audio:group=1:name=" -itags reset -tmp tmp -new mp4/without_subtitles_0.mp4

Track Importing MPEG-4 AVC - Width 720 Height 404 FPS 100/4 SAR 1/1
AVC|H264 Import results: 2250 samples (4510 NALUs) - Slices: 10 I 567 P 1674 B - 0 SEI - 9 IDR - 0 CRA
AVC|H264 Stream uses forward prediction - stream CTS offset: 3 frames
AVC|H264 Max NALU size is 1279 - stream could be optimized by setting nal_length=2
Track Importing AAC  - SampleRate 44100 Num Channels 2
Saving mp4/without_subtitles_0.mp4: 0.500 secs Interleaving
```

```
AtomicParsley.exe mp4/without_subtitles_0.mp4 --freefree --metaEnema --output mp4/without_subtitles.mp4

 Started writing to mp4/without_subtitles.mp4.
 Progress: ====>  7% ---------------------------------------------------|
 Finished writing to mp4/without_subtitles.mp4.
```

Print dump info:

```
AtomicParsley.exe mp4/without_subtitles.mp4 -T 1 > mp4/without_subtitles.mp4.AtomicParsley.txt
```

--

* Prepare custom .srt files for testing
* Download test files from [ale5000.altervista.org website](https://ale5000.altervista.org/subtitles.htm) and convert them to LF (without BOM):

```
$ ./convert_to_LF.sh 'SubRip subtitles capability tester.srt' srt/SubRip_subtitles_capability_tester.srt
DONE.

...
```

--

Convert all files in the srt/ directory to `.vtt` files:

```
$ srt-vtt.exe --verbose
Searching for files to convert in: .
Converting file: .\colors.srt => .\colors.vtt ...ASCII text encoding detected ...done!
Converting file: .\Font_face_capability_tester.srt => .\Font_face_capability_tester.vtt ...ASCII text encoding detected ...done!
Converting file: .\SubRip_subtitles_bug_tester.srt => .\SubRip_subtitles_bug_tester.vtt ...ASCII text encoding detected ...done!
Converting file: .\SubRip_subtitles_bug_tester_ALTERNATIVE.srt => .\SubRip_subtitles_bug_tester_ALTERNATIVE.vtt ...UTF8_NOBOM text encoding detected ...done!
Converting file: .\SubRip_subtitles_capability_tester.srt => .\SubRip_subtitles_capability_tester.vtt ...UTF8_NOBOM text encoding detected ...done!
Converting file: .\Tester_for_dots_instead_of_commas_in_timestamps.srt => .\Tester_for_dots_instead_of_commas_in_timestamps.vtt ...ASCII text encoding detected ...done!
Converting file: .\Tester_for_overlapped_subtitles_in_SubRip_subtitles.srt => .\Tester_for_overlapped_subtitles_in_SubRip_subtitles.vtt ...ASCII text encoding detected ...done!
```

### Create `.mp4` with "Timed Text (tx3g)" subtitles from 3 .srt files

load & parse `.srt` as Timed Text (tx3g)
```
$ time_mp4="$(date +"%d/%m/%Y-%H:%M:%S")" && mp4box.exe -time "${time_mp4}" -mtime "${time_mp4}" -keep-utc -add "QSVEncC.264#video:name=" -add "qaac64_track1.aac#audio:group=1:name=" -add "srt/colors.srt:hdlr=text:txtflags=0xC0000000:group=2:lang=eng:name=Color tester" -add "srt/SubRip_subtitles_capability_tester.srt:hdlr=text:group=2:disable:lang=ger:name=Capability tester" -add "srt/Tester_for_overlapped_subtitles_in_SubRip_subtitles.srt:hdlr=text:group=2:disable:lang=fre:name=Overlapped subtitles" -itags reset -tmp tmp -new mp4/tx3g_from_3_srt.mp4

Track Importing MPEG-4 AVC - Width 720 Height 404 FPS 100/4 SAR 1/1
AVC|H264 Import results: 2250 samples (4510 NALUs) - Slices: 10 I 567 P 1674 B - 0 SEI - 9 IDR - 0 CRA
AVC|H264 Stream uses forward prediction - stream CTS offset: 3 frames
AVC|H264 Max NALU size is 1279 - stream could be optimized by setting nal_length=2
Track Importing AAC  - SampleRate 44100 Num Channels 2
Track Importing Timed Text - Text track 720 x 404 font Serif (size 18) layer 0
Track Importing Timed Text - Text track 720 x 404 font Serif (size 18) layer 0
...
Track Importing Timed Text - Text track 720 x 404 font Serif (size 18) layer 0
...
Saving mp4/tx3g_from_3_srt.mp4: 0.500 secs Interleaving
```

```
AtomicParsley.exe mp4/tx3g_from_3_srt.mp4 -T 1 > mp4/tx3g_from_3_srt.mp4.AtomicParsley.txt
```

### Create `.mp4` with "WebVTT (wvtt)" subtitles from 3 .vtt files

load & parse `.vtt` as WebVTT (wvtt)
```
$ time_mp4="$(date +"%d/%m/%Y-%H:%M:%S")" && mp4box.exe -time "${time_mp4}" -mtime "${time_mp4}" -keep-utc -add "QSVEncC.264#video:name=" -add "qaac64_track1.aac#audio:group=1:name=" -add "vtt/colors.vtt:hdlr=text:txtflags=0xC0000000:group=2:lang=eng:name=Color tester" -add "vtt/SubRip_subtitles_capability_tester.vtt:hdlr=text:group=2:disable:lang=ger:name=Capability tester" -add "vtt/Tester_for_overlapped_subtitles_in_SubRip_subtitles.vtt:hdlr=text:group=2:disable:lang=fre:name=Overlapped subtitles" -itags reset -tmp tmp -new mp4/wvtt_from_3_vtt.mp4

Track Importing MPEG-4 AVC - Width 720 Height 404 FPS 100/4 SAR 1/1
AVC|H264 Import results: 2250 samples (4510 NALUs) - Slices: 10 I 567 P 1674 B - 0 SEI - 9 IDR - 0 CRA
AVC|H264 Stream uses forward prediction - stream CTS offset: 3 frames
AVC|H264 Max NALU size is 1279 - stream could be optimized by setting nal_length=2
Track Importing AAC  - SampleRate 44100 Num Channels 2
Track Importing WebVTT - Text track 720 x 404 layer 0
Track Importing WebVTT - Text track 720 x 404 layer 0
...
Track Importing WebVTT - Text track 720 x 404 layer 0
...
Saving mp4/wvtt_from_3_vtt.mp4: 0.500 secs Interleaving
```

```
AtomicParsley.exe mp4/wvtt_from_3_vtt.mp4 -T 1 > mp4/wvtt_from_3_vtt.mp4.AtomicParsley.txt
```

#### (ADDENDUM) extract subtitles from `.mp4` file to `.srt` format:

```
mp4box.exe -srt 3 vtt/wvtt_from_3_vtt.mp4
```

#### (ADDENDUM) fix/clean `.srt` files:

```
mp4box.exe -add "file.srt:hdlr=text:name=" -new srt_file.mp4
mp4box.exe -srt 1 srt_file.mp4 -out srt_new.srt
```

## Links

* [default Subtitle](https://github.com/staxrip/staxrip/issues/737)
* [Subtitling with GPAC](https://github.com/gpac/gpac/wiki/Subtitling-with-GPAC)
* [SubRip](https://en.wikipedia.org/wiki/SubRip)
* [WebVTT](https://en.wikipedia.org/wiki/WebVTT)
* [TTXT Format Documentation](https://github.com/gpac/gpac/wiki/TTXT-Format-Documentation)
* [MPEG-4 Timed Text](https://en.wikipedia.org/wiki/MPEG-4_Part_17)
* [Media Data Atom Types](https://web.archive.org/web/20210308070923/https://developer.apple.com/library/archive/documentation/QuickTime/QTFF/QTFFChap3/qtff3.html#//apple_ref/doc/uid/TP40000939-CH205-SW80)
* [SubRip (.SRT) subtitles support in players](https://ale5000.altervista.org/subtitles.htm)

## Copyright

Copyright: public domain / MIT
