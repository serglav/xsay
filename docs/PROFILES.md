# Voice Profiles

xsay ships with 8 built-in voice profiles. Switch profiles with `name:` prefix or `-v name`.

```bash
xsay ava: "Hello from Ava"
xsay -v lee "Fast and crisp"
```

## Built-in Profiles

| Profile | Voice | Rate (wpm) | Volume | Pitch | Flags | Use Case |
|---------|-------|-----------|--------|-------|-------|----------|
| default | Evan (Enhanced) | 180 | 1.0 | 45 | — | Default, balanced |
| ava | Ava (Premium) | 175 | 1.0 | 45 | ava, narrate, student | Female, natural |
| lee | Lee (Premium) | 200 | 1.0 | 45 | lee, announce | Fast, crisp |
| evan | Nathan (Enhanced) | 190 | 0.9 | 45 | evan, instructor | Instructor |
| nathan | Evan (Enhanced) | 175 | 1.0 | 45 | nathan, repo | Repo context announcer |
| allison | Allison (Enhanced) | 180 | 1.0 | 45 | allison | Neutral |
| nicky | Nicky (Enhanced) | 190 | 1.0 | 45 | nicky | Energetic |
| samantha | Samantha (Enhanced) | 185 | 1.0 | 45 | samantha | Familiar |
| tom | Tom (Enhanced) | 185 | 1.0 | 45 | tom | Deep, calm |

## Flags

Profiles can have multiple comma-separated flags. Any flag resolves to its profile:

```bash
xsay narrate: "This uses the ava profile"
xsay announce: "This uses the lee profile"
xsay instructor: "This uses the evan profile"
```

## Custom Profiles

Add custom profiles to your project `.xsay` or global `~/.config/xsay/xsay.conf`:

```ini
[custom]
voice=Zoe (Premium)
rate=170
volume=1.0
pitch=50
flag=custom,myvoice
```

Then use:
```bash
xsay custom: "Hello from custom profile"
xsay myvoice: "Same profile via flag"
```

## Available macOS Voices

To see all voices installed on your Mac:

```bash
say -v '?'
```

Enhanced and Premium voices sound significantly better than standard voices. Download them from:

**System Settings > Accessibility > Spoken Content > System Voice > Manage Voices**
