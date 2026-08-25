# Stillway

Ambient life companion for iOS 17+. Dark-only, offline-first, no account.

Stillway watches where you are and what you are doing, then starts the right ambient sound — commute, focus, reset, sleep — without asking you to pick a track.

Open `Stillway.xcodeproj` in Xcode 16+ on a Mac.

## Requirements

- Xcode 16+
- iOS 17.0 deployment target
- Apple Developer team (set `DEVELOPMENT_TEAM` in the Stillway target)
- Physical device for geofence, motion, and Dynamic Island testing

## First run

1. Open `Stillway.xcodeproj`.
2. Select the **Stillway** scheme.
3. Set your Development Team under Signing & Capabilities.
4. Enable App Groups `group.com.stillway.app` on both the app and the widget if Xcode asks.
5. Run on iPhone or Simulator.

The 12 field recordings are not checked in yet. `AudioEngine` generates looping ambient buffers so playback works immediately. Drop final `.m4a` files into `Stillway/Resources/Sounds/` using the IDs in `Sound.swift` (`tokyo_rain.m4a`, …).

## Layout

```
Stillway.xcodeproj
Stillway/                 App target (SwiftUI)
StillwayWidgets/          Lock Screen, Home Screen, Live Activity
scripts/                  GTFS download + station JSON builder
BUILD_PLAN.md
DESIGN_SYSTEM.md
PRODUCT_SPEC.md
```

Bundle ID: `com.stillway.app`  
Widget: `com.stillway.app.widgets`  
Pro product ID: `stillway.pro.lifetime.499`

## Station database

Sample stops ship in `Stillway/Resources/stations.json`. Full ~56k-stop coverage:

```bash
./scripts/download_gtfs.sh
python3 scripts/build_station_db.py
```

Japan (ODPT) and France (IDFM) feeds need a free API registration. Set `ODPT_GTFS_URL`, `IDFM_GTFS_URL`, and `IBB_GTFS_URL`.

## Languages

Turkish, Japanese, English, French. Change language in Settings — it applies immediately, no relaunch.
