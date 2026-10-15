# OpenMausBot — Android-native UI mockup (Flutter)

A working UI mockup of the OpenMausBot bot-control app, rebuilt for smartphone
(Android-native) form factors in Flutter. It replicates the user-facing surfaces
catalogued in `OPENMAUSBOT-UI-DIAGNOSTIC.md`, organized with a Discord-style
navigation: a workspace rail (servers) → session drawer (bots, rooms, tools) →
content pane.

## Run it

```bash
cd OMB_native-android
flutter run -d chrome        # web mockup
flutter run -d android       # native on a connected device/emulator
```

Deep links open any screen directly (handy for demos):
`?view=computer`, `?view=botSettings`, `?view=routines`, `?view=calendarGrid`,
`?view=groupRoom`, `?view=inspector`, `?view=appsMarket`, `?view=onboarding`,
`?view=setupStates`, `?view=uiKit`, `?view=newBot`, `?view=voiceCall`,
`?view=usage`, `?view=teamMap`, `?view=activity`.

## What's in the mockup

- **Chat** — tool chips, decision cards (approval / question / secret / widget /
  verify / screenshot / error+retry), queued-message chips with steer, smart
  composer (send → steer → queue), approval-mode selector, edit branches.
- **Bot Settings** — Identity / Brain / Permissions / Knowledge, gated by a
  Simple ↔ Advanced master switch (drawer footer).
- **Computer Panel** — destination grid, live view with the Take-control lease,
  browser profiles, safety rows.
- **Routines + Calendar grid** — run logs and webhooks, plus a drag-and-drop
  week grid with the full event editor (cron preview, overlap policy, …).
- **Group Room** — bulletin, member manager, responder modes, goal runs.
- **Team Map**, **Activity**, **Inspector**, **Apps/MCP marketplace**,
  **App Settings**, **Usage & spend**.
- **New Bot wizard** (9 steps), **Voice call overlay**, **Onboarding tour**,
  **setup states** (no engines / cloud sign-in / cloud intent),
  **Command Palette**, **Keyboard Shortcuts**.
- **UI Kit** (`?view=uiKit`) — the complete component inventory.

## CI builds (recommended for APKs)

Compiling the Android APK needs Gradle + NDK downloads; run it in GitHub Actions
instead of locally. The workflow **`omb-mockup-build`**
(`.github/workflows/omb-mockup-build.yml`) is `workflow_dispatch`-only and
uploads artifacts:

- `omb-android-apk` — `app-release.apk`
- `omb-web-bundle` — the built web bundle

It runs `flutter analyze` + `flutter test` first and pins Flutter 3.44.8 to
match the local toolchain. Trigger it from the Actions tab (or
`gh workflow run omb-mockup-build`).

## Validation

- `flutter analyze` — clean
- `flutter test` — 4/4, including interactivity tests (approval resolution,
  queue/steer, question answering)
- `flutter build web` — succeeds (verified locally)
- APK build — delegated to CI (see above)

## Scope

Mockup only: state is a plain in-memory `AppState` (`lib/state.dart`) with mock
threads in `lib/mock_data.dart`. No network, no harness server, no persistence.
Touch targets are sized for phones; layouts adapt: the session drawer is a
slide-over below 900 px, inline above it.
