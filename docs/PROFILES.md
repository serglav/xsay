# Voice Profiles

xsay ships with 4 built-in voice profiles. Switch profiles with `name:` prefix or `-v name`.

```bash
xsay zoe: "Hello from Zoe"
xsay -v nathan "Clear and crisp"
```

## Built-in Profiles

| Profile | Voice | Rate (wpm) | Volume | Pitch | Flags | Use Case |
|---------|-------|-----------|--------|-------|-------|----------|
| default | Evan (Enhanced) | 180 | 1.0 | 45 | — | Default, balanced |
| evan | Evan (Enhanced) | 175 | 1.0 | 45 | evan | General use |
| nathan | Nathan (Enhanced) | 190 | 0.9 | 45 | nathan, repo | Repo context announcer |
| zoe | Zoe (Premium) | 180 | 1.0 | 45 | zoe, narrate | Narration |
| tom | Tom (Enhanced) | 185 | 1.0 | 45 | tom | Deep, calm |

## Flags

Profiles can have comma-separated flags. Any flag resolves to its profile:

```bash
xsay narrate: "This uses the zoe profile"
xsay repo: "This uses the nathan profile"
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
