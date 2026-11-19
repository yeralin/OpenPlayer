# AGENTS.md

Notes for anyone (human or AI agent) working on this repository. Keep it
current: when you make a significant design decision, add it to the
**Design decisions** log below, with the date and the reason.

## Project

OpenPlayer is a UIKit music player for iOS (Swift 5, CocoaPods, Core Data).
Playlists are folders under the app's Documents directory and songs are the
audio files inside them; Core Data mirrors that structure. Songs can also be
streamed from a companion server, https://github.com/yeralin/OpenPlayer-Server.

| Area | Location |
|---|---|
| App entry, Core Data stack | `MusicPlayer/AppDelegate.swift` |
| Playback (`AVPlayer` wrapper, singleton) | `MusicPlayer/Audio/AudioPlayer.swift` |
| Streaming (custom `AVAssetResourceLoader`) | `MusicPlayer/Audio/AudioDownload/` |
| Lock screen / remote commands | `MusicPlayer/Audio/Utils/MPControl.swift` |
| Persistence (folder <-> Core Data sync) | `MusicPlayer/Model/PersistenceController/` |
| Server API | `MusicPlayer/Model/Network/ServerRequests.swift` |
| Screens | `MusicPlayer/ViewController/` (one folder per screen, split into extensions) |
| Unit tests (hosted in the app) | `MusicPlayerTests/` |
| UI tests | `MusicPlayerUITests/` |

## Building and testing

```bash
pod install
scripts/test.sh          # unit + UI tests on the newest iPhone simulator
scripts/test.sh unit     # unit tests only
```

Open `MusicPlayer.xcworkspace` (not the `.xcodeproj`) in Xcode.

CI (`.github/workflows/ci.yml`) runs on every push, on a GitHub-hosted macOS
runner, and does exactly the steps above plus `scripts/check-pods-in-sync.sh`.

## Conventions

- Small, single-purpose commits. A fix that needs several commits shares a
  common title prefix, e.g. `Move server credentials out of source (1/3): ...`.
- Every behaviour fix comes with a test that fails without it.
- New source or test files must be added to `MusicPlayer.xcodeproj` (the
  `xcodeproj` Ruby gem works for this even without Xcode).
- After editing the `Podfile`, commit the resulting `Podfile.lock` and project
  changes; CI fails otherwise. The Podfile checksum in `Podfile.lock` is the
  SHA-1 of the `Podfile` contents.

## Design decisions

### 2026-11-19: CI on GitHub Actions, driven by repo scripts

The old `.travis.yml` was template boilerplate and never ran. CI is now a
GitHub Actions workflow on a `macos-26` runner. It installs the CocoaPods
version recorded in `Podfile.lock`, runs `pod install`, checks that this did
not modify tracked files, then runs `scripts/test.sh`. All the real logic lives
in `scripts/` so a local run behaves exactly like CI. Runs are not cancelled
when a newer commit is pushed, so every commit of a stacked PR gets a result.
