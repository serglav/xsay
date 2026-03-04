# xsay — Project Instructions

macOS TTS CLI with voice profiles, inline sound effects, and async FIFO queue.
Current version: **v3.2.2** (~1,849 lines bash). Public repo: `serglav/xsay`.

## Repository Structure

This is a **monorepo with nested git repos**:

```
/Users/Dev/xsay/                  ← PUBLIC repo (serglav/xsay)
├── bin/xsay                      ← main script (1,849 lines)
├── share/xsay/xsay.conf          ← shipped default config (4 profiles)
├── share/xsay/soundfx/*.aiff     ← 14 system sound effects
├── Makefile                       ← self-contained install/uninstall
├── install.sh                     ← curl-friendly installer
├── docs/                          ← CHANGELOG, PROFILES, SPEC, claude-output-style
├── _on_homebrew/                  ← NESTED PUBLIC repo (serglav/homebrew-xsay)
│   └── Formula/xsay.rb           ← Homebrew formula (must match version+sha256)
├── _xsay/                         ← local dev workspace (research, tests)
│   ├── research/                  ← voice testing docs, say command reference
│   └── tests/                     ← test scripts
└── _xwDOMAIN/                     ← work tracking (ADRs, tickets, sessions)
```

### What's public vs private

| Directory | Git repo | Public | Gitignored from parent |
|-----------|----------|--------|----------------------|
| `/` (root) | `serglav/xsay` | Yes | — |
| `_on_homebrew/` | `serglav/homebrew-xsay` | Yes | Yes (gitignored from root) |
| `_xsay/` | none (local) | No | Yes |
| `_xwDOMAIN/` | none (local) | No | Yes |
| `_archive/` | none (local) | No | Yes |

**Critical**: `_xsay/`, `_xwDOMAIN/`, and `_archive/` are gitignored and NEVER pushed. They contain local-only dev artifacts.

## Public Repo Discipline

Both public repos require careful handling:

### Before any edit to public files
1. **Read before write** — always review current state
2. **Validate changes** — test xsay after edits (`xsay "test"`, `xsay evan: test`, `xsay --help`)
3. **No hardcoded paths** — all paths resolve dynamically via `_resolve_prefix()`
4. **No personal data** — no usernames, local paths, or machine-specific info in public files

### Version alignment (MANDATORY on release)
All three locations must agree on the version:

| Location | What to update |
|----------|---------------|
| `bin/xsay` line 2 | Header comment `# xsay vX.Y` |
| `bin/xsay` `--version` output | Version string in show_help/version handler |
| `docs/CHANGELOG.md` | New entry at top |
| `_on_homebrew/Formula/xsay.rb` | `url` tag + `sha256` + `test` block version |

### Release process
```
1. Commit & push serglav/xsay
2. Tag: git tag -a vX.Y.Z -m "description"
3. Push tag: git push origin vX.Y.Z
4. Create GitHub release: gh release create vX.Y.Z --generate-notes
5. Compute sha256: curl -sL <tarball_url> | shasum -a 256
6. Update _on_homebrew/Formula/xsay.rb (url, sha256, test version)
7. Commit & push serglav/homebrew-xsay
8. Verify: brew update && brew upgrade xsay (or reinstall)
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

### Voice profiles (v3.2)
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
Prefix syntax adjusts speech rate: `xsay 2x: message` (double speed), `xsay .5x: message` (half speed).
Combinable with profiles: `xsay evan: 1.5x: message`.

## xwDOMAIN (Work Tracking)

Dev-only workspace for decisions and session artifacts. **Gitignored from public repo.**

- `_xwDOMAIN/_xwDOMAIN.yaml` — START HERE for all work tracking
- `_xwDOMAIN/_xwADR/` — Architecture Decision Records
- `_xwDOMAIN/xwNN_*` — Work entry folders with tickets

Naming: `xwNN_{name}_{STATUS}/` where STATUS = `_OPEN|_WIP|_IMPL|_BLCK|_NOGO`

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
xsay 2x: "speed test"               # speed modifier
xsay --help                          # help output, version correct
xsay --version                       # version matches
xsay --config                        # config paths resolve
xsay --sounds                        # sound effects list
```

## Constraints

- **macOS only** — depends on `say`, `afplay`, macOS system sounds
- **bash 3.2+** — must work with macOS default bash (no bash 4+ features)
- **No `rm`** — use `trash` for all deletions
- **No hardcoded paths** — everything resolves dynamically
- **Spec file is stale** — `docs/xsay_SPEC.yaml` still references v3.1 paths from `claude-work/_xsay/`. Needs update if touched.

## Key Files Quick Reference

| File | Lines | Purpose |
|------|-------|---------|
| `bin/xsay` | 1,849 | Main CLI script |
| `share/xsay/xsay.conf` | 49 | Shipped default config |
| `Makefile` | ~25 | Install/uninstall targets |
| `install.sh` | ~60 | Curl-friendly installer |
| `_on_homebrew/Formula/xsay.rb` | 45 | Homebrew formula |
| `docs/CHANGELOG.md` | — | Version history |
| `docs/PROFILES.md` | — | Voice profile documentation |
| `docs/xsay_SPEC.yaml` | 190 | Technical spec (STALE — v3.1 paths) |
