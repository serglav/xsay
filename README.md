# xsay

**v3.5.1** — Project-aware macOS TTS CLI with voice profiles, inline sound effects, and async FIFO queue.

```bash
xsay "Hello world"
xsay "{ping} Task complete {hero}"
xsay zoe: "Switching voices is easy"
xsay -k                               # kill all speech instantly
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

### Default Voice

xsay uses your **macOS system voice** by default (System Settings > Accessibility > Spoken Content). No configuration needed — whatever voice you have set system-wide is what xsay speaks with.

For best quality, download an Enhanced or Premium voice (free, ~100-900MB each):

1. Open **System Settings > Accessibility > Spoken Content**
2. Click **System Voice** dropdown > **Manage Voices...**
3. Download voices like Evan (Enhanced), Zoe (Premium), or any you prefer

Named profiles (`evan:`, `zoe:`, etc.) override the system voice with their specific voice.

---

## Quick Start

```bash
xsay "Hello world"                    # speak with system voice
xsay "{ping} Starting build {2}"      # sound effect + 200ms pause
xsay zoe: "Different voice"           # use a named profile
xsay evan++: "Faster speech"          # speed boost (+20 wpm)
xsay --sounds                         # list available sound effects
xsay -l                               # list voice profiles
xsay -k                               # kill speech immediately
```

---

## AI Agent Integration

xsay was built for voice-narrated AI coding sessions. Three commands give AI agents everything they need:

| Command | Purpose |
|---------|---------|
| `xsay --context` | Quick reference for AI agents — usage, voices, pause rules, sound effects (~40 lines) |
| `xsay --afk` | Self-contained autonomous session protocol — voice rules, update tiers, session boundaries |
| `xsay -k` | Kill switch — instantly stops all speech |

### `--context` — AI Quick Reference

Outputs a focused spec designed for LLM context windows. Dynamic — lists voices from your project config and sounds from the installed soundfx directory. Teaches the agent how to call xsay correctly with one call pattern, pause rules, and sound semantics.

```bash
xsay --context    # paste into AI context or load via tool
```

### `--afk` — Autonomous Session Protocol

Self-contained protocol for when you step away and let an AI agent work autonomously. Includes syntax cheat sheet (so the agent doesn't also need `--context`), voice rules, and three update tiers:

- **Heartbeat** — every ~3 actions, voice-only status
- **Phase Gate** — at phase boundaries, voice + 1-line chat
- **Inflection Point** — blocked/done/tests, voice + full summary

```bash
xsay --afk       # agent reads this once, knows how to keep you posted
```

### `-k` / `--kill` — Kill Switch

Instantly kills the xsay consumer process and all child `say`/`afplay` processes. Cleans up the FIFO.

```bash
xsay -k           # silence everything immediately
xsay --kill       # same thing, long form
```

### Claude Code Output Style

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

## Flags

| Flag | Action |
|------|--------|
| `-v NAME` | Select voice profile by section name |
| `-l`, `--list-voices` | List all profiles with voice/rate/vol/pitch/flags |
| `--sounds [name]` | List sound effects or preview one by name |
| `--update` | Sync built-in profiles from master config, preserve custom |
| `--config` | Show paths, architecture, config status |
| `--context` | AI-focused quick reference — dynamic voices + sounds (~40 lines) |
| `--afk` | Autonomous session protocol for AI agents (self-contained) |
| `-k`, `--kill` | Kill consumer + child processes (`say`/`afplay`), clean up FIFO |
| `--version` | Print version |
| `-h`, `--help` | Human-readable help |
| `flag:` | Shorthand — matches `flag=` key in profiles (e.g., `narrate:` resolves to zoe) |
| `name+:` | Speed modifier — +10 wpm per `+` (max `+++`, e.g., `evan++:`) |

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

Use `{N}` for pauses in tenths of a second. `{2}` (200ms) is the recommended max — macOS `say` already pauses naturally on punctuation.

```bash
xsay "First part {2} second part"     # 200ms pause
xsay "Step one {1} step two"          # 100ms micro-pause
```

> **Rule**: Never place `{N}` after punctuation (`.` `!` `?` `,`) — `say` already pauses there.

### Emphasis

Double-quoted words get a micro-pause (200ms) for emphasis:

```bash
xsay 'This is "really" important'
```

---

## Voice Profiles

4 built-in profiles. The default voice uses your macOS system voice. Named profiles override with specific voices.

| Profile | Voice | Rate | Flags |
|---------|-------|------|-------|
| default | (system voice) | 180 | — |
| evan | Evan (Enhanced) | 175 | evan |
| nathan | Nathan (Enhanced) | 190 | nathan, repo |
| zoe | Zoe (Premium) | 180 | zoe, narrate |
| tom | Tom (Enhanced) | 185 | tom |

```bash
xsay zoe: "Hello from Zoe"            # flag shorthand
xsay -v nathan "Clear and crisp"      # explicit profile
xsay narrate: "Uses Zoe"              # flag resolves to profile
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
template=REPO {2} {repo}
# Placeholders: {repo}, {branch}, {commit}, {time}
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
3. Messages return instantly (~2ms); speech plays in order
4. The consumer self-terminates after 30 seconds of silence

This means xsay never blocks your terminal or scripts. Use `xsay -k` to kill the consumer and all speech immediately.

---

## Requirements

- macOS 12+ (uses the built-in `say` command)
- bash 3.2+ (ships with macOS)
- An Enhanced or Premium voice (optional but recommended)

---

## License

MIT - see [LICENSE](LICENSE)
