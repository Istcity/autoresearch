import AVFoundation
import UIKit
import UserNotifications

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowAirPlay, .allowBluetoothHFP, .allowBluetoothA2DP])
        try? session.setActive(true)
        NotificationScheduler.shared.configure()
        return true
    }
}
