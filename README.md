[![CI](https://github.com/SKrotkih/LiveEvents/actions/workflows/main.yml/badge.svg)](https://github.com/SKrotkih/LiveEvents/actions/workflows/main.yml)

# LiveEvents

A YouTube live-video manager for iOS and the sample app for the
[YTLiveStreaming](https://github.com/SKrotkih/YTLiveStreaming) package: list, schedule, edit and delete
your channel's live broadcasts, then go live from the phone camera.

Built with [SwiftUI](https://developer.apple.com/documentation/SwiftUI),
[Combine](https://developer.apple.com/documentation/Combine),
[Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html) and a small
[Redux-style](https://en.wikipedia.org/wiki/Redux_%28JavaScript_library%29) store for the sign-in state.

## Requirements

- Xcode 16 or newer
- iOS 15+
- [CocoaPods](https://cocoapods.org) (for the video/player pods; the two Swift packages resolve automatically)
- A Google account with a YouTube channel that has **live streaming enabled**
  (YouTube Studio → Go live; first-time activation can take up to 24 hours)

## Setup

### 1. Google Cloud project

1. Open the [Google Cloud Console](https://console.cloud.google.com) and create a project (or reuse one).
2. **APIs & Services → Library** → enable **YouTube Data API v3**.
3. **APIs & Services → OAuth consent screen**: External, fill in the app name and e-mail; under
   **Scopes** add
   `https://www.googleapis.com/auth/youtube` and `https://www.googleapis.com/auth/youtube.force-ssl`;
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
pod install
open LiveEvents.xcworkspace
```

- Copy `Config.plist.example.plist` to `Config.plist` (it is git-ignored) and put your Client ID
  into `CLIENT_ID`. `API_KEY` can stay as is; it is no longer used.
- In `Info.plist` → `CFBundleURLSchemes` replace the value starting with
  `com.googleusercontent.apps.` with the **reversed** Client ID:
  `NNNNNNNN-xxxxxxxx.apps.googleusercontent.com` → `com.googleusercontent.apps.NNNNNNNN-xxxxxxxx`.
  This is how the browser returns to the app after sign-in.
- Build and run (⌘R). Sign in, allow the YouTube permissions, and your channel's broadcasts appear.

To work offline or without a channel set `DSSettings.USE_MOCK_DATA = true` in `Constants.swift`;
the list is then served from the JSON fixtures in `LiveEventsTests/JSON`.

### Going live

The live screen needs a camera, so it runs on a physical iPhone only (the simulator can list,
create and delete broadcasts but cannot stream). Create a broadcast with **Add**, open it, start
the stream: the app fetches the RTMP ingest URL from YouTube, feeds it to the encoder and watches
the broadcast with `monitor(broadcastID:)` until it is live.

## How the pieces fit

| Concern | Where |
|---|---|
| Google Sign-In, scopes, session | [SwiftGoogleSignIn](https://github.com/SKrotkih/SwiftGoogleSignIn) package → Redux `AuthReduxStore` |
| Token → YouTube client | `Network/YTApiProvider.swift`: `ReduxTokenProvider` implements `TokenProvider` from YTLiveStreaming |
| YouTube Live API | [YTLiveStreaming](https://github.com/SKrotkih/YTLiveStreaming) 1.0 — `YouTubeLiveClient` (SPM, no third-party dependencies) |
| Broadcast list | `Scenes/VideoList` — `allBroadcasts(.all)` grouped by `LifeCycleStatus` |
| Create / update | `Scenes/AddNewBroadcast`, `Scenes/UpdateBroadcast` — `createBroadcastWithStream` |
| Live screen | `Scenes/LiveStreaming` — LFLiveKit encoder + `monitor(broadcastID:)` events |
| Playback | XCDYouTubeKit / youtube-ios-player-helper |

## Libraries

- [YTLiveStreaming](https://github.com/SKrotkih/YTLiveStreaming) 1.0 (SPM)
- [SwiftGoogleSignIn](https://github.com/SKrotkih/SwiftGoogleSignIn) 1.60+ (SPM), a thin wrapper over
  [Google Sign-In for iOS](https://developers.google.com/identity/sign-in/ios/start-integrating)
- [ReSwift](https://github.com/ReSwift/ReSwift) (SPM)
- CocoaPods: LFLiveKit, XCDYouTubeKit, youtube-ios-player-helper, RxSwift / RxCocoa / RxDataSources, PromiseKit

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
| Sign-in succeeds but the app returns to the login screen | Old SwiftGoogleSignIn (< 1.60) did not request the YouTube scopes. Update the package (File → Packages → Update to Latest Package Versions) and delete the app from the device to clear the stale session. |
| `Forbidden (403). Request had insufficient authentication scopes.` | The signed-in session was created without YouTube scopes — sign out (or delete the app) and sign in again. |
| `Forbidden (403)` with reason `liveStreamingNotEnabled` | Enable live streaming on the channel in YouTube Studio. |
| `pod install` hangs on "Cloning spec repo" | Remove any `source 'https://github.com/CocoaPods/Specs.git'` line from the Podfile; the CDN is the default. |
| `SDK does not contain 'libarclite'` | Xcode 15+ dropped it; the `post_install` hook in the Podfile raises the pods' deployment target to 13.0 — run `pod install` again. |
| `Build input file cannot be found: …/Config.plist` | Create `Config.plist` from the example (see Setup). |

## Author

Serhii Krotkykh

## History

- 15-09-2026 — YTLiveStreaming 1.0: `YouTubeLiveClient` + `TokenProvider` bridged to the Redux session, `createBroadcastWithStream`, `monitor(broadcastID:)` instead of the delegate; YouTube scopes requested at sign-in (SwiftGoogleSignIn 1.60); real API by default; Podfile fixes for Xcode 15+; README rewritten
- 20-12-2022 — update for YTLiveStreaming 0.2.29, mock data
- 19-12-2022 — update for YTLiveStreaming 0.2.28
- 30-11-2022 — SwiftGoogleSignIn 1.57
- 20-11-2022 — current user session is kept safely
- 20-09-2022 — bug fixes; redesigned home and log-in screens
- 20-07-2022 — Redux pattern for the log-in scene
- 15-07-2022 — CI unit tests with GitHub Actions
- 11-11-2016 — project created
