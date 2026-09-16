[![CI](https://github.com/SKrotkih/LiveEvents/actions/workflows/main.yml/badge.svg)](https://github.com/SKrotkih/LiveEvents/actions/workflows/main.yml)

# LiveEvents

A YouTube live-video manager for iOS and the sample app for the
[YTLiveStreaming](https://github.com/SKrotkih/YTLiveStreaming) package: list, schedule, edit and delete
your channel's live broadcasts, go live from the phone camera and watch the live chat while streaming.

Built with [SwiftUI](https://developer.apple.com/documentation/SwiftUI),
[Combine](https://developer.apple.com/documentation/Combine),
[Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html) and a small
[Redux-style](https://en.wikipedia.org/wiki/Redux_%28JavaScript_library%29) store for the sign-in state.
All dependencies are Swift packages — no CocoaPods.

## Requirements

- Xcode 26 or newer (Swift 6 language mode)
- iOS 18.6+ (the app's deployment target; the libraries themselves support iOS 15+)
- A Google account with a YouTube channel that has **live streaming enabled**
  (YouTube Studio → Go live; first-time activation can take up to 24 hours)
- A physical iPhone for streaming (the simulator can manage broadcasts but has no camera)

## Setup

### 1. Google Cloud project

1. Open the [Google Cloud Console](https://console.cloud.google.com) and create a project (or reuse one).
2. **APIs & Services → Library** → enable **YouTube Data API v3**.
3. **APIs & Services → OAuth consent screen**: External, fill in the app name and e-mail; under
   **Scopes** add
   `https://www.googleapis.com/auth/youtube`,
   `https://www.googleapis.com/auth/youtube.readonly` and
   `https://www.googleapis.com/auth/youtube.force-ssl`;
   under **Test users** add the Google account you will sign in with.
   (While the app is in *Testing* status Google shows a "Google hasn't verified this app" page on
   sign-in — tap **Advanced → Go to LiveEvents** — and only test users can sign in. That is enough
   for a sample; verification is only needed for a public release.)
4. **APIs & Services → Credentials → Create credentials → OAuth client ID**, type **iOS**,
   Bundle ID = the app's bundle id (`com.skdevappleid.liveevents` by default — change it to yours
   in Xcode → target → Signing & Capabilities and use the same value here).
5. Note the **Client ID**: `NNNNNNNN-xxxxxxxx.apps.googleusercontent.com`.
   No API key is needed — requests are authorised by the OAuth token.

### 2. Project

```bash
git clone https://github.com/SKrotkih/LiveEvents.git
cd LiveEvents
open LiveEvents.xcodeproj
```

Xcode resolves the Swift packages on first open (see [Libraries](#libraries)).

- Copy `Config.plist.example.plist` to `Config.plist` (it is git-ignored) and put your Client ID
  into `CLIENT_ID`. `API_KEY` can stay as is; it is not used.
- In `Info.plist` → `CFBundleURLSchemes` replace the value starting with
  `com.googleusercontent.apps.` with the **reversed** Client ID:
  `NNNNNNNN-xxxxxxxx.apps.googleusercontent.com` → `com.googleusercontent.apps.NNNNNNNN-xxxxxxxx`.
  This is how the browser returns to the app after sign-in.
- Build and run (⌘R). Sign in, allow the YouTube permissions, and your channel's broadcasts appear.

To work offline or without a channel set `DSSettings.USE_MOCK_DATA = true` in `Constants.swift`;
the list is then served from the JSON fixtures in `LiveEventsTests/JSON`.

### Going live

1. **Add** a broadcast (title, start time) — the app creates the broadcast and its stream in one
   call (`createBroadcastWithStream`).
2. Open the broadcast and tap **Go live**. The app fetches the RTMP ingest URL from YouTube,
   starts the HaishinKit encoder and watches the broadcast with `monitor(broadcastID:)`:
   the status label walks `ready → testing → ● LIVE` as soon as YouTube receives video.
3. Once live, chat messages appear over the preview (`chatMessageStream`).
4. **Finish** ends the broadcast (`transition(.complete)`); the recording stays on the channel and
   can be played back from the list.

## How the pieces fit

| Concern | Where |
|---|---|
| Google Sign-In, scopes, session | [SwiftGoogleSignIn](https://github.com/SKrotkih/swift-googlesignin) 2.0 → `SignInService` → Redux `AuthReduxStore` (session publisher + error publisher) |
| Token → YouTube client | `Network/YTApiProvider.swift`: `ReduxTokenProvider` implements `TokenProvider`; a 401 is retried after `API.refreshTokensIfNeeded()` |
| YouTube Live API | [YTLiveStreaming](https://github.com/SKrotkih/YTLiveStreaming) — `YouTubeLiveClient` (async/await, no third-party dependencies) |
| Broadcast list | `Scenes/VideoList` — `allBroadcasts(.all)` grouped by `LifeCycleStatus` |
| Create / update / delete | `Scenes/AddNewBroadcast`, `Scenes/UpdateBroadcast`, `Scenes/VideoDetails` |
| Live screen | `Scenes/LiveStreaming` — `LivePreviewView` (HaishinKit RTMP encoder), `LiveStreamingViewModel` (Combine), `monitor(broadcastID:)` events, chat overlay |
| Playback of recordings | `Scenes/YouTubeVideoPlayer` — youtube-ios-player-helper (`YTPlayerView`) |

## Libraries

All via Swift Package Manager:

- [YTLiveStreaming](https://github.com/SKrotkih/YTLiveStreaming) ≥ 1.1 — YouTube Live Streaming API
- [SwiftGoogleSignIn](https://github.com/SKrotkih/swift-googlesignin) ≥ 2.0 — thin Combine wrapper over
  [Google Sign-In for iOS](https://github.com/google/GoogleSignIn-iOS) SDK 8
- [ReSwift](https://github.com/ReSwift/ReSwift) — Redux store
- [HaishinKit](https://github.com/shogo4405/HaishinKit.swift) 1.9 — RTMP encoder for the live screen
- [youtube-ios-player-helper](https://github.com/youtube/youtube-ios-player-helper) — iframe player for recorded videos

## Video

![LiveEvents Demo Video](https://user-images.githubusercontent.com/2775621/203057067-4312cba6-dd33-40dc-9fa1-d278e6ce55b9.gif)

## UIKit version

The `UIKit` branch keeps the older UIKit implementation of the app (0.2.x era of the library).

## Logs

The app writes to `OSLog`. In Console.app pick your device or simulator, then filter by
`SUBSYSTEM = <bundle id>` and `CATEGORY = appstate`.

## Troubleshooting

| Symptom | Cause / fix |
|---|---|
| `Your app is missing support for the following URL schemes: com.googleusercontent.apps.…` | The reversed Client ID in `Info.plist` does not match `CLIENT_ID` in `Config.plist`. |
| `Build input file cannot be found: …/Config.plist` | Create `Config.plist` from the example (see Setup). |
| "Google hasn't verified this app" | Expected while the OAuth consent screen is in Testing mode — tap **Advanced → Go to LiveEvents**; your account must be listed as a test user. |
| Alert "did not grant the required permissions" | The Google account declined the YouTube scopes — tap **Ok** to request them again. |
| `Forbidden (403). Request had insufficient authentication scopes.` | The signed-in session was created without YouTube scopes — sign out and sign in again. |
| `Forbidden (403)` with reason `liveStreamingNotEnabled` | Enable live streaming on the channel in YouTube Studio. |
| Package resolution picks an old version | File → Packages → Update to Latest Package Versions, or Reset Package Caches. |
| Status never leaves `ready` on the live screen | The encoder is not reaching YouTube: check the network and that the RTMP URL was fetched (see the status label / Console logs). |

## Author

Serhii Krotkykh

## History

- 16-09-2026 — Swift 6 language mode; UIKit app shell replaced by the SwiftUI `App` lifecycle (`@main`, `WindowGroup`), Redux store made `@MainActor`, the live screen and the YouTube player rebuilt in SwiftUI (Main.storyboard, AppDelegate and the bridging header removed)
- 16-09-2026 — CocoaPods removed: HaishinKit and youtube-ios-player-helper via SPM; XCDYouTubeKit (archived, no longer works with YouTube) and unused PromiseKit dropped; open `LiveEvents.xcodeproj` directly
- 15-09-2026 — SwiftGoogleSignIn 2.0 (Google Sign-In SDK 8): errors on a separate publisher, access-token refresh wired into `TokenProvider`; live screen on HaishinKit + Combine (LFLiveKit and RxSwift removed); live chat overlay via YTLiveStreaming 1.1
- 15-09-2026 — YTLiveStreaming 1.0: `YouTubeLiveClient` + `TokenProvider` bridged to the Redux session, `createBroadcastWithStream`, `monitor(broadcastID:)` instead of the delegate; YouTube scopes requested at sign-in (SwiftGoogleSignIn 1.60); real API by default; README rewritten
- 20-12-2022 — update for YTLiveStreaming 0.2.29, mock data
- 19-12-2022 — update for YTLiveStreaming 0.2.28
- 30-11-2022 — SwiftGoogleSignIn 1.57
- 20-11-2022 — current user session is kept safely
- 20-09-2022 — bug fixes; redesigned home and log-in screens
- 20-07-2022 — Redux pattern for the log-in scene
- 15-07-2022 — CI unit tests with GitHub Actions
- 11-11-2016 — project created
