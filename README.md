# xsay

Project-aware macOS TTS CLI with voice profiles, inline sound effects, and async FIFO queue.

```bash
xsay "Hello world"
xsay "{ping} Task complete {hero}"
xsay ava: "Switching voices is easy"
```

---

## Install

### Homebrew (recommended)

```bash
brew install serglavren/xsay/xsay
```

### Git clone

```bash
git clone https://github.com/serglavren/xsay.git
cd xsay
make install
```

### curl one-liner

```bash
curl -fsSL https://raw.githubusercontent.com/serglavren/xsay/main/install.sh | bash
```

Installs to `~/.local/bin` by default. Set `PREFIX` to change:

```bash
PREFIX=/usr/local make install
```

### Voice Setup

xsay works best with enhanced voices. Download one:

**System Settings > Accessibility > Spoken Content > System Voice > Manage Voices**

Recommended: **Evan (Enhanced)** (default voice). Any Enhanced or Premium voice works.

Without an enhanced voice, xsay falls back to the system default.

---

## Quick Start

```bash
xsay "Hello world"                    # speak with default voice
xsay "{ping} Starting build {5}"      # sound effect + 500ms pause
xsay ava: "Different voice"           # use a named profile
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
xsay "First part {5} second part"     # 500ms pause
xsay "Wait for it {10} there it is"   # 1 second pause
```

### Emphasis

Double-quoted words get a micro-pause (200ms) for emphasis:

```bash
xsay 'This is "really" important'
```

---

## Voice Profiles

8 built-in profiles. Switch with `name:` prefix or `-v name`.

| Profile | Voice | Rate | Use Case |
|---------|-------|------|----------|
| default | Evan (Enhanced) | 180 | Default, balanced |
| ava | Ava (Premium) | 175 | Female, natural |
| lee | Lee (Premium) | 200 | Fast, crisp |
| evan | Nathan (Enhanced) | 190 | Instructor |
| nathan | Evan (Enhanced) | 175 | Repo context announcer |
| allison | Allison (Enhanced) | 180 | Neutral |
| nicky | Nicky (Enhanced) | 190 | Energetic |
| samantha | Samantha (Enhanced) | 185 | Familiar |
| tom | Tom (Enhanced) | 185 | Deep, calm |

```bash
xsay ava: "Hello from Ava"
xsay -v lee "Fast delivery"
```

Custom profiles can be added to your project `.xsay` config file.

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
voice=Evan (Enhanced)
rate=175
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
