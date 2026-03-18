# macOS Voice Installation Research — Definitive Findings

Researched: 2026-03-03. macOS 15.x Sequoia, Apple Silicon.

## Primary Question

**Can Enhanced/Premium macOS TTS voices be installed via CLI?**

**Answer: No. Not through any method.**

## Every Method Tested

| Method | Can install? | Details |
|--------|:---:|---------|
| `say` CLI | No | Playback only, no install capability |
| `softwareupdate` CLI | No | Wrong subsystem — handles OS/app updates, not voices |
| `defaults write com.apple.speech.*` | No | No download trigger keys exist |
| `NSSpeechSynthesizer` API (deprecated) | No | Enumerate only, no download method |
| `AVSpeechSynthesizer` API (current) | No | `AVSpeechSynthesisVoice(identifier:)` returns nil for non-installed |
| MDM configuration profiles | No | No voice payload type exists in Apple MDM spec |
| `assetsd` / MobileAsset (private) | Controls it internally | No public interface |
| Homebrew / community tools | No | `mklement0/voices` manages existing, can't download |
| AppleScript UI automation | Fragile | Breaks every macOS version — not viable |

## Voice Fallback Behavior (tested interactively)

When `say -v "NonInstalledVoice" "text"` is called:

1. **No error** — EXIT 0, no stderr output
2. **No auto-install** — voice is NOT downloaded
3. **Gender-matched fallback** — female voices fall back to Samantha, male voices fall back to system default male
4. **All non-installed female voices sound identical** — confirmed with Noelle, Susan, Karen
5. **Clear quality gap** — installed Enhanced/Premium vs fallback compact is audibly distinguishable at 200 wpm

## Voice Storage Architecture

| Tier | Location | Size |
|------|----------|------|
| Compact (ships with OS) | `/System/Library/SpeechBase/Voices/*.SpeechVoice` | 376KB-8.5MB |
| Compact neural models | `/System/Library/AssetsV2/com_apple_MobileAsset_TTSAXResourceModelAssets/` | `.caf` files per voice |
| Enhanced (downloaded) | MobileAsset cache (managed by `assetsd`) | 71-931 MB |
| Premium (downloaded) | MobileAsset cache (managed by `assetsd`) | 350-850 MB |

### Asset manifests on disk

| Manifest | Contains |
|----------|---------|
| `com_apple_MobileAsset_VoiceServices_CombinedVocalizerVoices.xml` | 41 CombinedVocalizer voices (Allison, Ava, Tom, etc.) with CDN download URLs |
| `com_apple_MobileAsset_MacinTalkVoiceAssets.xml` | Alex (844 MB), Vicki, legacy effects voices |
| `com_apple_MobileAsset_TTSAXResourceModelAssets.xml` | Neural model assets for ALL voices (Enhanced/Premium) — but `_DownloadSize=0` and no URLs (resolved dynamically) |

### CDN base URL (from CombinedVocalizer manifest)

```
https://updates.cdn-apple.com/2021/mobileassets/071-26769/D6BADDC4-9AA3-4948-9523-06C8708DD17D/
```

Download URLs exist in the manifest but Enhanced voices (TTSAXResourceModel) have `_DownloadSize: 0` — actual URLs are resolved dynamically at download time by `assetsd`. Cannot be curled directly.

## Siri Voices

| Approach | Works? |
|----------|:---:|
| `say -v "Siri"` | No — falls back to default |
| `AVSpeechSynthesisVoice(identifier: "com.apple.siri.natural.Aaron")` | No — returns nil |
| Siri TTS frameworks (`SiriTTS.framework`, `SiriSpeechSynthesis.framework`) | Private — not available to apps |
| Voices tagged "Hi, I'm Siri!" (Ona, Tara) | Yes — these are regular voices Siri uses, accessible via `say` |

Siri's neural voice engine is a completely separate, private pipeline. Not accessible to any third-party program.

## AVSpeechSynthesizer vs NSSpeechSynthesizer vs `say`

| Feature | `say` CLI | NSSpeechSynthesizer | AVSpeechSynthesizer |
|---------|:---:|:---:|:---:|
| `[[...]]` commands | Yes | Yes | No |
| Phoneme mode | Yes | Yes | No |
| Tune mode | Yes | Yes | No |
| Quality tier info | No | No | Yes (.quality property) |
| Gender info | No | No | Yes (.gender property) |
| Pitch control (modern voices) | Yes (`[[pbas]]` works!) | Yes | Yes (.pitchMultiplier) |
| Write to audio buffer | `-o file` | startSpeaking(to: URL) | write(:toBufferCallback:) |
| IPA pronunciation | No | No | Yes (SSML) |
| Install voices | No | No | No |
| Personal Voice | No | No | Yes (macOS 14+, auth required) |
| Deprecated? | No (CLI) | Yes (macOS 14+) | No (current API) |

## The Only Way to Install Voices

**System Settings > Accessibility > Spoken Content > System Voice > Manage Voices**

On macOS 15 Sequoia, the path may have moved to VoiceOver settings.

## Recommendations for xsay

1. **README must document voice download** — clear instructions with exact GUI path
2. **Add voice validation** — check `say -v '?'` to warn if configured voice isn't installed
3. **Compact fallback is usable** — voice C in testing "sounded okay" per user
4. **`[[pbas]]` works on all tiers** — xsay's pitch prefix is effective (debunked claim it doesn't work on Enhanced/Premium)
5. **`--duck-audio` flag** — consider adding to xsay for automatic audio ducking
