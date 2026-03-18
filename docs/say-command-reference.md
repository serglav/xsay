# macOS `say` Command — Complete Reference

Researched: 2026-03-03. macOS 15.x Sequoia, Apple Silicon.

## Synopsis

```
say [-v voice] [-r rate] [-o outfile [format opts] | -n name:port | -a device]
    [-f file | string ...]  [--progress] [-i[=markup]]
    [--file-format=fmt] [--data-format=fmt] [--channels=N]
    [--bit-rate=N] [--quality=0-127]
```

## All Flags

| Flag | Long form | Description |
|------|-----------|-------------|
| `-v voice` | `--voice=voice` | Select voice; `?` lists all installed (197 on test machine) |
| `-r rate` | `--rate=rate` | Words per minute (practical: 50-500; system range 0-65535) |
| `-f file` | `--input-file=file` | Read from file; `-f -` for stdin |
| `-o file` | `--output-file=file` | Save to audio file (default AIFF) |
| `-n name[:port]` | `--network-send=name:port` | Route via AUNetSend (network audio streaming) |
| `-a device` | `--audio-device=device` | Output device by ID or name; `?` lists devices |
| `-i[=markup]` | `--interactive[=markup]` | Interactive: highlight words as spoken |
| | `--progress` | Progress meter (%, bytes, elapsed time) |
| | `--file-format=fmt` | Container format; `?` lists all |
| | `--data-format=fmt` | Codec/PCM spec; `?` lists all |
| | `--channels=N` | Channel count (synth is always mono) |
| | `--bit-rate=N` | For compressed formats; `?` lists valid rates |
| | `--quality=0-127` | Converter quality |

### Undocumented flags (from `strings /usr/bin/say`)

| Flag | Behavior |
|------|----------|
| `--duck-audio` | Lowers other system audio during speech (EXIT 0, works) |
| `--annotate` | Broken on current macOS (always error -50) |
| `--all-voices` | Silently exits 0 — likely internal debug |

No `--help` flag. No environment variables. All docs from `man say`.

## Audio Output

### Native synthesis: 22050 Hz, mono, 16-bit (fixed engine output)

FLAC preserves 24-bit internal precision; other formats truncate to 16-bit.

### Supported containers (`--file-format=?`)

| ID | Name | Extensions |
|----|------|-----------|
| `AIFF` | AIFF | .aiff, .aif |
| `AIFC` | AIFC | .aifc |
| `WAVE` | WAVE | .wav |
| `caff` | CAF | .caf |
| `m4af` | Apple MPEG-4 Audio | .m4a, .m4r |
| `m4bf` | Apple MPEG-4 AudioBooks | .m4b |
| `mp4f` | MPEG-4 Audio | .mp4 |
| `adts` | AAC ADTS | .aac |
| `flac` | FLAC | .flac |
| `Oggf` | Ogg | .opus, .ogg |
| `NeXT` | NeXT/Sun | .snd, .au |
| `Sd2f` | Sound Designer II | .sd2 |
| `W64f` | Wave64 | .w64 |
| `BW64` | WAVE BW64 (>4GB) | .wav |
| `RF64` | WAVE RF64 (>4GB) | .wav |
| `loas` | LATM/LOAS | .loas, .xhe |

### PCM data format specifier syntax

```
[BE|LE][F|I|UI][8|16|24|32|64][@samplerate][/flags]
```

Examples: `LEI16`, `BEF32`, `LEF32@8000`

### Extension auto-detection (inconsistent!)

- Auto-detected: `.aiff`, `.aac`, `.flac`, `.caf`
- Require explicit `--file-format`: `.wav`, `.m4a`

### Practical examples

```bash
say -o out.aiff "hello"                                     # AIFF (default)
say -o out.wav --file-format=WAVE "hello"                   # WAV
say -o out.m4a --file-format=m4af --data-format=aac "hello" # AAC
say -o out.m4a --file-format=m4af --data-format=alac "hello" # ALAC
say -o out.flac "hello"                                     # FLAC (24-bit)
say -o out.opus --file-format=Oggf --data-format=opus "hello" # Opus
say -o out.caf "hello"                                      # CAF
```

## Interactive Mode

```bash
say --interactive "Hello world"              # reverse video highlight
say --interactive=green "Hello world"        # green text
say --interactive=green/black "Hello"        # green on black
say --interactive=bold "Hello world"         # bold
say --interactive=smul "Hello world"         # underline
```

Bug: `-i=red` (short form) fails — must use `--interactive=red` (long form).

## Network Audio Streaming

```bash
say -n AUNetSend "Hello network"
say -n AUNetSend:52800 "Hello on custom port"
```

Requires AUNetReceive host (AU Lab, Logic Pro) on receiving end.

## Edge Cases

| Test | Result |
|------|--------|
| Unknown voice name | Silently falls back — no error, EXIT 0 |
| Empty string `""` | EXIT 0, no audio |
| `-r 0` | Clamped to internal minimum |
| `-r 9999` | Clamped to internal maximum |
| Non-UTF-8 input | "Input text is not UTF-8 encoded", EXIT 1 |
| Multiple string args | Concatenated with spaces |
| `echo text \| say -f -` | Works (stdin pipe) |
| Headless / no audio | May fail — use `\|\| true` in CI |

## Framework Architecture

```
say(1) CLI
  -> ApplicationServices.framework (Speech Synthesis Manager / Carbon)
  -> AudioToolbox.framework (ExtAudioFile, format conversion)
  -> AudioUnit.framework (AUGraph, AUNetSend)
  -> CoreAudio.framework (device enumeration)
  -> libncurses (interactive mode terminal control)
```

`say` does NOT use AVFoundation. It uses the Carbon Speech Synthesis Manager.

### Deprecation status

- NSSpeechSynthesizer (AppKit): deprecated macOS 14+
- Speech Synthesis Manager (Carbon): still functional, no new features
- AVSpeechSynthesizer (modern): no `[[...]]` commands, no PHON/TUNE mode
- `say` CLI: still ships, still works, unclear future
