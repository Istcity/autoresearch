import Foundation
import CoreLocation
import CoreMotion
import UserNotifications
import Observation

/// One-shot startup permission priming. Remembers what was asked in UserPreferences.
@MainActor
enum PermissionBootstrap {
    struct Snapshot: Sendable {
        var locationStatus: CLAuthorizationStatus
        var motionStatus: CMAuthorizationStatus
        var notificationsAuthorized: Bool
    }

    static func currentSnapshot() async -> Snapshot {
        let notif = await UNUserNotificationCenter.current().notificationSettings()
        return Snapshot(
            locationStatus: CLLocationManager().authorizationStatus,
            motionStatus: CMMotionActivityManager.authorizationStatus(),
            notificationsAuthorized: notif.authorizationStatus == .authorized
                || notif.authorizationStatus == .provisional
        )
    }

    /// Request every permission Stillway needs and persist that we asked.
    static func requestAll(
        location: LocationManager,
        motion: MotionClassifier,
        preferences: UserPreferences?,
        save: () -> Void
    ) async {
        guard let preferences else {
            location.requestWhenInUse()
            motion.start()
            _ = try? await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            return
        }

        if !preferences.didRequestLocationPermission {
            location.requestWhenInUse()
            // Upgrade path: Always is required for geofence / visit / background commute.
            try? await Task.sleep(for: .milliseconds(600))
            location.requestAlwaysAuthorization()
            preferences.didRequestLocationPermission = true
            preferences.locationPermissionRequestedAt = Date()
        } else if location.authStatus == .authorizedWhenInUse {
            location.requestAlwaysAuthorization()
        }

        if !preferences.didRequestMotionPermission {
            motion.start()
            preferences.didRequestMotionPermission = true
            preferences.motionPermissionRequestedAt = Date()
        } else {
            motion.start()
        }

        if !preferences.didRequestNotificationPermission {
            _ = try? await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            preferences.didRequestNotificationPermission = true
            preferences.notificationPermissionRequestedAt = Date()
        }

        let snap = await currentSnapshot()
        preferences.lastKnownLocationAuthRaw = Int(snap.locationStatus.rawValue)
        preferences.lastKnownMotionAuthRaw = Int(snap.motionStatus.rawValue)
        preferences.lastKnownNotificationAuthorized = snap.notificationsAuthorized
        save()
    }
}
