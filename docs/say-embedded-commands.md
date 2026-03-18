# macOS `say` Embedded Speech Commands — `[[...]]` Reference

Researched: 2026-03-03. macOS 15.x Sequoia, Apple Silicon.

## Overview

Embedded commands use `[[command]]` delimiters inline in text. Processed by the Speech Synthesis Manager (Carbon API). Multiple commands can be combined: `[[emph +; rate 165]]`.

## TESTED: Which commands work on which voice tiers?

| Command | Legacy (Fred) | Enhanced (Evan) | Premium (Zoe) |
|---------|:---:|:---:|:---:|
| `[[slnc N]]` | YES | YES | YES |
| `[[rate N]]` | YES | YES | YES |
| `[[pbas N]]` | YES | **YES** | **YES** |
| `[[volm N]]` | YES | Accepted | Accepted |
| `[[pmod N]]` | YES | Accepted | Accepted |
| `[[emph +/-]]` | YES | Accepted | Accepted |

**NOTE**: Web sources claim `[[pbas]]` only works on legacy voices. This was **debunked by interactive testing** on 2026-03-03. `[[pbas 80]]` produces a clear, unmistakable pitch change on both Evan (Enhanced) and Zoe (Premium). Tested at 180 wpm with human verification.

"Accepted" = EXIT 0, no error, but effect not verified via file size or human ear.

## Complete Command Table

### Prosody Controls

| Command | Syntax | Range | Description |
|---------|--------|-------|-------------|
| `rate` | `[[rate N]]` or `[[rate +/-N]]` | 0-65535 WPM | Speech rate. Absolute or relative. |
| `pbas` | `[[pbas N]]` or `[[pbas +/-N]]` | 1.0-127.0 (MIDI) | Pitch base. 60=middle C. |
| `pmod` | `[[pmod N]]` or `[[pmod +/-N]]` | 0-127 | Pitch modulation (expressiveness). 0=monotone. |
| `volm` | `[[volm N]]` or `[[volm +/-N]]` | 0.0-1.0 | Volume. Absolute or relative. |
| `emph` | `[[emph +]]` / `[[emph -]]` | | Emphasis on next word. |

### Silence / Reset

| Command | Syntax | Description |
|---------|--------|-------------|
| `slnc` | `[[slnc N]]` | Silence in milliseconds. Universally supported. |
| `rset` | `[[rset 0]]` | Reset all parameters to defaults. |

### Input Mode

| Command | Syntax | Description |
|---------|--------|-------------|
| `inpt` | `[[inpt TEXT]]` | Normal text input (default). |
| `inpt` | `[[inpt PHON]]` | Phoneme input mode (see phonemes doc). |
| `inpt` | `[[inpt TUNE]]` | Tune mode for musical/precise pitch (see tune doc). |

### Character / Number Mode

| Command | Syntax | Description |
|---------|--------|-------------|
| `char` | `[[char LTRL]]` | Spell out each character. |
| `char` | `[[char NORM]]` | Normal processing (default). |
| `nmbr` | `[[nmbr LTRL]]` | "46" -> "four six". |
| `nmbr` | `[[nmbr NORM]]` | "46" -> "forty-six" (default). |

### Context / Metadata

| Command | Syntax | Description |
|---------|--------|-------------|
| `cmnt` | `[[cmnt text]]` | Comment — ignored by synthesizer. |
| `ctxt` | `[[ctxt WSKP\|WORD\|NORM\|TSKP\|TEXT]]` | Context hint for ambiguous words (10.4+). |
| `dlim` | `[[dlim $$ $$]]` | Change command delimiters. |
| `sync` | `[[sync 0x00000001]]` | Sync callback (programmatic use only). |
| `xtnd` | `[[xtnd <OSType> ...]]` | Synthesizer extension command. |
| `vers` | `[[vers N]]` | Format version declaration. |

## Punctuation Prosody (implicit)

| Char | Effect |
|------|--------|
| `,` | Pitch rise + short pause |
| `.` | Pitch fall + longer pause |
| `(` | Reduces pitch range |
| `)` | Restores pitch range |
| `"` | Expands pitch range |

## Phoneme Mode Quick Reference

Activate: `[[inpt PHON]]`, deactivate: `[[inpt TEXT]]`.

### Vowels (uppercase pairs)

| Code | Example | Code | Example |
|------|---------|------|---------|
| `AE` | bat | `AO` | caught |
| `EY` | bait | `AX` | about (schwa) |
| `IY` | beet | `EH` | bet |
| `IH` | bit | `AY` | bite |
| `IX` | roses | `AA` | father |
| `UW` | boot | `UH` | book |
| `UX` | bud | `OW` | boat |
| `AW` | bout | `OY` | boy |

### Consonants (case-sensitive)

| Code | Example | Code | Example |
|------|---------|------|---------|
| `b` | bin | `C` | chin |
| `d` | din | `D` | them (voiced th) |
| `f` | fin | `g` | gain |
| `h` | hat | `J` | jump |
| `k` | kin | `l` | limb |
| `m` | mat | `n` | nap |
| `N` | tang | `p` | pin |
| `r` | ran | `s` | sin |
| `S` | shin | `t` | tin |
| `T` | thin (unvoiced) | `v` | van |
| `w` | wet | `y` | yet |
| `z` | zoo | `Z` | measure |

### Prosodic modifiers (before phoneme)

| Symbol | Effect |
|--------|--------|
| `1` | Primary stress |
| `2` | Secondary stress |
| `=` | Syllable boundary |
| `~` | Destressed |
| `_` | Normal stress |
| `+` | Emphatic stress |
| `%` | Silence |
| `@` | Breath intake |

### Example

```bash
say '[[inpt PHON]] +yUW _1tAOl=kIHn ~AX [[pbas +3]] +mIY? [[inpt TEXT]]'
# "You talkin' to me?" with stress/pitch control
```

## Tune Mode Quick Reference

Musical synthesis with exact Hz and ms per phoneme.

```
[[inpt TUNE]]
<phoneme> {D <duration_ms>; P <pitch_hz>:<position_0-100> [P ...]}
[[inpt TEXT]]
```

Example:
```bash
say '[[inpt TUNE]] ~ AA {D 120; P 176.9:0 171.4:22 161.7:61} r {D 60; P 166.7:0} [[inpt TEXT]]'
```

Multiple P points create pitch curves (smooth interpolation).
