# `[[pbas]]` Embedded Command Testing Results

Tested: 2026-03-03. macOS 15.x Sequoia, Apple Silicon.

## Claim Under Test

Multiple web sources (Apple archived docs, community blogs) claim that `[[pbas]]` and other embedded speech commands **only work on legacy MacinTalk voices** (Fred, Ralph, Victoria, etc.) and are **silently ignored by modern Enhanced/Premium neural voices**.

## Test Method

Interactive human-verified audio comparison. Same sentence played twice per voice:
- A: Normal (no `[[pbas]]`)
- B: `[[pbas 80]]` (high pitch)

Rate: 180 wpm. User listened and confirmed whether pitch changed.

## Results

| # | Voice | Tier | Pitch change heard? | Verdict |
|---|-------|------|:---:|---------|
| T-01 | Fred | Legacy MacinTalk | YES — clear | Control: works as expected |
| T-02 | Evan (Enhanced) | Enhanced | **YES — clear** | **CLAIM DEBUNKED** |
| T-03 | Zoe (Premium) | Premium | **YES — absolutely clear** | **CLAIM DEBUNKED** |

## Conclusion

**`[[pbas N]]` works on ALL voice tiers** — legacy, Enhanced, AND Premium.

The web documentation claiming otherwise is either outdated (may have been true on older macOS versions) or incorrect. Apple appears to have extended `[[pbas]]` support to modern neural voices at some point.

### Also confirmed working on all tiers

| Command | Legacy | Enhanced | Premium |
|---------|:---:|:---:|:---:|
| `[[slnc N]]` | YES | YES | YES |
| `[[rate N]]` | YES | YES (file size diff) | YES (file size diff) |
| `[[pbas N]]` | YES | **YES** (human verified) | **YES** (human verified) |

### Not yet tested on Enhanced/Premium

- `[[volm N]]` — accepted (EXIT 0) but not human-verified
- `[[pmod N]]` — accepted but not human-verified
- `[[emph +/-]]` — accepted but not human-verified
- `[[inpt PHON]]` — likely legacy-only (different synthesis pipeline)
- `[[inpt TUNE]]` — likely legacy-only

## Impact on xsay

xsay's consumer prepends `[[volm V]][[pbas P]]` to messages before calling `say`. This testing confirms the `[[pbas P]]` prefix **actually affects the output** on Enhanced and Premium voices — it's not being silently ignored as the research initially suggested.
