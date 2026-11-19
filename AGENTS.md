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
- Every behaviour fix comes with a test that fails without it. When the old
  behaviour cannot be reproduced reliably (e.g. undefined behaviour that
  happens to work), the commit message says so and the test pins the
  intended behaviour.
- New source or test files must be added to `MusicPlayer.xcodeproj`. Without
  Xcode, use `scripts/xcodeproj-add.rb <target> <file>...` (needs
  `gem install xcodeproj`); it mirrors folders as groups and is idempotent.
- After editing the `Podfile`, commit the resulting `Podfile.lock` and project
  changes; CI fails otherwise. The Podfile checksum in `Podfile.lock` is the
  SHA-1 of the `Podfile` contents.

## Design decisions

### 2026-11-19: CI on GitHub Actions, driven by repo scripts

The old `.travis.yml` was template boilerplate and never ran. CI is now a
GitHub Actions workflow on a `macos-26` runner. It installs the CocoaPods
version recorded in `Podfile.lock`, runs `pod install`, checks that this did
not modify tracked files, then runs `scripts/test.sh`. All the real logic lives
in `scripts/` so a local run behaves exactly like CI (shared setup steps are in
`.github/actions/setup`). The unit-test job is never cancelled, so every commit
of a stacked PR gets a result. The UI-test job is slow (each test reinstalls
the app), so it uses a per-branch concurrency group with cancel-in-progress:
only the newest push runs it. `scripts/test.sh` enables per-test time limits so
a hung test fails with a report instead of running into the job timeout.

### 2026-11-19: Tests swap the persistence singletons' state, not the singletons

`PlaylistPersistencyManager.sharedInstance` and
`SongPersistencyManager.sharedInstance` are used directly all over the app
(view controllers, `SongEntity.getSongUrl()`, `AudioDownloadManager`).
Injecting new instances everywhere would be a large refactor, so tests use
`MusicPlayerTests/Fixtures/TestPersistence.swift` instead: it points the
shared instances' `docsUrl` at a fresh temporary folder and their
`managedObjectContext` at an in-memory store, and restores both afterwards.
Subclass `PersistenceTestCase` to get this per test.

The in-memory container reuses the app's `NSManagedObjectModel` instance.
Loading the model a second time registers two entity descriptions for the
same classes and makes `SongEntity(context:)` ambiguous.

Unit tests are hosted in the app (`TEST_HOST`), so the app launches normally
first; tests must not depend on whatever the real Documents folder contains.

### 2026-11-19: Server credentials come from a gitignored xcconfig

The OpenPlayer-Server username and password used to be hard-coded in
`ServerRequests.swift` (and are therefore in the public git history; the
owner has to change them on the server). They now flow:

`Config/Secrets.xcconfig` (gitignored, optional) -> build settings
`OPENPLAYER_SERVER_USERNAME` / `OPENPLAYER_SERVER_PASSWORD` (defaulted to empty
in the tracked `Config/Project.xcconfig`) -> Info.plist keys
`OPServerUsername` / `OPServerPassword` -> `ServerCredentials` at runtime.

`Config/Project.xcconfig` is the *project-level* base configuration, because
the targets' base configuration slot belongs to CocoaPods. Copy
`Config/Secrets.example.xcconfig` to get started. The values still end up in
the app bundle, so this keeps them out of source control, not out of the
binary; that was the owner's explicit choice over a Settings/Keychain UI.

### 2026-11-19: The Wi-Fi upload server stays unauthenticated (documented risk)

`ServerController.deployServer()` starts `GCDWebUploader` on port 80 with no
authentication, so anyone on the same network can upload, rename or delete
files under Documents while it runs. GCDWebServer supports Basic/Digest auth
(`GCDWebServerOption_AuthenticationMethod`), but the owner chose to keep the
current behaviour and document the risk (README "Security notes") rather than
add a password. Revisit if the server ever runs in the background.

### 2026-11-19: App Transport Security stays off

`Info.plist` keeps `NSAllowsArbitraryLoads = true` because OpenPlayer-Server is
self-hosted and often reachable only over plain HTTP on a LAN.
`NSAllowsLocalNetworking` alone would break servers reached by a public
hostname without TLS. Consequence: Basic auth credentials can travel
unencrypted. `ServerAddress.normalize` therefore never rewrites an explicit
`https://`, and only defaults to `http://` when no scheme is typed.

### 2026-11-19: Background URLSession completion handlers live in one registry

iOS hands the app a completion handler per background `URLSession` identifier
(`application(_:handleEventsForBackgroundURLSession:completionHandler:)`) and
expects it to be called on the main queue after that session's
`urlSessionDidFinishEvents(forBackgroundURLSession:)`. `AppDelegate` used to
keep a single handler and never call it. Handlers now go into
`BackgroundSessionCompletion.shared` keyed by identifier, and
`AudioDownloadDelegate` completes its own session's handler. Streaming creates
one background session per song (identifier = song URL), hence the dictionary.

### 2026-11-19: "Download to playlist" is hidden until it is finished

The download button on remote search results opened a playlist picker whose
handler (`DownloadTablePlaylistPickerImpl.moveSong`) is commented out, and
nothing ever calls `AudioDownloadManager.append(toDownload:toPlaylist:)`. The
owner chose to hide the button (`DownloadCell.awakeFromNib`) rather than
finish the feature now. The rest of the code is left in place for later. To
finish it:
- `AudioDownloadManager.offer` checks `active != nil` where it means `== nil`,
  so a queued download never starts, and it also leaves the started item in
  `downloadQueue`.
- The picker handler must call `append`, and on `.downloadFinished` the file
  must be written into the playlist folder and a `SongEntity` created for it
  (search results are unsaved objects, see `makeUnsavedSong()`).
`AudioDownloadManager` is still live: when a stream finishes outside a
download, it caches the file in the temporary directory
(`SongEntity.isCached()`).
