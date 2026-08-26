import Foundation

/// Test-phase switches. Flip `unlockAllFeatures` to `false` before App Store release.
enum StillwayTesting {
    /// Unlocks Pro sounds, mixer, and auto-start without StoreKit.
    static let unlockAllFeatures = true
}
