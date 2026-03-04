# xsay

Project-aware macOS TTS CLI with voice profiles, inline sound effects, and async FIFO queue.

```bash
xsay "Hello world"
xsay "{ping} Task complete {hero}"
xsay zoe: "Switching voices is easy"
```

---

## Install

### Homebrew (recommended)

```bash
brew install serglav/xsay/xsay
```

### Git clone

```bash
git clone https://github.com/serglav/xsay.git
cd xsay
make install
```

### curl one-liner

```bash
curl -fsSL https://raw.githubusercontent.com/serglav/xsay/main/install.sh | bash
```

Installs to `~/.local/bin` by default. Set `PREFIX` to change:

```bash
PREFIX=/usr/local make install
```

### Recommended Voices

xsay works out of the box with macOS default voices. For significantly better quality, download Enhanced or Premium voices (free, ~100-900MB each).

**Our top 4 after extensive testing (all ship as built-in profiles):**

| Rank | Voice | Tier | Why |
|------|-------|------|-----|
| 1 | **Evan (Enhanced)** | Enhanced | Natural, balanced — xsay's default voice |
| 2 | **Nathan (Enhanced)** | Enhanced | Clear, crisp articulation |
| 3 | **Zoe (Premium)** | Premium | Rich, natural female voice |
| 4 | **Tom (Enhanced)** | Enhanced | Deep, calm delivery |

**How to download:**

1. Open **System Settings**
2. Go to **Accessibility > Spoken Content**
3. Click **System Voice** dropdown > **Manage Voices...**
4. Search for the voice name (e.g. "Evan") and click the download button
5. Wait for download to complete (Enhanced: ~100-200MB, Premium: ~350-850MB)

> Not required — xsay falls back gracefully to the system default voice if an Enhanced/Premium voice isn't installed. No errors, just lower audio quality.

---

## Quick Start

```bash
xsay "Hello world"                    # speak with default voice
xsay "{ping} Starting build {2}"      # sound effect + 200ms pause
xsay zoe: "Different voice"           # use a named profile
xsay --sounds                         # list available sound effects
xsay -l                               # list voice profiles
```

---

## Sound Effects

Inline sound effects via `{name}` tokens. Plays `.aiff` files between speech segments.

| Token | Sound | Semantic Use |
|-------|-------|-------------|
| `{ping}` | Ping | Attention, turn start, new phase |
| `{tink}` | Tink | Light transition, acknowledgment |
| `{hero}` | Hero | Completion, success, milestone |
| `{glass}` | Glass | Error detected, issue found |
| `{funk}` | Funk | Blocked, warning, needs attention |
| `{pop}` | Pop | Quick ack, minor transition |
| `{basso}` | Basso | Low alert, serious warning |
| `{blow}` | Blow | Gentle notification |
| `{bottle}` | Bottle | Casual alert |
| `{frog}` | Frog | Playful notification |
| `{morse}` | Morse | Data, communication |
| `{purr}` | Purr | Soft confirmation |
| `{sosumi}` | Sosumi | Classic Mac alert |
| `{submarine}` | Submarine | Deep notification |

### Pauses

Use `{N}` for pauses in tenths of a second:

```bash
xsay "First part {2} second part"     # 200ms pause
xsay "Wait for it {5} there it is"    # 500ms pause
```

### Emphasis

Double-quoted words get a micro-pause (200ms) for emphasis:

```bash
xsay 'This is "really" important'
```

---

## Voice Profiles

4 built-in profiles. Switch with `name:` prefix or `-v name`.

| Profile | Voice | Rate | Use Case |
|---------|-------|------|----------|
| default | Evan (Enhanced) | 180 | Default, balanced |
| evan | Evan (Enhanced) | 175 | General use |
| nathan | Nathan (Enhanced) | 190 | Repo context announcer |
| zoe | Zoe (Premium) | 180 | Narration |
| tom | Tom (Enhanced) | 185 | Deep, calm |

```bash
xsay zoe: "Hello from Zoe"
xsay -v nathan "Clear and crisp"
```

Custom profiles can be added to your project `.xsay` config file.

### Speed Modifiers

Append `+` to any profile name to boost speech rate (+10 wpm per `+`, max `+++`):

```bash
xsay evan+: "a bit faster"           # +10 wpm
xsay evan++: "getting urgent"        # +20 wpm
xsay evan+++: "full speed"           # +30 wpm
```

---

## AI Integration

xsay was built for voice-narrated AI coding sessions. It includes a Claude Code output style that makes Claude narrate its work via xsay.

### Setup

```bash
mkdir -p ~/.claude/output-styles
cp docs/claude-output-style.md ~/.claude/output-styles/xsay-tts.md
```

Then activate in Claude Code:
```
/output-style xsay-tts
```

Claude will narrate state transitions, use sound effects for semantic boundaries, and provide voice feedback throughout coding sessions.

---

## Configuration

### User config (global defaults)

```
~/.config/xsay/xsay.conf
```

Created automatically on first run. Edit to change default voice, rate, volume, pitch, and profiles.

### Project config (per-project overrides)

```
<project-root>/.xsay
```

Created interactively on first run in a project. Overrides global defaults for that project.

### Repo context announcements

When you switch git repos, xsay announces the new repository using the `[nathan]` profile. Configure in `.xsay`:

```ini
[nathan]
voice=Nathan (Enhanced)
rate=190
stale_minutes=5       # re-announce after N min idle (0=always, -1=never)
enabled=true          # false to disable
template=REPO {2} {repo} {5}
# Placeholders: {repo}, {branch}, {commit}, {time}
# Pause tokens: {2}=200ms, {5}=500ms, {10}=1s
```

### Environment variables

| Variable | Purpose |
|----------|---------|
| `XSAY_PREFIX` | Override install prefix for path resolution |
| `XDG_CONFIG_HOME` | Override config directory (default: `~/.config`) |

---

## How It Works

xsay uses an async FIFO queue architecture:

1. `xsay "message"` writes to a named pipe (`/tmp/xsay-$USER.fifo`)
2. A background consumer process reads from the pipe and calls macOS `say`
3. Messages return instantly; speech plays in order
4. The consumer self-terminates after 30 seconds of silence

This means xsay never blocks your terminal or scripts.

---

## Requirements

- macOS 12+ (uses the built-in `say` command)
- bash 3.2+ (ships with macOS)
- An Enhanced or Premium voice (optional but recommended)

---

## License

MIT - see [LICENSE](LICENSE)
