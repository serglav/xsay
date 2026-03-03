# xsay Changelog

## v3.2 — 2026-03-03

### Changed
- **Trimmed to 4 voices**: Evan (Enhanced), Nathan (Enhanced), Zoe (Premium), Tom (Enhanced)
- **Removed profiles**: ava, lee, allison, nicky, samantha — config bloat without quality justification
- **Added [zoe] profile**: Zoe (Premium) at 180 wpm with `narrate` flag
- **Undid evan↔nathan voice swap**: Each profile now uses its own voice
- **Minimal flags**: Removed legacy aliases (narrate→ava, announce→lee, instructor→evan, student→ava)
- **New flag mapping**: narrate→zoe, repo→nathan

## v3.1 — 2026-03-02

### Added
- **Inline sound effects**: `{name}` tokens in messages play `.aiff` files from `soundfx/` directory
- **Sound effects library**: 14 macOS system sounds copied to `_xsay/soundfx/` (basso, blow, bottle, frog, funk, glass, hero, morse, ping, pop, purr, sosumi, submarine, tink)
- **`expand_soundfx()` function**: Producer-side expansion converting `{name}` → `[[sfx:name]]` markers, gated by file existence
- **Consumer interleave engine**: Splits messages at `[[sfx:*]]` boundaries, alternates `say`/`afplay` calls sequentially
- **`--sounds [name]` flag**: List all available sound effects or preview one by name
- **`list_sounds()` function**: Discovery and preview CLI for sound effects

### Changed
- `show_help()` updated with SOUND EFFECTS section and `--sounds` flag
- `show_context()` updated with Sound Effects section, `--sounds` flag, architecture note
- `show_config_info()` updated with soundfx dir path and count
- `write_to_fifo()` now chains `expand_soundfx()` after `expand_pauses()`
- Version bumped to v3.1 in header, help, and context outputs

### Technical Notes
- `{name}` regex (`[a-z_]+`) is disjoint from `{N}` regex (`[0-9]+`) — zero collision risk
- Non-matching `{name}` tokens pass through as literal text (file-existence gated)
- `afplay -v` volume matches profile's `volume=` setting
- FIFO protocol unchanged — `[[sfx:name]]` markers embedded in message field like `[[slnc]]`
- Consumer non-sfx path unchanged (single string check gates interleave)

## v3.0 — 2026-03-02

### Breaking Changes
- Master config moved from `~/.config/xsay/xsay.conf` to `_xsay/xsay.conf`
- FIFO protocol extended from 3-field to 5-field (backward compatible)
- Profile sections renamed: `[narrator]`->`[ava]`, `[announcer]`->`[lee]`, `[instructor]`->`[evan]`, `[student]` merged into `[ava]`, `[repo]`->`[nathan]`

### Added
- **Voice-name profiles**: section names match voices (`[ava]`, `[lee]`, `[evan]`, `[nathan]`)
- **4 new profiles**: `[allison]`, `[nicky]`, `[samantha]`, `[tom]`
- **Volume control**: `volume=0.0-1.0` config key, applied via `[[volm V]]`
- **Pitch control**: `pitch=0-127` config key, applied via `[[pbas P]]`
- **Comma-separated flags**: `flag=ava,narrate,student` — all resolve to same profile
- **5-field FIFO protocol**: `voice|rate|volume|pitch|message [[slnc 500]]`
- **Backward-compat consumer**: auto-detects 3-field (v2) vs 5-field (v3) lines
- **Vertical slice**: all source files consolidated in `_xsay/`

### Changed
- Pause token docs updated: `{N}` = tenths of a second (code was already correct)
- `--config` spec path now points to `_xsay/xsay_SPEC.yaml`
- `list_profiles` output includes Vol/Pitch columns
- Built-in profile count: 5 -> 8 (+ default)

### Removed
- `tone=` config key (was dead code — parsed but never affected output)
- `~/.config/xsay/` directory (archived to `_xsay/_archive/old_xsay/`)
- `_x00-extensions/x01-xsay/` directory (archived)
- `_k00_kanban/k09_xsay_v2_deploy/` directory (archived)
- Dead blueprint path in `show_config_info()`

## v2.0 — 2026-02-28

- Async FIFO consumer with double-fork spawn
- INI-style config with [section] profiles and flag= shortcuts
- Git repo context announcements with staleness detection
- YAML logging with per-day rotation
- Master config at `~/.config/xsay/xsay.conf`
- 5 built-in profiles: narrator, announcer, instructor, student, repo

## v1.0 — 2026-02-13

- Initial xsay CLI with basic TTS via macOS `say`
- Single voice, no profiles
