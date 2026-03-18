# xsay — Project Instructions

macOS TTS CLI with voice profiles, inline sound effects, and async FIFO queue.
Current version: **v3.5.1** (~1,849 lines bash). Public repo: `serglav/xsay`.

## Repository Structure

```
xsay/
├── bin/xsay                      ← main script (1,849 lines)
├── share/xsay/xsay.conf          ← shipped default config (4 profiles)
├── share/xsay/soundfx/*.aiff     ← 14 system sound effects
├── Makefile                       ← self-contained install/uninstall
├── install.sh                     ← curl-friendly installer
└── docs/                          ← CHANGELOG, PROFILES, claude-output-style
```

## Architecture

### Path resolution (lines 28-57 of bin/xsay)
- `_resolve_script_dir()` — portable symlink resolution (macOS lacks `readlink -f`)
- `_resolve_prefix()` — finds install prefix: `$XSAY_PREFIX` env > script-relative `../share/xsay` > `$HOME/.local`
- Works through Homebrew Cellar symlink chain: `/opt/homebrew/bin/xsay` → `../Cellar/xsay/X.Y.Z/bin/xsay`

### Config hierarchy
1. **Shipped default**: `$PREFIX/share/xsay/xsay.conf` (read-only, installed with package)
2. **User master**: `${XDG_CONFIG_HOME:-$HOME/.config}/xsay/xsay.conf` (copied from default on first run)
3. **Project override**: `.xsay` in project root (auto-created from master, project-specific overrides)

### Voice profiles (v3.5.1)
Four profiles with voice-name triggers:

| Profile | Voice | Flags | Purpose |
|---------|-------|-------|---------|
| `[evan]` | Evan (Enhanced) | `evan` | Default voice |
| `[nathan]` | Nathan (Enhanced) | `nathan,repo` | Repo announcements |
| `[zoe]` | Zoe (Premium) | `zoe,narrate` | Narration |
| `[tom]` | Tom (Enhanced) | `tom` | General |

Usage: `xsay evan: hello` or `xsay narrate: long text` (flag resolves to profile)

### FIFO protocol
Async TTS via named pipe at `/tmp/xsay-${USER}.fifo`:
- Format: `voice|rate|volume|pitch|message [[slnc 500]]`
- Consumer auto-starts, self-terminates after 30s idle
- Sound effects: `{name}` → `[[sfx:name]]` markers, consumer interleaves `say`/`afplay`
- Pauses: `{N}` → tenths of seconds (`{5}` = 500ms)

### Speed modifiers
Append `+` to any profile name before the colon to boost speech rate (+10 wpm per `+`, max `+++`):
- `xsay evan+: "faster"` → +10 wpm
- `xsay evan++: "urgent"` → +20 wpm
- `xsay evan+++: "full speed"` → +30 wpm (max)
Works with any profile or flag: `zoe+:`, `narrate++:`, `tom+++:`

## Install Methods (3)

```bash
# Homebrew (recommended)
brew install serglav/xsay/xsay

# Git clone + make
git clone https://github.com/serglav/xsay.git && cd xsay && make install

# curl one-liner
curl -fsSL https://raw.githubusercontent.com/serglav/xsay/main/install.sh | bash
```

## Testing Checklist

Run after any change to `bin/xsay` or `share/xsay/xsay.conf`:

```bash
xsay "basic test"                    # default voice works
xsay evan: "profile test"            # profile resolution
xsay nathan: "repo test"             # repo profile with template
xsay narrate: "flag test"            # flag→profile resolution (zoe)
xsay "{ping} sound test {hero}"      # inline sound effects
xsay "pause {5} test"                # pause tokens
xsay evan+: "speed test"             # speed modifier (+10 wpm)
xsay --help                          # help output, version correct
xsay --version                       # version matches
xsay --config                        # config paths resolve
xsay --sounds                        # sound effects list
```

## Constraints

- **macOS only** — depends on `say`, `afplay`, macOS system sounds
- **bash 3.2+** — must work with macOS default bash (no bash 4+ features)
- **No hardcoded paths** — everything resolves dynamically

## Key Files Quick Reference

| File | Lines | Purpose |
|------|-------|---------|
| `bin/xsay` | 1,849 | Main CLI script |
| `share/xsay/xsay.conf` | 49 | Shipped default config |
| `Makefile` | ~25 | Install/uninstall targets |
| `install.sh` | ~60 | Curl-friendly installer |
| `docs/CHANGELOG.md` | — | Version history |
| `docs/PROFILES.md` | — | Voice profile documentation |
