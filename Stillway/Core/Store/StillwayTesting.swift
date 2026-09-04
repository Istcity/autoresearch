import Foundation

/// Test-phase switches.
/// Debug builds unlock Pro for local QA; Release / App Store builds keep the real StoreKit gate.
enum StillwayTesting {
#if DEBUG
    static let unlockAllFeatures = true
#else
    static let unlockAllFeatures = false
#endif
}
